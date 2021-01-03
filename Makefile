# cocotb setup
export COCOTB_REDUCED_LOG_FMT=1
MODULE = test
TOPLEVEL = top
VERILOG_SOURCES = src/top.v src/encoder.v src/debounce.v src/pwm.v

include $(shell cocotb-config --makefiles)/Makefile.sim
