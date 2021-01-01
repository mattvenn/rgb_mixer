import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

PERIOD = 10

class Encoder():

    CYCLE = [ 1, 1, 0, 0 ]
    AB_PHASE = 1
    NOISE_CYCLES = 5 # number of cycles at the edges of transitions vulnerable to bouncing
    NOISE_CHANCE = 0.5 # % chance of a bounce within the edges

    def __init__(self, dut):
        self.dut = dut
        self.cycle = 0

    async def update(self, incr = 1, clocks = 20):
        self.cycle += incr 
        a_phase = self.cycle % len(Encoder.CYCLE)
        b_phase = (self.cycle - Encoder.AB_PHASE) % len(Encoder.CYCLE)

        for i in range(clocks):
            self.dut.a <= Encoder.CYCLE[a_phase]
            self.dut.b <= Encoder.CYCLE[b_phase]

            # noise at edges
            if a_phase == 0 and i < Encoder.NOISE_CYCLES and random.random() < Encoder.NOISE_CHANCE:
                self.dut.a <= random.randint(0, 1)
            if a_phase == 1 and i > (clocks - Encoder.NOISE_CYCLES) and random.random() < Encoder.NOISE_CHANCE:
                self.dut.a <= random.randint(0, 1)

            if b_phase == 1 and i < Encoder.NOISE_CYCLES and random.random() < Encoder.NOISE_CHANCE:
                self.dut.b <= random.randint(0, 1)
            if b_phase == 2 and i > (clocks - Encoder.NOISE_CYCLES) and random.random() < Encoder.NOISE_CHANCE:
                self.dut.b <= random.randint(0, 1)

            await ClockCycles(self.dut.clk, 1)

@cocotb.test()
async def test(dut):
    clock = Clock(dut.clk, 10, units="us")
    encoder = Encoder(dut)
    cocotb.fork(clock.start())

    dut.a <= 1
    dut.b <= 0
    dut.reset <= 1;
    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)
    assert dut.encoder == 0

    for i in range(10):

        for i in range(100):
            await encoder.update(1, random.randint(20, 40))

        assert dut.encoder == 51

        for i in range(100):
            await encoder.update(-1, random.randint(20, 40))

        assert dut.encoder == 1
