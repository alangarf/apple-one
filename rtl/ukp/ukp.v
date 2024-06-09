module ukp(
    clk25,
    clkusb,
    rst,
    usb_en,
    usb_dm_in,
    usb_dm_out,
    usb_dp_in,
    usb_dp_out,
    record_n,
    kbd_adr,
    kbd_data
);
	input clk25;
	input clkusb;
    input rst;
	input usb_dm_in;
	input usb_dp_in;
	input [3:0] kbd_adr;
	output usb_en;
    output usb_dm_out;
    output usb_dp_out;
	output record_n;
	output [7:0] kbd_data;

	parameter S_OPCODE = 0;
	parameter S_LDI0 = 1;
	parameter S_LDI1 = 2;
	parameter S_B0 = 3;
	parameter S_B1 = 4;

    parameter I_LDI    = 4'b0001;
    parameter I_START  = 4'b0010;

    parameter I_OUT0   = 4'b0100;
    parameter I_OUT1   = 4'b0101;
    parameter I_OUT2   = 4'b0110;
    parameter I_HZ     = 4'b0111;

    parameter I_BZ     = 4'b1000;
    parameter I_BC     = 4'b1001;
    parameter I_BNAK   = 4'b1010;
    parameter I_DJNZ   = 4'b1011;

    parameter I_TOGGLE = 4'b1100;
    parameter I_IN     = 4'b1101;
    parameter I_WAIT   = 4'b1110;

	function sel4;
		input [1:0] sel;
		input [3:0] a;
		case (sel)
			2'b00: sel4 = a[3];
			2'b01: sel4 = a[2];
			2'b10: sel4 = a[1];
			2'b11: sel4 = a[0];
		endcase
	endfunction

	function [3:0] decode4;
		input [1:0] sel;
		input g;
		if (g)
			case (sel)
				2'b00: decode4 = 4'b0001;
				2'b01: decode4 = 4'b0010;
				2'b10: decode4 = 4'b0100;
				2'b11: decode4 = 4'b1000;
			endcase
		else decode4 = 4'b0000;
	endfunction

	wire [3:0] inst;
	wire sample;
	reg connected;
    reg inst_ready;
    reg g;
    reg p;
    reg m;
    reg cond;
    reg nak;
    reg dm1;
	reg bank;
    reg record1;
	reg [2:0] state;
	reg [7:0] w;
	reg [9:0] pc;
	reg [2:0] timing;
	reg [3:0] tmp;
	reg [13:0] interval;
	reg [5:0] bitadr;
	reg [7:0] data;

	ukprom ukprom(
        .clk(clkusb),
        .adr(pc),
        .data(inst)
    );

	wire interval_cy = interval == 12001;
	wire next = ~(state == S_OPCODE & (
		~inst[3] & inst[2] & timing != 0 |
		~inst[3] & ~inst[2] & inst[1] & usb_dm_in |
		inst == 4'b1110 & ~interval_cy |
		inst == 4'b1101 & (~sample | (usb_dp_in | usb_dm_in) & w != 1)
	));
	wire branch = state == S_B1 & cond;
	wire record;
	wire [7:0] map;
	wire [3:0] keydata;

	always @(posedge clkusb or posedge rst)
    begin
        if (rst)
        begin
            connected <= 0;
            inst_ready <= 0;
            g <= 0;
            p <= 0;
            m <= 0;
            cond <= 0;
            nak <= 0;
            dm1 <= 0;
            bank <= 0;
            record1 <= 0;
            state <= 3'd0;
            w <= 8'd0;
            pc <= 10'd0;
            timing <= 3'd0;
            tmp <= 4'd0;
            interval <= 14'd0;
            bitadr <= 6'd0;
            data <= 8'd0;
        end
        else
        begin
            if (inst_ready)
            begin
                if (state == S_OPCODE)
                begin
                    // set LDI
                    if (inst == I_LDI) state <= S_LDI0;

                    // set connected
                    if (inst == I_TOGGLE) connected <= ~connected;

                    // handle USB outputs when timing is 0
                    if (~inst[3] & inst[2] & timing == 0)
                    begin
                        g <= ~inst[1] | ~inst[0];
                        p <= ~inst[1] & inst[0];
                        m <= inst[1] & ~inst[0];
                    end

                    // handle branching
                    if (inst[3] & ~inst[2])
                    begin
                        state <= S_B0;
                        cond <= sel4(inst[1:0], {~usb_dm_in, connected, nak, w != 1});
                    end

                    if (inst == 4'b1011 | inst == 4'b1101 & sample) w <= w - 1;
                end

                if (state == S_LDI0)
                begin
                    w[3:0] <= inst;
                    state <= S_LDI1;
                end

                if (state == S_LDI1)
                begin
                    w[7:4] <= inst;
                    state <= S_OPCODE;
                end

                if (state == S_B0)
                begin
                    tmp <= inst;
                    state <= S_B1;
                end

                if (state == S_B1)
                begin
                    state <= S_OPCODE;
                end

                if (next | branch)
                begin
                    pc <= branch ? { inst, tmp, 2'b00 } : pc + 1;
                    inst_ready <= 0;
                end
            end
            else
            begin
                inst_ready <= 1;
            end

            if (inst_ready & state == S_OPCODE & inst == 4'b0010)
            begin
                timing <= 0;
                bitadr <= 0;
                nak <= 1;
            end
            else
            begin
                timing <= timing + 1;
            end

            if (sample)
            begin
                if (bitadr == 8) nak <= usb_dm_in;
                data[6:0] <= data[7:1];
                data[7] <= dm1 ~^ usb_dm_in;
                dm1 <= usb_dm_in;
                bitadr <= bitadr + 1;
            end

            interval <= interval_cy ? 0 : interval + 1;
            record1 <= record;

            if (~record & record1)
            begin
                bank <= ~bank;
            end
        end
	end

	assign usb_dp = g ? p : 1'bZ;
	assign usb_dm = g ? m : 1'bZ;
	assign sample = inst_ready & state == S_OPCODE & inst == 4'b1101 & timing == 1;
	assign record = connected & ~nak;
	assign record_n = ~record;

	keymap keymap(
        .clk(clkusb),
        .adr({ ~timing[0], data[6:0] }),
        .data(map)
    );

	wire mod = bitadr == 24;
	assign keydata = mod ? { data[0] | data[4], data[1] | data[5], data[2] | data[6], data[3] | data[7] } : decode4(map[1:0], record1);

	wire [4:0] kbd_adr_in = record1 ? mod ? 5'b10001 : map[6:2] : interval[4:0];

    ukpram my_ukpram(
        .clk25(clk25),
        .read_addr({~bank, kbd_adr}),
        .r_en(1'b1),
        .dout(kbd_data),

        .clkusb(clkusb),
        .write_addr({bank, kbd_adr_in}),
        .w_en(
            (~record1 | (mod | bitadr == 40 | bitadr == 48) & (timing == 0 | timing == 1)) &&
            (~record1 | mod | map[7])
        ),
        .din(keydata)
    );

    //RAMB4_S4_S8 keyboard(
        //.WEA(~record1 | (mod | bitadr == 40 | bitadr == 48) & (timing == 0 | timing == 1)),
        //.ENA(~record1 | mod | map[7]),

        //.RSTA(1'b0),
        //.CLKA(clk12),
        //.ADDRA({ 4'b0000, bank, kbd_adr_in }),
        //.DIA(keydata),

        //.WEB(1'b0),
        //.ENB(1'b1),

        //.RSTB(1'b0),
        //.CLKB(clk12),
        //.ADDRB({ 4'b0000, ~bank, kbd_adr}),
        //.DIB(8'h00),
        //.DOB(kbd_data)
    //);
endmodule
