<?php

const COLOUR_RED = 2;             // 0010
const COLOUR_WHITE = 6;           // 0110
const COLOUR_GREY = 5;            // 0101

const COLOUR_LIGHT_ASPHALT = 13;  // 1101
const COLOUR_GRASS_1 = 12;        // 1100

const COLOUR_DARK_ASPHALT = 15;   // 1111
const COLOUR_GRASS_2 = 14;        // 1110

// could we add red and white afterwards?

// RASTER LINES WITH WHITE: these contain DARK_ASPHALT, GRASS_2 and COLOUR_WHITE
// these all have bitplanes 2 and 3 in common
// SUMMARY: we can write a solid value to bitplanes 2 and 3, and do copies for bitplanes 1 and 4
// 
// FOR ALL LINES TO BE DRAWN: set bitplanes 2 and 3 to 1
// copy 2 words, skip 2 words, copy 2 words, skip 2 words

// THEORY:
// 80 words per line
// 
// OLD:
// 80 words (20 words per plane) can be written using 3 nops = 240
// TOTAL: 240 nops
//
// NEW:
// 40 words can be written using 1 nop = 40
// 40 words can be written using 3 nops = 120
// TOTAL: 160 nops
//
// source data should be as follows:
// bitplane 4, bitplane 1, bitplane 4, bitplane 1 etc
// destination address should be "normal start address + 6
// draw two words, skip two words
// so xcount should be 2, ycount should be 20
// 

// INITIAL STATE: dark asphalt across bitplanes 2 and 3, no writes anywhere else (1 nop per word)
// bitplane 1: xxxxxxxxxxxxxxxx
// bitplane 2: 1111111111111111
// bitplane 3: 1111111111111111
// bitplane 4: xxxxxxxxxxxxxxxx

// to convert grass pixels to the correct colour, and lay foundations for white lines, write bitplane 4 only (1110) 
// bitplane 1: xxxxxxxxxxxxxxxx
// bitplane 2: 1111111111111111
// bitplane 3: 1111111111111111
// bitplane 4: 1100111100000000

// to convert grass cutouts prepared for road, write bitplane 1 only
// bitplane 1: 1100111111111111
// bitplane 2: 1111111111111111
// bitplane 3: 1111111111111111
// bitplane 4: 1100111100000000

// INITIAL STATE: light asphalt (1101) across everything

// INITIAL STATE: light asphalt across bitplanes 2 and 3 (1 nop per word)
// bitplane 1: 1111111111111111
// bitplane 2: 1111111111111111
// bitplane 3: 0000000000000000
// bitplane 4: xxxxxxxxxxxxxxxx

// to convert grass pixels to the write colour, do a pass over bitplane 4 (0 = grass, 1 = road)
// bitplane 1: 1111111111111111
// bitplane 2: 1111111111111111
// bitplane 3: 0000000000000000
// bitplane 4: 1111111000000000

// we need a transformation from light asphalt (1101) to red (0010). This is problematic because all four bitplanes need to be modified!
// is this a challenge for another day?



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

for ($type = 0; $type <2; $type++) {
    if ($type == 0) {
        $rumbleStripColour = COLOUR_WHITE;
        $roadLinesColour = COLOUR_WHITE;
        $asphaltColour = COLOUR_LIGHT_ASPHALT;
        $grassColour = COLOUR_GRASS_1;
    } else {
        $rumbleStripColour = COLOUR_RED;
        $roadLinesColour = COLOUR_DARK_ASPHALT;
        $asphaltColour = COLOUR_DARK_ASPHALT;
        $grassColour = COLOUR_GRASS_2;
    }

    $actualPixelWidthFloat = 10;
    for ($index = 0; $index < 255; $index++) {
        $actualPixelWidth = (int)$actualPixelWidthFloat;

        $computedRoadLinesColour = COLOUR_DARK_ASPHALT;
        if ($roadLinesColour == COLOUR_WHITE) {
            $computedRoadLinesColour = COLOUR_WHITE;

            if ($actualPixelWidth < 60) {
                $computedRoadLinesColour = COLOUR_DARK_ASPHALT;
            } elseif ($actualPixelWidth < 120) {
                $computedRoadLinesColour = COLOUR_GREY;
            }
        }

        $roundedPixelWidth = (($actualPixelWidth - 1) & 0xffe0) + 32 + ($padding * 16);
        //echo("rounded pixel width: ".$roundedPixelWidth."\n");

        $textureStep = 1.0 / $actualPixelWidth;
        $texturePosition = 0;
        $midpointTexturePosition = $textureStep * ($roundedPixelWidth / 2);
        $pixelColours = [];

        for ($xpos = 0; $xpos < $roundedPixelWidth; $xpos++) {
            if (($texturePosition > ($midpointTexturePosition + 0.46)) && ($texturePosition < ($midpointTexturePosition + 0.54))) {
                $pixelColour = $rumbleStripColour; // left rumble strip
            } elseif (($texturePosition > ($midpointTexturePosition - 0.54)) && ($texturePosition < ($midpointTexturePosition - 0.46))) {
                $pixelColour = $rumbleStripColour; // right rumble strip
            } elseif (($texturePosition > ($midpointTexturePosition + 0.42)) && ($texturePosition < ($midpointTexturePosition + 0.44))) {
                $pixelColour = $computedRoadLinesColour;
            } elseif (($texturePosition > ($midpointTexturePosition - 0.44)) && ($texturePosition < ($midpointTexturePosition - 0.42))) {
               $pixelColour = $computedRoadLinesColour;
            } elseif (($texturePosition > ($midpointTexturePosition - 0.24)) && ($texturePosition < ($midpointTexturePosition - 0.22))) {
               $pixelColour = $computedRoadLinesColour;
            } elseif (($texturePosition > ($midpointTexturePosition + 0.22)) && ($texturePosition < ($midpointTexturePosition + 0.24))) {
               $pixelColour = $computedRoadLinesColour;
            } elseif (($texturePosition > ($midpointTexturePosition - 0.01)) && ($texturePosition < ($midpointTexturePosition + 0.01))) {
                $pixelColour = $computedRoadLinesColour;
            } elseif (($texturePosition > ($midpointTexturePosition - 0.5)) && ($texturePosition < ($midpointTexturePosition + 0.5))) {
                $pixelColour = $asphaltColour;
            } else {
                $pixelColour = $grassColour;
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
