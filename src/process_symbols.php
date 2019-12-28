<?php

$handle = fopen('src/symbols.txt', 'r');

if ($handle) {
    while (($buffer = fgets($handle, 4096)) !== false) {
        $lineElements = explode(' ', $buffer);
        var_dump($lineElements);

        $address = '$' . $lineElements[0];
        $label = $lineElements[2];
        echo $label . ' equ ' . $address;
    }
    if (!feof($handle)) {
        echo "Error: unexpected fgets() fail\n";
    }
    fclose($handle);
}
