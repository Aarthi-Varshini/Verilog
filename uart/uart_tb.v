module uart_tb;
reg clk, rst, start_en;
reg [7:0] input_data;
wire [7:0] data;

uart u1(
    .clk(clk),
    .rst(rst),
    .start_en(start_en),
    .input_data(input_data),
    .data(data)
);

always begin
    #1 clk = ~clk;
end

initial begin
    $dumpfile("uart_module.vcd");
    $dumpvars(0, uart_tb);

    clk = 1'b0;
    start_en = 1'b0;
    input_data = 8'b0;
    rst = 1'b1;

    #20;
    rst = 1'b0;
    #20;

    start_en = 1'b1;
    input_data = 8'd18;

    #10;
    start_en = 1'b0;
    #200000;
    $display("Test Bench Complete. Output Register Data Value Is: %d", data);
    start_en = 1'b1;
    input_data = 8'd88;

    #200010;
    start_en = 1'b0;

    #400000;
    $display("Test Bench Complete. Output Register Data Value Is: %d", data);

    $finish;
end

endmodule
