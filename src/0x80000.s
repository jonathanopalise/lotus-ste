
    ORG $80000

    include "generated/road.s"
    include "init_draw_road.s"
    include "blitter_sprites.s"
    include "sky_gradient.s"
    include "preprocess_palette.s"
    include "ym_volume_adjust.s"
    include "vbl_start_intercept.s"
    include "mixer_init.s"
    include "mixer_data.s"
    include "mixer_variables.s"
    include "mixer_vbl.s"

