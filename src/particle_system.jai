// Dayne
// Particle System
// Alex Hartford
// February 2024

Particle_System :: struct {
    using #as entity: Entity;
    kind = .PARTICLE_SYSTEM;

    particles : [100] Particle; @NoSerialize
}

initialize :: (particle_system: *Particle_System) {
    generate_particle :: (particle: *Particle) {
        particle.color = white;
        particle.position = .{rng(0, PIXEL_WIDTH), rng(0, PIXEL_HEIGHT)};
        particle.velocity = .{1, 0};
    }

    for * particle: particle_system.particles {
        generate_particle(particle);
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
