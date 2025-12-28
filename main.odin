package main

import "core:fmt"
import "core:math"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"

// int :: i32
vec2 :: rl.Vector2

window_width : i32 = 800
window_height : i32 = 450

fret_delimiter_spacing : f32 = 20.0;
fretboard_length: f32 = 600
num_strings := 6
fretboard_width: f32 = f32(num_strings) * fret_delimiter_spacing
num_fret_delimiters := num_strings + 1;
num_frets := 24
num_fret_wires := num_frets + 1;

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


draw_fretboard :: proc() {
    fretboard_topleft := vec2{(f32(window_width) - fretboard_length) / 2, 75}
    fretboard_topright := fretboard_topleft + vec2{fretboard_length, 0}
    fretboard_botleft := fretboard_topleft + vec2{0, f32(num_strings) * fret_delimiter_spacing}
    fretboard_botright := fretboard_botleft + vec2{fretboard_length, 0}

    point_a := fretboard_topleft;
    point_b := fretboard_topright;

    for i := 0; i < num_fret_delimiters; i += 1 {

        rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
        point_a.y += fret_delimiter_spacing;
        point_b.y += fret_delimiter_spacing;
    }

    point_a = fretboard_topleft + vec2{-10, 10};

    for i := 0; i < num_strings; i += 1 {
        string_number_buffer: [2]byte
        string_number_string := strconv.write_int(string_number_buffer[:], i64(i + 1), 10)
        rl.DrawText(strings.clone_to_cstring(string_number_string), i32(point_a.x - 20), i32(point_a.y - fret_delimiter_spacing / 2), 20, rl.RAYWHITE)
        point_a.y += fret_delimiter_spacing;
    }

    point_a = fretboard_topleft
    point_b = fretboard_botleft

    // for i := 1; i <= num_frets; i += 1 {
    //     rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
    //     point_a = fretboard_topleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length), 0}
    //     point_b = fretboard_botleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length), 0}
    //     if (i == 3 || i == 5 || i == 7 || i == 9 || i == 12 || i == 15 || i == 17 || i == 19 || i == 21 || i == 24) {
    //         // rl.DrawCircleV(vec2{get_fret_wire_spacing(f32(i) + 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 5, rl.RAYWHITE)
    //         rl.DrawCircleV(vec2{fretboard_topleft.x + get_fret_wire_spacing(f32(i) - 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 4, rl.RAYWHITE)
    //     }
    // }

    for i := 1; i <= num_fret_wires; i += 1 {
        rl.DrawLineV(point_a, point_b, rl.RAYWHITE)
        point_a = fretboard_topleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length, num_frets), 0}
        point_b = fretboard_botleft + vec2{get_fret_wire_spacing(f32(i), fretboard_length, num_frets), 0}
        if (i == 3 || i == 5 || i == 7 || i == 9|| i == 15 || i == 17 || i == 19 || i == 21) {
            // rl.DrawCircleV(vec2{get_fret_wire_spacing(f32(i) + 0.5, fretboard_length), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 5, rl.RAYWHITE)
            rl.DrawCircleV(vec2{fretboard_topleft.x + get_fret_wire_spacing(f32(i) - 0.5, fretboard_length, num_frets), (fretboard_topleft.y + fretboard_botleft.y) / 2}, 4, rl.RAYWHITE)
        } else if (i == 12 || i == 24) {
            rl.DrawCircleV(vec2{fretboard_topleft.x + get_fret_wire_spacing(f32(i) - 0.5, fretboard_length, num_frets), (fretboard_topleft.y + fretboard_botleft.y - (fretboard_width - fret_delimiter_spacing)) / 2}, 4, rl.RAYWHITE)
            rl.DrawCircleV(vec2{fretboard_topleft.x + get_fret_wire_spacing(f32(i) - 0.5, fretboard_length, num_frets), (fretboard_topleft.y + fretboard_botleft.y + (fretboard_width - fret_delimiter_spacing)) / 2}, 4, rl.RAYWHITE)
        }
    }
}

minor_scale := [7]i32{0, 2, 3, 5, 7, 8, 10}

draw_scale :: proc() {
    for string_idx := 0; string_idx <= num_strings; string_idx += 1 {
        for fret_idx := 0; fret_idx <= num_frets; fret_idx += 1 {
            // save per-fret position data in a struct in the draw_fretboard step so it's simpler at this point?
        }
    }

}

// NOTE: Might it be a good way to quiz to ask for random frets whether they are on the scale or not?
main :: proc() {
    fmt.println("wassup")
    rl.InitWindow(window_width, window_height, "My Program")

    rl.SetTargetFPS(60)

    for (!rl.WindowShouldClose()) {
        rl.BeginDrawing()
        rl.ClearBackground(rl.BLUE)
        // rl.DrawText("hello world", screen_width / 2, screen_height / 2, 20, rl.RAYWHITE)
        draw_fretboard()
        rl.EndDrawing()
    }

    rl.CloseWindow()
}