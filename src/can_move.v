module main

struct CanMove {
    up bool
    down bool
    left bool
    right bool
}

@[inline]
fn (move CanMove) exist() bool {
    return move.left || move.right || move.up || move.down
}

@[inline]
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

fn (game Game) can_move_left() bool {
    for i := 0; i < size; i++ {
        for j := 1; j < size; j++ {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j - 1] == 0 || game.matrix[i][j] == game.matrix[i][j - 1] {
                    return true
                }
            }
        }
    }
    return false
}

fn (game Game) can_move_right() bool {
    for i := 0; i < size; i++ {
        for j := size - 2; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                if game.matrix[i][j + 1] == 0 || game.matrix[i][j] == game.matrix[i][j + 1] {
                    return true
                }
            }
        }
    }
    return false
}

fn (game Game) can_move_up() bool {
    for j := 0; j < size; j++ {
        for i := 1; i < size; i++ {
            if game.matrix[i][j] != 0 {
                if game.matrix[i - 1][j] == 0 || game.matrix[i][j] == game.matrix[i - 1][j] {
                    return true
                }
            }
        }
    }
    return false
}

fn (game Game) can_move_down() bool {
    for j := 0; j < size; j++ {
        for i := size - 2; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                if game.matrix[i + 1][j] == 0 || game.matrix[i][j] == game.matrix[i + 1][j] {
                    return true
                }
            }
        }
    }
    return false
}
