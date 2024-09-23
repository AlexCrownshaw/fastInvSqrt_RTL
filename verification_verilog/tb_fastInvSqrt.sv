module tb_fastInvSqrt;
    
    // Parameters for fixed-point configuration
    parameter INT_WIDTH = 12;
    parameter FRACT_WIDTH = 4;
    parameter WORD_WIDTH = INT_WIDTH + FRACT_WIDTH;
    
    // Inputs to DUT
    reg clk;
    reg rst_n;
    reg valid_in;
    reg [WORD_WIDTH-1:0] data_in;
    
    // Outputs from DUT
    wire ready_in;
    wire [WORD_WIDTH-1:0] data_out;
    wire valid_out;
    reg ready_out;

    // Import the C function from DPI-C
    import "DPI-C" function int compute_inv_sqrt(input int fixed_point_value, input int fract_width);

    // Instantiate the DUT
    fastInvSqrt #(
        .INT_WIDTH(INT_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .valid_in(valid_in),
        .ready_in(ready_in),
        .data_out(data_out),
        .valid_out(valid_out),
        .ready_out(ready_out)
    );
    
    // Testbench components
    initial begin
        $display("Starting the simulation");
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        ready_out = 1;
        data_in = 0;
        #10 rst_n = 1; // Release reset after some time
        run_tests();
        #1000 $finish;
    end
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end    

    // Test procedure
    task run_tests;
        integer i;
        reg [WORD_WIDTH-1:0] test_input;
        reg [31:0] expected_output;
        reg [WORD_WIDTH-1:0] received_output;
//        real tolerance = 1e-5;
        
        for (i = 0; i < 100; i = i + 1) begin
            test_input = $random; // Generate random input for testing
            
            // Call the C reference model to get the expected result
            expected_output = compute_inv_sqrt(test_input, FRACT_WIDTH);
            
            // Apply inputs to DUT
            valid_in = 1'b1;
            data_in = test_input;
            
            // Wait until DUT is ready
            @(posedge ready_in);
            if (valid_in && ready_in) begin
                valid_in = 1'b0;
                ready_out = 1'b1;
            end
            // Wait until DUT output is valid
            @(posedge valid_out);
            if (valid_out && ready_out) begin
                ready_out = 1'b0;
            end
            
            received_output = data_out;
            
            // Compare the received output with the expected output
            if (received_output - expected_output == 0) begin
                $display("Test %d PASSED. Input: %h, Output: %h, Expected: %h", i, test_input, received_output, expected_output);
            end else begin
                $display("Test %d FAILED. Input: %h, Output: %h, Expected: %h", i, test_input, received_output, expected_output);
            end
            
            valid_in = 0;
        end
    endtask
    
    // Coverage block
    covergroup cg_input_range @(posedge clk);
        input_valid: coverpoint data_in {
            bins low_range = {[0:10]};
            bins mid_range = {[11:1000]};
            bins high_range = {[1001:$]};
        }
    endgroup
    cg_input_range cg;
    
    // Run coverage
    initial begin
        cg = new();
        cg.start();
    end

endmodule
