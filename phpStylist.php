#!/usr/bin/env php -d display_errors=on -d error_reporting=E_ALL|E_STRICT
<?php
/**
 * The contents of this file are subject to the RECIPROCAL PUBLIC LICENSE
 * Version 1.1 ("License"); You may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/rpl1.0.php. Software distributed under the
 * License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,
 * either express or implied.
 *
 * @package phpStylist
 * @author  Mr. Milk (aka Marcelo Leite) <mrmilk@anysoft.com.br>
 * @author  Scott Buchanan <buchanan.sc@gmail.com>
 * @license http://opensource.org/licenses/rpl1.0.php Reciprocal Public License ("RPL") Version 1.1
 * @version 1.0.3
 */

$ps = new phpStylist();
$ps->cli();

class phpStylist
{
	var $version = "1.0.3";

	var $option_groups = array(
		array("Indentation and general formatting"),
		array("Operators", "= .= += -= *= /= &= |= <<< == === != !== > >= < <= - + * / % && || AND OR XOR ? :"),
		array("Functions, classes, and objects", "function, class, interface, abstract, public, protected, private, final, ->, ::"),
		array("Control structures", "if, elseif, else, for, foreach, while, do, switch, break"),
		array("Arrays and concatenation", "array, dot, double arrow =>"),
		array("Comments", "//, #, /* */, /** */"),
	);

	var $options = array(
		// name, description, $option_group, default value
		/*array('add_missing_script_tags', 'Wrap code in <?php ?> if missing', 1, false),*/
		array('indent_size', 'Characters per indentation level', 1, 4),
		array('indent_char', 'Character to indent with', 1, ' '),
		array('keep_redundant_lines', 'Keep redundant lines', 1, false),
		array('space_after_comma', 'Space after comma', 1, false),
		array('space_inside_parentheses', 'Space inside parentheses', 1, false),
		array('space_outside_parentheses', 'Space outside parentheses', 1, false),
		
		array('align_var_assignment', 'Align block +3 assigned variables', 2, false),
		array('space_around_arithmetic', '(- + * / %)', 2, false),
		array('space_around_assignment', '(= .= += -= *= /= <<<)', 2, false),
		array('space_around_colon_question', '(? :)', 2, false),
		array('space_around_comparison', '(== === != !== > >= < <=)', 2, false),
		array('space_around_logical', '(&& || AND OR XOR << >>)', 2, false),
		
		array('line_after_curly_function', 'Blank line below opening bracket', 3, false),
		array('line_before_curly_function', 'Opening bracket on next line', 3, false),
		array('line_before_function', 'Blank line before keyword', 3, false),
		array('space_around_double_colon', '(::)', 3, false),
		array('space_around_obj_operator', '(->)', 3, false),
		
		array('add_missing_braces', 'Add missing brackets to single line structs', 4, false),
		array('else_along_curly', 'Keep else/elseif along with bracket', 4, false),
		array('indent_case', 'Extra indent for "case" and "default"', 4, false),
		array('line_after_break', 'Blank line after case "break"', 4, false),
		array('line_before_curly', 'Opening bracket on next line', 4, false),
		array('space_after_if', 'Space between keyword and opening parentheses', 4, false),
		array('space_inside_for', 'Space between "for" elements', 4, false),
		
		array('align_array_assignment', 'Align block +3 assigned array elements', 5, false),
		array('line_before_array_paren', 'Opening array parentheses on next line', 5, false),
		array('space_around_concat', 'Space around concat elements', 5, false),
		array('space_around_double_arrow', 'Space around double arrow', 5, false),
		array('vertical_array', 'Non-empty arrays as vertical block', 5, false),
		array('vertical_concat', 'Concatenation as vertical block', 5, false),
		
		array('line_after_comment', 'Blank line after single line comments (//)', 6, false),
		array('line_after_comment_multi', 'Blank line after multi-line comment (/*)', 6, false),
		array('line_before_comment', 'Blank line before single line comments (//)', 6, false),
		array('line_before_comment_multi', 'Blank line before multi-line comment (/*)', 6, false),
	);

