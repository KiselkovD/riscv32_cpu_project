# waveform.do - ModelSim simulation script

# Clear previous waves and restart simulation
restart -f

# Add all signals under the testbench top module to waveform viewer
add wave -resize sim:/RV32ICPU/*

# Optionally add specific signals for clearer view
# add wave sim:/RV32ICPU/pc
# add wave sim:/RV32ICPU/instruction
# add wave sim:/RV32ICPU/alu_result
# add wave sim:/RV32ICPU/mem_read
# add wave sim:/RV32ICPU/mem_write
# add wave sim:/RV32ICPU/reg_write
# add wave sim:/RV32ICPU/rs1_data
# add wave sim:/RV32ICPU/rs2_data

# Run simulation for 1000 ns
run 1000ns

# Keep waveform window open (ModelSim default)
