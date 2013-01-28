#!/usr/bin/env php
<?php
/**
 * Run PHP_Beautifier with my own custom filters and configuration.
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r4 2013-01-28
 * @link      http://wafflesnatcha.github.com
 */
require_once "PHP/Beautifier.php";
class CustomFilter extends PHP_Beautifier_Filter
{
	protected $aFilterTokenFunctions = array(
		T_BREAK => 't_break',
		T_CASE => 't_case',
		T_DEFAULT => 't_case',
		T_DOC_COMMENT => 't_doc_comment',
		T_DOUBLE_COLON => 't_double_colon',
		T_ELSEIF => 't_elseif',
		T_FOR => 't_for',
		T_FUNCTION => 't_function',
		T_IF => 't_if',
		T_WHILE => 't_while',
		T_ARRAY_CAST => 't_cast',
		T_BOOL_CAST => 't_cast',
		T_DOUBLE_CAST => 't_cast',
		T_INT_CAST => 't_cast',
		T_OBJECT_CAST => 't_cast',
		T_STRING_CAST => 't_cast',
		T_UNSET_CAST => 't_cast',
	);

	protected $sDescription = "Custom PHP_Beautifier Filter";

	protected $aSettingsDefinition = array(
		'collapse_empty_curlys' => array(
			'type' => 'bool',
			'description' => "Remove all whitespace from inside empty curly braces"
		) ,
		'concat_else_if' => array(
			'type' => 'bool',
			'description' => "Make `else if` into `elseif`"
		) ,
		'newline_curly_class' => array(
			'type' => 'bool',
			'description' => "Newline before opening brace for a class definition"
		) ,
		'newline_curly_function' => array(
			'type' => 'bool',
			'description' => "Newline before opening brace on a function definition"
		) ,
		'space_after_for' => array(
			'type' => 'bool',
			'description' => "Space between `for` and opening parentheses"
		),
		'space_after_if' => array(
			'type' => 'bool',
			'description' => "Space between `if` and opening parentheses"
		) ,
		'space_after_while' => array(
			'type' => 'bool',
			'description' => "Space between `while` and opening parentheses"
		),
		'space_inside_for' => array(
			'type' => 'bool',
			'description' => "Space after semicolons in a `for` expression"
		),
		'switch_indent_case' => array(
			'type' => 'bool',
			'description' => "Indent `case` statements inside a switch/case"
		),
		'array_nested' => array(
			'type' => 'string',
			'description' => <<<'EOF'
Valid values are: `all`, `variables`, `none`, or `ignore`. (default `ignore`)
  all         Nest all arrays
  variables   Don't nest arrays that are part of function calls, or possibly nested in some other control statement..."
  none        Flatten all arrays
  ignore      Ignore arrays, leaving whitespace intact
EOF
		),
	);

	protected $aSettings = array(
		'collapse_empty_curlys' => false,
		'concat_else_if' => true,
		'newline_curly_class' => true,
		'newline_curly_function' => true,
		'space_after_for' => true,
		'space_after_if' => true,
		'space_after_while' => true,
		'space_inside_for' => true,
		'switch_indent_case' => true,
		'array_nested' => 'ignore' // all, variables, none, ignore
	);

	private function restoreWhitespace($sTag)
	{
		$this->oBeaut->removeWhitespace();
		$i = $this->oBeaut->iCount;
		while($t = &$this->oBeaut->getToken(--$i) && is_array($t) && $t[0] == T_WHITESPACE) {
			$this->oBeaut->add(is_array($t) ? $t[1] : $t);
		}
		$this->oBeaut->add($sTag);
		$i = $this->oBeaut->iCount;
		while($t = &$this->oBeaut->getToken(++$i) && is_array($t) && $t[0] == T_WHITESPACE) {
			$this->oBeaut->add(is_array($t) ? $t[1] : $t);
		}
	}

