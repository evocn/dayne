// Dayne
// Particle System
// Alex Hartford
// February 2024

Particle_System :: struct {
    using #as entity: Entity;
    kind = .PARTICLE_SYSTEM;

    color : Color;

    // A more complicated particle system probably looks like this:
    /*
    one_shot : bool; // Whether or not particles respawn when their lifetime ends.
    count : int;
    lifetime : float; // Maybe better as a range.
    initial_velocity : Vector2;
    constant_acceleration : Vector2 = .{};
    initial_range : Pair;
    */

    particles : [100] Particle; @NoSerialize
}

initialize :: (particle_system: *Particle_System) {
    generate_particle :: (particle: *Particle, color : Color) {
        particle.color = color;
        particle.position = .{random(0, PIXEL_WIDTH), random(0, PIXEL_HEIGHT)};
        particle.velocity = .{1, 0};
    }

    for * particle: particle_system.particles {
        generate_particle(particle, random_color());
    }
}

update :: (particle_system: *Particle_System, dt: float) {
    for * particle: particle_system.particles {
        update(particle, dt);
    }
}

draw :: (particle_system: Particle_System) {
    draw_particle :: (particle: Particle) {
        pixel := world_space_to_screen_pixel(particle.position);

        draw_pixel(pixel, particle.color);
    }

    for particle: particle_system.particles {
        draw_particle(particle);
    }
}

////////////////////////////////////////////////////////////////////////////////

Particle :: struct {
    // Properties
    color : Color;

    // State
    position : Vector2;
    velocity : Vector2;
}

update :: (particle : *Particle, dt: float) {
    particle.position += particle.velocity * dt;

    // Update Velocity based on gravity, forces, etc.
}
