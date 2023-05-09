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

fn (mut game Game) clone() &Game {
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

fn (mut game Game) generate_number() {
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
	if empty_count > 0 {
		index := cells[rand.u8() % empty_count]
		random := rand.f32n(1.0) or { 0.0 }
		game.matrix[index / size][index % size] = if random < 0.9 { 2 } else { 4 }
	}
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

fn (mut game Game) print_board_matrix() {
	for i in 0 .. size {
		for j in 0 .. size {
			print(game.matrix[i][j])
			print('  ')
		}
		println('\n')
	}
}