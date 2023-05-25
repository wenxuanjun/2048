module main

import time
import term
import math

const (
	dfs_depth = 7
	pred_per_move = 500
	pred_depth = 35
	minmax_depth = 10
	learning_rate = 0.1
	discount_factor = 0.99
	exploration_rate = 0.1
	n_episodes = 3000
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
	minmax
	expectimax
	monte
	reinforcement
}

fn algo_from_str(str string) AiAlgo {
	return match str {
		"dfs" { AiAlgo.dfs }
		"heuristic" { AiAlgo.heuristic }
		"minmax" { AiAlgo.minmax }
		"expectimax" { AiAlgo.expectimax }
		"monte" { AiAlgo.monte }
		"reinforcement" { AiAlgo.reinforcement }
		else { eprintln("Invalid AI algorithm!") exit(1) }
	}
}

fn (mut game Game) ai_move() {
	think_watch := time.new_stopwatch()
	prediction := match ai_algo {
		.dfs { game.ai_dfs() }
		.heuristic { game.ai_heuristic() }
		.minmax { game.ai_minmax() }
		.expectimax { game.ai_expectimax() }
		.monte { game.ai_monte() }
		.reinforcement { game.ai_reinforcement() }
	}
	think_time := think_watch.elapsed()
	ai_perform := &AiPerform{
		prediction: prediction,
		think_time: think_time.milliseconds(),
	}
	game.ai_perform(ai_perform)
}

fn (mut game Game) ai_perform(perform AiPerform) {
	if !move_log && game.moves != 0 {
		term.clear_previous_line()
	}
	print('Score: ${game.score} | ')
	print('Moves: ${game.moves} | ')
	print('Time: ${perform.think_time}ms | ')
	print('Move: ${perform.prediction.move} | ')
	println('Move Score: ${perform.prediction.move_score}')
	game.step(perform.prediction.move)
}

fn (game Game) ai_dfs() Prediction {
    mut best_prediction := Prediction{
		move: .up,
		move_score: -1.0
	}
    for dir in directions {
        if game.can_move.query(dir) {
            mut temp_game := game.clone()
            temp_game.move(dir)
            temp_game.generate_number()
            temp_game.refresh_move_status()
            score := dfs_perform(temp_game, 0)
            if score > best_prediction.move_score {
                best_prediction.move = dir
                best_prediction.move_score = score
            }
        }
    }
    return best_prediction
}

fn dfs_perform(game &Game, depth int) int {
    if depth == dfs_depth || !game.can_move.exist() {
        return game.score
    }
    mut max_score := 0
    for dir in directions {
        if game.can_move.query(dir) {
            mut temp_game := game.clone()
            temp_game.move(dir)
            temp_game.generate_number()
            temp_game.refresh_move_status()
            score := dfs_perform(temp_game, depth + 1)
            if score > max_score {
                max_score = score
            }
        }
    }
    return max_score
}

