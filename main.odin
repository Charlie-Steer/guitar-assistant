package main

import "core:fmt"
import "core:math"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

// int :: i32
Vec2 :: rl.Vector2

window_width : i32 = 800
window_height : i32 = 450


// Distance to bridge version.
// get_fret_wire_spacing :: proc(fret_number: f32, scale_length: f32) -> f32 {
//     return (scale_length * (1 - math.pow(2, (-fret_number)/12)))
// }

// Distance to fretboard end version.
get_fret_wire_spacing :: proc( fret_number: f32, fretboard_length: f32, total_frets: int) -> f32 {
	numerator   := 1.0 - math.pow(2.0, -fret_number / 12.0)
	denominator := 1.0 - math.pow(2.0, f32(-total_frets) / 12.0)
	return fretboard_length * (numerator / denominator)
}

Note :: enum {
	C,
	Cs,
	D,
	Ds,
	E,
	F,
	Fs,
	G,
	Gs,
	A,
	As,
	B,
}

Rectangle :: struct {
	x: Vec2,
	y: Vec2,
	w: Vec2,
	h: Vec2,
}

String_Fret :: struct {
	note: Note,
	box: Rectangle,
}

Scale :: struct {
	key: Note,
	steps: [dynamic]int,
}

Fretboard_Config :: struct {
	// Identity
	fret_count: int,
	string_count: int,

	tuning: [dynamic]Note,
	scale: Scale,

	// rendering.
	width: f32,
	length: f32,
}

Box :: struct {
	tl: Vec2, // top_left
	tr: Vec2, // top_right
	bl: Vec2, // bottom_left
	br: Vec2, // bottom_right
}

Fretboard :: struct {
	string_count: int,
	fret_count: int, // number of fret_wires + 1.
	tuning: [dynamic]Note,
	bounds: Box,
	string_frets: [dynamic]String_Fret, // number of (fret_wires + 1) * string_count.

	// Rendering:
	delimiter_spacing: f32,
	length: f32,
	width: f32,
	// fret_delimiter_count: int,
	// fret_wire_count: int,

	// fret_delimiter_spacing : f32 = 20.0,
	// num_strings := 6,
	// fretboard_length: f32 = 600,
	// fretboard_width: f32 = f32(num_strings) * fret_delimiter_spacing,
	// num_fret_delimiters := num_strings + 1,
	// num_frets := 24,
	// num_fret_wires := num_frets + 1,
}

// TODO: Get fretboard in first step. Draw fretboard in next.

// TODO: Calculate [dynamic]String_Fret.
create_fretboard :: proc(cfg: Fretboard_Config) -> ^Fretboard {
	f := new(Fretboard)

	f.string_count = cfg.string_count
	f.fret_count = cfg.fret_count
	f.tuning = cfg.tuning

	f.length = cfg.length
	f.width = cfg.width
	f.delimiter_spacing = f32(cfg.width) / f32(cfg.string_count)

	f.bounds.tl = Vec2{(f32(window_width) - cfg.length) / 2, 75}
	f.bounds.tr = f.bounds.tl + Vec2{cfg.length, 0}
	// f.bounds.bl = f.bounds.tl + Vec2{0, f32(cfg.string_count) * fret_delimiter_spacing}
	f.bounds.bl = f.bounds.tl + Vec2{0, cfg.width}
	f.bounds.br = f.bounds.bl + Vec2{cfg.length, 0}
	
	return f
}

