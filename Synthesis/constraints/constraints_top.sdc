###############################################################
# SDC Constraints for Systolic Array Design (Genus Compatible)
###############################################################

# Create the primary clock (3.01 ns period)
create_clock -name clk -period 5.00 [get_ports clk]

# Set the clk port as an ideal network (skip insertion, ideal for synthesis)
set_ideal_network [get_ports clk]
set_dont_touch_network [get_clocks clk]

# Set clock transition time (rise and fall)
set_clock_transition -rise 0.1 [get_clocks clk]
set_clock_transition -fall 0.1 [get_clocks clk]

# Set uncertainty to model jitter/skew for the clock network
set_clock_uncertainty 0.1 [get_clocks clk]

# Input/Output Delays — adjust according to actual environment or testbench
set_input_delay -max 2.50 -clock [get_clocks clk] [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 2.50 -clock [get_clocks clk] [all_outputs]

# Set false paths for non-clocked inputs/outputs during hold analysis
set_false_path -hold -from [remove_from_collection [all_inputs] [get_ports clk]]
set_false_path -hold -to [all_outputs]

# Wireload model settings (use defaults or skip if not used)
# Optional: let Genus handle wireload automatically
set auto_wire_load_selection area_reselect
set_wire_load_mode enclosed

