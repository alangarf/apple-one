module vga(
    input clk25,            // clock signal
    input enable,           // clock enable strobe,
    input rst,              // active high reset signal
    output vga_h_sync,      // horizontal VGA sync pulse
    output vga_v_sync,      // vertical VGA sync pulse
    output vga_red,         // red VGA signal
    output vga_grn,         // green VGA signal
    output vga_blu,         // blue VGA signal
    input address,          // address bus
    input w_en,             // active high write enable strobe
    input [7:0] din,        // 8-bit data bas (input)
    input clr_screen_btn,   // active high clear screen button
    input blink_clken,      // cursor blink enable strobe
    output [15:0] debug
    );

    reg [4:0] c_rom[0:447] /* synthesis syn_ramstyle = "block_ram" */;
    initial begin
        $readmemb("../../roms/vga_font.bin", c_rom, 0, 447);
    end

    reg [9:0] vram_r_addr;
    reg [9:0] vram_w_addr;
    reg vram_r_en;
    reg vram_w_en;
    reg [5:0] vram_din;
    reg [5:0] vram_dout;

    vram my_vram(
        .clk(clk25),
        .read_addr(vram_r_addr),
        .write_addr(vram_w_addr),
        .r_en(vram_r_en),
        .w_en(vram_w_en),
        .din(vram_din),
        .dout(vram_dout)
    );

    // video structure constants
    parameter hpixels = 800;    // horizontal pixels per line
    parameter vlines = 521;     // vertical lines per frame
    parameter hpulse = 96;      // hsync pulse length
    parameter vpulse = 2;       // vsync pulse length
    parameter hbp = 144;        // end of horizontal back porch
    parameter hfp = 784;        // beginning of horizontal front porch
    parameter vbp = 31;         // end of vertical back porch
    parameter vfp = 511;        // beginning of vertical front porch

    // registers for storing the horizontal & vertical counters
    reg [9:0] hc;
    reg [9:0] vc;
    reg [5:0] hpos;
    reg [4:0] vpos;
    reg [3:0] hdot;
    reg [4:0] vdot;

    reg [5:0] h_cursor;
    reg [4:0] v_cursor;

    wire vga_h_act;
    wire vga_v_act;

    assign vga_h_act = (hc >= hbp && hc < hfp);
    assign vga_v_act = (vc >= vbp && vc < vfp);

    assign vga_h_sync = (hc < hpulse) ? 0 : 1;
    assign vga_v_sync = (vc < vpulse) ? 0 : 1;
    //assign vblank = (vc >= vbp && vc < vfp) ? 0:1;

    always @(posedge clk25)
    begin
        if (hc < hpixels - 1)
        begin
            hc <= hc + 1;

            // count 16 pixels, so 640px / 16 = 40 characters
            if (vga_h_act)
            begin
                hdot <= hdot + 1;

                if (hdot == 4'hF)
                begin
                    hdot <= 0;
                    hpos <= hpos + 1;
                end
            end
        end
        else
        begin
            // reset horizontal counters
            hc <= 0;
            hdot <= 0;
            hpos <= 0;

            if (vc < vlines - 1)
            begin
                vc <= vc + 1;

                // count 20 rows, so 480px / 20 = 24 rows
                if (vga_v_act)
                begin
                    vdot <= vdot + 1;

                    if (vdot == 5'd19)
                    begin
                        vdot <= 0;
                        vpos <= vpos + 1;
                    end
                end
            end
            else
            begin
                // reset vertical counters
                vc <= 0;
                vdot <= 0;
                vpos <= 0;
            end
        end
    end

    reg out;
    assign vga_red = out;
    assign vga_grn = out;
    assign vga_blu = out;

    reg [8:0] cur_chr_offset;
    reg [9:0] v_pos_offset;
    reg [3:0] v_offset;
    reg [2:0] h_offset;
    reg blink;

    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
        begin
            vram_r_addr = 10'd0;
            vram_r_en = 1'b0;
        end
        else
        begin
            // get the current character from vram and build
            // offset to map into character ROM (5x7 font)
            if (blink && (hpos == h_cursor && vpos == v_cursor))
                cur_chr_offset = 9'd0; // the @ character
            else
            begin
                vram_r_en = 1'b1;
                v_pos_offset = (vpos * 40);
                vram_r_addr = (v_pos_offset + {4'b0, hpos});
                cur_chr_offset = (vram_dout * 7);

                //cur_chr_offset <= (v_ram[hpos + (40 * vpos)] * 7);
            end

            case ({vga_h_act, vga_v_act})
            default:
                // outside display area
                out = 1'b0;

            2'b11:
            begin
                // we're inside the visible screen display frame
                //
                // scan doubling is achieved by ignoring bit 0 of both vdot
                // and hdot counters, in affect doubling the pixel size
                // (each pixel becomes screen pixels)
                case (vdot[4:1])
                4'b0000,
                4'b0001,
                4'b1001:
                begin
                    // blank lines for spacing
                    out = 1'b0;
                end

                default:
                begin
                    // work out character rom offset for current line
                    // taking away 2 from counter to allow for the two
                    // blank preceding lines
                    v_offset = (vdot[4:1] - 2);

                    case (hdot[3:1])
                    3'b000,
                    3'b110,
                    3'b111:
                    begin
                        // blank columns for spacing
                        out = 1'b0;
                    end

                    default:
                    begin
                        // work out the character rom offset for the current
                        // column. We reverse the dot pattern by subtracting
                        // the column from the number of pixel in the
                        // character row in rom
                        h_offset = (5 - hdot[3:1]);

                        // grab the pixel from the character rom for
                        // the given screen column and line
                        out = c_rom[cur_chr_offset + {5'b0, v_offset}][h_offset];
                    end
                    endcase
                end
                endcase
            end
            endcase
        end
    end

    reg cls_flag, cls_running;
    reg char_seen;

    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
        begin
            blink <= 1'b1;
            h_cursor <= 6'd0;
            v_cursor <= 5'd0;
            char_seen <= 0;
            debug <= 0;
            cls_running <= 0;
            cls_flag <= 1;
        end
        else
        begin
            if (cls_flag || clr_screen_btn)
            begin
                if ((vpos == 0) && (hpos == 0))
                    cls_running <= 1;

                if (cls_running)
                begin
                    // clear the vram using the position pointers
                    // very similar to the original apple 1 :)
                    vram_w_addr <= ((vpos * 40) + {4'b0, hpos});
                    vram_din <= 6'd0;
                    vram_w_en <= 1;

                    if ((vpos == 23) && (hpos == 40))
                    begin
                        cls_running <= 0;
                    end
                end
                else
                begin
                    cls_flag <= 0;
                end
            end
            begin
                vram_w_en <= 0;

                if (address == 1'b0) // address low == TX register
                begin
                    if (enable & w_en & ~char_seen)
                    begin
                        // incoming character
                        debug <= {8'd0, din};
                        char_seen <= 1;

                        case(din)
                        8'h8D:
                        begin
                            // handle carriage return
                            h_cursor <= 0;
                            v_cursor <= v_cursor + 1;
                        end

                        8'h7F:
                            // ignore the DDR call to the PIA
                            h_cursor <= h_cursor + 1;

                        default:
                        begin
                            vram_w_addr <= ((v_cursor * 40) + {4'b0, h_cursor});
                            vram_din <= {~din[6], din[4:0]};
                            vram_w_en <= 1;

                            h_cursor <= h_cursor + 1;
                        end
                        endcase

                        if (h_cursor == 39)
                        begin
                            h_cursor <= 0;
                            v_cursor <= v_cursor + 1;
                        end

                        if (v_cursor == 23)
                        begin
                            // here we need to add the scroll, probably by moving the
                            // HEAD of vram up one line
                            v_cursor <= 0;
                        end

                    end
                    else if(~enable & ~w_en)
                        char_seen <= 0;
                end
            end

            if (blink_clken)
                blink <= ~blink;
        end
    end
endmodule
