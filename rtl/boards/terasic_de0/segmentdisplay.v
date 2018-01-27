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
// Description: 7-segment display driver for DE0 board
//
// Author.....: Niels A. Moseley
// Date.......: 26-1-2018
// 

module segmentdisplay (
    clk,
    latch,
    hexdigit_in,
    display_out
);

    input  clk,latch;
    input  [3:0] hexdigit_in;
    output reg [0:6] display_out;

    always @(posedge clk)
    begin
        if (latch == 1)
        begin 
            case (hexdigit_in)
                4'b0000:
                    display_out <= 7'b1000000;
                4'b0001:
                    display_out <= 7'b1111001;
                4'b0010:
                    display_out <= 7'b0100100;
                4'b0011:
                    display_out <= 7'b0110000;
                4'b0100:
                    display_out <= 7'b0011001;
                4'b0101:
                    display_out <= 7'b0010010;
                4'b0110:
                    display_out <= 7'b0000010;
                4'b0111:
                    display_out <= 7'b1111000;
                4'b1000:
                    display_out <= 7'b0000000;
                4'b1001:
                    display_out <= 7'b0011000;
                4'b1010:
                    display_out <= 7'b0001000;
                4'b1011:
                    display_out <= 7'b0000011;
                4'b1100:
                    display_out <= 7'b1000110;
                4'b1101:
                    display_out <= 7'b0100001;
                4'b1110:
                    display_out <= 7'b0000110;    
                4'b1111:
                    display_out <= 7'b0001110;
            endcase
        end                                                                                                   
    end
endmodule

