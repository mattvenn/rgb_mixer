import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

class Encoder():

    CYCLE = [ 1, 1, 0, 0 ]

    # number of cycles at the edges of transitions vulnerable to bouncing
    # % chance of a bounce within the edges
    def __init__(self, dut, clocks_per_phase = 20, noise_cycles = 5, noise_chance = 0.5):
        self.dut = dut
        self.cycle = 0
        self.clocks_per_phase = clocks_per_phase
        self.noise_chance = noise_chance
        self.noise_cycles = noise_cycles
        self.a_phase = 3
        self.b_phase = 2
        self.last_a_phase = 3
        self.last_b_phase = 2
        self.a_edge = 0
        self.b_edge = 0

    def set_clocks_per_phase(self, clocks_per_phase):
        self.clocks_per_phase = clocks_per_phase

    async def update(self, incr = 1):
        await ClockCycles(self.dut.clk, 1)
        self.cycle += 1 
        if self.cycle % self.clocks_per_phase == 0:
            # advance a phase
            self.a_phase = (self.a_phase + incr) % len(Encoder.CYCLE)
            self.b_phase = (self.b_phase + incr) % len(Encoder.CYCLE)

            # if a transition just happened, make a note of where we are for triggering noisy edges
            if Encoder.CYCLE[self.a_phase] != Encoder.CYCLE[self.last_a_phase]:
                self.a_edge = self.cycle
            
            if Encoder.CYCLE[self.b_phase] != Encoder.CYCLE[self.last_b_phase]:
                self.b_edge = self.cycle 

            self.last_a_phase = self.a_phase
            self.last_b_phase = self.b_phase

        # set encoder inputs
        self.dut.a <= Encoder.CYCLE[self.a_phase]
        self.dut.b <= Encoder.CYCLE[self.b_phase]

        # randomly generate noise at edges
        if (self.cycle - self.a_edge) < self.noise_cycles and random.random() < self.noise_chance:
            self.dut.a <= random.randint(0, 1)
        if (self.cycle - self.b_edge) < self.noise_cycles and random.random() < self.noise_chance:
            self.dut.b <= random.randint(0, 1)

async def reset(dut):
    dut.a <= 0
    dut.b <= 0
    dut.reset <= 1

    await ClockCycles(dut.clk, 5)
    dut.reset <= 0;
    await ClockCycles(dut.clk, 5)

@cocotb.test()
async def test_encoder(dut):
    clock = Clock(dut.clk, 10, units="us")
    clocks_per_phase = 10
    encoder = Encoder(dut, clocks_per_phase = clocks_per_phase, noise_cycles = clocks_per_phase / 4)
    cocotb.fork(clock.start())

    await reset(dut)
    assert dut.encoder == 0

    # count up
    for i in range(clocks_per_phase * 2 *  255):
        await encoder.update(1)

    # let noisy transition finish, otherwise can get an extra count
    for i in range(10):
        await encoder.update(0)
    
    assert(dut.encoder == 255)

    # count down
    for i in range(clocks_per_phase * 2 * 255):
        await encoder.update(-1)

    # let noisy transition finish
    for i in range(10):
        await encoder.update(0)

    assert(dut.encoder == 0)

@cocotb.test()
async def test_pwm(dut):
    clock = Clock(dut.clk, 10, units="us")
    cocotb.fork(clock.start())
    
    # test a range of values
    for i in range(10, 255, 20):
        await reset(dut)
        # set pwm to this level
        dut.pwm_inst.level <= i

        # synchronise to pwm out going high
        await RisingEdge(dut.pwm_out)
        # wait pwm level clock steps
        await ClockCycles(dut.clk, i)

        # assert still high
        assert(dut.pwm_out)

        # wait for next rising clk edge
        await RisingEdge(dut.clk)

        # assert pwm goes low
        assert(dut.pwm_out == 0)
