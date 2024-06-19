// Dayne
// Vignette
// Alex Hartford
// May 2024

Vignette :: struct {
    song : string;
}

vignette_begin :: (using vignette : *Vignette) {
    stop_music();

    if song then play_music(song);
}

vignette_end :: () {
    stop_music();
    // Fade music out.
}

////////////////////////////////////////////////////////////////////////////////

Spine :: struct {
    vignette_index  : int = -1;
    vignettes       : [..] Vignette;
}

spine_next :: (using spine : *Spine) {
    vignette_index = vignette_index + 1;

    if vignette_index >= vignettes.count {
        change_scene(.END);
        vignette_end();
        return;
    }


    vignette := *vignettes[vignette_index];

    vignette_begin(vignette);
}
