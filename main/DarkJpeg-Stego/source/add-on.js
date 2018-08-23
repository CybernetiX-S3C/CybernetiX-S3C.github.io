
function mime(name) {
	if (!name) return 'application/octet-stream';
	switch (name.split('.').pop().toLowerCase()){
		case 'gif': return 'image/gif';
		case 'png': return 'image/png';
		case 'jpg': case 'jpeg': return 'image/jpeg';
		default: return 'application/octet-stream';
	}
}

function decode(data) {
	var xhr = new XMLHttpRequest();
	xhr.open('GET', data.srcUrl, true);
	xhr.responseType = 'arraybuffer';
	
	xhr.onload = function(event) {
			if (this.status != 200)
				return this.onerror(event);
				
			var URL = window.URL || window.webkitURL,
				dark   = appAPI.resources.get('dark.js');
				blob   = new Blob([dark], {type: 'text/javascript'}),
				worker = new Worker(URL.createObjectURL(blob));

			worker.onmessage = function(event) {
				if (event.data.type == 'error')
					return alert('Oops! ' + event.data.msg + ' :(');
					
				if (event.data.type == 'decode') {
					pass = prompt("Password");
					if (pass === null) return;
					worker.postMessage({action: 'decrypt', pass: pass});
				}
				
				if (event.data.type == 'decrypt') {
					var blob = new Blob([event.data.buffer],
						{type: mime(event.data.name)}),
						url = URL.createObjectURL(blob),
						src = 'data:image/png;base64,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';

					var img = /image/.test(blob.type) ? url : src,
						win = window.open('', '', 'width=600,height=600');
					
					win.document.write('<body style="margin: 0; padding: 0; heigth: 100%; widht: 100%; background-color: #222; display: table;">');
					win.document.write('<div style=\'position: absolute; top: 0; left: 0; color: white; font-family: "Helvetica Neue", Helvetica, Arial, sans-serif; font-size: 16px; padding: 10px;\'>');
					win.document.write(event.data.name + '<br>' + ((blob.size >> 10) + 1) + ' Kb</div>');
					win.document.write('<div style="height: 600px; width: 600px; display: table-cell; vertical-align: middle; text-align: center;">');
					win.document.write('<a href="' + url + '" download="' + event.data.name + '" target="_blank">');
					win.document.write('<img src="' + img + '" style="max-width: 500px; max-height: 500px; min-width: 60px; min-height: 60px; border-radius: 8px; padding: 5px 5px 5px 5px; border: 2px dashed #ccc; cursor: pointer;">');
					win.document.write('</a></div></body>');
					win.focus();
				}
			};
			
			worker.postMessage({
				action: 'decode',
				method: 'auto',
				buffer: this.response
			}, [this.response]);
	};
	
	xhr.onerror = function(event) {
		alert('Oops! Download failed :(');
	};
	
	xhr.send();
}

appAPI.ready(function($) {
    appAPI.contextMenu.add("decode", "darkjpeg", decode, ["image"]);
});
