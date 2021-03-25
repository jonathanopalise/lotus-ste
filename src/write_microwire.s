write_microwire:
	lea.l		$ffff8900.w,a0					; ste dma sound base address
	move.w		#%0000011111111111,$24(a0)
	move.w		d0,$22(a0)
	rts
