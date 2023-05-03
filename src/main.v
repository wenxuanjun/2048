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
    ai_mode := fp.bool("ai", `a`, false, "enable ai mode")

    fp.finalize() or {
        println(fp.usage())
        return
    }

    game := game_init(ai_mode)
    mut app := &App {
        game: game,
        gui: gui_init(*game),
    }
    app.gui.gg.run()
}
