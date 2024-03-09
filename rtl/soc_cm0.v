module soc_cm0(
    // 时钟和复位
    input sysclk,
    input rst_n,
    // 调试接口
    input swclk,
    inout swdio
  );
  //------------------------------------------------------------------------------
  // DEBUG
  //------------------------------------------------------------------------------
  wire SWDIO,SWCLK;
  assign swdio=SWDIO;
  assign SWCLKTCK=swclk;

  wire SWDO;
  wire SWDOEN;
  wire SWDI;

  assign SWCLK=swclk;
  assign SWDI = SWDIO;
  assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

  //------------------------------------------------------------------------------
  // IRQ
  //------------------------------------------------------------------------------
  wire [31:0] IRQ;
  assign IRQ = {32'b0};

  //------------------------------------------------------------------------------
  // RESET AND DEBUG（复位与调试）
  //------------------------------------------------------------------------------
  wire SYSRESETREQ;
  reg cpuresetn;
  wire RSTn=rst_n;
  wire HCLK=sysclk;
  wire HRESETn=cpuresetn;
  always @(posedge sysclk or negedge RSTn)
  begin
    if (~RSTn)
      cpuresetn <= 1'b0;
    else if (SYSRESETREQ)
      cpuresetn <= 1'b0;
    else
      cpuresetn <= 1'b1;
  end

  wire CDBGPWRUPREQ;
  reg CDBGPWRUPACK;

  always @(posedge sysclk or negedge RSTn)
  begin
    if (~RSTn)
      CDBGPWRUPACK <= 1'b0;
    else
      CDBGPWRUPACK <= CDBGPWRUPREQ;
  end

//------------------------------------------------------------------------------
// S0接口所需的内部信号线，S0用于连接Cortex-M0软核
//------------------------------------------------------------------------------
  wire [31:0] HADDR,HWDATA,HRDATA;
  wire [1:0] HTRANS;
  wire HWRITE,HREADY;
  wire [2:0] HSIZE,HBURST;
  wire [3:0] HPROT;
  wire HRESP;

  CORTEXM0INTEGRATION cm0_u0 (

                        // System inputs
                        .FCLK           (sysclk),           //FREE running clock
                        .SCLK           (sysclk),           //system clock
                        .HCLK           (sysclk),           //AHB clock
                        .DCLK           (sysclk),           //Debug clock
                        .PORESETn       (RSTn),             //Power on reset
                        .HRESETn        (cpuresetn),        //AHB and System reset
                        .DBGRESETn      (RSTn),             //Debug Reset
                        .RSTBYPASS      (1'b0),             //Reset bypass
                        .SE             (1'b0),             // dummy scan enable port for synthesis

                        // Power management inputs
                        .SLEEPHOLDREQn  (1'b1),             // Sleep extension request from PMU
                        .WICENREQ       (1'b0),             // WIC enable request from PMU
                        .CDBGPWRUPACK   (CDBGPWRUPACK),     // Debug Power Up ACK from PMU

                        // Power management outputs
                        .CDBGPWRUPREQ   (CDBGPWRUPREQ),
                        .SYSRESETREQ    (SYSRESETREQ),

                        // System bus
                        .HADDR          (HADDR[31:0]),
                        .HTRANS         (HTRANS[1:0]),
                        .HSIZE          (HSIZE[2:0]),
                        .HBURST         (HBURST[2:0]),
                        .HPROT          (HPROT[3:0]),
                        .HMASTER        (HMASTER),
                        .HMASTLOCK      (HMASTLOCK),
                        .HWRITE         (HWRITE),
                        .HWDATA         (HWDATA[31:0]),
                        .HRDATA         (HRDATA[31:0]),
                        .HREADY         (HREADY),
                        .HRESP          (HRESP),

                        // Interrupts
                        .IRQ            (IRQ),          //Interrupt
                        .NMI            (1'b0),         //Watch dog interrupt
                        .IRQLATENCY     (8'h0),
                        .ECOREVNUM      (28'h0),

                        // Systick
                        .STCLKEN        (1'b1),
                        .STCALIB        (26'h0),

                        // Debug - JTAG or Serial wire
                        // Inputs
                        .nTRST          (1'b1),
                        .SWDITMS        (SWDI),
                        .SWCLKTCK       (SWCLK),
                        .TDI            (1'b0),
                        // Outputs
                        .SWDO           (SWDO),
                        .SWDOEN         (SWDOEN),

                        .DBGRESTART     (1'b0),

                        // Event communication
                        .RXEV           (RXEV),         // Generate event when a DMA operation completed.
                        .EDBGRQ         (1'b0)          // multi-core synchronous halt request
    );

//------------------------------------------------------------------------------
// M0和M1接口所需的内部信号线
// M0后面计划用于连接ROM，ROM用于存储代码
// M1后面计划用于连接RAM，RAM用于存放堆栈
//------------------------------------------------------------------------------
    wire HSELM0,HSELM1,HREADYM0,HREADYM1,HREADYOUTM0,HREADYOUTM1,HMASTLOCKM0,HMASTLOCKM1;
    wire HWRITEM0,HWRITEM1;
    wire [3:0] HPROTM0,HPROTM1;
    wire [2:0] HSIZEM0,HSIZEM1,HBURSTM0,HBURSTM1;
    wire HRESPM0,HRESPM1;
    wire [31:0] HADDRM0,HADDRM1,HWDATAM0,HWDATAM1,HRDATAM0,HRDATAM1;
    wire [1:0] HTRANSM0,HTRANSM1;
    
    //------------------------------------------------------------------------------
    // M2、M3和M4接口所需的内部信号线
    // M2后面计划用于连接APB子系统
    // M3后面计划用于连接GPIO
    // M4后面计划用于连接8080协议接口，后期可以外接一个LCD屏
    //------------------------------------------------------------------------------
    wire HSELM2,HWRITEM2,HMASTLOCKM2,HREADYM2,HREADYOUTM2,HRESPM2;
    wire [1:0] HTRANSM2;
    wire [2:0] HSIZEM2,HBURSTM2;
    wire [3:0] HPROTM2;
    wire [31:0] HWDATAM2,HRDATAM2,HADDRM2;
    
    wire HSELM3,HWRITEM3,HMASTLOCKM3,HREADYM3,HREADYOUTM3,HRESPM3;
    wire [1:0] HTRANSM3;
    wire [2:0] HSIZEM3,HBURSTM3;
    wire [3:0] HPROTM3;
    wire [31:0] HWDATAM3,HRDATAM3,HADDRM3;
    
    wire HSELM4,HWRITEM4,HMASTLOCKM4,HREADYM4,HREADYOUTM4,HRESPM4;
    wire [1:0] HTRANSM4;
    wire [2:0] HSIZEM4,HBURSTM4;
    wire [3:0] HPROTM4;
    wire [31:0] HWDATAM4,HRDATAM4,HADDRM4;

//------------------------------------------------------------------------------
// 总线矩阵
//------------------------------------------------------------------------------
    cm0_mtx_lite mtx_00_u0 (
        // Common AHB signals
        .HCLK(HCLK),
        .HRESETn(HRESETn),
    
        // System Address Remap control
        .REMAP(4'b0),
    
        // Input port SI0 (inputs from master 0)
        .HADDRS0(HADDR),
        .HTRANSS0(HTRANS),
        .HWRITES0(HWRITE),
        .HSIZES0(HSIZE),
        .HBURSTS0(HBURST),
        .HPROTS0(HPROT),
        .HWDATAS0(HWDATA),
        .HMASTLOCKS0(1'b0),
        .HAUSERS0(32'b0),
        .HWUSERS0(32'b0),
    
        // Output port MI0 (inputs from slave 0)
        .HRDATAM0(HRDATAM0),
        .HREADYOUTM0(HREADYOUTM0),
        .HRESPM0(HRESPM0),
        .HRUSERM0(32'b0),
    
        // Output port MI1 (inputs from slave 1)
        .HRDATAM1(HRDATAM1),
        .HREADYOUTM1(HREADYOUTM1),
        .HRESPM1(HRESPM1),
        .HRUSERM1(32'b0),
    
        // Output port MI2 (inputs from slave 2)
        .HRDATAM2(HRDATAM2),
        .HREADYOUTM2(HREADYOUTM2),
        .HRESPM2(HRESPM2),
        .HRUSERM2(32'b0),
    
        // Output port MI3 (inputs from slave 3)
        .HRDATAM3(HRDATAM3),
        .HREADYOUTM3(HREADYOUTM3),
        .HRESPM3(HRESPM3),
        .HRUSERM3(32'b0),
    
        // Output port MI4 (inputs from slave 4)
        .HRDATAM4(HRDATAM4),
        .HREADYOUTM4(HREADYOUTM4),
        .HRESPM4(HRESPM4),
        .HRUSERM4(32'b0),
    
        // Scan test dummy signals; not connected until scan insertion
        .SCANENABLE(1'b0),   // Scan Test Mode Enable
        .SCANINHCLK(1'b0),   // Scan Chain Input
    
    
        // Output port MI0 (outputs to slave 0)
        .HSELM0(HSELM0),
        .HADDRM0(HADDRM0),
        .HTRANSM0(HTRANSM0),
        .HWRITEM0(HWRITEM0),
        .HSIZEM0(HSIZEM0),
        .HBURSTM0(HBURSTM0),
        .HPROTM0(HPROTM0),
        .HWDATAM0(HWDATAM0),
        .HMASTLOCKM0(HMASTLOCKM0),
        .HREADYMUXM0(HREADYM0),
        .HAUSERM0(),
        .HWUSERM0(),
    
        // Output port MI1 (outputs to slave 1)
        .HSELM1(HSELM1),
        .HADDRM1(HADDRM1),
        .HTRANSM1(HTRANSM1),
        .HWRITEM1(HWRITEM1),
        .HSIZEM1(HSIZEM1),
        .HBURSTM1(HBURSTM1),
        .HPROTM1(HPROTM1),
        .HWDATAM1(HWDATAM1),
        .HMASTLOCKM1(HMASTLOCKM1),
        .HREADYMUXM1(HREADYM1),
        .HAUSERM1(),
        .HWUSERM1(),
    
        // Output port MI2 (outputs to slave 2)
        .HSELM2(HSELM2),
        .HADDRM2(HADDRM2),
        .HTRANSM2(HTRANSM2),
        .HWRITEM2(HWRITEM2),
        .HSIZEM2(HSIZEM2),
        .HBURSTM2(HBURSTM2),
        .HPROTM2(HPROTM2),
        .HWDATAM2(HWDATAM2),
        .HMASTLOCKM2(HMASTLOCKM2),
        .HREADYMUXM2(HREADYM2),
        .HAUSERM2(),
        .HWUSERM2(),
    
        // Output port MI3 (outputs to slave 3)
        .HSELM3(HSELM3),
        .HADDRM3(HADDRM3),
        .HTRANSM3(HTRANSM3),
        .HWRITEM3(HWRITEM3),
        .HSIZEM3(HSIZEM3),
        .HBURSTM3(HBURSTM3),
        .HPROTM3(HPROTM3),
        .HWDATAM3(HWDATAM3),
        .HMASTLOCKM3(HMASTLOCKM3),
        .HREADYMUXM3(HREADYM3),
        .HAUSERM3(),
        .HWUSERM3(),
    
        // Output port MI4 (outputs to slave 4)
        .HSELM4(HSELM4),
        .HADDRM4(HADDRM4),
        .HTRANSM4(HTRANSM4),
        .HWRITEM4(HWRITEM4),
        .HSIZEM4(HSIZEM4),
        .HBURSTM4(HBURSTM4),
        .HPROTM4(HPROTM4),
        .HWDATAM4(HWDATAM4),
        .HMASTLOCKM4(HMASTLOCKM4),
        .HREADYMUXM4(HREADYM4),
        .HAUSERM4(),
        .HWUSERM4(),
    
        // Input port SI0 (outputs to master 0)
        .HRDATAS0(HRDATA),
        .HREADYS0(HREADY),
        .HRESPS0(HRESP),
        .HRUSERS0(),
    
        // Scan test dummy signals; not connected until scan insertion
        .SCANOUTHCLK()   // Scan Chain Output
    
    );

//------------------------------------------------------------------------------
// AHB挂载TCM，包括ITCM和DTCM
//------------------------------------------------------------------------------
/* 存储器所需的内部信号 */
    wire [31:0] ITCM_RDATA,ITCM_WDATA,DTCM_RDATA,DTCM_WDATA; // 读写信号线
    wire [16:0] ITCM_ADDR,DTCM_ADDR;                         // 地址线
    wire [3:0]  ITCM_WRITE,DTCM_WRITE;                       // 写使能
    wire        ITCM_CS,DTCM_CS;                             // 片选
    
    /* AHB挂载ITCM */
    cmsdk_ahb_to_sram #(
        .AW                                 (32)
    ) ahb_itcm (
        .HCLK                               (HCLK),
        .HRESETn                            (HRESETn),
        .HSEL                               (HSELM0),
        .HREADY                             (HREADYM0),
        .HTRANS                             (HTRANSM0),
        .HSIZE                              (HSIZEM0),
        .HWRITE                             (HWRITEM0),
        .HADDR                              (HADDRM0),
        .HWDATA                             (HWDATAM0),
        .HREADYOUT                          (HREADYOUTM0),
        .HRESP                              (HRESPM0),
        .HRDATA                             (HRDATAM0),
    
        .SRAMRDATA                          (ITCM_RDATA),  // 读数据
        .SRAMADDR                           (ITCM_ADDR),   // 地址线
        .SRAMWEN                            (ITCM_WRITE),  // 写使能信号
        .SRAMWDATA                          (ITCM_WDATA),  // 写数据
        .SRAMCS                             (ITCM_CS)      // 片选信号
    );
    
    itcm itcm_u0(
        .clka                               (HCLK),
        .addra                              (ITCM_ADDR),
        .dia                                (ITCM_WDATA),
        .wea                                (ITCM_WRITE & {4{ITCM_CS}}),
        .doa                                (ITCM_RDATA)    
    );

/* AHB挂载DTCM */
    cmsdk_ahb_to_sram #(
        .AW                                 (32)
    ) ahb_dtcm (
        .HCLK                               (HCLK),
        .HRESETn                            (HRESETn),
        .HSEL                               (HSELM1),
        .HREADY                             (HREADYM1),
        .HTRANS                             (HTRANSM1),
        .HSIZE                              (HSIZEM1),
        .HWRITE                             (HWRITEM1),
        .HADDR                              (HADDRM1),
        .HWDATA                             (HWDATAM1),
        .HREADYOUT                          (HREADYOUTM1),
        .HRESP                              (HRESPM1),
        .HRDATA                             (HRDATAM1),
    
        .SRAMRDATA                          (DTCM_RDATA),  // 读数据
        .SRAMADDR                           (DTCM_ADDR),   // 地址线
        .SRAMWEN                            (DTCM_WRITE),  // 写使能信号
        .SRAMWDATA                          (DTCM_WDATA),  // 写数据
        .SRAMCS                             (DTCM_CS)      // 片选信号
    );
    
    dtcm dtcm_u0(
        .clka                               (HCLK),
        .addra                              (DTCM_ADDR),
        .dia                                (DTCM_WDATA),
        .wea                                (DTCM_WRITE& {4{DTCM_CS}}),
        .doa                                (DTCM_RDATA)    
    );
    

endmodule
