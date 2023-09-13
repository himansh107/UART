module uart_rx 
  #(parameter CLKS_PER_BIT)
  (
   input        i_Clock,
   input        rx_serial_input,
   output       rx_data_valid,
   output [7:0] rx_output
   );
    
  parameter idle         = 3'b000;
  parameter start_bit = 3'b001;
  parameter data_bit = 3'b010;
  parameter stop_bit  = 3'b011;
  parameter cleanup      = 3'b100;
   
  reg           int_data_buffer = 1'b1;
  reg           int_data   = 1'b1;
   
  reg [7:0]     r_clock_count = 0;
  reg [2:0]     r_bit_index   = 0; //8 bits total
  reg [7:0]     int_data_out     = 0;
  reg           data_valid      = 0;
  reg [2:0]     rx_state     = 0;
   
  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      int_data_buffer <= rx_serial_input;
      int_data   <= int_data_buffer;
    end
   
   
  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin
       
      case (rx_state)
        idle :
          begin
            data_valid      <= 1'b0;
            r_clock_count <= 0;
            r_bit_index   <= 0;
             
            if (int_data == 1'b0)          // Start bit detected
              rx_state <= start_bit;
            else
              rx_state <= idle;
          end
         
        // Check middle of start bit to make sure it's still low
        start_bit :
          begin
            if (r_clock_count == (CLKS_PER_BIT-1)/2)
              begin
                if (int_data == 1'b0)
                  begin
                    r_clock_count <= 0;  // reset counter, found the middle
                    rx_state     <= data_bit;
                  end
                else
                  rx_state <= idle;
              end
            else
              begin
                r_clock_count <= r_clock_count + 1;
                rx_state     <= start_bit;
              end
          end // case: start_bit
         
         
        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        data_bit :
          begin
            if (r_clock_count < CLKS_PER_BIT-1)
              begin
                r_clock_count <= r_clock_count + 1;
                rx_state     <= data_bit;
              end
            else
              begin
                r_clock_count          <= 0;
                int_data_out[r_bit_index] <= int_data;
                 
                // Check if we have received all bits
                if (r_bit_index < 7)
                  begin
                    r_bit_index <= r_bit_index + 1;
                    rx_state   <= data_bit;
                  end
                else
                  begin
                    r_bit_index <= 0;
                    rx_state   <= stop_bit;
                  end
              end
          end // case: data_bit
     
     
        // Receive Stop bit.  Stop bit = 1
        stop_bit :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_clock_count < CLKS_PER_BIT-1)
              begin
                r_clock_count <= r_clock_count + 1;
                rx_state     <= stop_bit;
              end
            else
              begin
                data_valid      <= 1'b1;
                r_clock_count <= 0;
                rx_state     <= cleanup;
              end
          end // case: stop_bit
     
         
        // Stay here 1 clock
        cleanup :
          begin
            rx_state <= idle;
            data_valid  <= 1'b0;
          end
         
         
        default :
          rx_state <= idle;
         
      endcase
    end   
   
  assign rx_data_valid   = data_valid;
  assign rx_output = int_data_out;
   
endmodule // uart_rx