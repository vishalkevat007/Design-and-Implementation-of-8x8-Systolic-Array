###############################################################
# Synthesis Script for Cadence Genus - Systolic Array Project
###############################################################

# Setup search paths
set_db init_lib_search_path ../LIB/
set_db init_hdl_search_path ../RTL/

# Read library and RTL design files
read_libs slow_vdd1v0_basicCells.lib

# Read all required RTL files (order matters if dependencies exist)
read_hdl {
    tpu_top.v
    addr_sel.v
    quantize.v
    systolic.v
    systolic_controll.v
    write_out.v
}

# Prevent unused registers removal
set_db hdl_preserve_unused_registers true

# Set the top-level design
elaborate tpu_top

# Disable flip-flop and latch removal/optimizations
set_db delete_unloaded_seqs false
set_db optimize_constant_feedback_seq false
set_db optimize_constant_0_flops false
set_db optimize_constant_1_flops false
set_db optimize_merge_flops false
set_db optimize_constant_latches false
set_db optimize_merge_latches false

# Read constraints
read_sdc constraints/constraints_top.sdc

# Set synthesis effort levels
set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

#Avoid BUFX2
set_db base_cell:BUFX2 .dont_use true

# Run synthesis passes
syn_generic
syn_map
syn_opt

# Generate synthesis reports
report_timing > reports/tpu_report_timing.rpt
report_power  > reports/tpu_report_power.rpt
report_area   > reports/tpu_report_area.rpt
report_qor    > reports/tpu_report_qor.rpt

# Write synthesized outputs
write_hdl > outputs/tpu_netlist.v
write_sdc > outputs/tpu_sdc.sdc
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/tpu_delays.sdf

