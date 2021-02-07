
    ORG $70896

    include symbols.inc

    move.w #$60,post_vbl_timer_b_lines_instruction+2
    move.l #$706c0,post_vbl_timer_b_vector_instruction+2


