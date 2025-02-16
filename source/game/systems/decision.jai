// Dayne
// Decision
// February 2025

Decision :: struct {
    question : string;

    Choice :: struct {
        text: string;
        consequence : (*Game);
    }
    choices : [..] Choice;
    selected: int;

    locked_in : bool;
}

apply_inputs :: (using decision: *Decision, input: Input) {
    if input.left.just_pressed {
        play_sfx("click");
        selected -= 1;
        selected = clamp(selected, 0, choices.count-1);
    }

    if input.right.just_pressed {
        play_sfx("click");
        selected += 1;
        selected = clamp(selected, 0, choices.count-1);
    }

    if input.a.just_pressed {
        locked_in = true;
    }
}

draw :: (using decision: Decision) {
    use_text_shader();

    draw_text(
        question,
        x = PIXEL_WIDTH / 2,
        y = PIXEL_HEIGHT - 30,
        alignment   = Alignment.CENTER,
        progress    = -1,
        font        = .MAIN,
        color       = white,
    );

    for choice : choices {
        color := gray;
        if selected == it_index then color = white;

        x := cast(int)(PIXEL_WIDTH * (0.5 + it_index) / choices.count);
        y := 80 + choice.text.count;
        draw_text(
            choice.text,
            x = x,
            y = y,
            alignment   = Alignment.CENTER,
            progress    = -1,
            font        = .MAIN,
            color       = color,
        );
    }
}
