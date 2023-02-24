`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/06 14:35:54
// Design Name: 
// Module Name: clk_div
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


module clk_div(
    input            clk,
    input            rst_n,
    output reg       clk_1m = 0,
    output reg       clk_200k = 0,
    output reg       clk_10m = 0,
    output reg       clk_50m = 0
    );
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            clk_50m <= 0;
        else 
            clk_50m <= ~clk_50m;
    end

    reg [2:0] clk_10m_cnt = 0;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            clk_10m_cnt <= 0;
            clk_10m <= 0;
        end
        else if(clk_10m_cnt == 4) begin
            clk_10m <= ~clk_10m;
            clk_10m_cnt <= 0;
        end
        else
            clk_10m_cnt <= clk_10m_cnt + 1;
    end
    
    reg [2:0] clk_1m_cnt = 0;
    always@(posedge clk_10m, negedge rst_n) begin
        if(!rst_n) begin
            clk_1m <= 0;
            clk_1m_cnt = 0;
        end
        else if(clk_1m_cnt == 4) begin
            clk_1m <= ~clk_1m;
            clk_1m_cnt <= 0;
        end
        else
            clk_1m_cnt <= clk_1m_cnt + 1;
    end
    
    reg [5:0] clk_200k_cnt = 0;
    always@(posedge clk_10m, negedge rst_n) begin
        if(!rst_n) begin
            clk_200k <= 0;
            clk_200k_cnt <= 0;
        end
        else if(clk_200k_cnt == 24) begin
            clk_200k <= ~clk_200k;
            clk_200k_cnt <= 0;
        end
        else
            clk_200k_cnt <= clk_200k_cnt + 1;
    end
endmodule
