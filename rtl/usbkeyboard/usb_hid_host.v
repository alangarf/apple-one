// Usb_hid_host: A compact USB HID host core.
//
// nand2mario, 8/2023, based on work by hi631
// modified heavily by Alan Garfield <alan@fromorbit.com> 09/2025
//
// This should support keyboard input out of the box, over low-speed
// USB (1.5Mbps). Just connect D+, D-, VBUS (5V) and GND, and two 15K resistors between
// D+ and GND, D- and GND. Then provide a 12Mhz clock through usbclk.
//
// See https://github.com/nand2mario/usb_hid_host
//

module usb_hid_host (
    input  usbclk,                  // 12MHz clock
    input  usbrst_n,                // reset
    inout  usb_dm, usb_dp,          // USB D- and D+

    output reg [1:0] typ,           // device type. 0: no device, 1: keyboard, 2: mouse, 3: gamepad
    output reg report,              // pulse after report received from device.
    output conerr,                  // connection or protocol error

    // keyboard
    output reg [7:0] key_modifiers,
    output reg [7:0] key1, key2, key3, key4

    // debug
    // output [63:0] dbg_hid_report	// last HID report
);

wire data_rdy;          // data ready
wire data_strobe;       // data strobe for each byte

wire [7:0] ukpdat;      // actual data
reg [7:0] regs [7:0];   // 0 (VID_L), 1 (VID_H), 2 (PID_L), 3 (PID_H), 4 (INTERFACE_CLASS), 5 (INTERFACE_SUBCLASS), 6 (INTERFACE_PROTOCOL)

wire save;              // save dat[b] to output register r
wire [3:0] save_r;      // which register to save to
wire [3:0] save_b;      // dat[b]
wire connected;

ukp ukp(
    .usbrst_n(usbrst_n),
    .usbclk(usbclk),
    .usb_dp(usb_dp),
    .usb_dm(usb_dm),
    .usb_oe(),
    .ukprdy(data_rdy),
    .ukpstb(data_strobe),
    .ukpdat(ukpdat),
    .save(save),
    .save_r(save_r),
    .save_b(save_b),
    .connected(connected),
    .conerr(conerr)
);

reg  [3:0] rcvct;                   // counter for recv data
reg  data_strobe_r, data_rdy_r;     // delayed data_strobe and data_rdy
reg  [7:0] dat[7:0];                // data in last response
// assign dbg_hid_report = {dat[7], dat[6], dat[5], dat[4], dat[3], dat[2], dat[1], dat[0]};

