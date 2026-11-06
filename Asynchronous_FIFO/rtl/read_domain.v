module read_domain #(parameter WIDTH = 3)
(
	input rclk, rrst,read_enb, empty,
        output reg[WIDTH:0] b_rptr,g_rptr,
	output wire[WIDTH-1:0] read_add
);

wire [WIDTH:0] b_rptr_next;
wire [WIDTH:0] g_rptr_next;

assign b_rptr_next = b_rptr + ((read_enb && !empty) ? 1'b1 : 1'b0);

assign g_rptr_next = (b_rptr_next >> 1) ^ b_rptr_next;

assign read_add = b_rptr[WIDTH-1:0];

always @(posedge rclk or negedge rrst) begin
        if(!rrst)begin
                b_rptr<=0;
                g_rptr<=0;
        end
        else begin
                if(read_enb && !empty)begin
                        b_rptr<=b_rptr_next;
			g_rptr<=g_rptr_next;
                end
        end
end
endmodule

