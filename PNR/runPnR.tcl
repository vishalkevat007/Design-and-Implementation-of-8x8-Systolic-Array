###############################################################
# PnR Flow Script for Cadence Innovus
###############################################################

# --- Setup: Set search paths for netlist, LEF, and MMMC view files ---
set_db init_netlist_files ../Synthesis/outputs/tpu_netlist.v
set_db init_lef_files {../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef}
set_db init_power_nets VDD
set_db init_ground_nets VSS
set_db init_mmmc_files  tpu.view

# --- Read MMMC view, LEF, and netlist ---
read_mmmc tpu.view
read_physical -lef {../LEF/gsclib045_tech.lef ../LEF/gsclib045_macro.lef}
read_netlist ../Synthesis/outputs/tpu_netlist.v -top tpu_top
init_design

# --- Connect global power and ground nets ---
connect_global_net VDD -type pg_pin -pin_base_name VDD -inst_base_name *
connect_global_net VSS -type pg_pin -pin_base_name VSS -inst_base_name *

# --- Create Floorplan and assign I/O pins ---
create_floorplan -core_margins_by die -site CoreSite -core_density_size 1.0 0.6 10 10 10 10
#create_row -site CoreSiteDouble -spacing 3.42 -limit_rows_in_core
create_row -site CoreSiteDouble -limit_rows_in_core
read_io_file pins.io

# --- Power Planning: Add rings and stripes for VDD/VSS distribution ---
set_db add_rings_skip_shared_inner_ring none
set_db add_rings_avoid_short 1
set_db add_rings_ignore_rows 0
set_db add_rings_extend_over_row 0
add_rings -type core_rings -jog_distance 0.6 -threshold 0.6 -nets {VDD VSS} -follow core -layer {bottom Metal11 top Metal11 right Metal10 left Metal10} -width 0.7 -spacing .4 -offset 0.6
add_stripes -block_ring_top_layer_limit Metal11 -max_same_layer_jog_length 0.44 -pad_core_ring_bottom_layer_limit Metal9 -set_to_set_distance 5 -pad_core_ring_top_layer_limit Metal11 -spacing 0.4 -merge_stripes_value 0.6 -layer Metal10 -block_ring_bottom_layer_limit Metal9 -width 0.3 -nets {VDD VSS} 
route_special -connect core_pin -layer_change_range { Metal1(1) Metal11(11) } -block_pin_target nearest_target -core_pin_target first_after_row_end -allow_jogging 1 -crossover_via_layer_range { Metal1(1) Metal11(11) } -nets { VDD VSS } -allow_layer_change 1 -target_via_layer_range { Metal1(1) Metal11(11) }

# --- Optional: Read Scan DEF if using scan chains (currently commented out) ---
#read_def counter.scandef
#set_db reorder_scan_comp_logic true

# Set process node and flow effort
set_db design_process_node 45
set_db design_flow_effort extreme

# --- Placement Optimization ---
#set_db [get_db base_cells *BUFX2*] .dont_use true
# set_db [get_db base_cells *BUFX2*] .dont_touch true
place_opt_design
write_db placeOpt  ;# Save placement optimization database

# --- Clock Tree Synthesis (CTS) ---
create_clock_tree_spec
ccopt_design
write_db postCTSopt  ;# Save post-CTS database

# --- Detailed Routing and RC Extraction ---
#set_db route_design_with_timing_driven 1
#set_db route_design_with_si_driven 1
#set_db design_top_routing_layer Metal11
#set_db design_bottom_routing_layer Metal1
#set_db route_design_detail_end_iteration 0
#set_db route_design_with_timing_driven true
#set_db route_design_with_si_driven true
route_design -global_detail
reset_parasitics
extract_rc