fn (game Game) ai_heuristic() Prediction {
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
		smallest_num[int(dir)] = temp_game.count_empty_num()
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

fn (grid ExpectGrid) clone() &ExpectGrid {
    mut new_grid := &ExpectGrid{
        game: grid.game.clone()
        active: grid.active
    }
    return new_grid
}

fn (game Game) ai_expectimax() Prediction {
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

fn (grid ExpectGrid) expect_search(depth int) f64 {
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

fn (grid ExpectGrid) evaluate_score() f64 {
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

fn (game Game) ai_minmax() Prediction {
	mut best_pred := Prediction{
		move: Direction.up
		move_score: f64(-1e10)
	}
	for dir in directions {
		if game.can_move.query(dir) {
			mut temp_game := game.clone()
			temp_game.move(dir)
			temp_game.refresh_move_status()
			score := ab_find_max(
				temp_game,
				minmax_depth,
				math.min_i32,
				math.max_i32
			)
			if score > best_pred.move_score {
				best_pred.move = dir
				best_pred.move_score = score
			}
		}
	}

	return best_pred
}

fn ab_find_max(game &Game, depth int, alpha int, beta int) int {
	if depth == 0 || !game.can_move.exist() {
		return game.score
	}

	mut max_score := math.min_i32
	mut temp_alpha := alpha

	for dir in directions {
		if !game.can_move.query(dir) {
			continue
		}
		mut temp_game := game.clone()
		temp_game.move(dir)
		temp_game.refresh_move_status()

		score := ab_find_min(temp_game, depth - 1, temp_alpha, beta)
		max_score = if max_score > score { max_score } else { score }

		if beta <= temp_alpha {
			break
		}
		if temp_alpha < max_score {
			temp_alpha = max_score
		}
	}

	return max_score
}

fn ab_find_min(game &Game, depth int, alpha int, beta int) int {
	if depth == 0 || !game.can_move.exist() {
		return game.score
	}

	mut min_score := math.max_i32
	mut temp_beta := beta

	for dir in directions {
		if !game.can_move.query(dir) {
			continue
		}
		mut temp_game := game.clone()
		temp_game.move(dir)
		temp_game.generate_number()
		temp_game.refresh_move_status()

		score := ab_find_max(temp_game, depth - 1, alpha, temp_beta)
		min_score = if min_score < score { min_score } else { score }

		if temp_beta <= alpha {
			break
		}
		if temp_beta > min_score {
			temp_beta = min_score
		}
	}

	return min_score
}

fn (mut game Game) ai_monte() Prediction {
	mut predictions := [4]Prediction{}
	for dir in directions {
		if !game.can_move.query(dir) {
			continue
		}
		mut all_score := 0
		predictions[int(dir)].move = dir
		for _ in 0 .. pred_per_move {
			if !game.can_move.query(dir) {
				continue
			}
			mut temp_game := game.clone()
			temp_game.move(dir)
			temp_game.generate_number()
			temp_game.refresh_move_status()
			if !temp_game.can_move.exist() {
				continue
			}
			all_score += temp_game.score
			mut move_depth := 0
			for temp_game.can_move.exist() {
				index := rng.u8() % directions.len
				rand_dir := directions[index]
				if !temp_game.can_move.query(rand_dir) {
					continue
				}
				temp_game.move(rand_dir)
				temp_game.generate_number()
				temp_game.refresh_move_status()
				move_depth++
				if move_depth > pred_depth {
					break
				}
			}
			all_score += temp_game.score
		}
		predictions[int(dir)].move_score = f64(all_score) / pred_per_move
	}
	mut prediction := predictions[0]
	for pred in predictions {
		if prediction.move_score < pred.move_score {
			prediction = pred
		}
	}
	return prediction
}

fn (mut game Game) ai_reinforcement() Prediction {
	prediction := Prediction{
		move: game.ai_qlearning()
		move_score: 0.0
	}
	return prediction
}

pub struct QTable {
mut:
    data map[string]map[Direction]f64
}

fn (qt QTable) get(state string, action Direction) f64 {
    if action_values := qt.data[state] {
        if q_value := action_values[action] {
            return q_value
        }
    }
    return 0.0
}

fn (mut qt QTable) update(state string, action Direction, new_value f64) {
    if mut action_values := qt.data[state] {
        action_values[action] = new_value
    } else {
		mut temp_map := map[Direction]f64{}
		temp_map[action] = new_value
        qt.data[state] = temp_map.clone()
    }
}

fn (qt QTable) choose_action(state string, valid_actions []Direction) Direction {
    mut best_action := valid_actions[0]
    mut max_q_value := qt.get(state, best_action)

    for action in valid_actions {
        q_value := qt.get(state, action)
        if q_value > max_q_value {
            max_q_value = q_value
            best_action = action
        }
    }

    return best_action
}

fn (mut game Game) ai_qlearning() Direction {
    state := game.get_state_string()
    valid_actions := game.get_valid_actions()

    if rng.f64() < exploration_rate {
        return valid_actions[rng.intn(valid_actions.len) or { 0 }]
    }

	return q_table.choose_action(state, valid_actions)
}

fn (game Game) train_qlearning() {
    for _ in 0 .. n_episodes {
        mut current_game := game.clone()

        for current_game.can_move.exist() {
            current_state := current_game.get_state_string()
            action := current_game.ai_qlearning()
            prev_score := current_game.score

            mut next_game := current_game.clone()
            next_game.move(action)
            next_game.generate_number()
            next_game.refresh_move_status()

            next_state := next_game.get_state_string()
            reward := next_game.score - prev_score

            q_value := q_table.get(current_state, action)
            mut target := f64(reward)

            if next_game.can_move.exist() {
                target += discount_factor * q_table.get(next_state, q_table.choose_action(next_state, next_game.get_valid_actions()))
            }

            q_table.update(current_state, action, q_value + learning_rate * (target - q_value))

            current_game = next_game
        }
    }

    println("Length of Q-table: ${q_table.data.len}")
}
