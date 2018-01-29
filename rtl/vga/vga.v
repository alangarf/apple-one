module vga(
    input clk25,
    input [6:0] in,
    input in_stb,
    output vga_h_sync,
    output vga_v_sync,
    output reg vga_red,
    output reg vga_grn,
    output reg vga_blu
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


    always @(posedge clk25)
    begin
        if (~(vga_h_act && vga_v_act))
        begin
            // outside display area
            vga_red = 0;

        end else begin
            // inside display area

            if (vdot[4:1] == 0 || vdot[4:1] == 1 || vdot[4:1] == 9 || hdot[3:1] == 0 || hdot[3:1] == 6 || hdot[3:1] == 7)
                vga_red = 0;
            else
                vga_red = c_rom[(v_ram[hpos + (vpos * 40)] * 7) + (vdot[4:1] - 2)][5 - hdot[3:1]];

        end

        vga_grn = vga_red;
        vga_blu = vga_red;
    end

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
