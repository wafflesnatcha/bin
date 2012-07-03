#!/usr/bin/env php
<?php
$file = "php://stdin";

if (array_intersect(array("--html", "-h"), $_SERVER['argv'])) {
	output_html($file);
} else {
	output_console($file);
}

function output_console($file)
{
	$colors = array(
		'line_number' => "\033[32m",
		'token_name' => "\033[33m",
		'token_bracket' => "\033[33m",
		'reset' => "\033[0m",
	);
	if (!array_intersect(array("--color", "-c"), $_SERVER['argv']) || !isset($_SERVER['TERM']) || !($_SERVER['TERM'] == "xterm-color" || $_SERVER['TERM'] == "xterm-256color" || (isset($_SERVER['CLICOLOR']) && $_SERVER['CLICOLOR'] != 0))) {
		foreach ($colors as &$c) {
			$c = "";
		}
	}
	
	$line = 1;
	$lines = array();
	$current = "";
	
	foreach (token_get_all(file_get_contents($file)) as $t) {
		if (is_array($t) && $t[2] > $line) {
			$lines[$line] = $current;
			$current = "";
			$line = $t[2];
		}
		
		if (is_array($t)) {
			$word = $colors['token_name'] . token_name($t[0]) . $colors['reset'] . $colors['token_bracket'] . "[" . $colors['reset'] . $t[1] . $colors['token_bracket'] . "]" . $colors['reset'];
		} else 
			$word = $t;
		
		$current .= "$word ";
	};
	
	foreach ($lines as $k => $v) {
		print "" . $colors['line_number'] . "($k)" . $colors['reset'] . " " . trim($v) . "\n";
	}
}

