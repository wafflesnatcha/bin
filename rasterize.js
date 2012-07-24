#!/usr/bin/env phantomjs

var config = {
	'delay': 0.25,
	'width': null,
	'height': null,
	'top': null,
	'left': null,
	'zoom': 1.0
};

var Script = (function () {
	var system = require('system'),
		argv = Array.prototype.slice.call(system.args),
		command = argv.shift(),
		name = command.replace(/^.+?\/([^\/]+)$/, '$1');

	var help = [
		'rasterize.js r1 2012-07-23',
		'Render a webpage into a PDF or PNG using PhantomJS.',
		'',
		'Usage: ' + name + ' [OPTION]... URL [FILE]',
		'',
		'Options:',
		' -d, --delay SECONDS  Time to wait after page load before taking screen shot',
		' -h, --height PIXELS  Viewport height, or if used in conjunction with --top,',
		'                      the output image height',
		' -w, --width PIXELS   Viewport width, or if used in conjunction with --left,',
		'                      the output image width',
		' -x, --left PIXELS    X-position of the screenshot',
		' -y, --top PIXELS     Y-position of the screenshot',
		' -z, --zoom FACTOR    Page zoom factor (1.0 = 100%)',
		'     --debug          Output more information',
		'     --help           Show this help',
		].join('\n');

	function usage() {
		console.log(help);
	}

	var debug = (function () {
		if (argv.indexOf('--debug') < 0) {
			return function () {};
		} else {
			argv.splice(argv.indexOf('--debug'), 1);
			return function () {
				console.log(Array.prototype.slice.call(arguments).join(', '));
			};
		}
	}());

	// Parse command line arguments
	var args = (function () {
		var res = []; // shift off first element (script name)
		while (argv.length > 0) {
			a = argv.shift();
			switch (a) {
			case '--help':
				usage();
				phantom.exit();
				break;
			case '--delay':
			case '-d':
				config.delay = argv.shift();
				break;
			case '--width':
			case '-w':
				config.width = argv.shift();
				break;
			case '--height':
			case '-h':
				config.height = argv.shift();
				break;
			case '--left':
			case '-x':
				config.left = argv.shift();
				break;
			case '--top':
			case '-y':
				config.top = argv.shift();
				break;
			case '--zoom':
			case '-z':
				config.zoom = argv.shift();
				break;
			case '--':
				return res.concat(a, argv);
				break;
			default:
				res.push(a);
			}
		}
		return res;
	}());

	return {
		debug: debug,
		args: args,
		usage: usage
	};
}());

Script.debug(Script.args);

if (Script.args.length < 1) {
	Script.usage();
	phantom.exit(1);
}

var address = Script.args.shift();
if (address.indexOf("://") == -1) {
	address = "http://" + address;
	Script.debug('address: ' + address);
}

var output = Script.args.shift();
if (!output) {
	output = address.substr(address.indexOf("://") + 3).replace(/[^a-z0-9\-_\.]/gi, "_").replace(/^_/, '') + ".png";
	Script.debug('output: ' + output);
}

var page = (function () {
	var page = require('webpage').create(),
		settings = {
			'loadImages': true,
			'loadPlugins': true,
			'webSecurityEnabled': false,
			'localToRemoteUrlAccessEnabled': true,
		};

	for (var prop in settings) {
		if (settings.hasOwnProperty(prop)) {
			page.settings[prop] = settings[prop];
		}
	}

	if (config.left || config.top) {
		page.clipRect = {
			top: config.top || 0,
			left: config.left || 0,
			width: config.width || screen.width,
			height: config.height || screen.height
		};
	} else if (config.width || config.height) {
		page.viewportSize = {
			width: config.width || screen.width,
			height: config.height || screen.height
		};
	}

	page.onConsoleMessage = function (msg) {
		Script.debug.log(msg);
	};

	page.onError = function (msg, trace) {
		Script.debug(msg);
		trace.forEach(function (item) {
			Script.debug('  ', item.file, ':', item.line);
		})
	};

	return page;
}());

var start = Date.now();
page.open(address, function (status) {
	if (status !== 'success') {
		console.error("Unable to load '" + address + "'");
		phantom.exit(1);
	}
	Script.debug('Page loaded ' + (Date.now() - start) + ' msec');
	window.setTimeout(function () {
		page.zoomFactor = config.zoom;
		page.render(output);
		console.log(output);
		phantom.exit();
	}, config.delay * 1000);
});