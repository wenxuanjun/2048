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
    ]
)

fn main() {
    mut fp := flag.new_flag_parser(os.args)
    fp.skip_executable()
    ai_mode := fp.bool("ai", `a`, false, usage[0])
    enable_gui := fp.bool("gui", `g`, false, usage[1])
    move_log := fp.bool("log", `l`, false, usage[2])

    fp.finalize() or {
        println(fp.usage())
        return
    }

    config := &GameConfig {
        ai_mode: ai_mode,
        move_log: move_log,
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
