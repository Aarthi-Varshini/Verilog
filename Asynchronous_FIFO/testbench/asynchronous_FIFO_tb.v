module asynchronous_FIFO_tb;

reg wclk,wrst,rclk,rrst,write_enb,read_enb;
reg [7:0] data_in;
wire full,empty;
wire [7:0] data_out;

reg [7:0] r1, r2, r3, r4, r5;
reg [7:0] expected_fifo [7:0];
reg [2:0] tb_wptr = 0;
reg [2:0] tb_rptr = 0;
reg[2:0] check_wptr;
integer occupancy = 0;
wire expected_empty = (occupancy == 0);
wire expected_full  = (occupancy == 8);
integer occupancy_before;

real w_half_period = 5;
real r_half_period = 8;

asynchronous_FIFO_top asyn_fifo(
	.wclk(wclk),
	.wrst(wrst),
	.rclk(rclk),
	.rrst(rrst),
	.write_enb(write_enb),
	.read_enb(read_enb),
	.data_in(data_in),
	.full(full),
	.empty(empty),
	.data_out(data_out)
);

// Clock Generation
initial begin
	wclk = 0;
	forever #(w_half_period) wclk = ~wclk;
end

initial begin
	rclk = 0;
	forever #(r_half_period) rclk = ~rclk;
end

// Task for writing a word
task write_data(input[7:0] din);
	begin
		@(posedge wclk);
		#1;
		write_enb = 1;
		data_in = din;
		@(posedge wclk);
		#1;
		write_enb = 0;
	end
endtask

// Task for reading a word
task read_data(output [7:0] dout);
	begin
		@(posedge rclk);
		#1;
		read_enb = 1;
		@(posedge rclk);
		#1;
		read_enb = 0;
		dout = data_out;
	end
endtask

initial begin
	$dumpfile("asynchronous_fifo_module.vcd");
	$dumpvars(0, asynchronous_FIFO_tb);
	write_enb = 0;
	read_enb = 0;
	data_in = 0;

	// TC:01 Reset
	$display("\n---TC:01 Reset---");
	wrst = 0;
	rrst = 0;
	#30;
	wrst = 1;
	rrst = 1;
	@(posedge rclk);
	#1;
	if (empty == expected_empty && full == expected_full) begin
		$display("[PASS] Time = %0t | Expected value for empty and full are %0d , %0d respectively| Actual value for empty and full are %0d , %0d respectively",$time, expected_empty, expected_full, empty, full);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | Expected value for empty and full are %0d , %0d respectively| Actual value for empty and full are %0d , %0d respectively",$time, expected_empty, expected_full, empty, full);
	end
$display("---TC:01 Completed---");

// TC:02 Pointer wraparound
$display("\n---TC:02 Pointer wraparound---");
$display("The current value of the  write pointer is %d", tb_wptr);
check_wptr = tb_wptr;
repeat(8) begin
	data_in = $random;
	write_data(data_in);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;
end
if (check_wptr == tb_wptr) begin
	$display("[PASS] Time = %0t | Pointer successfully wrapped around! Expected value = %0d| Actual value = %0d",$time,tb_wptr,check_wptr);
end else begin
	$display("[ERROR!FAIL] Time = %0t | Pointer didn't wrap around properly! Expected value = %0d| Actual value = %0d",$time,tb_wptr,check_wptr);
end
$display("---TC:02 Completed---");

#40;

// TC:03 Write 8 words to the FIFO       	
$display("\n---TC:03 Write 8 words to the FIFO---"); 
if (empty == expected_empty && full == expected_full) begin
	$display("[PASS] Time = %0t | Expected value: Empty = %0d, Full = %0d | Actual value: Empty = %0d, Full = %0d", $time, expected_empty, expected_full, empty, full);
end else begin
	$display("[ERROR!FAIL] Time = %0t | Expected value: Empty = %0d, Full = %0d | Actual value: Empty = %0d, Full = %0d", $time, expected_empty, expected_full, empty, full);
end
$display("---TC:03 Completed---");

// TC:04 Attempt a write when full
$display("\n---TC:04 Attempt a write when full---");
occupancy_before = occupancy;
data_in = $random;
write_data(data_in);
if (full && (occupancy == occupancy_before)) begin
	$display("[PASS] Time = %0t | Write successfully blocked because FIFO is full(Full flag = %0d).", $time, full);
end else begin
	$display("[ERROR!FAIL] Time = %0t | FIFO allowed a write when full! Full flag=%0d", $time, full);
end
$display("---TC:04 Completed---");

// TC:05 Read 8 words from the FIFO
$display("\n---TC:05 Read 8 words from the FIFO---");
repeat(8) begin
	@(negedge rclk);
	read_enb = 1;
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;
end
@(posedge rclk);
#1;
if (empty == expected_empty) begin
	$display("[PASS] Time = %0t |FIFO becomes empty successfully! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
end else begin
	$display("[ERROR!FAIL] Time = %0t | FIFO didn't become empty! Expected value for empty = %0d| Actual value for empty = %0d",$time, expected_empty, empty);
end

	$display("---TC:05 Completed---");

// TC:06 Attempt a read when empty
	$display("\n---TC:06 Attempt a read when empty---");
	occupancy_before = occupancy;
	@(negedge rclk);
	read_enb = 1;
	@(posedge rclk);
	#1;
	read_enb = 0;
	if (empty && (occupancy == occupancy_before)) begin
		$display("[PASS] Time = %0t | Read successfully blocked because FIFO is empty(Empty flag = %0d).",
			$time, empty);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | FIFO allowed a read when empty! Empty flag = %0d",
			$time, empty);
	end
	$display("---TC:06 Completed---");

