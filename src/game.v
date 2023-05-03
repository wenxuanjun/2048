import gg
import rand

enum Direction {
	left
	right
	up
	down
}

fn (mut app App) game_init() {
	app.matrix = [][]int{
        len: size,
        init: []int{len: size}
    }

    for _ in 0 .. init_number_count {
        app.generate_number()
    }

    app.refresh_move_status()
}

fn (mut app App) step(key gg.KeyCode) {
	// 根据按键获取方向
	dir := get_dir(key) or { return }

	// 判断是否可以移动，否则直接返回
	if app.can_move.query(dir) {
		app.move(dir)
	} else {
		return
	}

	// 生成新的数字并刷新可移动状态
	app.generate_number()
	app.refresh_move_status()

	// 打印矩阵和状态
	println('Score: ' + app.score.str())
	app.print_board_matrix()
	println('Status: ${app.can_move}')

	// 判断游戏是否结束
	if !app.can_move.exist() {
		println('App Over!')
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

fn (mut app App) generate_number() {
	mut empty_cells := []int{}
	for i in 0 .. size {
		for j in 0 .. size {
			if app.matrix[i][j] == 0 {
				empty_cells << i * size + j
			}
		}
	}
	if empty_cells.len > 0 {
		index := empty_cells[rand.intn(empty_cells.len) or { 0 }]
		random := rand.f64n(1.0) or { 0.0 }
		app.matrix[index / size][index % size] = if random < 0.9 { 2 } else { 4 }
	}
}

[inline]
fn (mut app App) refresh_move_status() {
	app.can_move = &CanMove{
		left: app.can_move(.left)
		right: app.can_move(.right)
		up: app.can_move(.up)
		down: app.can_move(.down)
	}
}

fn (mut app App) print_board_matrix() {
	for i in 0 .. size {
		for j in 0 .. size {
			print(app.matrix[i][j])
			print('  ')
		}
		println('\n')
	}
}