<?php

const COLOUR_RED = 1;
const COLOUR_WHITE = 2;
const COLOUR_ASPHALT = 3;
const COLOUR_GRASS = 4;

function convertPixelColourArrayToPlanarArray($pixel_colours) {
	$planar_pixels=array();
	for ($span_pixel_x=0; $span_pixel_x<8; $span_pixel_x++) {
		$planar_pixels[$span_pixel_x]=0;
	}

	$planar_representation=0;
	for ($span_pixel_x=0; $span_pixel_x<16; $span_pixel_x++) {
		if ($span_pixel_x>7) {
			$start_offset=0;
		} else {
			$start_offset=1;
		}
		$shift=$span_pixel_x&7;

		$pixel_colour=$pixel_colours[15-$span_pixel_x];
		$plane_0=$pixel_colour&1;
		$plane_1=($pixel_colour&2)>>1;
		$plane_2=($pixel_colour&4)>>2;
		$plane_3=($pixel_colour&8)>>3;

		$planar_pixels[$start_offset]|=($plane_0<<$shift);
		$planar_pixels[$start_offset+2]|=($plane_1<<$shift);
		$planar_pixels[$start_offset+4]|=($plane_2<<$shift);
		$planar_pixels[$start_offset+6]|=($plane_3<<$shift);
	}

    return $planar_pixels;
}

function convertPixelColoursToOutputBytes(array $pixelColours) {

    if ((count($pixelColours) & 15) != 0) {
        throw new \RuntimeException('Output byte array size is not a multiple of 16');
    }

    $outputBytes = [];

    $blocksOf16Pixels = array_chunk($pixelColours, 16); 
    foreach ($blocksOf16Pixels as $block) {
        //$boo = [0, 0, 0, 0, 3, 3, 3, 3, 5, 5, 5, 5, 7, 7, 7, 7];
        $outputBytes = array_merge(
            $outputBytes,
            convertPixelColourArrayToPlanarArray($block)
        );
    }

    return $outputBytes;
}

$padding = 14;

$byteOffsets = [];
$outputBytes = [];
$actualPixelWidthFloat = 10;

for ($index = 0; $index < 255; $index++) {
    $actualPixelWidth = (int)$actualPixelWidthFloat;
    $roundedPixelWidth = (($actualPixelWidth - 1) & 0xffe0) + 32 + ($padding * 16);
    //echo("rounded pixel width: ".$roundedPixelWidth."\n");

    $textureStep = 1.0 / $actualPixelWidth;
    $texturePosition = 0;
    $midpointTexturePosition = $textureStep * ($roundedPixelWidth / 2);
    $pixelColours = [];

    for ($xpos = 0; $xpos < $roundedPixelWidth; $xpos++) {
        if (($texturePosition > ($midpointTexturePosition + 0.485)) && ($texturePosition < ($midpointTexturePosition + 0.5))) {
            $pixelColour = COLOUR_RED;
        } elseif (($texturePosition > ($midpointTexturePosition - 0.5)) && ($texturePosition < ($midpointTexturePosition - 0.485))) {
            $pixelColour = COLOUR_RED;
        } elseif (($texturePosition > ($midpointTexturePosition + 0.47)) && ($texturePosition < ($midpointTexturePosition + 0.48))) {
            $pixelColour = COLOUR_WHITE;
        } elseif (($texturePosition > ($midpointTexturePosition - 0.48)) && ($texturePosition < ($midpointTexturePosition - 0.47))) {
           $pixelColour = COLOUR_WHITE;
        } elseif (($texturePosition > ($midpointTexturePosition - 0.01)) && ($texturePosition < ($midpointTexturePosition + 0.01))) {
            $pixelColour = COLOUR_WHITE;
        } elseif (($texturePosition > ($midpointTexturePosition - 0.5)) && ($texturePosition < ($midpointTexturePosition + 0.5))) {
            $pixelColour = COLOUR_ASPHALT;
        } else {
            $pixelColour = COLOUR_GRASS;
        }

        $pixelColours[] = $pixelColour;
        $texturePosition += $textureStep;
    }

    // rounded pixel width: 160
    // bytes width: 80 (2 pixels per byte)
    // does count($outputBytes) need to be multiplied by 4? (long words)
    $byteOffsets[] = (count($outputBytes) + ($roundedPixelWidth / 4)) - (160/2);

    $outputBytes = array_merge(
        $outputBytes,
        convertPixelColoursToOutputBytes($pixelColours)
    );

    $actualPixelWidthFloat+=1.5;
}

echo("byte_offsets:\n");
foreach ($byteOffsets as $byteOffset) {
    echo("    dc.l " . $byteOffset . "\n");
}

echo("\n");
echo("gfx_data:\n");
$outputBytesChunksOf8 = array_chunk($outputBytes, 8);
foreach ($outputBytesChunksOf8 as $chunkOf8) {
    $normalisedValues = [];
    foreach ($chunkOf8 as $byte) {
        $normalisedValues[] = '$' . dechex($byte>>4) . dechex($byte&15);
    }

    echo("    dc.b ". implode(",", $normalisedValues) ."\n");
}
