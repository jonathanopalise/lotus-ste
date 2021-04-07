<?php

const COLOUR_RED = 2;             // 0010 -> 0010
const COLOUR_WHITE = 6;           // 0110 -> 0110
const COLOUR_GREY = 5;            // 0101 -> 0101

const COLOUR_LIGHT_ASPHALT = 13;  // 1101 -> 1101
const COLOUR_GRASS_1 = 12;        // 1100 -> 1000

const COLOUR_DARK_ASPHALT = 15;   // 1111 -> 1111
const COLOUR_GRASS_2 = 14;        // 1110 -> 1100

$rumbleStripColour = COLOUR_WHITE;        // 0110 -> 1101
$roadLinesColour = COLOUR_WHITE;          // 0110 -> 1101
$roadLinesColour = COLOUR_GREY;           // 0101 -> 1101
$asphaltColour = COLOUR_LIGHT_ASPHALT;    // 1101 -> 1101
$grassColour = COLOUR_GRASS_1;            // 1100 -> 1100
// bitplane 0: hardcode to 1
// bitplane 1: hardcode to 1
// bitplane 2: hardcode to 0
// bitplane 3: copy

$rumbleStripColour = COLOUR_RED;          // 0010 -> 1111
$roadLinesColour = COLOUR_DARK_ASPHALT;   // 1111 -> 1111
$asphaltColour = COLOUR_DARK_ASPHALT;     // 1111 -> 1111
$grassColour = COLOUR_GRASS_2;            // 1110 -> 1110
// bitplane 0: hardcode to 1
// bitplane 1: hardcode to 1
// bitplane 2: hardcode to 1
// bitplane 3: copy


// leave grass_2 and red alone, transform dark asphalt to white
//
// red (unchanged)                = 0010 -> 0010
// grass_2 (unchanged)            = 1110 -> 1110
// dark_asphalt (change to white) = 1111 -> 0110
//
// could we use a "not source" (12) copy to copy bitplane 1 to bitplane 3?
// - bitplane 0 - solid 0
// - bitplane 1 - direct copy of source bitplane 1
// - bitplane 2 - direct copy of source bitplane 2
// - bitplane 3 - inverse copy of source bitplane 3
//
// white         = 0110 -> 0110
// light asphalt = 1101 -> 0110
// grass_1       = 1000 -> 1000
//
// method HERE:
// - bitplane 0 - solid 0
// - bitplane 1 - copy from source bitplane 2
// - bitplane 2 - copy from source bitplane 2
// - bitplane 3 - inverst copy of source bitplane 2

function convertPixelColourArrayToPlanarArray($pixel_colours, $ignoreBitplaneIndex) {
    $bitplanes = [
        [],
        [],
        [],
        []
    ];

    foreach ($pixel_colours as $pixel_colour) {
        $pixel_colour = transformPixelColour($pixel_colour);

        $bitplanes[3][] = ($pixel_colour & 8) ? 1: 0;
        $bitplanes[2][] = ($pixel_colour & 4) ? 1: 0;
        $bitplanes[1][] = ($pixel_colour & 2) ? 1: 0;
        $bitplanes[0][] = ($pixel_colour & 1) ? 1: 0;
    }

    foreach ($bitplanes as $index => $bitplane) {
        if ($index != $ignoreBitplaneIndex) {
            $bitplaneBinary = implode('', array_slice($bitplane, 0, 8));
            $planar_pixels[] = bindec($bitplaneBinary);

            $bitplaneBinary = implode('', array_slice($bitplane, 8, 8));
            $planar_pixels[] = bindec($bitplaneBinary);
        }
    }

    return $planar_pixels;
}

function transformPixelColour($colour) {
    $transformations = [
        COLOUR_WHITE => COLOUR_WHITE,
        COLOUR_GREY => COLOUR_GREY,
        COLOUR_LIGHT_ASPHALT => COLOUR_LIGHT_ASPHALT,
        COLOUR_GRASS_1 => (COLOUR_GRASS_1 & 11),
        COLOUR_RED => COLOUR_RED,
        COLOUR_DARK_ASPHALT => COLOUR_DARK_ASPHALT,
        COLOUR_GRASS_2 => (COLOUR_GRASS_2 & 13),
    ];

    if (!isset($transformations[$colour])) {
        throw new \Exception('Transformation not defined for colour '.$colour);
    }

    return $transformations[$colour];
}

function convertPixelColoursToOutputBytes(array $pixelColours, $ignoreBitplaneIndex) {

    if ((count($pixelColours) & 15) != 0) {
        throw new \RuntimeException('Output byte array size is not a multiple of 16');
    }

    $outputBytes = [];

    $blocksOf16Pixels = array_chunk($pixelColours, 16); 
    foreach ($blocksOf16Pixels as $block) {
        $outputBytes = array_merge(
            $outputBytes,
            convertPixelColourArrayToPlanarArray($block, $ignoreBitplaneIndex)
        );
    }

    return $outputBytes;
}

$padding = 22;

$byteOffsets = [];
$outputBytes = [];

