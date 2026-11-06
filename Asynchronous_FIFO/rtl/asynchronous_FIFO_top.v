module asynchronous_FIFO_top #(parameter DATA_WIDTH = 8, MEMORY_DEPTH = 8, WIDTH = 3)
(
        input wclk, wrst, rclk, rrst,write_enb, read_enb,
        input[DATA_WIDTH-1:0]data_in,
        output full, empty,
        output reg [DATA_WIDTH-1:0]data_out
);

wire [WIDTH:0] binary_write_ptr, binary_read_ptr, gray_write_ptr, gray_read_ptr ,gray_read_pointer_sync, gray_write_pointer_sync;
wire [WIDTH-1:0] write_address, read_address;
reg[DATA_WIDTH-1:0]memory [MEMORY_DEPTH-1:0];

assign empty = (gray_write_pointer_sync == gray_read_ptr);
assign full = (gray_write_ptr =={~gray_read_pointer_sync[WIDTH:WIDTH-1],gray_write_ptr[WIDTH-2:0]});

write_domain wd1 (
	.wclk(wclk),
        .wrst(wrst),
	.write_enb(write_enb),
        .full(full),
        .b_wptr(binary_write_ptr),
        .g_wptr(gray_write_ptr),
        .write_add(write_address)
);

synchronizer syn1 (
	.clk(rclk),
        .rst(rrst),
        .q_in(gray_write_ptr),
        .q_out(gray_write_pointer_sync)
);

read_domain rd1(
        .rclk(rclk),
        .rrst(rrst),
        .read_enb(read_enb),
        .empty(empty),
        .b_rptr(binary_read_ptr),
        .g_rptr(gray_read_ptr),
        .read_add(read_address)
);

synchronizer syn2 (
        .clk(wclk),
        .rst(wrst),
        .q_in(gray_read_ptr),
        .q_out(gray_read_pointer_sync)
);

always @(posedge wclk or negedge wrst) begin
	if(wrst && write_enb && !full) begin
		memory[write_address]<=data_in;
	end
end

always @(posedge rclk or negedge rrst) begin
	if(!rrst) begin
		data_out<=0;
	end
	else begin
		if(read_enb && !empty) begin
			data_out<=memory[read_address];
		end
	end
end
endmodule
