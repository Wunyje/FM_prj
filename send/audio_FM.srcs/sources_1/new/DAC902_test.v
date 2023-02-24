`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/08 20:10:01
// Design Name: 
// Module Name: DAC902_test
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


module DAC902_test(
    input               clk,
    input               rst_n,
    output              da902_clk,
    output      [11:0]  da902_out,
    output              da902_pw
    );  
    wire  [15:0]   da902_ddsout;
    wire           clk_165m;
  dac902_clk dac902_clk_inst
   (
    // Clock out ports
    .clk_out1(clk_165m),     // output clk_out1
    // Status and control signals
    .resetn(rst_n), // input resetn
   // Clock in ports
    .clk_in1(clk));      // input clk_in1
    
    dac902_dds dac902_dds_inst (
      .aclk(clk_165m),                                  // input wire aclk
      .aresetn(rst_n),
      .s_axis_config_tvalid(1),  // input wire s_axis_config_tvalid
      .s_axis_config_tdata(16'd794),    // input wire [15 : 0] s_axis_config_tdata 1311/100MHz
      .m_axis_data_tdata(da902_ddsout)        // output wire [15 : 0] m_axis_data_tdata
    );

    wire clk_o;
    DAC902_drive DAC902_drive_inst(
        .clk(clk_165m),
        .rst_n(rst_n),
        .sign_config(1),
        .da902_data(da902_ddsout[11:0]),
        .da902_pw(da902_pw),
        .da902_clk(clk_o),
        .da902_out(da902_out)
    );
    
     
     ODDR2 #(
        .DDR_ALIGNMENT("NONE"), //Sets output alignment to "NONE", "C0" or "C1"
        .INIT(1'b0),    //Sets initial state of the Q output to 1'b0 or 1'b1
        .SRTYPE("SYNC") // Specifies"SYNC" or "ASYNC" set/reset
    )
    U_ODDR2_PLL(
      .Q(da902_clk),   // 1-bit DDR output data
      .C0(clk_o),   // 1-bit clock input
      .C1(~clk_o),   // 1-bit clock input
      .CE(1'b1), //1-bit clock enable input
      .D0(1'b1), //1-bit data input (associated with C0)
      .D1(1'b0), //1-bit data input (associated with C1)
      .R(1'b0),   //1-bit reset input
      .S(1'b0)    //1-bit set input
    );
endmodule
