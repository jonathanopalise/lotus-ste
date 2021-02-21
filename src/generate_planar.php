<?php

function convertPixelColourArrayToPlanarArray($pixel_colours) {
    $bitplanes = [
        [],
        [],
        [],
        []
    ];

    foreach ($pixel_colours as $pixel_colour) {
        $bitplanes[3][] = ($pixel_colour & 8) ? 1: 0;
        $bitplanes[2][] = ($pixel_colour & 4) ? 1: 0;
        $bitplanes[1][] = ($pixel_colour & 2) ? 1: 0;
        $bitplanes[0][] = ($pixel_colour & 1) ? 1: 0;
    }

    foreach ($bitplanes as $index => $bitplane) {
        $bitplaneBinary = implode('', array_slice($bitplane, 0, 8));
        $planar_pixels[] = bindec($bitplaneBinary);

        $bitplaneBinary = implode('', array_slice($bitplane, 8, 8));
        $planar_pixels[] = bindec($bitplaneBinary);
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
        $outputBytes = array_merge(
            $outputBytes,
            convertPixelColourArrayToPlanarArray($block)
        );
    }

    return $outputBytes;
}


$inputFileContent = file_get_contents($argv[1]);
$inputFileContentLength = strlen($inputFileContent);
$pixelColours = [];

for ($index = 0; $index < $inputFileContentLength; $index++) {
    $pixelColours[] = ord($inputFileContent[$index]);
}

$outputBytes = [];
$blocksOf16Pixels = array_chunk($pixelColours, 16); 
foreach ($blocksOf16Pixels as $block) {
    $outputBytes = array_merge(
        $outputBytes,
        convertPixelColourArrayToPlanarArray($block)
    );
}

$outputBytesChunksOf8 = array_chunk($outputBytes, 8);
foreach ($outputBytesChunksOf8 as $chunkOf8) {
    $normalisedValues = [];
    foreach ($chunkOf8 as $byte) {
        $normalisedValues[] = '$' . dechex($byte>>4) . dechex($byte&15);
    }

    echo("    dc.b ". implode(",", $normalisedValues) ."\n");
}

