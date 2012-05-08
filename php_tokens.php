#!/usr/bin/env php
<?php

$file = isset($_SERVER['argv'][1]) ? $_SERVER['argv'][1] : "php://stdin";

$colors = array(
	'line_number' => "\033[32m",
	'token_name' => "\033[33m",
	'token_bracket' => "\033[33m",
	'reset' => "\033[0m"
);

if(! isset($_SERVER['TERM']) || ! ( $_SERVER['TERM'] == "xterm-color" || $_SERVER['TERM'] == "xterm-256color" || ( isset($_SERVER['CLICOLOR']) && $_SERVER['CLICOLOR'] != 0 ))) {
	foreach($colors as &$c) {
		$c = "";
	}
}

$line = 1;
$lines = array();
$current = "";

foreach (token_get_all(file_get_contents($file)) as $t) {
	if(is_array($t) && $t[2] > $line) {
		$lines[$line] = $current;
		$current = "";
		$line = $t[2];
	}

	if (is_array($t)) {
		$word = $colors['token_name'] . token_name($t[0]) . $colors['reset'] . $colors['token_bracket'] . "[" . $colors['reset'] . $t[1] . $colors['token_bracket'] . "]" . $colors['reset'];
	} else
		$word = $t;
	
	$current .= "$word ";
};

foreach ($lines as $k => $v) {
	print "" . $colors['line_number'] . "($k)" . $colors['reset'] . " ".trim($v)."\n";
}