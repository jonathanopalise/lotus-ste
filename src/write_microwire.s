write_microwire:
	lea.l		$ffff8920.w,a0					; ste dma sound base address
	move.w		#%0000011111111111,4(a0)
	move.w		d0,2(a0)
	rts
