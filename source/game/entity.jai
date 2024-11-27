// Dayne
// Entity
// September 2024

Entity :: struct {
    Kind :: enum {
        TEST;
    }
    kind : Kind;

    z_index     : int;

    id          : int;
    should_die  : bool;

    debug: struct {
        unique_color: Color;
    }
}

next_id := 0;
new_entity :: (kind : Entity.Kind) -> *Entity {
    new_entity : *Entity;

    if #complete kind == {
        case .TEST;             new_entity = xx New(Test);
    }

    initialize(new_entity);

    new_entity.id = next_id;
    next_id += 1;

    return new_entity;
}


initialize :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             initialize(cast(*Test)entity);
    }

    entity.debug.unique_color = random_color();
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .TEST;             update(cast(*Test)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             draw(cast(*Test)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .TEST;             draw_debug(cast(*Test)entity);
    }
}

