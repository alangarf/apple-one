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

    // keyboard translation signals
    reg [7:0]  ascii;       // ASCII code of received character
    reg ascii_rdy;          // new ASCII character received
    reg shift;              // state of the shift key
    reg [2:0] cur_state;
    reg [2:0] next_state;
    
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

//
// IBM Keyboard code page translation
// state machine for US keyboard layout
//
// http://www.computer-engineering.org/ps2keyboard/scancodes2.html
//

localparam S_KEYNORMAL  = 3'b000;
localparam S_KEYF0      = 3'b001;   // regular key release state
localparam S_KEYE0      = 3'b010;   // extended key state
localparam S_KEYE0F0    = 3'b011;   // extended release state

always @(posedge clk25 or posedge reset)
begin
    if (reset)
    begin
        rxflag_ff   <= 0;
        rx          <= 0;
        rx_rdy      <= 0;
        ascii_rdy   <= 0;
        shift       <= 0;
        cur_state   <= S_KEYNORMAL;
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
                dout <= ascii;
                ascii_rdy <= 1'b0;
            end
            else
            begin
                // RX status register
                dout <= {ascii_rdy, 7'b0};
            end
        end

        // keyboard translation state machine
        if (rx_rdy == 1'b1)
        begin
            rx_rdy <= 1'b0;
            case(cur_state)
                S_KEYNORMAL:
                    begin
                        if (rx == 8'hF0)
                            next_state = S_KEYF0;
                        else if (rx == 8'hE0)
                            next_state = S_KEYE0;
                        else
                        begin
                            ascii_rdy <= 1'b1;  // new key has arrived!
                            if (!shift)
                                case(rx)
                                    8'h1C:  ascii <= "A";
                                    8'h32:  ascii <= "B";
                                    8'h21:  ascii <= "C";
                                    8'h23:  ascii <= "D";
                                    8'h24:  ascii <= "E";
                                    8'h2B:  ascii <= "F";
                                    8'h34:  ascii <= "G";
                                    8'h33:  ascii <= "H";
                                    8'h43:  ascii <= "I";
                                    8'h3B:  ascii <= "J";
                                    8'h42:  ascii <= "K";
                                    8'h4B:  ascii <= "L";
                                    8'h3A:  ascii <= "M";
                                    8'h31:  ascii <= "N";
                                    8'h44:  ascii <= "O";
                                    8'h4D:  ascii <= "P";
                                    8'h15:  ascii <= "Q";
                                    8'h2D:  ascii <= "R";
                                    8'h1B:  ascii <= "S";
                                    8'h2C:  ascii <= "T";
                                    8'h3C:  ascii <= "U";
                                    8'h2A:  ascii <= "V";
                                    8'h1D:  ascii <= "W";
                                    8'h22:  ascii <= "X";
                                    8'h35:  ascii <= "Y";
                                    8'h1A:  ascii <= "Z";

                                    8'h45:  ascii <= "0";
                                    8'h16:  ascii <= "1";
                                    8'h1E:  ascii <= "2";
                                    8'h26:  ascii <= "3";
                                    8'h25:  ascii <= "4";
                                    8'h2E:  ascii <= "5";
                                    8'h36:  ascii <= "6";
                                    8'h3D:  ascii <= "7";
                                    8'h3E:  ascii <= "8";
                                    8'h46:  ascii <= "9";

                                    8'h4E:  ascii <= "-";
                                    8'h55:  ascii <= "=";
                                    8'h5D:  ascii <= "\\ ";
                                    8'h66:  ascii <= 8'd8;      // backspace
                                    8'h29:  ascii <= " ";

                                    8'h5A:  ascii <= 8'd13;     // enter
                                    8'h54:  ascii <= "[";
                                    8'h5B:  ascii <= "]";
                                    8'h4C:  ascii <= ";";
                                    8'h52:  ascii <= "'";
                                    8'h41:  ascii <= ",";
                                    8'h49:  ascii <= ".";
                                    8'h4A:  ascii <= "/"; 
                                    8'h59:  shift <= 1'b1;      // right shfit
                                    8'h12:  shift <= 1'b1;      // left shift
                                endcase
                            else
                                case(rx)
                                    8'h1C:  ascii <= "A";
                                    8'h32:  ascii <= "B";
                                    8'h21:  ascii <= "C";
                                    8'h23:  ascii <= "D";
                                    8'h24:  ascii <= "E";
                                    8'h2B:  ascii <= "F";
                                    8'h34:  ascii <= "G";
                                    8'h33:  ascii <= "H";
                                    8'h43:  ascii <= "I";
                                    8'h3B:  ascii <= "J";
                                    8'h42:  ascii <= "K";
                                    8'h4B:  ascii <= "L";
                                    8'h3A:  ascii <= "M";
                                    8'h31:  ascii <= "N";
                                    8'h44:  ascii <= "O";
                                    8'h4D:  ascii <= "P";
                                    8'h15:  ascii <= "Q";
                                    8'h2D:  ascii <= "R";
                                    8'h1B:  ascii <= "S";
                                    8'h2C:  ascii <= "T";
                                    8'h3C:  ascii <= "U";
                                    8'h2A:  ascii <= "V";
                                    8'h1D:  ascii <= "W";
                                    8'h22:  ascii <= "X";
                                    8'h35:  ascii <= "Y";
                                    8'h1A:  ascii <= "Z";

                                    8'h45:  ascii <= ")";
                                    8'h16:  ascii <= "!";
                                    8'h1E:  ascii <= "@";
                                    8'h26:  ascii <= "#";
                                    8'h25:  ascii <= "$";
                                    8'h2E:  ascii <= "%";
                                    8'h36:  ascii <= "^";
                                    8'h3D:  ascii <= "&";
                                    8'h3E:  ascii <= "*";
                                    8'h46:  ascii <= "(";

                                    8'h4E:  ascii <= "_";
                                    8'h55:  ascii <= "+";
                                    8'h5D:  ascii <= "|";
                                    8'h66:  ascii <= 8'd8;      // backspace
                                    8'h29:  ascii <= " ";

                                    8'h5A:  ascii <= 8'd13;     // enter
                                    8'h54:  ascii <= "{";
                                    8'h5B:  ascii <= "}";
                                    8'h4C:  ascii <= ":";
                                    8'h52:  ascii <= "\"";
                                    8'h41:  ascii <= "<";
                                    8'h49:  ascii <= ">";
                                    8'h4A:  ascii <= "?";
                                    8'h59:  shift <= 1'b1;      // right shfit
                                    8'h12:  shift <= 1'b1;      // left shift
                                endcase
                        end
                    end
                S_KEYF0:
                    // when we end up here, a 0xF0 byte was received
                    // which usually means a key release event
                    begin
                        if ((rx == 8'h59) || (rx == 8'h12))
                            shift <= 1'b0;
                        next_state = S_KEYNORMAL;
                    end
                S_KEYE0:
                    begin
                        if (rx == 8'hF0)
                            next_state = S_KEYE0F0;
                        else
                            next_state = S_KEYNORMAL;
                    end
                S_KEYE0F0:
                    begin
                        next_state = S_KEYNORMAL;
                    end
            endcase;
        end
        else
        begin
            next_state = cur_state;
        end

        cur_state <= next_state;
    end
end

endmodule

