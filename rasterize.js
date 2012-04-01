#!/usr/bin/env phantomjs

var page = require('webpage').create(),
	address, output, size;

if (phantom.args.length < 1) {
	console.error('Usage: rasterize.js URL [filename]');
	phantom.exit(1);
}

address = phantom.args[0];
if (address.indexOf("://") == -1) address = "http://" + address;

output = phantom.args[1];
if (!output) output = address.substr(address.indexOf("://") + 3).replace(/\//g, "_").replace(/[^a-z0-9\-_\.]/gi, "") + ".png";

page.viewportSize = {
	width: screen.width,
	height: screen.height
};
page.settings.loadPlugins = true;

page.open(address, function(status) {
	if (status !== 'success') {
		console.error('Unable to load the address!');
		phantom.exit(1);
	} else {
		window.setTimeout(function() {
			page.render(output);
			console.log(output);
			phantom.exit();
		}, 500);
	}
});
