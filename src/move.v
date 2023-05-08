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

/* 
 * 1. 先把所有的数字靠边
 * 2. 对于当前行，先合并这一行所有可以合并的
 * 3. 合并成功，跳过刚刚被设置为零的数字，防止递归合并
 * 4. 清空临时数组
 * 5. 再次把所有的数字靠边
 */

// 这四个函数只是方向不同，但我不知道怎么合并成一个函数（恼）

fn (mut game Game) move_left() {
    for i := 0; i < size; i++ {
        mut temp_arr := []int{cap: size}
        for j := 0; j < size; j++ {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            game.matrix[i][j] = temp_arr[j] or { 0 }
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
        temp_arr.clear()
        for j := 0; j < size; j++ {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            game.matrix[i][j] = temp_arr[j] or { 0 }
        }   
    }
}

fn (mut game Game) move_right() {
    for i := 0; i < size; i++ {
        mut temp_arr := []int{cap: size}
        for j := size - 1; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        if temp_arr.len == 0 {
            continue
        }
        for j := size - 1; j >= 0; j-- {
            game.matrix[i][j] = temp_arr[size - j - 1] or { 0 }
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
        temp_arr.clear()
        for j := size - 1; j >= 0; j-- {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        for j := size - 1; j >= 0; j-- {
            game.matrix[i][j] = temp_arr[size - j - 1] or { 0 }
        }
    }
}

fn (mut game Game) move_up() {
    for j := 0; j < size; j++ {
        mut temp_arr := []int{cap: size}
        for i := 0; i < size; i++ {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        if temp_arr.len == 0 {
            continue
        }
        for i := 0; i < size; i++ {
            game.matrix[i][j] = temp_arr[i] or { 0 }
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
        temp_arr.clear()
        for i := 0; i < size; i++ {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        for i := 0; i < size; i++ {
            game.matrix[i][j] = temp_arr[i] or { 0 }
        }
    }
}

fn (mut game Game) move_down() {
    for j := 0; j < size; j++ {
        mut temp_arr := []int{cap: size}
        for i := size - 1; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        if temp_arr.len == 0 {
            continue
        }
        for i := size - 1; i >= 0; i-- {
            game.matrix[i][j] = temp_arr[size - i - 1] or { 0 }
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
        temp_arr.clear()
        for i := size - 1; i >= 0; i-- {
            if game.matrix[i][j] != 0 {
                temp_arr << game.matrix[i][j]
            }
        }
        for i := size - 1; i >= 0; i-- {
            game.matrix[i][j] = temp_arr[size - i - 1] or { 0 }
        }
    }
}