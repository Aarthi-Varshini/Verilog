module synchronous_FIFO #(parameter DATA_WIDTH = 8, MEMORY_DEPTH = 8) 
(
	input clk, rst, write_enb, read_enb,
	input[DATA_WIDTH-1:0]data_in,
	output full, empty,
	output reg [DATA_WIDTH-1:0]data_out
);

reg[$clog2(MEMORY_DEPTH):0] write_ptr, read_ptr;
reg[DATA_WIDTH-1:0]memory [MEMORY_DEPTH-1:0];

assign empty = (write_ptr == read_ptr);
assign full = (write_ptr-read_ptr== MEMORY_DEPTH);

always @(posedge clk)
begin
	if(rst) begin
		read_ptr<=0;
		write_ptr<=0;
		data_out<=0;
	end
	else if(write_enb && !full) begin
		memory[write_ptr % MEMORY_DEPTH ]<=data_in;
		write_ptr<=write_ptr+1'b1;
	end
	else if(read_enb && !empty) begin
		data_out<=memory[read_ptr % MEMORY_DEPTH];
		read_ptr<=read_ptr+1'b1;
	end

end
endmodule

