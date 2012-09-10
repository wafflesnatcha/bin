<?php
/**
 * Command line script utility
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r3 2012-09-09
 * @link      http://wafflesnatcha.github.com
 */
class CLIScript
{
	var $wrap = 80;
	
	var $options = array();
	
	var $name;
	
	var $description;
	
	function __construct($config)
	{
		set_error_handler(array($this, "errorHandler"), E_USER_NOTICE);
		
		// Attempt to decipher version info from this file's `@version` tag
		if (!isset($config['version'])) {
			$this->version = preg_filter('/.*?\/\*\*.*?[\n\r]+\s*\*\s*@version\s*([^\n\r]+).*/is', '$1', file_get_contents($_SERVER['PHP_SELF']));
		}

		foreach ($config as $k => $v) {
			$this->$k = $v;
		}
		
		// Add -h|--help flag
		if (is_array($this->options) && !array_key_exists("help", $this->options)) {
			$this->options['help'] = array(
				'short' => 'h',
				'long' => 'help',
				'description' => 'Show this help',
			);
		}
	}

	function errorHandler($errno, $errstr, $errfile, $errline, $errcontext)
	{
		error_log(basename($errfile) . ": " . trim($errstr));
		exit($errno);
	}

	function usage()
	{
		echo $this->name . " " . $this->version . "\n";
		echo $this->description ? wordwrap($this->description, $this->wrap) . "\n" : "";
		echo $this->usage? "\nUsage: " . basename($_SERVER['argv'][0]) . " " . $this->usage . "\n": "";
		
		if ($this->options) {
			$lines = array();
			$longest = 0;
			foreach ($this->options as $k => $v) {
				$u = ($v['short'] ? "-" . rtrim($v['short'], ":") . ($v['long'] ? "," : " ") . " " : "    ") . ($v['long'] ? "--" . rtrim($v['long'], ":") . " " : "") . $v['usage'];
				$longest = (strlen($u) > $longest) ? strlen($u) : $longest;
				$lines[] = array($u, $v['description']);
			}
			$longest = ($longest > 0) ? $longest + 2 : 0;

			echo "\nOptions:\n";
			foreach ($lines as $line) {
				printf(" %-{$longest}s%s\n", $line[0], wordwrap($line[1], $this->wrap - 1 - $longest, "\n" . str_repeat(" ", $longest + 1)));
			}
		}

		if ($this->help)
			echo "\n" . wordwrap($this->help, $this->wrap) . "\n";
	}

	function parseArgs()
	{
		$short_opts = "";
		$long_opts = array();

		foreach ($this->options as $k => $v) {
			if (isset($v['short']))
				$short_opts .= $v['short'];
			if (isset($v['long']))
				$long_opts[] = $v['long'];
		}

		$options = getopt($short_opts, $long_opts);
		$args = array();
		foreach ($options as $opt_name => $opt_value) {
			foreach ($this->options as $def_name => $def_arr) {
				if ($opt_name == rtrim($def_arr['short'], ':') || $opt_name == rtrim($def_arr['long'], ':')) {
					if (isset($def_arr['filter']) && !$args[$def_name] = filter_var($opt_value, $def_arr['filter'], $def_arr['filter_options']))
						trigger_error("invalid value for " . $def_name . " '$opt_value' ");
					else
						$args[$def_name] = $opt_value;
					continue 2;
				}
			}
		}

		// Show usage
		if (isset($args['help'])) {
			$this->usage();
			exit;
		}

		return $args;
	}
}
