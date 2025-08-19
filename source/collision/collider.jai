
// Collider
////////////////////////////////////////////////////////////////////////////////

Collider :: struct {
    x, y : int;
    width, height : int;
}

collision :: (a: Collider, b: Collider) -> bool {
    return a.x < b.x + b.width && a.y < b.y + b.height
        && a.x + a.width > b.x && a.y + a.height > b.y;
}

point_within :: (p: Pair, c: Collider) -> bool {
    return p.x >= c.x && p.x < c.x + c.width
        && p.y >= c.y && p.y < c.y + c.width;
}

////////////////////////////////////////////////////////////////////////////////

check_collision_against_all_solids :: (collider : Collider, solids : [] *Solid) -> bool {
    for solids {
        if it.collidable && collision(collider, it.collider) return true;
    }

    return false;
}

check_if_hitting_head :: (actor : *Actor) -> bool {
    extended_collider := actor.collider;
    extended_collider.y += 1;

    relevant_solids := filter_irrelevant_solids(game.simulation.solids, actor);

    for solid : relevant_solids {
        if collision(extended_collider, solid.collider) return true;
    }
    
    return false;
}

check_if_grounded :: (actor : *Actor) -> bool {
    extended_collider := actor.collider;
    extended_collider.y -= 1;

    relevant_solids := filter_irrelevant_solids(game.simulation.solids, actor);

    for solid : relevant_solids {
        if collision(extended_collider, solid.collider) {
            return true;
        }
    }
    
    return false;
}

////////////////////////////////////////////////////////////////////////////////

draw :: (collider: Collider, color : Color, outline_color := white) {
    screen_pixel := world_space_to_screen_pixel(collider.x, collider.y);
    top_right := world_space_to_screen_pixel(collider.x + collider.width, collider.y + collider.height);
    if !on_screen(screen_pixel) && !on_screen(top_right) then return;
    scale := screen_pixel_zoom();
    
    draw_colored_quad(
        xx screen_pixel.x, xx screen_pixel.y,
        xx collider.width * scale, xx collider.height * scale,
        color=color
    );
}
