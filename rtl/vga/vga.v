module vga(
    input clk25,
    input [6:0] in,
    input in_stb,
    output vga_h_sync,
    output vga_v_sync,
    output vga_red,
    output vga_grn,
    output vga_blu
    );
    
    reg [5:0] v_ram[0:959] /* synthesis syn_ramstyle = "block_ram" */;
    reg [4:0] c_rom[0:447] /* synthesis syn_ramstyle = "block_ram" */;
    initial begin
        $readmemb("../../roms/vga_vram.bin", v_ram, 0, 959);
        $readmemb("../../roms/vga_font.bin", c_rom, 0, 447);
    end

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

    wire vga_h_act;
    wire vga_v_act;

    assign vga_h_act = (hc >= hbp && hc < hfp);
    assign vga_v_act = (vc >= vbp && vc < vfp);

    assign vga_h_sync = (hc < hpulse) ? 0 : 1;
    assign vga_v_sync = (vc < vpulse) ? 0 : 1;
    // assign vblank = (vc >= vbp && vc < vfp) ? 0:1;

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

    always @(posedge clk25)
    begin
        case ({vga_h_act, vga_v_act})
        default:
            begin
                // outside display area
                out = 1'b0;
            end

        2'b11:
            begin
                // inside display frame
                case (vdot)
                5'b00000,
                5'b00001,
                5'b00010,
                5'b00011,
                5'b10010,
                5'b10011:
                    // blank row for spacing
                    out = 1'b0;

                default:
                    case (hdot)
                    4'b0000,
                    4'b0001,
                    4'b1100,
                    4'b1101,
                    4'b1110,
                    4'b1111:
                        // blank column for spacing
                        out = 1'b0;

                    default:
                        // into character pixels
                        // TODO: fix this mess
                        out = c_rom[(v_ram[hpos + (vpos * 40)] * 7) + (vdot[4:1] - 2)][5 - hdot[3:1]];
                    endcase
                endcase
            end
        endcase
    end

    // FIXME: This is horrible
    reg [5:0] cur_pos;
    reg stb;
    always @(posedge clk25)
    begin
        if (in_stb & ~stb)
        begin
            v_ram[{4'b0, cur_pos}] <= {~in[6], in[4:0]};
            stb <= 1;
            cur_pos <= cur_pos + 1;
        end

        if (~in_stb & stb)
        begin
            stb <= 0;
        end
    end
endmodule
