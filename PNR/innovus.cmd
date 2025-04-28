#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Mon Apr 28 00:45:53 2025                
#                                                     
#######################################################

#@(#)CDS: Innovus v21.17-s075_1 (64bit) 03/15/2023 11:17 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: NanoRoute 21.17-s075_1 NR230308-2354/21_17-UB (database version 18.20.604) {superthreading v2.17}
#@(#)CDS: AAE 21.17-s026 (64bit) 03/15/2023 (Linux 3.10.0-693.el7.x86_64)
#@(#)CDS: CTE 21.17-s025_1 () Mar 14 2023 11:00:06 ( )
#@(#)CDS: SYNTECH 21.17-s007_1 () Feb 20 2023 06:56:35 ( )
#@(#)CDS: CPE v21.17-s068
#@(#)CDS: IQuantus/TQuantus 21.1.1-s939 (64bit) Wed Nov 9 09:34:24 PST 2022 (Linux 3.10.0-693.el7.x86_64)

#@ source runPnR.tcl 
#@ Begin verbose source (pre): source runPnR.tcl 
set_db init_netlist_files ../Synthesis/outputs/tpu_netlist.v
set_db init_lef_files {../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef}
set_db init_power_nets VDD
set_db init_ground_nets VSS
set_db init_mmmc_files  tpu.view
read_mmmc tpu.view
#@ Begin verbose source tpu.view (pre)
create_library_set -name max_timing\
   -timing ../LIB/slow_vdd1v0_basicCells.lib
create_library_set -name min_timing\
   -timing ../LIB/fast_vdd1v0_basicCells.lib
create_timing_condition -name default_mapping_tc_2\
   -library_sets min_timing
create_timing_condition -name default_mapping_tc_1\
   -library_sets max_timing
create_rc_corner -name rccorners\
   -cap_table ../Captable/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -qrc_tech ../QRC_tech/gpdk045.tch
create_delay_corner -name max_delay\
   -timing_condition {default_mapping_tc_1}\
   -rc_corner rccorners
create_delay_corner -name min_delay\
   -timing_condition {default_mapping_tc_2}\
   -rc_corner rccorners
create_constraint_mode -name sdc_cons\
   -sdc_files\
    ../Synthesis/outputs/tpu_sdc.sdc 
create_analysis_view -name wc -constraint_mode sdc_cons -delay_corner max_delay
create_analysis_view -name bc -constraint_mode sdc_cons -delay_corner min_delay
set_analysis_view -setup wc -hold bc
#@ End verbose source tpu.view
read_physical -lef {../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef}
read_netlist ../Synthesis/outputs/tpu_netlist.v -top tpu_top
init_design
connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name *
create_floorplan -core_margins_by die -site CoreSite -core_density_size 1.0 0.6 10 10 10 10
create_row -site CoreSiteDouble -limit_rows_in_core
read_io_file pins.io
set_db add_rings_skip_shared_inner_ring none
set_db add_rings_avoid_short 1
set_db add_rings_ignore_rows 0
set_db add_rings_extend_over_row 0
add_rings -type core_rings -jog_distance 0.6 -threshold 0.6 -nets {VDD VSS} -follow core -layer {bottom Metal11 top Metal11 right Metal10 left Metal10} -width 0.7 -spacing .4 -offset 0.6
add_stripes -block_ring_top_layer_limit Metal11 -max_same_layer_jog_length 0.44 -pad_core_ring_bottom_layer_limit Metal9 -set_to_set_distance 5 -pad_core_ring_top_layer_limit Metal11 -spacing 0.4 -merge_stripes_value 0.6 -layer Metal10 -block_ring_bottom_layer_limit Metal9 -width 0.3 -nets {VDD VSS} 
route_special -connect core_pin -layer_change_range { Metal1(1) Metal11(11) } -block_pin_target nearest_target -core_pin_target first_after_row_end -allow_jogging 1 -crossover_via_layer_range { Metal1(1) Metal11(11) } -nets { VDD VSS } -allow_layer_change 1 -target_via_layer_range { Metal1(1) Metal11(11) }
set_db design_process_node 45
set_db design_flow_effort extreme
place_opt_design
write_db placeOpt  ;
create_clock_tree_spec
ccopt_design
write_db postCTSopt  ;
route_design -global_detail
reset_parasitics
extract_rc
#@ End verbose source: runPnR.tcl
set_db check_drc_disable_rules {}
set_db check_drc_ndr_spacing auto
set_db check_drc_check_only default
set_db check_drc_inside_via_def true
set_db check_drc_exclude_pg_net false
set_db check_drc_ignore_trial_route false
set_db check_drc_ignore_cell_blockage false
set_db check_drc_use_min_spacing_on_block_obs auto
set_db check_drc_report tpu_top.drc.rpt
set_db check_drc_limit 1000
check_drc
set_db check_drc_area {0 0 0 0}
check_connectivity -type all -error 1000 -warning 50
write_db saved_design
