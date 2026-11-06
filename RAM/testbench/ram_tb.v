module ram_tb;
reg clk,  write_enb;
reg [7:0] data_in;
reg [2:0] address;
wire[7:0]data_out;

reg[7:0] expected_memory[7:0];

ram r1(
        .clk(clk),
        .we(write_enb),
        .data_in(data_in),
        .address(address),
        .data_out(data_out)
);

initial begin
        clk = 0;
        forever #5 clk = ~clk;
end

initial begin
        $dumpfile("ram_module.vcd");
        $dumpvars(0, ram_tb);
        write_enb = 0;
	address = 0;
        data_in = 0;
	#10;

// TC:01 Basic write and read
	$display("\n---TC:01 Basic write and read---");
	// Write
	@(negedge clk);
	write_enb = 1;
	address = 3'b101;
	data_in = $random;
	expected_memory[address] = data_in;
	$display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
	//Read
	@(negedge clk);
	write_enb = 0;
	@(posedge clk);
	#1;
	if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
	 end
	 $display("---TC:01 Completed---");

// TC:02 Multiple address access
        $display("\n---TC:02 Multiple address access---");
        // Write 3 values in 3 different address
	@(negedge clk);
        write_enb = 1;
        address = 3'b010;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        @(negedge clk);
        address = 3'b100;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
	@(negedge clk);
        address = 3'b110;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
	// Read 3 values from 3 different address
	@(negedge clk);
        write_enb = 0;
	address = 3'b010;
        @(posedge clk);
        #1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
	 address = 3'b100;
	 @(posedge clk);
	 #1;
	 if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
	 address = 3'b110;
	 @(posedge clk);
	 #1;
	 if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
	 $display("---TC:02 Completed---");

// TC:03 Overwrite existing data
	$display("\n---TC:03 Overwrite existing data---");
        // Write
	@(negedge clk);
        write_enb = 1;
        address = 3'b001;
        data_in = $random;
	$display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
	//Overwrite
	@(negedge clk);
	data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        //Read
	@(negedge clk);
        write_enb = 0;
        @(posedge clk);
        #1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
         $display("---TC:03 Completed---");

// TC:04 Data Integrity check(write enable disabled)
	$display("\n---TC:04 Data Integrity check---");
        // Write
	address = 3'b101;
	$display("Data already available in address %0d is %0d",address,expected_memory[address]);
        @(negedge clk);
        write_enb = 0;
        address = 3'b101;
        data_in = $random;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        //Read
        @(posedge clk);
        #1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
         $display("---TC:04 Completed---");

// TC:05 Data Retention
	$display("\n---TC:05 Data Retention---");
        // Write
        @(negedge clk);
        write_enb = 1;
        address = 3'b011;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        //Read
        @(negedge clk);
        write_enb = 0;
	address = 3'b100;
        @(posedge clk);
        #1;
	$display("[READ] Time = %0t | Address = %0d | Data = %0d", $time, address,data_out);
	address = 3'b011;
	@(posedge clk);
	#1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
         $display("---TC:05 Completed---");

// TC:06 Read from an unwritten address
	$display("\n---TC:06 Read from an unwritten address---");
	//Read
        @(negedge clk);
        write_enb = 0;
        address = 3'b111;
        @(posedge clk);
        #1;
        if (data_out === 8'hx) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = xx | Actual Data = %0h",
                         $time, address,data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = xx | Actual Data = %0h",
                         $time, address, data_out);
         end
         $display("---TC:06 Completed---");

// TC:07 Address boundary testing
	$display("\n---TC:07 Address boundary testing---");
        // Write
        @(negedge clk);
        write_enb = 1;
        address = 3'b000;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        //Read
        @(negedge clk);
        write_enb = 0;
        @(posedge clk);
        #1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
        // Write
        @(negedge clk);
        write_enb = 1;
        address = 3'b111;
        data_in = $random;
        expected_memory[address] = data_in;
        $display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
        //Read
        @(negedge clk);
        write_enb = 0;
        @(posedge clk);
        #1;
        if (data_out == expected_memory[address]) begin
                $display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
            end else begin
                $display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         $time, address, expected_memory[address], data_out);
         end
         $display("---TC:07 Completed---");

// TC:08 Back-to-Back Burst Write & Read Pipeline
	$display("\n---TC:08 Back-to-Back Burst Write & Read Pipeline---");
	address = 3'b000;
	write_enb = 1;
        repeat(8) begin
                @(negedge clk);
                data_in = $random;
		expected_memory[address] = data_in;
		$display("[WRITE] Time = %0t | Address = %0d | DataWritten = %0d", $time, address, data_in);
		@(negedge clk);
		address = address + 1;
	end
	@(posedge clk);
	write_enb = 0;
	@(posedge clk);
	#1;
	address = 3'b000;
	repeat(8) begin
        	@(posedge clk);
        	#1;
        	if (data_out == expected_memory[address]) begin
                	$display("[PASS] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                        	 $time, address, expected_memory[address], data_out);
            	end else begin
                	$display("[ERROR!FAIL] Time = %0t | Address = %0d | Expected Data = %0d | Actual Data = %0d",
                         	$time, address, expected_memory[address], data_out);
         	end
		@(negedge clk);
		address = address + 1;
        end
	$display("---TC:08 Completed---");
	$display("\n");
#500 $finish;
end
endmodule

                                                                                                                      
