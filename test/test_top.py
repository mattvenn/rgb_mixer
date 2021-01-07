import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random
from test.test_encoder import Encoder

async def reset(dut):
    dut.enc0_a <= 0
    dut.enc0_b <= 0
    dut.enc1_a <= 0
    dut.enc1_b <= 0
    dut.enc2_a <= 0
    dut.enc2_b <= 0
    dut.reset <= 1

    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)

@cocotb.test()
async def test_all(dut):
    clock = Clock(dut.clk, 10, units="us")
    clocks_per_phase = 10
    encoder0 = Encoder(dut.clk, dut.enc0_a, dut.enc0_b, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)
    encoder1 = Encoder(dut.clk, dut.enc1_a, dut.enc1_b, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)
    encoder2 = Encoder(dut.clk, dut.enc2_a, dut.enc2_b, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)

    cocotb.fork(clock.start())

    await reset(dut)
    assert dut.enc0 == 0
    assert dut.enc1 == 0
    assert dut.enc2 == 0

    # do 3 ramps for each encoder
    for encoder, dut_enc in zip([encoder0, encoder1, encoder2], [dut.enc0, dut.enc1, dut.enc2]):
        # count up encoder 0
        for i in range(clocks_per_phase * 2 *  255):
            await encoder.update(1)

        # let noisy transition finish, otherwise can get an extra count
        for i in range(10):
            await encoder.update(0)
        
        assert(dut_enc == 255)
