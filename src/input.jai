// Dayne
// Input
// Alex Hartford
// February 2024

Button :: struct {
    just_pressed : bool;
    is_down : bool;
}

press :: (button: *Button) {
    button.just_pressed = true;
    button.is_down = true;
}

release :: (button: *Button) {
    button.just_pressed = false;
    button.is_down = false;
}

update :: (button: *Button) {
    if button.just_pressed {
        button.just_pressed = false;
        button.is_down = true;
    }
}

post_frame_update :: (input: *Input) {
    update(*input.up);
    update(*input.left);
    update(*input.down);
    update(*input.right);
    update(*input.north);
    update(*input.south);
    update(*input.east);
    update(*input.west);
    update(*input.start);
    update(*input.select);

    update(*input.left_mouse);
    update(*input.right_mouse);
}


Input :: struct {
    up      : Button;
    left    : Button;
    down    : Button;
    right   : Button;

    north   : Button;
    south   : Button;
    east    : Button;
    west    : Button;

    start   : Button;
    select  : Button;

    mouse_position : Pair;
    left_mouse : Button;
    right_mouse: Button;
}

//
//

gather_input :: (input: *Input, gamepad: *SDL_Joystick) {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        ImGui_ImplSdl_ProcessEvent(*event);
        if event.type == {
            case SDL_QUIT;
                program_state.running = false;

            case SDL_KEYUP;
                if program_state.imgui_capturing_keyboard return;

                {
                         if event.key.keysym.sym == SDLK_w       release(*input.up);
                    else if event.key.keysym.sym == SDLK_a       release(*input.left);
                    else if event.key.keysym.sym == SDLK_s       release(*input.down);
                    else if event.key.keysym.sym == SDLK_d       release(*input.right);

                    else if event.key.keysym.sym == SDLK_h       release(*input.west);
                    else if event.key.keysym.sym == SDLK_j       release(*input.south);
                    else if event.key.keysym.sym == SDLK_k       release(*input.north);
                    else if event.key.keysym.sym == SDLK_l       release(*input.east);

                    else if event.key.keysym.sym == SDLK_SPACE   release(*input.start);
                    else if event.key.keysym.sym == SDLK_ESCAPE  release(*input.select);
                }

            case SDL_KEYDOWN;
                if program_state.imgui_capturing_keyboard return;

                // Main Program Inputs
                {
                    if event.key.repeat != 0 return;

                         if event.key.keysym.sym == SDLK_w       press(*input.up);
                    else if event.key.keysym.sym == SDLK_a       press(*input.left);
                    else if event.key.keysym.sym == SDLK_s       press(*input.down);
                    else if event.key.keysym.sym == SDLK_d       press(*input.right);

                    else if event.key.keysym.sym == SDLK_h       press(*input.west);
                    else if event.key.keysym.sym == SDLK_j       press(*input.south);
                    else if event.key.keysym.sym == SDLK_k       press(*input.north);
                    else if event.key.keysym.sym == SDLK_l       press(*input.east);

                    else if event.key.keysym.sym == SDLK_SPACE   press(*input.start);
                    else if event.key.keysym.sym == SDLK_ESCAPE  press(*input.select);
                }

                // Development keybinds
                {
                    if event.key.keysym.sym == SDLK_r {
                        if program_state.current_scene == {
                            case .GAME;
                                change_scene(.EDITOR);
                                mouse_editor_mode();

                            case .EDITOR;
                                change_scene(.GAME);
                                mouse_game_mode();

                                program_state.imgui_capturing_mouse = false;
                                program_state.imgui_capturing_keyboard = false;
                        }
                    }
                }

            case SDL_MOUSEBUTTONDOWN;
                if program_state.imgui_capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   press(*input.left_mouse);
                    if event.button.button == SDL_BUTTON_RIGHT  press(*input.right_mouse);
                }

            case SDL_MOUSEBUTTONUP;
                if program_state.imgui_capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   release(*input.left_mouse);
                    if event.button.button == SDL_BUTTON_RIGHT  release(*input.right_mouse);
                }

            case SDL_MOUSEMOTION;
                if program_state.imgui_capturing_mouse return;

                // Main Program Inputs
                {
                    input.mouse_position.x = cast(int)(event.motion.x * (cast(float)PIXEL_WIDTH  / render_context.window_width));
                    input.mouse_position.y = PIXEL_HEIGHT - cast(int)(event.motion.y * (cast(float)PIXEL_HEIGHT / render_context.window_height)) - 1;
                }


            JOYSTICK_DEAD_ZONE :: 8000;

            case SDL_JOYBUTTONDOWN;
                // 0, 1, 2, 3 : face buttons
                // 4, 5 : left bumper / right bumper
                // 6, 7 : select / start
                // 8, 9 : pressing in left stick / right stick

                if event.jbutton.button == 0 then press(*input.south);
                if event.jbutton.button == 1 then press(*input.east); 
                if event.jbutton.button == 2 then press(*input.west);
                if event.jbutton.button == 3 then press(*input.north);
                if event.jbutton.button == 6 then press(*input.start);
                if event.jbutton.button == 7 then press(*input.select);

            case SDL_JOYBUTTONUP;
                if event.jbutton.button == 0 then release(*input.south);
                if event.jbutton.button == 1 then release(*input.east); 
                if event.jbutton.button == 2 then release(*input.west);
                if event.jbutton.button == 3 then release(*input.north);
                if event.jbutton.button == 6 then release(*input.start);
                if event.jbutton.button == 7 then release(*input.select);

            case SDL_JOYHATMOTION;
                hat_state : u8;
                hat_state = event.jhat.value;

                if hat_state & 1 then press(*input.up);     else release(*input.up);   
                if hat_state & 2 then press(*input.right);  else release(*input.right);
                if hat_state & 4 then press(*input.down);   else release(*input.down); 
                if hat_state & 8 then press(*input.left);   else release(*input.left); 

            case SDL_JOYDEVICEADDED;
                gamepad = SDL_JoystickOpen(0);
                assert(gamepad != null);

            case SDL_JOYDEVICEREMOVED;
                log("Gamepad removed! ... Just figured you'd like to know <:");
                gamepad = null;

            case SDL_WINDOWEVENT;
                if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
                    render_context.window_width  = event.window.data1;
                    render_context.window_height = event.window.data2;

                    render_context.viewport_height = render_context.window_height;
                    render_context.viewport_width  = cast(s32)(render_context.viewport_height * GAME_ASPECT_RATIO);
                }
        }
    }
}
