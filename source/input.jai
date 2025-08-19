
// Input
////////////////////////////////////////////////////////////////////////////////

Button :: struct {
    just_pressed : bool;
    is_held : bool;
}

press :: (button: *Button) {
    button.just_pressed = true;
    button.is_held = true;
}

release :: (button: *Button) {
    button.just_pressed = false;
    button.is_held = false;
}

update :: (button: *Button) {
    if button.just_pressed {
        button.just_pressed = false;
        button.is_held = true;
    }
}

////////////////////////////////////////////////////////////////////////////////

Input :: struct {
    using button_inputs : struct {
        up      : Button;
        left    : Button;
        down    : Button;
        right   : Button;

        a       : Button;
        b       : Button;

        start   : Button;
        select  : Button;
    }

    mouse : Mouse;
}

post_frame_update :: (input: *Input) {
    update(*input.up);
    update(*input.left);
    update(*input.down);
    update(*input.right);
    update(*input.a);
    update(*input.b);
    update(*input.start);
    update(*input.select);
}

Mouse :: struct {
    active  : bool = true;

    position: Pair;

    left    : Button;
    right   : Button;
    middle  : Button;
}

post_frame_update :: (mouse: *Mouse) {
    update(*mouse.left);
    update(*mouse.right);
    update(*mouse.middle);
}

////////////////////////////////////////////////////////////////////////////////

gather_input :: (input: *Input, gamepad: *SDL_Joystick) {
    event : SDL_Event;
    while SDL_PollEvent(*event) {
        #if DEVELOPER_TOOLS then ImGui_ImplSdl_ProcessEvent(*event);

        if event.type == {
            case SDL_QUIT;
                program_state.running = false;

            case SDL_KEYUP;
                #if DEVELOPER_TOOLS then if program_state.editor.active && program_state.editor.imgui_state.capturing_keyboard return;

                {
                    if event.key.keysym.sym == SDLK_w       release(*input.up);
                    if event.key.keysym.sym == SDLK_a       release(*input.left);
                    if event.key.keysym.sym == SDLK_s       release(*input.down);
                    if event.key.keysym.sym == SDLK_d       release(*input.right);

                    if event.key.keysym.sym == SDLK_j       release(*input.a);
                    if event.key.keysym.sym == SDLK_k       release(*input.b);

                    if event.key.keysym.sym == SDLK_ESCAPE  release(*input.start);
                    if event.key.keysym.sym == SDLK_RETURN  release(*input.select);
                }

            case SDL_KEYDOWN;
                #if DEVELOPER_TOOLS then if program_state.editor.active && program_state.editor.imgui_state.capturing_keyboard return;

                // Main Program Inputs
                {
                    if event.key.repeat != 0 return;

                    if event.key.keysym.sym == SDLK_w       press(*input.up);
                    if event.key.keysym.sym == SDLK_a       press(*input.left);
                    if event.key.keysym.sym == SDLK_s       press(*input.down);
                    if event.key.keysym.sym == SDLK_d       press(*input.right);

                    if event.key.keysym.sym == SDLK_j       press(*input.a);
                    if event.key.keysym.sym == SDLK_k       press(*input.b);

                    if event.key.keysym.sym == SDLK_ESCAPE  press(*input.start);
                    if event.key.keysym.sym == SDLK_RETURN  press(*input.select);
                }

                // Development keybinds
                #if DEVELOPER_TOOLS {
                    if event.key.keysym.sym == SDLK_F1 {
                        switch_scene(.TITLE);
                    }

                    if event.key.keysym.sym == SDLK_F2 {
                        switch_scene(.GAME);
                    }

                    if event.key.keysym.sym == SDLK_F3 {
                        switch_scene(.MENU);
                    }

                    if event.key.keysym.sym == SDLK_F4 {
                        switch_scene(.DEMO);
                    }

                    if event.key.keysym.sym == SDLK_F5 {
                        // FREE
                    }

                    if event.key.keysym.sym == SDLK_F6 {
                        // FREE
                    }

                    if event.key.keysym.sym == SDLK_F7 {
                        if editor.active {
                            deactivate(*editor);
                        }
                        else {
                            activate(*editor);
                        }
                    }

                    if event.key.keysym.sym == SDLK_F8 {
                        show_debug_info = !show_debug_info;
                    }

                    if event.key.keysym.sym == SDLK_F9 {
                        program_state.simulation_state.frozen = !program_state.simulation_state.frozen;
                    }

                    if event.key.keysym.sym == SDLK_F10 {
                        program_state.simulation_state.step = true;
                    }

                    if event.key.keysym.sym == SDLK_F11 {
                        want_screenshot = true;
                    }

                    if event.key.keysym.sym == SDLK_F12 {
                        // DEBUGGER TAKES THIS ONE
                    }
                }

            case SDL_MOUSEBUTTONDOWN;
                #if DEVELOPER_TOOLS then if program_state.editor.active && program_state.editor.imgui_state.capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   press(*input.mouse.left);
                    if event.button.button == SDL_BUTTON_RIGHT  press(*input.mouse.right);
                    if event.button.button == SDL_BUTTON_MIDDLE press(*input.mouse.middle);
                }

            case SDL_MOUSEBUTTONUP;
                #if DEVELOPER_TOOLS then if program_state.editor.active && program_state.editor.imgui_state.capturing_mouse return;

                // Main Program Inputs
                {
                    if event.button.button == SDL_BUTTON_LEFT   release(*input.mouse.left);
                    if event.button.button == SDL_BUTTON_RIGHT  release(*input.mouse.right);
                    if event.button.button == SDL_BUTTON_MIDDLE release(*input.mouse.middle);
                }



            case SDL_MOUSEMOTION;
                #if DEVELOPER_TOOLS then if program_state.editor.active && program_state.editor.imgui_state.capturing_mouse return;

                // Main Program Inputs
                {
                    // @TODO: Review these arbitrary offsets for actual pixel correctness.
                    input.mouse.position.x = cast(int)(event.motion.x * 
                        (cast(float)PIXEL_WIDTH  / graphics_context.window_width)) + 1
                    ;
                    input.mouse.position.y = PIXEL_HEIGHT - cast(int)(event.motion.y * 
                        (cast(float)PIXEL_HEIGHT / graphics_context.window_height)) - 1
                    ;
                }


            JOYSTICK_DEAD_ZONE :: 8000;
            case SDL_JOYBUTTONDOWN;
                // 0, 1, 2, 3 : face buttons
                // 4, 5 : left bumper / right bumper
                // 6, 7 : select / start
                // 8, 9 : pressing in left stick / right stick

                if event.jbutton.button == 0 then press(*input.a);
                if event.jbutton.button == 1 then press(*input.b); 
                if event.jbutton.button == 2 then press(*input.b);
                if event.jbutton.button == 3 then press(*input.a);
                if event.jbutton.button == 6 then press(*input.start);
                if event.jbutton.button == 7 then press(*input.select);

            case SDL_JOYBUTTONUP;
                if event.jbutton.button == 0 then release(*input.a);
                if event.jbutton.button == 1 then release(*input.b); 
                if event.jbutton.button == 2 then release(*input.b);
                if event.jbutton.button == 3 then release(*input.a);
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
                if event.window.event == {
                    case .SDL_WINDOWEVENT_SIZE_CHANGED; {
                        resize_window(event.window.data1, event.window.data2);
                    }

                    case .SDL_WINDOWEVENT_ENTER; {
                        input.mouse.active = true;
                    }

                    case .SDL_WINDOWEVENT_LEAVE; {
                        input.mouse.active = false;
                    }
                }
        }
    }
}
