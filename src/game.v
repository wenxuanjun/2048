module main

import gg
import strings

const (
    size = 4
    init_number_count = 2
	directions = [Direction.up, .down, .left, .right]
)

enum Direction {
	left
	right
	up
	down
}

struct Game {
mut:
    score int
	moves int
    matrix [size][size]int
    can_move CanMove
}

fn game_init() &Game {
	mut game := &Game{
    	score: 0
		moves: 0
        matrix: [size][size]int{}
        can_move: &CanMove{}
	}

	// Generate the init numbers
    for _ in 0 .. init_number_count {
        game.generate_number()
    }
    game.refresh_move_status()

	return game
}

fn (game Game) clone() &Game {
	mut new_game := &Game{
		score: game.score
		matrix: [size][size]int{}
		can_move: &CanMove{
			left: game.can_move.left
			right: game.can_move.right
			up: game.can_move.up
			down: game.can_move.down
		}
	}
	for i in 0 .. size {
		for j in 0 .. size {
			new_game.matrix[i][j] = game.matrix[i][j]
		}
	}
	return new_game
}

fn (mut game Game) step(dir Direction) {
	// Return directly if cannot move
	if !game.can_move.query(dir) {
		return
	}

	// Move, spawn new number and refresh move status
	game.move(dir)
	game.generate_number()
	game.refresh_move_status()
	game.moves++

	// Print the matrix and status
	if !enable_ai && move_log {
		println('Score: ' + game.score.str())
		game.print_board_matrix()
		println('Status: ${game.can_move}')
	}

	// Judge whether the game is over
	if !game.can_move.exist() {
		println('Game Over!')
		game.print_board_matrix()
		println('Final score: ${game.score}')
		exit(0)
	}
}

[inline]
fn get_dir(key gg.KeyCode) ?Direction {
	match key {
		.left { return .left }
		.right { return .right }
		.up { return .up }
		.down { return .down }
		else { return none }
	}
}

fn (game Game) find_empty_cells(prob ...f32) []int {
	mut empty_count := 0
	mut cells := []int{len: size * size}
	for i in 0 .. size {
		for j in 0 .. size {
			if game.matrix[i][j] == 0 {
				cells[empty_count] = i * size + j
				empty_count++
			}
		}
	}
	cells.trim(empty_count)
	return cells
}

[inline]
fn (game Game) count_empty_num() int {
	cells := game.find_empty_cells()
	return cells.len
}

[inline]
fn (mut game Game) put_number(row int, col int, value int) ? {
	if game.matrix[row][col] != 0 {
		panic("Cannot put number where not eq zero!")
	}
	game.matrix[row][col] = value
}

fn (mut game Game) generate_number() {
	cells := game.find_empty_cells()
	if cells.len > 0 {
		// Generate only once due to performance issue
		rand_val := rng.u32()
		index := cells[rand_val % u32(cells.len)]
		value := if rand_val % 10 < 9 { 2 } else { 4 }
		game.put_number(index / size, index % size, value)
	}
}

fn (game Game) get_max_number() int {
	mut max_number := 0
    for i in 0 .. size {
        for j in 0 .. size {
            if game.matrix[i][j] >= max_number {
                max_number = game.matrix[i][j]
        	}
        }
    }
	return max_number
}

fn (game Game) get_valid_actions() []Direction {
	mut valid_actions := []Direction{cap: 4}
	for dir in directions {
		if game.can_move.query(dir) {
			valid_actions << dir
		}
	}
	return valid_actions
}

[inline]
fn (mut game Game) refresh_move_status() {
	game.can_move = &CanMove{
		left: game.can_move_left()
		right: game.can_move_right()
		up: game.can_move_up()
		down: game.can_move_down()
	}
}

fn (game Game) print_board_matrix() {
	for i in 0 .. size {
		for j in 0 .. size {
			print(game.matrix[i][j])
			print('  ')
		}
		println('\n')
	}
}

fn (game Game) get_state_string() string {
    // Generate game state unique string
	mut string_builder := strings.new_builder(100)
	for row := 0; row < size; row++ {
		for col := 0; col < size; col++ {
			string_builder.write_string(game.matrix[row][col].str())
			string_builder.write_u8(`|`)
		}
	}
	return string_builder.str()
}