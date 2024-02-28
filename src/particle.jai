// Dayne
// Particle System
// Alex Hartford
// February 2024

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

generate_particle :: (particle: *Particle) {
    particle.color = white;
    particle.position = .{rng(0, PIXEL_WIDTH), rng(0, PIXEL_HEIGHT)};
    particle.velocity = .{1, 0};
}

////////////////////////////////////////////////////////////////////////////////

Particle_System :: struct {
    particles : [100] Particle;
}

update :: (particle_system: *Particle_System, dt: float) {
    for * particle: particle_system.particles {
        update(particle, dt);
    }
}
