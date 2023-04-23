import ui
import rand

enum Direction {
	left
	right
	up
	down
}

fn (mut game Game) step(key ui.Key) {
	// 根据按键获取方向
	dir := get_dir(key)

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
	println('Score: ' + game.score.str())
	game.print_matrix()
	println('Status: ${game.can_move}')

	// 判断游戏是否结束
	if !game.can_move.exist() {
		println('Game Over!')
		exit(0)
	}
}

[inline]
fn get_dir(key ui.Key) Direction {
	match key {
		.left { return .left }
		.right { return .right }
		.up { return .up }
		.down { return .down }
		else { return .left }
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
		random := if rand.intn(10) or { 0 } < 9 { 2 } else { 4 }
		game.matrix[index / size][index % size] = random
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

fn (mut game Game) print_matrix() {
	for i in 0 .. size {
		for j in 0 .. size {
			print(game.matrix[i][j])
			print('  ')
		}
		println('\n')
	}
}