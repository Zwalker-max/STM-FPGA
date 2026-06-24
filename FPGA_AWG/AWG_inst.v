  //Example instantiation for system 'AWG'
  AWG AWG_inst
    (
      .clk_0                            (clk_0),
      .out_port_from_the_UART2DPRAM     (out_port_from_the_UART2DPRAM),
      .out_port_from_the_WRaddress      (out_port_from_the_WRaddress),
      .out_port_from_the_dpram_rdclk_en (out_port_from_the_dpram_rdclk_en),
      .out_port_from_the_dpram_wr_en    (out_port_from_the_dpram_wr_en),
      .out_port_from_the_dpram_wrclk    (out_port_from_the_dpram_wrclk),
      .out_port_from_the_dpram_wrclk_en (out_port_from_the_dpram_wrclk_en),
      .out_port_from_the_freq_word      (out_port_from_the_freq_word),
      .reset_n                          (reset_n),
      .rxd_to_the_uart_0                (rxd_to_the_uart_0),
      .txd_from_the_uart_0              (txd_from_the_uart_0),
      .zs_addr_from_the_sdram_0         (zs_addr_from_the_sdram_0),
      .zs_ba_from_the_sdram_0           (zs_ba_from_the_sdram_0),
      .zs_cas_n_from_the_sdram_0        (zs_cas_n_from_the_sdram_0),
      .zs_cke_from_the_sdram_0          (zs_cke_from_the_sdram_0),
      .zs_cs_n_from_the_sdram_0         (zs_cs_n_from_the_sdram_0),
      .zs_dq_to_and_from_the_sdram_0    (zs_dq_to_and_from_the_sdram_0),
      .zs_dqm_from_the_sdram_0          (zs_dqm_from_the_sdram_0),
      .zs_ras_n_from_the_sdram_0        (zs_ras_n_from_the_sdram_0),
      .zs_we_n_from_the_sdram_0         (zs_we_n_from_the_sdram_0)
    );

