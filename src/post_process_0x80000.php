<?php

function readLongword($str, $ofs)
{
    return (ord($str[$ofs]) << 24) + (ord($str[$ofs+1])<<16) + (ord($str[$ofs+2]) << 8) + ord($str[$ofs+3]);
}

function writeLongword($str, $ofs, $val)
{
    $str[$ofs] = chr($val >> 24);
    $str[$ofs+1] = chr(($val >> 16) & 0xff);
    $str[$ofs+2] = chr(($val >> 8) & 0xff);
    $str[$ofs+3] = chr($val & 0xff);
    return $str;
}

include $argv[1];

echo("Post processing 0x80000...\n");

$stringContent = file_get_contents($argv[2]);

// we need to add the gfx data address to each of the byte offsets addresses
$byteOffsetsAddress = $symbols['byte_offsets'];
$gfxDataAddress = $symbols['gfx_data'];

$currentByteOffset = $byteOffsetsAddress;
$stringOffset = $byteOffsetsAddress - 0x80000;
while ($currentByteOffset < $gfxDataAddress) {
    $value = readLongword($stringContent, $stringOffset);
    $updatedValue = $value + $gfxDataAddress;
    $stringContent = writeLongword($stringContent, $stringOffset, $updatedValue);

    $currentByteOffset += 4;
    $stringOffset += 4;
}

file_put_contents($argv[2], $stringContent);
