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
// Description: A wrapper for the basic UART from fpga4fun.com
//
// Author.....: Alan Garfield
//              Niels A. Moseley
// Date.......: 26-1-2018
//

module uart(
    input clk,              // clock signal
    input enable,           // clock enable strobe
    input rst,              // active high reset signal
    input [1:0] address,    // address bus
    input w_en,             // active high write enable strobe
    input [7:0] din,        // 8-bit data bus (input)
    output reg [7:0] dout,  // 8-bit data bus (output)

    input uart_rx,          // asynchronous serial data input from computer
    output uart_tx,         // asynchronous serial data output to computer
    output uart_cts         // clear to send flag to computer
    );

    parameter ClkFrequency = 25000000;	// 25MHz
    parameter Baud = 115200;
    parameter Oversampling = 16;

    reg uart_tx_stb, uart_tx_init;
    reg [7:0] uart_tx_byte;
    wire uart_tx_status;

    async_transmitter #(ClkFrequency, Baud) my_tx (
        .clk(clk),
        .rst(rst),
        .TxD_start(uart_tx_stb),
        .TxD_data(uart_tx_byte),
        .TxD(uart_tx),
        .TxD_busy(uart_tx_status)
        );

    wire uart_rx_stb, rx_idle, rx_end;
    wire [7:0] rx_data;
    reg uart_rx_status, uart_rx_ack;
    reg [7:0] uart_rx_byte;

    async_receiver #(ClkFrequency, Baud, Oversampling) my_rx(
        .clk(clk),
        .rst(rst),
        .RxD(uart_rx),
        .RxD_data_ready(uart_rx_stb),
        .RxD_data(rx_data),
        .RxD_idle(rx_idle),
        .RxD_endofpacket(rx_end)
        );

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            uart_rx_status <= 'b0;
            uart_rx_byte <= 8'd0;
        end
        else
        begin
            // new byte from RX, check register is clear and CPU has seen
            // previous byte, otherwise we ignore the new data
            if (uart_rx_stb && ~uart_rx_status)
            begin
                uart_rx_status <= 'b1;
                uart_rx_byte <= rx_data;
            end

            // clear the rx status flag on ack from CPU
            if (uart_rx_ack)
                uart_rx_status <= 'b0;
        end
    end

    assign uart_cts = ~rx_idle || uart_rx_status;

    localparam UART_RX   = 2'b00;
    localparam UART_RXCR = 2'b01;
    localparam UART_TX   = 2'b10;
    localparam UART_TXCR = 2'b11;

    // Handle Register
    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            dout <= 8'd0;

            uart_tx_init <= 0; // flag to ignore the DDR setup from Wozmon PIA call
            uart_tx_stb <= 0;
            uart_tx_byte <= 8'd0;
            uart_rx_ack <= 0;
        end
        else
        begin
            uart_tx_stb <= 0;
            uart_rx_ack <= 0;

            case (address)

            UART_RX:
            begin
                // UART RX - 0xD010
                // Bit b7 of KBD is permanently tied to high
                dout <= {1'b1, uart_rx_byte[6:0]};
                if (~w_en && ~uart_rx_ack && uart_rx_status && enable)
                    uart_rx_ack <= 1'b1;
            end

            UART_RXCR:
            begin
                // UART RX CR - 0xD011
                dout <= {uart_rx_status, 7'b0};
            end

            UART_TX:
            begin
                // UART TX - 0xD012
                dout <= {uart_tx_status, 7'd0};

                if (w_en)
                begin
                    // Apple 1 terminal only uses 7 bits, MSB indicates
                    // terminal has ack'd RX
                    //
                    // uart_tx_init is a flag to stop the first character
                    // sent to the UART from being sent. Wozmon initializes
                    // the PIA which normally isn't sent to the terminal.
                    // This causes the UART to ignore the very first byte sent.
                    if (~uart_tx_status && uart_tx_init)
                    begin
                        uart_tx_byte <= {1'b0, din[6:0]};
                        uart_tx_stb <= 1;
                    end
                    else if (~uart_tx_init)
                        uart_tx_init <= 1 && enable;
                end
            end

            UART_TXCR:
            begin
                // UART TX CR - 0xD013
                // Ignore the TX control register
                dout <= 8'b0;
            end

            endcase
        end
    end
endmodule
