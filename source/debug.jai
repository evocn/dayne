// Dayne
// Debug
// January 2025

Debugging_Stuff :: struct {
    Message :: struct {
        text: string;
        color := white;
    }

    messages : [..] Message;

    solids : [..] *Solid;
}
debugging_stuff : Debugging_Stuff;

debug_print :: (s : string, color := white) {
    array_add(*debugging_stuff.messages, .{s, color});
}

update :: (using debug: *Debugging_Stuff) {
    array_reset(*messages);
    array_reset(*solids);
}

draw :: (using debug: Debugging_Stuff) {
    k := 0;
    inc := 6;
    for message : messages {
        draw_text(
            message.text,
            1,
            PIXEL_HEIGHT - inc - (k * inc),
            font = .SMALL,
            color = message.color,
        );

        k += 1;
    }

    print("%\n", solids.count);
    for solid : solids {
        draw(solid.collider, white);
    }
}

////////////////////////////////////////////////////////////////////////////////

Fps_Tracker :: struct {
    samples : [100] float;
    index : int;
}

add_sample :: (using tracker : *Fps_Tracker, sample: float) {
    samples[index] = sample;

    index += 1;
    if index >= samples.count then index = 0;
}

get_average :: (using tracker : Fps_Tracker) -> float {
    average := 0.0;
    for sample : samples  average += sample;
    average /= samples.count;

    return average;
}