// TC:07 Single byte write and read
	$display("\n---TC:07 Single byte write and read---");
	data_in = $random;
	write_data(data_in);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;
	#40;
	@(posedge rclk);
	#1;
	read_enb = 1;
	tb_rptr =  tb_rptr + 1;
	occupancy = occupancy - 1;
	@(posedge rclk);
	#1;
	read_enb = 0;
	#20;
	if (data_out == data_in  && empty == expected_empty) begin
		$display("[PASS] Time = %0t | Expected read data = %d| Actual read data = %0d", $time, data_in, data_out);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | Expected read data = %d| Actual read data = %0d", $time, data_in, data_out);
	end
	$display("---TC:07 Completed---");

// TC:08 Multiple writes and reads
	$display("\n---TC:08 Multiple writes and reads---");
	write_data(8'd11);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd22);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd33);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd44);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd55);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	#50;

	read_data(r1);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;
	read_data(r2);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;
	read_data(r3);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;
	read_data(r4);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;
	read_data(r5);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	if (r1 == 8'd11 && r2 == 8'd22 && r3 == 8'd33 && r4 == 8'd44 && r5 == 8'd55) begin
		$display("[PASS] Time = %0t | Multiple writes and reads verified successfully in order. Expected value = 11, 22, 33, 44, 55, Actual value = %0d, %0d, %0d, %0d, %0d", $time,r1, r2, r3, r4, r5);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | Order mismatch or data error. Expected value = 11, 22, 33, 44, 55, Actual value = %0d, %0d, %0d, %0d, %0d", $time, r1, r2, r3, r4, r5);
	end
	$display("---TC:08 Completed---");

// TC:09 Reset while FIFO contains data
	$display("\n---TC:09 Reset while FIFO contains data---");
	write_data(8'd77);
	write_data(8'd88);
	#20;
	wrst = 0;
	rrst = 0;
	occupancy = 0;
	#30;
	wrst = 1;
	rrst = 1;
	#30;
	if (empty == expected_empty && full == expected_full) begin
		$display("[PASS] Time = %0t | FIFO returned to empty = 1, full = 0 after reset with stored data.", $time);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | FIFO flags incorrect after reset during data storage.", $time);
	end
	$display("---TC:09 Completed---");

// TC:10 Different clock frequencies
	$display("\n---TC:10 Different clock frequencies---");
	$display("\nCondition 1: Write clock faster than Read clock");
	$display("Write clock period = %g ns(%g MHz), Read clock period = %g ns(%g MHz)", (w_half_period*2),(1000/(w_half_period*2)),(r_half_period*2),(1000/(r_half_period*2)));
	#60; 
	write_data(8'd31);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd32);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd33);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd34);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd35);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	#50;

	read_data(r1);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r2);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r3);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r4);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r5);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	if (r1 == 8'd31 && r2 == 8'd32 && r3 == 8'd33 && r4 == 8'd34 && r5 == 8'd35) begin
		$display("[PASS] Time = %0t | Write clock faster than Read clock - Multiple writes and reads verified successfully in order. Expected value = 31, 32, 33, 34, 35, Actual value = %0d, %0d, %0d, %0d, %0d", $time,r1, r2, r3, r4, r5);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | Write clock faster than Read clock - Order mismatch or data error. Expected value = 31, 32, 33, 34, 35, Actual value = %0d, %0d, %0d, %0d, %0d", $time, r1, r2, r3, r4, r5);
	end

	$display("\nCondition 2: Read clock faster than Write clock");
	w_half_period = 10;
	r_half_period = 4;
	$display("Write clock period = %g ns(%g MHz), Read clock period = %g ns(%g MHz)", (w_half_period*2),(1000/(w_half_period*2)),(r_half_period*2),(1000/(r_half_period*2)));
	#60; 
	write_data(8'd21);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd22);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd23);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd24);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	write_data(8'd25);
	expected_fifo[tb_wptr] = data_in;
	tb_wptr = tb_wptr + 1;
	occupancy = occupancy + 1;

	#50;

	read_data(r1);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r2);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r3);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r4);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;

	read_data(r5);
	tb_rptr = tb_rptr + 1;
	occupancy = occupancy - 1;


	if (r1 == 8'd21 && r2 == 8'd22 && r3 == 8'd23 && r4 == 8'd24 && r5 == 8'd25) begin
		$display("[PASS] Time = %0t | Read clock faster than Write clock - Multiple writes and reads verified successfully in order. Expected value = 21, 22, 23, 24, 25, Actual value = %0d, %0d, %0d, %0d, %0d", $time,r1, r2, r3, r4, r5);
	end else begin
		$display("[ERROR!FAIL] Time = %0t | Read clock faster than Write clock - Order mismatch or data error. Expected value = 21, 22, 23, 24, 25, Actual value = %0d, %0d, %0d, %0d, %0d", $time, r1, r2, r3, r4, r5);
	end
	$display("---TC:10 Completed---");

	$display("\n");
	#2000;
	$finish;
end
endmodule
