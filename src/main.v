module main

import os
import flag

struct App {
mut:
    gui Gui
    game Game
}

const (
    usage = [
        "use AI to perform moves"
        "always run AI if GUI disabled"
        "log moves, disabled when AI enabled"
        "the AI algorithm to use"
        "random number generator algorithm"
        "list available random number generators"
    ]
)

fn main() {
    mut fp := flag.new_flag_parser(os.args)
    fp.skip_executable()
    ai_mode := fp.bool("ai", `a`, false, usage[0])
    enable_gui := fp.bool("gui", `g`, false, usage[1])
    move_log := fp.bool("log", `l`, false, usage[2])
    ai_algo := fp.string("algo", `A`, "dfs", usage[3])
    rand_algo := fp.string("rand", `r`, "xoroshiro128pp", usage[4])
    list_rand := fp.bool("list", `L`, false, usage[5])

    fp.finalize() or {
        println(fp.usage())
        return
    }

    if list_rand {
        list_prng() return
    }

    config := &GameConfig {
        ai_mode: ai_mode,
        move_log: move_log,
        ai_algo: algo_from_str(ai_algo),
        rng: get_prng(rand_algo)
    }

    mut game := game_init(config)

    if enable_gui {
        mut app := &App {
            game: game,
            gui: gui_init(*game),
        }
        app.gui.gg.run()
    } else {
        for {
            game.ai_move()
        }
    }
}
