#!/usr/bin/env phantomjs --web-security=no

var config = {
	delay: 500,
	width: screen.width,
	height: screen.height
};

function usage() {
	console.log('Usage: rasterize.js [--delay MILLISECONDS] [--height NUM] [--width NUM] URL [FILE]');
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

page.settings.loadPlugins = true;
page.settings.loadImages = true;


page.open(address, function (status) {
	if (status !== 'success') {
		console.error("Unable to load '" + address + "'");
		phantom.exit(1);
	}
	// console.debug('page loaded, waiting ' + config.delay + ' milliseconds...');
	window.setTimeout(function () {
		page.render(output);
		console.log(output);
		phantom.exit();
	}, config.delay);
});