for ($thePits = 0; $thePits < 2; $thePits++) {
    for ($type = 0; $type <2; $type++) {
        if ($type == 0) {
            $rumbleStripColour = COLOUR_WHITE;
            $roadLinesColour = COLOUR_WHITE;
            $asphaltColour = COLOUR_LIGHT_ASPHALT;
            $grassColour = COLOUR_GRASS_1;
            $ignoreBitplaneIndex = 1;
        } else {
            $rumbleStripColour = COLOUR_RED;
            $roadLinesColour = COLOUR_DARK_ASPHALT;
            $asphaltColour = COLOUR_DARK_ASPHALT;
            $grassColour = COLOUR_GRASS_2;
            $ignoreBitplaneIndex = 2;
        }
        $ignoreBitplaneIndex=15;

        $actualPixelWidthFloat = 1;
        for ($index = 0; $index < 255; $index++) {
            $actualPixelWidth = (int)$actualPixelWidthFloat;

            $computedRoadLinesColour = COLOUR_LIGHT_ASPHALT;
            if ($roadLinesColour == COLOUR_WHITE) {
                $computedRoadLinesColour = COLOUR_WHITE;

                if ($actualPixelWidth < 30) {
                    $computedRoadLinesColour = COLOUR_LIGHT_ASPHALT;
                } elseif ($actualPixelWidth < 60) {
                    $computedRoadLinesColour = COLOUR_GREY;
                }
            }

            $roundedPixelWidth = (($actualPixelWidth - 1) & 0xffe0) + 32 + ($padding * 16);
            //echo("rounded pixel width: ".$roundedPixelWidth."\n");

            $textureStep = 1.0 / $actualPixelWidth;
            $texturePosition = 0;
            $midpointTexturePosition = $textureStep * ($roundedPixelWidth / 2);
            $pixelColours = [];

            if ($thePits) {
                $pitsOffset = 0.3;
            } else {
                $pitsOffset = 0;
            }

            $roadMultiplier = 1.2;

            $leftRumbleStripLeft = ($midpointTexturePosition + (0.46 + $pitsOffset) * $roadMultiplier);
            $leftRumbleStripRight = ($midpointTexturePosition + (0.54 + $pitsOffset) * $roadMultiplier);
            $rightRumbleStripLeft = ($midpointTexturePosition - 0.54 * $roadMultiplier);
            $rightRumbleStripRight = ($midpointTexturePosition - 0.46 * $roadMultiplier);

            $whiteLine1Left = ($midpointTexturePosition + 0.42 * $roadMultiplier);
            $whiteLine1Right = ($midpointTexturePosition + 0.44 * $roadMultiplier);
            $whiteLine2Left = ($midpointTexturePosition + 0.46 * $roadMultiplier);
            $whiteLine2Right = ($midpointTexturePosition + 0.48 * $roadMultiplier);
            $whiteLine3Left = ($midpointTexturePosition - 0.44 * $roadMultiplier);
            $whiteLine3Right = ($midpointTexturePosition - 0.42 * $roadMultiplier);
            $whiteLine4Left = ($midpointTexturePosition - 0.24 * $roadMultiplier);
            $whiteLine4Right = ($midpointTexturePosition - 0.22 * $roadMultiplier);
            $whiteLine5Left = ($midpointTexturePosition + 0.22 * $roadMultiplier);
            $whiteLine5Right = ($midpointTexturePosition + 0.24 * $roadMultiplier);
            $whiteLine6Left = ($midpointTexturePosition - 0.01 * $roadMultiplier);
            $whiteLine6Right = ($midpointTexturePosition + 0.01 * $roadMultiplier);

            $asphaltLeft = ($midpointTexturePosition - 0.5 * $roadMultiplier);
            $asphaltRight = ($midpointTexturePosition + (0.5 + $pitsOffset) * $roadMultiplier);

            for ($xpos = 0; $xpos < $roundedPixelWidth; $xpos++) {
                if (($texturePosition > $leftRumbleStripLeft) && ($texturePosition < $leftRumbleStripRight)) {
                    $pixelColour = $rumbleStripColour; // left rumble strip
                } elseif (($texturePosition > $rightRumbleStripLeft) && ($texturePosition < $rightRumbleStripRight)) {
                    $pixelColour = $rumbleStripColour; // right rumble strip
                } elseif (($texturePosition > $whiteLine1Left) && ($texturePosition < $whiteLine1Right)) {
                    $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $whiteLine2Left) && ($texturePosition < $whiteLine2Right) && $thePits) {
                    $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $whiteLine3Left) && ($texturePosition < $whiteLine3Right)) {
                   $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $whiteLine4Left) && ($texturePosition < $whiteLine4Right)) {
                   $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $whiteLine5Left) && ($texturePosition < $whiteLine5Right)) {
                   $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $whiteLine6Left) && ($texturePosition < $whiteLine6Right)) {
                    $pixelColour = $computedRoadLinesColour;
                } elseif (($texturePosition > $asphaltLeft) && ($texturePosition < $asphaltRight)) {
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
                convertPixelColoursToOutputBytes($pixelColours, $ignoreBitplaneIndex)
            );

            $actualPixelWidthFloat+=1.515;
        }
    }
}

$pixelColours = array_fill(0, 16, COLOUR_GRASS_2);
for ($index = 0; $index < 11; $index++) {
    $outputBytes = array_merge(
        $outputBytes,
        convertPixelColoursToOutputBytes($pixelColours, $ignoreBitplaneIndex)
    );
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
