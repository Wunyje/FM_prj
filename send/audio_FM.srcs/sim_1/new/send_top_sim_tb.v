`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/08/11 15:36:37
// Design Name: 
// Module Name: send_top_sim_tb
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


module send_top_sim_tb(

    );
    reg           clk = 0;
    reg           dout = 0;
    reg           rst_n = 0;
    reg  [15:0]   ch1_data = 0;
    reg  [15:0]   ch2_data = 0;
    wire [34:0]   lpf_1;
    wire [34:0]   lpf_2;
    initial
	begin
		forever #5  clk=~clk; // 100MHz
	end
	
	// initial reset
	initial
	begin
	           rst_n=0;
		#10    rst_n=1;
	end
	
	integer i;
    reg signed [15:0] stimulus1[1:33360]; 
    reg signed [15:0] stimulus2[1:97698]; 
    
    always 
    begin
        $readmemh("I:/PractiseProject/_Vivado_projects/audio_FM/audio_FM.srcs/sources_1/new/ch1_3kHz.txt", stimulus1); 
        i = 0;
        // Generating one period data
        repeat(33360) begin  // 333600
            i = i + 1;
            ch1_data = stimulus1[i]; 
            #10;        
        end
    end
    
 	integer j;
    always 
    begin
        $readmemh("I:/PractiseProject/_Vivado_projects/audio_FM/audio_FM.srcs/sources_1/new/ch2_1kHz.txt", stimulus2); 
        j = 0;
        // Generating one period data
        repeat(97698) begin  // 976980
            j = j + 1;
            ch2_data = stimulus2[j]; 
            #10;        
        end
    end
    
    // instantiation
    wire    [39:0]  mix_res;
    wire    [31:0]  fft_imag;
    wire    [31:0]  fft_real;
    wire    [63:0]  re_square = $signed(fft_real)*$signed(fft_real)/32;
    wire    [63:0]  im_square = $signed(fft_imag)*$signed(fft_imag)/32;
    wire    [63:0]  FFT_amp = re_square + im_square;
    wire    [55:0]  hpf_0;
    wire    [57:0]  FDM_out;
    wire    [7:0]   FM_out;
    
    send_top_sim send_top_sim_inst(
        .clk(clk),
        .rst_n(rst_n),
        .ch1_data(ch1_data),
        .ch2_data(ch2_data),
        .lpf_1(lpf_1),
        .lpf_2(lpf_2),
        .hpf_0(hpf_0),
        .mix_res(mix_res),
        .fft_imag(fft_imag),
        .fft_real(fft_real),
        .FDM_out(FDM_out),
        .FM_out(FM_out)
    );
   
//   // save mix data
//    integer dout_file;
//    initial begin
//        dout_file=$fopen("I:/PractiseProject/_Vivado_projects/audio_FM/data.txt","w");    //open created file
//          if(dout_file == 0)begin 
//                    $display ("can not open the file!");    //"can not open the file!"
//                    $stop;
//           end
//    end

//    always @(posedge clk) begin
//         if(mix_res)        
//           $fdisplay(dout_file,"%d",$signed(mix_res));    //保存有符号数据
//    end

//    // save lpf1_out data
//    integer lpf1_out_file;
//    initial begin
//        lpf1_out_file=$fopen("I:/PractiseProject/_Vivado_projects/audio_FM/lpf1_data.txt","w");    //open created file
//          if(lpf1_out_file == 0)begin 
//                    $display ("can not open the file!");    //"can not open the file!"
//                    $stop;
//           end
//    end

//    always @(posedge clk) begin
//         if(lpf_1)        
//           $fdisplay(lpf1_out_file,"%d",$signed(lpf_1));    //保存有符号数据
//    end

//    // save lpf2_out data
//    integer lpf2_out_file;
//    initial begin
//        lpf2_out_file=$fopen("I:/PractiseProject/_Vivado_projects/audio_FM/lpf2_data.txt","w");    //open created file
//          if(lpf2_out_file == 0)begin 
//                    $display ("can not open the file!");    //"can not open the file!"
//                    $stop;
//           end
//    end

//    always @(posedge clk) begin
//         if(lpf_2)        
//           $fdisplay(lpf2_out_file,"%d",$signed(lpf_2));    //保存有符号数据
//    end
endmodule

