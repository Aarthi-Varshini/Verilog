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

    reg[7:0] data_in;
    reg[7:0] expected_data;
    reg[7:0] expected_data_2;
    reg[7:0] expected_data_3;
    reg[7:0] data_test;
    reg[7:0] data_test_2;

    always begin
        #1 clk = ~clk;
    end

    task send_byte(input [7:0] val);
        begin
            @(negedge clk);
            input_data = val;
            start_en = 1'b1;
            @(negedge clk);
            start_en = 1'b0;
        end
    endtask

    initial begin
        $dumpfile("uart_module.vcd");
        $dumpvars(0, uart_tb);

        clk = 1'b0;
        start_en = 1'b0;
        input_data = 8'h00;
        rst = 1'b1;

// TC:01 Reset operation
        $display("\n---TC:01 Reset Operation---");
        #20;
        rst = 1'b0;
        #20;
	if (data == 8'h00) begin
            $display("[PASS] Reset successful, Expected value for reset = %0d, Actual value for reset = %0d",0,rst);
    	end else begin
            $display("[ERROR!FAIL] Reset failed, Expected value for reset = %0d, Actual value for reset = %0d",0,rst);
    	end
	$display("---TC:01 Completed---");

// TC:02 Single-Byte Transmission & Reception
        $display("\n---TC:02 Single-Byte Transmission & Reception---");
	data_in = $random;
        send_byte(data_in);
	expected_data = data_in;
        #200000;
	if (data == expected_data) begin
            $display("[PASS] Time = %0t | Expected Data = %0d | Actual Data = %0d",
                         $time, expected_data, data);
	 end else begin
		 $display("[ERROR!FAIL] Time = %0t | Expected Data = %0d | Actual Data = %0d",
                         $time,expected_data, data);
	 end
	 $display("---TC:02 Completed---");

// TC:03 All-Zero Data
	$display("\n---TC:03 All-Zero Data---");
        data_in = 8'b00000000;
	send_byte(data_in);
	expected_data = data_in;
        #200000;
	if (data == expected_data) begin
            $display("[PASS] All-zero data handled correctly| Expected Data = %0b | Actual Data = %0b",expected_data, data);
    	end  else begin
            $display("[ERROR!FAIL] All-zero data not handled properly| Expected Data = %0b | Actual Data = %0b",expected_data, data);
    end
    $display("---TC:03 Completed---");

// TC:04 All-One Data     
	$display("\n---TC:04 All-One Data---");
        data_in = 8'b11111111;
	send_byte(data_in);
	expected_data = data_in;
        #200000;
	if (data == expected_data) begin
            $display("[PASS] All-one data handled correctly| Expected Data = %0b | Actual Data = %0b",expected_data, data);
    	end  else begin
            $display("[ERROR!FAIL] All-one data not handled properly| Expected Data = %0b | Actual Data = %0b",expected_data, data);
    end
    $display("---TC:04 Completed---");

// TC:05 Alternating-Bit Patterns
        $display("\n--- TC:05 Alternating-Bit Patterns---");
	data_in = 8'b01010101;
        send_byte(data_in);
	expected_data = data_in;
        #200000;
	data_test = data;
	data_in = 8'b10101010;
        send_byte(data_in);
	expected_data_2 = data_in;
        #200000;
	if (data_test == expected_data && data == expected_data_2) begin
            $display("[PASS] Alternationg-Bit Patterns handled correctly| First Expected Data = %0b | First Actual Data = %0b | Second Expected Data =%0b | Second Actual Data = %0b",expected_data, data_test, expected_data_2, data);
    	end  else begin
            $display("[ERROR!FAIL] Alternationg-Bit Patterns not handled properly| First Expected Data = %0b | First Actual Data = %0b | Second Expected Data =%0b | Second Actual Data = %0b",expected_data, data_test, expected_data_2, data);
    end
    $display("---TC:05 Completed---");

// TC:06 Multiple Consecutive Bytes 
        $display("\n---TC:06 Multiple Consecutive Bytes---");
        data_in = $random;
	send_byte(data_in);
	expected_data = data_in;
        #120000;
	data_test = data;
	data_in = $random;
        send_byte(data_in);
	expected_data_2 = data_in;
        #150000;
	data_test_2 = data;
	data_in = $random;
        send_byte(data_in);
	expected_data_3 = data_in;
        #200000; 
	if (data_test == expected_data && data_test_2 == expected_data_2 && data == expected_data_3) begin
            $display("[PASS] Multiple Consecutive Bytes handled correctly| First Expected Data = %0d | First Actual Data = %0d | Second Expected Data =%0d | Second Actual Data = %0d | Third Expected Data = %0d | Third Actual Data = %0d",expected_data, data_test, expected_data_2, data_test_2, expected_data_3, data);
    	end  else begin
            $display("[ERROR!FAIL] Multiple Consecutive Bytes not handled properly| First Expected Data = %0d | First Actual Data = %0d | Second Expected Data =%0d | Second Actual Data = %0d | Third Expected Data = %0d | Third Actual Data = %0d",expected_data, data_test, expected_data_2, data_test_2, expected_data_3, data);
        end
    $display("---TC:06 Completed---");
    $display("\n");

    #150000 $finish;
    end
endmodule
