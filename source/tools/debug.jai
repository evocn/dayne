
// Debug
////////////////////////////////////////////////////////////////////////////////

Debug_Messages :: struct {
    Message :: struct {
        text: string;
        color := white;
    }

    messages : [..] Message;
}
debug_messages : Debug_Messages;

update :: (using debug: *Debug_Messages) {
    array_reset(*messages);
}

draw :: (using debug: Debug_Messages) {
    use_text_shader();

    k := 0;
    inc := 8;
    for message : messages {
        draw_text(
            message.text,
            1,
            PIXEL_HEIGHT - inc - (k * inc),
            font = .MAIN,
            color = message.color,
        );

        k += 1;
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
