import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random
from test.test_encoder import Encoder

clocks_per_phase = 10
num_encoders = 3

async def reset(dut):
    for i in range(num_encoders):
        dut.enc_a[i] <= 0
        dut.enc_b[i] <= 0
    dut.reset  <= 1

    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5) # how long to wait for the debouncers to clear

async def run_encoder_test(encoder, dut_enc, max_count):
    for i in range(clocks_per_phase * 2 * max_count):
        await encoder.update(1)

    # let noisy transition finish, otherwise can get an extra count
    for i in range(10):
        await encoder.update(0)
    
    assert(dut_enc == max_count)

@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.clk, 10, units="us")
    encoders = []
    for i in range(num_encoders):
        encoders.append(Encoder(dut.clk, dut.enc_a[0], dut.enc_b[0], clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4))

    cocotb.fork(clock.start())

    await reset(dut)
    for i in range(num_encoders):
        assert dut.enc[i] == 0

    # pwm should all be low at start
    for i in range(num_encoders):
        assert dut.pwm_out[i] == 0

    # do 3 ramps for each encoder 
    max_count = 255
    for i in range(num_encoders):
        await run_encoder_test(encoders[i], dut.enc[i], max_count)

    # sync to pwm

    await RisingEdge(dut.pwm_out[0])
    # pwm should all be on for max_count 
    for i in range(max_count):
        for i in range(num_encoders):
            assert dut.pwm_out[i] == 1
        await ClockCycles(dut.clk, 1)
