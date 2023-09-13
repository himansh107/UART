module uart_top (
  input         i_Clock,
  input         tx_data_valid,
  input  [7:0]  in,
  output        tx_active,
  output        tx_serial_data,
  output        tx_done,
  output        rx_data_valid,
  output [7:0]  rx_output
);

  // Set CLKS_PER_BIT according to your requirements
  parameter CLKS_PER_BIT = 87;

  wire tx_done_internal;
  wire tx_data_internal;
  wire connection; 
  
  
  uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_inst (
    .i_Clock(i_Clock),
    .tx_data_valid(tx_data_valid),
    .in(in),
    .tx_active(tx_data_internal),
    .tx_serial_data(connection),
    .tx_done(tx_done_internal)
  );

  uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_inst (
    .i_Clock(i_Clock),
    .rx_serial_input(connection),
    .rx_data_valid(rx_data_valid),
    .rx_output(rx_output)
  );

  // Connect internal signals to external ports
  
  assign tx_serial_data = connection;
  assign tx_done = tx_done_internal;
  assign tx_active = tx_data_internal;

endmodule