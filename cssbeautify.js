#!/usr/bin/env node

var cssbeautify = require("cssbeautify");

var options = {
	indent: '    ',
	openbrace: 'end-of-line'
};

var args = process.argv.slice(2);
while (args.length) {
	switch (args.shift()) {
	case '--indent':
	case '-i':
		options.indent = args.shift();
		break;
	case '--openbrace':
	case '-o':
		options.openbrace = args.shift();
		break;
	case '--help':
	case '-h':
		process.stdout.write('Usage: ' + process.argv[1].replace(/^.*?([^\/]+)$/i, '$1') + ' [-i|--indent STRING] [-o|--openbrace end-of-line|separate-line]\n');
		process.exit();
		break;
	}
}

process.stdin.setEncoding('utf8');
process.stdin.resume();
process.stdin.on('data', function (text) {
	// strip opening and closing <style> tags and re-add them afterwards
	var m, indent = "",
		match = text.match(/^[\n\r]*([ \t]*)(<style[^>]*?>)\s*([\s\S]*?)\s*(<\/style>)([ \t]*)([\n\r]*)$/i),
		output = cssbeautify((match) ? match[3] : text, options);

	if (match) {
		m = process.env.TM_CURRENT_LINE.match(/^([ \t]*).*?<style/m);
		indent = (m) ? m[1] : match[1];
		output = match[2].replace(/^/gm, indent) + "\n" + output.replace(/^(?!$)/gm, indent) + "\n" + match[4].replace(/^/gm, indent) + match[6];
	}

	// remove tabs and spaces on blank lines
	output = output.replace(/^\s*$/gm, '');

	process.stdout.write(output);
});
