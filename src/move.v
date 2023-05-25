module main

[inline]
fn (mut game Game) move(dir Direction) {
	match dir {
		.left {
			game.move_left()
		}
		.right {
			game.move_right()
		}
		.up {
			game.move_up()
		}
		.down {
			game.move_down()
		}
	}
}

fn (mut game Game) move_left() {
    for i := 0; i < size; i++ {
        mut pointer := 0
        for j := 0; j < size; j++ {
            if game.matrix[i][j] != 0 {
                game.matrix[i][pointer] = game.matrix[i][j]
                pointer++
            }
        }
        if pointer == 0 {
            continue
        }
        for j := pointer; j < size; j++ {
            game.matrix[i][j] = 0
        }
        for j := 0; j < size - 1; j++ {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j] == game.matrix[i][j + 1] {
                    game.matrix[i][j] <<= 1
                    game.matrix[i][j + 1] = 0
                    game.score += game.matrix[i][j]
                    j++
                }
            }
        }
        pointer = 0
        for j := 0; j < size; j++ {
            if game.matrix[i][j] != 0 {
                game.matrix[i][pointer] = game.matrix[i][j]
                pointer++
            }
        }
        if pointer == 0 {
            continue
        }
        for j := pointer; j < size; j++ {
            game.matrix[i][j] = 0
        } 
    }
}

fn (mut game Game) move_right() {
    for i := 0; i < size; i++ {
        mut pointer := size - 1
        for j := size - 1; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                game.matrix[i][pointer] = game.matrix[i][j]
                pointer--
            }
        }
        if pointer == size - 1 {
            continue
        }
        for j := pointer; j >= 0; j-- {
            game.matrix[i][j] = 0
        }
        for j := size - 1; j > 0; j-- {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j] == game.matrix[i][j - 1] {
                    game.matrix[i][j] <<= 1
                    game.matrix[i][j - 1] = 0
                    game.score += game.matrix[i][j]
                    j--
                }
            }
        }
        pointer = size - 1
        for j := size - 1; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                game.matrix[i][pointer] = game.matrix[i][j]
                pointer--
            }
        }
        if pointer == size - 1 {
            continue
        }
        for j := pointer; j >= 0; j-- {
            game.matrix[i][j] = 0
        }
    }
}

fn (mut game Game) move_up() {
    for j := 0; j < size; j++ {
        mut pointer := 0
        for i := 0; i < size; i++ {
            if game.matrix[i][j] != 0 {
                game.matrix[pointer][j] = game.matrix[i][j]
                pointer++
            }
        }
        if pointer == 0 {
            continue
        }
        for i := pointer; i < size; i++ {
            game.matrix[i][j] = 0
        }
        for i := 0; i < size - 1; i++ {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j] == game.matrix[i + 1][j] {
                    game.matrix[i][j] <<= 1
                    game.matrix[i + 1][j] = 0
                    game.score += game.matrix[i][j]
                    i++
                }
            }
        }
        pointer = 0
        for i := 0; i < size; i++ {
            if game.matrix[i][j] != 0 {
                game.matrix[pointer][j] = game.matrix[i][j]
                pointer++
            }
        }
        if pointer == 0 {
            continue
        }
        for i := pointer; i < size; i++ {
            game.matrix[i][j] = 0
        }
    }
}

fn (mut game Game) move_down() {
    for j := 0; j < size; j++ {
        mut pointer := size - 1
        for i := size - 1; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                game.matrix[pointer][j] = game.matrix[i][j]
                pointer--
            }
        }
        if pointer == size - 1 {
            continue
        }
        for i := pointer; i >= 0; i-- {
            game.matrix[i][j] = 0
        }
        for i := size - 1; i > 0; i-- {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j] == game.matrix[i - 1][j] {
                    game.matrix[i][j] <<= 1
                    game.matrix[i - 1][j] = 0
                    game.score += game.matrix[i][j]
                    i--
                }
            }
        }
        pointer = size - 1
        for i := size - 1; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                game.matrix[pointer][j] = game.matrix[i][j]
                pointer--
            }
        }
        if pointer == size - 1 {
            continue
        }
        for i := pointer; i >= 0; i-- {
            game.matrix[i][j] = 0
        }
    }
}