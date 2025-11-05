@[has_globals]
module main

import os
import flag
import rand

__global (
    rng &rand.PRNG
    ai_algo AiAlgo
    enable_ai bool
    move_log bool
    q_table &QTable
)

const usage = [
    "use AI to perform moves"
    "always run AI if GUI disabled"
    "log moves, disabled when AI enabled"
    "the AI algorithm to use"
    "random number generator algorithm"
    "list available random number generators"
]

fn main() {
    mut fp := flag.new_flag_parser(os.args)
    fp.skip_executable()
    enable_ai_tmp := fp.bool("ai", `a`, false, usage[0])
    enable_gui := fp.bool("gui", `g`, false, usage[1])
    move_log_tmp := fp.bool("log", `l`, false, usage[2])
    ai_algo_tmp := fp.string("algo", `A`, "dfs", usage[3])
    rand_algo := fp.string("rand", `r`, "xoroshiro128pp", usage[4])
    list_rand := fp.bool("list", `L`, false, usage[5])

    fp.finalize() or {
        println(fp.usage())
        return
    }

    if list_rand {
        list_prng() return
    }

    // Init global variables
    rng = get_prng(rand_algo)
    ai_algo = algo_from_str(ai_algo_tmp)
    move_log = move_log_tmp
    enable_ai = enable_ai_tmp
    q_table = &QTable{
        data: map[string]map[Direction]f64{}
    }

    mut game := game_init()

    if ai_algo == AiAlgo.reinforcement {
        println("Training Q table...")
        game.train_qlearning()
        println("Training done, starting game!")
    }

    if enable_gui {
        mut gui := gui_init(*game)
        gui.gg.run()
    } else {
        for {
            game.ai_move()
        }
    }
}
