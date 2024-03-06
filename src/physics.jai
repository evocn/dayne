// Dayne
// Physics
// Alex Hartford
// March 2024

simulation : struct {
    solids : [..] *Solid;
    actors : [..] *Actor;
}

////////////////////////////////////////////////////////////////////////////////

filter_irrelevant_solids :: (solids: [..] *Solid, actor: Actor) -> [] *Solid {
    result : [..] *Solid;
    result.allocator = temp;

    for solid : solids {
        if solid.one_way {
            if solid.collider.y + solid.collider.height <= actor.collider.y {
                array_add(*result, solid);
            }
        }
        else {
            array_add(*result, solid);
        }
    }

    return result;
}

get_riding_actors :: (solid: Solid, actors: [..] *Actor) -> [..] *Actor {
    result : [..] *Actor;
    result.allocator = temp;

    for actor : actors {
        if is_riding(actor, solid) {
            array_add(*result, actor);
        }
    }

    return result;
}

check_collision_against_all_solids :: (collider : Collider, solids : [] *Solid) -> bool {
    for solids {
        if overlap(collider, it.collider) return true;
    }

    return false;
}
