#!/usr/bin/env perl
#
# FHTML.PL (for TextMate)
# Copyright (C) 1997 John Watson
# e-mail: john@watson-net.com
#
# modified for TextMate by Ross A. Reyman - 12/2005
# modified again by Scott Buchanan <buchanan.sc@gmail.com> 2012/02/27
# 
# -----About-----
# This Script formats and indents html source code.
# It makes code generated easier to read for humans.
#
# The latest copy of this script and documentation can be obtained from
# http://www.watson-net.com/

# tab settings | how many spaces per tab? Use tabs?
#
if ( $ENV{"TM_SOFT_TABS"} == "YES" ) {
	$usetabs = 0;
	$amount  = $ENV{"TM_TAB_SIZE"};
}
else {
	$usetabs = 1;
	$amount  = 1;
}

# These are the tags that will be formatted. Comment out to taste!
#
$tags = "";
$tags .= "<!DOCTYPE|<html|</html|<body|</body|<head|</head|<title|<meta|<style|</style";
$tags .= "<script|</script";
$tags .= "|<isindex|<link";
$tags .= "|<table|<tr|<th|<td|</tr|</th|</td|</table";
$tags .= "|<caption";
$tags .= "|<style|</style";
$tags .= "|<thead|</thead|<tbody|</tbody";
$tags .= "|<p";
$tags .= "|<blockquote|</blockquote|<hr|<div|</div";
$tags .= "|<img";
$tags .= "|<h1|<h2|<h3|<h4|<h5|<h6";
$tags .= "|<ul|</ul|<ol|</ol|<dl|</dl|<li|<dt|<dd|<dir|</dir|<menu|</menu";
$tags .= "|<map|<area|</map";
$tags .= "|<base";
$tags .= "|<object|<applet|<param|</object|</applet|<embed|</embed";
$tags .= "|<form|</form|<input|<select|<option|</select|<textarea";
$tags .= "|<fieldset|</fieldset|<legend|<label";

# honor EE code as tags
$tags .= "|{embed|{exp:|{/exp:";

# These tags get indented/unindented. Comment out to taste!
#
$tagindent = "";
#$tagindent.= "<html|<body|<head";
$tagindent .= "<body|<head";
$tagindent .= "|<style|<script";
$tagindent .= "|<table|<th|<tr|<td";

#$tagindent .= "|<h1|<h2|<h3|<h4|<h5|<h6";
#$tagindent .= "|<p";
$tagindent .= "|<div|<blockquote";
$tagindent .= "|<select|<form|<option";
$tagindent .= "|<ul|<ol|<dl|<dir|<menu|<map";
$tagindent .= "|<fieldset|<legend|<label";

$tagunindent = "";

#$tagunindent.= "</html|</body|</head";
$tagunindent .= "</body|</head";
$tagunindent .= "|</style|</script";
$tagunindent .= "|</table|</th|</tr|</td";

#$tagunindent .= "|<h1|<h2|<h3|<h4|<h5|<h6";
#$tagunindent .= "|</p";
$tagunindent .= "|</div|</blockquote";
$tagunindent .= "|</select|</form|</option";
$tagunindent .= "|</ul|</ol|</dl|</dir|</menu|</map";
$tagunindent .= "|</fieldset|</legend|</label";

# pass 1 - get selection and plug into array
@lines = ();
@temp  = ();

$x = 1;
while (<>) {
	push @temp, $_;
	$x = $x + 1;
}
splitlines();

# pass 2 - remove tabs, clean up tags
$SCRIPT  = 0;
$COMMENT = 0;
$PRE     = 0;

$temp = '';
foreach (@lines) {
	$SCRIPT  = 0 if ( $line =~ m@(</script|%>|\?>)@ig );
	$COMMENT = 0 if ( $line =~ m@(-->|</comment>|</style>)@ig );
	$PRE     = 0 if ( $line =~ m@</pre>@ig );

	$line = $_;

	$SCRIPT  = 1 if ( $line =~ m@(<script|<%|<\?php)@ig );
	$COMMENT = 1 if ( $line =~ m@(<!--|<comment|<style)@ig );
	$PRE     = 1 if ( $line =~ m@<pre@ig );

	if ( !$SCRIPT && !$COMMENT && !$PRE ) {

		# remove all tabs
		$line =~ s/\t//ig;

		# remove spaces just before or after an angle bracket
		$line =~ s/<\ /</ig;
		$line =~ s/\ >/>/ig;
		if ( $line =~ />$/ ) {
			$temp .= $line;
		}
		else {
			$temp .= $line . " ";
		}
	}
	else {
		$temp .= "\n" . $line . "\n";
	}
}
push @temp, $temp;
splitlines();

$SCRIPT  = 0;
$COMMENT = 0;
$PRE     = 0;

# pass 3 -
foreach (@lines) {
	$SCRIPT  = 0 if ( $line =~ m@(</script|%>|\?>)@ig );
	$COMMENT = 0 if ( $line =~ m@(-->|</comment>|</style>)@ig );
	$PRE     = 0 if ( $line =~ m@</pre>@ig );

	$line = $_;

	$SCRIPT  = 1 if ( $line =~ m@(<script|<%|<\?php)@ig );
	$COMMENT = 1 if ( $line =~ m@(<!--|<comment|<style)@ig );
	$PRE     = 1 if ( $line =~ m@<pre@ig );

	if ( !$SCRIPT && !$COMMENT && !$PRE ) {

		# remove extra whitespace
		$line =~ s/\ {2,}/\ /ig;

		# put tags on new lines
		$line =~ s@($tags)@\n$1@ig;
	}
	push @temp, $line;
}
splitlines();

# pass 4 - indent tags (defined in $tagsindent)
$indent = 0;

$SCRIPT  = 0;
$COMMENT = 0;
$PRE     = 0;

foreach (@lines) {
	$SCRIPT  = 0 if ( $line =~ m@(</script|%>|\?>)@ig );
	$COMMENT = 0 if ( $line =~ m@(-->|</comment>|</style>)@ig );
	$PRE     = 0 if ( $line =~ m@</pre>@ig );

	$line = $_;

	$SCRIPT  = 1 if ( $line =~ m@(<script|<%|<\?php)@ig );
	$COMMENT = 1 if ( $line =~ m@(<!--|<comment|<style)@ig );
	$PRE     = 1 if ( $line =~ m@<pre@ig );

	$spaces = "";
	if ( !$SCRIPT && !$COMMENT && !$PRE ) {

		# remove trailing spaces
		$line =~ s@(\ $)@@ig;

		$indent -= $line =~ s@($tagunindent)@$1@ig;

		$spaces = "";
		for ( $j = 0 ; $j < $indent ; $j++ ) {
			for ( $k = 0 ; $k < $amount ; $k++ ) {
				if ($usetabs) {
					$spaces .= "\t";
				}
				else {
					$spaces .= " ";
				}
			}
		}
	}

	push @temp, $spaces . $line;

	if ( !$SCRIPT && !$COMMENT && !$PRE ) {
		$indent += $line =~ s/($tagindent)/$1/ig;
	}
}
splitlines();

# do it! (send back to TextMate)
foreach (@lines) { print "$_\n"; }

exit;

# sub-routines
sub splitlines {
	@lines = ();

	foreach (@temp) {
		$line = $_;
		if ( $line eq "\n" ) {

			# This preserves blank lines in script and comments.
			push @lines, " ";
		}
		else {
			push @lines, split( /\n/, $line );
		}
	}

	@temp = ();
}