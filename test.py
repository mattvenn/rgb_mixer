import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

PERIOD = 10

class Encoder():

    CYCLE = [
               1, 0, 1, 1,
               1, 1, 1, 1,
               1, 1, 1, 1,
               1, 1, 0, 1,
               1, 0, 1, 0,
               0, 0, 0, 0,
               0, 0, 0, 0,
               0, 0, 0, 1,
               1, 0, 1, 0,
               1, 1, 1, 1,
               1, 1, 1, 1,
               1, 1, 1, 0,
               1, 1, 1, 0,
               0, 0, 0, 0,
               0, 0, 0, 0,
               0, 0, 1, 0,
               ]
    AB_PHASE = 8

    def __init__(self, dut):
        self.dut = dut
        self.dut.a <= 0
        self.dut.b <= 0
        self.cycle = 0

    async def update(self, incr):
        self.cycle += incr 

        await ClockCycles(self.dut.clk, 1)
        self.dut.a <= Encoder.CYCLE[self.cycle % len(Encoder.CYCLE)]
        self.dut.b <= Encoder.CYCLE[(self.cycle - Encoder.AB_PHASE) % len(Encoder.CYCLE)]

@cocotb.test()
async def test(dut):
    clock = Clock(dut.clk, 10, units="us")
    encoder = Encoder(dut)
    cocotb.fork(clock.start())
    dut.reset <= 1;
    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)

    for i in range(2 * len(Encoder.CYCLE)):
        await encoder.update(1)
    for i in range(2 * len(Encoder.CYCLE)):
        await encoder.update(-1)
