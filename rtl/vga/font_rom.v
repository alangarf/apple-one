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
//`define DOTTY
//`define SCANLINES
`define NORMAL

module font_rom(
    input clk,              // clock signal
    input [5:0] character,  // address bus
    input [3:0] pixel,      // address of the pixel to output
    input [4:0] line,       // address of the line to output
    output reg out          // single pixel from address and pixel pos
    );

    `ifdef SIM
    parameter ROM_FILENAME = "../roms/vga_font.bin";
    `else
    parameter ROM_FILENAME = "../../roms/vga_font.bin";
    `endif

    reg [7:0] rom[0:639];

    initial
        $readmemb(ROM_FILENAME, rom, 0, 639);

    // double width of pixel by ignoring bit 0
    wire [2:0] pixel_ptr;
    assign pixel_ptr = (3'h7 - pixel[3:1]);

    // double height of pixel by ignoring bit 0
    wire [3:0] line_ptr = line[4:1];

    always @(posedge clk)
    begin
        `ifdef DOTTY
        out <= (line[0] & pixel[0]) ? rom[(character * 10) + {2'd0, line_ptr}][pixel_ptr] : 1'b0;
        `endif
        `ifdef SCANLINES
        out <= (line[0]) ? rom[(character * 10) + {2'd0, line_ptr}][pixel_ptr] : 1'b0;
        `endif
        `ifdef NORMAL
        out <= rom[(character * 10) + {2'd0, line_ptr}][pixel_ptr];
        `endif
    end

endmodule
     
