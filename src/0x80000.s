
    ORG $80000

    include "lz4_decode.s"
    include "load_samples.s"
    include "init_mountains.s"
    include "init_draw_road.s"
    include "generated/road.s"
    include "blitter_sprites.s"
    include "sky_gradient.s"
    include "preprocess_palette.s"
    include "ym_volume_adjust.s"
    include "ym_engine_volume_adjust.s"
    include "vbl_start_intercept.s"
    include "mixer_init.s"
    include "mixer_data.s"
    include "mixer_variables.s"
    include "mixer_vbl.s"
    include "do_sound_events.s"
    include "status_panel.s"
