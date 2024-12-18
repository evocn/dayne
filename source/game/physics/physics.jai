// Dayne
// Physics
// August 2024

#load "collider.jai";
#load "actor.jai";
#load "solid.jai";

// All colliders are axis-aligned bounding boxes (AABBs)
// All collider positions, widths, and heights are integer numbers
// Except for special circumstances, Actors and Solids will never overlap
// Solids do not interact with other Solids

Simulation :: struct {
    actors : [..] *Actor;
    solids : [..] *Solid;
}

reset_simulation :: (simulation: *Simulation) {
    array_reset(*simulation.actors);
    array_reset(*simulation.solids);
}

// Utilities

filter_irrelevant_solids :: (solids: [..] *Solid, actor: Actor) -> [] *Solid {
    result : [..] *Solid;
    result.allocator = temp;

    for solid : solids {
        actor_below_solid := solid.collider.y + solid.collider.height > actor.collider.y;
        if solid.one_way && actor_below_solid then continue;

        array_add(*result, solid);
    }

    return result;
}

inside_collisions :: (extents: Collider, using actor: *Actor, velocity_to_bounce : *Vector2) {
    collided_x := (x < extents.x)
               || (x + width > extents.width)
    ;
    collided_y := (y < extents.y)
               || (y + height > extents.height)
    ;

    if collided_x {
        x = clamp(x, xx extents.x, xx (extents.x + extents.width - width));
        x_remainder = 0.0;
        velocity_to_bounce.x = -velocity_to_bounce.x;
    }
    if collided_y {
        y = clamp(y, xx extents.y, xx (extents.y + extents.height - height));
        y_remainder = 0.0;
        velocity_to_bounce.y = -velocity_to_bounce.y;
    }
}
