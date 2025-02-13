// Dayne
// Animator
// February 2025

Animator :: struct {
    animations : Table(string, Sprite_Animation);
    animation : *Sprite_Animation;
}

update :: (using animator: *Animator, dt: float) {
    if !animation then for animations {
        animation = *it;
        break;
    }

    update(animation, dt);
}

change :: (using animator: *Animator, to: string) {
    new_animation := table_find_pointer(*animations, to);
    if !new_animation {
        log_error("Unable to chang to animation % because it isn't on this Animator.", to);
        return;
    }

    if new_animation != animation {
        animation = new_animation;
        reset(animation);
    }
}
