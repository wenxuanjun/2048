module main

import ui

const (
    size = 4
    init_number_count = 2
    window_width = 400
    window_height = 600
)

[heap]
struct Game {
mut:
    score int
    window &ui.Window
    matrix [][]int
    can_move CanMove
}

fn main() {
    mut game := &Game {
        score: 0
        window: 0
        matrix: [][]int{len: size, init: []int{len: size}}
        can_move: &CanMove{}
    }

    for _ in 0 .. init_number_count {
        game.generate_number()
    }

    game.refresh_move_status()
    game.window = ui.window(
        title: '2048'
        width: window_width
        height: window_height
		on_key_down: fn [mut game] (_ &ui.Window, e ui.KeyEvent) {
            game.step(e.key)
        }
    )
    ui.run(game.window)
}
