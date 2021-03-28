<?php

function getFile($filename) {
    $fileContents = file_get_contents($filename);
    if ($fileContents === false) {
        echo(__FILE__.': unable to fetch contents of file '.$filename."\n");
        exit(1);
    }

    return $fileContents;
}

if ($argc < 3) {
    echo(__FILE__.": not enough arguments\n");
    exit(1);
}

$arguments = array_slice($argv, 1);

$sourcePath = $arguments[0];
$sourceFileContents = getFile($sourcePath);

$destinationPath = $arguments[1];
$destinationFileContents = getFile($destinationPath);

// jump instruction and executable checksum
$destinationFileContents[0] = chr(0x60);
$destinationFileContents[1] = chr(0x1c);
$destinationFileContents = substr_replace($destinationFileContents, $sourceFileContents, 0x1e, strlen($sourceFileContents));

// calculate executable checksum
$cumulative = 0;
$wordsRead = 0;
for ($index = 0; $index < 510; $index += 2) {
    $highByte = ord($destinationFileContents[$index]);
    $lowByte = ord($destinationFileContents[$index+1]);
    $wordValue = ($highByte << 8) + $lowByte;
    $cumulative += $wordValue;
    $wordsRead++;
}

$desiredChecksum = 0x1234;

echo("total of initial ".$wordsRead." words is 0x".dechex($cumulative & 0xffff)."\n");
echo("total of all words needs to be 0x".dechex($desiredChecksum)."\n");

$checksum = ((((0xffff + $desiredChecksum) - $cumulative) + 1) & 0xffff);
echo("checksum = 0x".dechex($checksum)."\n");

$destinationFileContents[0x1fe] = chr(($checksum >> 8) & 0xff);
$destinationFileContents[0x1ff] = chr($checksum & 0xff);

$cumulative = 0;
$wordsRead = 0;
for ($index = 0; $index < 512; $index += 2) {
    $highByte = ord($destinationFileContents[$index]);
    $lowByte = ord($destinationFileContents[$index+1]);
    $wordValue = ($highByte << 8) + $lowByte;
    $cumulative += $wordValue;
    $wordsRead++;
}

$cumulativeAsWord = $cumulative & 0xffff;
if ($cumulativeAsWord == $desiredChecksum) {
    echo("checksum successfully verified\n");
} else {
    echo("checksum verification failed - cumulative total of initial ".$wordsRead." words is 0x".dechex($cumulativeAsWord)." and needs to be 0x".dechex($desiredChecksum).". exiting!\n");
    exit(1);
}

file_put_contents($destinationPath, $destinationFileContents);

echo("Bootsector applied, writing modified file back to ".$destinationPath."...\n");
file_put_contents($destinationPath, $destinationFileContents);
