module main

import gg

const (
    size = 4
    init_number_count = 2
    default_width = 465
    default_height = 500
    window_title = "2048"
)

[heap]
struct App {
mut:
    score int
    gg &gg.Context
    matrix [][]int
    can_move CanMove
    window Window
}

fn main() {
    mut app := &App {
        gg: 0
        score: 0
        matrix: [][]int{}
        can_move: &CanMove{}
    }
    app.gui_init()
    app.game_init()
    app.gg.run()
}
