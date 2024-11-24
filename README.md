# Enhanced UART-Controlled Stopwatch

An FPGA Project from "FPGA Prototyping by Verilog Examples" by Pong P. Chu.

## Overview

This project implements a digital stopwatch with enhanced functionality, designed using Verilog HDL and deployed on an FPGA. The system is capable of bidirectional counting, pause/resume, reset, and real-time communication with a PC terminal via UART.

### Key Features:
1. Time Format: HH:MM:SS.ms
2. Commands: Go, pause, reset, count direction (up/down), and state retrieval.
3. Display: Time displayed on an 8-digit 7-segment display.
4. UART Communication: Interaction with the stopwatch through PC terminal.


### System Components:
#### UART Core:
1. Receiver (uart_rx.v): Receives data using start, data and stop bits.
2. Transmitter (uart_tx.v): Serially transmits data using start, data, and stop bits.
3. FIFO Buffer (fifo.v): Temporarily stores data for reliable UART operation.
4. Baud Generator (baud_generator.v): Provides clock ticks for UART modules.

#### Enhanced Stopwatch Logic:
1. Counts in increments of 0.1 seconds.
2. Handles overflow/underflow for HH:MM:SS.ms format.
3. Receives ASCII commands from the PC for operation - g/G for go, p/P for pause, c/C for clear, u/U for changing direction, r/R for transmission of stopwatch state back to the PC terminal.
4. LED Multiplexer (LED_mux.v): Drives the 8-digit 7-segment display using persistence of vision.

#### Top Module:
(uart_stopwatch.v): Integrates all submodules, processes UART commands, and controls stopwatch operations.



### Design and Implementation

1. FPGA Board: Nexys A7
2. System Clock: 100 MHz
3. Development Tools: Vivado Design Suite
4. Terminal Application: Tera Term (configured for 19200 baud rate, 8 data bits, no parity, 1 stop bit, no flow control).


