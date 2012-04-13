#!/usr/bin/env php
<?php
/**
 * Generate "lorem ipsum" text.
 * 
 * Based on {@link http://pastebin.com/eA3nsJ83}
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @link      http://wafflesnatcha.github.com
 */

$common = 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';
$word_list = array(
	'lipsum' => array('exercitationem','perferendis','perspiciatis','laborum','eveniet','sunt','iure','nam','nobis','eum','cum','officiis','excepturi','odio','consectetur','quasi','aut','quisquam','vel','eligendi','itaque','non','odit','tempore','quaerat','dignissimos','facilis','neque','nihil','expedita','vitae','vero','ipsum','nisi','animi','cumque','pariatur','velit','modi','natus','iusto','eaque','sequi','illo','sed','ex','et','voluptatibus','tempora','veritatis','ratione','assumenda','incidunt','nostrum','placeat','aliquid','fuga','provident','praesentium','rem','necessitatibus','suscipit','adipisci','quidem','possimus','voluptas','debitis','sint','accusantium','unde','sapiente','voluptate','qui','aspernatur','laudantium','soluta','amet','quo','aliquam','saepe','culpa','libero','ipsa','dicta','reiciendis','nesciunt','doloribus','autem','impedit','minima','maiores','repudiandae','ipsam','obcaecati','ullam','enim','totam','delectus','ducimus','quis','voluptates','dolores','molestiae','harum','dolorem','quia','voluptatem','molestias','magni','distinctio','omnis','illum','dolorum','voluptatum','ea','quas','quam','corporis','quae','blanditiis','atque','deserunt','laboriosam','earum','consequuntur','hic','cupiditate','quibusdam','accusamus','ut','rerum','error','minus','eius','ab','ad','nemo','fugit','officia','at','in','id','quos','reprehenderit','numquam','iste','fugiat','sit','inventore','beatae','repellendus','magnam','recusandae','quod','explicabo','doloremque','aperiam','consequatur','asperiores','commodi','optio','dolor','labore','temporibus','repellat','veniam','architecto','est','esse','mollitia','nulla','a','similique','eos','alias','dolore','tenetur','deleniti','porro','facere','maxime','corrupti'),
	'cosby' => array('bada', 'badum', 'bip', 'bloo', 'bop', 'caw', 'derp', 'dip', 'dum', 'hip', 'ka', 'loo', 'meep', 'mim', 'moom', 'na', 'naw', 'nerp', 'nup', 'pa', 'papa', 'spee', 'squee', 'squoo', 'woobly', 'yee', 'zap', 'zip', 'zoobity', 'zoop', 'zop')
);
$words = $word_list['lipsum'];

/**
 * Returns a randomly generated sentence of lorem ipsum text.
 *
 * The first word is capitalized, and the sentence ends in either a period.
 * Commas are added at random.
 */
function sentence()
{
	global $words;
	$sentence = array();
	for ($section_count = mt_rand(1, 5); $section_count; --$section_count) {
		$section = array();
		foreach (array_rand($words, mt_rand(3, 12)) as $key) 
			$section[] = $words[$key];
		$sentence[] = implode($section, ' ');
	}

	# Convert to sentence case and add end punctuation.
	return ucfirst(implode($sentence, ', ')) . ".";
}

/**
 * Returns a randomly generated paragraph of lorem ipsum text.
 * The paragraph consists of between 1 and 4 sentences, inclusive.
 */
function paragraph()
{
	global $words;
	$paragraph = array();
	for ($sentence_count = mt_rand(2, 4); $sentence_count; --$sentence_count) 
		$paragraph[] = sentence();
	
	return implode($paragraph, ' ');
}

/**
 * Returns a string of `count` lorem ipsum words separated by a single space.
 */
function words()
{
	global $words;
	$output = array();
	for ($x = 0; $x < $count; $x++) {
		$output[] = $words[array_rand($words)];
	}
	return implode($output, ' ');
}

$opts = array(
	'words' => array(
		'short' => 'w:',
		'long' => 'words:',
		'definition' => '-w, --words=NUM',
		'description' => 'output NUM lorem ipsum words separated by a single space',
	),
	'paragraphs' => array(
		'short' => 'p:',
		'long' => 'paragraphs:',
		'definition' => '-p, --paragraphs=NUM',
		'description' => 'output list of NUM paragraphs',
	),
	'common' => array(
		'short' => 'c',
		'long' => 'common',
		'definition' => '-c, --common',
		'description' => 'show the common first paragraph ("Lorem ipsum dolor sit amet...")',
	),
	'type' => array(
		'short' => 't:',
		'long' => 'type:',
		'definition' => '-t, --type=WORDLIST',
		'description' => 'which word list to generate the text from, currently: ' . implode(', ', array_keys($word_list))
	),
);

$short_opts = "";
$long_opts = array();
foreach ($opts as $k => $v) {
	if (isset($v['short'])) 
		$short_opts .= $v['short'];
	if (isset($v['long'])) 
		$long_opts[] = $v['long'];
}

$options = getopt($short_opts, $long_opts);
$result = array();
foreach ($options as $opt_name => $opt_value) {
	foreach ($opts as $def_name => $def_array) {
		if ($opt_name == rtrim($def_array['short'], ':') || $opt_name == rtrim($def_array['long'], ':')) {
			$result[$def_name] = $opt_value;
			continue 2;
		}
	}
}
if(isset($result['type'])) {
	$type = strtolower($result['type']);
	if(array_key_exists($type, $word_list))
		$words = $word_list[$type];
}

if (isset($result['common'])) {
	echo $common."\n";
} elseif ($result['paragraphs']) {
	for ($i = 0; $i < (int) $result['paragraphs']; $i++)
		echo paragraph() . "\n";
} elseif ($result['words']) {
	echo words((int) $result['words']);
} else {
	echo "Usage: " . basename($argv[0]) . " [options]\n\nOptions:\n";
	$lines = array();
	$longest = 0;
	foreach ($opts as $def_name => $def_array) {
		$lines[] = array(
			$def_array['definition'],
			$def_array['description'],
		);
		if (strlen($def_array['definition']) > $longest) 
			$longest = strlen($def_array['definition']);
	}
	
	$longest = ($longest > 0) ? $longest + 2 : 0;
	
	foreach ($lines as $line) {
		$l2 = 79 - $longest;
		$a = explode("\n", wordwrap($line[1], $l2));
		printf(" %-{$longest}s%s\n", $line[0], array_shift($a));
		foreach ($a as $l) {
			printf(" %{$longest}s%s\n", "", array_shift($a));
		}
	}
}