always @(posedge usbclk) begin : process_in_data
    data_rdy_r <= data_rdy;
    data_strobe_r <= data_strobe;
    report <= 0;                    // ensure pulse

    if(~data_rdy) rcvct <= 0;
    else begin
        if(data_strobe && ~data_strobe_r) begin  // rising edge of ukp data strobe
            dat[rcvct] <= ukpdat;

            if (typ == 1) begin     // keyboard
                case (rcvct)
                0: key_modifiers <= ukpdat;
                2: key1 <= ukpdat;
                3: key2 <= ukpdat;
                4: key3 <= ukpdat;
                5: key4 <= ukpdat;
                endcase
            end
            rcvct <= rcvct + {1'd1};
        end
    end
    if(~data_rdy && data_rdy_r && typ != 0)    // falling edge of ukp data ready
        report <= 1;
end

reg save_delayed;
reg connected_r;
always @(posedge usbclk) begin : response_recognition
    save_delayed <= save;
    if (save) begin
        regs[save_r] <= dat[save_b];
    end else if (save_delayed && ~save && save_r == 6) begin
        // falling edge of save for bInterfaceProtocol
        if (regs[4] == 3) begin                 // bInterfaceClass. 3: HID, other: non-HID
            if (regs[5] == 1)                   // bInterfaceSubClass. 1: Boot device
                typ <= regs[6] == 1 ? 1 : 2;    // bInterfaceProtocol. 1: keyboard, 2: mouse
            else
                typ <= 3;                       // gamepad
        end else
            typ <= 0;
    end
    connected_r <= connected;
    if (~connected & connected_r) typ <= 0;     // clear device type on disconnect
end

endmodule

module ukp(
    input usbrst_n,
    input usbclk,                   // 12MHz clock
    inout usb_dp, usb_dm,           // D+, D-
    output usb_oe,
    output reg ukprdy,              // data frame is outputing
    output ukpstb,                  // strobe for a byte within the frame
    output reg [7:0] ukpdat,        // output data when ukpstb=1
    output reg save,                // save: regs[save_r] <= dat[save_b]
    output reg [3:0] save_r, save_b,
    output reg connected,
    output conerr
);

    parameter S_OPCODE = 0;
    parameter S_LDI0 = 1;
    parameter S_LDI1 = 2;
    parameter S_B0 = 3;
    parameter S_B1 = 4;
    parameter S_B2 = 5;
    parameter S_S0 = 6;
    parameter S_S1 = 7;
    parameter S_S2 = 8;
    parameter S_TOGGLE0 = 9;
    parameter S_TOGGLE1 = 10;

    wire [3:0] inst;
    reg  [3:0] insth;
    wire sample;                                        // 1: an IN sample is available
    // reg connected = 0;
    reg inst_ready = 0;
    reg up = 0;
    reg um = 0;
    reg cond = 0;
    reg nak = 0;
    reg dmis = 0;
    reg ug, ugw, nrzon;                                 // ug=1: output enabled, 0: hi-Z
    reg bank = 0, record1 = 0;
    reg [1:0] mbit = 0;                                 // 1: out4/outb is transmitting
    reg [3:0] state = 0, stated;
    reg [7:0] wk = 0;                                   // W register
    reg [7:0] sb = 0;                                   // out value
    reg [3:0] sadr;                                     // out4/outb write ptr
    reg [13:0] pc = 0, wpc;                             // program counter, wpc = next pc
    reg [2:0] timing = 0;                               // T register (0~7)
    reg [3:0] lb4 = 0, lb4w;
    reg [13:0] interval = 0;
    reg [6:0] bitadr = 0;                               // 0~127
    reg [7:0] data = 0;                                 // received data
    reg [2:0] nrztxct, nrzrxct;                         // NRZI trans/recv count for bit stuffing
    wire interval_cy = interval == 12001;
    wire next = ~(state == S_OPCODE & (
        inst ==2 & dmi |                                // start
        (inst==4 || inst==5) & timing != 0 |            // out0/hiz
        inst ==13 & (~sample | (dpi | dmi) & wk != 1) | // in
        inst ==14 & ~interval_cy                        // wait
    ));
    wire branch = state == S_B1 & cond;
    wire retpc  = state == S_OPCODE && inst==7  ? 1 : 0;
    wire jmppc  = state == S_OPCODE && inst==15 ? 1 : 0;
    wire dbit   = sb[7-sadr[2:0]];
    wire record;
    reg  dmid;
    reg [23:0] conct;
    assign conerr = conct[23] || ~usbrst_n;

    usb_hid_host_rom ukprom(.clk(usbclk), .adr(pc), .data(inst));

    always @(posedge usbclk) begin
        if(~usbrst_n) begin
            pc <= 0;
            connected <= 0;
            cond <= 0;
            inst_ready <= 0;
            state <= S_OPCODE;
            timing <= 0;
            mbit <= 0;
            bitadr <= 0;
            nak <= 1;
            ug <= 0;
        end else begin
            dpi <= usb_dp;
            dmi <= usb_dm;
            save <= 0;                                  // ensure pulse

            if (!inst_ready) begin
                inst_ready <= 1;
            end else begin
                // Instruction decoding
                case(state)
                    S_OPCODE: begin
                        insth <= inst;
                        if(inst==1) state <= S_LDI0;                            // op=ldi
                        if(inst==3) begin sadr <= 3; state <= S_S0; end         // op=out4
                        if(inst==4) begin ug <= 1; up <= 0; um <= 0; end
                        if(inst==5) begin ug <= 0; end
                        if(inst==6) begin sadr <= 7; state <= S_S0; end	        // op=outb
                        if (inst[3:2]==2'b10) begin                             // op=10xx(BZ,BC,BNAK,DJNZ)
                            state <= S_B0;
                            case (inst[1:0])
                                2'b00: cond <= ~dmi;
                                2'b01: cond <= connected;
                                2'b10: cond <= nak;
                                2'b11: cond <= wk != 1;
                            endcase
                        end
                        if(inst==11 | inst==13 & sample) wk <= wk - 1'd1;       // op=DJNZ,IN
                        if(inst==15) begin state <= S_B2; cond <= 1; end        // op=jmp
                        if(inst==12) state <= S_TOGGLE0;
                    end
                    // Instructions with operands
                    // ldi
                    S_LDI0: begin
                        wk[3:0] <= inst;
                        state <= S_LDI1;
                    end
                    S_LDI1: begin
                        wk[7:4] <= inst;
                        state <= S_OPCODE;
                    end
                    // branch/jmp
                    S_B2: begin
                        lb4w <= inst;
                        state <= S_B0;
                    end
                    S_B0: begin
                        lb4  <= inst;
                        state <= S_B1;
                    end
                    // out
                    S_B1: begin
                        state <= S_OPCODE;
                    end
                    S_S0: begin
                        sb[3:0] <= inst;
                        state <= S_S1;
                    end
                    S_S1: begin
                        sb[7:4] <= inst;
                        state <= S_S2;
                        mbit <= 1;
                    end
                    // toggle and save
                    S_TOGGLE0: begin
                        if (inst == 15) connected <= ~connected;// toggle
                        else save_r <= inst;                    // save
                        state <= S_TOGGLE1;
                    end
                    S_TOGGLE1: begin
                        if (inst != 15) begin
                            save_b <= inst;
                            save <= 1;
                        end
                        state <= S_OPCODE;
                    end
                endcase

                // pc control
                if (mbit==0) begin
                    if(jmppc) wpc <= pc + {3'd4};
                    if (next | branch | retpc) begin
                        if(retpc) pc <= wpc;                                    // ret
                        else if(branch)
                            if(insth==15)                                       // jmp
                                pc <= { inst, lb4, lb4w, 2'b00 };
                            else                                                // branch
                                pc <= { 4'b0000, inst, lb4, 2'b00 };
                        else	pc <= pc + {1'd1};                              // next
                        inst_ready <= 0;
                    end
                end
            end

            // bit transmission (out4/outb)
            if (mbit==1 && timing == 0) begin
                if(ug==0) begin
                    nrztxct <= 0;
                end else begin
                    if(dbit) begin
                        nrztxct <= nrztxct + {1'd1};
                    end else begin
                        nrztxct <= 0;
                    end
                end

                if(insth == 4'd6) begin
                    if(nrztxct!=6) begin
                        up <= dbit ?  up : ~up;
                        um <= dbit ? ~up :  up;
                    end else begin
                        up <= ~up;
                        um <= up;
                        nrztxct <= 0;
                    end
                end else begin
                    up <=  sb[{1'b1,sadr[1:0]}]; um <= sb[sadr[2:0]];
                end

                ug <= 1'b1;
                if(nrztxct!=6) begin
                    sadr <= sadr - {1'd1};
                end
                if(sadr==0) begin
                    mbit <= 0;
                    state <= S_OPCODE;
                end
            end

            // start instruction
            dmid <= dmi;
            if (inst_ready & state == S_OPCODE & inst == 4'b0010) begin         // op=start
                bitadr <= 0; nak <= 1; nrzrxct <= 0;
            end else begin
                if(ug==0 && dmi!=dmid) begin
                    timing <= 1;
                end else begin
                    timing <= timing + {1'd1};
                end
            end

            // IN instruction
            if (sample) begin
                if (bitadr == 8) begin
                    nak <= dmi;
                end

                if(nrzrxct!=6) begin
                    data[6:0] <= data[7:1];
                    data[7] <= dmis ~^ dmi;                                     // ~^/^~ is XNOR, testing bit equality
                    bitadr <= bitadr + {1'd1};
                    nrzon <= 0;
                end else begin
                    nrzon <= 1;
                end

                dmis <= dmi;
                if(dmis ~^ dmi) begin
                    nrzrxct <= nrzrxct + {1'd1};
                end else begin
                    nrzrxct <= 0;
                end

                if (~dmi && ~dpi) begin
                    ukprdy <= 0; // SE0: packet is finished. Mouses send length 4 reports.
                end
            end

            if (ug==0) begin
                if(bitadr==24) ukprdy <= 1; // ignore first 3 bytes
                if(bitadr==88) ukprdy <= 0; // output next 8 bytes
            end
            if ((bitadr>11 & bitadr[2:0] == 3'b000) & (timing == 2)) ukpdat <= data;

            // Timing
            interval <= interval_cy ? {14'd0} : interval + {1'd1};
            record1 <= record;

            if (~record & record1) bank <= ~bank;

            // Connection status & WDT
            ukprdyd <= ukprdy;
            nakd <= nak;

            if (ukprdy && ~ukprdyd || inst_ready && state == S_OPCODE && inst == 4'b0010)
                conct <= 0;     // reset watchdog on data received or START instruction
            else begin
                if(conct[23:22]!=2'b11) conct <= conct + {1'd1};
                else begin
                    pc <= 0;
                    conct <= 0;
                end // !! WDT ON
            end
        end
    end

    assign usb_dp = ug ? up : 1'bZ;
    assign usb_dm = ug ? um : 1'bZ;
    assign usb_oe = ug;
    assign sample = inst_ready & state == S_OPCODE & inst == 4'b1101 & timing == 4; // IN
    assign record = connected & ~nak;
    assign ukpstb = ~nrzon & ukprdy & (bitadr[2:0] == 3'b100) & (timing == 2);
    reg    dpi, dmi;
    reg    ukprdyd;
    reg    nakd;
endmodule
