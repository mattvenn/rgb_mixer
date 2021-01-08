# COCOTB variables
export COCOTB_REDUCED_LOG_FMT=1

all: test_encoder test_debounce test_pwm test_top $(PROJECT).bin

# test recipes

test_top:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s top -s dump -g2012 src/top.v test/dump_top.v src/ src/encoder.v src/debounce.v src/pwm.v
	MODULE=test.test_top vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_top:
	gtkwave top.vcd top.gtkw

test_encoder:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s test_encoder -s dump -g2012 test/dump_encoder.v test/test_encoder.v src/encoder.v src/debounce.v
	MODULE=test.test_encoder vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_encoder:
	gtkwave encoder.vcd encoder.gtkw

test_pwm:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s pwm -s dump -g2012 src/pwm.v test/dump_pwm.v
	MODULE=test.test_pwm vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_pwm:
	gtkwave pwm.vcd pwm.gtkw

test_debounce:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s debounce -s dump -g2012 src/debounce.v test/dump_debounce.v
	MODULE=test.test_debounce vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_debounce:
	gtkwave debounce.vcd debounce.gtkw

# general recipes

clean:
	rm -rf *vcd sim_build fpga/*log fpga/*bin test/__pycache__

