#!/usr/bin/env php
<?php
/**
 * Strip EXIF data from jpeg images.
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2016 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r1 2016-10-19
 * @link      http://wafflesnatcha.github.com
 */
require_once ('CLIScript.php');

$script = new CLIScript(array(
	'name' => 'strip-exif.php',
	'description' => 'Strip EXIF data from jpeg images',
	'usage' => '[FILE]'
));

$image = array_pop($_SERVER['argv']);

try {   
	$res = imagecreatefromjpeg($image);
	imagejpeg($res);
} catch(Exception $e) {
   	echo 'Exception caught: ',  $e->getMessage(), "\n";
}