	var $new_tokens = array(
		"S_ABSTRACT"      => "abstract",
		"S_AT"            => "@",
		"S_CLOSE_BRACKET" => "]",
		"S_CLOSE_CURLY"   => "}",
		"S_CLOSE_PARENTH" => ")",
		"S_COLON"         => ":",
		"S_COMMA"         => ",",
		"S_CONCAT"        => ".",
		"S_DIVIDE"        => "/",
		"S_DOLLAR"        => "$",
		"S_EQUAL"         => "=",
		"S_EXCLAMATION"   => "!",
		"S_FINAL"         => "final",
		"S_INTERFACE"     => "interface",
		"S_IS_GREATER"    => ">",
		"S_IS_SMALLER"    => "<",
		"S_MINUS"         => "-",
		"S_MODULUS"       => "%",
		"S_NAMESPACE"     => "namespace",
		"S_OPEN_BRACKET"  => "[",
		"S_OPEN_CURLY"    => "{",
		"S_OPEN_PARENTH"  => "(",
		"S_PLUS"          => "+",
		"S_PRIVATE"       => "private",
		"S_PROTECTED"     => "protected",
		"S_PUBLIC"        => "public",
		"S_QUESTION"      => "?",
		"S_QUOTE"         => '"',
		"S_REFERENCE"     => "&",
		"S_SEMI_COLON"    => ";",
		"S_TIMES"         => "*",
	);

	var $config;

	var $block_size = 3;

	var $_new_line = "\n";

	var $_indent = 0;

	var $_for_idx = 0;

	var $_code = "";

	var $_log = false;

	var $_pointer = 0;

	var $_tokens = 0;

	function __construct()
	{
		/** Define new tokens */
		foreach($this->new_tokens as $k => $v) {
			if(!defined($k))
				define($k, $v);
		}
		if (defined("T_ML_COMMENT"))
			define("T_DOC_COMMENT", T_ML_COMMENT);
		elseif (defined("T_DOC_COMMENT"))
			define("T_ML_COMMENT", T_DOC_COMMENT);
			
		$this->clearConfig();
	}

	function cli()
	{
		$this->getOptions();
		$f = @$_SERVER['argv'][count($_SERVER['argv']) - 1];
		
		if(!$f || $f == '-' || count($_SERVER['argv']) <= 1)
			$f = "php://stdin";
		echo $this->parseFile($f);
	}

	function clearConfig()
	{
		$this->config = array();
		foreach($this->options as $option) {
			$this->config[$option[0]] = $option[3];
		}
	}

	function getOptions()
	{
		$shortopts = "h";
		$longopts = array("help");

		foreach($this->options as $option) {
			$longopts[] = $option[0] . (!is_bool($option[3])? ":" : "");
		}

		$args = getopt($shortopts, $longopts);

		if(isset($args['help']) || isset($args['h'])) {
			$this->usage();
			exit;
		}

		foreach($args as $k => $v) {
			if(isset($this->config[$k]))
				$this->config[$k] = ($v !== false? $v : true);
		}
	}

	function usage()
	{
		echo "phpStylist.php {$this->version}\n\n";
		echo "Usage: " . basename($_SERVER['argv'][0]) . " [options] [file]\n";

		$col1 = 10;		
		foreach($this->options as $o) {
			if(strlen($o[0]) > $col1)
				$col1 = strlen($o[0]);
		}
		
		for($i = 1; $i <= count($this->option_groups); $i++) {
 			// echo "\n". (($i != 0) ? implode("\n", $this->option_groups[$i-1]) . "\n" : "");
			echo "\n" . $this->option_groups[$i-1][0] . ":\n";
			foreach($this->options as $o) {
				if($o[2] == $i)
					printf(" --%-{$col1}s  %s\n", $o[0], $o[1]);
			}
		}
	}

	function parseFile($file)
	{
		return $this->parse(file_get_contents($file));
	}
	
