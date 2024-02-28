// Dayne
// Player Interface
// Alex Hartford
// February 2024

Player_Interface :: struct {
    state : Player_Interface_State;

    input : User_Input;

    gamepad: SDL_Joystick;
}


Player_Interface_State :: enum {
    DEFAULT;
}
