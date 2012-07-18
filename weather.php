#!/usr/bin/env php
<?php

$config = array(
	'city' => 'Dublin',
	'state' => 'CA',
	'url' => 'http://rss.wunderground.com/auto/rss_full/%%state%%/%%city%%.xml?units=english',
	'say' => '%%temperature%% degrees, %%conditions%%.',
	//'say' => '%%temperature%% degrees, %%conditions%%, %%wind speed%% mile an hour winds, %%humidity%% humidity.',
	'say_command' => '/usr/bin/say'
);

$url = preg_replace_callback('/%%([^%]*)%%/i', function($m) {
	global $config;
	return $config[$m[1]];
}, $config['url']);

if(!$res = file_get_contents($url)) {
	exit;
}
$xml = simplexml_load_string($res, "SimpleXMLElement", LIBXML_NOCDATA | LIBXML_NOENT);
$str = trim(strip_tags($xml->channel->item[0]->description));

$replacements = array(
	'/\bN\b/'   => 'North',
	'/\bNNE\b/' => 'North-northeast',
	'/\bNE\b/'  => 'NorthEast',
	'/\bENE\b/' => 'East-northeast',
	'/\bE\b/'   => 'East',
	'/\bESE\b/' => 'East-southeast',
	'/\bSE\b/'  => 'SouthEast',
	'/\bSSE\b/' => 'South-southeast',
	'/\bS\b/'   => 'South',
	'/\bSSW\b/' => 'South-southwest',
	'/\bSW\b/'  => 'Southwest',
	'/\bWSW\b/' => 'West-southwest',
	'/\bW\b/'   => 'West',
	'/\bWNW\b/' => 'West-northwest',
	'/\bNW\b/'  => 'Northwest',
	'/\bNNW\b/' => 'North-northwest',
	'/(&deg;|°)\s*F\b/i' => ' degrees fahrenheit',
	'/(&deg;|°)\s*C\b/i' => ' degrees celsius',
	'/([0-9\.\s]+)(mph)/i' => '$1 miles per hour',
	'/([0-9\.\s]+)(kph)/i' => '$1 kilometers per hour',
	// '/Wind Direction\:([^\|]+)\|\s*Wind Speed\:\s*([^\|\$\n\r]*)/i' => 'Wind: $1 $2',
	'/[0-9\.]+/i' => function($m) {
		return round($m[0]);
	},
	'/[ \t]{2,}/' => " ",
);

foreach($replacements as $pattern => $replacement) {
	if(is_string($replacement)) {
		if($pattern{0} !== "/")
			$str = str_replace($pattern, $replacement, $str);
		else
			$str = preg_replace($pattern, $replacement, $str);
	} else if (is_callable($replacement)) {
		$str = preg_replace_callback($pattern, $replacement, $str);
	}
}

$arr = explode("|", $str);
$params = array();
foreach($arr as $a) {
	preg_replace_callback('/([^:]+):(.+)/i', function($m) {
		global $params;
		$params[strtolower(trim($m[1]))] = strtolower(trim($m[2]));
	}, $a);
}

$params['wind speed'] = preg_replace_callback('/([0-9\.\s]+)(.*)/i', function($m) {
	global $params;
	$params['wind speed units'] = trim($m[2]);
	return trim($m[1]);
}, $params['wind speed']);

$params['temperature'] = preg_replace_callback('/^(.*?) (degrees .*)$/i', function($m) {
	global $params;
	$params['temperature units'] = trim($m[2]);
	return trim($m[1]);
}, $params['temperature']);

ksort($params);

$say = preg_replace_callback('/%%([^%]*)%%/i', function($m) {
	global $params;
	return $params[$m[1]];
}, $config['say']);

if(isset($config['say_command'])) {
	shell_exec($config['say_command']. ' '. escapeshellarg($say));
} else {
	echo "$say\n";
}
