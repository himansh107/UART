`timescale 1ns/10ps
 

 
module uart_tb ();
 
  // Testbench uses a 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.
  parameter c_CLOCK_PERIOD_NS = 100;
  parameter c_CLKS_PER_BIT    = 87;
  parameter c_BIT_PERIOD      = 8600;
   
  reg r_Clock = 0;
  reg tx_dv = 0;
  wire w_tx_done;
  reg [7:0] data_in = 0;
  reg rx_serial_input = 1;
  wire [7:0] data_read;
  wire connection;
 
  // Takes in input byte and serializes it 
  task UART_WRITE_BYTE;
    input [7:0] i_data;
    integer     ii;
    begin
       
      // Send Start Bit
      rx_serial_input <= 1'b0;
      #(c_BIT_PERIOD);
      #1000;
       
       
      // Send Data Byte
      for (ii=0; ii<8; ii=ii+1)
        begin
          rx_serial_input <= i_data[ii];
          #(c_BIT_PERIOD);
        end
       
      // Send Stop Bit
      rx_serial_input <= 1'b1;
      #(c_BIT_PERIOD);
     end
  endtask // UART_WRITE_BYTE
   
   
  uart_rx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_RX_INST
    (.i_Clock(r_Clock),
     .rx_serial_input(connection),
     .rx_data_valid(),
     .rx_output(data_read)
     );
   
  uart_tx #(.CLKS_PER_BIT(c_CLKS_PER_BIT)) UART_TX_INST
    (.i_Clock(r_Clock),
     .tx_data_valid(tx_dv),
     .in(data_in),
     .tx_active(),
     .tx_serial_data(connection),
     .tx_done(w_tx_done)
     );
 
   
  always
    #(c_CLOCK_PERIOD_NS/2) r_Clock <= !r_Clock;
 
   
  // Main Testing:
  initial
    begin
       
      // Tell UART to send a command (exercise Tx)
      @(posedge r_Clock);
      @(posedge r_Clock);
      tx_dv <= 1'b1;
      data_in <= 8'hAB;
      @(posedge r_Clock);
      tx_dv <= 1'b0;
      @(posedge w_tx_done);
       
      // Send a command to the UART (exercise Rx)
      @(posedge r_Clock);
      UART_WRITE_BYTE(8'h3F);
      @(posedge r_Clock);
             
      // Check that the correct command was received
      if (data_read == data_in)
        $display("Test Passed - Correct Byte Received");
      else
        $display("Test Failed - Incorrect Byte Received");
       
	   #40 $stop;
    end
   
endmodule