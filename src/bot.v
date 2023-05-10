import time
import term

const (
	directions = [Direction.up, .down, .left, .right]
	dfs_pred_per_move = 500
	dfs_pred_depth = 25
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
	abpruning
	mdp
	reinforcement
}

fn algo_from_str(str string) AiAlgo {
	return match str {
		"dfs" { AiAlgo.dfs }
		"abpruning" { AiAlgo.abpruning }
		"mdp" { AiAlgo.mdp }
		"reinforcement" { AiAlgo.reinforcement }
		else { eprintln("Invalid AI algorithm!") exit(1) }
	}
}

fn (mut game Game) ai_move() {
	think_watch := time.new_stopwatch()
	prediction := match game.config.ai_algo {
		.dfs { game.ai_dfs() }
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
