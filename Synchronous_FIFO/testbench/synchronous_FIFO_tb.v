module synchronous_FIFO_tb;
reg clk, rst, read_enb, write_enb;
wire full, empty;
reg [7:0] data_in;
wire [7:0] data_out;

reg [7:0] expected_fifo [7:0];
reg [2:0] tb_wptr = 0;
reg [2:0] tb_rptr = 0;
reg[2:0] check_wptr;
integer occupancy = 0;
wire expected_empty = (occupancy == 0);
wire expected_full  = (occupancy == 8); 
integer occupancy_before;

synchronous_FIFO syn_fifo(
	.clk(clk),
	.rst(rst),
	.write_enb(write_enb),
	.read_enb(read_enb),
	.data_in(data_in),
	.full(full),
	.empty(empty),
	.data_out(data_out)
);

initial begin
	clk = 0;
	forever #5 clk = ~clk;
end

initial begin
	$dumpfile("synchronous_fifo_module.vcd");
	$dumpvars(0, synchronous_FIFO_tb);

	rst = 1;
	write_enb = 0;
	read_enb = 0;
	data_in = 0;

// TC:01 Reset
        $display("\n---TC:01 Reset---");
	@(posedge clk);
	#1;
        if (empty == expected_empty && full == expected_full) begin
                $display("[PASS] Time = %0t | Expected value for empty and full are %0d , %0d respectively| Actual value for empty and full are %0d , %0d respectively",$time, expected_empty, expected_full, empty, full);
            end else begin
         	$display("[ERROR!FAIL] Time = %0t | Expected value for empty and full are %0d , %0d respectively| Actual value for empty and full are %0d , %0d respectively",$time, expected_empty, expected_full, empty, full);
	 end
         $display("---TC:01 Completed---");

// TC:02 Write one word
	$display("\n---TC:02 Write one word---");
	#10 rst = 0;
	@(negedge clk);
	write_enb = 1;
	data_in = $random;
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;
	@(posedge clk);
	#1;
	if (empty == expected_empty) begin
                $display("[PASS] Time = %0t | Write happended successfully! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Write didn't happend successfully! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
         end
         $display("---TC:02 Completed---");

	@(negedge clk);
	write_enb= 0;

// TC:03 Read one word
        $display("\n---TC:03 Read one word---");
	@(negedge clk);
	read_enb = 1;
	@(posedge clk);
	#1;
	if (data_out == expected_fifo[tb_rptr]) begin
                $display("[PASS] Time = %0t | Expected Data = %0d | Actual Data = %0d",
                         $time, expected_fifo[tb_rptr], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Expected Data = %0d | Actual Data = %0d",
                         $time,expected_fifo[tb_rptr], data_out);
         end
	 tb_rptr = tb_rptr + 1;
	 occupancy = occupancy - 1;
         $display("---TC:03 Completed---");

	@(negedge clk);
	read_enb=0;

// TC:04 Pointer wraparound
	$display("\n---TC:04 Pointer wraparound---");
	$display("After one write the pointer updated to %d", tb_wptr);
	check_wptr = tb_wptr;
	repeat(8) begin
		@(negedge clk);
		write_enb = 1;
		data_in = $random;
		expected_fifo[tb_wptr] = data_in;
		tb_wptr = tb_wptr + 1;
		occupancy = occupancy + 1;
	end
	if (check_wptr == tb_wptr) begin
                $display("[PASS] Time = %0t | Pointer successfully wrapped around! Expected value = %0d| Actual value = %0d",$time,tb_wptr,check_wptr);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Pointer didn't wrap around properly! Expected value = %0d| Actual value = %0d",$time,tb_wptr,check_wptr);
         end
         $display("---TC:04 Completed---");
	
// TC:05 Write eight words
	$display("\n---TC:05 Write eight words---");
	@(posedge clk);
	#1;
	if (full == expected_full) begin
                $display("[PASS] Time = %0t | FIFO becomes full successfully! Expected value for full = %0d| Actual value for full = %0d",$time, expected_full,full);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | FIFO didn't become full! Expected value for full = %0d| Actual value for full = %0d",$time, expected_full,full);
         end
         $display("---TC:05 Completed---");

	@(negedge clk);
	write_enb = 0;
	
// TC:06 Attempt a write when full
        $display("\n---TC:06 Attempt a write when full---");
        occupancy_before = occupancy;  
        @(negedge clk);
        write_enb = 1;
        data_in = $random;
        @(posedge clk);
        #1;
	write_enb = 0; 
        if (full && (occupancy == occupancy_before)) begin
            $display("[PASS] Time = %0t | Write successfully blocked because FIFO is full(Full flag = %0d).", $time, full);
        end else begin
            $display("[ERROR!FAIL] Time = %0t | FIFO allowed a write when full! Full flag=%0d", $time, full);
        end
        
        $display("---TC:06 Completed---");

// TC:07 Read eight words
        $display("\n---TC:07 Read eight words---");
	repeat(8) begin
		@(negedge clk);
                read_enb = 1;
		tb_rptr = tb_rptr + 1;
		occupancy = occupancy - 1;
	end
	@(posedge clk);
        #1;
        if (empty == expected_empty) begin
                $display("[PASS] Time = %0t |FIFO becomes empty successfully! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | FIFO didn't become empty! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
         end
         $display("---TC:07 Completed---");

	@(negedge clk);
        read_enb = 0;

// TC:08 Attempt a read when empty
        $display("\n---TC:08 Attempt a read when empty---");
        occupancy_before = occupancy;
        @(negedge clk);
        read_enb = 1;
        @(posedge clk);
        #1;
        read_enb = 0;
        if (empty && (occupancy == occupancy_before)) begin
            $display("[PASS] Time = %0t | Read successfully blocked because FIFO is empty(Empty flag = %0d).", 
                     $time, empty);
        end else begin
            $display("[ERROR!FAIL] Time = %0t | FIFO allowed a read when empty! Empty flag = %0d", 
                     $time, empty);
        end
        $display("---TC:08 Completed---");


// TC:09 Write and read repeatedly
	$display("\n---TC:09 Write and read repeatedly---");
	repeat(4) begin
		@(negedge clk);
		write_enb = 1;
		data_in = $random;
		expected_fifo[tb_wptr] = data_in;
        	tb_wptr = tb_wptr + 1;
		@(negedge clk);
		write_enb = 0;

		@(negedge clk);
		read_enb = 1;
		@(posedge clk);
        	#1;
        	if (data_out == expected_fifo[tb_rptr]) begin
                	$display("[PASS] Time = %0t | Expected Data = %0d | Actual Data = %0d",$time, expected_fifo[tb_rptr], data_out);
            	end else begin
                	$display("[ERROR!FAIL] Time = %0t | Expected Data = %0d | Actual Data = %0d",$time,expected_fifo[tb_rptr], data_out);
         	end
         	tb_rptr = tb_rptr + 1;
		@(negedge clk);
		read_enb= 0;
	end
	$display("---TC:09 Completed---");
	$display("\n");

#500 $finish;
end
endmodule