	private function nestedArray($sTag)
	{
		static $nested;
		if (!$nested) $nested = array();
		$setting = $this->getSetting('array_nested');
		if (!$setting || !in_array($setting, array('all', 'variables', 'none'))) {
			return $this->restoreWhitespace($sTag);
		}
		if ($setting == 'none') {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add($sTag);
			return;
		}

		if ($this->oBeaut->getControlParenthesis() != T_ARRAY) return PHP_Beautifier_Filter::BYPASS;

		$token = $this->oBeaut->getToken($this->oBeaut->iCount);

		switch($token) {
			case '(':
				if (!$this->oBeaut->isPreviousTokenConstant(T_ARRAY)) return PHP_Beautifier_Filter::BYPASS;
			case ',':
				if ($setting == 'variables') {
					for($i = 0; $i <= $this->oBeaut->iParenthesis; $i++) {
						if($this->oBeaut->getControlParenthesis($i) != T_ARRAY) {
							return PHP_Beautifier_Filter::BYPASS;
						}
					}
				}
				break;
			case ')':
				if (count($nested) <= 0) return PHP_Beautifier_Filter::BYPASS;
				break;
		}
		
		if ($token == '(') {
			array_push($nested, $token);
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLine();
			$this->oBeaut->incIndent();
			$this->oBeaut->addIndent();
		} else if ($token == ',') {
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLine();
			$this->oBeaut->addIndent();
		} else if ($token == ')') {
			array_pop($nested);
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			if ($this->oBeaut->getPreviousTokenContent() != '(') {
				$this->oBeaut->addNewLine();
				$this->oBeaut->addIndent();
			}
			$this->oBeaut->add($sTag);
		}
	}

	function t_parenthesis_open($sTag)
	{
		return $this->nestedArray($sTag);
	}
	function t_parenthesis_close($sTag)
	{
		return $this->nestedArray($sTag);
	}
	function t_comma($sTag)
	{
		return $this->nestedArray($sTag);
	}
	function t_function($sTag)
	{
		return PHP_Beautifier_Filter::BYPASS;
	}
	function t_break($sTag)
	{
		$this->oBeaut->add($sTag);
	}
	/**
	 * Add spaces after variable cast.
	 * 
	 * <code>
	 *     $value = (object) array( "key" => "value" );
	 * </code>
	 */
	function t_cast($sTag)
	{
		$this->oBeaut->add($sTag . " ");
	}
	function t_comment($sTag)
	{
		return PHP_Beautifier_Filter::BYPASS;

		// $this->oBeaut->removeWhitespace();
		// $this->oBeaut->add($sTag);
		// if ($this->oBeaut->getNextTokenContent() == '}') {
		// 	$this->oBeaut->removeWhitespace();
		// } else {
		// 	$this->oBeaut->addNewLineIndent();
		// }
	}
	function t_doc_comment($sTag)
	{
		if (!$this->oBeaut->isPreviousTokenConstant(T_OPEN_TAG) && !$this->oBeaut->isPreviousTokenConstant(T_COMMENT) && !$this->oBeaut->isPreviousTokenContent('{')) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->addNewLine();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLineIndent();
		} else {
			return PHP_Beautifier_Filter::BYPASS;
		}
	}
	function t_double_colon($sTag)
	{
		$this->oBeaut->removeWhitespace();
		$this->oBeaut->add($sTag);
	}
	function t_for($sTag)
	{
		$this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_for')) $this->oBeaut->add(' ');
	}
	function t_while($sTag)
	{
		$this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_while')) $this->oBeaut->add(' ');
	}
	function t_if($sTag)
	{
		if ($this->oBeaut->isPreviousTokenConstant(T_ELSE)) {
			$this->oBeaut->removeWhitespace();
			if (!$this->getSetting('concat_else_if')) $this->oBeaut->add(' ');
		}
		$this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_if')) $this->oBeaut->add(' ');
	}
	function t_elseif($sTag)
	{
		$this->oBeaut->removeWhitespace();
		if ($this->oBeaut->getPreviousTokenContent() == '}') $this->oBeaut->add(' ');
		if (!$this->getSetting('concat_else_if')) {
			$this->oBeaut->add(substr($sTag, 0, 4) . ' ' . substr($sTag, 4));
		} else {
			$this->oBeaut->add($sTag);
		}
		if ($this->getSetting('space_after_if')) $this->oBeaut->add(' ');
	}

	function t_open_brace($sTag)
	{
		$c = $this->oBeaut->getControlSeq();

		if ($this->oBeaut->openBraceDontProcess()) {
			$this->oBeaut->add($sTag);
		} else if ($this->oBeaut->getNextTokenContent() == '}' && $this->getSetting('collapse_empty_curlys')) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add(' ' . $sTag);
		} else if ($c == T_SWITCH) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->incIndent();
			if($this->getSetting('switch_indent_case')) $this->oBeaut->incIndent();
			$this->oBeaut->add($sTag);
		} else {
			if (($c == T_CLASS && $this->getSetting('newline_curly_class')) || ($c == T_FUNCTION && $this->getSetting('newline_curly_function'))) {
				$this->oBeaut->removeWhitespace();
				$this->oBeaut->addNewLineIndent();
				$this->oBeaut->add($sTag);
				$this->oBeaut->incIndent();
				$this->oBeaut->addNewLineIndent();
			} else {
				return PHP_Beautifier_Filter::BYPASS;
			}
		}
	}
	function t_close_brace($sTag)
	{
		$c = $this->oBeaut->getControlSeq();

		if ($this->oBeaut->getMode('string_index') || $this->oBeaut->getMode('double_quote')) {
			$this->oBeaut->add($sTag);
		} else if ($this->oBeaut->getPreviousTokenContent() == '{' && $this->getSetting('collapse_empty_curlys')) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add($sTag);
		} else if ($c == T_SWITCH) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			if($this->getSetting('switch_indent_case')) $this->oBeaut->decIndent();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLine();
		} else {
			return PHP_Beautifier_Filter::BYPASS;
			}

	}
	function t_semi_colon($sTag)
	{
		if ($this->oBeaut->getControlParenthesis() == T_FOR) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add($sTag . ($this->getSetting('space_inside_for') ? " " : ""));
		} else {
			return PHP_Beautifier_Filter::BYPASS;
		}
	}
}
$pb = new PHP_Beautifier();

