import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
    dut.reset.value = 1

    await ClockCycles(dut.clk, 5)
    dut.reset.value = 0;

@cocotb.test()
async def test_pwm(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    
    # test a range of values
    for i in range(10, 255, 20):
        # set pwm to this level
        dut.level.value = i

        await reset(dut)

        # wait pwm level clock steps
        for on in range(i):
            await RisingEdge(dut.clk)

            # assert high
            assert(dut.out)

        for off in range(255-i):
            await RisingEdge(dut.clk)

            # assert low
            assert(dut.out == 0)

        
