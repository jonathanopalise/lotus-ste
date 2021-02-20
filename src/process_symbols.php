<?php

$handle = fopen($argv[1], 'r');

if ($handle) {
    while (($buffer = fgets($handle, 4096)) !== false) {
        $lineElements = explode(' ', $buffer);

        $address = '$' . trim($lineElements[0]);
        $label = trim($lineElements[2]);
        echo $label . ' equ ' . $address . "\n";
    }
    if (!feof($handle)) {
        echo "Error: unexpected fgets() fail\n";
    }
    fclose($handle);
}
