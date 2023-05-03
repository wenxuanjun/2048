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
    matrix [][]int
    can_move CanMove
	ai_mode bool
}

fn game_init(ai_mode bool) &Game {
	mut game := &Game{
        score: 0
        matrix: [][]int{}
        can_move: &CanMove{}
		ai_mode: ai_mode
	}

	game.matrix = [][]int{
        len: size,
        init: []int{len: size}
    }

	// 生成最开始的数字
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
		ai_mode: game.ai_mode
	}
	return new_game
}

fn (mut game Game) step(dir Direction) {
	// 判断是否可以移动，否则直接返回
	if game.can_move.query(dir) {
		game.move(dir)
	} else {
		return
	}

	// 生成新的数字并刷新可移动状态
	game.generate_number()
	game.refresh_move_status()

	// 打印矩阵和状态
	if !game.ai_mode {
		println('Score: ' + game.score.str())
		game.print_board_matrix()
		println('Status: ${game.can_move}')
	}

	// 判断游戏是否结束
	if !game.can_move.exist() {
		println('Game Over!')
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
	mut empty_cells := []int{}
	for i in 0 .. size {
		for j in 0 .. size {
			if game.matrix[i][j] == 0 {
				empty_cells << i * size + j
			}
		}
	}
	if empty_cells.len > 0 {
		index := empty_cells[rand.intn(empty_cells.len) or { 0 }]
		random := rand.f64n(1.0) or { 0.0 }
		game.matrix[index / size][index % size] = if random < 0.9 { 2 } else { 4 }
	}
}

[inline]
fn (mut game Game) refresh_move_status() {
	game.can_move = &CanMove{
		left: game.can_move(.left)
		right: game.can_move(.right)
		up: game.can_move(.up)
		down: game.can_move(.down)
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