// TextMate indent settings (when run from inside TextMate)
if (isset($_SERVER['TM_SOFT_TABS'], $_SERVER['TM_TAB_SIZE']) && $_SERVER['TM_SOFT_TABS'] == "YES") {
	$pb->setIndentChar(" ");
	$pb->setIndentNumber($_SERVER['TM_TAB_SIZE']);
} else {
	$pb->setIndentChar("\t");
	$pb->setIndentNumber(1);
}

$filters = array(
	// 'IndentStyles' => array('style' => 'k&r'), // k&r, allman, gnu, ws
	'DocBlock',
	// 'EqualsAlign',
	'Lowercase', // lowercase all control structures
	// 'ArrayNested',
	// 'NewLines' => array('before' => "", 'after' => "T_NAMESPACE:"),
	// 'phpBB',
	// 'Pear',
	// 'Pear' => array('add_header' => false, 'newline_class' => false, 'newline_function' => false, 'switch_without_indent' => true),
	new CustomFilter($pb)
);
foreach ($filters as $k => $v) {
	if ($k && is_array($v)) $pb->addFilter($k, $v);
	else $pb->addFilter($v);
}
$text = file_get_contents('php://stdin');

// Convert leading tabs to spaces before filtering, DocBlockGenerator can't handle leading tabs
$text = preg_replace_callback("/^[\t ]+/m", function ($m) {
	return preg_replace("/([ ]{0,3}\t|[ ]{4})/", str_repeat(" ", 4), $m[0]);
}, $text);

$pb->setInputString($text);
$pb->setNewLine(PHP_EOL);
$pb->process();
$text = $pb->get();

// Change leading spaces back to tabs or vice versa
$text = preg_replace_callback("/^[\t ]+/m", function ($m) {
	global $pb;
	return preg_replace("/([ ]{0,3}\t|[ ]{4})/", str_repeat($pb->getIndentChar(), $pb->getIndentNumber()), $m[0]);
}, $text);

echo $text;