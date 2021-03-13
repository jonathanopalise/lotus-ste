
    ORG $80000

distxoffsets   equ $2b880
oneovertab     equ $2fd40
distbasewidths equ $30e40

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
    include "write_microwire.s"
    include "calculate_road.s"
    include "ascnlinedists.s"

