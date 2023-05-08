module main

struct CanMove {
    up bool
    down bool
    left bool
    right bool
}

[inline]
fn (move CanMove) exist() bool {
    return move.left || move.right || move.up || move.down
}

[inline]
fn (move CanMove) query(dir Direction) bool {
    match dir {
        .left {
            return move.left
        }
        .right {
            return move.right
        }
        .up {
            return move.up
        }
        .down {
            return move.down
        }
    }
}

[inline]
fn empty_equal(game &Game, x int, y int, r int, c int) bool {
    current := game.matrix[x][y]
    next_tile := game.matrix[r][c]
	if current != 0 {
		if next_tile == 0 || current == next_tile {
			return true
		}
	}
	return false
}

fn (mut game Game) can_move_left() bool {
    for i := 0; i < size; i++ {
        for j := 1; j < size; j++ {
            if empty_equal(game, i, j, i, j - 1) {
                return true
            }
        }
    }
    return false
}

fn (mut game Game) can_move_right() bool {
    for i := 0; i < size; i++ {
        for j := size - 2; j >= 0; j-- {
            if empty_equal(game, i, j, i, j + 1) {
                return true
            }
        }
    }
    return false
}

fn (mut game Game) can_move_up() bool {
    for j := 0; j < size; j++ {
        for i := 1; i < size; i++ {
            if empty_equal(game, i, j, i - 1, j) {
                return true
            }
        }
    }
    return false
}

fn (mut game Game) can_move_down() bool {
    for j := 0; j < size; j++ {
        for i := size - 2; i >= 0; i-- {
            if empty_equal(game, i, j, i + 1, j) {
                return true
            }
        }
    }
    return false
}