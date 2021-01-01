import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles

PERIOD = 10

class Encoder():

    CYCLE_A = [1, 1, 0, 0]
    CYCLE_B = [0, 1, 1, 0]

    def __init__(self, dut):
        self.dut = dut
        self.dut.a <= 0
        self.dut.b <= 0
        self.cycle = 0

    def update(self, incr):
        self.cycle += incr 
        if self.cycle > 3:
            self.cycle = 0
        if self.cycle < 0:
            self.cycle = 3

        self.dut.a <= Encoder.CYCLE_A[self.cycle]
        self.dut.b <= Encoder.CYCLE_B[self.cycle]

    async def increment(self):
        self.update(1)
        await ClockCycles(self.dut.clk, 5)
        self.update(1)
        await ClockCycles(self.dut.clk, 5)

    async def decrement(self):
        self.update(-1)
        await ClockCycles(self.dut.clk, 5)
        self.update(-1)
        await ClockCycles(self.dut.clk, 5)

@cocotb.test()
async def test(dut):
    clock = Clock(dut.clk, 10, units="us")
    encoder = Encoder(dut)
    cocotb.fork(clock.start())
    dut.reset <= 1;
    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)

    for i in range(5):
        await encoder.increment()
