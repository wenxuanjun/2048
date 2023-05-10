import rand

import rand.pcg32
import rand.mt19937
import rand.xoroshiro128pp
import rand.wyrand

fn get_prng(algo string) &rand.PRNG {
	match algo {
		"pcg32" {
			return &rand.PRNG(pcg32.PCG32RNG{})
		}
		"mt19937" {
			return &rand.PRNG(mt19937.MT19937RNG{})
		}
		"xoroshiro128pp" {
			return &rand.PRNG(xoroshiro128pp.XOROS128PPRNG{})
		}
		"wyrand" {
			return &rand.PRNG(wyrand.WyRandRNG{})
		}
		else { panic("Unknown PRNG!") }
	}
}