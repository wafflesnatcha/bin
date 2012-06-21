#!/usr/bin/env phantomjs --disk-cache=yes

var config = {
	'delay': 0.5,
	'width': screen.width,
	'height': screen.height,
	'settings': {
		'loadImages': true,
		'loadPlugins': true,
		'webSecurityEnabled': false,
		'localToRemoteUrlAccessEnabled': true,
	}
};

function usage() {
	console.log('Usage: rasterize.js [--delay SECONDS] [--height PIXELS] [--width PIXELS] URL [FILE]');
}

// Parse command line arguments
function parseArgs() {
	var args = Array.prototype.slice.call(phantom.args);
	while (args.length > 0) {
		switch (args[0]) {
		case '--delay':
		case '-d':
			config.delay = args[1];
			args.shift();
			break;
		case '--width':
		case '-w':
			config.width = args[1];
			args.shift();
			break;
		case '--height':
		case '-h':
			config.height = args[1];
			args.shift();
			break;
		case '--help':
			usage();
			phantom.exit();
		default:
			return args;
		}
		args.shift();
	}
	return args;
}

var args = parseArgs();

if (args.length < 1) {
	usage();
	phantom.exit(1);
}

var address = args.shift();
if (address.indexOf("://") == -1) {
	address = "http://" + address;
}

var output = args.shift();
if (!output) {
	output = address.substr(address.indexOf("://") + 3).replace(/[^a-z0-9\-_\.]/gi, "_") + ".png";
}

var page = require('webpage').create()
page.viewportSize = {
	width: config.width,
	height: config.height
};
for(var prop in config.settings) {
	page.settings[prop] = config.settings[prop];
}

page.open(address, function (status) {
	if (status !== 'success') {
		console.error("Unable to load '" + address + "'");
		phantom.exit(1);
	}
	window.setTimeout(function () {
		page.render(output);
		console.log("output: " + output);
		phantom.exit();
	}, config.delay * 1000);
});