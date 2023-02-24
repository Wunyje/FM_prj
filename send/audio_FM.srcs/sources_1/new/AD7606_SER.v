`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/01 18:34:52
// Design Name: 
// Module Name: AD7606_SER
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


module AD7606_SER(
    input               clk,          // must be 100MHz
    input               rst_n,
    input               din,
    input               fd_i,         // First Data
    input               busy_i,
    
    output  reg[15:0]   ch1_data = 0,
    output  reg[15:0]   ch2_data = 0,   
    output  reg[15:0]   ch3_data = 0,
    output  reg[15:0]   ch4_data = 0,  
    output  reg[15:0]   ch5_data = 0,
    output  reg[15:0]   ch6_data = 0,  
    output  reg[15:0]   ch7_data = 0,
    output  reg[15:0]   ch8_data = 0,  
    output              cs_o,
    output              rd_o,
    output  reg         convst_o = 1,
    output              fd_o,
    output              rst_o
    );
    parameter   S_IDLE         = 0;
    parameter   S_START_CONV   = 1;
    parameter   S_WAIT_TO_READ = 2;
    parameter   S_WAIT_FD      = 3;
    parameter   S_READ         = 4;
    parameter   S_WAIT_TO_NEXT = 5;
    reg [2:0]   state_n = 0;
    reg [2:0]   state_c = 0;
    
    // first data output
    assign  fd_o = fd_i;
    
    // rst_n to AD7607's reset
    assign  rst_o = ~rst_n;
    
    // generate 35MHz SCL
    wire clk_35m;
//    wire ;
    clk_wiz_0 clk_wiz_0_inst
   (
    .clk_out1(clk_35m),     // output clk_out1
//    .clk_out2(clk),
    .clk_in1(clk)           // input clk_in1
    );      
    assign rd_o = (state_c == S_READ)?clk_35m:1;
    
    // read data
    reg [4:0]   bit_cnt = 0;
    reg [15:0]  data_reg = 0;
    always@(negedge clk_35m, negedge rst_n) begin
        if(!rst_n) begin
            bit_cnt <= 0;
        end
        else if(state_c == S_READ) begin
            if(bit_cnt == 16) begin
                bit_cnt <= 0;
            end
            else begin
                data_reg[0] <= din;
                data_reg[1] <= data_reg[0];
                data_reg[2] <= data_reg[1];
                data_reg[3] <= data_reg[2];
                data_reg[4] <= data_reg[3];
                data_reg[5] <= data_reg[4];
                data_reg[6] <= data_reg[5];
                data_reg[7] <= data_reg[6];
                data_reg[8] <= data_reg[7];
                data_reg[9] <= data_reg[8];
                data_reg[10] <= data_reg[9];
                data_reg[11] <= data_reg[10];
                data_reg[12] <= data_reg[11];
                data_reg[13] <= data_reg[12];
                data_reg[14] <= data_reg[13];
                data_reg[15] <= data_reg[14];
                bit_cnt <= bit_cnt + 1;
            end 
        end
        else
            bit_cnt <= 0;
    end
    reg [3:0]   ch_cnt = 0;  
    always@(negedge clk_35m, negedge rst_n) begin
        if(!rst_n) begin
            ch_cnt   <= 0;
            ch1_data <= 0;
            ch2_data <= 0;
            ch3_data <= 0;
            ch4_data <= 0;
            ch5_data <= 0;
            ch6_data <= 0;
            ch7_data <= 0;
            ch8_data <= 0;
        end
        else if(state_c == S_READ) begin 
            if(ch_cnt == 0 && bit_cnt == 16) begin
                ch1_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 1 && bit_cnt == 16) begin
                ch2_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 2 && bit_cnt == 16) begin
                ch3_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 3 && bit_cnt == 16) begin
                ch4_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 4 && bit_cnt == 16) begin
                ch5_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 5 && bit_cnt == 16) begin
                ch6_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 6 && bit_cnt == 16) begin
                ch7_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
            else if(ch_cnt == 7 && bit_cnt == 16) begin
                ch8_data <= data_reg;
                ch_cnt <= ch_cnt + 1;
            end
        end
		else
		    ch_cnt <= 0;
    end
    
    // start data coversion
    always@(posedge clk, negedge rst_n ) begin
        if(!rst_n)
            convst_o = 1;
        else if(state_n == S_START_CONV)
            convst_o = 0;
        else
            convst_o = 1;
    end
    
    // extend the length of CONV
    reg [1:0] conv_cnt = 2'd0;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            conv_cnt   <= 2'd0;
        end
        else if(state_n == S_START_CONV) begin
            if(conv_cnt == 2'd3)
                conv_cnt   <= 0;
            else
                conv_cnt   <= conv_cnt + 1;
        end
        else
            conv_cnt   <= 2'd0;
    end
    
    // CS signal
    assign cs_o = (state_c == S_WAIT_FD || state_c == S_READ)?0:1;
    
    // state conversion
    always@(*) begin
        if(!rst_n)
            state_n = S_IDLE;
        else begin
            case(state_c)
                S_IDLE:begin
                   state_n =  S_START_CONV;
                end
                S_START_CONV:begin
                    if(conv_cnt == 2'd3)
                        state_n =  S_WAIT_TO_READ;
                    else begin
                        state_n = state_c;
                    end 
                end
                S_WAIT_TO_READ:begin
                    if(busy_i)
                        state_n =  S_WAIT_FD;
                    else
                        state_n =  state_c;    
                end
                S_WAIT_FD:begin
                    if(fd_i)
                        state_n =  S_READ;
                    else
                        state_n =  state_c;
                end
                S_READ:begin
                    if(ch_cnt == 8)
                        state_n =  S_WAIT_TO_NEXT;
                    else
                        state_n =  S_READ;
                end
                S_WAIT_TO_NEXT:begin                // wait for the negedge of busy_i
                    if(!busy_i)
                        state_n = S_IDLE;
                    else
                        state_n = state_c;
                end
                default:
                        state_n = S_IDLE;
            endcase
        end
    end
    
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n)
            state_c <= S_IDLE;
        else
            state_c <= state_n;
    end
    

endmodule

