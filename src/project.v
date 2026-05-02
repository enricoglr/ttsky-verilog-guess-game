/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_enrico_glr (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.
  //assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  //assign uio_out = 0;
  //assign uio_oe  = 0;

  assign uio_out[6:0] = 7'b000_0000;
  assign uio_oe  = 8'b1000_0000;
  
game my_game (
    .clki_i        (clk),
    .rst_i         (~rst_n),           
    .init_game_i   (ui_in[4]),
    .guess_valid_i (ui_in[5]),
    .guess_i       (ui_in[3:0]),
    .secret_i      (uio_in[3:0]),
    
    .busy_o        (uo_out[6]),
    .valid_o       (uo_out[7]),
    .correct_o     (uo_out[2:0]),
    .wrong_o       (uo_out[5:3]),
    .win_o         (uio_out[7])
);
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in[7:6], uio_in[7:4], 1'b0};

endmodule
