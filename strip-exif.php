#!/usr/bin/env php
<?php
/**
 * Strip EXIF data from jpeg images.
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2016 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r2 2016-10-26
 * @link      http://wafflesnatcha.github.com
 */
require_once ('CLIScript.php');

$script = new CLIScript(array(
	'name' => 'strip-exif.php',
	'description' => 'Strip EXIF data from jpeg images',
	'usage' => '[FILE]'
));

$args = $script->parseArgs();

if($_SERVER['argc'] <= 1) {
	$script->usage();
	exit;
} else
	array_shift($_SERVER['argv']);

$file = array_pop($_SERVER['argv']);

if(!is_file($file))
	die("No file found\n");

if(exif_imagetype($file) != IMAGETYPE_JPEG)
	die("Not a JPEG image\n");

try {
	$res = imagecreatefromjpeg($file);
	imagejpeg($res);
} catch(Exception $e) {
   	echo 'Exception caught: ',  $e->getMessage(), "\n";
}