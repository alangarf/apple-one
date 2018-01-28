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
// Description: PS/2 keyboard interface
//
// Author.....: Niels A. Moseley
// Date.......: 28-1-2018
// 

module ps2keyboard (
    input       clk25,          // 25MHz clock
    input       reset,          // active high reset

    // I/O interface to keyboard
    input       key_clk,        // clock input from keyboard / device
    input       key_din,        // data input from keyboard / device

    // I/O interface to computer
    input       cs,             // chip select, active high
    input       address,        // =0 RX buffer, =1 RX status
    output reg [7:0] dout       // 8-bit output bus.                                
);

    // signals in the slow PS/2 clock domain
    reg [3:0]  rxcnt;       // count how many bits have been shift into rxshiftbuf
    reg [10:0] rxshiftbuf;  // 11 bit shift receive register
    reg rx_flag = 0;        // this flag changes state (0->1 or 1->0) when
                            // valid data is available in rxshiftbuf

    // signals in the high-speed clock (clk25) domain
    reg [7:0]  rx;          // receive buffer
    reg rxflag_ff;          // flip-flop state for clk domain xing
    reg rx_rdy;             // data ready to be read

//
// PS/2 data from a device changes when the clock
// is low, so we latch when the clock transitions
// to a high state
//

always @(posedge key_clk or posedge reset)
begin
    if (reset == 1'b1)
    begin
        // reset the serial buffer
        rxshiftbuf <= 11'b0;
        rxcnt <= 0;
        rx_flag <= 0;
    end
    else
    begin
        // shift in LSB first from keyboard
        rxshiftbuf <= {key_din, rxshiftbuf[10:1]};
        rxcnt <= rxcnt + 4'b1;
        if (rxcnt == 4'd10)
        begin
            // 10 bits have been shifted in
            // we should have a complete
            // scan code here, including
            // start, parity and stop bits.
            rxcnt <= 0;
            rx_flag <= !rx_flag; // change state to signal new data
        end
    end
end

//
// clock domain crossing from slow PS/2 clock to
// high-speed clock domain:
//
//         --------------|     |
//        |  _______     | XOR |----> rx_valid_stb
//  flag ---| D   Q |----|     |
//          |       |
//  clk ----|>      |
//          |_______|
//
// when flag toggles state, tx_valid_stb will become
// '1' for exactly one (high-speed) clock cycle.
//

always @(posedge clk25 or posedge reset)
begin
    if (reset)
    begin
        rxflag_ff <= 0;
        rx <= 0;
        rx_rdy <= 0;
    end
    else
    begin
        // check for new RX data from the keyboard
        rxflag_ff <= rx_flag;

        if ((rxflag_ff ^ rx_flag) == 1'b1)
        begin
            // we detected a change in the rx_flag
            // so we have valid data in the rxshiftbuf
            rx <= rxshiftbuf[8:1];
            rx_rdy <= 1;
        end
        
        // handle I/O from CPU
        if (cs == 1'b1)
        begin
            if (address == 1'b0)
            begin
                // RX buffer address
                dout <= rx;
                rx_rdy <= 1'b0;
            end
            else
            begin
                // RX status register
                dout <= {rx_rdy, 7'b0};
            end
        end
    end
end

endmodule

