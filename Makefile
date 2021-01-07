# cocotb setup
export COCOTB_REDUCED_LOG_FMT=1
all: test_encoder test_debounce test_pwm test_top

test_top:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s top -s dump -g2012 src/top.v src/dump_top.v src/ src/encoder.v src/debounce.v src/pwm.v
	MODULE=test.test_top vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_top:
	gtkwave top.vcd top.gtkw

test_encoder:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s test_encoder -s dump -g2012 src/dump_encoder.v src/test_encoder.v src/encoder.v src/debounce.v
	MODULE=test.test_encoder vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_encoder:
	gtkwave encoder.vcd encoder.gtkw

test_pwm:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s pwm -s dump -g2012 src/pwm.v src/dump_pwm.v
	MODULE=test.test_pwm vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_pwm:
	gtkwave pwm.vcd pwm.gtkw

test_debounce:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s debounce -s dump -g2012 src/debounce.v src/dump_debounce.v
	MODULE=test.test_debounce vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_debounce:
	gtkwave debounce.vcd debounce.gtkw

clean:
	rm -rf *vcd sim_build

PROJECT = encoder_pwm
SOURCES= src/top.v src/encoder.v src/debounce.v src/pwm.v
ICEBREAKER_DEVICE = up5k
ICEBREAKER_PIN_DEF = icebreaker.pcf
ICEBREAKER_PACKAGE = sg48
SEED = 1

all: $(PROJECT).bin

%.json: $(SOURCES)
	yosys -l yosys.log -p 'synth_ice40 -top top -json $(PROJECT).json' $(SOURCES)

%.asc: %.json $(ICEBREAKER_PIN_DEF) 
	nextpnr-ice40 -l nextpnr.log --seed $(SEED) --freq 20 --package $(ICEBREAKER_PACKAGE) --$(ICEBREAKER_DEVICE) --asc $@ --pcf $(ICEBREAKER_PIN_DEF) --json $<

%.bin: %.asc
	icepack $< $@

prog: $(PROJECT).bin
	iceprog $<

#clean:
#	rm -f ${PROJECT}.json ${PROJECT}.asc ${PROJECT}.bin *log

.PHONY: clean