draw_fretboard :: proc(f: ^Fretboard) {
	// frets := &fretboard.string_frets
	// fretboard.fret_count = num_strings * (num_frets + 1)

	// fretboard.bounds.tl = Vec2{(f32(window_width) - fretboard_length) / 2, 75}
	// fretboard.bounds.tr = fretboard.bounds.tl + Vec2{fretboard_length, 0}
	// fretboard.bounds.bl = fretboard.bounds.tl + Vec2{0, f32(num_strings) * fret_delimiter_spacing}
	// fretboard.bounds.br = fretboard.bounds.bl + Vec2{fretboard_length, 0}

	// corners := fretboard.box

	// Horizontal lines.
	point_a := f.bounds.tl;
	point_b := f.bounds.tr;
	// for i := 0; i < num_fret_delimiters; i += 1 {
	for i := 0; i < f.string_count + 1; i += 1 {
		rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
		point_a.y +=  f.delimiter_spacing;
		point_b.y += f.delimiter_spacing;
	}

	// String Identifier.
	point_a = f.bounds.tl + Vec2{-10, 10};
	for i := 0; i < f.string_count; i += 1 {
		string_number_buffer: [2]byte
		string_number_string := strconv.write_int(string_number_buffer[:], i64(i + 1), 10)
		rl.DrawText(strings.clone_to_cstring(string_number_string), i32(point_a.x - 20), i32(point_a.y - f.delimiter_spacing / 2), 20, rl.RAYWHITE)
		point_a.y += f.delimiter_spacing;
	}

	point_a = f.bounds.tl
	point_b = f.bounds.bl

	// for i := 1; i <= num_frets; i += 1 {
	//     rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
	//     point_a = fretboard_topleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length), 0}
	//     point_b = fretboard_botleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length), 0}
	//     if (i == 3 || i == 5 || i == 7 || i == 9 || i == 12 || i == 15 || i == 17 || i == 19 || i == 21 || i == 24) {
	//         // rl.DrawCircleV(vec2{get_fret_wire_spacing(f32(i) + 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 5, rl.RAYWHITE)
	//         rl.DrawCircleV(vec2{fretboard_topleft.x + get_fret_wire_spacing(f32(i) - 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 4, rl.RAYWHITE)
	//     }
	// }

	for i := 1; i <= f.fret_count + 1; i += 1 {
		rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
		point_a = f.bounds.tl + Vec2{get_fret_wire_spacing(f32(i), f.length, f.fret_count), 0}
		point_b = f.bounds.bl + Vec2{get_fret_wire_spacing(f32(i), f.length, f.fret_count), 0}
		if (i == 3 || i == 5 || i == 7 || i == 9|| i == 15 || i == 17 || i == 19 || i == 21) {
			// rl.DrawCircleV(vec2{get_fret_wire_spacing(f32(i) + 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 5, rl.RAYWHITE)
			rl.DrawCircleV(Vec2{f.bounds.tl.x + get_fret_wire_spacing(f32(i) - 0.5, f.length, f.fret_count), (f.bounds.tl.y + f.bounds.bl.y) / 2}, 4, rl.RAYWHITE)
		} else if (i == 12 || i == 24) {
			rl.DrawCircleV(Vec2{f.bounds.tl.x + get_fret_wire_spacing(f32(i) - 0.5, f.length, f.fret_count), (f.bounds.tl.y + f.bounds.bl.y - (f.width - f.delimiter_spacing)) / 2}, 4, rl.RAYWHITE)
			rl.DrawCircleV(Vec2{f.bounds.tl.x + get_fret_wire_spacing(f32(i) - 0.5, f.length, f.fret_count), (f.bounds.tl.y + f.bounds.bl.y + (f.width - f.delimiter_spacing)) / 2}, 4, rl.RAYWHITE)
		}
	}
}

// Change to numerical interval sequence step system.
// minor_scale := [7]i32{0, 2, 3, 5, 7, 8, 10}
minor_scale_intervals := [7]i32{2, 1, 2, 2, 1, 2, 2}

/*
draw_scale :: proc() {
	for string_idx := 0; string_idx <= num_strings; string_idx += 1 {
		for fret_idx := 0; fret_idx <= num_frets; fret_idx += 1 {
			// save per-fret position data in a struct in the draw_fretboard step so it's simpler at this point?
		}
	}

}
	*/

// TODO: Explore the memory management strategy to use.

// @(require_results)
// make_and_init :: proc($T: typeid/[dynamic]$E, elements: ..$E, allocator := context.allocator, loc := #caller_location) -> (array: T, err: runtimeAllocator_Error) #optional_allocator_error {
// 	err = make_dynamic_array((^Raw_Dynamic_Array)(&array), allocator, loc)
// 	append_elems(arr, loc=loc, ..E)
// 	return array, err
// }

// NOTE: Might it be a good way to quiz to ask for random frets whether they are on the scale or not?
main :: proc() {
	fmt.println("wassup")
	rl.InitWindow(window_width, window_height, "My Program")

	rl.SetTargetFPS(60)

	// Fretboard Config:
	e_standard_tuning := make([dynamic]Note)
	append_elems(&e_standard_tuning, ..[]Note{.E, .A, .D, .G, .B, .E})

	minor_scale_step_sequence := make([dynamic]int)
	append_elems(&minor_scale_step_sequence, ..[]int{2, 1, 2, 2, 1, 2, 2})
	e_minor_scale := Scale {
		key = .E,
		steps = minor_scale_step_sequence,
	}

	fretboard_config := Fretboard_Config {
		fret_count = 24,
		string_count = 6,
		tuning = e_standard_tuning,
		scale = e_minor_scale,

		length = 600,
		width = 120,
	}

	fretboard := create_fretboard(fretboard_config)

	for (!rl.WindowShouldClose()) {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)
		// rl.DrawText("hello world", screen_width / 2, screen_height / 2, 20, rl.RAYWHITE)
		draw_fretboard(fretboard)
		rl.EndDrawing()
	}

	rl.CloseWindow()
}