#!/usr/bin/env php
<?php
$config = array(
	'templates' => array(
		'brief' => "<%round(current_observation.temp_f)%> degrees. <%current_observation.weather%>.",
		'long' => "<%round(current_observation.temp_f)%> degrees. <%current_observation.weather%>. Wind <%current_observation.wind_string%>. Humidity <%current_observation.relative_humidity%>.",
		'full' => "Temperature: <%round(current_observation.temp_f)%> degrees.\nConditions: <%current_observation.weather%>.\nWind: <%current_observation.wind_string%>.\nHumidity: <%current_observation.relative_humidity%>.",
	),
	'template' => count($_SERVER['argv']) > 1? $_SERVER['argv'][1] : 'brief',
	'url' => 'http://api.wunderground.com/api/<%api.key%>/<%api.features%>/<%api.settings%>/q/<%api.query%>.<%api.output_format%>',
	'api' => array(
		// http://www.wunderground.com/weather/api/d/docs?d=data/index
		'key' => 'e948b447d0c4ecc6',
		'features' => 'conditions/forecast',
		'settings' => 'pws:1/lang:EN',
		'query' => trim(shell_exec('type CoreLocationCLI &>/dev/null && CoreLocationCLI -once | perl -pe \'s/^<([+\-0-9\.]+)\s*,\s*([+\-0-9\.]+).*$/$1,$2/gi;s/\+|//gi\' || echo "autoip"')),
		'output_format' => 'xml', // json, xml
	),
);

function array_value($arr, $key) {
	$fn = array();
	while(preg_match('/^([^\(]+)\((.*)\)$/', $key, $m) == 1) {
		$fn[] = $m[1];
		$key = $m[2];
	}	
	$keys = explode(".", $key);
	foreach ($keys as $k) {
		if (is_array($arr) && isset($arr[$k])) {
			$arr = $arr[$k];
		} else if (is_object($arr) && property_exists($arr, $k)) {
			$arr = $arr->$k;
		} else {
			$arr = null;
			break;
		}
	}
	foreach($fn as $f) {
		switch ($f) {
			case 'round':
				$arr = round($arr);
				break;
		}
	}
	return trim($arr);
}

$url = preg_replace_callback('/<%([^%]+)%>/i', function ($m) {
	global $config;
	return array_value($config, $m[1]);
}, $config['url']);

if (!$res = file_get_contents($url)) {
	exit(2);
}

$xml = simplexml_load_string($res, "SimpleXMLElement", LIBXML_NOCDATA | LIBXML_NOENT);

$output = preg_replace_callback('/<%([^%]+)%>/i', function ($m) {
	global $xml;
	return array_value($xml, $m[1]);
}, $config['templates'][$config['template']]);

echo "$output\n";