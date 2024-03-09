module top_soc(
    // 系统时钟（50MHz）与复位信号
    input sysclk,
    input rst_n,
    // 调试接口
    input swclk,
    inout swdio,
    // 硬件工作指示灯
    output reg led_1s
);

//------------------------------------------------------------------------------
// PLL模块例化
//------------------------------------------------------------------------------
pll pll_u0(
	.refclk(sysclk),
	.reset(~rst_n),
	.clk0_out(soc_clk)
);

//------------------------------------------------------------------------------
// SoC例化
//------------------------------------------------------------------------------
soc_cm0 soc_cm0_u0(
    // 时钟和复位
    .sysclk(soc_clk),
    .rst_n(rst_n),
    // 调试接口
    .swclk(swclk),
    .swdio(swdio)
);

//------------------------------------------------------------------------------
// LED每秒闪动一次的逻辑
//------------------------------------------------------------------------------
reg [31:0] cnt1;
always @(posedge sysclk or negedge rst_n) begin
    if (~rst_n) begin 
        led_1s<=0;
	cnt1<=0;
    end
    else if (cnt1==32'd50000000-1) begin 	
        cnt1<=0;
        led_1s<=~led_1s;	
    end	
    else begin 
        cnt1<=cnt1+1'b1;
    end	
end

endmodule
