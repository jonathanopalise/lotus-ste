<?php

$nop = chr(0x4e).chr(0x71);
$patch = '';
for ($index = 0; $index < 15; $index++) {
    $patch .= $nop;
}

$filename = $argv[1];
$fileContents = file_get_contents($filename);
$fileContents = substr_replace($fileContents, $patch, 0x8a, strlen($patch));
file_put_contents($filename, $fileContents);
