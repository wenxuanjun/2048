import time
import term

const (
	directions = [Direction.up, .down, .left, .right]
	dfs_pred_per_move = 250
	dfs_pred_depth = 20
)

struct Prediction {
mut:
	move Direction
	move_score f64
}

struct AiPerform {
	prediction Prediction
	think_time i64
}

enum AiAlgo {
	dfs
	heuristic
	expectimax
	mdp
	reinforcement
}

fn algo_from_str(str string) AiAlgo {
	return match str {
		"dfs" { AiAlgo.dfs }
		"heuristic" { AiAlgo.heuristic }
		"mdp" { AiAlgo.mdp }
		"expectimax" { AiAlgo.expectimax }
		"reinforcement" { AiAlgo.reinforcement }
		else { eprintln("Invalid AI algorithm!") exit(1) }
	}
}

fn (mut game Game) ai_move() {
	think_watch := time.new_stopwatch()
	prediction := match game.config.ai_algo {
		.dfs { game.ai_dfs() }
		.heuristic { game.ai_heuristic() }
		.expectimax { game.ai_expectimax() }
		else { eprintln("This algo is not implemented yet!") exit(1) }
	}
	think_time := think_watch.elapsed()
	ai_perform := &AiPerform{
		prediction: prediction,
		think_time: think_time.milliseconds(),
	}
	game.ai_perform(ai_perform)
}

fn (mut game Game) ai_perform(perform AiPerform) {
	if !game.config.move_log && game.moves != 0 {
		term.clear_previous_line()
	}
	print('Score: ${game.score} | ')
	print('Moves: ${game.moves} | ')
	print('Time: ${perform.think_time}ms | ')
	print('Move: ${perform.prediction.move} | ')
	println('Move Score: ${perform.prediction.move_score}')
	game.step(perform.prediction.move)
}

fn (mut game Game) ai_dfs() Prediction {
	mut predictions := [4]Prediction{}
	for dir in directions {
		if !game.can_move.query(dir) {
			continue
		}
		mut all_score := 0
		predictions[int(dir)].move = dir
		for _ in 0 .. dfs_pred_per_move {
			if !game.can_move.query(dir) {
				continue
			}
			mut temp_game := game.clone()
			temp_game.move(dir)
			temp_game.refresh_move_status()
			if !temp_game.can_move.exist() {
				continue
			}
			temp_game.generate_number()
			all_score += temp_game.score
			mut move_depth := 0
			for temp_game.can_move.exist() {
				index := game.config.rng.u8() % directions.len
				rand_dir := directions[index]
				if !temp_game.can_move.query(rand_dir) {
					continue
				}
				temp_game.move(rand_dir)
				temp_game.refresh_move_status()
				temp_game.generate_number()
				move_depth++
				if move_depth > dfs_pred_depth {
					break
				}
			}
			all_score += temp_game.score
		}
		predictions[int(dir)].move_score = f64(all_score) / dfs_pred_per_move
	}
	mut prediction := predictions[0]
	for pred in predictions {
		if prediction.move_score < pred.move_score {
			prediction = pred
		}
	}
	return prediction
}

fn (mut game Game) ai_heuristic() Prediction {
	mut predictions := [4]Prediction{}
	mut smallest_num := [17, 17, 17, 17]
	for dir in directions {
		if !game.can_move.query(dir) {
			smallest_num[int(dir)] = 100
			continue
		}
		predictions[int(dir)].move = dir
		mut temp_game := game.clone()
		temp_game.move(dir)
		temp_game.refresh_move_status()
		smallest_num[int(dir)] = temp_game.count_num()
	}
	mut prediction := predictions[0]
	minimum := smallest_num[0]
	for i in 0 .. directions.len {
		if smallest_num[i] < minimum {
			prediction = predictions[i]
		}
	}
	return prediction
}

struct ExpectGrid {
mut:
    game Game
    active bool
}

fn (mut grid ExpectGrid) clone() &ExpectGrid {
    mut new_grid := &ExpectGrid{
        game: grid.game.clone()
        active: grid.active
    }
    return new_grid
}

fn (mut game Game) ai_expectimax() Prediction {
	if size != 4 {
		eprintln("Expectimax only supports 4x4 grid!")
		exit(1)
	}
    mut grid := ExpectGrid{
        game: &game
        active: false
    }
    mut best_score := f64(-1)
    mut best_move := Direction.up

    max_num := grid.game.get_max_number()
	depth := if max_num >= 2048 { 6 } else if max_num >= 1024 { 5 } else { 4 }

    for dir in directions {
        if !grid.game.can_move.query(dir) {
            continue
        }
        mut new_grid := grid.clone()
        new_grid.game.move(dir)
        new_grid.game.refresh_move_status()
        score := new_grid.expect_search(depth)
        if score > best_score {
            best_move = dir
        	best_score = score
        }
    }
    return Prediction{
        move: best_move
        move_score: best_score
    }
}

fn (mut grid ExpectGrid) expect_search(depth int) f64 {
    if depth == 0 {
        return grid.evaluate_score()
    }
    mut score := f64(0)
    if grid.active {
        for dir in directions {
            if !grid.game.can_move.query(dir) {
                continue
            }
            mut temp_grid := grid.clone()
            temp_grid.active = false
            temp_grid.game.move(dir)
            temp_grid.game.refresh_move_status()
            new_score := temp_grid.expect_search(depth - 1)
            if new_score > score {
                score = new_score
            }
        }
    } else {
		expect_map := {2: 0.9, 4: 0.1}
        cells := grid.game.find_empty_cells()
        for num, prob in expect_map {
            for index in cells {
                mut temp_grid := grid.clone()
                temp_grid.active = true
                temp_grid.game.put_number(index / size, index % size, num)
                new_score := temp_grid.expect_search(depth - 1)
                score += f64(new_score) * prob
            }
        }
        score /= f64(cells.len)
    }
    return score
}

fn (mut grid ExpectGrid) evaluate_score() f64 {
    mut result := [24]int{}
    for index, model in expect_models {
		for row := 0; row < size; row++ {
        	for col := 0; col < size; col++ {
        	    value := grid.game.matrix[row][col]
        	    if value != 0 {
    				start := index * 8
    				result[start] = value * model[row][col]
    				result[start + 1] += value * model[row][3 - col]
    				result[start + 2] += value * model[col][row]
    				result[start + 3] += value * model[3 - col][row]
    				result[start + 4] += value * model[3 - row][3 - col]
    				result[start + 5] += value * model[3 - row][col]
    				result[start + 6] += value * model[col][3 - row]
    				result[start + 7] += value * model[3 - col][3 - row]
        	    }
    		}
		}
	}
	mut max_number := 0
	for value in result {
		if value > max_number {
			max_number = value
		}
	}
    return f64(max_number)
}

/**
 * Weight matrix, see more details here:
 * Github: https://github.com/ovolve/2048-AI
 * Thought of the evaluation function from here either.
 */
const (
    expect_models = [
		[
    	    [16, 15, 14, 13],
    	    [9, 10, 11, 12],
    	    [8, 7, 6, 5],
    	    [1, 2, 3, 4],
		],
    	[
    	    [16, 15, 12, 4],
    	    [14, 13, 11, 3],
    	    [10, 9, 8, 2],
    	    [7, 6, 5, 1],
		],
    	[
    	    [16, 15, 14, 4],
    	    [13, 12, 11, 3],
    	    [10, 9, 8, 2],
    	    [7, 6, 5, 1],
    	]
	]
)