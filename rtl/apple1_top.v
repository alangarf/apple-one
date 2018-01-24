//`define CPU_EN
`define CPU2_EN
//`define LED_KEYS_EN
//`define VGA_EN
`define UART_EN

module top(
    input  clk,

    `ifdef UART_EN
    input  uart_rx,
    output uart_tx,
    output uart_cts,
    `endif

    `ifdef LED_KEYS_EN
    output tm_cs,
    output tm_clk,
    inout  tm_dio,
    `endif

    `ifdef VGA_EN
    output vga_h_sync,
    output vga_v_sync,
    output vga_red,
    output vga_grn,
    output vga_blu,
    `endif

    output reg [7:0] led,
    output reg [7:0] ledx
);
    `ifdef CPU2_EN
    wire res;
    reg rw;
    wire [15:0] ab;
    wire [7:0]  dbo;
    reg  [7:0]  dbi;
    `endif

    `ifdef CPU_EN
    wire        res, rw, irq, nmi;
    wire [15:0] ab;
    wire [7:0]  dbo;
    reg  [7:0]  dbi;
    `endif

    //////////////////////////////////////////////////////////////////////////
    // Clocks

    // 12MHz up to 50MHz
    wire clk_50;
    clock_pll clock_pll_inst(
            .REFERENCECLK(clk),
            .PLLOUTCORE(),
            .PLLOUTGLOBAL(clk_50),
            .RESET(1'b1)
    );

    `ifdef CPU_EN
    // generate 1MHz clock enable
    localparam phi_div = 50;
    reg [5:0] phi_cnt;
    wire phi_clk_en;
    
    always @(posedge clk_50)
    begin
        phi_cnt <= phi_cnt + 1;
        if (phi_cnt == phi_div)
            phi_cnt <= 0;
    end
    assign phi_clk_en = (phi_cnt == phi_div) ? 1 : 0;
    `endif

    `ifdef CPU2_EN
    // generate 1MHz clock enable
    localparam phi_div = 50000000;
    reg [26:0] phi_cnt;
    wire phi_clk_en;
    
    always @(posedge clk_50)
    begin
        phi_cnt <= phi_cnt + 1;
        if (phi_cnt == phi_div)
            phi_cnt <= 0;
    end
    assign phi_clk_en = (phi_cnt == phi_div) ? 1 : 0;
    `endif

    //////////////////////////////////////////////////////////////////////////
    // 6502 reset
    reg [7:0] start;
    always @(posedge clk_50)
        if (phi_clk_en)
            if (~start[7]) start <= start + 1;
    
    assign res = start[7];

    //////////////////////////////////////////////////////////////////////////
    // VGA Output
    `ifdef VGA_EN
    reg char_stb;
    reg [6:0] char_in;

    vga my_vga (
        .clk(clk_50),
        .in(char_in),
        .in_stb(char_stb),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_red(vga_red),
        .vga_grn(vga_grn),
        .vga_blu(vga_blu)
    );
    `endif

    //////////////////////////////////////////////////////////////////////////
    // UART
    `ifdef UART_EN
    reg uart_tx_stb;
    reg [7:0] uart_tx_byte;
    wire uart_tx_status;
    async_transmitter my_tx (
        .clk(clk_50),
        .TxD_start(uart_tx_stb),
        .TxD_data(uart_tx_byte),
        .TxD(uart_tx),
        .TxD_busy(uart_tx_status)
        );

    wire uart_rx_stb, rx_idle, rx_end;
    wire [7:0] rx_data;
    reg uart_rx_status, uart_rx_ack;
    reg [7:0] uart_rx_byte;
    async_receiver my_rx(
        .clk(clk_50),
        .RxD(uart_rx),
        .RxD_data_ready(uart_rx_stb),
        .RxD_data(rx_data),
        .RxD_idle(rx_idle),
        .RxD_endofpacket(rx_end)
        );

    always @(posedge clk_50)
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

    assign uart_cts = ~rx_idle || uart_rx_status;
    `endif

    //////////////////////////////////////////////////////////////////////////
    // TM1638 Display

    `ifdef LED_KEYS_EN
    reg  [3:0] display;
    reg  [7:0] digits[7:0];
    reg  [7:0] leds;
    wire [7:0] keys;

    ledAndKey my_led_and_keys (
        .clk        (clk_50),
        .clk_en     (phi_clk_en),
        .rst        (~res),
        .display    (display),
        .digit1     (digits[0]),
        .digit2     (digits[1]),
        .digit3     (digits[2]),
        .digit4     (digits[3]),
        .digit5     (digits[4]),
        .digit6     (digits[5]),
        .digit7     (digits[6]),
        .digit8     (digits[7]),
        .leds       (leds),
        .keys       (keys),
        .tm_cs      (tm_cs),
        .tm_clk     (tm_clk),
        .tm_dio     (tm_dio)
    );
    `endif
    
    //////////////////////////////////////////////////////////////////////////
    // 6502

    `ifdef CPU_EN
    chip_6502 chip_6502 (
        .clk    (clk_50),
        .phi    (phi_clk_en),
        .res    (res),
        .so     (1'b0),
        .rdy    (1'b1),
        .nmi    (nmi),
        .irq    (irq),
        .rw     (rw),
        .dbi    (dbi),
        .dbo    (dbo),
        .ab     (ab)
    );
    `endif

    `ifdef CPU2_EN
    wire c_rw;
    cpu my_cpu (
        .clk    (clk_50),
        .reset  (~res),
        .AB     (ab),
        .DI     (dbi),
        .DO     (dbo),
        .WE     (c_rw),
        .IRQ    (1'b0),
        .NMI    (1'b0),
        .RDY    (phi_clk_en)
    );

    always @(posedge clk_50)
    begin
        if (phi_clk_en)
        begin
            rw <= c_rw;
        end
    end

    `endif

    //////////////////////////////////////////////////////////////////////////
    // I/O locations

    localparam UART_RX      = 16'hD010; // PIA.A register on Apple 1 - RX byte
    localparam UART_RXCR    = 16'hD011; // PIA.A register on Apple 1 - RX control
    localparam UART_TX 	    = 16'hD012; // PIA.B register on Apple 1 - TX byte
    localparam LED_KEYS	    = 16'hD020; // Start address of the Led&Keys module
    localparam LED          = 16'hD000; // Breakout board LEDs
  
    //////////////////////////////////////////////////////////////////////////
    // RAM and ROM

    reg [7:0] ram[0:8191] /* synthesis syn_ramstyle = "block_ram" */;
    reg [7:0] rom[0:255] /* synthesis syn_ramstyle = "block_ram" */;
    reg [7:0] basic[0:4095] /* synthesis syn_ramstyle = "block_ram" */;
    
    initial begin
        $readmemh("../roms/ram.hex", ram, 0, 8191);
        $readmemh("../roms/rom.hex", rom, 0, 255);
        $readmemh("../roms/basic.hex", basic, 0, 4095);
    end

    always @(posedge clk_50)
    begin
        if (phi_clk_en)
        begin
            led <= ab[7:0];
            ledx[6:0] <= ~ab[14:8];
            ledx[7] <= rw;
            

            `ifdef UART_EN
            // reset uart tx and rx strobes
            uart_tx_stb <= 0;
            uart_rx_ack <= 0;
            `endif

            `ifdef VGA_EN
            char_stb <= 0;
            `endif

            if (res)
            begin
                case(ab)
                    `ifdef UART_EN
                    // UART TX control and TX register
                    UART_TX:
                    begin
                        if (rw)
                            dbi <= {uart_tx_status, 7'd0};
                        else
                        begin
                            // Apple 1 terminal only uses 7 bits, MSB indicates
                            // terminal has ack'd RX
                            if (~uart_tx_status)
                            begin
                                uart_tx_byte <= {1'b0, dbo[6:0]};
                                uart_tx_stb <= 1;

                                `ifdef VGA_EN
                                char_in <= dbo[6:0];
                                char_stb <= 1;
                                `endif
                            end
                        end
                    end

                    // UART RX control register
                    UART_RXCR:
                    begin
                        if (rw)
                            dbi <= {uart_rx_status, 7'b0};
                    end

                    // UART RX register
                    UART_RX:
                    begin
                        if (rw)
                        begin
                            dbi <= uart_rx_status ? {1'b1, uart_rx_byte[6:0]} : 8'd0;
                            uart_rx_ack <= 1'b1;
                        end
                    end
                    `endif

                    `ifdef LED_KEYS_EN
                    // LED&KEYS registers
                    LED_KEYS:      if (rw) dbi <= {4'b0, display}; else display <= dbo[3:0];
                    LED_KEYS + 1:  if (rw) dbi <= digits[0]; else digits[0] <= dbo;
                    LED_KEYS + 2:  if (rw) dbi <= digits[1]; else digits[1] <= dbo;
                    LED_KEYS + 3:  if (rw) dbi <= digits[2]; else digits[2] <= dbo;
                    LED_KEYS + 4:  if (rw) dbi <= digits[3]; else digits[3] <= dbo;
                    LED_KEYS + 5:  if (rw) dbi <= digits[4]; else digits[4] <= dbo;
                    LED_KEYS + 6:  if (rw) dbi <= digits[5]; else digits[5] <= dbo;
                    LED_KEYS + 7:  if (rw) dbi <= digits[6]; else digits[6] <= dbo;
                    LED_KEYS + 8:  if (rw) dbi <= digits[7]; else digits[7] <= dbo;
                    LED_KEYS + 9:  if (rw) dbi <= leds; else leds <= dbo;
                    LED_KEYS + 10: if (rw) dbi <= keys;
                    `endif

                    // breakout board LED registers
                    //LED: if (rw) dbi <= led; else led <= dbo;

                    default:
                    begin
                        if (ab[15:12] == 4'b0000 || ab[15:12] == 4'b0001)
                        begin
                            // 0x0000 -> 0x1FFF - RAM
                            dbi <= ram[ab[12:0]];
                            if (~rw) ram[ab[12:0]] <= dbo;
                        end
                        else if (ab[15:12] == 4'b1110)
                        begin
                            // 0xE000 -> 0xEFFF - BASIC
                            dbi <= basic[ab[11:0]];
                        end
                        else if (ab[15:8] == 8'b11111111)
                        begin
                            // 0xFF00 -> 0xFFFF - ROM
                            dbi <= rom[ab[7:0]];
                        end
                        else
                            // unknown address return zero
                            dbi <= 8'h0;
                    end

                endcase
            end
        end
    end
endmodule
