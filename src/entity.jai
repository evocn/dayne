// Dayne
// Entity
// Alex Hartford
// March 2024

/*
Current thoughts on entity systems:

I think these systems are good, if a little more friction can come out of them.
At the moment, I still have to manually add code in like four different functions when I make a new entity.
That's an improvement over the ~8 different places I would have to add code if I wasn't using this,
and the compiler helps me out with #complete enum protection,
but it should be a lot better!

Most of the trouble I am having is that in order to cast from *Entity to *Sub_Entity, I always need an if..case.
I'm pretty sure this is necessary, as the compiler has to know the type of the structure at compile time.
I could be wrong, and be able to somehow cast to 
*/

Entity :: struct {
    // @NOTE: This could also just be type : Type, but there are problems:
    // * I don't want to have to make serialization more complicated.
    // * I want #complete if..case statements to keep throwing good errors.
    Kind :: enum #complete {
        UNDEFINED;
        GUY;
        PARTICLE_SYSTEM;
    }
    kind : Kind;        @NoSerialize
    entity_id : u64;    @NoSerialize

    name : string;

    position : Vector2;
}

determine_entity_kind_and_initialize :: (entity: *Entity) {
    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!");
        case .GUY;              initialize(cast(*Guy)entity);
        case .PARTICLE_SYSTEM;  initialize(cast(*Particle_System)entity);
    }
}

determine_entity_kind_and_update :: (entity: *Entity, dt: float) {
    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!");
        case .GUY;              update(cast(*Guy)entity, dt);
        case .PARTICLE_SYSTEM;  update(cast(*Particle_System)entity, dt);
    }
}

determine_entity_kind_and_draw :: (entity: *Entity) {
    if #complete entity.kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!");
        case .GUY;              draw((cast(*Guy)entity).*);
        case .PARTICLE_SYSTEM;  draw((cast(*Particle_System)entity).*);
    }
}

////////////////////////////////////////////////////////////////////////////////
// Entity Creation and Destruction
////////////////////////////////////////////////////////////////////////////////

next_entity_id : u64 = 1;

// This allocates a new entity of a given type.
// @TODO: In the future, I can imagine a nice situation where it allocates from a
// Fridge based on the type of entity, and does other good stuff.
make_entity :: (kind : Entity.Kind) -> *Entity {
    entity_allocator: Allocator;
    entity_allocator.proc = flat_pool_allocator_proc;
    entity_allocator.data = *entity_pool;

    entity : *Entity;

    if #complete kind == {
        case .UNDEFINED;        assert(false, "This entity has an undefined type. Something is wrong!");
        case .GUY;              entity = cast(*Entity) New(Guy,, entity_allocator);
        case .PARTICLE_SYSTEM;  entity = cast(*Entity) New(Particle_System,, entity_allocator);
    }

    entity.entity_id = next_entity_id;
    next_entity_id += 1;

    entity.name = "placeholder";

    return entity;
}

// @TODO:
// We're not destroying entities right now, but soon we will.
// The best way to do this will be to keep spots in that fridge open, replacing them when stuff dies,
// but only freeing the fridge at the end of the program, or likewise.
