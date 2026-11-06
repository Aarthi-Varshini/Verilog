module write_domain #(parameter WIDTH = 3)
(
	input wclk, wrst, write_enb, full,
	output reg[WIDTH:0] b_wptr,g_wptr,
	output wire[WIDTH-1:0] write_add
);

wire [WIDTH:0] b_wptr_next;
wire [WIDTH:0] g_wptr_next;

assign write_add = b_wptr[WIDTH-1:0];

assign b_wptr_next = b_wptr + ((write_enb && !full) ? 1'b1 : 1'b0);

assign g_wptr_next = (b_wptr_next >> 1) ^ b_wptr_next;

always @(posedge wclk or negedge wrst) begin
	if(!wrst)begin
		b_wptr<=0;
		g_wptr<=0;
	end
	else begin
		if(write_enb && !full)begin
			b_wptr<=b_wptr_next;
			g_wptr<=g_wptr_next;
		end
	end
end
endmodule

