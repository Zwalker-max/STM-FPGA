//megafunction wizard: %Altera SOPC Builder%
//GENERATION: STANDARD
//VERSION: WM1.0


//Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
//use of Altera Corporation's design tools, logic functions and other
//software and tools, and its AMPP partner logic functions, and any
//output files any of the foregoing (including device programming or
//simulation files), and any associated documentation or information are
//expressly subject to the terms and conditions of the Altera Program
//License Subscription Agreement or other applicable license agreement,
//including, without limitation, that your use is for the sole purpose
//of programming logic devices manufactured by Altera and sold by Altera
//or its authorized distributors.  Please refer to the applicable
//agreement for further details.

// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module UART2DPRAM_s1_arbitrator (
                                  // inputs:
                                   UART2DPRAM_s1_readdata,
                                   clk,
                                   cpu_0_data_master_address_to_slave,
                                   cpu_0_data_master_read,
                                   cpu_0_data_master_waitrequest,
                                   cpu_0_data_master_write,
                                   cpu_0_data_master_writedata,
                                   reset_n,

                                  // outputs:
                                   UART2DPRAM_s1_address,
                                   UART2DPRAM_s1_chipselect,
                                   UART2DPRAM_s1_readdata_from_sa,
                                   UART2DPRAM_s1_reset_n,
                                   UART2DPRAM_s1_write_n,
                                   UART2DPRAM_s1_writedata,
                                   cpu_0_data_master_granted_UART2DPRAM_s1,
                                   cpu_0_data_master_qualified_request_UART2DPRAM_s1,
                                   cpu_0_data_master_read_data_valid_UART2DPRAM_s1,
                                   cpu_0_data_master_requests_UART2DPRAM_s1,
                                   d1_UART2DPRAM_s1_end_xfer
                                )
