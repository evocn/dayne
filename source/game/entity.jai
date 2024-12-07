// Dayne
// Entity
// September 2024

Entity :: struct {
    Kind :: enum {
        BASIC;
        GUY;
        PLATFORM;
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
        case .BASIC;            new_entity = xx New(Basic);
        case .GUY;              new_entity = xx New(Guy);
        case .PLATFORM;         new_entity = xx New(Platform);
    }

    initialize(new_entity);

    new_entity.id = next_id;
    next_id += 1;

    return new_entity;
}


initialize :: (entity: *Entity) {
    entity.debug.unique_color = random_color();

    if #complete entity.kind == {
        case .BASIC;            initialize(cast(*Basic)entity);
        case .GUY;              initialize(cast(*Guy)entity);
        case .PLATFORM;         initialize(cast(*Platform)entity);
    }
}

apply_input :: (entity: *Entity, input: Input) {
    if #complete entity.kind == {
        case .BASIC;            apply_input(cast(*Basic)entity, input);
        case .GUY;              apply_input(cast(*Guy)entity, input);
        case .PLATFORM;         apply_input(cast(*Platform)entity, input);
    }
}

update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .BASIC;            update(cast(*Basic)entity, dt);
        case .GUY;              update(cast(*Guy)entity, dt);
        case .PLATFORM;         update(cast(*Platform)entity, dt);
    }
}

draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw(cast(*Basic)entity);
        case .GUY;              draw(cast(*Guy)entity);
        case .PLATFORM;         draw(cast(*Platform)entity);
    }
}

draw_debug :: (entity: *Entity) {
    if #complete entity.kind == {
        case .BASIC;            draw_debug(cast(*Basic)entity);
        case .GUY;              draw_debug(cast(*Guy)entity);
        case .PLATFORM;         draw_debug(cast(*Platform)entity);
    }
}

