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
// Description: 8KB RAM for system
//
// Author.....: Alan Garfield
//              Niels A. Moseley
//					 Oskar A. Stepien
// Date.......: 06-05-2019
//

module ram #(
	parameter RAM_FILENAME        = "roms/ram_ise.hex",
	parameter PROGS					 = "progs_apple/programs.hex" //'macro'file with 16 programs in 23 parts 
																					// (from the Original Apple I 
																					//[https://linuxcoffee.com/apple1/software/notes.html])
) (
	input clk,              // clock signal
	input [12:0] address,   // address bus
	input w_en,             // active high write enable strobe
	input [7:0] din,        // 8-bit data bus (input)
	input [3:0] pick,			// program selected
	input [1:0] block,		// block selected
	input select,				// Load button	
	output reg [7:0] dout,   // 8-bit data bus (output)
	output reg ctrl_led_Init,
	output reg ctrl_led_Loading
);
	//Need to CHANGE in case of any NEW PROGRAM is added
	reg [7:0] ram_data[0:8191];
	reg [7:0] programs[0:40488]; //5. SIZE OF THE FILE PROGS (ALL-1)
	
	reg start;						//Flag to prepare the load
	reg [13:0] addressMem;		//Counter for the RAM
	reg rdy;							//Flag to start the load
	reg fnl;							//Flag to fill the remaining memory with 00
	reg finish;						//Flag to exit the loading
	reg [15:0] pos;			//Position where want to write in the RAM
	reg [15:0] size;			//Size of the program/part to load
	reg [15:0] add_prog;		//Position in the programs file

	initial
	begin
		//Need to CHANGE in case of any NEW PROGRAM is added
		$readmemh(RAM_FILENAME, ram_data, 0, 8191);
		$readmemh(PROGS, programs, 0, 40488);	//5. SIZE OF THE FILE PROGS (ALL-1)
		
		start <= 1'b0;
	end

	always @(posedge clk)
	begin
		if(select == 1'b0)
		begin
			if(start == 1'b0)
			begin
				ctrl_led_Init <= 1'b1;
				addressMem <= 14'd639;
				rdy <= 1'b0;
				fnl <= 1'b0;
				finish <= 1'b0;
				
				//Find which configuration need the selected program
				//
				//		-	"position to load"
				//		-	"size of the program"
				//		-	"postion in the file of the program (start)"
				//		-	[*]"special assign to adressMem paarameter"
				//
				
				case(block) 			//6. ADD NEW CASE
					0: begin
						case(pick)
							0: begin
									pos <= 16'd1;
									size <= 16'b0;
									add_prog <= 16'b0;
									addressMem <= 14'd0;
								end
							1: begin
									pos <= 16'd640;
									size <= 16'd3456;
									add_prog <= 16'd1;
								end
							2: begin
									pos <= 16'd640;
									size <= 16'd24;
									add_prog <= 16'd3457;
								end
							3: begin
									pos <= 16'd768;
									size <= 16'd1721;
									add_prog <= 16'd3481;
								end
							4: begin
									pos <= 16'd640;
									size <= 16'd290;
									add_prog <= 16'd5202;
								end
							5: begin
									pos <= 16'd4096;
									size <= 16'd2304;
									add_prog <= 16'd5492;
								end
							6: begin
									pos <= 16'd768;
									size <= 16'd566;
									add_prog <= 16'd7796;
								end
							7: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd8362;
									addressMem <= 14'd0;
								end
							8: begin
									pos <= 16'd768;
									size <= 16'd3328;
									add_prog <= 16'd8544;
								end
							9: begin
									pos <= 16'd768;
									size <= 16'd4558;
									add_prog <= 16'd11872;
								end
							default: 
								begin
									pos <= 16'd1;
									size <= 16'd0;
									add_prog <= 16'd0;
									addressMem <= 14'd0;
								end
						endcase
					end
					1: begin
						case(pick)
							0: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd16430;
									addressMem <= 14'd0;
								end
							1: begin
									pos <= 16'd2048;
									size <= 16'd2048;
									add_prog <= 16'd16612;
								end
							2: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd18660;
									addressMem <= 14'd0;
								end
							3: begin
									pos <= 16'd768;
									size <= 16'd3328;
									add_prog <= 16'd18842;
								end
							4: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd22170;
									addressMem <= 14'd0;
								end
							5: begin
									pos <= 16'd768;
									size <= 16'd3328;
									add_prog <= 16'd22352;
								end
							6: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd25680;
									addressMem <= 14'd0;
								end
							7: begin
									pos <= 16'd2048;
									size <= 16'd2048;
									add_prog <= 16'd25862;
								end
							8: begin
									pos <= 16'd74;
									size <= 16'd182;
									add_prog <= 16'd27910;
									addressMem <= 14'd0;
								end
							9: begin
									pos <= 16'd768;
									size <= 16'd3328;
									add_prog <= 16'd28092;
								end
							default: 
								begin
									pos <= 16'd1;
									size <= 16'd0;
									add_prog <= 16'd0;
									addressMem <= 14'd0;
								end
						endcase
					end
					2: begin
						case(pick)
						0: begin
								pos <= 16'd2048;
								size <= 16'd2048;
								add_prog <= 16'd31420;
							end
						1: begin
								pos <= 16'd74;
								size <= 16'd182;
								add_prog <= 16'd33468;
								addressMem <= 14'd0;
							end
						2: begin
								pos <= 16'd768;
								size <= 16'd3328;
								add_prog <= 16'd33650;
							end
						3: begin
								pos <= 16'd74;
								size <= 16'd182;
								add_prog <= 16'd36978;
								addressMem <= 14'd0;
							end
						4: begin
								pos <= 16'd768;
								size <= 16'd3328;
								add_prog <= 16'd37160;
							end
						default:
							begin
								pos <= 16'd1;
								size <= 16'd0;
								add_prog <= 16'd0;
								addressMem <= 14'd0;
							end
						endcase
					end
					default:
						begin
							pos <= 16'd1;
							size <= 16'd0;
							add_prog <= 16'd0;
							addressMem <= 14'd0;
						end
				endcase
				start <= 1'b1;	
			end
			
			if(start == 1'b1 && finish == 1'b0)
			begin
				//Initial Writing (Set to 0x00 until 'pos')
				// pos-1 because it skips the last position marked
				if(rdy == 1'b0 && fnl == 1'b0)
				begin
					ctrl_led_Loading <= 1'b1;
					if (addressMem < pos-1) 
					begin
						ram_data[addressMem] <= 8'h00;
					end
					if (addressMem == pos-1) 
					begin
						rdy <= 1'b1;
					end
				end
				
				//Data Writing
				if(rdy == 1'b1 && fnl == 1'b0) 
				begin
					if (addressMem < (pos+size)) 
					begin
						ram_data[addressMem] <= programs[add_prog];
					end
					
					if(addressMem == (pos+size)) 
					begin
						fnl <= 1'b1;
						rdy <= 1'b0;
					end
					add_prog <= add_prog[15:0] + 1'b1;
				end
				
				//'Filler' writting (set to 0x00 from last program position to last position in memory (writed by hand [NO AUTO]))
				if(rdy == 1'b0 && fnl == 1'b1) 
				begin
					if (addressMem < 8191) 
					begin
						ram_data[addressMem] <= 8'h00;
					end
					else if (addressMem == 8191)
					begin
						finish <= 1'b1;
						ctrl_led_Loading <= 1'b0;
					end
				end
				addressMem <= addressMem[13:0] + 1'b1;
			end
			
			//Prepare to next load execution
			if(start == 1'b1 && finish == 1'b1)
			begin
				start <= 1'b0;
				finish <= 1'b0;
			end
		end
		else
			//Normal behavoir of the RAM
		begin
			ctrl_led_Init <= 1'b0;
			ctrl_led_Loading <= 1'b0;
			dout <= ram_data[address];
			if (w_en) ram_data[address] <= din;
		end
	end

endmodule
     
