#!/usr/bin/env php
<?php
/**
 * Generate "dummy" text.
 *
 * Based on {@link http://pastebin.com/eA3nsJ83}
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r1 2012-05-31
 * @link      http://wafflesnatcha.github.com
 */

/**
 * Command line script utility
 */
class CLIScript
{
	var $wrap = 80;
	
	function __construct($config)
	{
		set_error_handler(array($this, "error_handler"), E_USER_NOTICE);
		foreach ($config as $k => $v) {
			$this->$k = $v;
		}
		// Attempt to decipher version info from this file's `@version` tag
		if (!$this->version)
			$this->version = preg_filter('/.*?\/\*\*.*?[\n\r]+\s*\*\s*@version\s*([^\n\r]+).*/is', '$1', file_get_contents($_SERVER['PHP_SELF']));

		// Add -h|--help flag
		if (is_array($this->options) && !array_key_exists("help", $this->options))
			$this->options['help'] = array(
				'short' => 'h',
				'long' => 'help',
				'usage' => '-h, --help',
				'description' => 'Show this help',
			);
	}

	function error_handler($errno, $errstr, $errfile, $errline)
	{
		error_log(basename($errfile) . ": " . trim($errstr));
		exit($code);
	}

	function usage()
	{
		echo $this->name . " " . $this->version . "\n" . ($this->description ? wordwrap($this->description, $this->wrap) . "\n" : "") . ($this->usage? "\nUsage: " . $this->usage . "\n": "");
		
		if ($this->options) {
			$lines = array();
			$longest = 0;
			foreach ($this->options as $def_name => $def_array) {
				$lines[] = array(
					$def_array['usage'],
					$def_array['description'],
				);
				if (strlen($def_array['usage']) > $longest)
					$longest = strlen($def_array['usage']);
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
		$defs = $this->options;
		$short_opts = "";
		$long_opts = array();

		foreach ($defs as $k => $v) {
			if (isset($v['short']))
				$short_opts .= $v['short'];
			if (isset($v['long']))
				$long_opts[] = $v['long'];
		}

		$options = getopt($short_opts, $long_opts);
		$args = array();
		foreach ($options as $opt_name => $opt_value) {
			foreach ($defs as $def_name => $def_array) {
				if ($opt_name == rtrim($def_array['short'], ':') || $opt_name == rtrim($def_array['long'], ':')) {
					if ($def_array['filter'] && !$args[$def_name] = filter_var($opt_value, $def_array['filter'], $def_array['filter_options']))
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

/**
 * Lipsum generator
 */
abstract class Lipsum
{

	static $_default = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

	static $_list = 'lipsum';

	static $_lists = array(
		'lipsum' => 'a ac accumsan ad adipiscing aenean aliquam aliquet amet ante aptent arcu at auctor augue bibendum blandit class commodo condimentum congue consectetur consequat conubia convallis cras cubilia cum curabitur curae cursus dapibus diam dictum dictumst dignissim dis dolor donec dui duis egestas eget eleifend elementum elit enim erat eros est et etiam eu euismod facilisi facilisis fames faucibus felis fermentum feugiat fringilla fusce gravida habitant habitasse hac hendrerit himenaeos iaculis id imperdiet in inceptos integer interdum ipsum justo lacinia lacus laoreet lectus leo libero ligula litora lobortis lorem luctus maecenas magna magnis malesuada massa mattis mauris metus mi molestie mollis montes morbi mus nam nascetur natoque nec neque netus nibh nisi nisl non nostra nulla nullam nunc odio orci ornare parturient pellentesque penatibus per pharetra phasellus placerat platea porta porttitor posuere potenti praesent pretium primis proin pulvinar purus quam quis quisque rhoncus ridiculus risus rutrum sagittis sapien scelerisque sed sem semper senectus sit sociis sociosqu sodales sollicitudin suscipit suspendisse taciti tellus tempor tempus tincidunt torquent tortor tristique turpis ullamcorper ultrices ultricies urna ut varius vehicula vel velit venenatis vestibulum vitae vivamus viverra volutpat vulputate',
		'cosby' => 'babity bada badum bibity bip bloo bop cachoo caw coo derp dip dum flibbity hip ka loo meep mim moom na naw nerp nup pa papa spee squee squoo voom woobly yee zam zap zim zip zoobity zoop zop',
	);

	static $_separator = array(
		'paragraph' => "\n\n",
		'sentence' => ' ',
		'word' => ' '
	);

	static function wordList($list = null) {
		if(isset($list)) {
			$list = strtolower($list);
			if (array_key_exists($list, self::$_lists))
				self::$_list = $list;
			else
				return false;
		}

		$l = &self::$_lists[self::$_list];
		if (!is_array($l))
			$l = explode(" ", $l);
		return $l;
	}

	/**
	 * Returns a randomly generated sentence.
	 *
	 * The first word is capitalized, and the sentence ends in a period.
	 * Commas are added at random.
	 */
	public static function sentence()
	{
		$words = self::wordList();
		$sentence = array();
		for ($section_count = mt_rand(1, 4); $section_count; --$section_count) {
			$section = array();
			foreach (array_rand($words, mt_rand(3, 12)) as $key) {
				$section[] = $words[$key];
			}
			$sentence[] = implode($section, ' ');
		}

		# Convert to sentence case and add end punctuation.
		return ucfirst(implode($sentence, ', ')) . ".";
	}


	public static function paragraphs($count = 1, $sentences = null)
	{
		$paragraphs = array();
		for ($x = 0; $x < $count; $x++) {
			$p = array();
			$sentences = ($sentences) ? $sentences : mt_rand(3, 5);
			for ($i = 0; $i < $sentences; $i++) {
				$p[] = self::sentence();
			}
			$paragraphs[] = implode($p, self::$_separator['sentence']);
		}
		return implode($paragraphs, self::$_separator['paragraph']);
	}

	/**
	 * Returns a string of `count` lorem ipsum words separated by a single space.
	 */
	public static function words($count)
	{
		$words = self::wordList();
		$output = array();
		for ($x = 0; $x < $count; $x++) {
			$output[] = $words[array_rand($words)];
		}
		return implode($output, self::$_separator['word']);
	}
}

$script = new CLIScript(array(
	'name' => 'lipsum.php',
	'description' => 'Generate "dummy" text.',
	'usage' => basename($_SERVER['argv'][0]) . ' [OPTION]...',
	'help' => 'Without any options, output will be the common lorem ipsum paragraph ("Lorem ipsum dolor sit amet...").',
	'options' => array(
		'paragraphs' => array(
			'short' => 'p:',
			'long' => 'paragraphs:',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array(
				'options' => array(
					'min_range' => 1,
				),
			),
			'usage' => '-p, --paragraphs NUM',
			'description' => 'Output text in paragraphs',
		),
		'sentences' => array(
			'short' => 's:',
			'long' => 'sentences:',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array(
				'options' => array(
					'min_range' => 1,
				),
			),
			'usage' => '-s, --sentences NUM',
			'description' => 'Output text in sentences, or when used in conjunction with -p, will define sentences per paragraph.',
		),
		'words' => array(
			'short' => 'w:',
			'long' => 'words:',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array(
				'options' => array(
					'min_range' => 1,
				),
			),
			'usage' => '-w, --words NUM',
			'description' => 'Output NUM words separated by a single space',
		),
		'list' => array(
			'short' => 'l:',
			'long' => 'list:',
			'usage' => '-l, --list WORDLIST',
			'description' => 'Available words lists: ' . implode(', ', array_keys(Lipsum::$_lists)),
		)
	)
));

$args = $script->parseArgs();

if (isset($args['list'])) {
	if (!Lipsum::wordList($args['list']))
		trigger_error('invalid word list');

	// User specified a list but no paragraphs, sentences, or words
	// Assume they meant --paragraphs 1
	if (!array_intersect(array('paragraphs', 'sentences', 'words'), array_keys($args)))
		$args['paragraphs'] = 1;
}

if (isset($args['paragraphs']) || isset($args['sentences']))
	echo Lipsum::paragraphs($args['paragraphs']? : 1, $args['sentences']? : null) . "\n";
elseif (isset($args['words']))
	echo Lipsum::words((int) $args['words']);
else
	echo Lipsum::$_default . "\n";
