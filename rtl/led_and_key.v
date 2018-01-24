module ledAndKey(
    input clk,
    input clk_en,
    input rst,

    input [3:0] display,
    input [7:0] digit1,
    input [7:0] digit2,
    input [7:0] digit3,
    input [7:0] digit4,
    input [7:0] digit5,
    input [7:0] digit6,
    input [7:0] digit7,
    input [7:0] digit8,
    input [7:0] leds,

    output reg [7:0] keys,

    output reg tm_cs,
    output tm_clk,
    inout  tm_dio
);

    localparam 
        HIGH    = 1'b1,
        LOW     = 1'b0;

    localparam [7:0]
        C_READ  = 8'b01000010,
        C_WRITE = 8'b01000000,
        C_DISP  = 8'b10001111,
        C_ADDR  = 8'b11000000;

    reg counter;
    reg [5:0] instruction_step;

    // set up tristate IO pin for display
    //   tm_dio     is physical pin
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //   tm_rw      selects input or output
    reg tm_rw;
    wire dio_in, dio_out;
    SB_IO #(
        .PIN_TYPE(6'b101001),
        .PULLUP(1'b1)
    ) tm_dio_io (
        .PACKAGE_PIN(tm_dio),
        .OUTPUT_ENABLE(tm_rw),
        .D_IN_0(dio_in),
        .D_OUT_0(dio_out)
    );

    // setup tm1638 module with it's tristate IO
    //   tm_in      is read from module
    //   tm_out     is written to module
    //   tm_latch   triggers the module to read/write display
    //   tm_rw      selects read or write mode to display
    //   busy       indicates when module is busy
    //                (another latch will interrupt)
    //   tm_clk     is the data clk
    //   dio_in     for reading from display
    //   dio_out    for sending to display
    //
    //   tm_data    the tristate io pin to module
    reg tm_latch;
    wire busy;
    wire [7:0] tm_data, tm_in;
    reg [7:0] tm_out;

    assign tm_in = tm_data;
    assign tm_data = tm_rw ? tm_out : 8'hZZ;

    tm1638 u_tm1638 (
        .clk(clk),
        .clk_en(clk_en),
        .rst(rst),
        .data_latch(tm_latch),
        .data(tm_data),
        .rw(tm_rw),
        .busy(busy),
        .sclk(tm_clk),
        .dio_in(dio_in),
        .dio_out(dio_out)
    );

    always @(posedge clk) begin
        if (clk_en) begin
            if (rst) begin
                instruction_step <= 6'b0;
                tm_cs <= HIGH;
                tm_rw <= HIGH;

                counter <= 1'b0;
                keys <= 8'b0;

            end else begin
                if (counter && ~busy) begin
                    case (instruction_step)
                        // *** KEYS ***
                        1:  {tm_cs, tm_rw}     <= {LOW, HIGH};
                        2:  {tm_latch, tm_out} <= {HIGH, C_READ}; // read mode
                        3:  {tm_latch, tm_rw}  <= {HIGH, LOW};

                        //  read back keys S1 - S8
                        4:  {keys[7], keys[3]} <= {tm_in[0], tm_in[4]};
                        5:  {tm_latch}         <= {HIGH};
                        6:  {keys[6], keys[2]} <= {tm_in[0], tm_in[4]};
                        7:  {tm_latch}         <= {HIGH};
                        8:  {keys[5], keys[1]} <= {tm_in[0], tm_in[4]};
                        9:  {tm_latch}         <= {HIGH};
                        10: {keys[4], keys[0]} <= {tm_in[0], tm_in[4]};
                        11: {tm_cs}            <= {HIGH};

                        // *** DISPLAY ***
                        12: {tm_cs, tm_rw}     <= {LOW, HIGH};
                        13: {tm_latch, tm_out} <= {HIGH, C_WRITE}; // write mode
                        14: {tm_cs}            <= {HIGH};

                        15: {tm_cs, tm_rw}     <= {LOW, HIGH};
                        16: {tm_latch, tm_out} <= {HIGH, C_ADDR}; // set addr 0 pos

                        17: {tm_latch, tm_out} <= {HIGH, digit1};           // Digit 1
                        18: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[7]}};  // LED 1

                        19: {tm_latch, tm_out} <= {HIGH, digit2};           // Digit 2
                        20: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[6]}};  // LED 2

                        21: {tm_latch, tm_out} <= {HIGH, digit3};           // Digit 3
                        22: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[5]}};  // LED 3

                        23: {tm_latch, tm_out} <= {HIGH, digit4};           // Digit 4
                        24: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[4]}};  // LED 4

                        25: {tm_latch, tm_out} <= {HIGH, digit5};           // Digit 5
                        26: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[3]}};  // LED 5

                        27: {tm_latch, tm_out} <= {HIGH, digit6};           // Digit 6
                        28: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[2]}};  // LED 6

                        29: {tm_latch, tm_out} <= {HIGH, digit7};           // Digit 7
                        30: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[1]}};  // LED 7

                        31: {tm_latch, tm_out} <= {HIGH, digit8};           // Digit 8
                        32: {tm_latch, tm_out} <= {HIGH, {7'b0, leds[0]}};  // LED 8

                        33: {tm_cs}            <= {HIGH};

                        34: {tm_cs, tm_rw}     <= {LOW, HIGH};
                        35: {tm_latch, tm_out} <= {HIGH, {4'b1000, display}}; // display
                        36: {tm_cs, instruction_step} <= {HIGH, 6'b0};

                    endcase

                    instruction_step <= instruction_step + 1;

                end else if (busy) begin
                    // pull latch low next clock cycle after module has been
                    // latched
                    tm_latch <= LOW;
                end

                counter <= ~counter;
            end
        end
    end
endmodule
