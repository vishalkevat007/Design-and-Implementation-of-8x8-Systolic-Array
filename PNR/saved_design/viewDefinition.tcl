if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name max_timing\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells.lib]
create_library_set -name min_timing\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib]
create_timing_condition -name default_mapping_tc_2\
   -library_sets [list min_timing]
create_timing_condition -name default_mapping_tc_1\
   -library_sets [list max_timing]
create_rc_corner -name rccorners\
   -cap_table ${::IMEX::libVar}/mmmc/cln28hpl_1p10m+alrdl_5x2yu2yz_typical.capTbl\
   -pre_route_res 1\
   -post_route_res 1\
   -pre_route_cap 1\
   -post_route_cap 1\
   -post_route_cross_cap 1\
   -pre_route_clock_res 0\
   -pre_route_clock_cap 0\
   -qrc_tech ${::IMEX::libVar}/mmmc/rccorners/gpdk045.tch
create_delay_corner -name max_delay\
   -timing_condition {default_mapping_tc_1}\
   -rc_corner rccorners
create_delay_corner -name min_delay\
   -timing_condition {default_mapping_tc_2}\
   -rc_corner rccorners
create_constraint_mode -name sdc_cons\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/sdc_cons/sdc_cons.sdc]
create_analysis_view -name wc -constraint_mode sdc_cons -delay_corner max_delay -latency_file ${::IMEX::dataVar}/mmmc/views/wc/latency.sdc
create_analysis_view -name bc -constraint_mode sdc_cons -delay_corner min_delay -latency_file ${::IMEX::dataVar}/mmmc/views/bc/latency.sdc
set_analysis_view -setup [list wc] -hold [list bc]
