var page = new WebPage(),
    address, output, size;
    
//capture and captureSelector functions adapted from CasperJS - https://github.com/n1k0/casperjs
capture = function(targetFile, clipRect) {
    var previousClipRect;
    var clipRect = {top: 0, left:0, width: 40, height: 40};
    if (clipRect) {
        console.log('Capturing page to ' + targetFile + ' with clipRect' + JSON.stringify(clipRect), "debug");
    } else {
        console.log('Capturing page to ' + targetFile, "debug");
    }
    try {
        page.render(targetFile);
    } catch (e) {
        console.log('Failed to capture screenshot as ' + targetFile + ': ' + e, "error");
    }
    if (previousClipRect) {
        page.clipRect = previousClipRect;
    }
    return this;
}

captureSelector = function(targetFile, selector) {
    var selector = selector;
    return capture(targetFile, page.evaluate(function(selector) {  
        try { 
            var clipRect = document.querySelector(selector).getBoundingClientRect();
            return {
                top: clipRect.top,
                left: clipRect.left,
                width: clipRect.width,
                height: clipRect.height
            };
        } catch (e) {
            console.log("Unable to fetch bounds for element " + selector, "warning");
        }
    }, { selector: selector }));
}

if (phantom.args.length != 2) {
    console.log('Usage: makemaps.js http://example.com/path.html');
    phantom.exit();
} else {
    address = phantom.args[0];
    path = phantom.args[1];
    page.viewportSize = { width: 960, height: 550 };
    //page.paperSize = { width: 400, height: 300, border: '0px' }
    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address!');
        } else {
            captureSelector(path, '#netmap');
            phantom.exit();
        }
    });
}
