module vga2tmds (
	input  wire        clkp,
	input  wire        clkt, // 10x clkp
	input  wire        vsync,
	input  wire        hsync,
	input  wire        de,
	input  wire  [7:0] r,
	input  wire  [7:0] g,
	input  wire  [7:0] b,
	output logic [3:0] tmds
);
	assign tmds[0] = bts[0];
	assign tmds[1] = gts[0];
	assign tmds[2] = rts[0];
	assign tmds[3] = clkp;

	logic [3:0] counter;
	logic       load;
	logic [9:0] rt, gt, bt;
	logic [9:0] rts, gts, bts;

	tmds_encoder B_encode (clkp, b, {vsync, hsync}, de, bt);
	tmds_encoder G_encode (clkp, g, {2'b0},         de, gt);
	tmds_encoder R_encode (clkp, r, {2'b0},         de, rt);

	always_ff @(posedge clkt) begin
		load <= (counter == 4'd9);

		rts <= load ? rt : {1'b0, rts[9:1]};
		gts <= load ? gt : {1'b0, gts[9:1]};
		bts <= load ? bt : {1'b0, bts[9:1]};

		counter <= (counter == 4'd9) ? 4'b0 : counter + 1;
	end
endmodule
