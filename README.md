# UART
Universal Asynchronous Receiver Transmitter. UART has a term 'asynchronous' because the receiver (rx) and transmitter (tx) can work at different clock speeds. The data transfer is governed by Baud rate. The unit of Baud rate is bits/sec and it represents the speed at which we are transferring bits from the tx to rx. The synchronization between tx and rx is done through a common baud rate. </p>
This project was made using Verilog, synthesized using Xilinx Vivado.

* The uart_tx file contains the code for the transmitter module
* uart_rx is for the receiver module
* uart_top is the top-level module file specifying connections between input, transmitter, receiver, and output data. 
* uart_tb is the testbench specifying input data to test the proper functioning of UART.<br><br>

The gate level netlist of the UART is shown below: <br>
![](uart_gate_level_netlist.png) <br>
The internal netlist for the receiver module: <br><br>
![](tx_netlist.png) <br> <br>
The internal netlist for the transmitter module: <br><br>
![](rx_netlist.png) <br> <br>
