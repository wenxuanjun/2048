import time
import rand
import term

struct Prediction {
mut:
	move Direction
	move_score f64
}

struct AiPerform {
	prediction Prediction
	think_time i64
}

const (
	directions = [Direction.up, .down, .left, .right]
	pred_per_move = 500
	pred_depth = 20
)

fn (mut game Game) ai_move() {
	mut predictions := [4]Prediction{}
	think_watch := time.new_stopwatch()
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
			temp_game.refresh_move_status()
			if !temp_game.can_move.exist() {
				continue
			}
			temp_game.generate_number()
			all_score += temp_game.score
			mut move_depth := 0
			for temp_game.can_move.exist() {
				index := rand.u8() % directions.len
				rand_dir := directions[index]
				if !temp_game.can_move.query(rand_dir) {
					continue
				}
				temp_game.move(rand_dir)
				temp_game.refresh_move_status()
				temp_game.generate_number()
				move_depth++
				if move_depth > pred_depth {
					break
				}
			}
			all_score += temp_game.score
		}
		predictions[int(dir)].move_score = f64(all_score) / pred_per_move
	}
	mut best_pred := predictions[0]
	for prediction in predictions {
		if best_pred.move_score < prediction.move_score {
			best_pred = prediction
		}
	}
	ai_perform := &AiPerform{
		prediction: &best_pred,
		think_time: think_watch.elapsed().milliseconds(),
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
