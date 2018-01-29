module apple1(
    input  clk25,               // 25 MHz master clock
    input  rst_n,               // active low synchronous reset (needed for simulation)

    input  uart_rx,
    output uart_tx,
    output uart_cts,

    input ps2_clk,              // PS/2 keyboard serial clock input
    input ps2_din,              // PS/2 keyboard serial data input

    output [15:0] pc_monitor,   // spy for program counter / debugging
    input reset_button          // allow a physical reset button
);
    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires

    wire [15:0] ab;
    wire [7:0] dbi;
    wire [7:0] dbo;
    wire we;

    //////////////////////////////////////////////////////////////////////////
    // Clocks

    // generate clock enable once every
    // 25 clocks. This will (hopefully) make
    // the 6502 run at 1 MHz or 1Hz
    //
    // the clock division counter is synchronously
    // reset using rst_n to avoid undefined signals
    // in simulation
    //

    //`define SLOWCPU
    `ifdef SLOWCPU
        reg [25:0] clk_div;
        reg cpu_clken;
        always @(posedge clk25)
        begin
            // note: clk_div should be compared to
            //       N-1, where N is the clock divisor
            if ((clk_div == 24999999) || (rst_n == 1'b0))
                clk_div <= 0;
            else
                clk_div <= clk_div + 1'b1;

            cpu_clken <= (clk_div[25:0] == 0);
        end
    `else
        reg [4:0] clk_div;
        reg cpu_clken;
        always @(posedge clk25)
        begin
            // note: clk_div should be compared to
            //       N-1, where N is the clock divisor
            if ((clk_div == 24) || (rst_n == 1'b0))
                clk_div <= 0;
            else
                clk_div <= clk_div + 1'b1;

            cpu_clken <= (clk_div[4:0] == 0);
        end
    `endif

    //////////////////////////////////////////////////////////////////////////
    // Reset
    wire reset;
    reg hard_reset;
    reg [5:0] reset_cnt;
    wire pwr_up_reset = &reset_cnt;

    always @(posedge clk25)
    begin
        if (rst_n == 1'b0)
        begin
            reset_cnt  <= 6'b0;
            hard_reset <= 1'b0;
        end
        else if (cpu_clken)
        begin
            if (!pwr_up_reset)
                reset_cnt <= reset_cnt + 6'b1;

            hard_reset <= pwr_up_reset;
        end
    end

    assign reset = ~(hard_reset && reset_button);

    //////////////////////////////////////////////////////////////////////////
    // 6502
    arlet_6502 my_cpu(
        .clk    (clk25),
        .enable (cpu_clken),
        .reset  (reset),
        .ab     (ab),
        .dbi    (dbi),
        .dbo    (dbo),
        .we     (we),
        .irq_n  (1'b1),
        .nmi_n  (1'b1),
        .ready  (cpu_clken),
        .pc_monitor (pc_monitor)
    );

    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    wire ram_cs =   (ab[15:13] ==  3'b000);            // 0x0000 -> 0x1FFF
    wire uart_cs =  (ab[15:2]  == 14'b11010000000100); // 0xD010 -> 0xD013
    wire ps2kb_cs = 1'b0;
    //wire uart_cs =  (ab[15:1]  == 15'b110100000001001); // 0xD012 -> 0xD013
    //wire ps2kb_cs = (ab[15:1]  == 15'b110100000001000); // 0xD010 -> 0xD011
    wire basic_cs = (ab[15:12] ==  4'b1110);           // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);       // 0xFF00 -> 0xFFFF

    // RAM
    wire [7:0] ram_dout;
    ram my_ram(
        .clk(clk25),
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    // WozMon ROM
    wire [7:0] rom_dout;
    rom_wozmon my_rom_wozmon(
        .clk(clk25),
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    // Basic ROM
    wire [7:0] basic_dout;
    rom_basic my_rom_basic(
        .clk(clk25),
        .address(ab[11:0]),
        .dout(basic_dout)
    );

    // UART
    wire [7:0] uart_dout;
    uart #(
        `ifdef SIM
        100, 10, 2 // for simulation don't need real baud rates
        `else
        25000000, 115200, 8 // 25MHz, 115200 baud, 8 times RX oversampling
        `endif
    ) my_uart(
        .clk(clk25),
        .reset(reset),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .enable(uart_cs & cpu_clken),
        //.address({1'b1, ab[0]}),  // for ps/2
        .address(ab[1:0]),
        .w_en(we & uart_cs),
        .din(dbo),
        .dout(uart_dout)
    );

    // PS/2 keyboard interface
    wire [7:0] ps2_dout;
    ps2keyboard keyboard(
        .clk25(clk25),
        .reset(reset),
        .key_clk(ps2_clk),
        .key_din(ps2_din),
        .cs(ps2kb_cs),
        .address(ab[0]),
        .dout(ps2_dout)
    );

    // link up chip selected device to cpu input
    assign dbi = ram_cs   ? ram_dout :
                 rom_cs   ? rom_dout :
                 basic_cs ? basic_dout :
                 uart_cs  ? uart_dout :
                 ps2kb_cs ? ps2_dout :
                 8'hFF;
endmodule
