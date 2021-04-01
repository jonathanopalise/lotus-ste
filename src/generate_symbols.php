<?php

$handle = fopen($argv[1], 'r');

echo("<" . "?php\n");
echo("\$symbols = [\n");
if ($handle) {
    while (($buffer = fgets($handle, 4096)) !== false) {
        $lineElements = explode(' ', $buffer);

        $address = '0x' . trim($lineElements[0]);
        $label = trim($lineElements[2]);
        echo '    \'' . $label . '\' => ' . $address . ",\n";
    }
    if (!feof($handle)) {
        echo "Error: unexpected fgets() fail\n";
    }
    fclose($handle);
}
echo("];\n");
echo("?".">\n");
