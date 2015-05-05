
# ** Clock Latency
#    -------------
set_time_format -unit ps -decimal_places 0
create_clock -period 5000 -waveform {0.000 2500} -name clk clk

# ** Multicycles
#    -----------
set_multicycle_path -setup -end -from {LU:compBlock|LUControl:conBlock|m*} -to {LU:compBlock|LUControl:conBlock|mdivk*} 15
set_multicycle_path -hold -end -from {LU:compBlock|LUControl:conBlock|m*} -to {LU:compBlock|LUControl:conBlock|mdivk*} 15
set_multicycle_path -setup -end -from {LU:compBlock|divsp:rec|*} -to {LU:compBlock|divsp:rec|*} 50
set_multicycle_path -hold -end -from {LU:compBlock|divsp:rec|*} -to {LU:compBlock|divsp:rec|*} 50
set_multicycle_path -setup -end -from {MarshallerController:MC|N*} -to {MarshallerController:MC|Ndivk*} 15
set_multicycle_path -hold -end -from {MarshallerController:MC|N*} -to {MarshallerController:MC|Ndivk*} 15

# ---------------------------------------------