;

  output  [  1: 0] UART2DPRAM_s1_address;
  output           UART2DPRAM_s1_chipselect;
  output  [ 11: 0] UART2DPRAM_s1_readdata_from_sa;
  output           UART2DPRAM_s1_reset_n;
  output           UART2DPRAM_s1_write_n;
  output  [ 11: 0] UART2DPRAM_s1_writedata;
  output           cpu_0_data_master_granted_UART2DPRAM_s1;
  output           cpu_0_data_master_qualified_request_UART2DPRAM_s1;
  output           cpu_0_data_master_read_data_valid_UART2DPRAM_s1;
  output           cpu_0_data_master_requests_UART2DPRAM_s1;
  output           d1_UART2DPRAM_s1_end_xfer;
  input   [ 11: 0] UART2DPRAM_s1_readdata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            reset_n;

  wire    [  1: 0] UART2DPRAM_s1_address;
  wire             UART2DPRAM_s1_allgrants;
  wire             UART2DPRAM_s1_allow_new_arb_cycle;
  wire             UART2DPRAM_s1_any_bursting_master_saved_grant;
  wire             UART2DPRAM_s1_any_continuerequest;
  wire             UART2DPRAM_s1_arb_counter_enable;
  reg     [  1: 0] UART2DPRAM_s1_arb_share_counter;
  wire    [  1: 0] UART2DPRAM_s1_arb_share_counter_next_value;
  wire    [  1: 0] UART2DPRAM_s1_arb_share_set_values;
  wire             UART2DPRAM_s1_beginbursttransfer_internal;
  wire             UART2DPRAM_s1_begins_xfer;
  wire             UART2DPRAM_s1_chipselect;
  wire             UART2DPRAM_s1_end_xfer;
  wire             UART2DPRAM_s1_firsttransfer;
  wire             UART2DPRAM_s1_grant_vector;
  wire             UART2DPRAM_s1_in_a_read_cycle;
  wire             UART2DPRAM_s1_in_a_write_cycle;
  wire             UART2DPRAM_s1_master_qreq_vector;
  wire             UART2DPRAM_s1_non_bursting_master_requests;
  wire    [ 11: 0] UART2DPRAM_s1_readdata_from_sa;
  reg              UART2DPRAM_s1_reg_firsttransfer;
  wire             UART2DPRAM_s1_reset_n;
  reg              UART2DPRAM_s1_slavearbiterlockenable;
  wire             UART2DPRAM_s1_slavearbiterlockenable2;
  wire             UART2DPRAM_s1_unreg_firsttransfer;
  wire             UART2DPRAM_s1_waits_for_read;
  wire             UART2DPRAM_s1_waits_for_write;
  wire             UART2DPRAM_s1_write_n;
  wire    [ 11: 0] UART2DPRAM_s1_writedata;
  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_UART2DPRAM_s1;
  wire             cpu_0_data_master_qualified_request_UART2DPRAM_s1;
  wire             cpu_0_data_master_read_data_valid_UART2DPRAM_s1;
  wire             cpu_0_data_master_requests_UART2DPRAM_s1;
  wire             cpu_0_data_master_saved_grant_UART2DPRAM_s1;
  reg              d1_UART2DPRAM_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_UART2DPRAM_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_UART2DPRAM_s1_from_cpu_0_data_master;
  wire             wait_for_UART2DPRAM_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~UART2DPRAM_s1_end_xfer;
    end


  assign UART2DPRAM_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_UART2DPRAM_s1));
  //assign UART2DPRAM_s1_readdata_from_sa = UART2DPRAM_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign UART2DPRAM_s1_readdata_from_sa = UART2DPRAM_s1_readdata;

  assign cpu_0_data_master_requests_UART2DPRAM_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002020) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //UART2DPRAM_s1_arb_share_counter set values, which is an e_mux
  assign UART2DPRAM_s1_arb_share_set_values = 1;

  //UART2DPRAM_s1_non_bursting_master_requests mux, which is an e_mux
  assign UART2DPRAM_s1_non_bursting_master_requests = cpu_0_data_master_requests_UART2DPRAM_s1;

  //UART2DPRAM_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign UART2DPRAM_s1_any_bursting_master_saved_grant = 0;

  //UART2DPRAM_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign UART2DPRAM_s1_arb_share_counter_next_value = UART2DPRAM_s1_firsttransfer ? (UART2DPRAM_s1_arb_share_set_values - 1) : |UART2DPRAM_s1_arb_share_counter ? (UART2DPRAM_s1_arb_share_counter - 1) : 0;

  //UART2DPRAM_s1_allgrants all slave grants, which is an e_mux
  assign UART2DPRAM_s1_allgrants = |UART2DPRAM_s1_grant_vector;

  //UART2DPRAM_s1_end_xfer assignment, which is an e_assign
  assign UART2DPRAM_s1_end_xfer = ~(UART2DPRAM_s1_waits_for_read | UART2DPRAM_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_UART2DPRAM_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_UART2DPRAM_s1 = UART2DPRAM_s1_end_xfer & (~UART2DPRAM_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //UART2DPRAM_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign UART2DPRAM_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_UART2DPRAM_s1 & UART2DPRAM_s1_allgrants) | (end_xfer_arb_share_counter_term_UART2DPRAM_s1 & ~UART2DPRAM_s1_non_bursting_master_requests);

  //UART2DPRAM_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          UART2DPRAM_s1_arb_share_counter <= 0;
      else if (UART2DPRAM_s1_arb_counter_enable)
          UART2DPRAM_s1_arb_share_counter <= UART2DPRAM_s1_arb_share_counter_next_value;
    end


  //UART2DPRAM_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          UART2DPRAM_s1_slavearbiterlockenable <= 0;
      else if ((|UART2DPRAM_s1_master_qreq_vector & end_xfer_arb_share_counter_term_UART2DPRAM_s1) | (end_xfer_arb_share_counter_term_UART2DPRAM_s1 & ~UART2DPRAM_s1_non_bursting_master_requests))
          UART2DPRAM_s1_slavearbiterlockenable <= |UART2DPRAM_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master UART2DPRAM/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = UART2DPRAM_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //UART2DPRAM_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign UART2DPRAM_s1_slavearbiterlockenable2 = |UART2DPRAM_s1_arb_share_counter_next_value;

  //cpu_0/data_master UART2DPRAM/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = UART2DPRAM_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //UART2DPRAM_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign UART2DPRAM_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_UART2DPRAM_s1 = cpu_0_data_master_requests_UART2DPRAM_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //UART2DPRAM_s1_writedata mux, which is an e_mux
  assign UART2DPRAM_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_UART2DPRAM_s1 = cpu_0_data_master_qualified_request_UART2DPRAM_s1;

  //cpu_0/data_master saved-grant UART2DPRAM/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_UART2DPRAM_s1 = cpu_0_data_master_requests_UART2DPRAM_s1;

  //allow new arb cycle for UART2DPRAM/s1, which is an e_assign
  assign UART2DPRAM_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign UART2DPRAM_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign UART2DPRAM_s1_master_qreq_vector = 1;

  //UART2DPRAM_s1_reset_n assignment, which is an e_assign
  assign UART2DPRAM_s1_reset_n = reset_n;

  assign UART2DPRAM_s1_chipselect = cpu_0_data_master_granted_UART2DPRAM_s1;
  //UART2DPRAM_s1_firsttransfer first transaction, which is an e_assign
  assign UART2DPRAM_s1_firsttransfer = UART2DPRAM_s1_begins_xfer ? UART2DPRAM_s1_unreg_firsttransfer : UART2DPRAM_s1_reg_firsttransfer;

  //UART2DPRAM_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign UART2DPRAM_s1_unreg_firsttransfer = ~(UART2DPRAM_s1_slavearbiterlockenable & UART2DPRAM_s1_any_continuerequest);

  //UART2DPRAM_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          UART2DPRAM_s1_reg_firsttransfer <= 1'b1;
      else if (UART2DPRAM_s1_begins_xfer)
          UART2DPRAM_s1_reg_firsttransfer <= UART2DPRAM_s1_unreg_firsttransfer;
    end


  //UART2DPRAM_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign UART2DPRAM_s1_beginbursttransfer_internal = UART2DPRAM_s1_begins_xfer;

  //~UART2DPRAM_s1_write_n assignment, which is an e_mux
  assign UART2DPRAM_s1_write_n = ~(cpu_0_data_master_granted_UART2DPRAM_s1 & cpu_0_data_master_write);

  assign shifted_address_to_UART2DPRAM_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //UART2DPRAM_s1_address mux, which is an e_mux
  assign UART2DPRAM_s1_address = shifted_address_to_UART2DPRAM_s1_from_cpu_0_data_master >> 2;

  //d1_UART2DPRAM_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_UART2DPRAM_s1_end_xfer <= 1;
      else 
        d1_UART2DPRAM_s1_end_xfer <= UART2DPRAM_s1_end_xfer;
    end


  //UART2DPRAM_s1_waits_for_read in a cycle, which is an e_mux
  assign UART2DPRAM_s1_waits_for_read = UART2DPRAM_s1_in_a_read_cycle & UART2DPRAM_s1_begins_xfer;

  //UART2DPRAM_s1_in_a_read_cycle assignment, which is an e_assign
  assign UART2DPRAM_s1_in_a_read_cycle = cpu_0_data_master_granted_UART2DPRAM_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = UART2DPRAM_s1_in_a_read_cycle;

  //UART2DPRAM_s1_waits_for_write in a cycle, which is an e_mux
  assign UART2DPRAM_s1_waits_for_write = UART2DPRAM_s1_in_a_write_cycle & 0;

  //UART2DPRAM_s1_in_a_write_cycle assignment, which is an e_assign
  assign UART2DPRAM_s1_in_a_write_cycle = cpu_0_data_master_granted_UART2DPRAM_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = UART2DPRAM_s1_in_a_write_cycle;

  assign wait_for_UART2DPRAM_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //UART2DPRAM/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module WRaddress_s1_arbitrator (
                                 // inputs:
                                  WRaddress_s1_readdata,
                                  clk,
                                  cpu_0_data_master_address_to_slave,
                                  cpu_0_data_master_read,
                                  cpu_0_data_master_waitrequest,
                                  cpu_0_data_master_write,
                                  cpu_0_data_master_writedata,
                                  reset_n,

                                 // outputs:
                                  WRaddress_s1_address,
                                  WRaddress_s1_chipselect,
                                  WRaddress_s1_readdata_from_sa,
                                  WRaddress_s1_reset_n,
                                  WRaddress_s1_write_n,
                                  WRaddress_s1_writedata,
                                  cpu_0_data_master_granted_WRaddress_s1,
                                  cpu_0_data_master_qualified_request_WRaddress_s1,
                                  cpu_0_data_master_read_data_valid_WRaddress_s1,
                                  cpu_0_data_master_requests_WRaddress_s1,
                                  d1_WRaddress_s1_end_xfer
                               )
;

  output  [  1: 0] WRaddress_s1_address;
  output           WRaddress_s1_chipselect;
  output  [  9: 0] WRaddress_s1_readdata_from_sa;
  output           WRaddress_s1_reset_n;
  output           WRaddress_s1_write_n;
  output  [  9: 0] WRaddress_s1_writedata;
  output           cpu_0_data_master_granted_WRaddress_s1;
  output           cpu_0_data_master_qualified_request_WRaddress_s1;
  output           cpu_0_data_master_read_data_valid_WRaddress_s1;
  output           cpu_0_data_master_requests_WRaddress_s1;
  output           d1_WRaddress_s1_end_xfer;
  input   [  9: 0] WRaddress_s1_readdata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            reset_n;

  wire    [  1: 0] WRaddress_s1_address;
  wire             WRaddress_s1_allgrants;
  wire             WRaddress_s1_allow_new_arb_cycle;
  wire             WRaddress_s1_any_bursting_master_saved_grant;
  wire             WRaddress_s1_any_continuerequest;
  wire             WRaddress_s1_arb_counter_enable;
  reg     [  1: 0] WRaddress_s1_arb_share_counter;
  wire    [  1: 0] WRaddress_s1_arb_share_counter_next_value;
  wire    [  1: 0] WRaddress_s1_arb_share_set_values;
  wire             WRaddress_s1_beginbursttransfer_internal;
  wire             WRaddress_s1_begins_xfer;
  wire             WRaddress_s1_chipselect;
  wire             WRaddress_s1_end_xfer;
  wire             WRaddress_s1_firsttransfer;
  wire             WRaddress_s1_grant_vector;
  wire             WRaddress_s1_in_a_read_cycle;
  wire             WRaddress_s1_in_a_write_cycle;
  wire             WRaddress_s1_master_qreq_vector;
  wire             WRaddress_s1_non_bursting_master_requests;
  wire    [  9: 0] WRaddress_s1_readdata_from_sa;
  reg              WRaddress_s1_reg_firsttransfer;
  wire             WRaddress_s1_reset_n;
  reg              WRaddress_s1_slavearbiterlockenable;
  wire             WRaddress_s1_slavearbiterlockenable2;
  wire             WRaddress_s1_unreg_firsttransfer;
  wire             WRaddress_s1_waits_for_read;
  wire             WRaddress_s1_waits_for_write;
  wire             WRaddress_s1_write_n;
  wire    [  9: 0] WRaddress_s1_writedata;
  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_WRaddress_s1;
  wire             cpu_0_data_master_qualified_request_WRaddress_s1;
  wire             cpu_0_data_master_read_data_valid_WRaddress_s1;
  wire             cpu_0_data_master_requests_WRaddress_s1;
  wire             cpu_0_data_master_saved_grant_WRaddress_s1;
  reg              d1_WRaddress_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_WRaddress_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_WRaddress_s1_from_cpu_0_data_master;
  wire             wait_for_WRaddress_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~WRaddress_s1_end_xfer;
    end


  assign WRaddress_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_WRaddress_s1));
  //assign WRaddress_s1_readdata_from_sa = WRaddress_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign WRaddress_s1_readdata_from_sa = WRaddress_s1_readdata;

  assign cpu_0_data_master_requests_WRaddress_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002030) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //WRaddress_s1_arb_share_counter set values, which is an e_mux
  assign WRaddress_s1_arb_share_set_values = 1;

  //WRaddress_s1_non_bursting_master_requests mux, which is an e_mux
  assign WRaddress_s1_non_bursting_master_requests = cpu_0_data_master_requests_WRaddress_s1;

  //WRaddress_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign WRaddress_s1_any_bursting_master_saved_grant = 0;

  //WRaddress_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign WRaddress_s1_arb_share_counter_next_value = WRaddress_s1_firsttransfer ? (WRaddress_s1_arb_share_set_values - 1) : |WRaddress_s1_arb_share_counter ? (WRaddress_s1_arb_share_counter - 1) : 0;

  //WRaddress_s1_allgrants all slave grants, which is an e_mux
  assign WRaddress_s1_allgrants = |WRaddress_s1_grant_vector;

  //WRaddress_s1_end_xfer assignment, which is an e_assign
  assign WRaddress_s1_end_xfer = ~(WRaddress_s1_waits_for_read | WRaddress_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_WRaddress_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_WRaddress_s1 = WRaddress_s1_end_xfer & (~WRaddress_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //WRaddress_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign WRaddress_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_WRaddress_s1 & WRaddress_s1_allgrants) | (end_xfer_arb_share_counter_term_WRaddress_s1 & ~WRaddress_s1_non_bursting_master_requests);

  //WRaddress_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          WRaddress_s1_arb_share_counter <= 0;
      else if (WRaddress_s1_arb_counter_enable)
          WRaddress_s1_arb_share_counter <= WRaddress_s1_arb_share_counter_next_value;
    end


  //WRaddress_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          WRaddress_s1_slavearbiterlockenable <= 0;
      else if ((|WRaddress_s1_master_qreq_vector & end_xfer_arb_share_counter_term_WRaddress_s1) | (end_xfer_arb_share_counter_term_WRaddress_s1 & ~WRaddress_s1_non_bursting_master_requests))
          WRaddress_s1_slavearbiterlockenable <= |WRaddress_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master WRaddress/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = WRaddress_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //WRaddress_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign WRaddress_s1_slavearbiterlockenable2 = |WRaddress_s1_arb_share_counter_next_value;

  //cpu_0/data_master WRaddress/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = WRaddress_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //WRaddress_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign WRaddress_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_WRaddress_s1 = cpu_0_data_master_requests_WRaddress_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //WRaddress_s1_writedata mux, which is an e_mux
  assign WRaddress_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_WRaddress_s1 = cpu_0_data_master_qualified_request_WRaddress_s1;

  //cpu_0/data_master saved-grant WRaddress/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_WRaddress_s1 = cpu_0_data_master_requests_WRaddress_s1;

  //allow new arb cycle for WRaddress/s1, which is an e_assign
  assign WRaddress_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign WRaddress_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign WRaddress_s1_master_qreq_vector = 1;

  //WRaddress_s1_reset_n assignment, which is an e_assign
  assign WRaddress_s1_reset_n = reset_n;

  assign WRaddress_s1_chipselect = cpu_0_data_master_granted_WRaddress_s1;
  //WRaddress_s1_firsttransfer first transaction, which is an e_assign
  assign WRaddress_s1_firsttransfer = WRaddress_s1_begins_xfer ? WRaddress_s1_unreg_firsttransfer : WRaddress_s1_reg_firsttransfer;

  //WRaddress_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign WRaddress_s1_unreg_firsttransfer = ~(WRaddress_s1_slavearbiterlockenable & WRaddress_s1_any_continuerequest);

  //WRaddress_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          WRaddress_s1_reg_firsttransfer <= 1'b1;
      else if (WRaddress_s1_begins_xfer)
          WRaddress_s1_reg_firsttransfer <= WRaddress_s1_unreg_firsttransfer;
    end


  //WRaddress_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign WRaddress_s1_beginbursttransfer_internal = WRaddress_s1_begins_xfer;

  //~WRaddress_s1_write_n assignment, which is an e_mux
  assign WRaddress_s1_write_n = ~(cpu_0_data_master_granted_WRaddress_s1 & cpu_0_data_master_write);

  assign shifted_address_to_WRaddress_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //WRaddress_s1_address mux, which is an e_mux
  assign WRaddress_s1_address = shifted_address_to_WRaddress_s1_from_cpu_0_data_master >> 2;

  //d1_WRaddress_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_WRaddress_s1_end_xfer <= 1;
      else 
        d1_WRaddress_s1_end_xfer <= WRaddress_s1_end_xfer;
    end


  //WRaddress_s1_waits_for_read in a cycle, which is an e_mux
  assign WRaddress_s1_waits_for_read = WRaddress_s1_in_a_read_cycle & WRaddress_s1_begins_xfer;

  //WRaddress_s1_in_a_read_cycle assignment, which is an e_assign
  assign WRaddress_s1_in_a_read_cycle = cpu_0_data_master_granted_WRaddress_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = WRaddress_s1_in_a_read_cycle;

  //WRaddress_s1_waits_for_write in a cycle, which is an e_mux
  assign WRaddress_s1_waits_for_write = WRaddress_s1_in_a_write_cycle & 0;

  //WRaddress_s1_in_a_write_cycle assignment, which is an e_assign
  assign WRaddress_s1_in_a_write_cycle = cpu_0_data_master_granted_WRaddress_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = WRaddress_s1_in_a_write_cycle;

  assign wait_for_WRaddress_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //WRaddress/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_0_jtag_debug_module_arbitrator (
                                            // inputs:
                                             clk,
                                             cpu_0_data_master_address_to_slave,
                                             cpu_0_data_master_byteenable,
                                             cpu_0_data_master_debugaccess,
                                             cpu_0_data_master_read,
                                             cpu_0_data_master_waitrequest,
                                             cpu_0_data_master_write,
                                             cpu_0_data_master_writedata,
                                             cpu_0_instruction_master_address_to_slave,
                                             cpu_0_instruction_master_read,
                                             cpu_0_jtag_debug_module_readdata,
                                             cpu_0_jtag_debug_module_resetrequest,
                                             reset_n,

                                            // outputs:
                                             cpu_0_data_master_granted_cpu_0_jtag_debug_module,
                                             cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
                                             cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
                                             cpu_0_data_master_requests_cpu_0_jtag_debug_module,
                                             cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
                                             cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
                                             cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
                                             cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
                                             cpu_0_jtag_debug_module_address,
                                             cpu_0_jtag_debug_module_begintransfer,
                                             cpu_0_jtag_debug_module_byteenable,
                                             cpu_0_jtag_debug_module_chipselect,
                                             cpu_0_jtag_debug_module_debugaccess,
                                             cpu_0_jtag_debug_module_readdata_from_sa,
                                             cpu_0_jtag_debug_module_reset_n,
                                             cpu_0_jtag_debug_module_resetrequest_from_sa,
                                             cpu_0_jtag_debug_module_write,
                                             cpu_0_jtag_debug_module_writedata,
                                             d1_cpu_0_jtag_debug_module_end_xfer
                                          )
;

  output           cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  output           cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  output           cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module;
  output           cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  output           cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  output           cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  output           cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module;
  output           cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  output  [  8: 0] cpu_0_jtag_debug_module_address;
  output           cpu_0_jtag_debug_module_begintransfer;
  output  [  3: 0] cpu_0_jtag_debug_module_byteenable;
  output           cpu_0_jtag_debug_module_chipselect;
  output           cpu_0_jtag_debug_module_debugaccess;
  output  [ 31: 0] cpu_0_jtag_debug_module_readdata_from_sa;
  output           cpu_0_jtag_debug_module_reset_n;
  output           cpu_0_jtag_debug_module_resetrequest_from_sa;
  output           cpu_0_jtag_debug_module_write;
  output  [ 31: 0] cpu_0_jtag_debug_module_writedata;
  output           d1_cpu_0_jtag_debug_module_end_xfer;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input   [  3: 0] cpu_0_data_master_byteenable;
  input            cpu_0_data_master_debugaccess;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input   [ 24: 0] cpu_0_instruction_master_address_to_slave;
  input            cpu_0_instruction_master_read;
  input   [ 31: 0] cpu_0_jtag_debug_module_readdata;
  input            cpu_0_jtag_debug_module_resetrequest;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_arbiterlock;
  wire             cpu_0_instruction_master_arbiterlock2;
  wire             cpu_0_instruction_master_continuerequest;
  wire             cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module;
  wire    [  8: 0] cpu_0_jtag_debug_module_address;
  wire             cpu_0_jtag_debug_module_allgrants;
  wire             cpu_0_jtag_debug_module_allow_new_arb_cycle;
  wire             cpu_0_jtag_debug_module_any_bursting_master_saved_grant;
  wire             cpu_0_jtag_debug_module_any_continuerequest;
  reg     [  1: 0] cpu_0_jtag_debug_module_arb_addend;
  wire             cpu_0_jtag_debug_module_arb_counter_enable;
  reg     [  1: 0] cpu_0_jtag_debug_module_arb_share_counter;
  wire    [  1: 0] cpu_0_jtag_debug_module_arb_share_counter_next_value;
  wire    [  1: 0] cpu_0_jtag_debug_module_arb_share_set_values;
  wire    [  1: 0] cpu_0_jtag_debug_module_arb_winner;
  wire             cpu_0_jtag_debug_module_arbitration_holdoff_internal;
  wire             cpu_0_jtag_debug_module_beginbursttransfer_internal;
  wire             cpu_0_jtag_debug_module_begins_xfer;
  wire             cpu_0_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_0_jtag_debug_module_byteenable;
  wire             cpu_0_jtag_debug_module_chipselect;
  wire    [  3: 0] cpu_0_jtag_debug_module_chosen_master_double_vector;
  wire    [  1: 0] cpu_0_jtag_debug_module_chosen_master_rot_left;
  wire             cpu_0_jtag_debug_module_debugaccess;
  wire             cpu_0_jtag_debug_module_end_xfer;
  wire             cpu_0_jtag_debug_module_firsttransfer;
  wire    [  1: 0] cpu_0_jtag_debug_module_grant_vector;
  wire             cpu_0_jtag_debug_module_in_a_read_cycle;
  wire             cpu_0_jtag_debug_module_in_a_write_cycle;
  wire    [  1: 0] cpu_0_jtag_debug_module_master_qreq_vector;
  wire             cpu_0_jtag_debug_module_non_bursting_master_requests;
  wire    [ 31: 0] cpu_0_jtag_debug_module_readdata_from_sa;
  reg              cpu_0_jtag_debug_module_reg_firsttransfer;
  wire             cpu_0_jtag_debug_module_reset_n;
  wire             cpu_0_jtag_debug_module_resetrequest_from_sa;
  reg     [  1: 0] cpu_0_jtag_debug_module_saved_chosen_master_vector;
  reg              cpu_0_jtag_debug_module_slavearbiterlockenable;
  wire             cpu_0_jtag_debug_module_slavearbiterlockenable2;
  wire             cpu_0_jtag_debug_module_unreg_firsttransfer;
  wire             cpu_0_jtag_debug_module_waits_for_read;
  wire             cpu_0_jtag_debug_module_waits_for_write;
  wire             cpu_0_jtag_debug_module_write;
  wire    [ 31: 0] cpu_0_jtag_debug_module_writedata;
  reg              d1_cpu_0_jtag_debug_module_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module;
  reg              last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module;
  wire    [ 24: 0] shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master;
  wire    [ 24: 0] shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master;
  wire             wait_for_cpu_0_jtag_debug_module_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~cpu_0_jtag_debug_module_end_xfer;
    end


  assign cpu_0_jtag_debug_module_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module | cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module));
  //assign cpu_0_jtag_debug_module_readdata_from_sa = cpu_0_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_0_jtag_debug_module_readdata_from_sa = cpu_0_jtag_debug_module_readdata;

  assign cpu_0_data_master_requests_cpu_0_jtag_debug_module = ({cpu_0_data_master_address_to_slave[24 : 11] , 11'b0} == 25'h1001000) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //cpu_0_jtag_debug_module_arb_share_counter set values, which is an e_mux
  assign cpu_0_jtag_debug_module_arb_share_set_values = 1;

  //cpu_0_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  assign cpu_0_jtag_debug_module_non_bursting_master_requests = cpu_0_data_master_requests_cpu_0_jtag_debug_module |
    cpu_0_instruction_master_requests_cpu_0_jtag_debug_module |
    cpu_0_data_master_requests_cpu_0_jtag_debug_module |
    cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;

  //cpu_0_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  assign cpu_0_jtag_debug_module_any_bursting_master_saved_grant = 0;

  //cpu_0_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  assign cpu_0_jtag_debug_module_arb_share_counter_next_value = cpu_0_jtag_debug_module_firsttransfer ? (cpu_0_jtag_debug_module_arb_share_set_values - 1) : |cpu_0_jtag_debug_module_arb_share_counter ? (cpu_0_jtag_debug_module_arb_share_counter - 1) : 0;

  //cpu_0_jtag_debug_module_allgrants all slave grants, which is an e_mux
  assign cpu_0_jtag_debug_module_allgrants = (|cpu_0_jtag_debug_module_grant_vector) |
    (|cpu_0_jtag_debug_module_grant_vector) |
    (|cpu_0_jtag_debug_module_grant_vector) |
    (|cpu_0_jtag_debug_module_grant_vector);

  //cpu_0_jtag_debug_module_end_xfer assignment, which is an e_assign
  assign cpu_0_jtag_debug_module_end_xfer = ~(cpu_0_jtag_debug_module_waits_for_read | cpu_0_jtag_debug_module_waits_for_write);

  //end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module = cpu_0_jtag_debug_module_end_xfer & (~cpu_0_jtag_debug_module_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //cpu_0_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  assign cpu_0_jtag_debug_module_arb_counter_enable = (end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module & cpu_0_jtag_debug_module_allgrants) | (end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module & ~cpu_0_jtag_debug_module_non_bursting_master_requests);

  //cpu_0_jtag_debug_module_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_jtag_debug_module_arb_share_counter <= 0;
      else if (cpu_0_jtag_debug_module_arb_counter_enable)
          cpu_0_jtag_debug_module_arb_share_counter <= cpu_0_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_0_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_jtag_debug_module_slavearbiterlockenable <= 0;
      else if ((|cpu_0_jtag_debug_module_master_qreq_vector & end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module) | (end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module & ~cpu_0_jtag_debug_module_non_bursting_master_requests))
          cpu_0_jtag_debug_module_slavearbiterlockenable <= |cpu_0_jtag_debug_module_arb_share_counter_next_value;
    end


  //cpu_0/data_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = cpu_0_jtag_debug_module_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //cpu_0_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign cpu_0_jtag_debug_module_slavearbiterlockenable2 = |cpu_0_jtag_debug_module_arb_share_counter_next_value;

  //cpu_0/data_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = cpu_0_jtag_debug_module_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock = cpu_0_jtag_debug_module_slavearbiterlockenable & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock2 = cpu_0_jtag_debug_module_slavearbiterlockenable2 & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master granted cpu_0/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module ? 1 : (cpu_0_jtag_debug_module_arbitration_holdoff_internal | ~cpu_0_instruction_master_requests_cpu_0_jtag_debug_module) ? 0 : last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module;
    end


  //cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_0_instruction_master_continuerequest = last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module & cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;

  //cpu_0_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  assign cpu_0_jtag_debug_module_any_continuerequest = cpu_0_instruction_master_continuerequest |
    cpu_0_data_master_continuerequest;

  assign cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module = cpu_0_data_master_requests_cpu_0_jtag_debug_module & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write) | cpu_0_instruction_master_arbiterlock);
  //cpu_0_jtag_debug_module_writedata mux, which is an e_mux
  assign cpu_0_jtag_debug_module_writedata = cpu_0_data_master_writedata;

  assign cpu_0_instruction_master_requests_cpu_0_jtag_debug_module = (({cpu_0_instruction_master_address_to_slave[24 : 11] , 11'b0} == 25'h1001000) & (cpu_0_instruction_master_read)) & cpu_0_instruction_master_read;
  //cpu_0/data_master granted cpu_0/jtag_debug_module last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= 0;
      else 
        last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module ? 1 : (cpu_0_jtag_debug_module_arbitration_holdoff_internal | ~cpu_0_data_master_requests_cpu_0_jtag_debug_module) ? 0 : last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module;
    end


  //cpu_0_data_master_continuerequest continued request, which is an e_mux
  assign cpu_0_data_master_continuerequest = last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module & cpu_0_data_master_requests_cpu_0_jtag_debug_module;

  assign cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module = cpu_0_instruction_master_requests_cpu_0_jtag_debug_module & ~(cpu_0_data_master_arbiterlock);
  //allow new arb cycle for cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_jtag_debug_module_allow_new_arb_cycle = ~cpu_0_data_master_arbiterlock & ~cpu_0_instruction_master_arbiterlock;

  //cpu_0/instruction_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_jtag_debug_module_master_qreq_vector[0] = cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;

  //cpu_0/instruction_master grant cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_instruction_master_granted_cpu_0_jtag_debug_module = cpu_0_jtag_debug_module_grant_vector[0];

  //cpu_0/instruction_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module = cpu_0_jtag_debug_module_arb_winner[0] && cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;

  //cpu_0/data_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_jtag_debug_module_master_qreq_vector[1] = cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;

  //cpu_0/data_master grant cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_data_master_granted_cpu_0_jtag_debug_module = cpu_0_jtag_debug_module_grant_vector[1];

  //cpu_0/data_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  assign cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module = cpu_0_jtag_debug_module_arb_winner[1] && cpu_0_data_master_requests_cpu_0_jtag_debug_module;

  //cpu_0/jtag_debug_module chosen-master double-vector, which is an e_assign
  assign cpu_0_jtag_debug_module_chosen_master_double_vector = {cpu_0_jtag_debug_module_master_qreq_vector, cpu_0_jtag_debug_module_master_qreq_vector} & ({~cpu_0_jtag_debug_module_master_qreq_vector, ~cpu_0_jtag_debug_module_master_qreq_vector} + cpu_0_jtag_debug_module_arb_addend);

  //stable onehot encoding of arb winner
  assign cpu_0_jtag_debug_module_arb_winner = (cpu_0_jtag_debug_module_allow_new_arb_cycle & | cpu_0_jtag_debug_module_grant_vector) ? cpu_0_jtag_debug_module_grant_vector : cpu_0_jtag_debug_module_saved_chosen_master_vector;

  //saved cpu_0_jtag_debug_module_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_jtag_debug_module_saved_chosen_master_vector <= 0;
      else if (cpu_0_jtag_debug_module_allow_new_arb_cycle)
          cpu_0_jtag_debug_module_saved_chosen_master_vector <= |cpu_0_jtag_debug_module_grant_vector ? cpu_0_jtag_debug_module_grant_vector : cpu_0_jtag_debug_module_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign cpu_0_jtag_debug_module_grant_vector = {(cpu_0_jtag_debug_module_chosen_master_double_vector[1] | cpu_0_jtag_debug_module_chosen_master_double_vector[3]),
    (cpu_0_jtag_debug_module_chosen_master_double_vector[0] | cpu_0_jtag_debug_module_chosen_master_double_vector[2])};

  //cpu_0/jtag_debug_module chosen master rotated left, which is an e_assign
  assign cpu_0_jtag_debug_module_chosen_master_rot_left = (cpu_0_jtag_debug_module_arb_winner << 1) ? (cpu_0_jtag_debug_module_arb_winner << 1) : 1;

  //cpu_0/jtag_debug_module's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_jtag_debug_module_arb_addend <= 1;
      else if (|cpu_0_jtag_debug_module_grant_vector)
          cpu_0_jtag_debug_module_arb_addend <= cpu_0_jtag_debug_module_end_xfer? cpu_0_jtag_debug_module_chosen_master_rot_left : cpu_0_jtag_debug_module_grant_vector;
    end


  assign cpu_0_jtag_debug_module_begintransfer = cpu_0_jtag_debug_module_begins_xfer;
  //cpu_0_jtag_debug_module_reset_n assignment, which is an e_assign
  assign cpu_0_jtag_debug_module_reset_n = reset_n;

  //assign cpu_0_jtag_debug_module_resetrequest_from_sa = cpu_0_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign cpu_0_jtag_debug_module_resetrequest_from_sa = cpu_0_jtag_debug_module_resetrequest;

  assign cpu_0_jtag_debug_module_chipselect = cpu_0_data_master_granted_cpu_0_jtag_debug_module | cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  //cpu_0_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  assign cpu_0_jtag_debug_module_firsttransfer = cpu_0_jtag_debug_module_begins_xfer ? cpu_0_jtag_debug_module_unreg_firsttransfer : cpu_0_jtag_debug_module_reg_firsttransfer;

  //cpu_0_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  assign cpu_0_jtag_debug_module_unreg_firsttransfer = ~(cpu_0_jtag_debug_module_slavearbiterlockenable & cpu_0_jtag_debug_module_any_continuerequest);

  //cpu_0_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_jtag_debug_module_reg_firsttransfer <= 1'b1;
      else if (cpu_0_jtag_debug_module_begins_xfer)
          cpu_0_jtag_debug_module_reg_firsttransfer <= cpu_0_jtag_debug_module_unreg_firsttransfer;
    end


  //cpu_0_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign cpu_0_jtag_debug_module_beginbursttransfer_internal = cpu_0_jtag_debug_module_begins_xfer;

  //cpu_0_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign cpu_0_jtag_debug_module_arbitration_holdoff_internal = cpu_0_jtag_debug_module_begins_xfer & cpu_0_jtag_debug_module_firsttransfer;

  //cpu_0_jtag_debug_module_write assignment, which is an e_mux
  assign cpu_0_jtag_debug_module_write = cpu_0_data_master_granted_cpu_0_jtag_debug_module & cpu_0_data_master_write;

  assign shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //cpu_0_jtag_debug_module_address mux, which is an e_mux
  assign cpu_0_jtag_debug_module_address = (cpu_0_data_master_granted_cpu_0_jtag_debug_module)? (shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master >> 2) :
    (shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master >> 2);

  assign shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master = cpu_0_instruction_master_address_to_slave;
  //d1_cpu_0_jtag_debug_module_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_cpu_0_jtag_debug_module_end_xfer <= 1;
      else 
        d1_cpu_0_jtag_debug_module_end_xfer <= cpu_0_jtag_debug_module_end_xfer;
    end


  //cpu_0_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  assign cpu_0_jtag_debug_module_waits_for_read = cpu_0_jtag_debug_module_in_a_read_cycle & cpu_0_jtag_debug_module_begins_xfer;

  //cpu_0_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  assign cpu_0_jtag_debug_module_in_a_read_cycle = (cpu_0_data_master_granted_cpu_0_jtag_debug_module & cpu_0_data_master_read) | (cpu_0_instruction_master_granted_cpu_0_jtag_debug_module & cpu_0_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = cpu_0_jtag_debug_module_in_a_read_cycle;

  //cpu_0_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  assign cpu_0_jtag_debug_module_waits_for_write = cpu_0_jtag_debug_module_in_a_write_cycle & 0;

  //cpu_0_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  assign cpu_0_jtag_debug_module_in_a_write_cycle = cpu_0_data_master_granted_cpu_0_jtag_debug_module & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = cpu_0_jtag_debug_module_in_a_write_cycle;

  assign wait_for_cpu_0_jtag_debug_module_counter = 0;
  //cpu_0_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  assign cpu_0_jtag_debug_module_byteenable = (cpu_0_data_master_granted_cpu_0_jtag_debug_module)? cpu_0_data_master_byteenable :
    -1;

  //debugaccess mux, which is an e_mux
  assign cpu_0_jtag_debug_module_debugaccess = (cpu_0_data_master_granted_cpu_0_jtag_debug_module)? cpu_0_data_master_debugaccess :
    0;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_0/jtag_debug_module enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_granted_cpu_0_jtag_debug_module + cpu_0_instruction_master_granted_cpu_0_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module + cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_0_data_master_arbitrator (
                                      // inputs:
                                       UART2DPRAM_s1_readdata_from_sa,
                                       WRaddress_s1_readdata_from_sa,
                                       clk,
                                       cpu_0_data_master_address,
                                       cpu_0_data_master_byteenable_sdram_0_s1,
                                       cpu_0_data_master_granted_UART2DPRAM_s1,
                                       cpu_0_data_master_granted_WRaddress_s1,
                                       cpu_0_data_master_granted_cpu_0_jtag_debug_module,
                                       cpu_0_data_master_granted_dpram_rdclk_en_s1,
                                       cpu_0_data_master_granted_dpram_wr_en_s1,
                                       cpu_0_data_master_granted_dpram_wrclk_en_s1,
                                       cpu_0_data_master_granted_dpram_wrclk_s1,
                                       cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port,
                                       cpu_0_data_master_granted_freq_word_s1,
                                       cpu_0_data_master_granted_sdram_0_s1,
                                       cpu_0_data_master_granted_uart_0_s1,
                                       cpu_0_data_master_qualified_request_UART2DPRAM_s1,
                                       cpu_0_data_master_qualified_request_WRaddress_s1,
                                       cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
                                       cpu_0_data_master_qualified_request_dpram_rdclk_en_s1,
                                       cpu_0_data_master_qualified_request_dpram_wr_en_s1,
                                       cpu_0_data_master_qualified_request_dpram_wrclk_en_s1,
                                       cpu_0_data_master_qualified_request_dpram_wrclk_s1,
                                       cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
                                       cpu_0_data_master_qualified_request_freq_word_s1,
                                       cpu_0_data_master_qualified_request_sdram_0_s1,
                                       cpu_0_data_master_qualified_request_uart_0_s1,
                                       cpu_0_data_master_read,
                                       cpu_0_data_master_read_data_valid_UART2DPRAM_s1,
                                       cpu_0_data_master_read_data_valid_WRaddress_s1,
                                       cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
                                       cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1,
                                       cpu_0_data_master_read_data_valid_dpram_wr_en_s1,
                                       cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1,
                                       cpu_0_data_master_read_data_valid_dpram_wrclk_s1,
                                       cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
                                       cpu_0_data_master_read_data_valid_freq_word_s1,
                                       cpu_0_data_master_read_data_valid_sdram_0_s1,
                                       cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register,
                                       cpu_0_data_master_read_data_valid_uart_0_s1,
                                       cpu_0_data_master_requests_UART2DPRAM_s1,
                                       cpu_0_data_master_requests_WRaddress_s1,
                                       cpu_0_data_master_requests_cpu_0_jtag_debug_module,
                                       cpu_0_data_master_requests_dpram_rdclk_en_s1,
                                       cpu_0_data_master_requests_dpram_wr_en_s1,
                                       cpu_0_data_master_requests_dpram_wrclk_en_s1,
                                       cpu_0_data_master_requests_dpram_wrclk_s1,
                                       cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port,
                                       cpu_0_data_master_requests_freq_word_s1,
                                       cpu_0_data_master_requests_sdram_0_s1,
                                       cpu_0_data_master_requests_uart_0_s1,
                                       cpu_0_data_master_write,
                                       cpu_0_data_master_writedata,
                                       cpu_0_jtag_debug_module_readdata_from_sa,
                                       d1_UART2DPRAM_s1_end_xfer,
                                       d1_WRaddress_s1_end_xfer,
                                       d1_cpu_0_jtag_debug_module_end_xfer,
                                       d1_dpram_rdclk_en_s1_end_xfer,
                                       d1_dpram_wr_en_s1_end_xfer,
                                       d1_dpram_wrclk_en_s1_end_xfer,
                                       d1_dpram_wrclk_s1_end_xfer,
                                       d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
                                       d1_freq_word_s1_end_xfer,
                                       d1_sdram_0_s1_end_xfer,
                                       d1_uart_0_s1_end_xfer,
                                       dpram_rdclk_en_s1_readdata_from_sa,
                                       dpram_wr_en_s1_readdata_from_sa,
                                       dpram_wrclk_en_s1_readdata_from_sa,
                                       dpram_wrclk_s1_readdata_from_sa,
                                       epcs_flash_controller_0_epcs_control_port_irq_from_sa,
                                       epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
                                       freq_word_s1_readdata_from_sa,
                                       reset_n,
                                       sdram_0_s1_readdata_from_sa,
                                       sdram_0_s1_waitrequest_from_sa,
                                       uart_0_s1_irq_from_sa,
                                       uart_0_s1_readdata_from_sa,

                                      // outputs:
                                       cpu_0_data_master_address_to_slave,
                                       cpu_0_data_master_dbs_address,
                                       cpu_0_data_master_dbs_write_16,
                                       cpu_0_data_master_irq,
                                       cpu_0_data_master_no_byte_enables_and_last_term,
                                       cpu_0_data_master_readdata,
                                       cpu_0_data_master_waitrequest
                                    )
;

  output  [ 24: 0] cpu_0_data_master_address_to_slave;
  output  [  1: 0] cpu_0_data_master_dbs_address;
  output  [ 15: 0] cpu_0_data_master_dbs_write_16;
  output  [ 31: 0] cpu_0_data_master_irq;
  output           cpu_0_data_master_no_byte_enables_and_last_term;
  output  [ 31: 0] cpu_0_data_master_readdata;
  output           cpu_0_data_master_waitrequest;
  input   [ 11: 0] UART2DPRAM_s1_readdata_from_sa;
  input   [  9: 0] WRaddress_s1_readdata_from_sa;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address;
  input   [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1;
  input            cpu_0_data_master_granted_UART2DPRAM_s1;
  input            cpu_0_data_master_granted_WRaddress_s1;
  input            cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  input            cpu_0_data_master_granted_dpram_rdclk_en_s1;
  input            cpu_0_data_master_granted_dpram_wr_en_s1;
  input            cpu_0_data_master_granted_dpram_wrclk_en_s1;
  input            cpu_0_data_master_granted_dpram_wrclk_s1;
  input            cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_data_master_granted_freq_word_s1;
  input            cpu_0_data_master_granted_sdram_0_s1;
  input            cpu_0_data_master_granted_uart_0_s1;
  input            cpu_0_data_master_qualified_request_UART2DPRAM_s1;
  input            cpu_0_data_master_qualified_request_WRaddress_s1;
  input            cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  input            cpu_0_data_master_qualified_request_dpram_rdclk_en_s1;
  input            cpu_0_data_master_qualified_request_dpram_wr_en_s1;
  input            cpu_0_data_master_qualified_request_dpram_wrclk_en_s1;
  input            cpu_0_data_master_qualified_request_dpram_wrclk_s1;
  input            cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_data_master_qualified_request_freq_word_s1;
  input            cpu_0_data_master_qualified_request_sdram_0_s1;
  input            cpu_0_data_master_qualified_request_uart_0_s1;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_read_data_valid_UART2DPRAM_s1;
  input            cpu_0_data_master_read_data_valid_WRaddress_s1;
  input            cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module;
  input            cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1;
  input            cpu_0_data_master_read_data_valid_dpram_wr_en_s1;
  input            cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1;
  input            cpu_0_data_master_read_data_valid_dpram_wrclk_s1;
  input            cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_data_master_read_data_valid_freq_word_s1;
  input            cpu_0_data_master_read_data_valid_sdram_0_s1;
  input            cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register;
  input            cpu_0_data_master_read_data_valid_uart_0_s1;
  input            cpu_0_data_master_requests_UART2DPRAM_s1;
  input            cpu_0_data_master_requests_WRaddress_s1;
  input            cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  input            cpu_0_data_master_requests_dpram_rdclk_en_s1;
  input            cpu_0_data_master_requests_dpram_wr_en_s1;
  input            cpu_0_data_master_requests_dpram_wrclk_en_s1;
  input            cpu_0_data_master_requests_dpram_wrclk_s1;
  input            cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_data_master_requests_freq_word_s1;
  input            cpu_0_data_master_requests_sdram_0_s1;
  input            cpu_0_data_master_requests_uart_0_s1;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input   [ 31: 0] cpu_0_jtag_debug_module_readdata_from_sa;
  input            d1_UART2DPRAM_s1_end_xfer;
  input            d1_WRaddress_s1_end_xfer;
  input            d1_cpu_0_jtag_debug_module_end_xfer;
  input            d1_dpram_rdclk_en_s1_end_xfer;
  input            d1_dpram_wr_en_s1_end_xfer;
  input            d1_dpram_wrclk_en_s1_end_xfer;
  input            d1_dpram_wrclk_s1_end_xfer;
  input            d1_epcs_flash_controller_0_epcs_control_port_end_xfer;
  input            d1_freq_word_s1_end_xfer;
  input            d1_sdram_0_s1_end_xfer;
  input            d1_uart_0_s1_end_xfer;
  input            dpram_rdclk_en_s1_readdata_from_sa;
  input            dpram_wr_en_s1_readdata_from_sa;
  input            dpram_wrclk_en_s1_readdata_from_sa;
  input            dpram_wrclk_s1_readdata_from_sa;
  input            epcs_flash_controller_0_epcs_control_port_irq_from_sa;
  input   [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata_from_sa;
  input   [ 22: 0] freq_word_s1_readdata_from_sa;
  input            reset_n;
  input   [ 15: 0] sdram_0_s1_readdata_from_sa;
  input            sdram_0_s1_waitrequest_from_sa;
  input            uart_0_s1_irq_from_sa;
  input   [ 15: 0] uart_0_s1_readdata_from_sa;

  wire    [ 24: 0] cpu_0_data_master_address_to_slave;
  reg     [  1: 0] cpu_0_data_master_dbs_address;
  wire    [  1: 0] cpu_0_data_master_dbs_increment;
  wire    [ 15: 0] cpu_0_data_master_dbs_write_16;
  wire    [ 31: 0] cpu_0_data_master_irq;
  reg              cpu_0_data_master_no_byte_enables_and_last_term;
  wire    [ 31: 0] cpu_0_data_master_readdata;
  wire             cpu_0_data_master_run;
  reg              cpu_0_data_master_waitrequest;
  reg     [ 15: 0] dbs_16_reg_segment_0;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  wire             last_dbs_term_and_run;
  wire    [  1: 0] next_dbs_address;
  wire    [ 15: 0] p1_dbs_16_reg_segment_0;
  wire    [ 31: 0] p1_registered_cpu_0_data_master_readdata;
  wire             pre_dbs_count_enable;
  wire             r_0;
  wire             r_1;
  wire             r_2;
  reg     [ 31: 0] registered_cpu_0_data_master_readdata;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_0_data_master_qualified_request_UART2DPRAM_s1 | ~cpu_0_data_master_requests_UART2DPRAM_s1) & ((~cpu_0_data_master_qualified_request_UART2DPRAM_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_UART2DPRAM_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_WRaddress_s1 | ~cpu_0_data_master_requests_WRaddress_s1) & ((~cpu_0_data_master_qualified_request_WRaddress_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_WRaddress_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module | ~cpu_0_data_master_requests_cpu_0_jtag_debug_module) & (cpu_0_data_master_granted_cpu_0_jtag_debug_module | ~cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module) & ((~cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_dpram_rdclk_en_s1 | ~cpu_0_data_master_requests_dpram_rdclk_en_s1) & ((~cpu_0_data_master_qualified_request_dpram_rdclk_en_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_dpram_rdclk_en_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_dpram_wr_en_s1 | ~cpu_0_data_master_requests_dpram_wr_en_s1) & ((~cpu_0_data_master_qualified_request_dpram_wr_en_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read)));

  //cascaded wait assignment, which is an e_assign
  assign cpu_0_data_master_run = r_0 & r_1 & r_2;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = ((~cpu_0_data_master_qualified_request_dpram_wr_en_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_dpram_wrclk_s1 | ~cpu_0_data_master_requests_dpram_wrclk_s1) & ((~cpu_0_data_master_qualified_request_dpram_wrclk_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_dpram_wrclk_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_dpram_wrclk_en_s1 | ~cpu_0_data_master_requests_dpram_wrclk_en_s1) & ((~cpu_0_data_master_qualified_request_dpram_wrclk_en_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_dpram_wrclk_en_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port | ~cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port) & (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port | ~cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port) & ((~cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port | ~(cpu_0_data_master_read | cpu_0_data_master_write) | (1 & 1 & (cpu_0_data_master_read | cpu_0_data_master_write)))) & ((~cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port | ~(cpu_0_data_master_read | cpu_0_data_master_write) | (1 & 1 & (cpu_0_data_master_read | cpu_0_data_master_write)))) & 1 & (cpu_0_data_master_qualified_request_freq_word_s1 | ~cpu_0_data_master_requests_freq_word_s1) & ((~cpu_0_data_master_qualified_request_freq_word_s1 | ~cpu_0_data_master_read | (1 & 1 & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_freq_word_s1 | ~cpu_0_data_master_write | (1 & cpu_0_data_master_write))) & 1 & (cpu_0_data_master_qualified_request_sdram_0_s1 | (cpu_0_data_master_read_data_valid_sdram_0_s1 & cpu_0_data_master_dbs_address[1]) | (cpu_0_data_master_write & !cpu_0_data_master_byteenable_sdram_0_s1 & cpu_0_data_master_dbs_address[1]) | ~cpu_0_data_master_requests_sdram_0_s1);

  //r_2 master_run cascaded wait assignment, which is an e_assign
  assign r_2 = (cpu_0_data_master_granted_sdram_0_s1 | ~cpu_0_data_master_qualified_request_sdram_0_s1) & ((~cpu_0_data_master_qualified_request_sdram_0_s1 | ~cpu_0_data_master_read | (cpu_0_data_master_read_data_valid_sdram_0_s1 & (cpu_0_data_master_dbs_address[1]) & cpu_0_data_master_read))) & ((~cpu_0_data_master_qualified_request_sdram_0_s1 | ~cpu_0_data_master_write | (1 & ~sdram_0_s1_waitrequest_from_sa & (cpu_0_data_master_dbs_address[1]) & cpu_0_data_master_write))) & 1 & ((~cpu_0_data_master_qualified_request_uart_0_s1 | ~(cpu_0_data_master_read | cpu_0_data_master_write) | (1 & 1 & (cpu_0_data_master_read | cpu_0_data_master_write)))) & ((~cpu_0_data_master_qualified_request_uart_0_s1 | ~(cpu_0_data_master_read | cpu_0_data_master_write) | (1 & 1 & (cpu_0_data_master_read | cpu_0_data_master_write))));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_0_data_master_address_to_slave = cpu_0_data_master_address[24 : 0];

  //cpu_0/data_master readdata mux, which is an e_mux
  assign cpu_0_data_master_readdata = ({32 {~cpu_0_data_master_requests_UART2DPRAM_s1}} | UART2DPRAM_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_WRaddress_s1}} | WRaddress_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_cpu_0_jtag_debug_module}} | cpu_0_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_dpram_rdclk_en_s1}} | dpram_rdclk_en_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_dpram_wr_en_s1}} | dpram_wr_en_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_dpram_wrclk_s1}} | dpram_wrclk_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_dpram_wrclk_en_s1}} | dpram_wrclk_en_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port}} | epcs_flash_controller_0_epcs_control_port_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_freq_word_s1}} | freq_word_s1_readdata_from_sa) &
    ({32 {~cpu_0_data_master_requests_sdram_0_s1}} | registered_cpu_0_data_master_readdata) &
    ({32 {~cpu_0_data_master_requests_uart_0_s1}} | uart_0_s1_readdata_from_sa);

  //actual waitrequest port, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_data_master_waitrequest <= ~0;
      else 
        cpu_0_data_master_waitrequest <= ~((~(cpu_0_data_master_read | cpu_0_data_master_write))? 0: (cpu_0_data_master_run & cpu_0_data_master_waitrequest));
    end


  //irq assign, which is an e_assign
  assign cpu_0_data_master_irq = {1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    1'b0,
    epcs_flash_controller_0_epcs_control_port_irq_from_sa,
    uart_0_s1_irq_from_sa};

  //no_byte_enables_and_last_term, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_data_master_no_byte_enables_and_last_term <= 0;
      else 
        cpu_0_data_master_no_byte_enables_and_last_term <= last_dbs_term_and_run;
    end


  //compute the last dbs term, which is an e_mux
  assign last_dbs_term_and_run = (cpu_0_data_master_dbs_address == 2'b10) & cpu_0_data_master_write & !cpu_0_data_master_byteenable_sdram_0_s1;

  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = (((~cpu_0_data_master_no_byte_enables_and_last_term) & cpu_0_data_master_requests_sdram_0_s1 & cpu_0_data_master_write & !cpu_0_data_master_byteenable_sdram_0_s1)) |
    cpu_0_data_master_read_data_valid_sdram_0_s1 |
    (cpu_0_data_master_granted_sdram_0_s1 & cpu_0_data_master_write & 1 & 1 & ~sdram_0_s1_waitrequest_from_sa);

  //input to dbs-16 stored 0, which is an e_mux
  assign p1_dbs_16_reg_segment_0 = sdram_0_s1_readdata_from_sa;

  //dbs register for dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_16_reg_segment_0 <= 0;
      else if (dbs_count_enable & ((cpu_0_data_master_dbs_address[1]) == 0))
          dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
    end


  //unpredictable registered wait state incoming data, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          registered_cpu_0_data_master_readdata <= 0;
      else 
        registered_cpu_0_data_master_readdata <= p1_registered_cpu_0_data_master_readdata;
    end


  //registered readdata mux, which is an e_mux
  assign p1_registered_cpu_0_data_master_readdata = {32 {~cpu_0_data_master_requests_sdram_0_s1}} | {sdram_0_s1_readdata_from_sa[15 : 0],
    dbs_16_reg_segment_0};

  //mux write dbs 1, which is an e_mux
  assign cpu_0_data_master_dbs_write_16 = (cpu_0_data_master_dbs_address[1])? cpu_0_data_master_writedata[31 : 16] :
    cpu_0_data_master_writedata[15 : 0];

  //dbs count increment, which is an e_mux
  assign cpu_0_data_master_dbs_increment = (cpu_0_data_master_requests_sdram_0_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_0_data_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_0_data_master_dbs_address + cpu_0_data_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable &
    (~(cpu_0_data_master_requests_sdram_0_s1 & ~cpu_0_data_master_waitrequest));

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_data_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_0_data_master_dbs_address <= next_dbs_address;
    end



endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module cpu_0_instruction_master_arbitrator (
                                             // inputs:
                                              clk,
                                              cpu_0_instruction_master_address,
                                              cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
                                              cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
                                              cpu_0_instruction_master_granted_sdram_0_s1,
                                              cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
                                              cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
                                              cpu_0_instruction_master_qualified_request_sdram_0_s1,
                                              cpu_0_instruction_master_read,
                                              cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
                                              cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
                                              cpu_0_instruction_master_read_data_valid_sdram_0_s1,
                                              cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register,
                                              cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
                                              cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
                                              cpu_0_instruction_master_requests_sdram_0_s1,
                                              cpu_0_jtag_debug_module_readdata_from_sa,
                                              d1_cpu_0_jtag_debug_module_end_xfer,
                                              d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
                                              d1_sdram_0_s1_end_xfer,
                                              epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
                                              reset_n,
                                              sdram_0_s1_readdata_from_sa,
                                              sdram_0_s1_waitrequest_from_sa,

                                             // outputs:
                                              cpu_0_instruction_master_address_to_slave,
                                              cpu_0_instruction_master_dbs_address,
                                              cpu_0_instruction_master_readdata,
                                              cpu_0_instruction_master_waitrequest
                                           )
;

  output  [ 24: 0] cpu_0_instruction_master_address_to_slave;
  output  [  1: 0] cpu_0_instruction_master_dbs_address;
  output  [ 31: 0] cpu_0_instruction_master_readdata;
  output           cpu_0_instruction_master_waitrequest;
  input            clk;
  input   [ 24: 0] cpu_0_instruction_master_address;
  input            cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  input            cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_instruction_master_granted_sdram_0_s1;
  input            cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  input            cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_instruction_master_qualified_request_sdram_0_s1;
  input            cpu_0_instruction_master_read;
  input            cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module;
  input            cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_instruction_master_read_data_valid_sdram_0_s1;
  input            cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register;
  input            cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  input            cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  input            cpu_0_instruction_master_requests_sdram_0_s1;
  input   [ 31: 0] cpu_0_jtag_debug_module_readdata_from_sa;
  input            d1_cpu_0_jtag_debug_module_end_xfer;
  input            d1_epcs_flash_controller_0_epcs_control_port_end_xfer;
  input            d1_sdram_0_s1_end_xfer;
  input   [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata_from_sa;
  input            reset_n;
  input   [ 15: 0] sdram_0_s1_readdata_from_sa;
  input            sdram_0_s1_waitrequest_from_sa;

  reg              active_and_waiting_last_time;
  reg     [ 24: 0] cpu_0_instruction_master_address_last_time;
  wire    [ 24: 0] cpu_0_instruction_master_address_to_slave;
  reg     [  1: 0] cpu_0_instruction_master_dbs_address;
  wire    [  1: 0] cpu_0_instruction_master_dbs_increment;
  reg              cpu_0_instruction_master_read_last_time;
  wire    [ 31: 0] cpu_0_instruction_master_readdata;
  wire             cpu_0_instruction_master_run;
  wire             cpu_0_instruction_master_waitrequest;
  reg     [ 15: 0] dbs_16_reg_segment_0;
  wire             dbs_count_enable;
  wire             dbs_counter_overflow;
  wire    [  1: 0] next_dbs_address;
  wire    [ 15: 0] p1_dbs_16_reg_segment_0;
  wire             pre_dbs_count_enable;
  wire             r_0;
  wire             r_1;
  wire             r_2;
  //r_0 master_run cascaded wait assignment, which is an e_assign
  assign r_0 = 1 & (cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module | ~cpu_0_instruction_master_requests_cpu_0_jtag_debug_module) & (cpu_0_instruction_master_granted_cpu_0_jtag_debug_module | ~cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module) & ((~cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module | ~cpu_0_instruction_master_read | (1 & ~d1_cpu_0_jtag_debug_module_end_xfer & cpu_0_instruction_master_read)));

  //cascaded wait assignment, which is an e_assign
  assign cpu_0_instruction_master_run = r_0 & r_1 & r_2;

  //r_1 master_run cascaded wait assignment, which is an e_assign
  assign r_1 = 1 & (cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port | ~cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port) & (cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port | ~cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port) & ((~cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port | ~(cpu_0_instruction_master_read) | (1 & ~d1_epcs_flash_controller_0_epcs_control_port_end_xfer & (cpu_0_instruction_master_read))));

  //r_2 master_run cascaded wait assignment, which is an e_assign
  assign r_2 = 1 & (cpu_0_instruction_master_qualified_request_sdram_0_s1 | (cpu_0_instruction_master_read_data_valid_sdram_0_s1 & cpu_0_instruction_master_dbs_address[1]) | ~cpu_0_instruction_master_requests_sdram_0_s1) & (cpu_0_instruction_master_granted_sdram_0_s1 | ~cpu_0_instruction_master_qualified_request_sdram_0_s1) & ((~cpu_0_instruction_master_qualified_request_sdram_0_s1 | ~cpu_0_instruction_master_read | (cpu_0_instruction_master_read_data_valid_sdram_0_s1 & (cpu_0_instruction_master_dbs_address[1]) & cpu_0_instruction_master_read)));

  //optimize select-logic by passing only those address bits which matter.
  assign cpu_0_instruction_master_address_to_slave = cpu_0_instruction_master_address[24 : 0];

  //cpu_0/instruction_master readdata mux, which is an e_mux
  assign cpu_0_instruction_master_readdata = ({32 {~cpu_0_instruction_master_requests_cpu_0_jtag_debug_module}} | cpu_0_jtag_debug_module_readdata_from_sa) &
    ({32 {~cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port}} | epcs_flash_controller_0_epcs_control_port_readdata_from_sa) &
    ({32 {~cpu_0_instruction_master_requests_sdram_0_s1}} | {sdram_0_s1_readdata_from_sa[15 : 0],
    dbs_16_reg_segment_0});

  //actual waitrequest port, which is an e_assign
  assign cpu_0_instruction_master_waitrequest = ~cpu_0_instruction_master_run;

  //input to dbs-16 stored 0, which is an e_mux
  assign p1_dbs_16_reg_segment_0 = sdram_0_s1_readdata_from_sa;

  //dbs register for dbs-16 segment 0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dbs_16_reg_segment_0 <= 0;
      else if (dbs_count_enable & ((cpu_0_instruction_master_dbs_address[1]) == 0))
          dbs_16_reg_segment_0 <= p1_dbs_16_reg_segment_0;
    end


  //dbs count increment, which is an e_mux
  assign cpu_0_instruction_master_dbs_increment = (cpu_0_instruction_master_requests_sdram_0_s1)? 2 :
    0;

  //dbs counter overflow, which is an e_assign
  assign dbs_counter_overflow = cpu_0_instruction_master_dbs_address[1] & !(next_dbs_address[1]);

  //next master address, which is an e_assign
  assign next_dbs_address = cpu_0_instruction_master_dbs_address + cpu_0_instruction_master_dbs_increment;

  //dbs count enable, which is an e_mux
  assign dbs_count_enable = pre_dbs_count_enable;

  //dbs counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_instruction_master_dbs_address <= 0;
      else if (dbs_count_enable)
          cpu_0_instruction_master_dbs_address <= next_dbs_address;
    end


  //pre dbs count enable, which is an e_mux
  assign pre_dbs_count_enable = cpu_0_instruction_master_read_data_valid_sdram_0_s1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //cpu_0_instruction_master_address check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_instruction_master_address_last_time <= 0;
      else 
        cpu_0_instruction_master_address_last_time <= cpu_0_instruction_master_address;
    end


  //cpu_0/instruction_master waited last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          active_and_waiting_last_time <= 0;
      else 
        active_and_waiting_last_time <= cpu_0_instruction_master_waitrequest & (cpu_0_instruction_master_read);
    end


  //cpu_0_instruction_master_address matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_0_instruction_master_address != cpu_0_instruction_master_address_last_time))
        begin
          $write("%0d ns: cpu_0_instruction_master_address did not heed wait!!!", $time);
          $stop;
        end
    end


  //cpu_0_instruction_master_read check against wait, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          cpu_0_instruction_master_read_last_time <= 0;
      else 
        cpu_0_instruction_master_read_last_time <= cpu_0_instruction_master_read;
    end


  //cpu_0_instruction_master_read matches last port_name, which is an e_process
  always @(posedge clk)
    begin
      if (active_and_waiting_last_time & (cpu_0_instruction_master_read != cpu_0_instruction_master_read_last_time))
        begin
          $write("%0d ns: cpu_0_instruction_master_read did not heed wait!!!", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module dpram_rdclk_en_s1_arbitrator (
                                      // inputs:
                                       clk,
                                       cpu_0_data_master_address_to_slave,
                                       cpu_0_data_master_read,
                                       cpu_0_data_master_waitrequest,
                                       cpu_0_data_master_write,
                                       cpu_0_data_master_writedata,
                                       dpram_rdclk_en_s1_readdata,
                                       reset_n,

                                      // outputs:
                                       cpu_0_data_master_granted_dpram_rdclk_en_s1,
                                       cpu_0_data_master_qualified_request_dpram_rdclk_en_s1,
                                       cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1,
                                       cpu_0_data_master_requests_dpram_rdclk_en_s1,
                                       d1_dpram_rdclk_en_s1_end_xfer,
                                       dpram_rdclk_en_s1_address,
                                       dpram_rdclk_en_s1_chipselect,
                                       dpram_rdclk_en_s1_readdata_from_sa,
                                       dpram_rdclk_en_s1_reset_n,
                                       dpram_rdclk_en_s1_write_n,
                                       dpram_rdclk_en_s1_writedata
                                    )
;

  output           cpu_0_data_master_granted_dpram_rdclk_en_s1;
  output           cpu_0_data_master_qualified_request_dpram_rdclk_en_s1;
  output           cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1;
  output           cpu_0_data_master_requests_dpram_rdclk_en_s1;
  output           d1_dpram_rdclk_en_s1_end_xfer;
  output  [  1: 0] dpram_rdclk_en_s1_address;
  output           dpram_rdclk_en_s1_chipselect;
  output           dpram_rdclk_en_s1_readdata_from_sa;
  output           dpram_rdclk_en_s1_reset_n;
  output           dpram_rdclk_en_s1_write_n;
  output           dpram_rdclk_en_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            dpram_rdclk_en_s1_readdata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_requests_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_saved_grant_dpram_rdclk_en_s1;
  reg              d1_dpram_rdclk_en_s1_end_xfer;
  reg              d1_reasons_to_wait;
  wire    [  1: 0] dpram_rdclk_en_s1_address;
  wire             dpram_rdclk_en_s1_allgrants;
  wire             dpram_rdclk_en_s1_allow_new_arb_cycle;
  wire             dpram_rdclk_en_s1_any_bursting_master_saved_grant;
  wire             dpram_rdclk_en_s1_any_continuerequest;
  wire             dpram_rdclk_en_s1_arb_counter_enable;
  reg     [  1: 0] dpram_rdclk_en_s1_arb_share_counter;
  wire    [  1: 0] dpram_rdclk_en_s1_arb_share_counter_next_value;
  wire    [  1: 0] dpram_rdclk_en_s1_arb_share_set_values;
  wire             dpram_rdclk_en_s1_beginbursttransfer_internal;
  wire             dpram_rdclk_en_s1_begins_xfer;
  wire             dpram_rdclk_en_s1_chipselect;
  wire             dpram_rdclk_en_s1_end_xfer;
  wire             dpram_rdclk_en_s1_firsttransfer;
  wire             dpram_rdclk_en_s1_grant_vector;
  wire             dpram_rdclk_en_s1_in_a_read_cycle;
  wire             dpram_rdclk_en_s1_in_a_write_cycle;
  wire             dpram_rdclk_en_s1_master_qreq_vector;
  wire             dpram_rdclk_en_s1_non_bursting_master_requests;
  wire             dpram_rdclk_en_s1_readdata_from_sa;
  reg              dpram_rdclk_en_s1_reg_firsttransfer;
  wire             dpram_rdclk_en_s1_reset_n;
  reg              dpram_rdclk_en_s1_slavearbiterlockenable;
  wire             dpram_rdclk_en_s1_slavearbiterlockenable2;
  wire             dpram_rdclk_en_s1_unreg_firsttransfer;
  wire             dpram_rdclk_en_s1_waits_for_read;
  wire             dpram_rdclk_en_s1_waits_for_write;
  wire             dpram_rdclk_en_s1_write_n;
  wire             dpram_rdclk_en_s1_writedata;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_dpram_rdclk_en_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_dpram_rdclk_en_s1_from_cpu_0_data_master;
  wire             wait_for_dpram_rdclk_en_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~dpram_rdclk_en_s1_end_xfer;
    end


  assign dpram_rdclk_en_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_dpram_rdclk_en_s1));
  //assign dpram_rdclk_en_s1_readdata_from_sa = dpram_rdclk_en_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign dpram_rdclk_en_s1_readdata_from_sa = dpram_rdclk_en_s1_readdata;

  assign cpu_0_data_master_requests_dpram_rdclk_en_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002080) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //dpram_rdclk_en_s1_arb_share_counter set values, which is an e_mux
  assign dpram_rdclk_en_s1_arb_share_set_values = 1;

  //dpram_rdclk_en_s1_non_bursting_master_requests mux, which is an e_mux
  assign dpram_rdclk_en_s1_non_bursting_master_requests = cpu_0_data_master_requests_dpram_rdclk_en_s1;

  //dpram_rdclk_en_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign dpram_rdclk_en_s1_any_bursting_master_saved_grant = 0;

  //dpram_rdclk_en_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign dpram_rdclk_en_s1_arb_share_counter_next_value = dpram_rdclk_en_s1_firsttransfer ? (dpram_rdclk_en_s1_arb_share_set_values - 1) : |dpram_rdclk_en_s1_arb_share_counter ? (dpram_rdclk_en_s1_arb_share_counter - 1) : 0;

  //dpram_rdclk_en_s1_allgrants all slave grants, which is an e_mux
  assign dpram_rdclk_en_s1_allgrants = |dpram_rdclk_en_s1_grant_vector;

  //dpram_rdclk_en_s1_end_xfer assignment, which is an e_assign
  assign dpram_rdclk_en_s1_end_xfer = ~(dpram_rdclk_en_s1_waits_for_read | dpram_rdclk_en_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_dpram_rdclk_en_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_dpram_rdclk_en_s1 = dpram_rdclk_en_s1_end_xfer & (~dpram_rdclk_en_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //dpram_rdclk_en_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign dpram_rdclk_en_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_dpram_rdclk_en_s1 & dpram_rdclk_en_s1_allgrants) | (end_xfer_arb_share_counter_term_dpram_rdclk_en_s1 & ~dpram_rdclk_en_s1_non_bursting_master_requests);

  //dpram_rdclk_en_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_rdclk_en_s1_arb_share_counter <= 0;
      else if (dpram_rdclk_en_s1_arb_counter_enable)
          dpram_rdclk_en_s1_arb_share_counter <= dpram_rdclk_en_s1_arb_share_counter_next_value;
    end


  //dpram_rdclk_en_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_rdclk_en_s1_slavearbiterlockenable <= 0;
      else if ((|dpram_rdclk_en_s1_master_qreq_vector & end_xfer_arb_share_counter_term_dpram_rdclk_en_s1) | (end_xfer_arb_share_counter_term_dpram_rdclk_en_s1 & ~dpram_rdclk_en_s1_non_bursting_master_requests))
          dpram_rdclk_en_s1_slavearbiterlockenable <= |dpram_rdclk_en_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master dpram_rdclk_en/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = dpram_rdclk_en_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //dpram_rdclk_en_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign dpram_rdclk_en_s1_slavearbiterlockenable2 = |dpram_rdclk_en_s1_arb_share_counter_next_value;

  //cpu_0/data_master dpram_rdclk_en/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = dpram_rdclk_en_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //dpram_rdclk_en_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign dpram_rdclk_en_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_dpram_rdclk_en_s1 = cpu_0_data_master_requests_dpram_rdclk_en_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //dpram_rdclk_en_s1_writedata mux, which is an e_mux
  assign dpram_rdclk_en_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_dpram_rdclk_en_s1 = cpu_0_data_master_qualified_request_dpram_rdclk_en_s1;

  //cpu_0/data_master saved-grant dpram_rdclk_en/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_dpram_rdclk_en_s1 = cpu_0_data_master_requests_dpram_rdclk_en_s1;

  //allow new arb cycle for dpram_rdclk_en/s1, which is an e_assign
  assign dpram_rdclk_en_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign dpram_rdclk_en_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign dpram_rdclk_en_s1_master_qreq_vector = 1;

  //dpram_rdclk_en_s1_reset_n assignment, which is an e_assign
  assign dpram_rdclk_en_s1_reset_n = reset_n;

  assign dpram_rdclk_en_s1_chipselect = cpu_0_data_master_granted_dpram_rdclk_en_s1;
  //dpram_rdclk_en_s1_firsttransfer first transaction, which is an e_assign
  assign dpram_rdclk_en_s1_firsttransfer = dpram_rdclk_en_s1_begins_xfer ? dpram_rdclk_en_s1_unreg_firsttransfer : dpram_rdclk_en_s1_reg_firsttransfer;

  //dpram_rdclk_en_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign dpram_rdclk_en_s1_unreg_firsttransfer = ~(dpram_rdclk_en_s1_slavearbiterlockenable & dpram_rdclk_en_s1_any_continuerequest);

  //dpram_rdclk_en_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_rdclk_en_s1_reg_firsttransfer <= 1'b1;
      else if (dpram_rdclk_en_s1_begins_xfer)
          dpram_rdclk_en_s1_reg_firsttransfer <= dpram_rdclk_en_s1_unreg_firsttransfer;
    end


  //dpram_rdclk_en_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign dpram_rdclk_en_s1_beginbursttransfer_internal = dpram_rdclk_en_s1_begins_xfer;

  //~dpram_rdclk_en_s1_write_n assignment, which is an e_mux
  assign dpram_rdclk_en_s1_write_n = ~(cpu_0_data_master_granted_dpram_rdclk_en_s1 & cpu_0_data_master_write);

  assign shifted_address_to_dpram_rdclk_en_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //dpram_rdclk_en_s1_address mux, which is an e_mux
  assign dpram_rdclk_en_s1_address = shifted_address_to_dpram_rdclk_en_s1_from_cpu_0_data_master >> 2;

  //d1_dpram_rdclk_en_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_dpram_rdclk_en_s1_end_xfer <= 1;
      else 
        d1_dpram_rdclk_en_s1_end_xfer <= dpram_rdclk_en_s1_end_xfer;
    end


  //dpram_rdclk_en_s1_waits_for_read in a cycle, which is an e_mux
  assign dpram_rdclk_en_s1_waits_for_read = dpram_rdclk_en_s1_in_a_read_cycle & dpram_rdclk_en_s1_begins_xfer;

  //dpram_rdclk_en_s1_in_a_read_cycle assignment, which is an e_assign
  assign dpram_rdclk_en_s1_in_a_read_cycle = cpu_0_data_master_granted_dpram_rdclk_en_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = dpram_rdclk_en_s1_in_a_read_cycle;

  //dpram_rdclk_en_s1_waits_for_write in a cycle, which is an e_mux
  assign dpram_rdclk_en_s1_waits_for_write = dpram_rdclk_en_s1_in_a_write_cycle & 0;

  //dpram_rdclk_en_s1_in_a_write_cycle assignment, which is an e_assign
  assign dpram_rdclk_en_s1_in_a_write_cycle = cpu_0_data_master_granted_dpram_rdclk_en_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = dpram_rdclk_en_s1_in_a_write_cycle;

  assign wait_for_dpram_rdclk_en_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //dpram_rdclk_en/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module dpram_wr_en_s1_arbitrator (
                                   // inputs:
                                    clk,
                                    cpu_0_data_master_address_to_slave,
                                    cpu_0_data_master_read,
                                    cpu_0_data_master_waitrequest,
                                    cpu_0_data_master_write,
                                    cpu_0_data_master_writedata,
                                    dpram_wr_en_s1_readdata,
                                    reset_n,

                                   // outputs:
                                    cpu_0_data_master_granted_dpram_wr_en_s1,
                                    cpu_0_data_master_qualified_request_dpram_wr_en_s1,
                                    cpu_0_data_master_read_data_valid_dpram_wr_en_s1,
                                    cpu_0_data_master_requests_dpram_wr_en_s1,
                                    d1_dpram_wr_en_s1_end_xfer,
                                    dpram_wr_en_s1_address,
                                    dpram_wr_en_s1_chipselect,
                                    dpram_wr_en_s1_readdata_from_sa,
                                    dpram_wr_en_s1_reset_n,
                                    dpram_wr_en_s1_write_n,
                                    dpram_wr_en_s1_writedata
                                 )
;

  output           cpu_0_data_master_granted_dpram_wr_en_s1;
  output           cpu_0_data_master_qualified_request_dpram_wr_en_s1;
  output           cpu_0_data_master_read_data_valid_dpram_wr_en_s1;
  output           cpu_0_data_master_requests_dpram_wr_en_s1;
  output           d1_dpram_wr_en_s1_end_xfer;
  output  [  1: 0] dpram_wr_en_s1_address;
  output           dpram_wr_en_s1_chipselect;
  output           dpram_wr_en_s1_readdata_from_sa;
  output           dpram_wr_en_s1_reset_n;
  output           dpram_wr_en_s1_write_n;
  output           dpram_wr_en_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            dpram_wr_en_s1_readdata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_dpram_wr_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wr_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wr_en_s1;
  wire             cpu_0_data_master_requests_dpram_wr_en_s1;
  wire             cpu_0_data_master_saved_grant_dpram_wr_en_s1;
  reg              d1_dpram_wr_en_s1_end_xfer;
  reg              d1_reasons_to_wait;
  wire    [  1: 0] dpram_wr_en_s1_address;
  wire             dpram_wr_en_s1_allgrants;
  wire             dpram_wr_en_s1_allow_new_arb_cycle;
  wire             dpram_wr_en_s1_any_bursting_master_saved_grant;
  wire             dpram_wr_en_s1_any_continuerequest;
  wire             dpram_wr_en_s1_arb_counter_enable;
  reg     [  1: 0] dpram_wr_en_s1_arb_share_counter;
  wire    [  1: 0] dpram_wr_en_s1_arb_share_counter_next_value;
  wire    [  1: 0] dpram_wr_en_s1_arb_share_set_values;
  wire             dpram_wr_en_s1_beginbursttransfer_internal;
  wire             dpram_wr_en_s1_begins_xfer;
  wire             dpram_wr_en_s1_chipselect;
  wire             dpram_wr_en_s1_end_xfer;
  wire             dpram_wr_en_s1_firsttransfer;
  wire             dpram_wr_en_s1_grant_vector;
  wire             dpram_wr_en_s1_in_a_read_cycle;
  wire             dpram_wr_en_s1_in_a_write_cycle;
  wire             dpram_wr_en_s1_master_qreq_vector;
  wire             dpram_wr_en_s1_non_bursting_master_requests;
  wire             dpram_wr_en_s1_readdata_from_sa;
  reg              dpram_wr_en_s1_reg_firsttransfer;
  wire             dpram_wr_en_s1_reset_n;
  reg              dpram_wr_en_s1_slavearbiterlockenable;
  wire             dpram_wr_en_s1_slavearbiterlockenable2;
  wire             dpram_wr_en_s1_unreg_firsttransfer;
  wire             dpram_wr_en_s1_waits_for_read;
  wire             dpram_wr_en_s1_waits_for_write;
  wire             dpram_wr_en_s1_write_n;
  wire             dpram_wr_en_s1_writedata;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_dpram_wr_en_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_dpram_wr_en_s1_from_cpu_0_data_master;
  wire             wait_for_dpram_wr_en_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~dpram_wr_en_s1_end_xfer;
    end


  assign dpram_wr_en_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_dpram_wr_en_s1));
  //assign dpram_wr_en_s1_readdata_from_sa = dpram_wr_en_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign dpram_wr_en_s1_readdata_from_sa = dpram_wr_en_s1_readdata;

  assign cpu_0_data_master_requests_dpram_wr_en_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002040) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //dpram_wr_en_s1_arb_share_counter set values, which is an e_mux
  assign dpram_wr_en_s1_arb_share_set_values = 1;

  //dpram_wr_en_s1_non_bursting_master_requests mux, which is an e_mux
  assign dpram_wr_en_s1_non_bursting_master_requests = cpu_0_data_master_requests_dpram_wr_en_s1;

  //dpram_wr_en_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign dpram_wr_en_s1_any_bursting_master_saved_grant = 0;

  //dpram_wr_en_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign dpram_wr_en_s1_arb_share_counter_next_value = dpram_wr_en_s1_firsttransfer ? (dpram_wr_en_s1_arb_share_set_values - 1) : |dpram_wr_en_s1_arb_share_counter ? (dpram_wr_en_s1_arb_share_counter - 1) : 0;

  //dpram_wr_en_s1_allgrants all slave grants, which is an e_mux
  assign dpram_wr_en_s1_allgrants = |dpram_wr_en_s1_grant_vector;

  //dpram_wr_en_s1_end_xfer assignment, which is an e_assign
  assign dpram_wr_en_s1_end_xfer = ~(dpram_wr_en_s1_waits_for_read | dpram_wr_en_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_dpram_wr_en_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_dpram_wr_en_s1 = dpram_wr_en_s1_end_xfer & (~dpram_wr_en_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //dpram_wr_en_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign dpram_wr_en_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_dpram_wr_en_s1 & dpram_wr_en_s1_allgrants) | (end_xfer_arb_share_counter_term_dpram_wr_en_s1 & ~dpram_wr_en_s1_non_bursting_master_requests);

  //dpram_wr_en_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wr_en_s1_arb_share_counter <= 0;
      else if (dpram_wr_en_s1_arb_counter_enable)
          dpram_wr_en_s1_arb_share_counter <= dpram_wr_en_s1_arb_share_counter_next_value;
    end


  //dpram_wr_en_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wr_en_s1_slavearbiterlockenable <= 0;
      else if ((|dpram_wr_en_s1_master_qreq_vector & end_xfer_arb_share_counter_term_dpram_wr_en_s1) | (end_xfer_arb_share_counter_term_dpram_wr_en_s1 & ~dpram_wr_en_s1_non_bursting_master_requests))
          dpram_wr_en_s1_slavearbiterlockenable <= |dpram_wr_en_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master dpram_wr_en/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = dpram_wr_en_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //dpram_wr_en_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign dpram_wr_en_s1_slavearbiterlockenable2 = |dpram_wr_en_s1_arb_share_counter_next_value;

  //cpu_0/data_master dpram_wr_en/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = dpram_wr_en_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //dpram_wr_en_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign dpram_wr_en_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_dpram_wr_en_s1 = cpu_0_data_master_requests_dpram_wr_en_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //dpram_wr_en_s1_writedata mux, which is an e_mux
  assign dpram_wr_en_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_dpram_wr_en_s1 = cpu_0_data_master_qualified_request_dpram_wr_en_s1;

  //cpu_0/data_master saved-grant dpram_wr_en/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_dpram_wr_en_s1 = cpu_0_data_master_requests_dpram_wr_en_s1;

  //allow new arb cycle for dpram_wr_en/s1, which is an e_assign
  assign dpram_wr_en_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign dpram_wr_en_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign dpram_wr_en_s1_master_qreq_vector = 1;

  //dpram_wr_en_s1_reset_n assignment, which is an e_assign
  assign dpram_wr_en_s1_reset_n = reset_n;

  assign dpram_wr_en_s1_chipselect = cpu_0_data_master_granted_dpram_wr_en_s1;
  //dpram_wr_en_s1_firsttransfer first transaction, which is an e_assign
  assign dpram_wr_en_s1_firsttransfer = dpram_wr_en_s1_begins_xfer ? dpram_wr_en_s1_unreg_firsttransfer : dpram_wr_en_s1_reg_firsttransfer;

  //dpram_wr_en_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign dpram_wr_en_s1_unreg_firsttransfer = ~(dpram_wr_en_s1_slavearbiterlockenable & dpram_wr_en_s1_any_continuerequest);

  //dpram_wr_en_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wr_en_s1_reg_firsttransfer <= 1'b1;
      else if (dpram_wr_en_s1_begins_xfer)
          dpram_wr_en_s1_reg_firsttransfer <= dpram_wr_en_s1_unreg_firsttransfer;
    end


  //dpram_wr_en_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign dpram_wr_en_s1_beginbursttransfer_internal = dpram_wr_en_s1_begins_xfer;

  //~dpram_wr_en_s1_write_n assignment, which is an e_mux
  assign dpram_wr_en_s1_write_n = ~(cpu_0_data_master_granted_dpram_wr_en_s1 & cpu_0_data_master_write);

  assign shifted_address_to_dpram_wr_en_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //dpram_wr_en_s1_address mux, which is an e_mux
  assign dpram_wr_en_s1_address = shifted_address_to_dpram_wr_en_s1_from_cpu_0_data_master >> 2;

  //d1_dpram_wr_en_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_dpram_wr_en_s1_end_xfer <= 1;
      else 
        d1_dpram_wr_en_s1_end_xfer <= dpram_wr_en_s1_end_xfer;
    end


  //dpram_wr_en_s1_waits_for_read in a cycle, which is an e_mux
  assign dpram_wr_en_s1_waits_for_read = dpram_wr_en_s1_in_a_read_cycle & dpram_wr_en_s1_begins_xfer;

  //dpram_wr_en_s1_in_a_read_cycle assignment, which is an e_assign
  assign dpram_wr_en_s1_in_a_read_cycle = cpu_0_data_master_granted_dpram_wr_en_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = dpram_wr_en_s1_in_a_read_cycle;

  //dpram_wr_en_s1_waits_for_write in a cycle, which is an e_mux
  assign dpram_wr_en_s1_waits_for_write = dpram_wr_en_s1_in_a_write_cycle & 0;

  //dpram_wr_en_s1_in_a_write_cycle assignment, which is an e_assign
  assign dpram_wr_en_s1_in_a_write_cycle = cpu_0_data_master_granted_dpram_wr_en_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = dpram_wr_en_s1_in_a_write_cycle;

  assign wait_for_dpram_wr_en_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //dpram_wr_en/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module dpram_wrclk_s1_arbitrator (
                                   // inputs:
                                    clk,
                                    cpu_0_data_master_address_to_slave,
                                    cpu_0_data_master_read,
                                    cpu_0_data_master_waitrequest,
                                    cpu_0_data_master_write,
                                    cpu_0_data_master_writedata,
                                    dpram_wrclk_s1_readdata,
                                    reset_n,

                                   // outputs:
                                    cpu_0_data_master_granted_dpram_wrclk_s1,
                                    cpu_0_data_master_qualified_request_dpram_wrclk_s1,
                                    cpu_0_data_master_read_data_valid_dpram_wrclk_s1,
                                    cpu_0_data_master_requests_dpram_wrclk_s1,
                                    d1_dpram_wrclk_s1_end_xfer,
                                    dpram_wrclk_s1_address,
                                    dpram_wrclk_s1_chipselect,
                                    dpram_wrclk_s1_readdata_from_sa,
                                    dpram_wrclk_s1_reset_n,
                                    dpram_wrclk_s1_write_n,
                                    dpram_wrclk_s1_writedata
                                 )
;

  output           cpu_0_data_master_granted_dpram_wrclk_s1;
  output           cpu_0_data_master_qualified_request_dpram_wrclk_s1;
  output           cpu_0_data_master_read_data_valid_dpram_wrclk_s1;
  output           cpu_0_data_master_requests_dpram_wrclk_s1;
  output           d1_dpram_wrclk_s1_end_xfer;
  output  [  1: 0] dpram_wrclk_s1_address;
  output           dpram_wrclk_s1_chipselect;
  output           dpram_wrclk_s1_readdata_from_sa;
  output           dpram_wrclk_s1_reset_n;
  output           dpram_wrclk_s1_write_n;
  output           dpram_wrclk_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            dpram_wrclk_s1_readdata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_dpram_wrclk_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wrclk_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wrclk_s1;
  wire             cpu_0_data_master_requests_dpram_wrclk_s1;
  wire             cpu_0_data_master_saved_grant_dpram_wrclk_s1;
  reg              d1_dpram_wrclk_s1_end_xfer;
  reg              d1_reasons_to_wait;
  wire    [  1: 0] dpram_wrclk_s1_address;
  wire             dpram_wrclk_s1_allgrants;
  wire             dpram_wrclk_s1_allow_new_arb_cycle;
  wire             dpram_wrclk_s1_any_bursting_master_saved_grant;
  wire             dpram_wrclk_s1_any_continuerequest;
  wire             dpram_wrclk_s1_arb_counter_enable;
  reg     [  1: 0] dpram_wrclk_s1_arb_share_counter;
  wire    [  1: 0] dpram_wrclk_s1_arb_share_counter_next_value;
  wire    [  1: 0] dpram_wrclk_s1_arb_share_set_values;
  wire             dpram_wrclk_s1_beginbursttransfer_internal;
  wire             dpram_wrclk_s1_begins_xfer;
  wire             dpram_wrclk_s1_chipselect;
  wire             dpram_wrclk_s1_end_xfer;
  wire             dpram_wrclk_s1_firsttransfer;
  wire             dpram_wrclk_s1_grant_vector;
  wire             dpram_wrclk_s1_in_a_read_cycle;
  wire             dpram_wrclk_s1_in_a_write_cycle;
  wire             dpram_wrclk_s1_master_qreq_vector;
  wire             dpram_wrclk_s1_non_bursting_master_requests;
  wire             dpram_wrclk_s1_readdata_from_sa;
  reg              dpram_wrclk_s1_reg_firsttransfer;
  wire             dpram_wrclk_s1_reset_n;
  reg              dpram_wrclk_s1_slavearbiterlockenable;
  wire             dpram_wrclk_s1_slavearbiterlockenable2;
  wire             dpram_wrclk_s1_unreg_firsttransfer;
  wire             dpram_wrclk_s1_waits_for_read;
  wire             dpram_wrclk_s1_waits_for_write;
  wire             dpram_wrclk_s1_write_n;
  wire             dpram_wrclk_s1_writedata;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_dpram_wrclk_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_dpram_wrclk_s1_from_cpu_0_data_master;
  wire             wait_for_dpram_wrclk_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~dpram_wrclk_s1_end_xfer;
    end


  assign dpram_wrclk_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_dpram_wrclk_s1));
  //assign dpram_wrclk_s1_readdata_from_sa = dpram_wrclk_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign dpram_wrclk_s1_readdata_from_sa = dpram_wrclk_s1_readdata;

  assign cpu_0_data_master_requests_dpram_wrclk_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002070) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //dpram_wrclk_s1_arb_share_counter set values, which is an e_mux
  assign dpram_wrclk_s1_arb_share_set_values = 1;

  //dpram_wrclk_s1_non_bursting_master_requests mux, which is an e_mux
  assign dpram_wrclk_s1_non_bursting_master_requests = cpu_0_data_master_requests_dpram_wrclk_s1;

  //dpram_wrclk_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign dpram_wrclk_s1_any_bursting_master_saved_grant = 0;

  //dpram_wrclk_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign dpram_wrclk_s1_arb_share_counter_next_value = dpram_wrclk_s1_firsttransfer ? (dpram_wrclk_s1_arb_share_set_values - 1) : |dpram_wrclk_s1_arb_share_counter ? (dpram_wrclk_s1_arb_share_counter - 1) : 0;

  //dpram_wrclk_s1_allgrants all slave grants, which is an e_mux
  assign dpram_wrclk_s1_allgrants = |dpram_wrclk_s1_grant_vector;

  //dpram_wrclk_s1_end_xfer assignment, which is an e_assign
  assign dpram_wrclk_s1_end_xfer = ~(dpram_wrclk_s1_waits_for_read | dpram_wrclk_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_dpram_wrclk_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_dpram_wrclk_s1 = dpram_wrclk_s1_end_xfer & (~dpram_wrclk_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //dpram_wrclk_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign dpram_wrclk_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_dpram_wrclk_s1 & dpram_wrclk_s1_allgrants) | (end_xfer_arb_share_counter_term_dpram_wrclk_s1 & ~dpram_wrclk_s1_non_bursting_master_requests);

  //dpram_wrclk_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_s1_arb_share_counter <= 0;
      else if (dpram_wrclk_s1_arb_counter_enable)
          dpram_wrclk_s1_arb_share_counter <= dpram_wrclk_s1_arb_share_counter_next_value;
    end


  //dpram_wrclk_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_s1_slavearbiterlockenable <= 0;
      else if ((|dpram_wrclk_s1_master_qreq_vector & end_xfer_arb_share_counter_term_dpram_wrclk_s1) | (end_xfer_arb_share_counter_term_dpram_wrclk_s1 & ~dpram_wrclk_s1_non_bursting_master_requests))
          dpram_wrclk_s1_slavearbiterlockenable <= |dpram_wrclk_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master dpram_wrclk/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = dpram_wrclk_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //dpram_wrclk_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign dpram_wrclk_s1_slavearbiterlockenable2 = |dpram_wrclk_s1_arb_share_counter_next_value;

  //cpu_0/data_master dpram_wrclk/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = dpram_wrclk_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //dpram_wrclk_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign dpram_wrclk_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_dpram_wrclk_s1 = cpu_0_data_master_requests_dpram_wrclk_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //dpram_wrclk_s1_writedata mux, which is an e_mux
  assign dpram_wrclk_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_dpram_wrclk_s1 = cpu_0_data_master_qualified_request_dpram_wrclk_s1;

  //cpu_0/data_master saved-grant dpram_wrclk/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_dpram_wrclk_s1 = cpu_0_data_master_requests_dpram_wrclk_s1;

  //allow new arb cycle for dpram_wrclk/s1, which is an e_assign
  assign dpram_wrclk_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign dpram_wrclk_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign dpram_wrclk_s1_master_qreq_vector = 1;

  //dpram_wrclk_s1_reset_n assignment, which is an e_assign
  assign dpram_wrclk_s1_reset_n = reset_n;

  assign dpram_wrclk_s1_chipselect = cpu_0_data_master_granted_dpram_wrclk_s1;
  //dpram_wrclk_s1_firsttransfer first transaction, which is an e_assign
  assign dpram_wrclk_s1_firsttransfer = dpram_wrclk_s1_begins_xfer ? dpram_wrclk_s1_unreg_firsttransfer : dpram_wrclk_s1_reg_firsttransfer;

  //dpram_wrclk_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign dpram_wrclk_s1_unreg_firsttransfer = ~(dpram_wrclk_s1_slavearbiterlockenable & dpram_wrclk_s1_any_continuerequest);

  //dpram_wrclk_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_s1_reg_firsttransfer <= 1'b1;
      else if (dpram_wrclk_s1_begins_xfer)
          dpram_wrclk_s1_reg_firsttransfer <= dpram_wrclk_s1_unreg_firsttransfer;
    end


  //dpram_wrclk_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign dpram_wrclk_s1_beginbursttransfer_internal = dpram_wrclk_s1_begins_xfer;

  //~dpram_wrclk_s1_write_n assignment, which is an e_mux
  assign dpram_wrclk_s1_write_n = ~(cpu_0_data_master_granted_dpram_wrclk_s1 & cpu_0_data_master_write);

  assign shifted_address_to_dpram_wrclk_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //dpram_wrclk_s1_address mux, which is an e_mux
  assign dpram_wrclk_s1_address = shifted_address_to_dpram_wrclk_s1_from_cpu_0_data_master >> 2;

  //d1_dpram_wrclk_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_dpram_wrclk_s1_end_xfer <= 1;
      else 
        d1_dpram_wrclk_s1_end_xfer <= dpram_wrclk_s1_end_xfer;
    end


  //dpram_wrclk_s1_waits_for_read in a cycle, which is an e_mux
  assign dpram_wrclk_s1_waits_for_read = dpram_wrclk_s1_in_a_read_cycle & dpram_wrclk_s1_begins_xfer;

  //dpram_wrclk_s1_in_a_read_cycle assignment, which is an e_assign
  assign dpram_wrclk_s1_in_a_read_cycle = cpu_0_data_master_granted_dpram_wrclk_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = dpram_wrclk_s1_in_a_read_cycle;

  //dpram_wrclk_s1_waits_for_write in a cycle, which is an e_mux
  assign dpram_wrclk_s1_waits_for_write = dpram_wrclk_s1_in_a_write_cycle & 0;

  //dpram_wrclk_s1_in_a_write_cycle assignment, which is an e_assign
  assign dpram_wrclk_s1_in_a_write_cycle = cpu_0_data_master_granted_dpram_wrclk_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = dpram_wrclk_s1_in_a_write_cycle;

  assign wait_for_dpram_wrclk_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //dpram_wrclk/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module dpram_wrclk_en_s1_arbitrator (
                                      // inputs:
                                       clk,
                                       cpu_0_data_master_address_to_slave,
                                       cpu_0_data_master_read,
                                       cpu_0_data_master_waitrequest,
                                       cpu_0_data_master_write,
                                       cpu_0_data_master_writedata,
                                       dpram_wrclk_en_s1_readdata,
                                       reset_n,

                                      // outputs:
                                       cpu_0_data_master_granted_dpram_wrclk_en_s1,
                                       cpu_0_data_master_qualified_request_dpram_wrclk_en_s1,
                                       cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1,
                                       cpu_0_data_master_requests_dpram_wrclk_en_s1,
                                       d1_dpram_wrclk_en_s1_end_xfer,
                                       dpram_wrclk_en_s1_address,
                                       dpram_wrclk_en_s1_chipselect,
                                       dpram_wrclk_en_s1_readdata_from_sa,
                                       dpram_wrclk_en_s1_reset_n,
                                       dpram_wrclk_en_s1_write_n,
                                       dpram_wrclk_en_s1_writedata
                                    )
;

  output           cpu_0_data_master_granted_dpram_wrclk_en_s1;
  output           cpu_0_data_master_qualified_request_dpram_wrclk_en_s1;
  output           cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1;
  output           cpu_0_data_master_requests_dpram_wrclk_en_s1;
  output           d1_dpram_wrclk_en_s1_end_xfer;
  output  [  1: 0] dpram_wrclk_en_s1_address;
  output           dpram_wrclk_en_s1_chipselect;
  output           dpram_wrclk_en_s1_readdata_from_sa;
  output           dpram_wrclk_en_s1_reset_n;
  output           dpram_wrclk_en_s1_write_n;
  output           dpram_wrclk_en_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            dpram_wrclk_en_s1_readdata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_requests_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_saved_grant_dpram_wrclk_en_s1;
  reg              d1_dpram_wrclk_en_s1_end_xfer;
  reg              d1_reasons_to_wait;
  wire    [  1: 0] dpram_wrclk_en_s1_address;
  wire             dpram_wrclk_en_s1_allgrants;
  wire             dpram_wrclk_en_s1_allow_new_arb_cycle;
  wire             dpram_wrclk_en_s1_any_bursting_master_saved_grant;
  wire             dpram_wrclk_en_s1_any_continuerequest;
  wire             dpram_wrclk_en_s1_arb_counter_enable;
  reg     [  1: 0] dpram_wrclk_en_s1_arb_share_counter;
  wire    [  1: 0] dpram_wrclk_en_s1_arb_share_counter_next_value;
  wire    [  1: 0] dpram_wrclk_en_s1_arb_share_set_values;
  wire             dpram_wrclk_en_s1_beginbursttransfer_internal;
  wire             dpram_wrclk_en_s1_begins_xfer;
  wire             dpram_wrclk_en_s1_chipselect;
  wire             dpram_wrclk_en_s1_end_xfer;
  wire             dpram_wrclk_en_s1_firsttransfer;
  wire             dpram_wrclk_en_s1_grant_vector;
  wire             dpram_wrclk_en_s1_in_a_read_cycle;
  wire             dpram_wrclk_en_s1_in_a_write_cycle;
  wire             dpram_wrclk_en_s1_master_qreq_vector;
  wire             dpram_wrclk_en_s1_non_bursting_master_requests;
  wire             dpram_wrclk_en_s1_readdata_from_sa;
  reg              dpram_wrclk_en_s1_reg_firsttransfer;
  wire             dpram_wrclk_en_s1_reset_n;
  reg              dpram_wrclk_en_s1_slavearbiterlockenable;
  wire             dpram_wrclk_en_s1_slavearbiterlockenable2;
  wire             dpram_wrclk_en_s1_unreg_firsttransfer;
  wire             dpram_wrclk_en_s1_waits_for_read;
  wire             dpram_wrclk_en_s1_waits_for_write;
  wire             dpram_wrclk_en_s1_write_n;
  wire             dpram_wrclk_en_s1_writedata;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_dpram_wrclk_en_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_dpram_wrclk_en_s1_from_cpu_0_data_master;
  wire             wait_for_dpram_wrclk_en_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~dpram_wrclk_en_s1_end_xfer;
    end


  assign dpram_wrclk_en_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_dpram_wrclk_en_s1));
  //assign dpram_wrclk_en_s1_readdata_from_sa = dpram_wrclk_en_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign dpram_wrclk_en_s1_readdata_from_sa = dpram_wrclk_en_s1_readdata;

  assign cpu_0_data_master_requests_dpram_wrclk_en_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002050) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //dpram_wrclk_en_s1_arb_share_counter set values, which is an e_mux
  assign dpram_wrclk_en_s1_arb_share_set_values = 1;

  //dpram_wrclk_en_s1_non_bursting_master_requests mux, which is an e_mux
  assign dpram_wrclk_en_s1_non_bursting_master_requests = cpu_0_data_master_requests_dpram_wrclk_en_s1;

  //dpram_wrclk_en_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign dpram_wrclk_en_s1_any_bursting_master_saved_grant = 0;

  //dpram_wrclk_en_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign dpram_wrclk_en_s1_arb_share_counter_next_value = dpram_wrclk_en_s1_firsttransfer ? (dpram_wrclk_en_s1_arb_share_set_values - 1) : |dpram_wrclk_en_s1_arb_share_counter ? (dpram_wrclk_en_s1_arb_share_counter - 1) : 0;

  //dpram_wrclk_en_s1_allgrants all slave grants, which is an e_mux
  assign dpram_wrclk_en_s1_allgrants = |dpram_wrclk_en_s1_grant_vector;

  //dpram_wrclk_en_s1_end_xfer assignment, which is an e_assign
  assign dpram_wrclk_en_s1_end_xfer = ~(dpram_wrclk_en_s1_waits_for_read | dpram_wrclk_en_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_dpram_wrclk_en_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_dpram_wrclk_en_s1 = dpram_wrclk_en_s1_end_xfer & (~dpram_wrclk_en_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //dpram_wrclk_en_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign dpram_wrclk_en_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_dpram_wrclk_en_s1 & dpram_wrclk_en_s1_allgrants) | (end_xfer_arb_share_counter_term_dpram_wrclk_en_s1 & ~dpram_wrclk_en_s1_non_bursting_master_requests);

  //dpram_wrclk_en_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_en_s1_arb_share_counter <= 0;
      else if (dpram_wrclk_en_s1_arb_counter_enable)
          dpram_wrclk_en_s1_arb_share_counter <= dpram_wrclk_en_s1_arb_share_counter_next_value;
    end


  //dpram_wrclk_en_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_en_s1_slavearbiterlockenable <= 0;
      else if ((|dpram_wrclk_en_s1_master_qreq_vector & end_xfer_arb_share_counter_term_dpram_wrclk_en_s1) | (end_xfer_arb_share_counter_term_dpram_wrclk_en_s1 & ~dpram_wrclk_en_s1_non_bursting_master_requests))
          dpram_wrclk_en_s1_slavearbiterlockenable <= |dpram_wrclk_en_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master dpram_wrclk_en/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = dpram_wrclk_en_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //dpram_wrclk_en_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign dpram_wrclk_en_s1_slavearbiterlockenable2 = |dpram_wrclk_en_s1_arb_share_counter_next_value;

  //cpu_0/data_master dpram_wrclk_en/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = dpram_wrclk_en_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //dpram_wrclk_en_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign dpram_wrclk_en_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_dpram_wrclk_en_s1 = cpu_0_data_master_requests_dpram_wrclk_en_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //dpram_wrclk_en_s1_writedata mux, which is an e_mux
  assign dpram_wrclk_en_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_dpram_wrclk_en_s1 = cpu_0_data_master_qualified_request_dpram_wrclk_en_s1;

  //cpu_0/data_master saved-grant dpram_wrclk_en/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_dpram_wrclk_en_s1 = cpu_0_data_master_requests_dpram_wrclk_en_s1;

  //allow new arb cycle for dpram_wrclk_en/s1, which is an e_assign
  assign dpram_wrclk_en_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign dpram_wrclk_en_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign dpram_wrclk_en_s1_master_qreq_vector = 1;

  //dpram_wrclk_en_s1_reset_n assignment, which is an e_assign
  assign dpram_wrclk_en_s1_reset_n = reset_n;

  assign dpram_wrclk_en_s1_chipselect = cpu_0_data_master_granted_dpram_wrclk_en_s1;
  //dpram_wrclk_en_s1_firsttransfer first transaction, which is an e_assign
  assign dpram_wrclk_en_s1_firsttransfer = dpram_wrclk_en_s1_begins_xfer ? dpram_wrclk_en_s1_unreg_firsttransfer : dpram_wrclk_en_s1_reg_firsttransfer;

  //dpram_wrclk_en_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign dpram_wrclk_en_s1_unreg_firsttransfer = ~(dpram_wrclk_en_s1_slavearbiterlockenable & dpram_wrclk_en_s1_any_continuerequest);

  //dpram_wrclk_en_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          dpram_wrclk_en_s1_reg_firsttransfer <= 1'b1;
      else if (dpram_wrclk_en_s1_begins_xfer)
          dpram_wrclk_en_s1_reg_firsttransfer <= dpram_wrclk_en_s1_unreg_firsttransfer;
    end


  //dpram_wrclk_en_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign dpram_wrclk_en_s1_beginbursttransfer_internal = dpram_wrclk_en_s1_begins_xfer;

  //~dpram_wrclk_en_s1_write_n assignment, which is an e_mux
  assign dpram_wrclk_en_s1_write_n = ~(cpu_0_data_master_granted_dpram_wrclk_en_s1 & cpu_0_data_master_write);

  assign shifted_address_to_dpram_wrclk_en_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //dpram_wrclk_en_s1_address mux, which is an e_mux
  assign dpram_wrclk_en_s1_address = shifted_address_to_dpram_wrclk_en_s1_from_cpu_0_data_master >> 2;

  //d1_dpram_wrclk_en_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_dpram_wrclk_en_s1_end_xfer <= 1;
      else 
        d1_dpram_wrclk_en_s1_end_xfer <= dpram_wrclk_en_s1_end_xfer;
    end


  //dpram_wrclk_en_s1_waits_for_read in a cycle, which is an e_mux
  assign dpram_wrclk_en_s1_waits_for_read = dpram_wrclk_en_s1_in_a_read_cycle & dpram_wrclk_en_s1_begins_xfer;

  //dpram_wrclk_en_s1_in_a_read_cycle assignment, which is an e_assign
  assign dpram_wrclk_en_s1_in_a_read_cycle = cpu_0_data_master_granted_dpram_wrclk_en_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = dpram_wrclk_en_s1_in_a_read_cycle;

  //dpram_wrclk_en_s1_waits_for_write in a cycle, which is an e_mux
  assign dpram_wrclk_en_s1_waits_for_write = dpram_wrclk_en_s1_in_a_write_cycle & 0;

  //dpram_wrclk_en_s1_in_a_write_cycle assignment, which is an e_assign
  assign dpram_wrclk_en_s1_in_a_write_cycle = cpu_0_data_master_granted_dpram_wrclk_en_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = dpram_wrclk_en_s1_in_a_write_cycle;

  assign wait_for_dpram_wrclk_en_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //dpram_wrclk_en/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module epcs_flash_controller_0_epcs_control_port_arbitrator (
                                                              // inputs:
                                                               clk,
                                                               cpu_0_data_master_address_to_slave,
                                                               cpu_0_data_master_read,
                                                               cpu_0_data_master_write,
                                                               cpu_0_data_master_writedata,
                                                               cpu_0_instruction_master_address_to_slave,
                                                               cpu_0_instruction_master_read,
                                                               epcs_flash_controller_0_epcs_control_port_dataavailable,
                                                               epcs_flash_controller_0_epcs_control_port_endofpacket,
                                                               epcs_flash_controller_0_epcs_control_port_irq,
                                                               epcs_flash_controller_0_epcs_control_port_readdata,
                                                               epcs_flash_controller_0_epcs_control_port_readyfordata,
                                                               reset_n,

                                                              // outputs:
                                                               cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port,
                                                               cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port,
                                                               d1_epcs_flash_controller_0_epcs_control_port_end_xfer,
                                                               epcs_flash_controller_0_epcs_control_port_address,
                                                               epcs_flash_controller_0_epcs_control_port_chipselect,
                                                               epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa,
                                                               epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa,
                                                               epcs_flash_controller_0_epcs_control_port_irq_from_sa,
                                                               epcs_flash_controller_0_epcs_control_port_read_n,
                                                               epcs_flash_controller_0_epcs_control_port_readdata_from_sa,
                                                               epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa,
                                                               epcs_flash_controller_0_epcs_control_port_reset_n,
                                                               epcs_flash_controller_0_epcs_control_port_write_n,
                                                               epcs_flash_controller_0_epcs_control_port_writedata
                                                            )
;

  output           cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  output           cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  output           d1_epcs_flash_controller_0_epcs_control_port_end_xfer;
  output  [  8: 0] epcs_flash_controller_0_epcs_control_port_address;
  output           epcs_flash_controller_0_epcs_control_port_chipselect;
  output           epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa;
  output           epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa;
  output           epcs_flash_controller_0_epcs_control_port_irq_from_sa;
  output           epcs_flash_controller_0_epcs_control_port_read_n;
  output  [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata_from_sa;
  output           epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa;
  output           epcs_flash_controller_0_epcs_control_port_reset_n;
  output           epcs_flash_controller_0_epcs_control_port_write_n;
  output  [ 31: 0] epcs_flash_controller_0_epcs_control_port_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input   [ 24: 0] cpu_0_instruction_master_address_to_slave;
  input            cpu_0_instruction_master_read;
  input            epcs_flash_controller_0_epcs_control_port_dataavailable;
  input            epcs_flash_controller_0_epcs_control_port_endofpacket;
  input            epcs_flash_controller_0_epcs_control_port_irq;
  input   [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata;
  input            epcs_flash_controller_0_epcs_control_port_readyfordata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_arbiterlock;
  wire             cpu_0_instruction_master_arbiterlock2;
  wire             cpu_0_instruction_master_continuerequest;
  wire             cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port;
  reg              d1_epcs_flash_controller_0_epcs_control_port_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port;
  wire    [  8: 0] epcs_flash_controller_0_epcs_control_port_address;
  wire             epcs_flash_controller_0_epcs_control_port_allgrants;
  wire             epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle;
  wire             epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant;
  wire             epcs_flash_controller_0_epcs_control_port_any_continuerequest;
  reg     [  1: 0] epcs_flash_controller_0_epcs_control_port_arb_addend;
  wire             epcs_flash_controller_0_epcs_control_port_arb_counter_enable;
  reg     [  1: 0] epcs_flash_controller_0_epcs_control_port_arb_share_counter;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_arb_share_set_values;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_arb_winner;
  wire             epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal;
  wire             epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal;
  wire             epcs_flash_controller_0_epcs_control_port_begins_xfer;
  wire             epcs_flash_controller_0_epcs_control_port_chipselect;
  wire    [  3: 0] epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left;
  wire             epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_end_xfer;
  wire             epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_firsttransfer;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_grant_vector;
  wire             epcs_flash_controller_0_epcs_control_port_in_a_read_cycle;
  wire             epcs_flash_controller_0_epcs_control_port_in_a_write_cycle;
  wire             epcs_flash_controller_0_epcs_control_port_irq_from_sa;
  wire    [  1: 0] epcs_flash_controller_0_epcs_control_port_master_qreq_vector;
  wire             epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests;
  wire             epcs_flash_controller_0_epcs_control_port_read_n;
  wire    [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa;
  reg              epcs_flash_controller_0_epcs_control_port_reg_firsttransfer;
  wire             epcs_flash_controller_0_epcs_control_port_reset_n;
  reg     [  1: 0] epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector;
  reg              epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable;
  wire             epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2;
  wire             epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer;
  wire             epcs_flash_controller_0_epcs_control_port_waits_for_read;
  wire             epcs_flash_controller_0_epcs_control_port_waits_for_write;
  wire             epcs_flash_controller_0_epcs_control_port_write_n;
  wire    [ 31: 0] epcs_flash_controller_0_epcs_control_port_writedata;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_0_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port;
  reg              last_cycle_cpu_0_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port;
  wire    [ 24: 0] shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_data_master;
  wire    [ 24: 0] shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_instruction_master;
  wire             wait_for_epcs_flash_controller_0_epcs_control_port_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~epcs_flash_controller_0_epcs_control_port_end_xfer;
    end


  assign epcs_flash_controller_0_epcs_control_port_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port | cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port));
  //assign epcs_flash_controller_0_epcs_control_port_readdata_from_sa = epcs_flash_controller_0_epcs_control_port_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_readdata_from_sa = epcs_flash_controller_0_epcs_control_port_readdata;

  assign cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port = ({cpu_0_data_master_address_to_slave[24 : 11] , 11'b0} == 25'h1001800) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //assign epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa = epcs_flash_controller_0_epcs_control_port_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa = epcs_flash_controller_0_epcs_control_port_dataavailable;

  //assign epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa = epcs_flash_controller_0_epcs_control_port_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa = epcs_flash_controller_0_epcs_control_port_readyfordata;

  //epcs_flash_controller_0_epcs_control_port_arb_share_counter set values, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_arb_share_set_values = 1;

  //epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests mux, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests = cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port |
    cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port |
    cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port |
    cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;

  //epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant mux, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant = 0;

  //epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value assignment, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value = epcs_flash_controller_0_epcs_control_port_firsttransfer ? (epcs_flash_controller_0_epcs_control_port_arb_share_set_values - 1) : |epcs_flash_controller_0_epcs_control_port_arb_share_counter ? (epcs_flash_controller_0_epcs_control_port_arb_share_counter - 1) : 0;

  //epcs_flash_controller_0_epcs_control_port_allgrants all slave grants, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_allgrants = (|epcs_flash_controller_0_epcs_control_port_grant_vector) |
    (|epcs_flash_controller_0_epcs_control_port_grant_vector) |
    (|epcs_flash_controller_0_epcs_control_port_grant_vector) |
    (|epcs_flash_controller_0_epcs_control_port_grant_vector);

  //epcs_flash_controller_0_epcs_control_port_end_xfer assignment, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_end_xfer = ~(epcs_flash_controller_0_epcs_control_port_waits_for_read | epcs_flash_controller_0_epcs_control_port_waits_for_write);

  //end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port = epcs_flash_controller_0_epcs_control_port_end_xfer & (~epcs_flash_controller_0_epcs_control_port_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //epcs_flash_controller_0_epcs_control_port_arb_share_counter arbitration counter enable, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_arb_counter_enable = (end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port & epcs_flash_controller_0_epcs_control_port_allgrants) | (end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port & ~epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests);

  //epcs_flash_controller_0_epcs_control_port_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_flash_controller_0_epcs_control_port_arb_share_counter <= 0;
      else if (epcs_flash_controller_0_epcs_control_port_arb_counter_enable)
          epcs_flash_controller_0_epcs_control_port_arb_share_counter <= epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
    end


  //epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable <= 0;
      else if ((|epcs_flash_controller_0_epcs_control_port_master_qreq_vector & end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port) | (end_xfer_arb_share_counter_term_epcs_flash_controller_0_epcs_control_port & ~epcs_flash_controller_0_epcs_control_port_non_bursting_master_requests))
          epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable <= |epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;
    end


  //cpu_0/data_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 = |epcs_flash_controller_0_epcs_control_port_arb_share_counter_next_value;

  //cpu_0/data_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //cpu_0/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock = epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master epcs_flash_controller_0/epcs_control_port arbiterlock2, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock2 = epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable2 & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= 0;
      else 
        last_cycle_cpu_0_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= cpu_0_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port ? 1 : (epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal | ~cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port) ? 0 : last_cycle_cpu_0_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port;
    end


  //cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_0_instruction_master_continuerequest = last_cycle_cpu_0_instruction_master_granted_slave_epcs_flash_controller_0_epcs_control_port & cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;

  //epcs_flash_controller_0_epcs_control_port_any_continuerequest at least one master continues requesting, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_any_continuerequest = cpu_0_instruction_master_continuerequest |
    cpu_0_data_master_continuerequest;

  assign cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port = cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port & ~(cpu_0_instruction_master_arbiterlock);
  //epcs_flash_controller_0_epcs_control_port_writedata mux, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_writedata = cpu_0_data_master_writedata;

  //assign epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa = epcs_flash_controller_0_epcs_control_port_endofpacket so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa = epcs_flash_controller_0_epcs_control_port_endofpacket;

  assign cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port = (({cpu_0_instruction_master_address_to_slave[24 : 11] , 11'b0} == 25'h1001800) & (cpu_0_instruction_master_read)) & cpu_0_instruction_master_read;
  //cpu_0/data_master granted epcs_flash_controller_0/epcs_control_port last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= 0;
      else 
        last_cycle_cpu_0_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port <= cpu_0_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port ? 1 : (epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal | ~cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port) ? 0 : last_cycle_cpu_0_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port;
    end


  //cpu_0_data_master_continuerequest continued request, which is an e_mux
  assign cpu_0_data_master_continuerequest = last_cycle_cpu_0_data_master_granted_slave_epcs_flash_controller_0_epcs_control_port & cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;

  assign cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port = cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port & ~(cpu_0_data_master_arbiterlock);
  //allow new arb cycle for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle = ~cpu_0_data_master_arbiterlock & ~cpu_0_instruction_master_arbiterlock;

  //cpu_0/instruction_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_master_qreq_vector[0] = cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;

  //cpu_0/instruction_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port = epcs_flash_controller_0_epcs_control_port_grant_vector[0];

  //cpu_0/instruction_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign cpu_0_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port = epcs_flash_controller_0_epcs_control_port_arb_winner[0] && cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;

  //cpu_0/data_master assignment into master qualified-requests vector for epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_master_qreq_vector[1] = cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;

  //cpu_0/data_master grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port = epcs_flash_controller_0_epcs_control_port_grant_vector[1];

  //cpu_0/data_master saved-grant epcs_flash_controller_0/epcs_control_port, which is an e_assign
  assign cpu_0_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port = epcs_flash_controller_0_epcs_control_port_arb_winner[1] && cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;

  //epcs_flash_controller_0/epcs_control_port chosen-master double-vector, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector = {epcs_flash_controller_0_epcs_control_port_master_qreq_vector, epcs_flash_controller_0_epcs_control_port_master_qreq_vector} & ({~epcs_flash_controller_0_epcs_control_port_master_qreq_vector, ~epcs_flash_controller_0_epcs_control_port_master_qreq_vector} + epcs_flash_controller_0_epcs_control_port_arb_addend);

  //stable onehot encoding of arb winner
  assign epcs_flash_controller_0_epcs_control_port_arb_winner = (epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle & | epcs_flash_controller_0_epcs_control_port_grant_vector) ? epcs_flash_controller_0_epcs_control_port_grant_vector : epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector;

  //saved epcs_flash_controller_0_epcs_control_port_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector <= 0;
      else if (epcs_flash_controller_0_epcs_control_port_allow_new_arb_cycle)
          epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector <= |epcs_flash_controller_0_epcs_control_port_grant_vector ? epcs_flash_controller_0_epcs_control_port_grant_vector : epcs_flash_controller_0_epcs_control_port_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign epcs_flash_controller_0_epcs_control_port_grant_vector = {(epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector[1] | epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector[3]),
    (epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector[0] | epcs_flash_controller_0_epcs_control_port_chosen_master_double_vector[2])};

  //epcs_flash_controller_0/epcs_control_port chosen master rotated left, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left = (epcs_flash_controller_0_epcs_control_port_arb_winner << 1) ? (epcs_flash_controller_0_epcs_control_port_arb_winner << 1) : 1;

  //epcs_flash_controller_0/epcs_control_port's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_flash_controller_0_epcs_control_port_arb_addend <= 1;
      else if (|epcs_flash_controller_0_epcs_control_port_grant_vector)
          epcs_flash_controller_0_epcs_control_port_arb_addend <= epcs_flash_controller_0_epcs_control_port_end_xfer? epcs_flash_controller_0_epcs_control_port_chosen_master_rot_left : epcs_flash_controller_0_epcs_control_port_grant_vector;
    end


  //epcs_flash_controller_0_epcs_control_port_reset_n assignment, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_reset_n = reset_n;

  assign epcs_flash_controller_0_epcs_control_port_chipselect = cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port | cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  //epcs_flash_controller_0_epcs_control_port_firsttransfer first transaction, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_firsttransfer = epcs_flash_controller_0_epcs_control_port_begins_xfer ? epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer : epcs_flash_controller_0_epcs_control_port_reg_firsttransfer;

  //epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer first transaction, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer = ~(epcs_flash_controller_0_epcs_control_port_slavearbiterlockenable & epcs_flash_controller_0_epcs_control_port_any_continuerequest);

  //epcs_flash_controller_0_epcs_control_port_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          epcs_flash_controller_0_epcs_control_port_reg_firsttransfer <= 1'b1;
      else if (epcs_flash_controller_0_epcs_control_port_begins_xfer)
          epcs_flash_controller_0_epcs_control_port_reg_firsttransfer <= epcs_flash_controller_0_epcs_control_port_unreg_firsttransfer;
    end


  //epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_beginbursttransfer_internal = epcs_flash_controller_0_epcs_control_port_begins_xfer;

  //epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_arbitration_holdoff_internal = epcs_flash_controller_0_epcs_control_port_begins_xfer & epcs_flash_controller_0_epcs_control_port_firsttransfer;

  //~epcs_flash_controller_0_epcs_control_port_read_n assignment, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_read_n = ~((cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_data_master_read) | (cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_instruction_master_read));

  //~epcs_flash_controller_0_epcs_control_port_write_n assignment, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_write_n = ~(cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_data_master_write);

  assign shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //epcs_flash_controller_0_epcs_control_port_address mux, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_address = (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port)? (shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_data_master >> 2) :
    (shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_instruction_master >> 2);

  assign shifted_address_to_epcs_flash_controller_0_epcs_control_port_from_cpu_0_instruction_master = cpu_0_instruction_master_address_to_slave;
  //d1_epcs_flash_controller_0_epcs_control_port_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_epcs_flash_controller_0_epcs_control_port_end_xfer <= 1;
      else 
        d1_epcs_flash_controller_0_epcs_control_port_end_xfer <= epcs_flash_controller_0_epcs_control_port_end_xfer;
    end


  //epcs_flash_controller_0_epcs_control_port_waits_for_read in a cycle, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_waits_for_read = epcs_flash_controller_0_epcs_control_port_in_a_read_cycle & epcs_flash_controller_0_epcs_control_port_begins_xfer;

  //epcs_flash_controller_0_epcs_control_port_in_a_read_cycle assignment, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_in_a_read_cycle = (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_data_master_read) | (cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = epcs_flash_controller_0_epcs_control_port_in_a_read_cycle;

  //epcs_flash_controller_0_epcs_control_port_waits_for_write in a cycle, which is an e_mux
  assign epcs_flash_controller_0_epcs_control_port_waits_for_write = epcs_flash_controller_0_epcs_control_port_in_a_write_cycle & epcs_flash_controller_0_epcs_control_port_begins_xfer;

  //epcs_flash_controller_0_epcs_control_port_in_a_write_cycle assignment, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_in_a_write_cycle = cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = epcs_flash_controller_0_epcs_control_port_in_a_write_cycle;

  assign wait_for_epcs_flash_controller_0_epcs_control_port_counter = 0;
  //assign epcs_flash_controller_0_epcs_control_port_irq_from_sa = epcs_flash_controller_0_epcs_control_port_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign epcs_flash_controller_0_epcs_control_port_irq_from_sa = epcs_flash_controller_0_epcs_control_port_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //epcs_flash_controller_0/epcs_control_port enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port + cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_saved_grant_epcs_flash_controller_0_epcs_control_port + cpu_0_instruction_master_saved_grant_epcs_flash_controller_0_epcs_control_port > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module freq_word_s1_arbitrator (
                                 // inputs:
                                  clk,
                                  cpu_0_data_master_address_to_slave,
                                  cpu_0_data_master_read,
                                  cpu_0_data_master_waitrequest,
                                  cpu_0_data_master_write,
                                  cpu_0_data_master_writedata,
                                  freq_word_s1_readdata,
                                  reset_n,

                                 // outputs:
                                  cpu_0_data_master_granted_freq_word_s1,
                                  cpu_0_data_master_qualified_request_freq_word_s1,
                                  cpu_0_data_master_read_data_valid_freq_word_s1,
                                  cpu_0_data_master_requests_freq_word_s1,
                                  d1_freq_word_s1_end_xfer,
                                  freq_word_s1_address,
                                  freq_word_s1_chipselect,
                                  freq_word_s1_readdata_from_sa,
                                  freq_word_s1_reset_n,
                                  freq_word_s1_write_n,
                                  freq_word_s1_writedata
                               )
;

  output           cpu_0_data_master_granted_freq_word_s1;
  output           cpu_0_data_master_qualified_request_freq_word_s1;
  output           cpu_0_data_master_read_data_valid_freq_word_s1;
  output           cpu_0_data_master_requests_freq_word_s1;
  output           d1_freq_word_s1_end_xfer;
  output  [  1: 0] freq_word_s1_address;
  output           freq_word_s1_chipselect;
  output  [ 22: 0] freq_word_s1_readdata_from_sa;
  output           freq_word_s1_reset_n;
  output           freq_word_s1_write_n;
  output  [ 22: 0] freq_word_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input   [ 22: 0] freq_word_s1_readdata;
  input            reset_n;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_freq_word_s1;
  wire             cpu_0_data_master_qualified_request_freq_word_s1;
  wire             cpu_0_data_master_read_data_valid_freq_word_s1;
  wire             cpu_0_data_master_requests_freq_word_s1;
  wire             cpu_0_data_master_saved_grant_freq_word_s1;
  reg              d1_freq_word_s1_end_xfer;
  reg              d1_reasons_to_wait;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_freq_word_s1;
  wire    [  1: 0] freq_word_s1_address;
  wire             freq_word_s1_allgrants;
  wire             freq_word_s1_allow_new_arb_cycle;
  wire             freq_word_s1_any_bursting_master_saved_grant;
  wire             freq_word_s1_any_continuerequest;
  wire             freq_word_s1_arb_counter_enable;
  reg     [  1: 0] freq_word_s1_arb_share_counter;
  wire    [  1: 0] freq_word_s1_arb_share_counter_next_value;
  wire    [  1: 0] freq_word_s1_arb_share_set_values;
  wire             freq_word_s1_beginbursttransfer_internal;
  wire             freq_word_s1_begins_xfer;
  wire             freq_word_s1_chipselect;
  wire             freq_word_s1_end_xfer;
  wire             freq_word_s1_firsttransfer;
  wire             freq_word_s1_grant_vector;
  wire             freq_word_s1_in_a_read_cycle;
  wire             freq_word_s1_in_a_write_cycle;
  wire             freq_word_s1_master_qreq_vector;
  wire             freq_word_s1_non_bursting_master_requests;
  wire    [ 22: 0] freq_word_s1_readdata_from_sa;
  reg              freq_word_s1_reg_firsttransfer;
  wire             freq_word_s1_reset_n;
  reg              freq_word_s1_slavearbiterlockenable;
  wire             freq_word_s1_slavearbiterlockenable2;
  wire             freq_word_s1_unreg_firsttransfer;
  wire             freq_word_s1_waits_for_read;
  wire             freq_word_s1_waits_for_write;
  wire             freq_word_s1_write_n;
  wire    [ 22: 0] freq_word_s1_writedata;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_freq_word_s1_from_cpu_0_data_master;
  wire             wait_for_freq_word_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~freq_word_s1_end_xfer;
    end


  assign freq_word_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_freq_word_s1));
  //assign freq_word_s1_readdata_from_sa = freq_word_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign freq_word_s1_readdata_from_sa = freq_word_s1_readdata;

  assign cpu_0_data_master_requests_freq_word_s1 = ({cpu_0_data_master_address_to_slave[24 : 4] , 4'b0} == 25'h1002060) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //freq_word_s1_arb_share_counter set values, which is an e_mux
  assign freq_word_s1_arb_share_set_values = 1;

  //freq_word_s1_non_bursting_master_requests mux, which is an e_mux
  assign freq_word_s1_non_bursting_master_requests = cpu_0_data_master_requests_freq_word_s1;

  //freq_word_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign freq_word_s1_any_bursting_master_saved_grant = 0;

  //freq_word_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign freq_word_s1_arb_share_counter_next_value = freq_word_s1_firsttransfer ? (freq_word_s1_arb_share_set_values - 1) : |freq_word_s1_arb_share_counter ? (freq_word_s1_arb_share_counter - 1) : 0;

  //freq_word_s1_allgrants all slave grants, which is an e_mux
  assign freq_word_s1_allgrants = |freq_word_s1_grant_vector;

  //freq_word_s1_end_xfer assignment, which is an e_assign
  assign freq_word_s1_end_xfer = ~(freq_word_s1_waits_for_read | freq_word_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_freq_word_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_freq_word_s1 = freq_word_s1_end_xfer & (~freq_word_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //freq_word_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign freq_word_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_freq_word_s1 & freq_word_s1_allgrants) | (end_xfer_arb_share_counter_term_freq_word_s1 & ~freq_word_s1_non_bursting_master_requests);

  //freq_word_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          freq_word_s1_arb_share_counter <= 0;
      else if (freq_word_s1_arb_counter_enable)
          freq_word_s1_arb_share_counter <= freq_word_s1_arb_share_counter_next_value;
    end


  //freq_word_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          freq_word_s1_slavearbiterlockenable <= 0;
      else if ((|freq_word_s1_master_qreq_vector & end_xfer_arb_share_counter_term_freq_word_s1) | (end_xfer_arb_share_counter_term_freq_word_s1 & ~freq_word_s1_non_bursting_master_requests))
          freq_word_s1_slavearbiterlockenable <= |freq_word_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master freq_word/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = freq_word_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //freq_word_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign freq_word_s1_slavearbiterlockenable2 = |freq_word_s1_arb_share_counter_next_value;

  //cpu_0/data_master freq_word/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = freq_word_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //freq_word_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign freq_word_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_freq_word_s1 = cpu_0_data_master_requests_freq_word_s1 & ~(((~cpu_0_data_master_waitrequest) & cpu_0_data_master_write));
  //freq_word_s1_writedata mux, which is an e_mux
  assign freq_word_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_freq_word_s1 = cpu_0_data_master_qualified_request_freq_word_s1;

  //cpu_0/data_master saved-grant freq_word/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_freq_word_s1 = cpu_0_data_master_requests_freq_word_s1;

  //allow new arb cycle for freq_word/s1, which is an e_assign
  assign freq_word_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign freq_word_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign freq_word_s1_master_qreq_vector = 1;

  //freq_word_s1_reset_n assignment, which is an e_assign
  assign freq_word_s1_reset_n = reset_n;

  assign freq_word_s1_chipselect = cpu_0_data_master_granted_freq_word_s1;
  //freq_word_s1_firsttransfer first transaction, which is an e_assign
  assign freq_word_s1_firsttransfer = freq_word_s1_begins_xfer ? freq_word_s1_unreg_firsttransfer : freq_word_s1_reg_firsttransfer;

  //freq_word_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign freq_word_s1_unreg_firsttransfer = ~(freq_word_s1_slavearbiterlockenable & freq_word_s1_any_continuerequest);

  //freq_word_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          freq_word_s1_reg_firsttransfer <= 1'b1;
      else if (freq_word_s1_begins_xfer)
          freq_word_s1_reg_firsttransfer <= freq_word_s1_unreg_firsttransfer;
    end


  //freq_word_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign freq_word_s1_beginbursttransfer_internal = freq_word_s1_begins_xfer;

  //~freq_word_s1_write_n assignment, which is an e_mux
  assign freq_word_s1_write_n = ~(cpu_0_data_master_granted_freq_word_s1 & cpu_0_data_master_write);

  assign shifted_address_to_freq_word_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //freq_word_s1_address mux, which is an e_mux
  assign freq_word_s1_address = shifted_address_to_freq_word_s1_from_cpu_0_data_master >> 2;

  //d1_freq_word_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_freq_word_s1_end_xfer <= 1;
      else 
        d1_freq_word_s1_end_xfer <= freq_word_s1_end_xfer;
    end


  //freq_word_s1_waits_for_read in a cycle, which is an e_mux
  assign freq_word_s1_waits_for_read = freq_word_s1_in_a_read_cycle & freq_word_s1_begins_xfer;

  //freq_word_s1_in_a_read_cycle assignment, which is an e_assign
  assign freq_word_s1_in_a_read_cycle = cpu_0_data_master_granted_freq_word_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = freq_word_s1_in_a_read_cycle;

  //freq_word_s1_waits_for_write in a cycle, which is an e_mux
  assign freq_word_s1_waits_for_write = freq_word_s1_in_a_write_cycle & 0;

  //freq_word_s1_in_a_write_cycle assignment, which is an e_assign
  assign freq_word_s1_in_a_write_cycle = cpu_0_data_master_granted_freq_word_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = freq_word_s1_in_a_write_cycle;

  assign wait_for_freq_word_s1_counter = 0;

//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //freq_word/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_0_data_master_to_sdram_0_s1_module (
                                                             // inputs:
                                                              clear_fifo,
                                                              clk,
                                                              data_in,
                                                              read,
                                                              reset_n,
                                                              sync_reset,
                                                              write,

                                                             // outputs:
                                                              data_out,
                                                              empty,
                                                              fifo_contains_ones_n,
                                                              full
                                                           )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  reg              full_6;
  wire             full_7;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  wire             p6_full_6;
  wire             p6_stage_6;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  reg              stage_6;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_6;
  assign empty = !full_0;
  assign full_7 = 0;
  //data_6, which is an e_mux
  assign p6_stage_6 = ((full_7 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_6 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_6))
          if (sync_reset & full_6 & !((full_7 == 0) & read & write))
              stage_6 <= 0;
          else 
            stage_6 <= p6_stage_6;
    end


  //control_6, which is an e_mux
  assign p6_full_6 = ((read & !write) == 0)? full_5 :
    0;

  //control_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_6 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_6 <= 0;
          else 
            full_6 <= p6_full_6;
    end


  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    stage_6;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    full_6;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module rdv_fifo_for_cpu_0_instruction_master_to_sdram_0_s1_module (
                                                                    // inputs:
                                                                     clear_fifo,
                                                                     clk,
                                                                     data_in,
                                                                     read,
                                                                     reset_n,
                                                                     sync_reset,
                                                                     write,

                                                                    // outputs:
                                                                     data_out,
                                                                     empty,
                                                                     fifo_contains_ones_n,
                                                                     full
                                                                  )
;

  output           data_out;
  output           empty;
  output           fifo_contains_ones_n;
  output           full;
  input            clear_fifo;
  input            clk;
  input            data_in;
  input            read;
  input            reset_n;
  input            sync_reset;
  input            write;

  wire             data_out;
  wire             empty;
  reg              fifo_contains_ones_n;
  wire             full;
  reg              full_0;
  reg              full_1;
  reg              full_2;
  reg              full_3;
  reg              full_4;
  reg              full_5;
  reg              full_6;
  wire             full_7;
  reg     [  3: 0] how_many_ones;
  wire    [  3: 0] one_count_minus_one;
  wire    [  3: 0] one_count_plus_one;
  wire             p0_full_0;
  wire             p0_stage_0;
  wire             p1_full_1;
  wire             p1_stage_1;
  wire             p2_full_2;
  wire             p2_stage_2;
  wire             p3_full_3;
  wire             p3_stage_3;
  wire             p4_full_4;
  wire             p4_stage_4;
  wire             p5_full_5;
  wire             p5_stage_5;
  wire             p6_full_6;
  wire             p6_stage_6;
  reg              stage_0;
  reg              stage_1;
  reg              stage_2;
  reg              stage_3;
  reg              stage_4;
  reg              stage_5;
  reg              stage_6;
  wire    [  3: 0] updated_one_count;
  assign data_out = stage_0;
  assign full = full_6;
  assign empty = !full_0;
  assign full_7 = 0;
  //data_6, which is an e_mux
  assign p6_stage_6 = ((full_7 & ~clear_fifo) == 0)? data_in :
    data_in;

  //data_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_6 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_6))
          if (sync_reset & full_6 & !((full_7 == 0) & read & write))
              stage_6 <= 0;
          else 
            stage_6 <= p6_stage_6;
    end


  //control_6, which is an e_mux
  assign p6_full_6 = ((read & !write) == 0)? full_5 :
    0;

  //control_reg_6, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_6 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_6 <= 0;
          else 
            full_6 <= p6_full_6;
    end


  //data_5, which is an e_mux
  assign p5_stage_5 = ((full_6 & ~clear_fifo) == 0)? data_in :
    stage_6;

  //data_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_5 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_5))
          if (sync_reset & full_5 & !((full_6 == 0) & read & write))
              stage_5 <= 0;
          else 
            stage_5 <= p5_stage_5;
    end


  //control_5, which is an e_mux
  assign p5_full_5 = ((read & !write) == 0)? full_4 :
    full_6;

  //control_reg_5, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_5 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_5 <= 0;
          else 
            full_5 <= p5_full_5;
    end


  //data_4, which is an e_mux
  assign p4_stage_4 = ((full_5 & ~clear_fifo) == 0)? data_in :
    stage_5;

  //data_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_4 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_4))
          if (sync_reset & full_4 & !((full_5 == 0) & read & write))
              stage_4 <= 0;
          else 
            stage_4 <= p4_stage_4;
    end


  //control_4, which is an e_mux
  assign p4_full_4 = ((read & !write) == 0)? full_3 :
    full_5;

  //control_reg_4, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_4 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_4 <= 0;
          else 
            full_4 <= p4_full_4;
    end


  //data_3, which is an e_mux
  assign p3_stage_3 = ((full_4 & ~clear_fifo) == 0)? data_in :
    stage_4;

  //data_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_3 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_3))
          if (sync_reset & full_3 & !((full_4 == 0) & read & write))
              stage_3 <= 0;
          else 
            stage_3 <= p3_stage_3;
    end


  //control_3, which is an e_mux
  assign p3_full_3 = ((read & !write) == 0)? full_2 :
    full_4;

  //control_reg_3, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_3 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_3 <= 0;
          else 
            full_3 <= p3_full_3;
    end


  //data_2, which is an e_mux
  assign p2_stage_2 = ((full_3 & ~clear_fifo) == 0)? data_in :
    stage_3;

  //data_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_2 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_2))
          if (sync_reset & full_2 & !((full_3 == 0) & read & write))
              stage_2 <= 0;
          else 
            stage_2 <= p2_stage_2;
    end


  //control_2, which is an e_mux
  assign p2_full_2 = ((read & !write) == 0)? full_1 :
    full_3;

  //control_reg_2, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_2 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_2 <= 0;
          else 
            full_2 <= p2_full_2;
    end


  //data_1, which is an e_mux
  assign p1_stage_1 = ((full_2 & ~clear_fifo) == 0)? data_in :
    stage_2;

  //data_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_1 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_1))
          if (sync_reset & full_1 & !((full_2 == 0) & read & write))
              stage_1 <= 0;
          else 
            stage_1 <= p1_stage_1;
    end


  //control_1, which is an e_mux
  assign p1_full_1 = ((read & !write) == 0)? full_0 :
    full_2;

  //control_reg_1, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_1 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo)
              full_1 <= 0;
          else 
            full_1 <= p1_full_1;
    end


  //data_0, which is an e_mux
  assign p0_stage_0 = ((full_1 & ~clear_fifo) == 0)? data_in :
    stage_1;

  //data_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          stage_0 <= 0;
      else if (clear_fifo | sync_reset | read | (write & !full_0))
          if (sync_reset & full_0 & !((full_1 == 0) & read & write))
              stage_0 <= 0;
          else 
            stage_0 <= p0_stage_0;
    end


  //control_0, which is an e_mux
  assign p0_full_0 = ((read & !write) == 0)? 1 :
    full_1;

  //control_reg_0, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          full_0 <= 0;
      else if (clear_fifo | (read ^ write) | (write & !full_0))
          if (clear_fifo & ~write)
              full_0 <= 0;
          else 
            full_0 <= p0_full_0;
    end


  assign one_count_plus_one = how_many_ones + 1;
  assign one_count_minus_one = how_many_ones - 1;
  //updated_one_count, which is an e_mux
  assign updated_one_count = ((((clear_fifo | sync_reset) & !write)))? 0 :
    ((((clear_fifo | sync_reset) & write)))? |data_in :
    ((read & (|data_in) & write & (|stage_0)))? how_many_ones :
    ((write & (|data_in)))? one_count_plus_one :
    ((read & (|stage_0)))? one_count_minus_one :
    how_many_ones;

  //counts how many ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          how_many_ones <= 0;
      else if (clear_fifo | sync_reset | read | write)
          how_many_ones <= updated_one_count;
    end


  //this fifo contains ones in the data pipeline, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          fifo_contains_ones_n <= 1;
      else if (clear_fifo | sync_reset | read | write)
          fifo_contains_ones_n <= ~(|updated_one_count);
    end



endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module sdram_0_s1_arbitrator (
                               // inputs:
                                clk,
                                cpu_0_data_master_address_to_slave,
                                cpu_0_data_master_byteenable,
                                cpu_0_data_master_dbs_address,
                                cpu_0_data_master_dbs_write_16,
                                cpu_0_data_master_no_byte_enables_and_last_term,
                                cpu_0_data_master_read,
                                cpu_0_data_master_waitrequest,
                                cpu_0_data_master_write,
                                cpu_0_instruction_master_address_to_slave,
                                cpu_0_instruction_master_dbs_address,
                                cpu_0_instruction_master_read,
                                reset_n,
                                sdram_0_s1_readdata,
                                sdram_0_s1_readdatavalid,
                                sdram_0_s1_waitrequest,

                               // outputs:
                                cpu_0_data_master_byteenable_sdram_0_s1,
                                cpu_0_data_master_granted_sdram_0_s1,
                                cpu_0_data_master_qualified_request_sdram_0_s1,
                                cpu_0_data_master_read_data_valid_sdram_0_s1,
                                cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register,
                                cpu_0_data_master_requests_sdram_0_s1,
                                cpu_0_instruction_master_granted_sdram_0_s1,
                                cpu_0_instruction_master_qualified_request_sdram_0_s1,
                                cpu_0_instruction_master_read_data_valid_sdram_0_s1,
                                cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register,
                                cpu_0_instruction_master_requests_sdram_0_s1,
                                d1_sdram_0_s1_end_xfer,
                                sdram_0_s1_address,
                                sdram_0_s1_byteenable_n,
                                sdram_0_s1_chipselect,
                                sdram_0_s1_read_n,
                                sdram_0_s1_readdata_from_sa,
                                sdram_0_s1_reset_n,
                                sdram_0_s1_waitrequest_from_sa,
                                sdram_0_s1_write_n,
                                sdram_0_s1_writedata
                             )
;

  output  [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1;
  output           cpu_0_data_master_granted_sdram_0_s1;
  output           cpu_0_data_master_qualified_request_sdram_0_s1;
  output           cpu_0_data_master_read_data_valid_sdram_0_s1;
  output           cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register;
  output           cpu_0_data_master_requests_sdram_0_s1;
  output           cpu_0_instruction_master_granted_sdram_0_s1;
  output           cpu_0_instruction_master_qualified_request_sdram_0_s1;
  output           cpu_0_instruction_master_read_data_valid_sdram_0_s1;
  output           cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register;
  output           cpu_0_instruction_master_requests_sdram_0_s1;
  output           d1_sdram_0_s1_end_xfer;
  output  [ 21: 0] sdram_0_s1_address;
  output  [  1: 0] sdram_0_s1_byteenable_n;
  output           sdram_0_s1_chipselect;
  output           sdram_0_s1_read_n;
  output  [ 15: 0] sdram_0_s1_readdata_from_sa;
  output           sdram_0_s1_reset_n;
  output           sdram_0_s1_waitrequest_from_sa;
  output           sdram_0_s1_write_n;
  output  [ 15: 0] sdram_0_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input   [  3: 0] cpu_0_data_master_byteenable;
  input   [  1: 0] cpu_0_data_master_dbs_address;
  input   [ 15: 0] cpu_0_data_master_dbs_write_16;
  input            cpu_0_data_master_no_byte_enables_and_last_term;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_waitrequest;
  input            cpu_0_data_master_write;
  input   [ 24: 0] cpu_0_instruction_master_address_to_slave;
  input   [  1: 0] cpu_0_instruction_master_dbs_address;
  input            cpu_0_instruction_master_read;
  input            reset_n;
  input   [ 15: 0] sdram_0_s1_readdata;
  input            sdram_0_s1_readdatavalid;
  input            sdram_0_s1_waitrequest;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire    [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1;
  wire    [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1_segment_0;
  wire    [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1_segment_1;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_sdram_0_s1;
  wire             cpu_0_data_master_qualified_request_sdram_0_s1;
  wire             cpu_0_data_master_rdv_fifo_empty_sdram_0_s1;
  wire             cpu_0_data_master_rdv_fifo_output_from_sdram_0_s1;
  wire             cpu_0_data_master_read_data_valid_sdram_0_s1;
  wire             cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register;
  wire             cpu_0_data_master_requests_sdram_0_s1;
  wire             cpu_0_data_master_saved_grant_sdram_0_s1;
  wire             cpu_0_instruction_master_arbiterlock;
  wire             cpu_0_instruction_master_arbiterlock2;
  wire             cpu_0_instruction_master_continuerequest;
  wire             cpu_0_instruction_master_granted_sdram_0_s1;
  wire             cpu_0_instruction_master_qualified_request_sdram_0_s1;
  wire             cpu_0_instruction_master_rdv_fifo_empty_sdram_0_s1;
  wire             cpu_0_instruction_master_rdv_fifo_output_from_sdram_0_s1;
  wire             cpu_0_instruction_master_read_data_valid_sdram_0_s1;
  wire             cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register;
  wire             cpu_0_instruction_master_requests_sdram_0_s1;
  wire             cpu_0_instruction_master_saved_grant_sdram_0_s1;
  reg              d1_reasons_to_wait;
  reg              d1_sdram_0_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_sdram_0_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  reg              last_cycle_cpu_0_data_master_granted_slave_sdram_0_s1;
  reg              last_cycle_cpu_0_instruction_master_granted_slave_sdram_0_s1;
  wire    [ 21: 0] sdram_0_s1_address;
  wire             sdram_0_s1_allgrants;
  wire             sdram_0_s1_allow_new_arb_cycle;
  wire             sdram_0_s1_any_bursting_master_saved_grant;
  wire             sdram_0_s1_any_continuerequest;
  reg     [  1: 0] sdram_0_s1_arb_addend;
  wire             sdram_0_s1_arb_counter_enable;
  reg     [  1: 0] sdram_0_s1_arb_share_counter;
  wire    [  1: 0] sdram_0_s1_arb_share_counter_next_value;
  wire    [  1: 0] sdram_0_s1_arb_share_set_values;
  wire    [  1: 0] sdram_0_s1_arb_winner;
  wire             sdram_0_s1_arbitration_holdoff_internal;
  wire             sdram_0_s1_beginbursttransfer_internal;
  wire             sdram_0_s1_begins_xfer;
  wire    [  1: 0] sdram_0_s1_byteenable_n;
  wire             sdram_0_s1_chipselect;
  wire    [  3: 0] sdram_0_s1_chosen_master_double_vector;
  wire    [  1: 0] sdram_0_s1_chosen_master_rot_left;
  wire             sdram_0_s1_end_xfer;
  wire             sdram_0_s1_firsttransfer;
  wire    [  1: 0] sdram_0_s1_grant_vector;
  wire             sdram_0_s1_in_a_read_cycle;
  wire             sdram_0_s1_in_a_write_cycle;
  wire    [  1: 0] sdram_0_s1_master_qreq_vector;
  wire             sdram_0_s1_move_on_to_next_transaction;
  wire             sdram_0_s1_non_bursting_master_requests;
  wire             sdram_0_s1_read_n;
  wire    [ 15: 0] sdram_0_s1_readdata_from_sa;
  wire             sdram_0_s1_readdatavalid_from_sa;
  reg              sdram_0_s1_reg_firsttransfer;
  wire             sdram_0_s1_reset_n;
  reg     [  1: 0] sdram_0_s1_saved_chosen_master_vector;
  reg              sdram_0_s1_slavearbiterlockenable;
  wire             sdram_0_s1_slavearbiterlockenable2;
  wire             sdram_0_s1_unreg_firsttransfer;
  wire             sdram_0_s1_waitrequest_from_sa;
  wire             sdram_0_s1_waits_for_read;
  wire             sdram_0_s1_waits_for_write;
  wire             sdram_0_s1_write_n;
  wire    [ 15: 0] sdram_0_s1_writedata;
  wire    [ 24: 0] shifted_address_to_sdram_0_s1_from_cpu_0_data_master;
  wire    [ 24: 0] shifted_address_to_sdram_0_s1_from_cpu_0_instruction_master;
  wire             wait_for_sdram_0_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~sdram_0_s1_end_xfer;
    end


  assign sdram_0_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_sdram_0_s1 | cpu_0_instruction_master_qualified_request_sdram_0_s1));
  //assign sdram_0_s1_readdata_from_sa = sdram_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_0_s1_readdata_from_sa = sdram_0_s1_readdata;

  assign cpu_0_data_master_requests_sdram_0_s1 = ({cpu_0_data_master_address_to_slave[24 : 23] , 23'b0} == 25'h800000) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //assign sdram_0_s1_waitrequest_from_sa = sdram_0_s1_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_0_s1_waitrequest_from_sa = sdram_0_s1_waitrequest;

  //assign sdram_0_s1_readdatavalid_from_sa = sdram_0_s1_readdatavalid so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign sdram_0_s1_readdatavalid_from_sa = sdram_0_s1_readdatavalid;

  //sdram_0_s1_arb_share_counter set values, which is an e_mux
  assign sdram_0_s1_arb_share_set_values = (cpu_0_data_master_granted_sdram_0_s1)? 2 :
    (cpu_0_instruction_master_granted_sdram_0_s1)? 2 :
    (cpu_0_data_master_granted_sdram_0_s1)? 2 :
    (cpu_0_instruction_master_granted_sdram_0_s1)? 2 :
    1;

  //sdram_0_s1_non_bursting_master_requests mux, which is an e_mux
  assign sdram_0_s1_non_bursting_master_requests = cpu_0_data_master_requests_sdram_0_s1 |
    cpu_0_instruction_master_requests_sdram_0_s1 |
    cpu_0_data_master_requests_sdram_0_s1 |
    cpu_0_instruction_master_requests_sdram_0_s1;

  //sdram_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign sdram_0_s1_any_bursting_master_saved_grant = 0;

  //sdram_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign sdram_0_s1_arb_share_counter_next_value = sdram_0_s1_firsttransfer ? (sdram_0_s1_arb_share_set_values - 1) : |sdram_0_s1_arb_share_counter ? (sdram_0_s1_arb_share_counter - 1) : 0;

  //sdram_0_s1_allgrants all slave grants, which is an e_mux
  assign sdram_0_s1_allgrants = (|sdram_0_s1_grant_vector) |
    (|sdram_0_s1_grant_vector) |
    (|sdram_0_s1_grant_vector) |
    (|sdram_0_s1_grant_vector);

  //sdram_0_s1_end_xfer assignment, which is an e_assign
  assign sdram_0_s1_end_xfer = ~(sdram_0_s1_waits_for_read | sdram_0_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_sdram_0_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_sdram_0_s1 = sdram_0_s1_end_xfer & (~sdram_0_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //sdram_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign sdram_0_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_sdram_0_s1 & sdram_0_s1_allgrants) | (end_xfer_arb_share_counter_term_sdram_0_s1 & ~sdram_0_s1_non_bursting_master_requests);

  //sdram_0_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_0_s1_arb_share_counter <= 0;
      else if (sdram_0_s1_arb_counter_enable)
          sdram_0_s1_arb_share_counter <= sdram_0_s1_arb_share_counter_next_value;
    end


  //sdram_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_0_s1_slavearbiterlockenable <= 0;
      else if ((|sdram_0_s1_master_qreq_vector & end_xfer_arb_share_counter_term_sdram_0_s1) | (end_xfer_arb_share_counter_term_sdram_0_s1 & ~sdram_0_s1_non_bursting_master_requests))
          sdram_0_s1_slavearbiterlockenable <= |sdram_0_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master sdram_0/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = sdram_0_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //sdram_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign sdram_0_s1_slavearbiterlockenable2 = |sdram_0_s1_arb_share_counter_next_value;

  //cpu_0/data_master sdram_0/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = sdram_0_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //cpu_0/instruction_master sdram_0/s1 arbiterlock, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock = sdram_0_s1_slavearbiterlockenable & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master sdram_0/s1 arbiterlock2, which is an e_assign
  assign cpu_0_instruction_master_arbiterlock2 = sdram_0_s1_slavearbiterlockenable2 & cpu_0_instruction_master_continuerequest;

  //cpu_0/instruction_master granted sdram_0/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_instruction_master_granted_slave_sdram_0_s1 <= 0;
      else 
        last_cycle_cpu_0_instruction_master_granted_slave_sdram_0_s1 <= cpu_0_instruction_master_saved_grant_sdram_0_s1 ? 1 : (sdram_0_s1_arbitration_holdoff_internal | ~cpu_0_instruction_master_requests_sdram_0_s1) ? 0 : last_cycle_cpu_0_instruction_master_granted_slave_sdram_0_s1;
    end


  //cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  assign cpu_0_instruction_master_continuerequest = last_cycle_cpu_0_instruction_master_granted_slave_sdram_0_s1 & cpu_0_instruction_master_requests_sdram_0_s1;

  //sdram_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  assign sdram_0_s1_any_continuerequest = cpu_0_instruction_master_continuerequest |
    cpu_0_data_master_continuerequest;

  assign cpu_0_data_master_qualified_request_sdram_0_s1 = cpu_0_data_master_requests_sdram_0_s1 & ~((cpu_0_data_master_read & (~cpu_0_data_master_waitrequest | (|cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register))) | ((~cpu_0_data_master_waitrequest | cpu_0_data_master_no_byte_enables_and_last_term | !cpu_0_data_master_byteenable_sdram_0_s1) & cpu_0_data_master_write) | cpu_0_instruction_master_arbiterlock);
  //unique name for sdram_0_s1_move_on_to_next_transaction, which is an e_assign
  assign sdram_0_s1_move_on_to_next_transaction = sdram_0_s1_readdatavalid_from_sa;

  //rdv_fifo_for_cpu_0_data_master_to_sdram_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_0_data_master_to_sdram_0_s1_module rdv_fifo_for_cpu_0_data_master_to_sdram_0_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_0_data_master_granted_sdram_0_s1),
      .data_out             (cpu_0_data_master_rdv_fifo_output_from_sdram_0_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_0_data_master_rdv_fifo_empty_sdram_0_s1),
      .full                 (),
      .read                 (sdram_0_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_0_s1_waits_for_read)
    );

  assign cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register = ~cpu_0_data_master_rdv_fifo_empty_sdram_0_s1;
  //local readdatavalid cpu_0_data_master_read_data_valid_sdram_0_s1, which is an e_mux
  assign cpu_0_data_master_read_data_valid_sdram_0_s1 = (sdram_0_s1_readdatavalid_from_sa & cpu_0_data_master_rdv_fifo_output_from_sdram_0_s1) & ~ cpu_0_data_master_rdv_fifo_empty_sdram_0_s1;

  //sdram_0_s1_writedata mux, which is an e_mux
  assign sdram_0_s1_writedata = cpu_0_data_master_dbs_write_16;

  assign cpu_0_instruction_master_requests_sdram_0_s1 = (({cpu_0_instruction_master_address_to_slave[24 : 23] , 23'b0} == 25'h800000) & (cpu_0_instruction_master_read)) & cpu_0_instruction_master_read;
  //cpu_0/data_master granted sdram_0/s1 last time, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          last_cycle_cpu_0_data_master_granted_slave_sdram_0_s1 <= 0;
      else 
        last_cycle_cpu_0_data_master_granted_slave_sdram_0_s1 <= cpu_0_data_master_saved_grant_sdram_0_s1 ? 1 : (sdram_0_s1_arbitration_holdoff_internal | ~cpu_0_data_master_requests_sdram_0_s1) ? 0 : last_cycle_cpu_0_data_master_granted_slave_sdram_0_s1;
    end


  //cpu_0_data_master_continuerequest continued request, which is an e_mux
  assign cpu_0_data_master_continuerequest = last_cycle_cpu_0_data_master_granted_slave_sdram_0_s1 & cpu_0_data_master_requests_sdram_0_s1;

  assign cpu_0_instruction_master_qualified_request_sdram_0_s1 = cpu_0_instruction_master_requests_sdram_0_s1 & ~((cpu_0_instruction_master_read & ((|cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register))) | cpu_0_data_master_arbiterlock);
  //rdv_fifo_for_cpu_0_instruction_master_to_sdram_0_s1, which is an e_fifo_with_registered_outputs
  rdv_fifo_for_cpu_0_instruction_master_to_sdram_0_s1_module rdv_fifo_for_cpu_0_instruction_master_to_sdram_0_s1
    (
      .clear_fifo           (1'b0),
      .clk                  (clk),
      .data_in              (cpu_0_instruction_master_granted_sdram_0_s1),
      .data_out             (cpu_0_instruction_master_rdv_fifo_output_from_sdram_0_s1),
      .empty                (),
      .fifo_contains_ones_n (cpu_0_instruction_master_rdv_fifo_empty_sdram_0_s1),
      .full                 (),
      .read                 (sdram_0_s1_move_on_to_next_transaction),
      .reset_n              (reset_n),
      .sync_reset           (1'b0),
      .write                (in_a_read_cycle & ~sdram_0_s1_waits_for_read)
    );

  assign cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register = ~cpu_0_instruction_master_rdv_fifo_empty_sdram_0_s1;
  //local readdatavalid cpu_0_instruction_master_read_data_valid_sdram_0_s1, which is an e_mux
  assign cpu_0_instruction_master_read_data_valid_sdram_0_s1 = (sdram_0_s1_readdatavalid_from_sa & cpu_0_instruction_master_rdv_fifo_output_from_sdram_0_s1) & ~ cpu_0_instruction_master_rdv_fifo_empty_sdram_0_s1;

  //allow new arb cycle for sdram_0/s1, which is an e_assign
  assign sdram_0_s1_allow_new_arb_cycle = ~cpu_0_data_master_arbiterlock & ~cpu_0_instruction_master_arbiterlock;

  //cpu_0/instruction_master assignment into master qualified-requests vector for sdram_0/s1, which is an e_assign
  assign sdram_0_s1_master_qreq_vector[0] = cpu_0_instruction_master_qualified_request_sdram_0_s1;

  //cpu_0/instruction_master grant sdram_0/s1, which is an e_assign
  assign cpu_0_instruction_master_granted_sdram_0_s1 = sdram_0_s1_grant_vector[0];

  //cpu_0/instruction_master saved-grant sdram_0/s1, which is an e_assign
  assign cpu_0_instruction_master_saved_grant_sdram_0_s1 = sdram_0_s1_arb_winner[0] && cpu_0_instruction_master_requests_sdram_0_s1;

  //cpu_0/data_master assignment into master qualified-requests vector for sdram_0/s1, which is an e_assign
  assign sdram_0_s1_master_qreq_vector[1] = cpu_0_data_master_qualified_request_sdram_0_s1;

  //cpu_0/data_master grant sdram_0/s1, which is an e_assign
  assign cpu_0_data_master_granted_sdram_0_s1 = sdram_0_s1_grant_vector[1];

  //cpu_0/data_master saved-grant sdram_0/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_sdram_0_s1 = sdram_0_s1_arb_winner[1] && cpu_0_data_master_requests_sdram_0_s1;

  //sdram_0/s1 chosen-master double-vector, which is an e_assign
  assign sdram_0_s1_chosen_master_double_vector = {sdram_0_s1_master_qreq_vector, sdram_0_s1_master_qreq_vector} & ({~sdram_0_s1_master_qreq_vector, ~sdram_0_s1_master_qreq_vector} + sdram_0_s1_arb_addend);

  //stable onehot encoding of arb winner
  assign sdram_0_s1_arb_winner = (sdram_0_s1_allow_new_arb_cycle & | sdram_0_s1_grant_vector) ? sdram_0_s1_grant_vector : sdram_0_s1_saved_chosen_master_vector;

  //saved sdram_0_s1_grant_vector, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_0_s1_saved_chosen_master_vector <= 0;
      else if (sdram_0_s1_allow_new_arb_cycle)
          sdram_0_s1_saved_chosen_master_vector <= |sdram_0_s1_grant_vector ? sdram_0_s1_grant_vector : sdram_0_s1_saved_chosen_master_vector;
    end


  //onehot encoding of chosen master
  assign sdram_0_s1_grant_vector = {(sdram_0_s1_chosen_master_double_vector[1] | sdram_0_s1_chosen_master_double_vector[3]),
    (sdram_0_s1_chosen_master_double_vector[0] | sdram_0_s1_chosen_master_double_vector[2])};

  //sdram_0/s1 chosen master rotated left, which is an e_assign
  assign sdram_0_s1_chosen_master_rot_left = (sdram_0_s1_arb_winner << 1) ? (sdram_0_s1_arb_winner << 1) : 1;

  //sdram_0/s1's addend for next-master-grant
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_0_s1_arb_addend <= 1;
      else if (|sdram_0_s1_grant_vector)
          sdram_0_s1_arb_addend <= sdram_0_s1_end_xfer? sdram_0_s1_chosen_master_rot_left : sdram_0_s1_grant_vector;
    end


  //sdram_0_s1_reset_n assignment, which is an e_assign
  assign sdram_0_s1_reset_n = reset_n;

  assign sdram_0_s1_chipselect = cpu_0_data_master_granted_sdram_0_s1 | cpu_0_instruction_master_granted_sdram_0_s1;
  //sdram_0_s1_firsttransfer first transaction, which is an e_assign
  assign sdram_0_s1_firsttransfer = sdram_0_s1_begins_xfer ? sdram_0_s1_unreg_firsttransfer : sdram_0_s1_reg_firsttransfer;

  //sdram_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign sdram_0_s1_unreg_firsttransfer = ~(sdram_0_s1_slavearbiterlockenable & sdram_0_s1_any_continuerequest);

  //sdram_0_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          sdram_0_s1_reg_firsttransfer <= 1'b1;
      else if (sdram_0_s1_begins_xfer)
          sdram_0_s1_reg_firsttransfer <= sdram_0_s1_unreg_firsttransfer;
    end


  //sdram_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign sdram_0_s1_beginbursttransfer_internal = sdram_0_s1_begins_xfer;

  //sdram_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  assign sdram_0_s1_arbitration_holdoff_internal = sdram_0_s1_begins_xfer & sdram_0_s1_firsttransfer;

  //~sdram_0_s1_read_n assignment, which is an e_mux
  assign sdram_0_s1_read_n = ~((cpu_0_data_master_granted_sdram_0_s1 & cpu_0_data_master_read) | (cpu_0_instruction_master_granted_sdram_0_s1 & cpu_0_instruction_master_read));

  //~sdram_0_s1_write_n assignment, which is an e_mux
  assign sdram_0_s1_write_n = ~(cpu_0_data_master_granted_sdram_0_s1 & cpu_0_data_master_write);

  assign shifted_address_to_sdram_0_s1_from_cpu_0_data_master = {cpu_0_data_master_address_to_slave >> 2,
    cpu_0_data_master_dbs_address[1],
    {1 {1'b0}}};

  //sdram_0_s1_address mux, which is an e_mux
  assign sdram_0_s1_address = (cpu_0_data_master_granted_sdram_0_s1)? (shifted_address_to_sdram_0_s1_from_cpu_0_data_master >> 1) :
    (shifted_address_to_sdram_0_s1_from_cpu_0_instruction_master >> 1);

  assign shifted_address_to_sdram_0_s1_from_cpu_0_instruction_master = {cpu_0_instruction_master_address_to_slave >> 2,
    cpu_0_instruction_master_dbs_address[1],
    {1 {1'b0}}};

  //d1_sdram_0_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_sdram_0_s1_end_xfer <= 1;
      else 
        d1_sdram_0_s1_end_xfer <= sdram_0_s1_end_xfer;
    end


  //sdram_0_s1_waits_for_read in a cycle, which is an e_mux
  assign sdram_0_s1_waits_for_read = sdram_0_s1_in_a_read_cycle & sdram_0_s1_waitrequest_from_sa;

  //sdram_0_s1_in_a_read_cycle assignment, which is an e_assign
  assign sdram_0_s1_in_a_read_cycle = (cpu_0_data_master_granted_sdram_0_s1 & cpu_0_data_master_read) | (cpu_0_instruction_master_granted_sdram_0_s1 & cpu_0_instruction_master_read);

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = sdram_0_s1_in_a_read_cycle;

  //sdram_0_s1_waits_for_write in a cycle, which is an e_mux
  assign sdram_0_s1_waits_for_write = sdram_0_s1_in_a_write_cycle & sdram_0_s1_waitrequest_from_sa;

  //sdram_0_s1_in_a_write_cycle assignment, which is an e_assign
  assign sdram_0_s1_in_a_write_cycle = cpu_0_data_master_granted_sdram_0_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = sdram_0_s1_in_a_write_cycle;

  assign wait_for_sdram_0_s1_counter = 0;
  //~sdram_0_s1_byteenable_n byte enable port mux, which is an e_mux
  assign sdram_0_s1_byteenable_n = ~((cpu_0_data_master_granted_sdram_0_s1)? cpu_0_data_master_byteenable_sdram_0_s1 :
    -1);

  assign {cpu_0_data_master_byteenable_sdram_0_s1_segment_1,
cpu_0_data_master_byteenable_sdram_0_s1_segment_0} = cpu_0_data_master_byteenable;
  assign cpu_0_data_master_byteenable_sdram_0_s1 = ((cpu_0_data_master_dbs_address[1] == 0))? cpu_0_data_master_byteenable_sdram_0_s1_segment_0 :
    cpu_0_data_master_byteenable_sdram_0_s1_segment_1;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //sdram_0/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end


  //grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_granted_sdram_0_s1 + cpu_0_instruction_master_granted_sdram_0_s1 > 1)
        begin
          $write("%0d ns: > 1 of grant signals are active simultaneously", $time);
          $stop;
        end
    end


  //saved_grant signals are active simultaneously, which is an e_process
  always @(posedge clk)
    begin
      if (cpu_0_data_master_saved_grant_sdram_0_s1 + cpu_0_instruction_master_saved_grant_sdram_0_s1 > 1)
        begin
          $write("%0d ns: > 1 of saved_grant signals are active simultaneously", $time);
          $stop;
        end
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module uart_0_s1_arbitrator (
                              // inputs:
                               clk,
                               cpu_0_data_master_address_to_slave,
                               cpu_0_data_master_read,
                               cpu_0_data_master_write,
                               cpu_0_data_master_writedata,
                               reset_n,
                               uart_0_s1_dataavailable,
                               uart_0_s1_irq,
                               uart_0_s1_readdata,
                               uart_0_s1_readyfordata,

                              // outputs:
                               cpu_0_data_master_granted_uart_0_s1,
                               cpu_0_data_master_qualified_request_uart_0_s1,
                               cpu_0_data_master_read_data_valid_uart_0_s1,
                               cpu_0_data_master_requests_uart_0_s1,
                               d1_uart_0_s1_end_xfer,
                               uart_0_s1_address,
                               uart_0_s1_begintransfer,
                               uart_0_s1_chipselect,
                               uart_0_s1_dataavailable_from_sa,
                               uart_0_s1_irq_from_sa,
                               uart_0_s1_read_n,
                               uart_0_s1_readdata_from_sa,
                               uart_0_s1_readyfordata_from_sa,
                               uart_0_s1_reset_n,
                               uart_0_s1_write_n,
                               uart_0_s1_writedata
                            )
;

  output           cpu_0_data_master_granted_uart_0_s1;
  output           cpu_0_data_master_qualified_request_uart_0_s1;
  output           cpu_0_data_master_read_data_valid_uart_0_s1;
  output           cpu_0_data_master_requests_uart_0_s1;
  output           d1_uart_0_s1_end_xfer;
  output  [  2: 0] uart_0_s1_address;
  output           uart_0_s1_begintransfer;
  output           uart_0_s1_chipselect;
  output           uart_0_s1_dataavailable_from_sa;
  output           uart_0_s1_irq_from_sa;
  output           uart_0_s1_read_n;
  output  [ 15: 0] uart_0_s1_readdata_from_sa;
  output           uart_0_s1_readyfordata_from_sa;
  output           uart_0_s1_reset_n;
  output           uart_0_s1_write_n;
  output  [ 15: 0] uart_0_s1_writedata;
  input            clk;
  input   [ 24: 0] cpu_0_data_master_address_to_slave;
  input            cpu_0_data_master_read;
  input            cpu_0_data_master_write;
  input   [ 31: 0] cpu_0_data_master_writedata;
  input            reset_n;
  input            uart_0_s1_dataavailable;
  input            uart_0_s1_irq;
  input   [ 15: 0] uart_0_s1_readdata;
  input            uart_0_s1_readyfordata;

  wire             cpu_0_data_master_arbiterlock;
  wire             cpu_0_data_master_arbiterlock2;
  wire             cpu_0_data_master_continuerequest;
  wire             cpu_0_data_master_granted_uart_0_s1;
  wire             cpu_0_data_master_qualified_request_uart_0_s1;
  wire             cpu_0_data_master_read_data_valid_uart_0_s1;
  wire             cpu_0_data_master_requests_uart_0_s1;
  wire             cpu_0_data_master_saved_grant_uart_0_s1;
  reg              d1_reasons_to_wait;
  reg              d1_uart_0_s1_end_xfer;
  reg              enable_nonzero_assertions;
  wire             end_xfer_arb_share_counter_term_uart_0_s1;
  wire             in_a_read_cycle;
  wire             in_a_write_cycle;
  wire    [ 24: 0] shifted_address_to_uart_0_s1_from_cpu_0_data_master;
  wire    [  2: 0] uart_0_s1_address;
  wire             uart_0_s1_allgrants;
  wire             uart_0_s1_allow_new_arb_cycle;
  wire             uart_0_s1_any_bursting_master_saved_grant;
  wire             uart_0_s1_any_continuerequest;
  wire             uart_0_s1_arb_counter_enable;
  reg     [  1: 0] uart_0_s1_arb_share_counter;
  wire    [  1: 0] uart_0_s1_arb_share_counter_next_value;
  wire    [  1: 0] uart_0_s1_arb_share_set_values;
  wire             uart_0_s1_beginbursttransfer_internal;
  wire             uart_0_s1_begins_xfer;
  wire             uart_0_s1_begintransfer;
  wire             uart_0_s1_chipselect;
  wire             uart_0_s1_dataavailable_from_sa;
  wire             uart_0_s1_end_xfer;
  wire             uart_0_s1_firsttransfer;
  wire             uart_0_s1_grant_vector;
  wire             uart_0_s1_in_a_read_cycle;
  wire             uart_0_s1_in_a_write_cycle;
  wire             uart_0_s1_irq_from_sa;
  wire             uart_0_s1_master_qreq_vector;
  wire             uart_0_s1_non_bursting_master_requests;
  wire             uart_0_s1_read_n;
  wire    [ 15: 0] uart_0_s1_readdata_from_sa;
  wire             uart_0_s1_readyfordata_from_sa;
  reg              uart_0_s1_reg_firsttransfer;
  wire             uart_0_s1_reset_n;
  reg              uart_0_s1_slavearbiterlockenable;
  wire             uart_0_s1_slavearbiterlockenable2;
  wire             uart_0_s1_unreg_firsttransfer;
  wire             uart_0_s1_waits_for_read;
  wire             uart_0_s1_waits_for_write;
  wire             uart_0_s1_write_n;
  wire    [ 15: 0] uart_0_s1_writedata;
  wire             wait_for_uart_0_s1_counter;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_reasons_to_wait <= 0;
      else 
        d1_reasons_to_wait <= ~uart_0_s1_end_xfer;
    end


  assign uart_0_s1_begins_xfer = ~d1_reasons_to_wait & ((cpu_0_data_master_qualified_request_uart_0_s1));
  //assign uart_0_s1_readdata_from_sa = uart_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_0_s1_readdata_from_sa = uart_0_s1_readdata;

  assign cpu_0_data_master_requests_uart_0_s1 = ({cpu_0_data_master_address_to_slave[24 : 5] , 5'b0} == 25'h1002000) & (cpu_0_data_master_read | cpu_0_data_master_write);
  //assign uart_0_s1_dataavailable_from_sa = uart_0_s1_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_0_s1_dataavailable_from_sa = uart_0_s1_dataavailable;

  //assign uart_0_s1_readyfordata_from_sa = uart_0_s1_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_0_s1_readyfordata_from_sa = uart_0_s1_readyfordata;

  //uart_0_s1_arb_share_counter set values, which is an e_mux
  assign uart_0_s1_arb_share_set_values = 1;

  //uart_0_s1_non_bursting_master_requests mux, which is an e_mux
  assign uart_0_s1_non_bursting_master_requests = cpu_0_data_master_requests_uart_0_s1;

  //uart_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  assign uart_0_s1_any_bursting_master_saved_grant = 0;

  //uart_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  assign uart_0_s1_arb_share_counter_next_value = uart_0_s1_firsttransfer ? (uart_0_s1_arb_share_set_values - 1) : |uart_0_s1_arb_share_counter ? (uart_0_s1_arb_share_counter - 1) : 0;

  //uart_0_s1_allgrants all slave grants, which is an e_mux
  assign uart_0_s1_allgrants = |uart_0_s1_grant_vector;

  //uart_0_s1_end_xfer assignment, which is an e_assign
  assign uart_0_s1_end_xfer = ~(uart_0_s1_waits_for_read | uart_0_s1_waits_for_write);

  //end_xfer_arb_share_counter_term_uart_0_s1 arb share counter enable term, which is an e_assign
  assign end_xfer_arb_share_counter_term_uart_0_s1 = uart_0_s1_end_xfer & (~uart_0_s1_any_bursting_master_saved_grant | in_a_read_cycle | in_a_write_cycle);

  //uart_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  assign uart_0_s1_arb_counter_enable = (end_xfer_arb_share_counter_term_uart_0_s1 & uart_0_s1_allgrants) | (end_xfer_arb_share_counter_term_uart_0_s1 & ~uart_0_s1_non_bursting_master_requests);

  //uart_0_s1_arb_share_counter counter, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_0_s1_arb_share_counter <= 0;
      else if (uart_0_s1_arb_counter_enable)
          uart_0_s1_arb_share_counter <= uart_0_s1_arb_share_counter_next_value;
    end


  //uart_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_0_s1_slavearbiterlockenable <= 0;
      else if ((|uart_0_s1_master_qreq_vector & end_xfer_arb_share_counter_term_uart_0_s1) | (end_xfer_arb_share_counter_term_uart_0_s1 & ~uart_0_s1_non_bursting_master_requests))
          uart_0_s1_slavearbiterlockenable <= |uart_0_s1_arb_share_counter_next_value;
    end


  //cpu_0/data_master uart_0/s1 arbiterlock, which is an e_assign
  assign cpu_0_data_master_arbiterlock = uart_0_s1_slavearbiterlockenable & cpu_0_data_master_continuerequest;

  //uart_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  assign uart_0_s1_slavearbiterlockenable2 = |uart_0_s1_arb_share_counter_next_value;

  //cpu_0/data_master uart_0/s1 arbiterlock2, which is an e_assign
  assign cpu_0_data_master_arbiterlock2 = uart_0_s1_slavearbiterlockenable2 & cpu_0_data_master_continuerequest;

  //uart_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  assign uart_0_s1_any_continuerequest = 1;

  //cpu_0_data_master_continuerequest continued request, which is an e_assign
  assign cpu_0_data_master_continuerequest = 1;

  assign cpu_0_data_master_qualified_request_uart_0_s1 = cpu_0_data_master_requests_uart_0_s1;
  //uart_0_s1_writedata mux, which is an e_mux
  assign uart_0_s1_writedata = cpu_0_data_master_writedata;

  //master is always granted when requested
  assign cpu_0_data_master_granted_uart_0_s1 = cpu_0_data_master_qualified_request_uart_0_s1;

  //cpu_0/data_master saved-grant uart_0/s1, which is an e_assign
  assign cpu_0_data_master_saved_grant_uart_0_s1 = cpu_0_data_master_requests_uart_0_s1;

  //allow new arb cycle for uart_0/s1, which is an e_assign
  assign uart_0_s1_allow_new_arb_cycle = 1;

  //placeholder chosen master
  assign uart_0_s1_grant_vector = 1;

  //placeholder vector of master qualified-requests
  assign uart_0_s1_master_qreq_vector = 1;

  assign uart_0_s1_begintransfer = uart_0_s1_begins_xfer;
  //uart_0_s1_reset_n assignment, which is an e_assign
  assign uart_0_s1_reset_n = reset_n;

  assign uart_0_s1_chipselect = cpu_0_data_master_granted_uart_0_s1;
  //uart_0_s1_firsttransfer first transaction, which is an e_assign
  assign uart_0_s1_firsttransfer = uart_0_s1_begins_xfer ? uart_0_s1_unreg_firsttransfer : uart_0_s1_reg_firsttransfer;

  //uart_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  assign uart_0_s1_unreg_firsttransfer = ~(uart_0_s1_slavearbiterlockenable & uart_0_s1_any_continuerequest);

  //uart_0_s1_reg_firsttransfer first transaction, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          uart_0_s1_reg_firsttransfer <= 1'b1;
      else if (uart_0_s1_begins_xfer)
          uart_0_s1_reg_firsttransfer <= uart_0_s1_unreg_firsttransfer;
    end


  //uart_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  assign uart_0_s1_beginbursttransfer_internal = uart_0_s1_begins_xfer;

  //~uart_0_s1_read_n assignment, which is an e_mux
  assign uart_0_s1_read_n = ~(cpu_0_data_master_granted_uart_0_s1 & cpu_0_data_master_read);

  //~uart_0_s1_write_n assignment, which is an e_mux
  assign uart_0_s1_write_n = ~(cpu_0_data_master_granted_uart_0_s1 & cpu_0_data_master_write);

  assign shifted_address_to_uart_0_s1_from_cpu_0_data_master = cpu_0_data_master_address_to_slave;
  //uart_0_s1_address mux, which is an e_mux
  assign uart_0_s1_address = shifted_address_to_uart_0_s1_from_cpu_0_data_master >> 2;

  //d1_uart_0_s1_end_xfer register, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          d1_uart_0_s1_end_xfer <= 1;
      else 
        d1_uart_0_s1_end_xfer <= uart_0_s1_end_xfer;
    end


  //uart_0_s1_waits_for_read in a cycle, which is an e_mux
  assign uart_0_s1_waits_for_read = uart_0_s1_in_a_read_cycle & uart_0_s1_begins_xfer;

  //uart_0_s1_in_a_read_cycle assignment, which is an e_assign
  assign uart_0_s1_in_a_read_cycle = cpu_0_data_master_granted_uart_0_s1 & cpu_0_data_master_read;

  //in_a_read_cycle assignment, which is an e_mux
  assign in_a_read_cycle = uart_0_s1_in_a_read_cycle;

  //uart_0_s1_waits_for_write in a cycle, which is an e_mux
  assign uart_0_s1_waits_for_write = uart_0_s1_in_a_write_cycle & uart_0_s1_begins_xfer;

  //uart_0_s1_in_a_write_cycle assignment, which is an e_assign
  assign uart_0_s1_in_a_write_cycle = cpu_0_data_master_granted_uart_0_s1 & cpu_0_data_master_write;

  //in_a_write_cycle assignment, which is an e_mux
  assign in_a_write_cycle = uart_0_s1_in_a_write_cycle;

  assign wait_for_uart_0_s1_counter = 0;
  //assign uart_0_s1_irq_from_sa = uart_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  assign uart_0_s1_irq_from_sa = uart_0_s1_irq;


//synthesis translate_off
//////////////// SIMULATION-ONLY CONTENTS
  //uart_0/s1 enable non-zero assertions, which is an e_register
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          enable_nonzero_assertions <= 0;
      else 
        enable_nonzero_assertions <= 1'b1;
    end



//////////////// END SIMULATION-ONLY CONTENTS

//synthesis translate_on

endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module AWG_reset_clk_0_domain_synch_module (
                                             // inputs:
                                              clk,
                                              data_in,
                                              reset_n,

                                             // outputs:
                                              data_out
                                           )
;

  output           data_out;
  input            clk;
  input            data_in;
  input            reset_n;

  reg              data_in_d1 /* synthesis ALTERA_ATTRIBUTE = "{-from \"*\"} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  reg              data_out /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;
  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_in_d1 <= 0;
      else 
        data_in_d1 <= data_in;
    end


  always @(posedge clk or negedge reset_n)
    begin
      if (reset_n == 0)
          data_out <= 0;
      else 
        data_out <= data_in_d1;
    end



endmodule



// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10034 10035 10036 10037 10230 10240 10030 

module AWG (
             // 1) global signals:
              clk_0,
              reset_n,

             // the_UART2DPRAM
              out_port_from_the_UART2DPRAM,

             // the_WRaddress
              out_port_from_the_WRaddress,

             // the_dpram_rdclk_en
              out_port_from_the_dpram_rdclk_en,

             // the_dpram_wr_en
              out_port_from_the_dpram_wr_en,

             // the_dpram_wrclk
              out_port_from_the_dpram_wrclk,

             // the_dpram_wrclk_en
              out_port_from_the_dpram_wrclk_en,

             // the_freq_word
              out_port_from_the_freq_word,

             // the_sdram_0
              zs_addr_from_the_sdram_0,
              zs_ba_from_the_sdram_0,
              zs_cas_n_from_the_sdram_0,
              zs_cke_from_the_sdram_0,
              zs_cs_n_from_the_sdram_0,
              zs_dq_to_and_from_the_sdram_0,
              zs_dqm_from_the_sdram_0,
              zs_ras_n_from_the_sdram_0,
              zs_we_n_from_the_sdram_0,

             // the_uart_0
              rxd_to_the_uart_0,
              txd_from_the_uart_0
           )
;

  output  [ 11: 0] out_port_from_the_UART2DPRAM;
  output  [  9: 0] out_port_from_the_WRaddress;
  output           out_port_from_the_dpram_rdclk_en;
  output           out_port_from_the_dpram_wr_en;
  output           out_port_from_the_dpram_wrclk;
  output           out_port_from_the_dpram_wrclk_en;
  output  [ 22: 0] out_port_from_the_freq_word;
  output           txd_from_the_uart_0;
  output  [ 11: 0] zs_addr_from_the_sdram_0;
  output  [  1: 0] zs_ba_from_the_sdram_0;
  output           zs_cas_n_from_the_sdram_0;
  output           zs_cke_from_the_sdram_0;
  output           zs_cs_n_from_the_sdram_0;
  inout   [ 15: 0] zs_dq_to_and_from_the_sdram_0;
  output  [  1: 0] zs_dqm_from_the_sdram_0;
  output           zs_ras_n_from_the_sdram_0;
  output           zs_we_n_from_the_sdram_0;
  input            clk_0;
  input            reset_n;
  input            rxd_to_the_uart_0;

  wire    [  1: 0] UART2DPRAM_s1_address;
  wire             UART2DPRAM_s1_chipselect;
  wire    [ 11: 0] UART2DPRAM_s1_readdata;
  wire    [ 11: 0] UART2DPRAM_s1_readdata_from_sa;
  wire             UART2DPRAM_s1_reset_n;
  wire             UART2DPRAM_s1_write_n;
  wire    [ 11: 0] UART2DPRAM_s1_writedata;
  wire    [  1: 0] WRaddress_s1_address;
  wire             WRaddress_s1_chipselect;
  wire    [  9: 0] WRaddress_s1_readdata;
  wire    [  9: 0] WRaddress_s1_readdata_from_sa;
  wire             WRaddress_s1_reset_n;
  wire             WRaddress_s1_write_n;
  wire    [  9: 0] WRaddress_s1_writedata;
  wire             clk_0_reset_n;
  wire    [ 24: 0] cpu_0_data_master_address;
  wire    [ 24: 0] cpu_0_data_master_address_to_slave;
  wire    [  3: 0] cpu_0_data_master_byteenable;
  wire    [  1: 0] cpu_0_data_master_byteenable_sdram_0_s1;
  wire    [  1: 0] cpu_0_data_master_dbs_address;
  wire    [ 15: 0] cpu_0_data_master_dbs_write_16;
  wire             cpu_0_data_master_debugaccess;
  wire             cpu_0_data_master_granted_UART2DPRAM_s1;
  wire             cpu_0_data_master_granted_WRaddress_s1;
  wire             cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_granted_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_granted_dpram_wr_en_s1;
  wire             cpu_0_data_master_granted_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_granted_dpram_wrclk_s1;
  wire             cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_granted_freq_word_s1;
  wire             cpu_0_data_master_granted_sdram_0_s1;
  wire             cpu_0_data_master_granted_uart_0_s1;
  wire    [ 31: 0] cpu_0_data_master_irq;
  wire             cpu_0_data_master_no_byte_enables_and_last_term;
  wire             cpu_0_data_master_qualified_request_UART2DPRAM_s1;
  wire             cpu_0_data_master_qualified_request_WRaddress_s1;
  wire             cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_qualified_request_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wr_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_qualified_request_dpram_wrclk_s1;
  wire             cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_qualified_request_freq_word_s1;
  wire             cpu_0_data_master_qualified_request_sdram_0_s1;
  wire             cpu_0_data_master_qualified_request_uart_0_s1;
  wire             cpu_0_data_master_read;
  wire             cpu_0_data_master_read_data_valid_UART2DPRAM_s1;
  wire             cpu_0_data_master_read_data_valid_WRaddress_s1;
  wire             cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wr_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_read_data_valid_dpram_wrclk_s1;
  wire             cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_read_data_valid_freq_word_s1;
  wire             cpu_0_data_master_read_data_valid_sdram_0_s1;
  wire             cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register;
  wire             cpu_0_data_master_read_data_valid_uart_0_s1;
  wire    [ 31: 0] cpu_0_data_master_readdata;
  wire             cpu_0_data_master_requests_UART2DPRAM_s1;
  wire             cpu_0_data_master_requests_WRaddress_s1;
  wire             cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  wire             cpu_0_data_master_requests_dpram_rdclk_en_s1;
  wire             cpu_0_data_master_requests_dpram_wr_en_s1;
  wire             cpu_0_data_master_requests_dpram_wrclk_en_s1;
  wire             cpu_0_data_master_requests_dpram_wrclk_s1;
  wire             cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_data_master_requests_freq_word_s1;
  wire             cpu_0_data_master_requests_sdram_0_s1;
  wire             cpu_0_data_master_requests_uart_0_s1;
  wire             cpu_0_data_master_waitrequest;
  wire             cpu_0_data_master_write;
  wire    [ 31: 0] cpu_0_data_master_writedata;
  wire    [ 24: 0] cpu_0_instruction_master_address;
  wire    [ 24: 0] cpu_0_instruction_master_address_to_slave;
  wire    [  1: 0] cpu_0_instruction_master_dbs_address;
  wire             cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_granted_sdram_0_s1;
  wire             cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_qualified_request_sdram_0_s1;
  wire             cpu_0_instruction_master_read;
  wire             cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_read_data_valid_sdram_0_s1;
  wire             cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register;
  wire    [ 31: 0] cpu_0_instruction_master_readdata;
  wire             cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  wire             cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port;
  wire             cpu_0_instruction_master_requests_sdram_0_s1;
  wire             cpu_0_instruction_master_waitrequest;
  wire    [  8: 0] cpu_0_jtag_debug_module_address;
  wire             cpu_0_jtag_debug_module_begintransfer;
  wire    [  3: 0] cpu_0_jtag_debug_module_byteenable;
  wire             cpu_0_jtag_debug_module_chipselect;
  wire             cpu_0_jtag_debug_module_debugaccess;
  wire    [ 31: 0] cpu_0_jtag_debug_module_readdata;
  wire    [ 31: 0] cpu_0_jtag_debug_module_readdata_from_sa;
  wire             cpu_0_jtag_debug_module_reset_n;
  wire             cpu_0_jtag_debug_module_resetrequest;
  wire             cpu_0_jtag_debug_module_resetrequest_from_sa;
  wire             cpu_0_jtag_debug_module_write;
  wire    [ 31: 0] cpu_0_jtag_debug_module_writedata;
  wire             d1_UART2DPRAM_s1_end_xfer;
  wire             d1_WRaddress_s1_end_xfer;
  wire             d1_cpu_0_jtag_debug_module_end_xfer;
  wire             d1_dpram_rdclk_en_s1_end_xfer;
  wire             d1_dpram_wr_en_s1_end_xfer;
  wire             d1_dpram_wrclk_en_s1_end_xfer;
  wire             d1_dpram_wrclk_s1_end_xfer;
  wire             d1_epcs_flash_controller_0_epcs_control_port_end_xfer;
  wire             d1_freq_word_s1_end_xfer;
  wire             d1_sdram_0_s1_end_xfer;
  wire             d1_uart_0_s1_end_xfer;
  wire    [  1: 0] dpram_rdclk_en_s1_address;
  wire             dpram_rdclk_en_s1_chipselect;
  wire             dpram_rdclk_en_s1_readdata;
  wire             dpram_rdclk_en_s1_readdata_from_sa;
  wire             dpram_rdclk_en_s1_reset_n;
  wire             dpram_rdclk_en_s1_write_n;
  wire             dpram_rdclk_en_s1_writedata;
  wire    [  1: 0] dpram_wr_en_s1_address;
  wire             dpram_wr_en_s1_chipselect;
  wire             dpram_wr_en_s1_readdata;
  wire             dpram_wr_en_s1_readdata_from_sa;
  wire             dpram_wr_en_s1_reset_n;
  wire             dpram_wr_en_s1_write_n;
  wire             dpram_wr_en_s1_writedata;
  wire    [  1: 0] dpram_wrclk_en_s1_address;
  wire             dpram_wrclk_en_s1_chipselect;
  wire             dpram_wrclk_en_s1_readdata;
  wire             dpram_wrclk_en_s1_readdata_from_sa;
  wire             dpram_wrclk_en_s1_reset_n;
  wire             dpram_wrclk_en_s1_write_n;
  wire             dpram_wrclk_en_s1_writedata;
  wire    [  1: 0] dpram_wrclk_s1_address;
  wire             dpram_wrclk_s1_chipselect;
  wire             dpram_wrclk_s1_readdata;
  wire             dpram_wrclk_s1_readdata_from_sa;
  wire             dpram_wrclk_s1_reset_n;
  wire             dpram_wrclk_s1_write_n;
  wire             dpram_wrclk_s1_writedata;
  wire    [  8: 0] epcs_flash_controller_0_epcs_control_port_address;
  wire             epcs_flash_controller_0_epcs_control_port_chipselect;
  wire             epcs_flash_controller_0_epcs_control_port_dataavailable;
  wire             epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_endofpacket;
  wire             epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_irq;
  wire             epcs_flash_controller_0_epcs_control_port_irq_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_read_n;
  wire    [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata;
  wire    [ 31: 0] epcs_flash_controller_0_epcs_control_port_readdata_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_readyfordata;
  wire             epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_reset_n;
  wire             epcs_flash_controller_0_epcs_control_port_write_n;
  wire    [ 31: 0] epcs_flash_controller_0_epcs_control_port_writedata;
  wire    [  1: 0] freq_word_s1_address;
  wire             freq_word_s1_chipselect;
  wire    [ 22: 0] freq_word_s1_readdata;
  wire    [ 22: 0] freq_word_s1_readdata_from_sa;
  wire             freq_word_s1_reset_n;
  wire             freq_word_s1_write_n;
  wire    [ 22: 0] freq_word_s1_writedata;
  wire    [ 11: 0] out_port_from_the_UART2DPRAM;
  wire    [  9: 0] out_port_from_the_WRaddress;
  wire             out_port_from_the_dpram_rdclk_en;
  wire             out_port_from_the_dpram_wr_en;
  wire             out_port_from_the_dpram_wrclk;
  wire             out_port_from_the_dpram_wrclk_en;
  wire    [ 22: 0] out_port_from_the_freq_word;
  wire             reset_n_sources;
  wire    [ 21: 0] sdram_0_s1_address;
  wire    [  1: 0] sdram_0_s1_byteenable_n;
  wire             sdram_0_s1_chipselect;
  wire             sdram_0_s1_read_n;
  wire    [ 15: 0] sdram_0_s1_readdata;
  wire    [ 15: 0] sdram_0_s1_readdata_from_sa;
  wire             sdram_0_s1_readdatavalid;
  wire             sdram_0_s1_reset_n;
  wire             sdram_0_s1_waitrequest;
  wire             sdram_0_s1_waitrequest_from_sa;
  wire             sdram_0_s1_write_n;
  wire    [ 15: 0] sdram_0_s1_writedata;
  wire             txd_from_the_uart_0;
  wire    [  2: 0] uart_0_s1_address;
  wire             uart_0_s1_begintransfer;
  wire             uart_0_s1_chipselect;
  wire             uart_0_s1_dataavailable;
  wire             uart_0_s1_dataavailable_from_sa;
  wire             uart_0_s1_irq;
  wire             uart_0_s1_irq_from_sa;
  wire             uart_0_s1_read_n;
  wire    [ 15: 0] uart_0_s1_readdata;
  wire    [ 15: 0] uart_0_s1_readdata_from_sa;
  wire             uart_0_s1_readyfordata;
  wire             uart_0_s1_readyfordata_from_sa;
  wire             uart_0_s1_reset_n;
  wire             uart_0_s1_write_n;
  wire    [ 15: 0] uart_0_s1_writedata;
  wire    [ 11: 0] zs_addr_from_the_sdram_0;
  wire    [  1: 0] zs_ba_from_the_sdram_0;
  wire             zs_cas_n_from_the_sdram_0;
  wire             zs_cke_from_the_sdram_0;
  wire             zs_cs_n_from_the_sdram_0;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram_0;
  wire    [  1: 0] zs_dqm_from_the_sdram_0;
  wire             zs_ras_n_from_the_sdram_0;
  wire             zs_we_n_from_the_sdram_0;
  UART2DPRAM_s1_arbitrator the_UART2DPRAM_s1
    (
      .UART2DPRAM_s1_address                             (UART2DPRAM_s1_address),
      .UART2DPRAM_s1_chipselect                          (UART2DPRAM_s1_chipselect),
      .UART2DPRAM_s1_readdata                            (UART2DPRAM_s1_readdata),
      .UART2DPRAM_s1_readdata_from_sa                    (UART2DPRAM_s1_readdata_from_sa),
      .UART2DPRAM_s1_reset_n                             (UART2DPRAM_s1_reset_n),
      .UART2DPRAM_s1_write_n                             (UART2DPRAM_s1_write_n),
      .UART2DPRAM_s1_writedata                           (UART2DPRAM_s1_writedata),
      .clk                                               (clk_0),
      .cpu_0_data_master_address_to_slave                (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_UART2DPRAM_s1           (cpu_0_data_master_granted_UART2DPRAM_s1),
      .cpu_0_data_master_qualified_request_UART2DPRAM_s1 (cpu_0_data_master_qualified_request_UART2DPRAM_s1),
      .cpu_0_data_master_read                            (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_UART2DPRAM_s1   (cpu_0_data_master_read_data_valid_UART2DPRAM_s1),
      .cpu_0_data_master_requests_UART2DPRAM_s1          (cpu_0_data_master_requests_UART2DPRAM_s1),
      .cpu_0_data_master_waitrequest                     (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                           (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                       (cpu_0_data_master_writedata),
      .d1_UART2DPRAM_s1_end_xfer                         (d1_UART2DPRAM_s1_end_xfer),
      .reset_n                                           (clk_0_reset_n)
    );

  UART2DPRAM the_UART2DPRAM
    (
      .address    (UART2DPRAM_s1_address),
      .chipselect (UART2DPRAM_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_UART2DPRAM),
      .readdata   (UART2DPRAM_s1_readdata),
      .reset_n    (UART2DPRAM_s1_reset_n),
      .write_n    (UART2DPRAM_s1_write_n),
      .writedata  (UART2DPRAM_s1_writedata)
    );

  WRaddress_s1_arbitrator the_WRaddress_s1
    (
      .WRaddress_s1_address                             (WRaddress_s1_address),
      .WRaddress_s1_chipselect                          (WRaddress_s1_chipselect),
      .WRaddress_s1_readdata                            (WRaddress_s1_readdata),
      .WRaddress_s1_readdata_from_sa                    (WRaddress_s1_readdata_from_sa),
      .WRaddress_s1_reset_n                             (WRaddress_s1_reset_n),
      .WRaddress_s1_write_n                             (WRaddress_s1_write_n),
      .WRaddress_s1_writedata                           (WRaddress_s1_writedata),
      .clk                                              (clk_0),
      .cpu_0_data_master_address_to_slave               (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_WRaddress_s1           (cpu_0_data_master_granted_WRaddress_s1),
      .cpu_0_data_master_qualified_request_WRaddress_s1 (cpu_0_data_master_qualified_request_WRaddress_s1),
      .cpu_0_data_master_read                           (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_WRaddress_s1   (cpu_0_data_master_read_data_valid_WRaddress_s1),
      .cpu_0_data_master_requests_WRaddress_s1          (cpu_0_data_master_requests_WRaddress_s1),
      .cpu_0_data_master_waitrequest                    (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                          (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                      (cpu_0_data_master_writedata),
      .d1_WRaddress_s1_end_xfer                         (d1_WRaddress_s1_end_xfer),
      .reset_n                                          (clk_0_reset_n)
    );

  WRaddress the_WRaddress
    (
      .address    (WRaddress_s1_address),
      .chipselect (WRaddress_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_WRaddress),
      .readdata   (WRaddress_s1_readdata),
      .reset_n    (WRaddress_s1_reset_n),
      .write_n    (WRaddress_s1_write_n),
      .writedata  (WRaddress_s1_writedata)
    );

  cpu_0_jtag_debug_module_arbitrator the_cpu_0_jtag_debug_module
    (
      .clk                                                                (clk_0),
      .cpu_0_data_master_address_to_slave                                 (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_byteenable                                       (cpu_0_data_master_byteenable),
      .cpu_0_data_master_debugaccess                                      (cpu_0_data_master_debugaccess),
      .cpu_0_data_master_granted_cpu_0_jtag_debug_module                  (cpu_0_data_master_granted_cpu_0_jtag_debug_module),
      .cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module        (cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module),
      .cpu_0_data_master_read                                             (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module          (cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module),
      .cpu_0_data_master_requests_cpu_0_jtag_debug_module                 (cpu_0_data_master_requests_cpu_0_jtag_debug_module),
      .cpu_0_data_master_waitrequest                                      (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                                            (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                                        (cpu_0_data_master_writedata),
      .cpu_0_instruction_master_address_to_slave                          (cpu_0_instruction_master_address_to_slave),
      .cpu_0_instruction_master_granted_cpu_0_jtag_debug_module           (cpu_0_instruction_master_granted_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module (cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_read                                      (cpu_0_instruction_master_read),
      .cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module   (cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_requests_cpu_0_jtag_debug_module          (cpu_0_instruction_master_requests_cpu_0_jtag_debug_module),
      .cpu_0_jtag_debug_module_address                                    (cpu_0_jtag_debug_module_address),
      .cpu_0_jtag_debug_module_begintransfer                              (cpu_0_jtag_debug_module_begintransfer),
      .cpu_0_jtag_debug_module_byteenable                                 (cpu_0_jtag_debug_module_byteenable),
      .cpu_0_jtag_debug_module_chipselect                                 (cpu_0_jtag_debug_module_chipselect),
      .cpu_0_jtag_debug_module_debugaccess                                (cpu_0_jtag_debug_module_debugaccess),
      .cpu_0_jtag_debug_module_readdata                                   (cpu_0_jtag_debug_module_readdata),
      .cpu_0_jtag_debug_module_readdata_from_sa                           (cpu_0_jtag_debug_module_readdata_from_sa),
      .cpu_0_jtag_debug_module_reset_n                                    (cpu_0_jtag_debug_module_reset_n),
      .cpu_0_jtag_debug_module_resetrequest                               (cpu_0_jtag_debug_module_resetrequest),
      .cpu_0_jtag_debug_module_resetrequest_from_sa                       (cpu_0_jtag_debug_module_resetrequest_from_sa),
      .cpu_0_jtag_debug_module_write                                      (cpu_0_jtag_debug_module_write),
      .cpu_0_jtag_debug_module_writedata                                  (cpu_0_jtag_debug_module_writedata),
      .d1_cpu_0_jtag_debug_module_end_xfer                                (d1_cpu_0_jtag_debug_module_end_xfer),
      .reset_n                                                            (clk_0_reset_n)
    );

  cpu_0_data_master_arbitrator the_cpu_0_data_master
    (
      .UART2DPRAM_s1_readdata_from_sa                                                (UART2DPRAM_s1_readdata_from_sa),
      .WRaddress_s1_readdata_from_sa                                                 (WRaddress_s1_readdata_from_sa),
      .clk                                                                           (clk_0),
      .cpu_0_data_master_address                                                     (cpu_0_data_master_address),
      .cpu_0_data_master_address_to_slave                                            (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_byteenable_sdram_0_s1                                       (cpu_0_data_master_byteenable_sdram_0_s1),
      .cpu_0_data_master_dbs_address                                                 (cpu_0_data_master_dbs_address),
      .cpu_0_data_master_dbs_write_16                                                (cpu_0_data_master_dbs_write_16),
      .cpu_0_data_master_granted_UART2DPRAM_s1                                       (cpu_0_data_master_granted_UART2DPRAM_s1),
      .cpu_0_data_master_granted_WRaddress_s1                                        (cpu_0_data_master_granted_WRaddress_s1),
      .cpu_0_data_master_granted_cpu_0_jtag_debug_module                             (cpu_0_data_master_granted_cpu_0_jtag_debug_module),
      .cpu_0_data_master_granted_dpram_rdclk_en_s1                                   (cpu_0_data_master_granted_dpram_rdclk_en_s1),
      .cpu_0_data_master_granted_dpram_wr_en_s1                                      (cpu_0_data_master_granted_dpram_wr_en_s1),
      .cpu_0_data_master_granted_dpram_wrclk_en_s1                                   (cpu_0_data_master_granted_dpram_wrclk_en_s1),
      .cpu_0_data_master_granted_dpram_wrclk_s1                                      (cpu_0_data_master_granted_dpram_wrclk_s1),
      .cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port           (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_granted_freq_word_s1                                        (cpu_0_data_master_granted_freq_word_s1),
      .cpu_0_data_master_granted_sdram_0_s1                                          (cpu_0_data_master_granted_sdram_0_s1),
      .cpu_0_data_master_granted_uart_0_s1                                           (cpu_0_data_master_granted_uart_0_s1),
      .cpu_0_data_master_irq                                                         (cpu_0_data_master_irq),
      .cpu_0_data_master_no_byte_enables_and_last_term                               (cpu_0_data_master_no_byte_enables_and_last_term),
      .cpu_0_data_master_qualified_request_UART2DPRAM_s1                             (cpu_0_data_master_qualified_request_UART2DPRAM_s1),
      .cpu_0_data_master_qualified_request_WRaddress_s1                              (cpu_0_data_master_qualified_request_WRaddress_s1),
      .cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module                   (cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module),
      .cpu_0_data_master_qualified_request_dpram_rdclk_en_s1                         (cpu_0_data_master_qualified_request_dpram_rdclk_en_s1),
      .cpu_0_data_master_qualified_request_dpram_wr_en_s1                            (cpu_0_data_master_qualified_request_dpram_wr_en_s1),
      .cpu_0_data_master_qualified_request_dpram_wrclk_en_s1                         (cpu_0_data_master_qualified_request_dpram_wrclk_en_s1),
      .cpu_0_data_master_qualified_request_dpram_wrclk_s1                            (cpu_0_data_master_qualified_request_dpram_wrclk_s1),
      .cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port (cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_qualified_request_freq_word_s1                              (cpu_0_data_master_qualified_request_freq_word_s1),
      .cpu_0_data_master_qualified_request_sdram_0_s1                                (cpu_0_data_master_qualified_request_sdram_0_s1),
      .cpu_0_data_master_qualified_request_uart_0_s1                                 (cpu_0_data_master_qualified_request_uart_0_s1),
      .cpu_0_data_master_read                                                        (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_UART2DPRAM_s1                               (cpu_0_data_master_read_data_valid_UART2DPRAM_s1),
      .cpu_0_data_master_read_data_valid_WRaddress_s1                                (cpu_0_data_master_read_data_valid_WRaddress_s1),
      .cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module                     (cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module),
      .cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1                           (cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1),
      .cpu_0_data_master_read_data_valid_dpram_wr_en_s1                              (cpu_0_data_master_read_data_valid_dpram_wr_en_s1),
      .cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1                           (cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1),
      .cpu_0_data_master_read_data_valid_dpram_wrclk_s1                              (cpu_0_data_master_read_data_valid_dpram_wrclk_s1),
      .cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port   (cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_read_data_valid_freq_word_s1                                (cpu_0_data_master_read_data_valid_freq_word_s1),
      .cpu_0_data_master_read_data_valid_sdram_0_s1                                  (cpu_0_data_master_read_data_valid_sdram_0_s1),
      .cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register                   (cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register),
      .cpu_0_data_master_read_data_valid_uart_0_s1                                   (cpu_0_data_master_read_data_valid_uart_0_s1),
      .cpu_0_data_master_readdata                                                    (cpu_0_data_master_readdata),
      .cpu_0_data_master_requests_UART2DPRAM_s1                                      (cpu_0_data_master_requests_UART2DPRAM_s1),
      .cpu_0_data_master_requests_WRaddress_s1                                       (cpu_0_data_master_requests_WRaddress_s1),
      .cpu_0_data_master_requests_cpu_0_jtag_debug_module                            (cpu_0_data_master_requests_cpu_0_jtag_debug_module),
      .cpu_0_data_master_requests_dpram_rdclk_en_s1                                  (cpu_0_data_master_requests_dpram_rdclk_en_s1),
      .cpu_0_data_master_requests_dpram_wr_en_s1                                     (cpu_0_data_master_requests_dpram_wr_en_s1),
      .cpu_0_data_master_requests_dpram_wrclk_en_s1                                  (cpu_0_data_master_requests_dpram_wrclk_en_s1),
      .cpu_0_data_master_requests_dpram_wrclk_s1                                     (cpu_0_data_master_requests_dpram_wrclk_s1),
      .cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port          (cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_requests_freq_word_s1                                       (cpu_0_data_master_requests_freq_word_s1),
      .cpu_0_data_master_requests_sdram_0_s1                                         (cpu_0_data_master_requests_sdram_0_s1),
      .cpu_0_data_master_requests_uart_0_s1                                          (cpu_0_data_master_requests_uart_0_s1),
      .cpu_0_data_master_waitrequest                                                 (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                                                       (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                                                   (cpu_0_data_master_writedata),
      .cpu_0_jtag_debug_module_readdata_from_sa                                      (cpu_0_jtag_debug_module_readdata_from_sa),
      .d1_UART2DPRAM_s1_end_xfer                                                     (d1_UART2DPRAM_s1_end_xfer),
      .d1_WRaddress_s1_end_xfer                                                      (d1_WRaddress_s1_end_xfer),
      .d1_cpu_0_jtag_debug_module_end_xfer                                           (d1_cpu_0_jtag_debug_module_end_xfer),
      .d1_dpram_rdclk_en_s1_end_xfer                                                 (d1_dpram_rdclk_en_s1_end_xfer),
      .d1_dpram_wr_en_s1_end_xfer                                                    (d1_dpram_wr_en_s1_end_xfer),
      .d1_dpram_wrclk_en_s1_end_xfer                                                 (d1_dpram_wrclk_en_s1_end_xfer),
      .d1_dpram_wrclk_s1_end_xfer                                                    (d1_dpram_wrclk_s1_end_xfer),
      .d1_epcs_flash_controller_0_epcs_control_port_end_xfer                         (d1_epcs_flash_controller_0_epcs_control_port_end_xfer),
      .d1_freq_word_s1_end_xfer                                                      (d1_freq_word_s1_end_xfer),
      .d1_sdram_0_s1_end_xfer                                                        (d1_sdram_0_s1_end_xfer),
      .d1_uart_0_s1_end_xfer                                                         (d1_uart_0_s1_end_xfer),
      .dpram_rdclk_en_s1_readdata_from_sa                                            (dpram_rdclk_en_s1_readdata_from_sa),
      .dpram_wr_en_s1_readdata_from_sa                                               (dpram_wr_en_s1_readdata_from_sa),
      .dpram_wrclk_en_s1_readdata_from_sa                                            (dpram_wrclk_en_s1_readdata_from_sa),
      .dpram_wrclk_s1_readdata_from_sa                                               (dpram_wrclk_s1_readdata_from_sa),
      .epcs_flash_controller_0_epcs_control_port_irq_from_sa                         (epcs_flash_controller_0_epcs_control_port_irq_from_sa),
      .epcs_flash_controller_0_epcs_control_port_readdata_from_sa                    (epcs_flash_controller_0_epcs_control_port_readdata_from_sa),
      .freq_word_s1_readdata_from_sa                                                 (freq_word_s1_readdata_from_sa),
      .reset_n                                                                       (clk_0_reset_n),
      .sdram_0_s1_readdata_from_sa                                                   (sdram_0_s1_readdata_from_sa),
      .sdram_0_s1_waitrequest_from_sa                                                (sdram_0_s1_waitrequest_from_sa),
      .uart_0_s1_irq_from_sa                                                         (uart_0_s1_irq_from_sa),
      .uart_0_s1_readdata_from_sa                                                    (uart_0_s1_readdata_from_sa)
    );

  cpu_0_instruction_master_arbitrator the_cpu_0_instruction_master
    (
      .clk                                                                                  (clk_0),
      .cpu_0_instruction_master_address                                                     (cpu_0_instruction_master_address),
      .cpu_0_instruction_master_address_to_slave                                            (cpu_0_instruction_master_address_to_slave),
      .cpu_0_instruction_master_dbs_address                                                 (cpu_0_instruction_master_dbs_address),
      .cpu_0_instruction_master_granted_cpu_0_jtag_debug_module                             (cpu_0_instruction_master_granted_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port           (cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_granted_sdram_0_s1                                          (cpu_0_instruction_master_granted_sdram_0_s1),
      .cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module                   (cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port (cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_qualified_request_sdram_0_s1                                (cpu_0_instruction_master_qualified_request_sdram_0_s1),
      .cpu_0_instruction_master_read                                                        (cpu_0_instruction_master_read),
      .cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module                     (cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port   (cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_read_data_valid_sdram_0_s1                                  (cpu_0_instruction_master_read_data_valid_sdram_0_s1),
      .cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register                   (cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register),
      .cpu_0_instruction_master_readdata                                                    (cpu_0_instruction_master_readdata),
      .cpu_0_instruction_master_requests_cpu_0_jtag_debug_module                            (cpu_0_instruction_master_requests_cpu_0_jtag_debug_module),
      .cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port          (cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_requests_sdram_0_s1                                         (cpu_0_instruction_master_requests_sdram_0_s1),
      .cpu_0_instruction_master_waitrequest                                                 (cpu_0_instruction_master_waitrequest),
      .cpu_0_jtag_debug_module_readdata_from_sa                                             (cpu_0_jtag_debug_module_readdata_from_sa),
      .d1_cpu_0_jtag_debug_module_end_xfer                                                  (d1_cpu_0_jtag_debug_module_end_xfer),
      .d1_epcs_flash_controller_0_epcs_control_port_end_xfer                                (d1_epcs_flash_controller_0_epcs_control_port_end_xfer),
      .d1_sdram_0_s1_end_xfer                                                               (d1_sdram_0_s1_end_xfer),
      .epcs_flash_controller_0_epcs_control_port_readdata_from_sa                           (epcs_flash_controller_0_epcs_control_port_readdata_from_sa),
      .reset_n                                                                              (clk_0_reset_n),
      .sdram_0_s1_readdata_from_sa                                                          (sdram_0_s1_readdata_from_sa),
      .sdram_0_s1_waitrequest_from_sa                                                       (sdram_0_s1_waitrequest_from_sa)
    );

  cpu_0 the_cpu_0
    (
      .clk                                   (clk_0),
      .d_address                             (cpu_0_data_master_address),
      .d_byteenable                          (cpu_0_data_master_byteenable),
      .d_irq                                 (cpu_0_data_master_irq),
      .d_read                                (cpu_0_data_master_read),
      .d_readdata                            (cpu_0_data_master_readdata),
      .d_waitrequest                         (cpu_0_data_master_waitrequest),
      .d_write                               (cpu_0_data_master_write),
      .d_writedata                           (cpu_0_data_master_writedata),
      .i_address                             (cpu_0_instruction_master_address),
      .i_read                                (cpu_0_instruction_master_read),
      .i_readdata                            (cpu_0_instruction_master_readdata),
      .i_waitrequest                         (cpu_0_instruction_master_waitrequest),
      .jtag_debug_module_address             (cpu_0_jtag_debug_module_address),
      .jtag_debug_module_begintransfer       (cpu_0_jtag_debug_module_begintransfer),
      .jtag_debug_module_byteenable          (cpu_0_jtag_debug_module_byteenable),
      .jtag_debug_module_debugaccess         (cpu_0_jtag_debug_module_debugaccess),
      .jtag_debug_module_debugaccess_to_roms (cpu_0_data_master_debugaccess),
      .jtag_debug_module_readdata            (cpu_0_jtag_debug_module_readdata),
      .jtag_debug_module_resetrequest        (cpu_0_jtag_debug_module_resetrequest),
      .jtag_debug_module_select              (cpu_0_jtag_debug_module_chipselect),
      .jtag_debug_module_write               (cpu_0_jtag_debug_module_write),
      .jtag_debug_module_writedata           (cpu_0_jtag_debug_module_writedata),
      .reset_n                               (cpu_0_jtag_debug_module_reset_n)
    );

  dpram_rdclk_en_s1_arbitrator the_dpram_rdclk_en_s1
    (
      .clk                                                   (clk_0),
      .cpu_0_data_master_address_to_slave                    (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_dpram_rdclk_en_s1           (cpu_0_data_master_granted_dpram_rdclk_en_s1),
      .cpu_0_data_master_qualified_request_dpram_rdclk_en_s1 (cpu_0_data_master_qualified_request_dpram_rdclk_en_s1),
      .cpu_0_data_master_read                                (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1   (cpu_0_data_master_read_data_valid_dpram_rdclk_en_s1),
      .cpu_0_data_master_requests_dpram_rdclk_en_s1          (cpu_0_data_master_requests_dpram_rdclk_en_s1),
      .cpu_0_data_master_waitrequest                         (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                               (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                           (cpu_0_data_master_writedata),
      .d1_dpram_rdclk_en_s1_end_xfer                         (d1_dpram_rdclk_en_s1_end_xfer),
      .dpram_rdclk_en_s1_address                             (dpram_rdclk_en_s1_address),
      .dpram_rdclk_en_s1_chipselect                          (dpram_rdclk_en_s1_chipselect),
      .dpram_rdclk_en_s1_readdata                            (dpram_rdclk_en_s1_readdata),
      .dpram_rdclk_en_s1_readdata_from_sa                    (dpram_rdclk_en_s1_readdata_from_sa),
      .dpram_rdclk_en_s1_reset_n                             (dpram_rdclk_en_s1_reset_n),
      .dpram_rdclk_en_s1_write_n                             (dpram_rdclk_en_s1_write_n),
      .dpram_rdclk_en_s1_writedata                           (dpram_rdclk_en_s1_writedata),
      .reset_n                                               (clk_0_reset_n)
    );

  dpram_rdclk_en the_dpram_rdclk_en
    (
      .address    (dpram_rdclk_en_s1_address),
      .chipselect (dpram_rdclk_en_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_dpram_rdclk_en),
      .readdata   (dpram_rdclk_en_s1_readdata),
      .reset_n    (dpram_rdclk_en_s1_reset_n),
      .write_n    (dpram_rdclk_en_s1_write_n),
      .writedata  (dpram_rdclk_en_s1_writedata)
    );

  dpram_wr_en_s1_arbitrator the_dpram_wr_en_s1
    (
      .clk                                                (clk_0),
      .cpu_0_data_master_address_to_slave                 (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_dpram_wr_en_s1           (cpu_0_data_master_granted_dpram_wr_en_s1),
      .cpu_0_data_master_qualified_request_dpram_wr_en_s1 (cpu_0_data_master_qualified_request_dpram_wr_en_s1),
      .cpu_0_data_master_read                             (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_dpram_wr_en_s1   (cpu_0_data_master_read_data_valid_dpram_wr_en_s1),
      .cpu_0_data_master_requests_dpram_wr_en_s1          (cpu_0_data_master_requests_dpram_wr_en_s1),
      .cpu_0_data_master_waitrequest                      (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                            (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                        (cpu_0_data_master_writedata),
      .d1_dpram_wr_en_s1_end_xfer                         (d1_dpram_wr_en_s1_end_xfer),
      .dpram_wr_en_s1_address                             (dpram_wr_en_s1_address),
      .dpram_wr_en_s1_chipselect                          (dpram_wr_en_s1_chipselect),
      .dpram_wr_en_s1_readdata                            (dpram_wr_en_s1_readdata),
      .dpram_wr_en_s1_readdata_from_sa                    (dpram_wr_en_s1_readdata_from_sa),
      .dpram_wr_en_s1_reset_n                             (dpram_wr_en_s1_reset_n),
      .dpram_wr_en_s1_write_n                             (dpram_wr_en_s1_write_n),
      .dpram_wr_en_s1_writedata                           (dpram_wr_en_s1_writedata),
      .reset_n                                            (clk_0_reset_n)
    );

  dpram_wr_en the_dpram_wr_en
    (
      .address    (dpram_wr_en_s1_address),
      .chipselect (dpram_wr_en_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_dpram_wr_en),
      .readdata   (dpram_wr_en_s1_readdata),
      .reset_n    (dpram_wr_en_s1_reset_n),
      .write_n    (dpram_wr_en_s1_write_n),
      .writedata  (dpram_wr_en_s1_writedata)
    );

  dpram_wrclk_s1_arbitrator the_dpram_wrclk_s1
    (
      .clk                                                (clk_0),
      .cpu_0_data_master_address_to_slave                 (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_dpram_wrclk_s1           (cpu_0_data_master_granted_dpram_wrclk_s1),
      .cpu_0_data_master_qualified_request_dpram_wrclk_s1 (cpu_0_data_master_qualified_request_dpram_wrclk_s1),
      .cpu_0_data_master_read                             (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_dpram_wrclk_s1   (cpu_0_data_master_read_data_valid_dpram_wrclk_s1),
      .cpu_0_data_master_requests_dpram_wrclk_s1          (cpu_0_data_master_requests_dpram_wrclk_s1),
      .cpu_0_data_master_waitrequest                      (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                            (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                        (cpu_0_data_master_writedata),
      .d1_dpram_wrclk_s1_end_xfer                         (d1_dpram_wrclk_s1_end_xfer),
      .dpram_wrclk_s1_address                             (dpram_wrclk_s1_address),
      .dpram_wrclk_s1_chipselect                          (dpram_wrclk_s1_chipselect),
      .dpram_wrclk_s1_readdata                            (dpram_wrclk_s1_readdata),
      .dpram_wrclk_s1_readdata_from_sa                    (dpram_wrclk_s1_readdata_from_sa),
      .dpram_wrclk_s1_reset_n                             (dpram_wrclk_s1_reset_n),
      .dpram_wrclk_s1_write_n                             (dpram_wrclk_s1_write_n),
      .dpram_wrclk_s1_writedata                           (dpram_wrclk_s1_writedata),
      .reset_n                                            (clk_0_reset_n)
    );

  dpram_wrclk the_dpram_wrclk
    (
      .address    (dpram_wrclk_s1_address),
      .chipselect (dpram_wrclk_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_dpram_wrclk),
      .readdata   (dpram_wrclk_s1_readdata),
      .reset_n    (dpram_wrclk_s1_reset_n),
      .write_n    (dpram_wrclk_s1_write_n),
      .writedata  (dpram_wrclk_s1_writedata)
    );

  dpram_wrclk_en_s1_arbitrator the_dpram_wrclk_en_s1
    (
      .clk                                                   (clk_0),
      .cpu_0_data_master_address_to_slave                    (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_dpram_wrclk_en_s1           (cpu_0_data_master_granted_dpram_wrclk_en_s1),
      .cpu_0_data_master_qualified_request_dpram_wrclk_en_s1 (cpu_0_data_master_qualified_request_dpram_wrclk_en_s1),
      .cpu_0_data_master_read                                (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1   (cpu_0_data_master_read_data_valid_dpram_wrclk_en_s1),
      .cpu_0_data_master_requests_dpram_wrclk_en_s1          (cpu_0_data_master_requests_dpram_wrclk_en_s1),
      .cpu_0_data_master_waitrequest                         (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                               (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                           (cpu_0_data_master_writedata),
      .d1_dpram_wrclk_en_s1_end_xfer                         (d1_dpram_wrclk_en_s1_end_xfer),
      .dpram_wrclk_en_s1_address                             (dpram_wrclk_en_s1_address),
      .dpram_wrclk_en_s1_chipselect                          (dpram_wrclk_en_s1_chipselect),
      .dpram_wrclk_en_s1_readdata                            (dpram_wrclk_en_s1_readdata),
      .dpram_wrclk_en_s1_readdata_from_sa                    (dpram_wrclk_en_s1_readdata_from_sa),
      .dpram_wrclk_en_s1_reset_n                             (dpram_wrclk_en_s1_reset_n),
      .dpram_wrclk_en_s1_write_n                             (dpram_wrclk_en_s1_write_n),
      .dpram_wrclk_en_s1_writedata                           (dpram_wrclk_en_s1_writedata),
      .reset_n                                               (clk_0_reset_n)
    );

  dpram_wrclk_en the_dpram_wrclk_en
    (
      .address    (dpram_wrclk_en_s1_address),
      .chipselect (dpram_wrclk_en_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_dpram_wrclk_en),
      .readdata   (dpram_wrclk_en_s1_readdata),
      .reset_n    (dpram_wrclk_en_s1_reset_n),
      .write_n    (dpram_wrclk_en_s1_write_n),
      .writedata  (dpram_wrclk_en_s1_writedata)
    );

  epcs_flash_controller_0_epcs_control_port_arbitrator the_epcs_flash_controller_0_epcs_control_port
    (
      .clk                                                                                  (clk_0),
      .cpu_0_data_master_address_to_slave                                                   (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port                  (cpu_0_data_master_granted_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port        (cpu_0_data_master_qualified_request_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_read                                                               (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port          (cpu_0_data_master_read_data_valid_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port                 (cpu_0_data_master_requests_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_data_master_write                                                              (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                                                          (cpu_0_data_master_writedata),
      .cpu_0_instruction_master_address_to_slave                                            (cpu_0_instruction_master_address_to_slave),
      .cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port           (cpu_0_instruction_master_granted_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port (cpu_0_instruction_master_qualified_request_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_read                                                        (cpu_0_instruction_master_read),
      .cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port   (cpu_0_instruction_master_read_data_valid_epcs_flash_controller_0_epcs_control_port),
      .cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port          (cpu_0_instruction_master_requests_epcs_flash_controller_0_epcs_control_port),
      .d1_epcs_flash_controller_0_epcs_control_port_end_xfer                                (d1_epcs_flash_controller_0_epcs_control_port_end_xfer),
      .epcs_flash_controller_0_epcs_control_port_address                                    (epcs_flash_controller_0_epcs_control_port_address),
      .epcs_flash_controller_0_epcs_control_port_chipselect                                 (epcs_flash_controller_0_epcs_control_port_chipselect),
      .epcs_flash_controller_0_epcs_control_port_dataavailable                              (epcs_flash_controller_0_epcs_control_port_dataavailable),
      .epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa                      (epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa),
      .epcs_flash_controller_0_epcs_control_port_endofpacket                                (epcs_flash_controller_0_epcs_control_port_endofpacket),
      .epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa                        (epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa),
      .epcs_flash_controller_0_epcs_control_port_irq                                        (epcs_flash_controller_0_epcs_control_port_irq),
      .epcs_flash_controller_0_epcs_control_port_irq_from_sa                                (epcs_flash_controller_0_epcs_control_port_irq_from_sa),
      .epcs_flash_controller_0_epcs_control_port_read_n                                     (epcs_flash_controller_0_epcs_control_port_read_n),
      .epcs_flash_controller_0_epcs_control_port_readdata                                   (epcs_flash_controller_0_epcs_control_port_readdata),
      .epcs_flash_controller_0_epcs_control_port_readdata_from_sa                           (epcs_flash_controller_0_epcs_control_port_readdata_from_sa),
      .epcs_flash_controller_0_epcs_control_port_readyfordata                               (epcs_flash_controller_0_epcs_control_port_readyfordata),
      .epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa                       (epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa),
      .epcs_flash_controller_0_epcs_control_port_reset_n                                    (epcs_flash_controller_0_epcs_control_port_reset_n),
      .epcs_flash_controller_0_epcs_control_port_write_n                                    (epcs_flash_controller_0_epcs_control_port_write_n),
      .epcs_flash_controller_0_epcs_control_port_writedata                                  (epcs_flash_controller_0_epcs_control_port_writedata),
      .reset_n                                                                              (clk_0_reset_n)
    );

  epcs_flash_controller_0 the_epcs_flash_controller_0
    (
      .address       (epcs_flash_controller_0_epcs_control_port_address),
      .chipselect    (epcs_flash_controller_0_epcs_control_port_chipselect),
      .clk           (clk_0),
      .dataavailable (epcs_flash_controller_0_epcs_control_port_dataavailable),
      .endofpacket   (epcs_flash_controller_0_epcs_control_port_endofpacket),
      .irq           (epcs_flash_controller_0_epcs_control_port_irq),
      .read_n        (epcs_flash_controller_0_epcs_control_port_read_n),
      .readdata      (epcs_flash_controller_0_epcs_control_port_readdata),
      .readyfordata  (epcs_flash_controller_0_epcs_control_port_readyfordata),
      .reset_n       (epcs_flash_controller_0_epcs_control_port_reset_n),
      .write_n       (epcs_flash_controller_0_epcs_control_port_write_n),
      .writedata     (epcs_flash_controller_0_epcs_control_port_writedata)
    );

  freq_word_s1_arbitrator the_freq_word_s1
    (
      .clk                                              (clk_0),
      .cpu_0_data_master_address_to_slave               (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_freq_word_s1           (cpu_0_data_master_granted_freq_word_s1),
      .cpu_0_data_master_qualified_request_freq_word_s1 (cpu_0_data_master_qualified_request_freq_word_s1),
      .cpu_0_data_master_read                           (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_freq_word_s1   (cpu_0_data_master_read_data_valid_freq_word_s1),
      .cpu_0_data_master_requests_freq_word_s1          (cpu_0_data_master_requests_freq_word_s1),
      .cpu_0_data_master_waitrequest                    (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                          (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                      (cpu_0_data_master_writedata),
      .d1_freq_word_s1_end_xfer                         (d1_freq_word_s1_end_xfer),
      .freq_word_s1_address                             (freq_word_s1_address),
      .freq_word_s1_chipselect                          (freq_word_s1_chipselect),
      .freq_word_s1_readdata                            (freq_word_s1_readdata),
      .freq_word_s1_readdata_from_sa                    (freq_word_s1_readdata_from_sa),
      .freq_word_s1_reset_n                             (freq_word_s1_reset_n),
      .freq_word_s1_write_n                             (freq_word_s1_write_n),
      .freq_word_s1_writedata                           (freq_word_s1_writedata),
      .reset_n                                          (clk_0_reset_n)
    );

  freq_word the_freq_word
    (
      .address    (freq_word_s1_address),
      .chipselect (freq_word_s1_chipselect),
      .clk        (clk_0),
      .out_port   (out_port_from_the_freq_word),
      .readdata   (freq_word_s1_readdata),
      .reset_n    (freq_word_s1_reset_n),
      .write_n    (freq_word_s1_write_n),
      .writedata  (freq_word_s1_writedata)
    );

  sdram_0_s1_arbitrator the_sdram_0_s1
    (
      .clk                                                                (clk_0),
      .cpu_0_data_master_address_to_slave                                 (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_byteenable                                       (cpu_0_data_master_byteenable),
      .cpu_0_data_master_byteenable_sdram_0_s1                            (cpu_0_data_master_byteenable_sdram_0_s1),
      .cpu_0_data_master_dbs_address                                      (cpu_0_data_master_dbs_address),
      .cpu_0_data_master_dbs_write_16                                     (cpu_0_data_master_dbs_write_16),
      .cpu_0_data_master_granted_sdram_0_s1                               (cpu_0_data_master_granted_sdram_0_s1),
      .cpu_0_data_master_no_byte_enables_and_last_term                    (cpu_0_data_master_no_byte_enables_and_last_term),
      .cpu_0_data_master_qualified_request_sdram_0_s1                     (cpu_0_data_master_qualified_request_sdram_0_s1),
      .cpu_0_data_master_read                                             (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_sdram_0_s1                       (cpu_0_data_master_read_data_valid_sdram_0_s1),
      .cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register        (cpu_0_data_master_read_data_valid_sdram_0_s1_shift_register),
      .cpu_0_data_master_requests_sdram_0_s1                              (cpu_0_data_master_requests_sdram_0_s1),
      .cpu_0_data_master_waitrequest                                      (cpu_0_data_master_waitrequest),
      .cpu_0_data_master_write                                            (cpu_0_data_master_write),
      .cpu_0_instruction_master_address_to_slave                          (cpu_0_instruction_master_address_to_slave),
      .cpu_0_instruction_master_dbs_address                               (cpu_0_instruction_master_dbs_address),
      .cpu_0_instruction_master_granted_sdram_0_s1                        (cpu_0_instruction_master_granted_sdram_0_s1),
      .cpu_0_instruction_master_qualified_request_sdram_0_s1              (cpu_0_instruction_master_qualified_request_sdram_0_s1),
      .cpu_0_instruction_master_read                                      (cpu_0_instruction_master_read),
      .cpu_0_instruction_master_read_data_valid_sdram_0_s1                (cpu_0_instruction_master_read_data_valid_sdram_0_s1),
      .cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register (cpu_0_instruction_master_read_data_valid_sdram_0_s1_shift_register),
      .cpu_0_instruction_master_requests_sdram_0_s1                       (cpu_0_instruction_master_requests_sdram_0_s1),
      .d1_sdram_0_s1_end_xfer                                             (d1_sdram_0_s1_end_xfer),
      .reset_n                                                            (clk_0_reset_n),
      .sdram_0_s1_address                                                 (sdram_0_s1_address),
      .sdram_0_s1_byteenable_n                                            (sdram_0_s1_byteenable_n),
      .sdram_0_s1_chipselect                                              (sdram_0_s1_chipselect),
      .sdram_0_s1_read_n                                                  (sdram_0_s1_read_n),
      .sdram_0_s1_readdata                                                (sdram_0_s1_readdata),
      .sdram_0_s1_readdata_from_sa                                        (sdram_0_s1_readdata_from_sa),
      .sdram_0_s1_readdatavalid                                           (sdram_0_s1_readdatavalid),
      .sdram_0_s1_reset_n                                                 (sdram_0_s1_reset_n),
      .sdram_0_s1_waitrequest                                             (sdram_0_s1_waitrequest),
      .sdram_0_s1_waitrequest_from_sa                                     (sdram_0_s1_waitrequest_from_sa),
      .sdram_0_s1_write_n                                                 (sdram_0_s1_write_n),
      .sdram_0_s1_writedata                                               (sdram_0_s1_writedata)
    );

  sdram_0 the_sdram_0
    (
      .az_addr        (sdram_0_s1_address),
      .az_be_n        (sdram_0_s1_byteenable_n),
      .az_cs          (sdram_0_s1_chipselect),
      .az_data        (sdram_0_s1_writedata),
      .az_rd_n        (sdram_0_s1_read_n),
      .az_wr_n        (sdram_0_s1_write_n),
      .clk            (clk_0),
      .reset_n        (sdram_0_s1_reset_n),
      .za_data        (sdram_0_s1_readdata),
      .za_valid       (sdram_0_s1_readdatavalid),
      .za_waitrequest (sdram_0_s1_waitrequest),
      .zs_addr        (zs_addr_from_the_sdram_0),
      .zs_ba          (zs_ba_from_the_sdram_0),
      .zs_cas_n       (zs_cas_n_from_the_sdram_0),
      .zs_cke         (zs_cke_from_the_sdram_0),
      .zs_cs_n        (zs_cs_n_from_the_sdram_0),
      .zs_dq          (zs_dq_to_and_from_the_sdram_0),
      .zs_dqm         (zs_dqm_from_the_sdram_0),
      .zs_ras_n       (zs_ras_n_from_the_sdram_0),
      .zs_we_n        (zs_we_n_from_the_sdram_0)
    );

  uart_0_s1_arbitrator the_uart_0_s1
    (
      .clk                                           (clk_0),
      .cpu_0_data_master_address_to_slave            (cpu_0_data_master_address_to_slave),
      .cpu_0_data_master_granted_uart_0_s1           (cpu_0_data_master_granted_uart_0_s1),
      .cpu_0_data_master_qualified_request_uart_0_s1 (cpu_0_data_master_qualified_request_uart_0_s1),
      .cpu_0_data_master_read                        (cpu_0_data_master_read),
      .cpu_0_data_master_read_data_valid_uart_0_s1   (cpu_0_data_master_read_data_valid_uart_0_s1),
      .cpu_0_data_master_requests_uart_0_s1          (cpu_0_data_master_requests_uart_0_s1),
      .cpu_0_data_master_write                       (cpu_0_data_master_write),
      .cpu_0_data_master_writedata                   (cpu_0_data_master_writedata),
      .d1_uart_0_s1_end_xfer                         (d1_uart_0_s1_end_xfer),
      .reset_n                                       (clk_0_reset_n),
      .uart_0_s1_address                             (uart_0_s1_address),
      .uart_0_s1_begintransfer                       (uart_0_s1_begintransfer),
      .uart_0_s1_chipselect                          (uart_0_s1_chipselect),
      .uart_0_s1_dataavailable                       (uart_0_s1_dataavailable),
      .uart_0_s1_dataavailable_from_sa               (uart_0_s1_dataavailable_from_sa),
      .uart_0_s1_irq                                 (uart_0_s1_irq),
      .uart_0_s1_irq_from_sa                         (uart_0_s1_irq_from_sa),
      .uart_0_s1_read_n                              (uart_0_s1_read_n),
      .uart_0_s1_readdata                            (uart_0_s1_readdata),
      .uart_0_s1_readdata_from_sa                    (uart_0_s1_readdata_from_sa),
      .uart_0_s1_readyfordata                        (uart_0_s1_readyfordata),
      .uart_0_s1_readyfordata_from_sa                (uart_0_s1_readyfordata_from_sa),
      .uart_0_s1_reset_n                             (uart_0_s1_reset_n),
      .uart_0_s1_write_n                             (uart_0_s1_write_n),
      .uart_0_s1_writedata                           (uart_0_s1_writedata)
    );

  uart_0 the_uart_0
    (
      .address       (uart_0_s1_address),
      .begintransfer (uart_0_s1_begintransfer),
      .chipselect    (uart_0_s1_chipselect),
      .clk           (clk_0),
      .dataavailable (uart_0_s1_dataavailable),
      .irq           (uart_0_s1_irq),
      .read_n        (uart_0_s1_read_n),
      .readdata      (uart_0_s1_readdata),
      .readyfordata  (uart_0_s1_readyfordata),
      .reset_n       (uart_0_s1_reset_n),
      .rxd           (rxd_to_the_uart_0),
      .txd           (txd_from_the_uart_0),
      .write_n       (uart_0_s1_write_n),
      .writedata     (uart_0_s1_writedata)
    );

  //reset is asserted asynchronously and deasserted synchronously
  AWG_reset_clk_0_domain_synch_module AWG_reset_clk_0_domain_synch
    (
      .clk      (clk_0),
      .data_in  (1'b1),
      .data_out (clk_0_reset_n),
      .reset_n  (reset_n_sources)
    );

  //reset sources mux, which is an e_mux
  assign reset_n_sources = ~(~reset_n |
    0 |
    cpu_0_jtag_debug_module_resetrequest_from_sa |
    cpu_0_jtag_debug_module_resetrequest_from_sa);


endmodule


//synthesis translate_off



// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE

// AND HERE WILL BE PRESERVED </ALTERA_NOTE>


// If user logic components use Altsync_Ram with convert_hex2ver.dll,
// set USE_convert_hex2ver in the user comments section above

// `ifdef USE_convert_hex2ver
// `else
// `define NO_PLI 1
// `endif

`include "d:/altera/91/quartus/eda/sim_lib/altera_mf.v"
`include "d:/altera/91/quartus/eda/sim_lib/220model.v"
`include "d:/altera/91/quartus/eda/sim_lib/sgate.v"
`include "dpram_wrclk.v"
`include "dpram_wrclk_en.v"
`include "sdram_0.v"
`include "sdram_0_test_component.v"
`include "freq_word.v"
`include "epcs_flash_controller_0.v"
`include "cpu_0_test_bench.v"
`include "cpu_0_oci_test_bench.v"
`include "cpu_0_jtag_debug_module_tck.v"
`include "cpu_0_jtag_debug_module_sysclk.v"
`include "cpu_0_jtag_debug_module_wrapper.v"
`include "cpu_0.v"
`include "uart_0.v"
`include "dpram_rdclk_en.v"
`include "UART2DPRAM.v"
`include "WRaddress.v"
`include "dpram_wr_en.v"

`timescale 1ns / 1ps

module test_bench 
;


  wire             clk;
  reg              clk_0;
  wire             epcs_flash_controller_0_epcs_control_port_dataavailable_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_endofpacket_from_sa;
  wire             epcs_flash_controller_0_epcs_control_port_readyfordata_from_sa;
  wire    [ 11: 0] out_port_from_the_UART2DPRAM;
  wire    [  9: 0] out_port_from_the_WRaddress;
  wire             out_port_from_the_dpram_rdclk_en;
  wire             out_port_from_the_dpram_wr_en;
  wire             out_port_from_the_dpram_wrclk;
  wire             out_port_from_the_dpram_wrclk_en;
  wire    [ 22: 0] out_port_from_the_freq_word;
  reg              reset_n;
  wire             rxd_to_the_uart_0;
  wire             txd_from_the_uart_0;
  wire             uart_0_s1_dataavailable_from_sa;
  wire             uart_0_s1_readyfordata_from_sa;
  wire    [ 11: 0] zs_addr_from_the_sdram_0;
  wire    [  1: 0] zs_ba_from_the_sdram_0;
  wire             zs_cas_n_from_the_sdram_0;
  wire             zs_cke_from_the_sdram_0;
  wire             zs_cs_n_from_the_sdram_0;
  wire    [ 15: 0] zs_dq_to_and_from_the_sdram_0;
  wire    [  1: 0] zs_dqm_from_the_sdram_0;
  wire             zs_ras_n_from_the_sdram_0;
  wire             zs_we_n_from_the_sdram_0;


// <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
//  add your signals and additional architecture here
// AND HERE WILL BE PRESERVED </ALTERA_NOTE>

  //Set us up the Dut
  AWG DUT
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

  sdram_0_test_component the_sdram_0_test_component
    (
      .clk      (clk_0),
      .zs_addr  (zs_addr_from_the_sdram_0),
      .zs_ba    (zs_ba_from_the_sdram_0),
      .zs_cas_n (zs_cas_n_from_the_sdram_0),
      .zs_cke   (zs_cke_from_the_sdram_0),
      .zs_cs_n  (zs_cs_n_from_the_sdram_0),
      .zs_dq    (zs_dq_to_and_from_the_sdram_0),
      .zs_dqm   (zs_dqm_from_the_sdram_0),
      .zs_ras_n (zs_ras_n_from_the_sdram_0),
      .zs_we_n  (zs_we_n_from_the_sdram_0)
    );

  initial
    clk_0 = 1'b0;
  always
    #10 clk_0 <= ~clk_0;
  
  initial 
    begin
      reset_n <= 0;
      #200 reset_n <= 1;
    end

endmodule


//synthesis translate_on