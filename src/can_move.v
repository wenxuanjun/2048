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

[params]
struct CompareParam {
    row int
    col int
    row_next int
    col_next int
}

[inline]
fn (mut game Game) empty_or_equal(params CompareParam) bool {
    // 获取当前位置和下一个位置的值
    current := game.matrix[params.row][params.col]
    next_tile := game.matrix[params.row_next][params.col_next]
    // 当前不为空，下一个为空或当前与下一个相等，则可移动
	if current != 0 {
		if next_tile == 0 || current == next_tile {
			return true
		}
	}
	return false
}

fn (mut game Game) can_move(dir Direction) bool {
    if dir == .left || dir == .right {
        for i := 0; i < size; i++ {
            if dir == .left {
                for j := 1; j < size; j++ {
                    if game.empty_or_equal(i, j, i, j - 1) {
                        return true
                    }
                }
            } else {
                for j := size - 2; j >= 0; j-- {
                    if game.empty_or_equal(i, j, i, j + 1) {
                        return true
                    }
                }
            }
        }
    } else {
        for j := 0; j < size; j++ {
            if dir == .up {
                for i := 1; i < size; i++ {
                    if game.empty_or_equal(i, j, i - 1, j) {
                        return true
                    }
                }
            } else {
                for i := size - 2; i >= 0; i-- {
                    if game.empty_or_equal(i, j, i + 1, j) {
                        return true
                    }
                }
            }
        }
    }
    return false
}