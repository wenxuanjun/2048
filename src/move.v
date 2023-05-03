module main

[inline]
fn (mut app App) move(dir Direction) {
	match dir {
		.left {
			app.move_left()
		}
		.right {
			app.move_right()
		}
		.up {
			app.move_up()
		}
		.down {
			app.move_down()
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

fn (mut app App) move_left() {
    for i := 0; i < size; i++ {
        mut temp_arr := []int{cap: size}
        for j := 0; j < size; j++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            app.matrix[i][j] = temp_arr[j] or { 0 }
        }
        for j := 0; j < size - 1; j++ {
            if app.matrix[i][j] != 0 {
                if app.matrix[i][j] == app.matrix[i][j + 1] {
                    app.matrix[i][j] *= 2
                    app.matrix[i][j + 1] = 0
                    app.score += app.matrix[i][j]
                    j++
                }
            }
        }
        temp_arr.clear()
        for j := 0; j < size; j++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            app.matrix[i][j] = temp_arr[j] or { 0 }
        }   
    }
}

fn (mut app App) move_right() {
    for i := 0; i < size; i++ {
        mut temp_arr := []int{cap: size}
        for j := 0; j < size; j++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            app.matrix[i][size - j - 1] = temp_arr[j] or { 0 }
        }
        for j := size - 1; j > 0; j-- {
            if app.matrix[i][j] != 0 {
                if app.matrix[i][j] == app.matrix[i][j - 1] {
                    app.matrix[i][j] *= 2
                    app.matrix[i][j - 1] = 0
                    app.score += app.matrix[i][j]
                    j--
                }
            }
        }
        temp_arr.clear()
        for j := 0; j < size; j++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for j := 0; j < size; j++ {
            app.matrix[i][size - j - 1] = temp_arr[j] or { 0 }
        }
    }
}

fn (mut app App) move_up() {
    for j := 0; j < size; j++ {
        mut temp_arr := []int{cap: size}
        for i := 0; i < size; i++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for i := 0; i < size; i++ {
            app.matrix[i][j] = temp_arr[i] or { 0 }
        }
        for i := 0; i < size - 1; i++ {
            if app.matrix[i][j] != 0 {
                if app.matrix[i][j] == app.matrix[i + 1][j] {
                    app.matrix[i][j] *= 2
                    app.matrix[i + 1][j] = 0
                    app.score += app.matrix[i][j]
                    i++
                }
            }
        }
        temp_arr.clear()
        for i := 0; i < size; i++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for i := 0; i < size; i++ {
            app.matrix[i][j] = temp_arr[i] or { 0 }
        }
    }
}

fn (mut app App) move_down() {
    for j := 0; j < size; j++ {
        mut temp_arr := []int{cap: size}
        for i := 0; i < size; i++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for i := 0; i < size; i++ {
            app.matrix[size - i - 1][j] = temp_arr[i] or { 0 }
        }
        for i := size - 1; i > 0; i-- {
            if app.matrix[i][j] != 0 {
                if app.matrix[i][j] == app.matrix[i - 1][j] {
                    app.matrix[i][j] *= 2
                    app.matrix[i - 1][j] = 0
                    app.score += app.matrix[i][j]
                    i--
                }
            }
        }
        temp_arr.clear()
        for i := 0; i < size; i++ {
            if app.matrix[i][j] != 0 {
                temp_arr << app.matrix[i][j]
            }
        }
        for i := 0; i < size; i++ {
            app.matrix[size - i - 1][j] = temp_arr[i] or { 0 }
        }
    }
}