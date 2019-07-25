// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//
// Description: Display Controller for Nexys 3 with Spartan 6
//
// Author.....: Oskar A. Stepien
// Date.......: 25-2-2019
// 

module display(
		input [3:0] pick,
		input clk,
		input [1:0] block,
		output reg [6:0] seg,
		output reg [3:0] an,
		output reg dp
    );
	
	reg [31:0] x;
	wire [1:0] s;	 
	reg [3:0] digit;
	wire [3:0] aen;
	reg [19:0] clkdiv = 0;

	assign s = clkdiv[19:18];
	assign aen = 4'b1111; // all turned off initially


//Write usign 32b the info to show. MUST BE CHANGED/APPEND if wnat to add new programs.
always @(*) begin			////4. ADD VALUES FOR DISPLAY (4 DIGITS 7 SEGMENTS+DP)
	case(block)
		0: begin
			case(pick)
				0: x = 32'b01000000101010111100000111000111; //0.nUL 
				1: x = 32'b01111001100010001011000011000000; //1.A30
				2: x = 32'b00100100100010111000011011000111; //2.hEL 
				3: x = 32'b00110000110001111100000110101011; //3.LUn
				4: x = 32'b00011001100010011000011010001001; //4.HEH (MEM)
				5: x = 32'b00010010111000111100011010001011; //5.uCh
				6: x = 32'b00000010100011001000100010010010; //6.PAS
				7: x = 32'b01111000100100101000011111111001; //7.ST1   
				8: x = 32'b00000000100100101000011110100100; //8.ST2
				9: x = 32'b00010000110001111000011110100011; //9.LTO
				
				default: x = 32'b10000000100000001000000010000000; //8888
			
			endcase
			end
		1: begin
			case(pick)
				0: x = 32'b01000000100000111110000011111001; //0.bJ1 
				1: x = 32'b01111001100000111110000010100100; //1.bJ2
				2: x = 32'b00100100110001101000101011111001; //2.Ck1 
				3: x = 32'b00110000110001101000101010100100; //3.Ck2
				4: x = 32'b00011001100010111000100011111001; //4.hA1
				5: x = 32'b00010010100010111000100010100100; //5.hA2
				6: x = 32'b00000010100010011000011111111001; //6.Mt1
				7: x = 32'b01111000100010011000011110100100; //7.Mt2   
				8: x = 32'b00000000100100101100011111111001; //8.SL1
				9: x = 32'b00010000100100101100011110100100; //9.SL2
				
				default: x = 32'b10000000100000001000000010000000; //8888
			
			endcase
			end
		2: begin
			case(pick)
				0: x = 32'b01000000100010011010001110101011; //0.Mon 
				1: x = 32'b01111001100010011000110011111001; //1.Wp1 (HP2)
				2: x = 32'b00100100100010011000110010100100; //2.Wp2 (HP2)
				3: x = 32'b00110000110001101000101011111001; //3.Ck1 
				4: x = 32'b00011001110001101000101010100100; //4.Ck2			
				
				default: x = 32'b10000000100000001000000010000000; //8888
			
			endcase
			end
		default: x = 32'b10000000100000001000000010000000; //8888
	endcase
end

//Select what show in each digit of the display
always @(posedge clk)
begin
	case(s)
		0:	begin
			dp = x[7];
			seg = x[6:0];
			end
		1:	begin
			dp = x[15];
			seg = x[14:8];
			end
		2:	begin
			dp = x[23];
			seg = x[22:16];
			end
		3:	begin
			dp = x[31];
			seg = x[30:24];
			end
		default:digit = x[3:0];
	endcase
end
	
always @(*)
begin
	an=4'b1111;
	if(aen[s] == 1)
	an[s] = 0;
end

//clkdiv
//Asign the digit to show procedurally, depend of the clock
always @(posedge clk) 
begin
	clkdiv <= clkdiv[19:0]+1'b1;
end

endmodule
