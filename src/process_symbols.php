<?php

include $argv[1];

foreach ($symbols as $name => $address) {
    echo $name . ' equ ' . $address . "\n";
} 

