module ram(
	input clk, we,
	input[7:0] data_in,
	input[2:0] address, 
	output reg[7:0] data_out
);

reg[7:0]memory[7:0];

always @(posedge clk) begin
	if(we)begin
		memory[address]<=data_in;		
	end
	else begin
		data_out<=memory[address];
	end
end
endmodule
