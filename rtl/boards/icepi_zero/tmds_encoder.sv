module tmds_encoder (
	input  wire        clk,
	input  wire  [7:0] data,
	input  wire  [1:0] c,
	input  wire        de,
	output logic [9:0] out
);
	// https://www.fpga4fun.com/files/dvi_spec-V1_0.pdf Page 29
	wire [3:0] Nb1s = data[0] + data[1] + data[2] + data[3] + data[4] + data[5] + data[6] + data[7];

	wire XNOR = (Nb1s>4'd4) || (Nb1s==4'd4 && data[0]==1'b0);
	wire [8:0] q_m = {~XNOR, q_m[6:0] ^ data[7:1] ^ {7{XNOR}}, data[0]};

	logic [3:0] balance_acc;
	wire [3:0] balance = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7] - 4'd4;
	wire balance_sign_eq = (balance[3] == balance_acc[3]);
	wire invert_q_m = (balance==0 || balance_acc==0) ? ~q_m[8] : balance_sign_eq;
	wire [3:0] balance_acc_inc = balance - ({q_m[8] ^ ~balance_sign_eq} & ~(balance==0 || balance_acc==0));
	wire [3:0] balance_acc_new = invert_q_m ? balance_acc-balance_acc_inc : balance_acc+balance_acc_inc;

	initial begin
		balance_acc = 0;
	end

	always_ff @(posedge clk) begin 
		if (de) begin
			out <= {invert_q_m, q_m[8], q_m[7:0] ^ {8{invert_q_m}}};

			balance_acc <= balance_acc_new;
		end else begin
			case (c)
				2'b00: begin
					out <= 10'b1101010100;
				end
				2'b01: begin
					out <= 10'b0010101011;
				end
				2'b10: begin
					out <= 10'b0101010100;
				end
				2'b11: begin
					out <= 10'b1010101011;
				end
			endcase

			balance_acc <= 4'b0;
		end
	end
endmodule
