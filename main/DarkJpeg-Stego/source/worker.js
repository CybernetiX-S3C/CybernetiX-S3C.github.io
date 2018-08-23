
// Copyright (C) 2013 Mikhail Mukovnikov <m.mukovnikov@gmail.com>

// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

"use strict";

var Exception = function (name, message)
{
    this.name = name;
    this.message = message;
    this.prototype = new Error();
    this.prototype.constructor = this;
}

this.onmessage = function (event)
{
    try
    {
        switch (event.data.action)
        {
        case "encrypt":
            new Crypto(event.data.name,
                event.data.buffer, event.data.pass, 0);
            break;

        case "decrypt":
            new Crypto(null, null, event.data.pass, 1);
            break;

        case "encode":
            new JPEGEncoder(event.data.method, event.data.buffer,
                event.data.width, event.data.height);
            break;

        case "decode":
            new JPEGDecoder(event.data.method, event.data.buffer);
            break;
        }
    }
    catch (err)
    {
        postMessage({
            type: 'error',
            name:  err.name,
            msg:   err.message,
        });
    }
}

var Crypto = function (name, buf, pass, dir)
{
    if (dir == 0)
    {
        var idata = new Uint8Array(buf),
            len  = idata.length,
            size = 10 + name.length * 2 + len,
            size = (pass != '') ? 16 * Math.ceil(size / 16) : size,
            odata = new Uint8Array(size),
            k = 0, chr;

        odata[k++] = 0x3;
        odata[k++] = 0x14;
        odata[k++] = 0x15;
        odata[k++] = 0x93;

        odata[k++] = len >> 24;
        odata[k++] = (len >> 16) & 0xFF;
        odata[k++] = (len >> 8) & 0xFF;
        odata[k++] = len & 0xFF;

        odata[k++] = name.length >> 8;
        odata[k++] = name.length & 0xFF;

        for (var i = 0; i < name.length; i++)
        {
            chr = name.charCodeAt(i);
            odata[k++] = chr >> 8;
            odata[k++] = chr & 0xFF;
        }

        for (var i = 0; i < len; i++)
            odata[k++] = idata[i];

        Crypto.prototype.data = (pass != '') ? new AES256(odata, pass, dir) : odata;
        postMessage({type: 'encrypt', size: size});
    }
    else
    {
        var idata = (typeof Crypto.prototype.data !== 'undefined') ?
            Crypto.prototype.data : [], dsize, nsize, name, odata,
            len  = idata.length, k = 0;
            
        if (len == 0)
            throw new Exception('decrypt', "Nothing to decrypt");

        idata = (pass != '') ? new AES256(idata, pass, dir) : idata;
        dsize = (idata[4] << 24) | (idata[5] << 16) | (idata[6] << 8) | idata[7];
        nsize = (idata[8] << 8) | idata[9];

        if (idata[0] != 0x03 || idata[1] != 0x14 ||
            idata[2] != 0x15 || idata[3] != 0x93)
            throw new Exception('decrypt', "Wrong password");

        if (dsize == 0 || nsize == 0)
            throw new Exception('decrypt', "Empty data");

        k = 10;
        name = new Array(nsize);
        for (var i = 0; i < nsize; i++)
        {
            name[i]  = idata[k++] << 8;
            name[i] |= idata[k++];
            name[i]  = String.fromCharCode(name[i]);
        }

        odata = new Uint8Array(dsize);
        for (var i = 0; i < dsize; i++)
            odata[i] = idata[k++];

        postMessage({
            type:  'decrypt',
            name:   name.join(''),
            buffer: odata.buffer,
        }, [odata.buffer]);
    }
}