	function parse($input)
	{
		$in_for = false;
		$in_break = false;
		$in_function = false;
		$in_concat = false;
		$space_after = false;
		$curly_open = false;
		$array_level = 0;
		$arr_parenth = array();
		$switch_level = 0;
		$if_level = 0;
		$if_pending = 0;
		$else_pending = false;
		$if_parenth = array();
		$switch_arr = array();
		$halt_parser = false;
		$after = false;
		$this->_tokens = token_get_all($input);

		foreach ($this->_tokens as $index => $token) {
			list($id, $text) = $this->_token($token);
			$this->_pointer = $index;

			if ($halt_parser && $id != S_QUOTE) {
				$this->_append_code($text, false);
				continue;
			}
			if (substr(phpversion(), 0, 1) == "4" && $id == T_STRING) {
				switch (strtolower(trim($text))) {
					case S_ABSTRACT:
					case S_FINAL:
					case S_INTERFACE:
					case S_PRIVATE:
					case S_PROTECTED:
					case S_PUBLIC:
						$id = T_PUBLIC;
					default:
				}
			}

			switch ($id) {

				case S_OPEN_CURLY:
					$condition = $in_function ? $this->config["line_before_curly_function"] : $this->config["line_before_curly"];
					$this->_set_indent( + 1);
					$this->_append_code((!$condition ? ' ' : $this->_crlf_indent(false, - 1)) . $text . $this->_crlf($this->config["line_after_curly_function"] && $in_function && !$this->_is_token_lf()) . $this->_crlf_indent());
					$in_function = false;
					break;

				case S_CLOSE_CURLY:
					if ($curly_open) {
						$curly_open = false;
						$this->_append_code(trim($text));
					} else {
						if (($in_break || $this->_is_token(S_CLOSE_CURLY)) && $switch_level > 0 && $switch_arr["l" . $switch_level] > 0 && $switch_arr["s" . $switch_level] == $this->_indent - 2) {
							if ($this->config["indent_case"])
								$this->_set_indent( - 1);
							$switch_arr["l" . $switch_level]--;
							$switch_arr["c" . $switch_level]--;
						}
						while ($switch_level > 0 && $switch_arr["l" . $switch_level] == 0 && $this->config["indent_case"]) {
							unset($switch_arr["s" . $switch_level]);
							unset($switch_arr["c" . $switch_level]);
							unset($switch_arr["l" . $switch_level]);
							$switch_level--;
							if ($switch_level > 0)
								$switch_arr["l" . $switch_level]--;
							$this->_set_indent( - 1);
							$this->_append_code($this->_crlf_indent() . $text . $this->_crlf_indent());
							$text = '';
						}
						if ($text != '') {
							$this->_set_indent( - 1);
							$this->_append_code($this->_crlf_indent() . $text . $this->_crlf_indent());
						}
					}
					break;

				case S_SEMI_COLON:
					if (($in_break || $this->_is_token(S_CLOSE_CURLY)) && $switch_level > 0 && $switch_arr["l" . $switch_level] > 0 && $switch_arr["s" . $switch_level] == $this->_indent - 2) {
						if ($this->config["indent_case"])
							$this->_set_indent( - 1);
						$switch_arr["l" . $switch_level]--;
						$switch_arr["c" . $switch_level]--;
					}
					if ($in_concat) {
						$this->_set_indent( - 1);
						$in_concat = false;
					}
					$this->_append_code($text . $this->_crlf($this->config["line_after_break"] && $in_break) . $this->_crlf_indent($in_for));
					while ($if_pending > 0) {
						$text = $this->config["add_missing_braces"] ? "}" : "";
						$this->_set_indent( - 1);
						if ($text != "")
							$this->_append_code($this->_crlf_indent() . $text . $this->_crlf_indent());
						else
							$this->_append_code($this->_crlf_indent());
						$if_pending--;
						if ($this->_is_token(array(T_ELSE, T_ELSEIF)))
							break;
					}
					if ($this->_for_idx == 0)
						$in_for = false;
					$in_break = false;
					$in_function = false;
					break;

				case S_CLOSE_BRACKET:
				case S_OPEN_BRACKET:
					$this->_append_code($text);
					break;

				case S_OPEN_PARENTH:
					if ($if_level > 0)
						$if_parenth["i" . $if_level]++;
					if ($array_level > 0) {
						$arr_parenth["i" . $array_level]++;
						if ($this->_is_token(array(T_ARRAY), true) && !$this->_is_token(S_CLOSE_PARENTH)) {
							$this->_set_indent( + 1);
							$this->_append_code((!$this->config["line_before_array_paren"] ? '' : $this->_crlf_indent(false, - 1)) . $text . $this->_crlf_indent());
							break;
						}
					}
					$this->_append_code($this->_space($this->config["space_outside_parentheses"] || $space_after) . $text . $this->_space($this->config["space_inside_parentheses"]));
					$space_after = false;
					break;

				case S_CLOSE_PARENTH:
					if ($array_level > 0) {
						$arr_parenth["i" . $array_level]--;
						if ($arr_parenth["i" . $array_level] == 0) {
							$comma = substr(trim($this->_code), - 1) != "," && $this->config['vertical_array'] ? "," : "";
							$this->_set_indent( - 1);
							$this->_append_code($comma . $this->_crlf_indent() . $text . $this->_crlf_indent());
							unset($arr_parenth["i" . $array_level]);
							$array_level--;
							break;
						}
					}
					$this->_append_code($this->_space($this->config["space_inside_parentheses"]) . $text . $this->_space($this->config["space_outside_parentheses"]));
					if ($if_level > 0) {
						$if_parenth["i" . $if_level]--;
						if ($if_parenth["i" . $if_level] == 0) {
							if (!$this->_is_token(S_OPEN_CURLY) && !$this->_is_token(S_SEMI_COLON)) {
								$text = $this->config["add_missing_braces"] ? "{" : "";
								$this->_set_indent( + 1);
								$this->_append_code((!$this->config["line_before_curly"] || $text == "" ? ' ' : $this->_crlf_indent(false, - 1)) . $text . $this->_crlf_indent());
								$if_pending++;
							}
							unset($if_parenth["i" . $if_level]);
							$if_level--;
						}
					}
					break;

				case S_COMMA:
					if ($array_level > 0)
						$this->_append_code($text . $this->_crlf_indent($in_for));
					else {
						$this->_append_code($text . $this->_space($this->config["space_after_comma"]));
						if ($this->_is_token(S_OPEN_PARENTH))
							$space_after = $this->config["space_after_comma"];
					}
					break;

				case S_CONCAT:
					$condition = $this->config["space_around_concat"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					if ($this->config["vertical_concat"]) {
						if (!$in_concat) {
							$in_concat = true;
							$this->_set_indent( + 1);
						}
						$this->_append_code($this->_space($condition) . $text . $this->_crlf_indent());
					} else
						$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case S_EQUAL:
				case T_AND_EQUAL:
				case T_CONCAT_EQUAL:
				case T_DIV_EQUAL:
				case T_MINUS_EQUAL:
				case T_MOD_EQUAL:
				case T_MUL_EQUAL:
				case T_OR_EQUAL:
				case T_PLUS_EQUAL:
				case T_SL_EQUAL:
				case T_SR_EQUAL:
				case T_XOR_EQUAL:
					$condition = $this->config["space_around_assignment"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case S_IS_GREATER:
				case S_IS_SMALLER:
				case T_IS_EQUAL:
				case T_IS_GREATER_OR_EQUAL:
				case T_IS_IDENTICAL:
				case T_IS_NOT_EQUAL:
				case T_IS_NOT_IDENTICAL:
				case T_IS_SMALLER_OR_EQUAL:
					$condition = $this->config["space_around_comparison"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case T_BOOLEAN_AND:
				case T_BOOLEAN_OR:
				case T_LOGICAL_AND:
				case T_LOGICAL_OR:
				case T_LOGICAL_XOR:
				case T_SL:
				case T_SR:
					$condition = $this->config["space_around_logical"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case T_DOUBLE_COLON:
					$condition = $this->config["space_around_double_colon"];
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case S_COLON:
					if ($switch_level > 0 && $switch_arr["l" . $switch_level] > 0 && $switch_arr["c" . $switch_level] < $switch_arr["l" . $switch_level]) {
						$switch_arr["c" . $switch_level]++;
						if ($this->config["indent_case"])
							$this->_set_indent( + 1);
						$this->_append_code($text . $this->_crlf_indent());
					} else {
						$condition = $this->config["space_around_colon_question"];
						if ($this->_is_token(S_OPEN_PARENTH))
							$space_after = $condition;
						$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					}
					if (($in_break || $this->_is_token(S_CLOSE_CURLY)) && $switch_level > 0 && $switch_arr["l" . $switch_level] > 0) {
						if ($this->config["indent_case"])
							$this->_set_indent( - 1);
						$switch_arr["l" . $switch_level]--;
						$switch_arr["c" . $switch_level]--;
					}
					break;

				case S_QUESTION:
					$condition = $this->config["space_around_colon_question"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case T_DOUBLE_ARROW:
					$condition = $this->config["space_around_double_arrow"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case S_DIVIDE:
				case S_MINUS:
				case S_MODULUS:
				case S_PLUS:
				case S_TIMES:
					$condition = $this->config["space_around_arithmetic"];
					if ($this->_is_token(S_OPEN_PARENTH))
						$space_after = $condition;
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case T_OBJECT_OPERATOR:
					$condition = $this->config["space_around_obj_operator"];
					$this->_append_code($this->_space($condition) . $text . $this->_space($condition));
					break;

				case T_FOR:
					$in_for = true;
				case T_DO:
				case T_FOREACH:
				case T_IF:
				case T_SWITCH:
				case T_WHILE:
					$space_after = $this->config["space_after_if"];
					$this->_append_code($text . $this->_space($space_after), false);
					if ($id == T_SWITCH) {
						$switch_level++;
						$switch_arr["s" . $switch_level] = $this->_indent;
						$switch_arr["l" . $switch_level] = 0;
						$switch_arr["c" . $switch_level] = 0;
					}
					$if_level++;
					$if_parenth["i" . $if_level] = 0;
					break;

				case T_ABSTRACT:
				case T_CLASS:
				case T_FINAL:
				case T_FUNCTION:
				case T_INTERFACE:
				case T_PRIVATE:
				case T_PROTECTED:
				case T_PUBLIC:
					if (!$in_function) {
						if ($this->config["line_before_function"]) {
							$this->_append_code($this->_crlf($after || !$this->_is_token(array(T_COMMENT, T_ML_COMMENT, T_DOC_COMMENT), true)) . $this->_crlf_indent() . $text . $this->_space());
							$after = false;
						} else
							$this->_append_code($text . $this->_space(), false);
						$in_function = true;
					} else
						$this->_append_code($this->_space() . $text . $this->_space());
					break;

				case T_START_HEREDOC:
					$this->_append_code($this->_space($this->config["space_around_assignment"]) . $text);
					break;

				case T_END_HEREDOC:
					$this->_append_code($this->_crlf() . $text . $this->_crlf_indent());
					break;

				case T_COMMENT:
				case T_DOC_COMMENT:
				case T_ML_COMMENT:
					if (is_array($this->_tokens[$index - 1])) {
						$pad = $this->_tokens[$index - 1][1];
						$i = strlen($pad) - 1;
						$k = "";
						while (substr($pad, $i, 1) != "\n" && substr($pad, $i, 1) != "\r" && $i >= 0) {
							$k .= substr($pad, $i--, 1);
						}
						$text = preg_replace("/\r?\n$k/", $this->_crlf_indent(), $text);
					}
					$after = $id == (T_COMMENT && preg_match("/^\/\//", $text)) ? $this->config["line_after_comment"] : $this->config["line_after_comment_multi"];
					$before = $id == (T_COMMENT && preg_match("/^\/\//", $text)) ? $this->config["line_before_comment"] : $this->config["line_before_comment_multi"];
					if ($prev = $this->_is_token(S_OPEN_CURLY, true, $index, true))
						$before = $before && !$this->_is_token_lf(true, $prev);
					$after = $after && (!$this->_is_token_lf() || !$this->config["keep_redundant_lines"]);
					if ($before)
						$this->_append_code($this->_crlf(!$this->_is_token(array(T_COMMENT), true)) . $this->_crlf_indent() . trim($text) . $this->_crlf($after) . $this->_crlf_indent());
					else
						$this->_append_code(trim($text) . $this->_crlf($after) . $this->_crlf_indent(), false);
					break;

				case T_CURLY_OPEN:
				case T_DOLLAR_OPEN_CURLY_BRACES:
					$curly_open = true;
				case T_BAD_CHARACTER:
				case T_NUM_STRING:
					$this->_append_code(trim($text));
					break;

				case T_AS:
				case T_EXTENDS:
				case T_IMPLEMENTS:
				case T_INSTANCEOF:
					$this->_append_code($this->_space() . $text . $this->_space());
					break;

				case S_DOLLAR:
				case S_REFERENCE:
				case T_DEC:
				case T_INC:
					$this->_append_code(trim($text), false);
					break;

				case T_WHITESPACE:
					$redundant = "";
					if ($this->config["keep_redundant_lines"]) {
						$lines = preg_match_all("/\r\n|\r|\n/", $text, $matches);
						$lines = $lines > 0 ? $lines - 1 : 0;
						$redundant = $lines > 0 ? str_repeat($this->_new_line, $lines) : "";
						$current_indent = $this->_indent();
						if (substr($this->_code, strlen($current_indent) * - 1) == $current_indent && $lines > 0)
							$redundant .= $current_indent;
					}
					if ($this->_is_token(array(T_OPEN_TAG), true))
						$this->_append_code($text, false);
					else
						$this->_append_code($redundant . trim($text), false);
					break;

				case S_QUOTE:
					$this->_append_code($text, false);
					$halt_parser = !$halt_parser;
					break;

				case T_ARRAY:
					if ($this->config["vertical_array"]) {
						$next = $this->_is_token(array(T_DOUBLE_ARROW), true);
						$next |= $this->_is_token(S_EQUAL, true);
						$next |= $array_level > 0;
						if ($next) {
							$next = $this->_is_token(S_OPEN_PARENTH, false, $index, true);
							if ($next)
								$next = !$this->_is_token(S_CLOSE_PARENTH, false, $next);
						}
						if ($next) {
							$array_level++;
							$arr_parenth["i" . $array_level] = 0;
						}
					}
				case S_AT:
				case S_EXCLAMATION:
				case T_CHARACTER:
				case T_CONSTANT_ENCAPSED_STRING:
				case T_ENCAPSED_AND_WHITESPACE:
				case T_OPEN_TAG:
				case T_OPEN_TAG_WITH_ECHO:
				case T_STRING:
				case T_STRING_VARNAME:
				case T_VARIABLE:
					$this->_append_code($text, false);
					break;

				case T_CLOSE_TAG:
					$this->_append_code($text, !$this->_is_token_lf(true));
					break;

				case T_CASE:
				case T_DEFAULT:
					if ($switch_arr["l" . $switch_level] > 0 && $this->config["indent_case"]) {
						$switch_arr["c" . $switch_level]--;
						$this->_set_indent( - 1);
						$this->_append_code($this->_crlf_indent() . $text . $this->_space());
					} else {
						$switch_arr["l" . $switch_level]++;
						$this->_append_code($text . $this->_space(), false);
					}
					break;

				case T_INLINE_HTML:
					$this->_append_code($text, false);
					break;

				case T_BREAK:
				case T_CONTINUE:
					$in_break = true;
				case T_CLASS_C:
				case T_CLONE:
				case T_CONST:
				case T_DECLARE:
				case T_DNUMBER:
				case T_ECHO:
				case T_EMPTY:
				case T_EVAL:
				case T_EXIT:
				case T_FILE:
				case T_FUNC_C:
				case T_GLOBAL:
				case T_INCLUDE:
				case T_INCLUDE_ONCE:
				case T_ISSET:
				case T_LINE:
				case T_LIST:
				case T_LNUMBER:
				case T_NEW:
				case T_PRINT:
				case T_REQUIRE:
				case T_REQUIRE_ONCE:
				case T_RETURN:
				case T_STATIC:
				case T_UNSET:
				case T_VAR:
					$this->_append_code($text . $this->_space(), false);
					break;

				case T_ELSEIF:
					$space_after = $this->config["space_after_if"];
					$added_braces = $this->_is_token(S_SEMI_COLON, true) && $this->config["add_missing_braces"];
					$condition = $this->config['else_along_curly'] && ($this->_is_token(S_CLOSE_CURLY, true) || $added_braces);
					$this->_append_code($this->_space($condition) . $text . $this->_space($space_after), $condition);
					$if_level++;
					$if_parenth["i" . $if_level] = 0;
					break;

				case T_ELSE:
					$added_braces = $this->_is_token(S_SEMI_COLON, true) && $this->config["add_missing_braces"];
					$condition = $this->config['else_along_curly'] && ($this->_is_token(S_CLOSE_CURLY, true) || $added_braces);
					$this->_append_code($this->_space($condition) . $text, $condition);
					if (!$this->_is_token(S_OPEN_CURLY) && !$this->_is_token(array(T_IF))) {
						$text = $this->config["add_missing_braces"] ? "{" : "";
						$this->_set_indent( + 1);
						$this->_append_code((!$this->config["line_before_curly"] || $text == "" ? ' ' : $this->_crlf_indent(false, - 1)) . $text . $this->_crlf_indent());
						$if_pending++;
					}
					break;

				default:
					$this->_append_code($text . ' ', true);
					break;
			}
		}
		return $this->_align_operators();
	}

	private function _align_operators()
	{
		if ($this->config['align_array_assignment'] || $this->config['align_var_assignment'])
			return preg_replace_callback("/<\?.*?\?" . ">/s", array($this, "_parse_block"), $this->_code);
		else
			return $this->_code;
	}
	
	private function _append_code($code = "", $trim = true)
	{
		if ($trim)
			$this->_code = rtrim($this->_code) . $code;
		else
			$this->_code .= $code;
	}

	private function _crlf_indent($in_for = false, $increment = 0)
	{
		if ($in_for) {
			$this->_for_idx++;
			if ($this->_for_idx > 2)
				$this->_for_idx = 0;
		}
		if ($this->_for_idx == 0 || !$in_for)
			return $this->_crlf() . $this->_indent($increment);
		else
			return $this->_space($this->config["space_inside_for"]);
	}

	private function _crlf($true = true)
	{
		return $true ? $this->_new_line : "";
	}

	private function _indent($increment = 0)
	{
		return str_repeat($this->config['indent_char'], ($this->_indent + $increment) * $this->config['indent_size']);
	}

	private function _space($true = true)
	{
		return $true ? " " : "";
	}

	private function _token($token)
	{
		if (is_string($token))
			return array($token, $token);
		else
			return $token;
	}

	private function _set_indent($increment)
	{
		$this->_indent += $increment;
		if ($this->_indent < 0)
			$this->_indent = 0;
	}

	private function _is_token($token, $prev = false, $i = 99999, $idx = false)
	{
		if ($i == 99999)
			$i = $this->_pointer;
		if ($prev)
			while (--$i >= 0 && is_array($this->_tokens[$i]) && $this->_tokens[$i][0] == T_WHITESPACE);
		else
			while (++$i < count($this->_tokens) - 1 && is_array($this->_tokens[$i]) && $this->_tokens[$i][0] == T_WHITESPACE);
		if (isset($this->_tokens[$i]) && is_string($this->_tokens[$i]) && $this->_tokens[$i] == $token)
			return $idx ? $i : true;
		elseif (is_array($token) && is_array($this->_tokens[$i])) {
			if (in_array($this->_tokens[$i][0], $token))
				return $idx ? $i : true;
			elseif ($prev && $this->_tokens[$i][0] == T_OPEN_TAG)
				return $idx ? $i : true;
		}
		return false;
	}

	private function _is_token_lf($prev = false, $i = 99999)
	{
		if ($i == 99999)
			$i = $this->_pointer;
		if ($prev) {
			$count = 0;
			while (--$i >= 0 && is_array($this->_tokens[$i]) && $this->_tokens[$i][0] == T_WHITESPACE && strpos($this->_tokens[$i][1], "\n") === false);
		} else {
			$count = 1;
			while (++$i < count($this->_tokens) && is_array($this->_tokens[$i]) && $this->_tokens[$i][0] == T_WHITESPACE && strpos($this->_tokens[$i][1], "\n") === false);
		}
		if (is_array($this->_tokens[$i]) && preg_match_all("/\r?\n/", $this->_tokens[$i][1], $matches) > $count)
			return true;
		return false;
	}

	private function _pad_operators($found)
	{
		global $quotes;
		$pad_size = 0;
		$result = "";
		$source = explode($this->_new_line, $found[0]);
		$position = array();
		array_pop($source);
		foreach ($source as $k => $line) {
			if (preg_match("/'quote[0-9]+'/", $line)) {
				preg_match_all("/'quote([0-9]+)'/", $line, $holders);
				for ($i = 0; $i < count($holders[1]); $i++) {
					$line = preg_replace("/" . $holders[0][$i] . "/", str_repeat(" ", strlen($quotes[0][$holders[1][$i]])), $line);
				}
			}
			if (strpos($line, "=") > $pad_size)
				$pad_size = strpos($line, "=");
			$position[$k] = strpos($line, "=");
		}
		foreach ($source as $k => $line) {
			$padding = str_repeat(" ", $pad_size - $position[$k]);
			$padded = preg_replace("/^([^=]+?)([\.\+\*\/\-\%]?=)(.*)$/", "\\1{$padding}\\2\\3" . $this->_new_line, $line);
			$result .= $padded;
		}
		return $result;
	}

	private function _parse_block($blocks)
	{
		global $quotes;
		$pad_chars = "";
		$holders = array();
		if ($this->config['align_array_assignment'])
			$pad_chars .= ",";
		if ($this->config['align_var_assignment'])
			$pad_chars .= ";";
		$php_code = $blocks[0];
		preg_match_all("/\/\*.*?\*\/|\/\/[^\n]*|#[^\n]|([\"'])[^\\\\]*?(?:\\\\.[^\\\\]*?)*?\\1/s", $php_code, $quotes);
		$quotes[0] = array_values(array_unique($quotes[0]));
		for ($i = 0; $i < count($quotes[0]); $i++) {
			$patterns[] = "/" . preg_quote($quotes[0][$i], '/') . "/";
			$holders[] = "'quote$i'";
			$quotes[0][$i] = str_replace('\\\\', '\\\\\\\\', $quotes[0][$i]);
		}
		if (count($holders) > 0)
			$php_code = preg_replace($patterns, $holders, $php_code);
		$php_code = preg_replace_callback("/(?:.+=.+[" . $pad_chars . "]\r?\n){" . $this->block_size . ",}/", array($this, "_pad_operators"), $php_code);
		for ($i = count($holders) - 1; $i >= 0; $i--) {
			$holders[$i] = "/" . $holders[$i] . "/";
		}
		if (count($holders) > 0)
			$php_code = preg_replace($holders, $quotes[0], $php_code);
		return $php_code;
	}

}
