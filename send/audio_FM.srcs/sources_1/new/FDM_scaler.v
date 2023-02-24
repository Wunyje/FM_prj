`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/08 15:47:33
// Design Name: 
// Module Name: FDM_scaler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FDM_scaler(
    input               clk,
    input               rst_n,
    input      [57:0]   FDM_sig,
    output reg [12:0]   FDM_scaled
    );
    
    wire        [79:0] div_gen_out;
    wire signed [63:0] div_out = div_gen_out[63:0];
    wire        [12:0] FDM_scaled_out = div_gen_out[15:3]; // get fraction part
    div_gen_0 FDM_scaler (
      .aclk(clk),                                      // input wire aclk
      .aresetn(rst_n),                                // input wire aresetn
      .s_axis_divisor_tvalid(1),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata({{3{0}},44'd8790000000000}),      // input wire [47 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(1),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata({{6{FDM_sig[57]}},FDM_sig}),    // input wire [63 : 0] s_axis_dividend_tdata
      .m_axis_dout_tdata(div_gen_out)            // output wire [79 : 0] m_axis_dout_tdata
    );
    
endmodule
