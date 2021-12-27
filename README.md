# 项目特点

本项目基于EGO1开发板，使用verilog硬件描述语言在vivado集成设计环境学习FPGA开发流程。实现了通过拨码开关输入二进制信号，通过板上VGA接口连接显示器，使显示器显示二进制信号对应ASCII码的数字、字母以及特殊符号。

# 设计及实现

## 设计思路

要在VGA显示屏上显示内容，实质上是给显示屏的不同位置像素改变其RGB属性。因此需要知道设计一套字典，方便查询每个字母对应的像素位置。这里我们设计一个字母或者符号占8*7个像素（8行7列）。将其中应该有显示的像素标记为1，没有显示的像素标记为0。之后根据每个像素为1或为0来分别改变其RGB属性。

通过一个寄存器来存储拨码开关的输入，再根据该寄存器在字典中查找具体的像素赋值情况。再根据显示屏刷新时刷到的每个像素的值改变其RGB属性。

需注意显示屏并非一直显示信息，其中有部分时间用来发送行同步和场同步信息，但因为时间过短，人类的眼睛无法辨认因此看起来像是显示屏一直在显示。在具体代码中要实现相关行同步和场同步信号的产生与发送。

## 代码实现

### 字典示例

符号“*”的字典：

```c
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
```

### 接收拨码开关输入及查询字典相应信息

字典过长，只展示部分

其中s为开关的输入信号

```c
input wire [5:0] s;  
reg [5:0] data;  
  
always @(posedge clk or negedge rst_n)  
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
  
                ...  
  
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
```

### 定义x计数器和y计数器用于产生基本的行和场时序

```c
reg[10:0] x_cnt;    // x 计数器，计数范围 0-1039，主要用于控制产生行时序  
reg[9:0] y_cnt; // y 计数器，计数范围 0-665，主要用于控制产生场时序  
  
always @ (posedge clk or negedge rst_n)  
    if(!rst_n) x_cnt <= 11'd0;  
    else if(x_cnt == 11'd1039) x_cnt <= 11'd0;  
    else x_cnt <= x_cnt+1'b1;  
  
always @ (posedge clk or negedge rst_n)  
    if(!rst_n) y_cnt <= 10'd0;  
    else if(y_cnt == 10'd665) y_cnt <= 10'd0;  
    else if(x_cnt == 11'd1039) y_cnt <= y_cnt+1'b1;
```

### 设计行同步信号与场同步信号

```c
// 行同步和场同步信号的产生，行同步信号是 x 计数器的第 0-119 个脉冲，而场  
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
```

### 根据字典查找到的字形着色

```c
always @(posedge clk/* or negedge rst_n */)  
begin  
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
```

# 结果展示

![result](https://github.com/GLORYFeonix/VGA_Display/blob/3887432acce86e7878c71fb08f26d3e38a943038/vga_display.gif)