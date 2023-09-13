module uart_tx 
  #(parameter CLKS_PER_BIT)
  (
   input       i_Clock,
   input       tx_data_valid,
   input [7:0] in, 
   output      tx_active,
   output reg  tx_serial_data,
   output      tx_done
   );
  
  parameter idle         = 3'b000;
  parameter start_bit = 3'b001;
  parameter data_bit = 3'b010;
  parameter stop_bit  = 3'b011;
  parameter cleanup      = 3'b100;
   
  reg [2:0]    tx_state     = 0;
  reg [7:0]    t_clock_count = 0;
  reg [2:0]    t_bit_index   = 0;
  reg [7:0]    data     = 0;
  reg          int_done     = 0;
  reg          int_active   = 0;
     
  always @(posedge i_Clock)
    begin
       
      case (tx_state)
        idle :
          begin
            tx_serial_data   <= 1'b1;         // Drive Line High for Idle
            int_done     <= 1'b0;
            t_clock_count <= 0;
            t_bit_index   <= 0;
             
            if (tx_data_valid == 1'b1)
              begin
                int_active <= 1'b1;
                data   <= in;
                tx_state   <= start_bit;
              end
            else
              tx_state <= idle;
          end // case: idle
         
         
        // Send out Start Bit. Start bit = 0
        start_bit :
          begin
            tx_serial_data <= 1'b0;
             
            // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            if (t_clock_count < CLKS_PER_BIT-1)
              begin
                t_clock_count <= t_clock_count + 1;
                tx_state     <= start_bit;
              end
            else
              begin
                t_clock_count <= 0;
                tx_state     <= data_bit;
              end
          end // case: start_bit
         
         
        // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
        data_bit :
          begin
            tx_serial_data <= data[t_bit_index];
             
            if (t_clock_count < CLKS_PER_BIT-1)
              begin
                t_clock_count <= t_clock_count + 1;
                tx_state     <= data_bit;
              end
            else
              begin
                t_clock_count <= 0;
                 
                // Check if we have sent out all bits
                if (t_bit_index < 7)
                  begin
                    t_bit_index <= t_bit_index + 1;
                    tx_state   <= data_bit;
                  end
                else
                  begin
                    t_bit_index <= 0;
                    tx_state   <= stop_bit;
                  end
              end
          end // case: data_bit
         
         
        // Send out Stop bit.  Stop bit = 1
        stop_bit :
          begin
            tx_serial_data <= 1'b1;
             
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (t_clock_count < CLKS_PER_BIT-1)
              begin
                t_clock_count <= t_clock_count + 1;
                tx_state     <= stop_bit;
              end
            else
              begin
                int_done     <= 1'b1;
                t_clock_count <= 0;
                tx_state     <= cleanup;
                int_active   <= 1'b0;
              end
          end // case: stop_bit
         
         
        // Stay here 1 clock
        cleanup :
          begin
            int_done <= 1'b1;
            tx_state <= idle;
          end
         
         
        default :
          tx_state <= idle;
         
      endcase
    end
 

  assign tx_active = int_active;
  assign tx_done   = int_done;
   
endmodule