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
// Description: RAM for ukp
//
// Author.....: Alan Garfield
// Date.......: 11-4-2018
//

module ukpram #(
    parameter UKPRAM_FILENAME       = "../../../roms/ukp_ram.bin"
) (
    input clk25,                // clock signal
    input clkusb,               // USB clock signal
    input [4:0] read_addr,      // read address bus
    input [5:0] write_addr,     // write address bus
    input r_en,                 // active high read enable strobe
    input w_en,                 // active high write enable strobe
    input [3:0] din,            // 4-bit data bus (input)
    output reg [7:0] dout       // 8-bit data bus (output)
);

    reg [3:0] ram_data[0:63];

    //initial
    //    $readmemb(UKPRAM_FILENAME, ram_data, 0, 63);

    always @(posedge clkusb)
    begin
        if (w_en) ram_data[write_addr] <= din;
    end

    always @(posedge clk25)
    begin
        if (r_en) dout <= {
            ram_data[{read_addr, 1'b1}],
            ram_data[{read_addr, 1'b0}]
        };
    end

endmodule

// BANK A
// 0000     000001
//          000000
// 0001     000011
//          000010
// 0010
// 0011
// 0100
// 0101
// 0110
// 0111
//
// BANK B
// 1000
// 1001
// 1010
// 1011
// 1100
// 1101
// 1110
// 1111
