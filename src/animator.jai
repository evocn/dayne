// Dayne
// Animation
// Alex Hartford
// March 2024

Animator :: struct {
    Key_Frame :: struct {
        time : float;
        value: int;
    }

    // Parameters
    key_frames  : [..] Key_Frame;

    length      : float;
    looping     : bool;


    // State
    paused  : bool;
    time    : float;
}

make_animator :: (key_frames : ..Animator.Key_Frame, length := 1.0, looping := true) -> Animator {
    animator : Animator;

    for key_frame : key_frames {
        array_add(*animator.key_frames, key_frame);
    }

    animator.length  = length;
    animator.looping = looping;

    return animator;
}

////////////////////////////////////////////////////////////////////////////////

get_value :: (animator: Animator) -> int {
    index := animator.key_frames.count - 1;

    for key_frame : animator.key_frames {
        if animator.time < key_frame.time {
            index = it_index;
            break;
        }
    }

    return animator.key_frames[index].value;
}

////////////////////////////////////////////////////////////////////////////////

play :: (animator : *Animator) {
    animator.paused = false;
}

pause :: (animator : *Animator) {
    animator.paused = true;
}

start :: (animator : *Animator) {
    animator.time = 0.0;
    play(animator);
}

////////////////////////////////////////////////////////////////////////////////

update :: (animator : *Animator, dt: float) {
    if animator.paused return;

    animator.time += dt;

    if animator.time > animator.length {
        if animator.looping {
            start(animator);
            animator.time = animator.time - animator.length;
        }
        else {
            pause(animator);
            animator.time = animator.length;
        }
    }
}