function output_html($file)
{
	$template = <<<'EOF'
<!DOCTYPE html>
<html lang="en-US">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<meta charset="utf-8">
	<title>%%title%%</title>
	<style type="text/css" media="screen">
	html,body{ margin: 0; padding: 0; }
	body { background: #fff; color: #000; font-family: "Menlo", "Consolas", "DejaVu Sans Mono", "Courier", monospace; font-size: 12px; line-height: normal; }
	#code { margin: 18px 24px; font: inherit; }
	.token { background: #ebebff; padding: 0 1px; margin: 0; box-sizing: border-box; border-right: 1px solid rgba(50,50,50,.1); border-top: 0; border-bottom: 0; }
	.t_whitespace { background: #eee; }
	.t_constant_encapsed_string { background: #ffebf4; }
	.t_comment, .t_doc_comment { background: #e0ffe2; font-style: italic; }
	.token:hover { background: #444; color: #fff; }
	</style>
	<style type="text/css" media="screen">.tipsy{font-size:10px;position:absolute;padding:5px;z-index:100000}.tipsy-inner{background-color:#000;color:#FFF;max-width:200px;padding:5px 8px 4px;text-align:center;border-radius:3px;-moz-border-radius:3px;-webkit-border-radius:3px}.tipsy-arrow{position:absolute;width:0;height:0;line-height:0;border:5px dashed #000}.tipsy-arrow-n{border-bottom-color:#000}.tipsy-arrow-s{border-top-color:#000}.tipsy-arrow-e{border-left-color:#000}.tipsy-arrow-w{border-right-color:#000}.tipsy-n .tipsy-arrow{top:0;left:50%;margin-left:-5px;border-bottom-style:solid;border-top:none;border-left-color:transparent;border-right-color:transparent}.tipsy-nw .tipsy-arrow{top:0;left:10px;border-bottom-style:solid;border-top:none;border-left-color:transparent;border-right-color:transparent}.tipsy-ne .tipsy-arrow{top:0;right:10px;border-bottom-style:solid;border-top:none;border-left-color:transparent;border-right-color:transparent}.tipsy-s .tipsy-arrow{bottom:0;left:50%;margin-left:-5px;border-top-style:solid;border-bottom:none;border-left-color:transparent;border-right-color:transparent}.tipsy-sw .tipsy-arrow{bottom:0;left:10px;border-top-style:solid;border-bottom:none;border-left-color:transparent;border-right-color:transparent}.tipsy-se .tipsy-arrow{bottom:0;right:10px;border-top-style:solid;border-bottom:none;border-left-color:transparent;border-right-color:transparent}.tipsy-e .tipsy-arrow{right:0;top:50%;margin-top:-5px;border-left-style:solid;border-right:none;border-top-color:transparent;border-bottom-color:transparent}.tipsy-w .tipsy-arrow{left:0;top:50%;margin-top:-5px;border-right-style:solid;border-left:none;border-top-color:transparent;border-bottom-color:transparent}</style>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
	<script type="text/javascript">
	// tipsy, facebook style tooltips for jquery
	// version 1.0.0a
	// (c) 2008-2010 jason frame [jason@onehackoranother.com]
	// released under the MIT license
	(function(c){function b(e,d){return(typeof e=="function")?(e.call(d)):e}function a(e,d){this.$element=c(e);this.options=d;this.enabled=true;this.fixTitle()}a.prototype={show:function(){var g=this.getTitle();if(g&&this.enabled){var f=this.tip();f.find(".tipsy-inner")[this.options.html?"html":"text"](g);f[0].className="tipsy";f.remove().css({top:0,left:0,visibility:"hidden",display:"block"}).prependTo(document.body);var j=c.extend({},this.$element.offset(),{width:this.$element[0].offsetWidth,height:this.$element[0].offsetHeight});var d=f[0].offsetWidth,i=f[0].offsetHeight,h=b(this.options.gravity,this.$element[0]);var e;switch(h.charAt(0)){case"n":e={top:j.top+j.height+this.options.offset,left:j.left+j.width/2-d/2};break;case"s":e={top:j.top-i-this.options.offset,left:j.left+j.width/2-d/2};break;case"e":e={top:j.top+j.height/2-i/2,left:j.left-d-this.options.offset};break;case"w":e={top:j.top+j.height/2-i/2,left:j.left+j.width+this.options.offset};break}if(h.length==2){if(h.charAt(1)=="w"){e.left=j.left+j.width/2-15}else{e.left=j.left+j.width/2-d+15}}f.css(e).addClass("tipsy-"+h);f.find(".tipsy-arrow")[0].className="tipsy-arrow tipsy-arrow-"+h.charAt(0);if(this.options.className){f.addClass(b(this.options.className,this.$element[0]))}if(this.options.fade){f.stop().css({opacity:0,display:"block",visibility:"visible"}).animate({opacity:this.options.opacity})}else{f.css({visibility:"visible",opacity:this.options.opacity})}}},hide:function(){if(this.options.fade){this.tip().stop().fadeOut(function(){c(this).remove()})}else{this.tip().remove()}},fixTitle:function(){var d=this.$element;if(d.attr("title")||typeof(d.attr("original-title"))!="string"){d.attr("original-title",d.attr("title")||"").removeAttr("title")}},getTitle:function(){var f,d=this.$element,e=this.options;this.fixTitle();var f,e=this.options;if(typeof e.title=="string"){f=d.attr(e.title=="title"?"original-title":e.title)}else{if(typeof e.title=="function"){f=e.title.call(d[0])}}f=(""+f).replace(/(^\s*|\s*$)/,"");return f||e.fallback},tip:function(){if(!this.$tip){this.$tip=c('<div class="tipsy"></div>').html('<div class="tipsy-arrow"></div><div class="tipsy-inner"></div>')}return this.$tip},validate:function(){if(!this.$element[0].parentNode){this.hide();this.$element=null;this.options=null}},enable:function(){this.enabled=true},disable:function(){this.enabled=false},toggleEnabled:function(){this.enabled=!this.enabled}};c.fn.tipsy=function(h){if(h===true){return this.data("tipsy")}else{if(typeof h=="string"){var j=this.data("tipsy");if(j){j[h]()}return this}}h=c.extend({},c.fn.tipsy.defaults,h);function g(l){var m=c.data(l,"tipsy");if(!m){m=new a(l,c.fn.tipsy.elementOptions(l,h));c.data(l,"tipsy",m)}return m}function k(){var l=g(this);l.hoverState="in";if(h.delayIn==0){l.show()}else{l.fixTitle();setTimeout(function(){if(l.hoverState=="in"){l.show()}},h.delayIn)}}function f(){var l=g(this);l.hoverState="out";if(h.delayOut==0){l.hide()}else{setTimeout(function(){if(l.hoverState=="out"){l.hide()}},h.delayOut)}}if(!h.live){this.each(function(){g(this)})}if(h.trigger!="manual"){var d=h.live?"live":"bind",i=h.trigger=="hover"?"mouseenter":"focus",e=h.trigger=="hover"?"mouseleave":"blur";this[d](i,k)[d](e,f)}return this};c.fn.tipsy.defaults={className:null,delayIn:0,delayOut:0,fade:false,fallback:"",gravity:"n",html:false,live:false,offset:0,opacity:0.8,title:"title",trigger:"hover"};c.fn.tipsy.elementOptions=function(e,d){return c.metadata?c.extend({},d,c(e).metadata()):d};c.fn.tipsy.autoNS=function(){return c(this).offset().top>(c(document).scrollTop()+c(window).height()/2)?"s":"n"};c.fn.tipsy.autoWE=function(){return c(this).offset().left>(c(document).scrollLeft()+c(window).width()/2)?"e":"w"};c.fn.tipsy.autoBounds=function(e,d){return function(){var f={ns:d[0],ew:(d.length>1?d[1]:false)},i=c(document).scrollTop()+e,g=c(document).scrollLeft()+e,h=c(this);if(h.offset().top<i){f.ns="n"}if(h.offset().left<g){f.ew="w"}if(c(window).width()+c(document).scrollLeft()-h.offset().left<e){f.ew="e"}if(c(window).height()+c(document).scrollTop()-h.offset().top<e){f.ns="s"}return f.ns+(f.ew?f.ew:"")}}})(jQuery);
	</script>
	<script type="text/javascript">
	jQuery(function() {
		jQuery().tipsy && $(".token").tipsy({
			delayIn: 0,
			delayOut: 0,
			fade: false,
			fallback: '',
			gravity: 'nw', //$.fn.tipsy.autoWE,
			html: false,
			live: false,
			offset: 0,
			opacity: 1,
			title: 'title',
			trigger: 'hover',
		});
	});
	</script>
</head>
<body>
<pre id="code">%%content%%</pre>
</body>
</html>
EOF;
	
	$content = '';
	
	$tokens = token_get_all(file_get_contents($file));
	for ($i = 0; $i<count($tokens); $i++) {
		$t = $tokens[$i];
		if (is_array($t)) {
			$title = "#" . ($i + 1) . " " . token_name($t[0]);
			$classes = array("token", strtolower(token_name($t[0])));
			$text = $t[1];
		} else {
			$title = null;
			$classes = array("string");
			$text = $t;
		}
		
		$text = htmlspecialchars($text);
		$content .= "<span class=\"" . implode(" ", $classes) . "\"" . ($title ? " title=\"$title\"" : "") . ">$text</span>";
	};
	
	echo str_replace(array('%%title%%', '%%content%%'), array($file, $content), $template);
}
