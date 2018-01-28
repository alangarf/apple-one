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
// Description: Top level test bench for apple1_top
//
// Author.....: Niels A. Moseley
// Date.......: 26-1-2018
//

`timescale 1ns/1ps

module apple1_tb;

    reg clk25, uart_rx, rst_n;
    wire uart_tx, uart_cts;

    //////////////////////////////////////////////////////////////////////////
    // Setup dumping of data for inspection

    initial begin

        // force core_top.clk_div = 0;
        // force core_top.cpu_clken = 0;
        // force core_top.hard_reset = 0;
        // force core_top.reset_cnt = 0;

        // force core_top.my_cpu.arlet_cpu.AB = 0;
        // force core_top.my_cpu.arlet_cpu.PC = 0;
        // force core_top.my_cpu.arlet_cpu.ABL = 0;
        // force core_top.my_cpu.arlet_cpu.ABH = 0;
        // force core_top.my_cpu.arlet_cpu.DIHOLD = 0;
        // force core_top.my_cpu.arlet_cpu.IRHOLD = 0;
        // force core_top.my_cpu.arlet_cpu.IRHOLD_valid = 0;
        // force core_top.my_cpu.arlet_cpu.C = 0;
        // force core_top.my_cpu.arlet_cpu.Z = 0;
        // force core_top.my_cpu.arlet_cpu.I = 0;
        // force core_top.my_cpu.arlet_cpu.D = 0;
        // force core_top.my_cpu.arlet_cpu.V = 0;
        // force core_top.my_cpu.arlet_cpu.N = 0;
        // force core_top.my_cpu.arlet_cpu.AI = 0;
        // force core_top.my_cpu.arlet_cpu.BI = 0;
        // force core_top.my_cpu.arlet_cpu.DO = 0;
        // force core_top.my_cpu.arlet_cpu.WE = 0;
        // force core_top.my_cpu.arlet_cpu.CI = 0;
        // force core_top.my_cpu.arlet_cpu.NMI_edge = 0;
        // force core_top.my_cpu.arlet_cpu.regsel = 0;
        // force core_top.my_cpu.arlet_cpu.PC_inc = 0;
        // force core_top.my_cpu.arlet_cpu.PC_temp = 0;
        // force core_top.my_cpu.arlet_cpu.src_reg = 0;
        // force core_top.my_cpu.arlet_cpu.dst_reg = 0;
        // force core_top.my_cpu.arlet_cpu.index_y = 0;
        // force core_top.my_cpu.arlet_cpu.load_reg = 0;
        // force core_top.my_cpu.arlet_cpu.inc = 0;
        // force core_top.my_cpu.arlet_cpu.write_back = 0;
        // force core_top.my_cpu.arlet_cpu.load_only = 0;
        // force core_top.my_cpu.arlet_cpu.store = 0;
        // force core_top.my_cpu.arlet_cpu.adc_sbc = 0;
        // force core_top.my_cpu.arlet_cpu.compare = 0;
        // force core_top.my_cpu.arlet_cpu.shift = 0;
        // force core_top.my_cpu.arlet_cpu.rotate = 0;
        // force core_top.my_cpu.arlet_cpu.backwards = 0;
        // force core_top.my_cpu.arlet_cpu.cond_true = 0;
        // force core_top.my_cpu.arlet_cpu.cond_code = 0;
        // force core_top.my_cpu.arlet_cpu.shift_right = 0;
        // force core_top.my_cpu.arlet_cpu.alu_shift_right = 0;
        // force core_top.my_cpu.arlet_cpu.op = 0;
        // force core_top.my_cpu.arlet_cpu.alu_op = 0;
        // force core_top.my_cpu.arlet_cpu.adc_bcd = 0;
        // force core_top.my_cpu.arlet_cpu.adj_bcd = 0;
        // force core_top.my_cpu.arlet_cpu.bit_ins = 0;
        // force core_top.my_cpu.arlet_cpu.plp = 0;
        // force core_top.my_cpu.arlet_cpu.php = 0;
        // force core_top.my_cpu.arlet_cpu.clc = 0;
        // force core_top.my_cpu.arlet_cpu.sed = 0;
        // force core_top.my_cpu.arlet_cpu.cli = 0;
        // force core_top.my_cpu.arlet_cpu.sei = 0;
        // force core_top.my_cpu.arlet_cpu.clv = 0;
        // force core_top.my_cpu.arlet_cpu.brk = 0;
        // force core_top.my_cpu.arlet_cpu.res = 0;
        // force core_top.my_cpu.arlet_cpu.write_register = 0;
        // force core_top.my_cpu.arlet_cpu.ADJL = 0;
        // force core_top.my_cpu.arlet_cpu.ADJH = 0;
        // force core_top.my_cpu.arlet_cpu.NMI_1 = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.OUT = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.CO = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.N = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.HC = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.AI7 = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.BI7 = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.temp_logic = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.temp_BI = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.temp_l = 0;
        // force core_top.my_cpu.arlet_cpu.ALU.temp_h = 0;

        clk25 = 1'b0;
        uart_rx = 1'b1;
        rst_n = 1'b0;
        #40 rst_n = 1'b1;

        // release core_top.clk_div;
        // release core_top.cpu_clken;
        // release core_top.hard_reset;
        // release core_top.reset_cnt;
        // release core_top.my_cpu.arlet_cpu.AB;
        // release core_top.my_cpu.arlet_cpu.PC;
        // release core_top.my_cpu.arlet_cpu.ABL;
        // release core_top.my_cpu.arlet_cpu.ABH;
        // release core_top.my_cpu.arlet_cpu.DIHOLD;
        // release core_top.my_cpu.arlet_cpu.IRHOLD;
        // release core_top.my_cpu.arlet_cpu.IRHOLD_valid;
        // release core_top.my_cpu.arlet_cpu.C;
        // release core_top.my_cpu.arlet_cpu.Z;
        // release core_top.my_cpu.arlet_cpu.I;
        // release core_top.my_cpu.arlet_cpu.D;
        // release core_top.my_cpu.arlet_cpu.V;
        // release core_top.my_cpu.arlet_cpu.N;
        // release core_top.my_cpu.arlet_cpu.AI;
        // release core_top.my_cpu.arlet_cpu.BI;
        // release core_top.my_cpu.arlet_cpu.DO;
        // release core_top.my_cpu.arlet_cpu.WE;
        // release core_top.my_cpu.arlet_cpu.CI;
        // release core_top.my_cpu.arlet_cpu.NMI_edge;
        // release core_top.my_cpu.arlet_cpu.regsel;
        // release core_top.my_cpu.arlet_cpu.PC_inc;
        // release core_top.my_cpu.arlet_cpu.PC_temp;
        // release core_top.my_cpu.arlet_cpu.src_reg;
        // release core_top.my_cpu.arlet_cpu.dst_reg;
        // release core_top.my_cpu.arlet_cpu.index_y;
        // release core_top.my_cpu.arlet_cpu.load_reg;
        // release core_top.my_cpu.arlet_cpu.inc;
        // release core_top.my_cpu.arlet_cpu.write_back;
        // release core_top.my_cpu.arlet_cpu.load_only;
        // release core_top.my_cpu.arlet_cpu.store;
        // release core_top.my_cpu.arlet_cpu.adc_sbc;
        // release core_top.my_cpu.arlet_cpu.compare;
        // release core_top.my_cpu.arlet_cpu.shift;
        // release core_top.my_cpu.arlet_cpu.rotate;
        // release core_top.my_cpu.arlet_cpu.backwards;
        // release core_top.my_cpu.arlet_cpu.cond_true;
        // release core_top.my_cpu.arlet_cpu.cond_code;
        // release core_top.my_cpu.arlet_cpu.shift_right;
        // release core_top.my_cpu.arlet_cpu.alu_shift_right;
        // release core_top.my_cpu.arlet_cpu.op;
        // release core_top.my_cpu.arlet_cpu.alu_op;
        // release core_top.my_cpu.arlet_cpu.adc_bcd;
        // release core_top.my_cpu.arlet_cpu.adj_bcd;
        // release core_top.my_cpu.arlet_cpu.bit_ins;
        // release core_top.my_cpu.arlet_cpu.plp;
        // release core_top.my_cpu.arlet_cpu.php;
        // release core_top.my_cpu.arlet_cpu.clc;
        // release core_top.my_cpu.arlet_cpu.sec;
        // release core_top.my_cpu.arlet_cpu.cld;
        // release core_top.my_cpu.arlet_cpu.sed;
        // release core_top.my_cpu.arlet_cpu.sei;
        // release core_top.my_cpu.arlet_cpu.clv;
        // release core_top.my_cpu.arlet_cpu.brk;
        // release core_top.my_cpu.arlet_cpu.res;
        // release core_top.my_cpu.arlet_cpu.write_register;
        // release core_top.my_cpu.arlet_cpu.ADJL;
        // release core_top.my_cpu.arlet_cpu.ADJH;
        // release core_top.my_cpu.arlet_cpu.NMI_1;
        // release core_top.my_cpu.arlet_cpu.ALU.OUT;
        // release core_top.my_cpu.arlet_cpu.ALU.CO;
        // release core_top.my_cpu.arlet_cpu.ALU.N;
        // release core_top.my_cpu.arlet_cpu.ALU.HC;
        // release core_top.my_cpu.arlet_cpu.ALU.AI7;
        // release core_top.my_cpu.arlet_cpu.ALU.BI7;
        // release core_top.my_cpu.arlet_cpu.ALU.temp_logic;
        // release core_top.my_cpu.arlet_cpu.ALU.temp_BI;
        // release core_top.my_cpu.arlet_cpu.ALU.temp_l;
        // release core_top.my_cpu.arlet_cpu.ALU.temp_h;

        $display("Starting...");
        $dumpfile("apple1_top_tb.vcd");
        $dumpvars;

        #180000
        uart_rx = 1'b0;
        #400
        uart_rx = 1'b1;
        #400
        uart_rx = 1'b0;
        #400
        uart_rx = 1'b1;
        #800
        uart_rx = 1'b0;
        #1600
        uart_rx = 1'b1;
 

        //#1000000 $display("Stopping...");
        #1000 $display("Stopping...");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Clock

    always
        #20 clk25 = !clk25;

    //////////////////////////////////////////////////////////////////////////
    // Core of system
    apple1 #(
        "../roms/ram.hex",
        "../roms/wozmon.hex",
        "../roms/basic.hex"
    ) core_top (
        .clk25(clk25),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts)
    );

endmodule
