module apple1(
    input  clk25,           // 25 MHz master clock
    input  rst_n,           // active low synchronous reset (needed for simulation)

    input  uart_rx,
    output uart_tx,
    output uart_cts
);
    //////////////////////////////////////////////////////////////////////////
    // Registers and Wires

    reg [15:0] ab;
    wire [7:0] dbi;
    reg [7:0] dbo;
    reg we;

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
                reset_cnt <= reset_cnt + 1;

            hard_reset <= pwr_up_reset;
        end
    end

    assign reset = ~hard_reset;

    //////////////////////////////////////////////////////////////////////////
    // 6502
    wire [7:0] dbo_c;
    wire [15:0] ab_c;
    wire we_c;
    reg [7:0] dbi_c;

    cpu my_cpu (
        .clk    (clk25),
        .reset  (reset),
        .AB     (ab_c),
        .DI     (dbi_c),
        .DO     (dbo_c),
        .WE     (we_c),
        .IRQ    (1'b1),
        .NMI    (1'b1),
        .RDY    (cpu_clken)
    );

    always @(posedge clk25)
    begin
        if (cpu_clken)
        begin
            ab <= ab_c;
            dbo <= dbo_c;
            dbi_c <= dbi;
            we <= we_c;
        end
    end

    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    wire ram_cs =   (ab[15:13] ==  3'b000);            // 0x0000 -> 0x1FFF
    wire uart_cs =  (ab[15:2]  == 14'b11010000000100); // 0xD010 -> 0xD013
    wire basic_cs = (ab[15:12] ==  4'b1110);           // 0xE000 -> 0xEFFF
    wire rom_cs =   (ab[15:8]  ==  8'b11111111);       // 0xFF00 -> 0xFFFF

    // RAM
    wire [7:0] ram_dout;
    ram #("../../roms/ram.hex") my_ram (
        .clk(clk25),
        .address(ab[12:0]),
        .w_en(we & ram_cs),
        .din(dbo),
        .dout(ram_dout)
    );

    // WozMon ROM
    wire [7:0] rom_dout;
    rom_wozmon #("../../roms/wozmon.hex") my_rom_wozmon (
        .clk(clk25),
        .address(ab[7:0]),
        .dout(rom_dout)
    );

    // UART
    wire [7:0] uart_dout;
    uart my_uart (
        .clk(clk25),

        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .uart_cts(uart_cts),

        .enable(uart_cs & cpu_clken),
        .address(ab[1:0]),
        .w_en(we & uart_cs),
        .din(dbo),
        .dout(uart_dout)
    );

    // link up chip selected device to cpu input
    assign dbi = ram_cs  ? ram_dout : 
                 rom_cs  ? rom_dout :
                 uart_cs ? uart_dout :
                 8'hFF;
endmodule
