import time
import rand

struct Prediction {
mut:
	move Direction
	move_score f64
}

const (
	directions = [Direction.up, .down, .left, .right]
	pred_per_move = 200
	pred_depth = 10
)

fn (mut game Game) ai_move() {
	mut preds := [4]Prediction{}
	think_watch := time.new_stopwatch()
	for dir in directions {
		preds[int(dir)].move = dir
		mut move_score := 0
		for _ in 0 .. pred_per_move {
			mut temp_game := game.clone()
			if temp_game.can_move.query(dir) {
				temp_game.move(dir)
			} else {
				continue
			}
			temp_game.refresh_move_status()
			if !temp_game.can_move.exist() {
				continue
			}
			move_score += temp_game.score
			temp_game.generate_number()
			mut move_depth := 0
			for temp_game.can_move.exist() {
				index := rand.intn(directions.len) or { 0 }
				rand_dir := directions[index]
				if temp_game.can_move.query(rand_dir) {
					temp_game.move(rand_dir)
				} else {
					continue
				}
				temp_game.refresh_move_status()
				temp_game.generate_number()
				move_depth++
				if move_depth > pred_depth {
					break
				}
			}
			move_score += temp_game.score
		}
		preds[int(dir)].move_score = f64(move_score) / pred_per_move
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
	println('Simulation time: ${think_time:4}ms | move: ${best_move} | score: ${max_score}')
	game.step(best_move)
}