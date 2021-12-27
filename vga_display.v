module vga_dis(
			clk,rst_n,
			hsync,vsync,
			vga_r,vga_g,vga_b,
			s
		);
input clk;	
input rst_n;	
input wire [5:0] s;
output reg hsync;	
output reg vsync;	
output vga_r;
output vga_g;
output vga_b;

//-------------------------------------
// 1) x 和 y 计数器，用于产生基本的行和场时序
reg[10:0] x_cnt;	// 2) x 计数器，计数范围 0-1039，主要用于控制产生行时序
reg[9:0] y_cnt;	    // 3) y 计数器，计数范围 0-665，主要用于控制产生场时序

always @ (posedge clk or negedge rst_n)
	if(!rst_n) x_cnt <= 11'd0;
	else if(x_cnt == 11'd1039) x_cnt <= 11'd0;
	else x_cnt <= x_cnt+1'b1;

always @ (posedge clk or negedge rst_n)
	if(!rst_n) y_cnt <= 10'd0;
	else if(y_cnt == 10'd665) y_cnt <= 10'd0;
	else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;

//-------------------------------------
// 4)产生有效显示区域坐标范围的标志信号 valid、行有效显示坐标计数（ 0-799）器
//   xpos、场有效显示坐标计数（ 0-599）器 ypos

// 5) 查对表 6.3，可以知道行有效显示是从第 120+67 个脉冲后开始连续 800 个脉冲，
//    场有效显示是从第 6+25 个脉冲后开始连续 600 个脉冲，这里的 valid 信号便是
//    由此产生
wire valid = (x_cnt >= 11'd187) && (x_cnt < 11'd987) 
					&& (y_cnt >= 10'd31) && (y_cnt < 10'd631); 	// 

wire[9:0] xpos = x_cnt-11'd187;   // 6) 查对表 6.3，行有效坐标的计算点是第 120+67 个脉冲
wire[9:0] ypos = y_cnt-10'd31;    // 7) 查对表 6.3，场有效坐标的计算点是第 6+25 个脉冲

//-------------------------------------
// 8) 行同步和场同步信号的产生，行同步信号是 x 计数器的第 0-119 个脉冲，而场
//  同步信号则是 y 计数器的第 0-5 个脉冲。在同步脉冲器件，行同步和场同步信
//  号值被拉低
always @ (posedge clk or negedge rst_n)
	if(!rst_n) hsync <= 1'b1;
	else if(x_cnt == 11'd0) hsync <= 1'b0;	
	else if(x_cnt == 11'd120) hsync <= 1'b1;
 
always @ (posedge clk or negedge rst_n)
	if(!rst_n) vsync <= 1'b1;
	else if(y_cnt == 10'd0) vsync <= 1'b0;	
	else if(y_cnt == 10'd6) vsync <= 1'b1;

reg [5:0] data;

reg [7:0] col0;
reg [7:0] col1;
reg [7:0] col2;
reg [7:0] col3;
reg [7:0] col4;
reg [7:0] col5;
reg [7:0] col6;

reg c0;
reg c1;
reg c2;
reg c3;
reg c4;
reg c5;
reg c6;
reg c;

always @(posedge clk/* or negedge rst_n */)
begin
    data = s;
    if (!rst_n)
        begin
            col0 <= 8'b0000_0000;
            col1 <= 8'b0000_0000;
            col2 <= 8'b0000_0000;
            col3 <= 8'b0000_0000;
            col4 <= 8'b0000_0000;
            col5 <= 8'b0000_0000;
            col6 <= 8'b0000_0000;
        end
    else
        begin
            case (data)
                6'b00_0000: // "0"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0101_0001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_0101;
                        col5 <= 8'b0011_1110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0001: // "1"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0000;;
                        col2 <= 8'b0100_0010;
                        col3 <= 8'b0111_1111;
                        col4 <= 8'b0100_0000;
                        col5 <= 8'b0000_0000;;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0010: // "2"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0100_0010;
                        col2 <= 8'b0110_0001;
                        col3 <= 8'b0101_0001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0100_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0011: // "3"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0010;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0100: // "4"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0001_1000;
                        col2 <= 8'b0001_0100;
                        col3 <= 8'b0001_0010;
                        col4 <= 8'b0111_1111;
                        col5 <= 8'b0001_0000;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0101: // "5"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0111;
                        col2 <= 8'b0100_0101;
                        col3 <= 8'b0100_0101;
                        col4 <= 8'b0100_0101;
                        col5 <= 8'b0011_1001;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0110: // "6"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_0010;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_0111: // "7"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0110_0001;
                        col2 <= 8'b0001_0001;
                        col3 <= 8'b0000_1001;
                        col4 <= 8'b0000_0101;
                        col5 <= 8'b0000_0011;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1000: // "8"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_0110;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1001: // "9"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0110;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_1110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1010: // "A"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1100;
                        col2 <= 8'b0001_0010;
                        col3 <= 8'b0001_0001;
                        col4 <= 8'b0001_0010;
                        col5 <= 8'b0111_1100;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1011: // "B"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1100: // "C"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_0001;
                        col4 <= 8'b0100_0001;
                        col5 <= 8'b0010_0010;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1101: // "D"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_0001;
                        col4 <= 8'b0100_0001;
                        col5 <= 8'b0011_1110;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1110: // "E"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0100_0001;
                        col6 <= 8'b0000_0000;
                    end
                6'b00_1111: // "F"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_1001;
                        col3 <= 8'b0000_1001;
                        col4 <= 8'b0000_1001;
                        col5 <= 8'b0000_0001;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0000: // "G"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_1010;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0001: // "H"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_1000;
                        col3 <= 8'b0000_1000;
                        col4 <= 8'b0000_1000;
                        col5 <= 8'b0111_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0010: // "I"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0000;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0111_1111;
                        col4 <= 8'b0100_0001;
                        col5 <= 8'b0000_0000;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0011: // "J"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0000;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_0001;
                        col4 <= 8'b0011_1111;
                        col5 <= 8'b0000_0001;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0100: // "K"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_1000;
                        col3 <= 8'b0001_0100;
                        col4 <= 8'b0010_0010;
                        col5 <= 8'b0100_0001;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0101: // "L"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0100_0000;
                        col3 <= 8'b0100_0000;
                        col4 <= 8'b0100_0000;
                        col5 <= 8'b0100_0000;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0110: // "M"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_0010;
                        col3 <= 8'b0000_1100;
                        col4 <= 8'b0000_0010;
                        col5 <= 8'b0111_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_0111: // "N"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_0010;
                        col3 <= 8'b0000_0100;
                        col4 <= 8'b0000_1000;
                        col5 <= 8'b0111_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1000: // "O"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0100_0001;
                        col4 <= 8'b0100_0001;
                        col5 <= 8'b0011_1110;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1001: // "P"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_1001;
                        col3 <= 8'b0000_1001;
                        col4 <= 8'b0000_1001;
                        col5 <= 8'b0000_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1010: // "Q"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1110;
                        col2 <= 8'b0100_0001;
                        col3 <= 8'b0101_0001;
                        col4 <= 8'b0110_0001;
                        col5 <= 8'b0111_1110;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1011: // "R"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0111_1111;
                        col2 <= 8'b0000_1001;
                        col3 <= 8'b0001_1001;
                        col4 <= 8'b0010_1001;
                        col5 <= 8'b0100_0110;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1100: // "S"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0110;
                        col2 <= 8'b0100_1001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_1001;
                        col5 <= 8'b0011_0010;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1101: // "T"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0001;
                        col2 <= 8'b0000_0001;
                        col3 <= 8'b0111_1111;
                        col4 <= 8'b0000_0001;
                        col5 <= 8'b0000_0001;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1110: // "U"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1111;
                        col2 <= 8'b0100_0000;
                        col3 <= 8'b0100_0000;
                        col4 <= 8'b0100_0000;
                        col5 <= 8'b0011_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b01_1111: // "V"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0001_1111;
                        col2 <= 8'b0010_0000;
                        col3 <= 8'b0100_0000;
                        col4 <= 8'b0010_0000;
                        col5 <= 8'b0001_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b10_0000: // "W"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0011_1111;
                        col2 <= 8'b0100_0000;
                        col3 <= 8'b0011_0000;
                        col4 <= 8'b0100_0000;
                        col5 <= 8'b0011_1111;
                        col6 <= 8'b0000_0000;
                    end
                6'b10_0001: // "X"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0110_0011;
                        col2 <= 8'b0001_0100;
                        col3 <= 8'b0000_1000;
                        col4 <= 8'b0001_0100;
                        col5 <= 8'b0110_0011;
                        col6 <= 8'b0000_0000;
                    end
                6'b10_0010: // "Y"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0011;
                        col2 <= 8'b0000_0100;
                        col3 <= 8'b0111_1000;
                        col4 <= 8'b0000_0100;
                        col5 <= 8'b0000_0011;
                        col6 <= 8'b0000_0000;
                    end
                6'b10_0011: // "Z"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0110_0001;
                        col2 <= 8'b0101_0001;
                        col3 <= 8'b0100_1001;
                        col4 <= 8'b0100_0101;
                        col5 <= 8'b0100_0011;
                        col6 <= 8'b0000_0000;
                    end
                6'b11_1110: // " "
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0000;
                        col2 <= 8'b0000_0000;
                        col3 <= 8'b0000_0000;
                        col4 <= 8'b0000_0000;
                        col5 <= 8'b0000_0000;
                        col6 <= 8'b0000_0000;
                    end
                6'b11_1111: // ":"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0000_0000;
                        col2 <= 8'b0011_0110;
                        col3 <= 8'b0011_0110;
                        col4 <= 8'b0000_0000;
                        col5 <= 8'b0000_0000;
                        col6 <= 8'b0000_0000;
                    end
                default: // "*"
                    begin
                        col0 <= 8'b0000_0000;
                        col1 <= 8'b0010_0010;
                        col2 <= 8'b0001_0100;
                        col3 <= 8'b0000_1000;
                        col4 <= 8'b0001_0100;
                        col5 <= 8'b0010_0010;
                        col6 <= 8'b0000_0000;
                    end
            endcase
        end

    c=0;
    if ((ypos>=300)&&(ypos<=306)) 
        begin
            c0<=(col0[ypos-300])&&(xpos==200);
            c1<=(col1[ypos-300])&&(xpos==201);
            c2<=(col2[ypos-300])&&(xpos==202);
            c3<=(col3[ypos-300])&&(xpos==203);
            c4<=(col4[ypos-300])&&(xpos==204);
            c5<=(col5[ypos-300])&&(xpos==205);
            c6<=(col6[ypos-300])&&(xpos==206);
            c=c0|c1|c2|c3|c4|c5|c6;
        end

end
assign vga_r=c?1:0;
assign vga_g=0;
assign vga_b=1;
		

endmodule