<?php

function generateSteNibble($value)
{
    $amigaNibble = ($value >> 4);
    return (($amigaNibble >> 1) | (($amigaNibble & 1) << 3));
}

$rgbPalette = file_get_contents($argv[1]);

$stePalette = [];
$offset = 0;
for ($index = 0; $index < 16; $index++) {
    $red = ord($rgbPalette[$offset]);
    $green = ord($rgbPalette[$offset+1]);
    $blue = ord($rgbPalette[$offset+2]);
    /*echo(
        sprintf(
            "entry: %d %d %d\n",
            $red,
            $green,
            $blue,
        )
    );*/

    $steRed = generateSteNibble($red);
    $steGreen = generateSteNibble($green);
    $steBlue = generateSteNibble($blue);

    /*echo(
        sprintf(
            "ste entry: %d %d %d\n",
            dechex($steRed),
            dechex($steGreen),
            dechex($steBlue),
        )
    );*/

    $stePalette[] = ($steRed << 8) | ($steGreen << 4) | ($steBlue);

    $offset += 3;
}

foreach ($stePalette as $entry) {
    echo('    dc.w $'. dechex($entry) ."\n");
}
