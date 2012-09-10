#!/usr/bin/env php
<?php
/**
 * Run PHP_Beautifier with my own custom filters and configuration.
 *
 * @author    Scott Buchanan <buchanan.sc@gmail.com>
 * @copyright 2012 Scott Buchanan
 * @license   http://www.opensource.org/licenses/mit-license.php The MIT License
 * @version   r1 2012-09-09
 * @link      http://wafflesnatcha.github.com
 */

require_once "PHP/Beautifier.php";

class PHP_Beautifier_Filter_Custom extends PHP_Beautifier_Filter
{
	protected $sDescription = "Scott's custom PHP_Beautifier_Filter";
	protected $aSettingsDefinition = array(
		'newline_curly_class' => array('type' => 'bool', 'description' => 'newline before braces on classes'),
		'newline_curly_function' => array('type' => 'bool', 'description' => 'newline before braces on functions'),
		'concat_else_if' => array('type' => 'bool', 'description' => ''),
		'space_after_if' => array('type' => 'bool', 'description' => ''),
		'collapse_empty_curlys' => array('type' => 'bool', 'description' => '')
	);
	protected $aSettings = array(
		'newline_curly_class' => false,
		'newline_curly_function' => false,
		'concat_else_if' => false,
		'space_after_if' => false,
		'collapse_empty_curlys' => true,
	);
	protected $aFilterTokenFunctions = array(
		T_CASE => 't_case',
		T_DEFAULT => 't_case',
		T_DOC_COMMENT => 't_doc_comment',
		T_ELSEIF => 't_elseif',
		T_IF => 't_if',
		
		T_ARRAY_CAST => 't_cast',
		T_BOOL_CAST => 't_cast',
		T_DOUBLE_CAST => 't_cast',
		T_INT_CAST => 't_cast',
		T_OBJECT_CAST => 't_cast',
		T_STRING_CAST => 't_cast',
		T_UNSET_CAST => 't_cast',
	);

	/**
	 * Add spaces after variable cast.
	 * 
	 *     $value = (object) array( "key" => "value" );
	 */
	public function t_cast($sTag)
	{
		$this->oBeaut->add($sTag . " ");
	}

	function t_comment($sTag)
	{
		return PHP_Beautifier_Filter::BYPASS;
		$this->oBeaut->removeWhitespace();
		$this->oBeaut->add($sTag);
		if ($this->oBeaut->getNextTokenContent() == '}') {
			$this->oBeaut->removeWhitespace();
		} else {
			$this->oBeaut->addNewLineIndent();
		}
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
		if ($this->oBeaut->getPreviousTokenContent() == '}') {
			$this->oBeaut->add(' ');
		}
		if (!$this->getSetting('concat_else_if')) $this->oBeaut->add(substr($sTag, 0, 4) . ' ' . substr($sTag, 4));
		else $this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_if')) $this->oBeaut->add(' ');
	}
	function t_open_brace($sTag)
	{
		if ($this->oBeaut->openBraceDontProcess()) {
			$this->oBeaut->add($sTag);
		} else {
			$c = $this->oBeaut->getControlSeq();
			if (($c == T_CLASS && $this->getSetting('newline_curly_class')) || ($c == T_FUNCTION && $this->getSetting('newline_curly_function'))) {
				$this->oBeaut->removeWhitespace();
				$this->oBeaut->addNewLineIndent();
				$this->oBeaut->add($sTag);
				$this->oBeaut->incIndent();
				$this->oBeaut->addNewLineIndent();
			} else return PHP_Beautifier_Filter::BYPASS;
		}
	}
	function t_close_brace($sTag)
	{
		if ($this->oBeaut->getMode('string_index') || $this->oBeaut->getMode('double_quote')) {
			$this->oBeaut->add($sTag);
		} else {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			if ($this->oBeaut->getNextTokenContent() != ",") {
				$this->oBeaut->addNewLineIndent();
			}
		}
	}
	function t_parenthesis_open($sTag)
	{
		$this->oBeaut->add($sTag);
		return true;
		if ($this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->addNewLine();
			$this->oBeaut->incIndent();
			$this->oBeaut->addIndent();
		}
	}
	function t_parenthesis_close($sTag)
	{
		if(in_array($this->oBeaut->getPreviousTokenContent(), array(",", ")", "}"))) {
			// $this->oBeaut->removeWhitespace();
		}
		if ($this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->decIndent();
		}
		$this->oBeaut->add($sTag);
		return;
		if ($this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->decIndent();
			if ($this->oBeaut->getPreviousTokenContent() != '(') {
				$this->oBeaut->addNewLineIndent();
			}
			$this->oBeaut->add($sTag);
		} else $this->oBeaut->add($sTag . ' ');
	}
	function t_comma($sTag)
	{
		if ($this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->add($sTag . $this->oBeaut->getPreviousWhitespace());
		} else return PHP_Beautifier_Filter::BYPASS;
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

// PHP_Beautifier Fiters
$filters = array(
	// 'IndentStyles' => array('style' => 'k&r'), // k&r, allman, gnu, ws
	'DocBlock',
	// 'EqualsAlign',
	'Lowercase', // lowercase all control structures
	// 'ArrayNested',
	// 'NewLines' => array('before' => "", 'after' => "T_NAMESPACE:"),
	// 'phpBB',
	// 'Pear' => array('add_header' => false, 'newline_class' => false, 'newline_function' => false, 'switch_without_indent' => true),
	new PHP_Beautifier_Filter_Custom($pb, array(
		'newline_curly_class' => true,
		'newline_curly_function' => true,
		'nested_array' => false,
		'concat_else_if' => false,
		'space_after_if' => true,
		'collapse_empty_curlys' => true,
	))
);
foreach ($filters as $k => $v) {
	if ($k && is_array($v)) $pb->addFilter($k, $v);
	else $pb->addFilter($v);
}

$text = file_get_contents('php://stdin');
// Convert leading tabs to 4 spaces before filtering
// DocBlockGenerator can't handle leading tabs
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