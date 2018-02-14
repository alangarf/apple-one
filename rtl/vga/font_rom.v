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
// Date.......: 3-2-2018
//

module font_rom #(
    parameter FONT_ROM_FILENAME   = "../../../roms/vga_font_bitreversed.hex"
) (
    input clk,              // clock signal
    input [1:0] mode,       // character mode
    input [5:0] character,  // address bus
    input [3:0] pixel,      // address of the pixel to output
    input [4:0] line,       // address of the line to output
    output reg out          // single pixel from address and pixel pos
    );

    reg [7:0] rom[0:1023];

    initial
        $readmemh(FONT_ROM_FILENAME, rom, 0, 1023);

    // double height of pixel by ignoring bit 0
    wire [3:0] line_ptr = line[4:1];

    // Note: Quartus II reverses the pixels when we do:
    //
    // rom[address][bitindex] 
    //
    // directly, so we use an intermediate 
    // signal, romout, to work around this 
    // problem.
    //
    // IceCube2 and Yosys don't seem to have this problem.
    //
    
    reg [7:0] romout;
    
    always @(posedge clk)
    begin
        // mode
        // 00 - normal
        // 01 - vertical scanlines
        // 10 - horizontal scanlines
        // 11 - dotty mode
        
        romout = rom[(character * 10) + {2'd0, line_ptr}];
        
        out <= (mode[1] & line[0]) ? 1'b0 :
               (mode[0] & pixel[0]) ? 1'b0 :
               romout[pixel[3:1]];
    end

endmodule
     
