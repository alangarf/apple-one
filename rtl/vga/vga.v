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
    input blink_clken      // cursor blink enable strobe
    );

    //////////////////////////////////////////////////////////////////////////
    // VGA Sync Generation

    // video structure constants
    parameter h_pixels = 799;   // horizontal pixels per line
    parameter v_lines = 520;    // vertical lines per frame
    parameter h_pulse = 96;     // hsync pulse length
    parameter v_pulse = 2;      // vsync pulse length
    parameter hbp = 144;        // end of horizontal back porch
    parameter hfp = 784;        // beginning of horizontal front porch
    parameter vbp = 31;         // end of vertical back porch
    parameter vfp = 511;        // beginning of vertical front porch

    // registers for storing the horizontal & vertical counters
    reg [9:0] h_cnt;
    reg [9:0] v_cnt;
    wire [3:0] h_dot;
    reg [4:0] v_dot;

    reg [5:0] h_cursor;
    reg [4:0] v_cursor;

    wire h_active;
    wire v_active;
    assign h_active = (h_cnt >= hbp && h_cnt < hfp);
    assign v_active = (v_cnt >= vbp && v_cnt < vfp);

    assign vga_h_sync = (h_cnt < h_pulse) ? 0 : 1;
    assign vga_v_sync = (v_cnt < v_pulse) ? 0 : 1;

    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
        begin
            h_cnt <= 10'd0;
            v_cnt <= 10'd0;
            v_dot <= 5'd0;
        end
        else
        begin
            if (h_cnt < h_pixels)
                h_cnt <= h_cnt + 1;

            else
            begin
                // reset horizontal counters
                h_cnt <= 0;

                if (v_cnt < v_lines)
                begin
                    v_cnt <= v_cnt + 1;

                    // count 20 rows, so 480px / 20 = 24 rows
                    if (v_active)
                    begin
                        v_dot <= v_dot + 1;

                        if (v_dot == 5'd19)
                            v_dot <= 0;
                    end
                end
                else
                begin
                    // reset vertical counters
                    v_cnt <= 0;
                    v_dot <= 0;
                end
            end
        end
    end

    // count 16 pixels, so 640px / 16 = 40 characters
    assign h_dot = h_active ? h_cnt[3:0] : 4'd0;

    //////////////////////////////////////////////////////////////////////////
    // Character ROM

    wire [5:0] font_char;
    wire [3:0] font_pixel;
    wire [4:0] font_line;
    wire font_out;

    font_rom my_font_rom(
        .clk(clk25),
        .character(font_char),
        .pixel(font_pixel),
        .line(font_line),
        .out(font_out)
    );

    //////////////////////////////////////////////////////////////////////////
    // Video RAM

    wire [9:0] vram_r_addr;
    reg [9:0] vram_w_addr;
    reg vram_w_en;
    reg [5:0] vram_din;
    wire [5:0] vram_dout;

    vram my_vram(
        .clk(clk25),
        .rst(rst),
        .read_addr(vram_r_addr),
        .write_addr(vram_w_addr),
        .r_en(h_active),
        .w_en(vram_w_en),
        .din(vram_din),
        .dout(vram_dout)
    );


    reg [5:0] vram_h_addr;
    reg [9:0] vram_v_addr;

    //////////////////////////////////////////////////////////////////////////
    // Video Signal Generation

    always @(posedge clk25 or posedge rst) begin
        if (rst) begin
            vram_h_addr <= 0;
            vram_v_addr <= 0;
        end else begin
            // start the pipeline for reading vram and font details
            // 3 pixel clock cycles early
            if (h_dot == 4'hC)
                vram_h_addr <= vram_h_addr + 1;

            // advance to next row when last display line is reached for row
            if (v_dot == 5'd19 && h_cnt == 10'd0)
                vram_v_addr <= vram_v_addr + 10'h28;

            // clear the address registers if we're not in visible area
            if (~h_active)
                vram_h_addr <= 0;
            if (~v_active)
                vram_v_addr <= 0;
        end
    end

    assign vram_r_addr = ({4'd0, vram_h_addr} + vram_v_addr);
    assign font_char = vram_dout;
    assign font_pixel = h_dot + 1; // offset by one to get pixel into right cycle,
                                   // font output one pixel clk behind
    assign font_line = v_dot;

    assign vga_red = font_out;
    assign vga_grn = font_out;
    assign vga_blu = font_out;

    reg char_seen;

    always @(posedge clk25 or posedge rst)
    begin
        if (rst)
        begin
            h_cursor <= 6'd0;
            v_cursor <= 5'd0;
            char_seen <= 0;
        end
        else
        begin
            vram_w_en <= 0;

            if (address == 1'b0) // address low == TX register
            begin
                if (enable & w_en & ~char_seen)
                begin
                    // incoming character
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
    end

endmodule
