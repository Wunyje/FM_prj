`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/11 15:34:09
// Design Name: 
// Module Name: send_top
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


module send_top(
    input            clk,
    input            rst_n,
    input            din,
    input            fd_i,         // First Data
    input            busy_i,
    
    output           rd_o,
    output           convst_o,
    output           rst_o,
    output  [11:0]   da902_out,
    output           da902_clk,
    output           da902_pw
    );

    wire    clk_200k;
    wire    clk_10m;
    clk_div clk_div_inst(
        .clk(clk),
        .rst_n(rst_n),
        .clk_200k(clk_200k),
        .clk_10m(clk_10m)
    );
    
    wire [15:0] ch1_data;
    wire [15:0] ch2_data;
    wire [34:0] lpf_1;
    wire [34:0] lpf_2;
    AD7606_SER AD7606_SER_inst(
    .clk(clk),
    .rst_n(rst_n),
    .din(din),
    .fd_i(fd_i),         // First Data
    .busy_i(busy_i),
    .ch1_data(ch1_data),
    .ch2_data(ch2_data),
    .rd_o(rd_o),
    .convst_o(convst_o),
    .rst_o(rst_o)
    );
    
    LPF_128 LPF_128_1_inst(
    .clk(clk_10m),
    .clk_enable(1),
    .reset(~rst_n),
    .filter_in(ch1_data),
    .filter_out(lpf_1)
    );
    
    LPF_128 LPF_128_2_inst(
    .clk(clk_10m),
    .clk_enable(1),
    .reset(~rst_n),
    .filter_in(ch2_data),
    .filter_out(lpf_2)
    );

    wire [7 : 0] sig_8kHz;
    reg  [23:0]  tdata = 84;
    dds_compiler_0 dds_compiler_0_inst (
      .aclk(clk),                                  // input wire aclk
      .aresetn(rst_n),                            // input wire aresetn
      .s_axis_config_tvalid(1),  // input wire s_axis_config_tvalid
      .s_axis_config_tdata(tdata),    // input wire [23 : 0] s_axis_config_tdata
      .m_axis_data_tvalid(),      // output wire m_axis_data_tvalid
      .m_axis_data_tdata(sig_8kHz)        // output wire [7 : 0] m_axis_data_tdata
    );
    
    wire            cmpy_a_ready;
    wire            cmpy_b_ready;
    wire            cmpy_valid; 
    wire    [39:0]  mix_res;
    cmpy_0 cmpy_0_inst (
      .aclk(clk_200k),                              // input wire aclk
      .aresetn(rst_n),                        // input wire aresetn
      .s_axis_a_tvalid(1),        // input wire s_axis_a_tvalid
      .s_axis_a_tready(cmpy_a_ready),        // output wire s_axis_a_tready
      .s_axis_a_tdata({{45{1'b0}},lpf_2}),          // input wire [79 : 0] s_axis_a_tdata
      .s_axis_b_tvalid(1),        // input wire s_axis_b_tvalid
      .s_axis_b_tready(cmpy_b_ready),        // output wire s_axis_b_tready
      .s_axis_b_tdata({{8{1'b0}},sig_8kHz}),          // input wire [15 : 0] s_axis_b_tdata
      .m_axis_dout_tvalid(cmpy_valid),  // output wire m_axis_dout_tvalid
      .m_axis_dout_tready(1),//xfft_ready),  // input wire m_axis_dout_tready
      .m_axis_dout_tdata(mix_res)    // output wire [79 : 0] m_axis_dout_tdata
    );
    
    wire    [56:0]   hpf_0;
    HPF_256 HPF_256_0_inst(
        .clk(clk_10m),
        .clk_enable(1),
        .reset(~rst_n),
        .filter_in(mix_res),       // [39:0]
        .filter_out(hpf_0)         // [56:0]
    );
    
    wire [57:0] FDM_out;
    wire [45:0] lpf_1_amp = lpf_1*11'd2000;
    c_addsub_0 FDM_adder (
      .A(lpf_1_amp),      // input wire [45 : 0] A
      .B(hpf_0),      // input wire [56 : 0] B
      .CLK(clk),  // input wire CLK
      .S(FDM_out)      // output wire [57 : 0] S
    );
    

    wire [79:0] div_gen_out;
    wire [63:0] div_out = div_gen_out[63:0];
    wire [12:0] FDM_scaled_out = div_gen_out[15:3]; // get fraction part
    div_gen_0 FDM_scaler (
      .aclk(clk),                                      // input wire aclk
      .aresetn(rst_n),                                // input wire aresetn
      .s_axis_divisor_tvalid(1),    // input wire s_axis_divisor_tvalid
      .s_axis_divisor_tdata({{3{1'b0}},44'd8790000000000}),      // input wire [47 : 0] s_axis_divisor_tdata
      .s_axis_dividend_tvalid(1),  // input wire s_axis_dividend_tvalid
      .s_axis_dividend_tdata({{6{FDM_out[57]}},FDM_out}),    // input wire [63 : 0] s_axis_dividend_tdata
      .m_axis_dout_tdata(div_gen_out)            // output wire [79 : 0] m_axis_dout_tdata
    );

    wire [15:0] offset;
    c_addsub_1 offset_adder (
      .A(FDM_scaled_out),      // input wire [12 : 0] A
      .CLK(clk),  // input wire CLK
      .S(offset)      // output wire [15 : 0] S
    );
    
    wire [7 : 0] FM_out;
    dds_compiler_1 FM_dds (
      .aclk(clk),                                  // input wire aclk
      .s_axis_config_tvalid(1),  // input wire s_axis_config_tvalid
      .s_axis_config_tdata(offset),    // input wire [15 : 0] s_axis_config_tdata
      .m_axis_data_tdata(FM_out)        // output wire [7 : 0] m_axis_data_tdata
    );
    
    wire            clk_o;
    wire    [11:0]  da902_data = {FM_out,{4{1'b0}}};
    DAC902_drive DAC902_drive_inst(
        .clk(clk),
        .rst_n(rst_n),
        .sign_config(1),
        .da902_data(da902_data),
        .da902_clk(clk_o),
        .da902_pw(da902_pw),
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
    
//    ila_0 ila_0_inst (
//        .clk(clk), // input wire clk
//        .probe0(ch1_data), // input wire [15:0]  probe0  
//        .probe1(ch2_data) // input wire [15:0]  probe1 
//    );
    
endmodule
