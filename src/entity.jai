// Dayne
// Entity
// Alex Hartford
// March 2024

/*
* Serialization built-in to all inheritors
* Editing is consistent
* Can just call Update() and Draw() on all the entities, with minor caveats.
* Don't need to bother adding new arrays for each kind of Entity.
*/

next_entity_id : u64 = 1;

// This allocates a new entity of this type.
// In the future, I can imagine a nice situation where it allocates from a specific
// Fridge based on the type of entity, and does other good stuff.
make_entity :: (kind : Entity.Kind) -> *Entity {
    entity : *Entity;

    if #complete kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!\n");
        case .GUY;              entity = cast(*Entity) New(Guy);
        case .PARTICLE_SYSTEM;  entity = cast(*Entity) New(Particle_System);
    }

    entity.entity_id = next_entity_id;
    next_entity_id += 1;

    return entity;
}

// We're not destroying entities right now, but soon.
// The best way to do this will be to keep spots in that fridge open, replacing them when stuff dies,
// but only freeing the fridge at the end of the program, or likewise.

Entity :: struct {
    entity_id : u64;

    position: Vector2;

    Kind :: enum #complete {
        UNDEFINED;
        GUY;
        PARTICLE_SYSTEM;
    }
    kind : Kind;
}

determine_entity_kind_and_update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!\n");
        case .GUY;              update((cast(*Guy)entity), dt);
        case .PARTICLE_SYSTEM;  update((cast(*Particle_System)entity), dt);
    }
}

determine_entity_kind_and_draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!\n");
        case .GUY;              draw((cast(*Guy)entity).*);
        case .PARTICLE_SYSTEM;  draw((cast(*Particle_System)entity).*);
    }
}
