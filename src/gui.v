module main

import gg
import gx
import math

const (
	theme = &Theme{
		tile_colors: [
            gx.rgb(205, 193, 180),
			gx.rgb(238, 228, 218),
			gx.rgb(237, 224, 200),
			gx.rgb(242, 177, 121),
			gx.rgb(245, 149, 99),
			gx.rgb(246, 124, 95),
			gx.rgb(246, 94, 59),
			gx.rgb(237, 207, 114),
			gx.rgb(237, 204, 97),
			gx.rgb(237, 200, 80),
			gx.rgb(237, 197, 63),
			gx.rgb(237, 194, 46),
			gx.rgb(60, 58, 50)
		]
        bakground_color: gx.rgb(250, 248, 239)
		container_color: gx.rgb(187, 173, 160)
		text_color: fn (tile_value int) gx.Color {
            if tile_value < 8 {
                return gx.rgb(119, 110, 101)
            } else {
                return gx.rgb(249, 246, 242)
            }
        }
    }
    default_width = 465
    default_height = 500
    window_title = "2048"
)

struct Theme {
	bakground_color gx.Color
	container_color gx.Color
	text_color fn (int) gx.Color
	tile_colors []gx.Color
}

struct Gui {
mut:
	game &Game
    gg &gg.Context
    window Window
}

struct Window {
mut:
	width int
	height int
	tile_size int
	border_size int
	padding_size int
	header_size int
	font_size int
	x_offset int
	y_offset int
}

fn gui_init(game &Game) &Gui {
	mut gui := &Gui{
		gg: 0
		game: unsafe { game }
	}
	gui.gg = gg.new_context(
		width: default_width
        height: default_height
        window_title: window_title
        bg_color: theme.bakground_color
        event_fn: on_event
        frame_fn: on_frame
        user_data: gui
        init_fn: fn (mut gui Gui) {
            gui.on_resize()
        }
	)
	return gui
}

fn on_event(e &gg.Event, mut gui Gui) {
    match e.typ {
        .key_down {
			if enable_ai {
				return
			}
			dir := get_dir(e.key_code)
            gui.game.step(dir or { return })
        }
        .resized, .restored, .resumed {
            gui.on_resize()
        }
        else {}
    }
}

fn on_frame(mut gui Gui) {
	gui.gg.begin()
    gui.draw_tiles()
	if enable_ai {
		gui.game.ai_move()
	}
	gui.gg.end()
}

fn (mut gui Gui) on_resize() {
	// Get the window size
	window_size := gui.gg.window_size()
	width := window_size.width

    // Left a little space for score
    left_ratio := f32(default_width) / f32(default_height)
	height := int(f32(window_size.height) * left_ratio)

    // Choose the smaller one as the container size
	min := f32(math.min(width, height))

	// Padding is the width between tiles
	padding_size, border_size := int(min / 40), int(min / 32)

	// Use these params to calc tile size
    gui.window = &Window{
        width: width
        height: height
        padding_size: padding_size
        border_size: border_size
        tile_size: int((min - border_size * 2 - padding_size * (size + 1)) / size)
        font_size: int(min / 8)
    }

    // Pre-calculate padding
    gui.window.y_offset = window_size.height - height

    // Center when width not equal to height
    if width > height {
        gui.window.x_offset += (width - height) / 2
    } else {
        gui.window.y_offset += (height - width) / 2
    }
}

fn (gui Gui) draw_tiles() {
    // Calculate the real position of the container
	x_start := gui.window.x_offset + gui.window.border_size
	y_start := gui.window.y_offset + gui.window.border_size

    // The length a tile takes and the size of the container
	tile_offset := gui.window.tile_size + gui.window.padding_size
	cont_size := math.min(gui.window.width, gui.window.height) - gui.window.border_size * 2
    cont_radius, cont_color := cont_size / 48, theme.container_color
	gui.gg.draw_rounded_rect_filled(x_start, y_start, cont_size, cont_size, cont_radius, cont_color)

	for y in 0..size {
		for x in 0..size {
			tile_value := gui.game.matrix[y][x]
            index := if tile_value == 0 { 0 } else { int(math.log2(tile_value)) }
			tile_color := if index < theme.tile_colors.len {
				theme.tile_colors[index]
			} else {
				theme.tile_colors.last()
			}
            tile_size := gui.window.tile_size
			x_tile := x_start + gui.window.padding_size + x * tile_offset
			y_tile := y_start + gui.window.padding_size + y * tile_offset
			gui.gg.draw_rounded_rect_filled(x_tile, y_tile, tile_size, tile_size, tile_size / 16, tile_color)

            // Draw the number of the tile
			if tile_value != 0 {
				x_font := x_tile + tile_size / 2
				y_font := y_tile + tile_size / 2
				tile_log := 5 - int(math.log10(tile_value))
				format := &gx.TextCfg{
			    	color: theme.text_color(tile_value)
			    	align: .center
			    	vertical_align: .middle
			    	size: gui.window.font_size * tile_log / (tile_log + 1)
			    }
				gui.gg.draw_text(x_font, y_font, '${tile_value}', format)
			}
		}
	}

    // Draw the score of the game
    score_format := &gx.TextCfg{
		color: gx.black
		align: .left
		vertical_align: .middle
		size: gui.window.font_size * 2 / 5
	}
    y_lable := y_start / 2
    gui.gg.draw_text(x_start, y_lable, 'Scores: ${gui.game.score}', score_format)

	// Draw the moves of the game
	move_format := &gx.TextCfg{
		color: gx.black
		align: .right
		vertical_align: .middle
		size: gui.window.font_size * 2 / 5
	}
	x_lable := gui.window.width - x_start
	gui.gg.draw_text(x_lable, y_lable, 'Moves: ${gui.game.moves}', move_format)
}