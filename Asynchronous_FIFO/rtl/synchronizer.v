module synchronizer #(parameter WIDTH = 4)
(
	input clk, rst, 
	input[WIDTH-1:0] q_in,
	output reg[WIDTH-1:0] q_out
);

reg[WIDTH-1:0] q;

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		q<=0;
		q_out<=0;
	end
	else begin
		q<=q_in;
		q_out<=q;
	end
end
endmodule

