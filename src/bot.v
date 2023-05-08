import time
import rand
import term

struct Prediction {
mut:
	move Direction
	move_score f64
}

struct AiLog {
	think_time i64
	move Direction
	move_score f64
}

const (
	directions = [Direction.up, .down, .left, .right]
	pred_per_move = 500
	pred_depth = 20
)

fn (mut game Game) ai_move() {
	mut preds := [4]Prediction{}
	think_watch := time.new_stopwatch()

	for dir in directions {
		if !game.can_move.query(dir) {
			continue
		}
		preds[int(dir)].move = dir
		mut all_score := 0
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
		preds[int(dir)].move_score = f64(all_score) / pred_per_move
	}
	think_time := think_watch.elapsed().milliseconds()

	mut max_score := -1.0
	mut best_move := Direction.up
	for move_idx in 0 .. directions.len {
		if max_score < preds[move_idx].move_score {
			max_score = preds[move_idx].move_score
			best_move = preds[move_idx].move
		}
	}
	ai_log := &AiLog{
		think_time: think_time,
		move: best_move,
		move_score: max_score,
	}
	game.ai_log(ai_log)
	game.step(best_move)
}

fn (mut game Game) ai_log(log AiLog) {
	// Not clear if show move log
	if !game.config.move_log {
		term.clear_previous_line()
	}
	print('Score: ${game.score} | ')
	print('Time: ${log.think_time}ms | ')
	print('Move: ${log.move} | ')
	println('Move Score: ${log.move_score}')
}
