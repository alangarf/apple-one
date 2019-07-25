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
// Description: Cassette module for Digilent Nexys 3 board 
//					 with Spartan 6, like a cassette loader
//
// Author.....: Oskar A. Stepien
// Date.......: 25-2-2019
// 

module cassette(
	input clk25,
	input next,
	input prev,
	input [1:0] block,
	output [6:0] seg,
	output [3:0] an,
	output dp,
	output reg[3:0] pick
);
	
	//Register to save previous state of next, making only one next per click
	reg ant;
	
	//Assign max
	reg [3:0] max;
	
	
	//Asign the maximum block position, to add new programs MUST BE CHANGED!
	always @(posedge clk25)  //3. CHANGE MAXIMUM PICK OPTION
	begin
		case (block)
			0,1: max <= 4'd9;
			
			2: max <= 4'd4;
			
			default: max <= 4'd0;
		endcase;
	end;
	
	//Circular "selector" from 0 to 6, pick the program to load on RAM Memory
	always @(posedge clk25)
	begin
		if(ant == 1'b1 && next == 1'b0)
		begin
			if (pick >= max)
			begin
				pick = 1'd0;
			end
			else
			begin
				pick = pick + 1'd1;
			end
		end		
		else if(ant == 1'b1 && prev == 1'b0)
		begin
			if (pick <= 4'd0) 
			begin
				pick = max;
			end
			else
			begin
				pick = pick - 1'd1;
			end
		end
		ant <= (next ~^ prev);
	end
	
	//Display 4-digit to show to the user
	display cassette_display (
		.pick(pick),
		.block(block),
		.clk(clk25), 
		.seg(seg), 
		.an(an), 
		.dp(dp)
	);
	 
endmodule
