#!/usr/bin/env php
<?php
/**
 * Generate "dummy" text.
 *
 * Based on {@link http://pastebin.com/eA3nsJ83}.
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r4 2012-09-05
 * @link      http://wafflesnatcha.github.com
 */
error_reporting(E_ALL & ~E_NOTICE);
require_once ('CLIScript.php');

/**
 * Lipsum generator
 */
abstract class Lipsum
{
	static $_default = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
	static $_lists = array(
		'lipsum' => 'a ac accumsan ad adipiscing aenean aliquam aliquet amet ante aptent arcu at auctor augue bibendum blandit class commodo condimentum congue consectetur consequat conubia convallis cras cubilia cum curabitur curae cursus dapibus diam dictum dictumst dignissim dis dolor donec dui duis egestas eget eleifend elementum elit enim erat eros est et etiam eu euismod facilisi facilisis fames faucibus felis fermentum feugiat fringilla fusce gravida habitant habitasse hac hendrerit himenaeos iaculis id imperdiet in inceptos integer interdum ipsum justo lacinia lacus laoreet lectus leo libero ligula litora lobortis lorem luctus maecenas magna magnis malesuada massa mattis mauris metus mi molestie mollis montes morbi mus nam nascetur natoque nec neque netus nibh nisi nisl non nostra nulla nullam nunc odio orci ornare parturient pellentesque penatibus per pharetra phasellus placerat platea porta porttitor posuere potenti praesent pretium primis proin pulvinar purus quam quis quisque rhoncus ridiculus risus rutrum sagittis sapien scelerisque sed sem semper senectus sit sociis sociosqu sodales sollicitudin suscipit suspendisse taciti tellus tempor tempus tincidunt torquent tortor tristique turpis ullamcorper ultrices ultricies urna ut varius vehicula vel velit venenatis vestibulum vitae vivamus viverra volutpat vulputate',
		'cosby' => 'babity bada badum bibity bip bloo bop cachoo caw coo derp dip dum flibbity hip ka loo meep mim moom na naw nerp nup pa papa spee squee squoo voom woobly yee zam zap zim zip zoobity zoop zop',
	);
	static $_list = 'lipsum';
	static $_separator = array(
		'paragraph' => "\n\n",
		'sentence' => ' ',
		'word' => ' '
	);
	
	/**
	 * Get/set the activate word list
	 *
	 * @param string $list Leave empty to just retreive the word list.
	 * @return array|boolean Returns an array of words, or `false` if $list is invalid.
	 */
	static function wordList($list = null)
	{
		if ($list) {
			$list = strtolower($list);
			if (array_key_exists($list, self::$_lists)) self::$_list = $list;
			else return false;
		}
		$l = & self::$_lists[self::$_list];
		if (!is_array($l)) $l = explode(" ", $l);
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
			$output[] = $words[array_rand($words) ];
		}
		return implode($output, self::$_separator['word']);
	}
}

$script = new CLIScript(array(
	'name' => 'lipsum.php',
	'description' => 'Generate "dummy" text.',
	'usage' => '[OPTION]...',
	'help' => 'Without any options, output will be the common lorem ipsum paragraph ("Lorem ipsum dolor sit amet...").',
	'options' => array(
		'paragraphs' => array(
			'short' => 'p:',
			'long' => 'paragraphs:',
			'usage' => 'NUM',
			'description' => 'Output text in paragraphs',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array('options' => array('min_range' => 1)),
		),
		'sentences' => array(
			'short' => 's:',
			'long' => 'sentences:',
			'usage' => 'NUM',
			'description' => 'Output text in sentences, or when used in conjunction with -p, will define sentences per paragraph.',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array('options' => array('min_range' => 1)),
		),
		'words' => array(
			'short' => 'w:',
			'long' => 'words:',
			'usage' => 'NUM',
			'description' => 'Output NUM words separated by a single space',
			'filter' => FILTER_VALIDATE_INT,
			'filter_options' => array('options' => array('min_range' => 1)),
		),
		'list' => array(
			'short' => 'l:',
			'long' => 'list:',
			'usage' => 'WORDLIST',
			'description' => 'Available words lists: ' . str_replace(Lipsum::$_list, Lipsum::$_list . " (default)", implode(', ', array_keys(Lipsum::$_lists))),
		)
	)
));

$args = $script->parseArgs();

if ($args['list']) {
	if (!Lipsum::wordList($args['list'])) {
		trigger_error('invalid word list');
	}

	// User specified a list but no paragraphs, sentences, or words.
	// Assume they meant `--paragraphs 1`
	if (!array_intersect(array('paragraphs', 'sentences', 'words'), array_keys($args))) {
		$args['paragraphs'] = 1;
	}
}

if ($args['paragraphs'] || $args['sentences']) {
	echo Lipsum::paragraphs($args['paragraphs']? $args['paragraphs'] : 1, $args['sentences']? $args['sentences'] : null) . "\n";
} else if ($args['words']) {
	echo Lipsum::words((int)$args['words']);
} else {
	echo Lipsum::$_default . "\n";
}
