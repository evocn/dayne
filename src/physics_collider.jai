// Dayne
// Physics Collider
// Alex Hartford
// March 2024

// All colliders are axis-aligned bounding boxes (AABBs)
// All collider positions, widths, and heights are integer numbers
// Except for special circumstances, Actors and Solids will never overlap
// Solids do not interact with other Solids

Collider :: struct {
    x, y : int;
    width, height : int;
}

overlap :: (a: Collider, b: Collider) -> bool {
    return a.x < b.x + b.width && a.y < b.y + b.height
        && a.x + a.width > b.x && a.y + a.height > b.y;
}

////////////////////////////////////////////////////////////////////////////////

clamp_collider_to_level :: (collider : *Collider, level_width : int, level_height : int) {
    collider.x = clamp(collider.x, 0, level_width  - collider.width);
    collider.y = clamp(collider.y, 0, level_height - collider.height);
}

check_if_hitting_head :: (actor : Actor) -> bool {
    extended_collider := actor.collider;
    extended_collider.y += 1;

    relevant_solids := filter_irrelevant_solids(simulation.solids, actor);

    for solid : relevant_solids {
        if overlap(extended_collider, solid.collider) return true;
    }
    
    return false;
}

check_if_grounded :: (actor : Actor) -> bool {
    extended_collider := actor.collider;
    extended_collider.y -= 1;

    relevant_solids := filter_irrelevant_solids(simulation.solids, actor);

    for solid : relevant_solids {
        if overlap(extended_collider, solid.collider) {
            return true;
        }
    }
    
    return false;
}
