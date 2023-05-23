import gg
import rand

const (
    size = 4
    init_number_count = 2
)

enum Direction {
	left
	right
	up
	down
}

[heap]
struct Game {
mut:
    score int
	moves int
    matrix [][]int
    can_move CanMove
	config GameConfig
}

struct GameConfig {
	ai_mode bool
	move_log bool
	ai_algo AiAlgo
mut:
	rng rand.PRNG
}

fn game_init(config GameConfig) &Game {
	mut game := &Game{
    	score: 0
		moves: 0
        matrix: [][]int{}
        can_move: &CanMove{}
		config: config
	}

	// Initialize the matrix
	game.matrix = [][]int{
        len: size,
        init: []int{len: size}
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
		matrix: game.matrix.clone()
		can_move: &CanMove{
			left: game.can_move.left
			right: game.can_move.right
			up: game.can_move.up
			down: game.can_move.down
		}
		config: game.config
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
	if !game.config.ai_mode && game.config.move_log {
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
	mut cells := []int{ len: size * size }
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
		index := cells[game.config.rng.u8() % cells.len]
		random := game.config.rng.f32n(1.0) or { 0.0 }
		value := if random < 0.9 { 2 } else { 4 }
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