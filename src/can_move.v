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
        mut index := -1
        for j := size - 1; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                index = j
                break
            }
        }
        if index != -1 {
            for j := index; j > 0; j-- {
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
        mut index := -1
        for j := 0; j < size; j++ {
            if game.matrix[i][j] != 0 {
                index = j
                break
            }
        }
        if index != -1 {
            for j := index; j < size - 1; j++ {
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
        mut index := -1
        for i := size - 1; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                index = i
                break
            }
        }
        if index != -1 {
            for i := index; i > 0; i-- {
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
        mut index := -1
        for i := 0; i < size; i++ {
            if game.matrix[i][j] != 0 {
                index = i
                break
            }
        }
        if index != -1 {
            for i := index; i < size - 1; i++ {
                if game.matrix[i + 1][j] == 0 || game.matrix[i][j] == game.matrix[i + 1][j] {
                    return true
                }
            }
        }
    }
    return false
}
