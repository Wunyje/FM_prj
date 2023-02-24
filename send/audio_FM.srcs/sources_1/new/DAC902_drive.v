`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/08 18:49:00
// Design Name: 
// Module Name: DAC902_drive
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


module DAC902_drive(
    input               clk,
    input               rst_n,
    input       [11:0]  da902_data,
    input               sign_config,
    output              da902_clk,
    output              da902_pw,
    output  reg [11:0]  da902_out
    );
    
    assign          da902_pw = 0;
    assign          da902_clk = clk;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            da902_out <= 0;
        else if(sign_config)
            da902_out <= da902_data + 12'd2048;
        else    
            da902_out <= da902_data;
    end
endmodule
