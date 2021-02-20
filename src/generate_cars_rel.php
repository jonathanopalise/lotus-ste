<?php

function getFile($filename) {
    $fileContents = file_get_contents($filename);
    if ($fileContents === false) {
        echo(__FILE__.': unable to fetch contents of file '.$filename."\n");
        exit(1);
    }

    return $fileContents;
}

if ($argc < 2) {
    echo(__FILE__.": not enough arguments\n");
    exit(1);
}

$arguments = array_slice($argv, 1);
$destinationPath = $arguments[0];
$sourcePaths = array_slice($arguments, 1);
$baseAddress = 0x70400;

$destinationFileContents = getFile($destinationPath);

foreach ($sourcePaths as $sourcePath) {
    echo("Reading patch file ".$sourcePath."\n");
    $sourcePathElements = explode('/', $sourcePath);
    $sourceFilename = $sourcePathElements[count($sourcePathElements)-1];

    $sourceFilenameLength = strlen($sourceFilename);
    if ($sourceFilenameLength < 11) {
        echo(__FILE__.": source filename ".$sourceFilename." length must be at least 11 characters, exiting.\n");
        exit(1);
    }

    if (substr($sourceFilename, 0, 2) !== '0x') {
        echo(__FILE__.": source file " . $sourceFilename . " does not have required 0x prefix, exiting.\n");
        exit(1);
    }

    if (substr($sourceFilename, $sourceFilenameLength - 4) != '.bin') {
        echo(__FILE__.": source file " . $sourceFilename . " does not have required .bin extension, exiting.\n");
        exit(1);
    }

    $hexAddress = substr($sourceFilename, 2, $sourceFilenameLength - 6);
    if (!ctype_xdigit($hexAddress)) {
        echo(__FILE__.": source file " . $sourceFilename . " does not contain a valid hex address in the name, exiting.");
        exit(1);
    }

    $intAddress = hexdec($hexAddress) - 0x70400;

    echo("Writing patch to ".$destinationPath." address ".dechex($intAddress)."\n");

    $sourceFileContents = getFile($sourcePath);
    $destinationFileContents = substr_replace($destinationFileContents, $sourceFileContents, $intAddress);
}

echo("Writing modified file back to ".$destinationPath."...\n");
file_put_contents($destinationPath, $destinationFileContents);
