module main

import os
import flag

struct App {
mut:
    gui Gui
    game Game
}

fn main() {
    mut fp := flag.new_flag_parser(os.args)
    fp.skip_executable()
    ai_mode := fp.bool("ai", `a`, false, "use AI to perform moves")
    enable_gui := fp.bool("gui", `g`, false, "run AI if GUI disabled")
    move_log := fp.bool("log", `l`, false, "log moves, disabled when AI enabled")

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
