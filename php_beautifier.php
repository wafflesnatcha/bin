#!/usr/bin/env php
<?php
set_error_handler(function ($num, $str, $file, $line) {
	file_put_contents("php://stderr", "[" . $file . ":" . $line . "] " . $str . "\n");
});

require_once "PHP/Beautifier.php";

/**
 * My custom PHP_Beautifier_Filter
 */
class PHP_Beautifier_Filter_Custom extends PHP_Beautifier_Filter
{
	/**
     * Description for protected
     */
	protected $aFilterTokenFunctions = array(
		T_DOC_COMMENT => 't_doc_comment',
		T_IF => 't_if',
		T_ELSEIF => 't_elseif',
	);

	/**
     * Filter settings
     */
	protected $aSettings = array(
		'newline_curly_class' => true,
		'newline_curly_function' => true,
		'newline_after_function' => false,
		'switch_without_indent' => false,
		'nested_array' => true,
		'concat_else_if' => false,
		'space_after_if' => true,
		'keep_blank_lines' => true,
	);

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return unknown Return description (if any) ...
     * @access public 
     */
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

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return void   
     * @access public 
     */
	function t_if($sTag)
	{
		if ($this->oBeaut->isPreviousTokenConstant(T_ELSE)) {
			$this->oBeaut->removeWhitespace();
			if (!$this->getSetting('concat_else_if')) $this->oBeaut->add(' ');
		}
		$this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_if')) $this->oBeaut->add(' ');
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return void   
     * @access public 
     */
	function t_elseif($sTag)
	{
		$this->oBeaut->removeWhitespace();
		if ($this->oBeaut->getPreviousTokenContent() == '}') $this->oBeaut->add(' ');
		if (!$this->getSetting('concat_else_if')) $this->oBeaut->add(substr($sTag, 0, 4) . ' ' . substr($sTag, 4));
		else $this->oBeaut->add($sTag);
		if ($this->getSetting('space_after_if')) $this->oBeaut->add(' ');
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  string  $sTag Parameter description (if any) ...
     * @return unknown Return description (if any) ...
     * @access public 
     */
	function t_semi_colon($sTag)
	{
		// A break statement and the next statement are separated by an empty line
		if ($this->oBeaut->isPreviousTokenConstant(T_BREAK)) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add($sTag); // add the semicolon
			$this->oBeaut->addNewLine(); // empty line
			$this->oBeaut->addNewLineIndent();
		} else if ($this->oBeaut->getControlParenthesis() == T_FOR) {
			// The three terms in the head of a for loop are separated by the string "; "
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->add($sTag . " "); // Bug 8327
			
		} else return PHP_Beautifier_Filter::BYPASS;
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  string $sTag Parameter description (if any) ...
     * @return void  
     * @access public
     */
	function t_case($sTag)
	{
		$this->oBeaut->removeWhitespace();
		$this->oBeaut->decIndent();
		if ($this->oBeaut->isPreviousTokenConstant(T_BREAK, 2)) {
			$this->oBeaut->addNewLine();
		}
		$this->oBeaut->addNewLineIndent();
		$this->oBeaut->add($sTag . ' ');
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return void   
     * @access public 
     */
	function t_default($sTag)
	{
		$this->t_case($sTag);
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return void   
     * @access public 
     */
	function t_break($sTag)
	{
		$this->oBeaut->add($sTag);
		if ($this->oBeaut->isNextTokenConstant(T_LNUMBER)) $this->oBeaut->add(' ');
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return unknown Return description (if any) ...
     * @access public 
     */
	function t_open_brace($sTag)
	{
		if ($this->oBeaut->openBraceDontProcess()) {
			$this->oBeaut->add($sTag);
		} else if ($this->oBeaut->getControlSeq() == T_SWITCH && $this->getSetting('switch_without_indent')) {
			$this->oBeaut->add($sTag);
			$this->oBeaut->incIndent();
		} else {
			$bypass = true;
			if ($this->oBeaut->getControlSeq() == T_CLASS && $this->getSetting('newline_curly_class')) {
				$bypass = false;
			}
			if ($this->oBeaut->getControlSeq() == T_FUNCTION && $this->getSetting('newline_curly_function')) {
				$bypass = false;
			}
			if ($bypass) return PHP_Beautifier_Filter::BYPASS;
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			$this->oBeaut->incIndent();
			$this->oBeaut->addNewLineIndent();
		}
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  unknown $sTag Parameter description (if any) ...
     * @return unknown Return description (if any) ...
     * @access public 
     */
	function t_close_brace($sTag)
	{
		if ($this->oBeaut->getMode('string_index') || $this->oBeaut->getMode('double_quote')) {
			$this->oBeaut->add($sTag);
		} else if ($this->oBeaut->getControlSeq() == T_SWITCH && $this->getSetting('switch_without_indent')) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLineIndent();
		} else if ($this->oBeaut->getNextTokenConstant() == ",") {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
		} else if ($this->oBeaut->getControlSeq() == T_FUNCTION && $this->getSetting('newline_after_function')) {
			$this->oBeaut->removeWhitespace();
			$this->oBeaut->decIndent();
			$this->oBeaut->addNewLineIndent();
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLine();
			$this->oBeaut->addNewLineIndent();
		} else return PHP_Beautifier_Filter::BYPASS;
	}

	/** Nested Array stuff */
	function t_parenthesis_open($sTag)
	{
		if (!$this->getSetting('nested_array')) return PHP_Beautifier_Filter::BYPASS;
		$this->oBeaut->add($sTag);
		if ($this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->addNewLine();
			$this->oBeaut->incIndent();
			$this->oBeaut->addIndent();
		}
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  string $sTag Parameter description (if any) ...
     * @return void  
     * @access public
     */
	function t_parenthesis_close($sTag)
	{
		$this->oBeaut->removeWhitespace();
		if ($this->getSetting('nested_array') && $this->oBeaut->getControlParenthesis() == T_ARRAY) {
			$this->oBeaut->decIndent();
			if ($this->oBeaut->getPreviousTokenContent() != '(') {
				$this->oBeaut->addNewLine();
				$this->oBeaut->addIndent();
			}
			$this->oBeaut->add($sTag);
		} else $this->oBeaut->add($sTag . ' ');
	}

	/**
     * Short description for function
     * 
     * Long description (if any) ...
     * 
     * @param  string $sTag Parameter description (if any) ...
     * @return void  
     * @access public
     */
	function t_comma($sTag)
	{
		// $this->oBeaut->add(token_name($this->oBeaut->getControlParenthesis()));
		if (!$this->getSetting('nested_array') || $this->oBeaut->getControlParenthesis() != T_ARRAY) $this->oBeaut->add($sTag . ' ');
		else {
			$this->oBeaut->add($sTag);
			$this->oBeaut->addNewLine();
			$this->oBeaut->addIndent();
		}
	}
}
$pb = new PHP_Beautifier();
$pb->setInputString(file_get_contents('php://stdin'));
$pb->setNewLine("\n");
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
	// 'NewLines' => array(
	// 	'before' => "",
	// 	'after' => ""
	// ),
	// 'ArrayNested',
	// 'Pear' => array(
	// 	'add_header' => false,
	// 	'newline_class' => false,
	// 	'newline_function' => false,
	// 	'switch_without_indent' => true,
	// ),
	// 'phpBB',
	new PHP_Beautifier_Filter_Custom($pb)
);
foreach ($filters as $k => $v) {
	if ($k && is_array($v)) $pb->addFilter($k, $v);
	else $pb->addFilter($v);
}
$pb->process();
$pb->show();
