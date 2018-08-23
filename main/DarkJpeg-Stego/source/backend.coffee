
# Copyright (C) 2013 Mikhail Mukovnikov <m.mukovnikov@gmail.com>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

async = (func) ->
    setTimeout func, 0

abort = ->
    window.aborted = true
    xhr.abort() if 0 < xhr?.readyState < 4

fail = (error, stack) ->
    if @ instanceof fail
        @error = error; @stack = stack; @
    else new fail error, stack

okay = (obj) ->
    obj? && obj not instanceof fail

trace = (stack, debug = false) ->
    level = 0
    node = stack
    console.log '----- traceback -----' if debug
    while node instanceof fail
        item = level: level++, error: node.error
        console.log JSON.stringify item if debug
        node = node.stack
        item.data = node
        console.log "-> #{node}" \
            if typeof node is 'string' and debug         
    console.log '-------- end --------' if debug
    item

imageDataToImageData = (data, width, height, cb) -> async ->
    return cb fail "Bad image data", data if not okay data
    cvs1 = document.createElement 'canvas'
    cvs2 = document.createElement 'canvas'
    cvs1.width = data.width
    cvs1.height = data.height
    cvs2.width = width
    cvs2.height = height
    ctx1 = cvs1.getContext '2d'
    ctx2 = cvs2.getContext '2d'
    ctx1.putImageData data, 0, 0
    ctx2.drawImage cvs1, 0, 0, width, height
    cb ctx2.getImageData 0, 0, width, height

imageToImageData = (image, cb) -> async ->
    return cb fail "Bad image", image if not okay image
    cvs = document.createElement 'canvas'
    cvs.width = image.width
    cvs.height = image.height
    ctx = cvs.getContext '2d'
    ctx.drawImage image, 0, 0
    cb ctx.getImageData 0, 0, cvs.width, cvs.height

dataURLSave = (url, name) ->
    return if not okay url
    URL = window.URL || window.webkitURL
    a = document.createElement 'a'
    [a.href, a.download, a.target] = [url, name, "_blank"]
    event = document.createEvent 'MouseEvent'
    event.initMouseEvent "click", true, true, window, 0,
        event.screenX, event.screenY, event.clientX,
        event.clientY, event.ctrlKey, event.altKey,
        event.shiftKey, event.metaKey, 0, null
    a.dispatchEvent event

dataURLToImage = (url, cb) -> async ->
    return cb fail "Bad URL", url if not okay url
    image = document.createElement 'img'
    image.onload = -> cb image
    image.onerror = -> cb fail "Wrong image format", url
    image.src = url

blobToDataURL = (blob, legacy, cb) -> async ->
    return cb fail "Bad blob", blob if not okay blob
    URL = window.URL || window.webkitURL
    return cb URL.createObjectURL blob if URL and not legacy
    reader = new FileReader
    reader.onload = -> cb @result
    reader.readAsDataURL blob

blobToImageData = (blob, cb) -> async ->
    return cb fail "Bad blob", blob if not okay blob
    await blobToDataURL blob, false, defer url
    await dataURLToImage url, defer ans
    await imageToImageData ans, defer ans
    URL = window.URL || window.webkitURL
    URL.revokeObjectURL url
    cb ans

blobToArrayBuffer = (blob, cb) ->
    return cb fail "Bad blob", blob if not okay blob
    reader = new FileReader
    reader.onload = -> cb @result
    reader.onerror = -> cb fail "File reading error", blob
    reader.readAsArrayBuffer blob

blobRandomName = (blob) ->
    blob?.name = Math.random().toString(36).slice(2) + '.jpg'
    return blob

objectToBlob = (obj, type = 'image/jpeg') ->
    return fail "Bad object", obj if not okay obj
    new Blob [obj.buffer], type: type

objectToImageData = (obj, cb) ->
    blobToImageData objectToBlob(obj), cb

objectToMimeType = (obj) ->
    switch obj?.name?.split('.').pop().toLowerCase()
        when 'gif' then 'image/gif'
        when 'png' then 'image/png'
        when 'jpg', 'jpeg' then 'image/jpeg'
        else 'application/octet-stream'

invokeJSONP = (json, cbm, cb) -> async ->
    @wikicb =
        timeout: setTimeout (-> wikicb.panic()), 15000
        func: (ans) -> clearTimeout wikicb.timeout; cb ans
        panic: -> wikicb.func = (->); \
            cb fail "Wikimedia not responding", JSON.stringify json
    script = document.createElement 'script'
    script.type = 'text/javascript'
    script.src = 'http://commons.wikimedia.org/w/api.php?' +
    'action=query&format=json&callback=wikicb.func&' + $.param(json)
    cbm? type: 'wiki', url: script.src
    $('body').append(script)
    
invokeXHR = (url, cbm, cb) ->
    lastprog = prog = -1
    @xhr = new XMLHttpRequest
    xhr.open 'GET', url, true
    xhr.responseType = 'arraybuffer'
    cbm? type: 'progress', name: 'download', url: url, progress: 0
    xhr.onprogress = (event) ->
        if event.lengthComputable
            prog = 100 * event.loaded / event.total | 0
            prog = 100 if prog > 100
        if prog > lastprog + 9
            lastprog = prog
            cbm? type: 'progress', \
                name: 'download', url: url, progress: prog
    xhr.onabort = -> cb type: 'error', code: -1
    xhr.onerror = -> cb type: 'error', code: @status
    xhr.onload = (event) ->
        return cb type: 'error', code: @status if @status != 200
        return cb type: 'done', buffer: @response
    xhr.send()

fractalRandomData = (iterations) ->
    pointList = {}
    pointList.first = x: 0, y: 1
    lastPoint = x: 1, y: 1
    minY = maxY = 1
    minRatio = 0.33
    pointList.first.next = lastPoint;
    for i in [0...iterations]
        point = pointList.first
        while point.next
            nextPoint = point.next
            ratio = minRatio + Math.random() * (1 - 2 * minRatio)
            newX = point.x + ratio * (nextPoint.x - point.x)
            dx = if ratio < 0.5 then newX - point.x else nextPoint.x - newX
            newY = point.y + ratio * (nextPoint.y - point.y)
            newY += dx * (Math.random() * 2 - 1)
            newPoint = x: newX, y: newY
            minY = newY if newY < minY
            maxY = newY if newY > maxY
            newPoint.next = nextPoint
            point.next = newPoint
            point = nextPoint
    if maxY != minY
        normalizeRate = 1.0 / (maxY - minY)
        point = pointList.first
        while point
            point.y = normalizeRate * (point.y - minY)
            point = point.next
    else
        point = pointList.first
        while point
            point.y = 1
            point = point.next
    return pointList

fractalGradient = (ctx, x0, y0, x1, y1, t, r, g, b, a, v, i) ->
    stopNumber = 0
    zeroAlpha = 0.5 / 255;        
    gradRGB = "rgba(#{r},#{g},#{b},"
    numGradSteps = Math.pow(2, i + 1)
    angle = (1 - 2 * Math.random()) * t
    xm = 0.5 * (x0 + x1)
    ym = 0.5 * (y0 + y1)
    ux = x0 - xm
    uy = y0 - ym
    sinAngle = Math.sin(angle)
    cosAngle = Math.cos(angle)
    vx = cosAngle*ux - sinAngle*uy
    vy = sinAngle*ux + cosAngle*uy
    driftX0 = xm + vx
    driftY0 = ym + vy
    driftX1 = xm - vx
    driftY1 = ym - vy
    grad = ctx.createLinearGradient driftX0, driftY0, driftX1, driftY1     
    gradPoints = fractalRandomData i
    gradFunctionPoint = gradPoints.first
    while gradFunctionPoint
        alpha = a + gradFunctionPoint.y * v
        alpha = 0 if alpha < zeroAlpha
        alpha = 1 if alpha > 1
        grad.addColorStop stopNumber / numGradSteps,
                          gradRGB + alpha + ')'
        gradFunctionPoint = gradFunctionPoint.next
        stopNumber++
    return grad

drawGradient = (hw, cbm, cb) -> async ->
    cvs = document.createElement 'canvas'
    cvs.width = Math.sqrt(hw) * 1.2 + 1 | 0
    cvs.height = Math.sqrt(hw) * (1.0 / 1.2) + 1 | 0
    ctx = cvs.getContext '2d'
    prog = lastprog = 0
    x0 = y0 = 0
    numRects = 12
    w = cvs.width
    h = cvs.height * 2
    xMid = x0 + w / 2.0
    yMid = y0 + h / 2.0
    av = Math.PI / 32.0
    for i in [0...numRects]
        return cb fail "Aborted by user" if @aborted
        [r, g, b] = (Math.random() * 256 | 0 for [0..2])
        ctx.globalCompositeOperation = 'lighter'
        alphaVariation = 2.0 / numRects
        gradRad = 1.1 * h / 2
        gradIterates = 8
        baseAlpha = 0
        ctx.fillStyle = fractalGradient ctx, xMid,
            yMid - gradRad, xMid, yMid + gradRad, av,
            r, g, b, baseAlpha, alphaVariation, gradIterates
        ctx.fillRect x0, y0, w, h
        ctx.globalCompositeOperation = 'destination-over'
        prog = 100 * (i + 1) / numRects | 0
        if prog > lastprog + 9
            lastprog = prog
            cbm? type: 'progress', name: 'generate', progress: prog
    cb ctx.getImageData 0, 0, cvs.width, cvs.height

downloadError = (code) ->
    switch code
        when  -1 then "Download aborted by user"
        when   0 then "Cross-domain request error"
        when 404 then "File not found"
        when 405 then "This is not JPEG"
        when 406 then "Bad URL specified"
        when 503 then "Over Google App Engine quota"
        else "Download error"

downloadWiki = (hw, cbm, cb) -> async ->
    for i in [0..2]
        return cb fail "Aborted by user" if @aborted
        time = new Date().getTime() / 1000 | 0
        min  = 1104537600
        max  = time - 2678400
        time = Math.random() * (max - min) + min | 0
        min  = [hw >> 2, hw >> 5, 100][i]
        max  = [hw, hw << 1, 20971520][i]
        await invokeJSONP list: 'allimages', aisort: 'timestamp', \
            aidir: 'older', aistart: time, aiminsize: min, \
            aimaxsize: max, aiprop: 'url|dimensions|mime', \
            ailimit: 15 * (i + 1), cbm, defer ans
        if ans?.query?.allimages
            res = null
            min = 1 << 30
            for image in ans.query.allimages
                if image.mime == 'image/jpeg' &&
                   hw <= image.width * image.height < min
                    continue if image.width * image.height < 10000
                    min = image.width * image.height
                    res = image
        if okay res
            await invokeXHR res.url, cbm, defer ans
            if ans.type != 'done'
                return cb fail "Wikimedia download error", \
                    fail downloadError(ans.code), res.url
            else return cb ans
    return cb fail "Could not find anything on Wikimedia"

downloadFile = (url, cbm, cb) -> async ->
    urls = ['http://hugs-1.appspot.com/',
            'http://hugs-2.appspot.com/']
    return cb fail "Bad URL", url if not okay url
    url = 'http://' + url if not /:\/\//.test(url)
    for x, i in urls by -1
        urls[i] += btoa(url)
    for x, i in urls by -1
        j = Math.random() * (i + 1) | 0
        [urls[i], urls[j]] = [urls[j], urls[i]]
    for x in [url].concat(urls)
        return cb fail "Aborted by user" if @aborted
        await invokeXHR x, cbm, defer ans
        break if ans.type == 'done'
        cbm type: 'download', url: x, code: ans.code
    if ans?.type != 'done'
        cb fail "File download error", \
            fail downloadError(ans.code), url
    else cb ans

darkExec = (req, cbm, cb) ->
    trans = []
    @dark = new Worker 'build/dark.js' if not dark?
    for key, obj of req
        trans.push obj if obj instanceof ArrayBuffer
        return cb fail "Bad object", obj if not okay obj
    dark.onmessage = (event) ->
        switch event.data.type
            when 'error'
                delete req.buffer if req.buffer?
                cb fail 'Dark.js error: ' + event.data.name, \
                    fail event.data.msg, JSON.stringify req
            when 'progress', 'debug' then cbm? event.data
            else cbm? event.data; cb event.data
    dark.postMessage req, trans

probeContainerQuot = (width, height, limit) ->
    ratio = width / height
    limit = Math.max(100, limit)
    [w, h] = [limit, limit / ratio | 0] if width > height
    [w, h] = [limit * ratio | 0, limit] if height >= width
    return [w, h]

probeContainerSize = (idata, size, cbm, cb) -> async ->
    return cb fail "Bad container", idata if not okay idata
    [w, h] = probeContainerQuot idata.width, idata.height, 100
    for i in [0..5]
        return cb fail "Aborted by user" if @aborted
        await imageDataToImageData idata, w, h, defer ans
        await darkExec action: 'encode', method: 'steg', \
            buffer: ans, width: w, height: h, cbm, defer ans
        return cb fail "Cannot encode", ans if not okay ans
        cbm? type: 'probe', width: w, height: h, \
            rate: 100 * ans.csize / size
        if ans.csize >= size then break
        if w >= idata.width || h >= idata.height then break
        quot = Math.sqrt(size / ans.csize) * 1.4
        [w, h] = [w * quot | 0, h * quot | 0]
        if w > idata.width || h > idata.height
            [w, h] = [idata.width, idata.height]     
    return cb fail "Container too small", ans if ans.csize < size
    imageDataToImageData idata, w, h, cb

probeContainerJoin = (obj, safe, size, cbm, cb) -> async ->
    if obj instanceof ImageData or
       obj instanceof ArrayBuffer
        obj.width ?= 0; obj.height ?= 0; return cb obj
    if obj == 'rand'
        for i in [4, 2, 0]
            return cb fail "Aborted by user" if @aborted
            ssize = Math.max(40000, (size >> 2) << i)
            ssize = Math.min(2 << 20, ssize) if not safe
            await downloadWiki ssize, cbm, defer ans
            await objectToImageData ans, defer ans
            break if okay ans
        if safe && ans?.width * ans?.height >= size * 4
            [w, h] = probeContainerQuot ans.width,
                ans.height, 2 * Math.sqrt(size) | 0
            await imageDataToImageData ans, w, h, defer ans
        return cb ans if okay ans
    size = Math.min(2 << 20, size) if not safe
    drawGradient Math.max(40000, size), cbm, cb

probeContainerSteg = (obj, size, cbm, cb) -> async ->
    if obj instanceof ImageData
        return probeContainerSize obj, size, cbm, cb  
    if obj == 'rand' && size < 2*1024*1024
        ssize = Math.max(40000, size << 4)
        for i in [0..2]
            return cb fail "Aborted by user" if @aborted
            await downloadWiki ssize, cbm, defer ans
            await objectToImageData ans, defer ans
            await probeContainerSize ans, size, cbm, defer ans
            return cb ans if okay ans
            ssize *= 1.5
    ssize = 40000
    for i in [0..7]
        return cb fail "Aborted by user" if @aborted
        await drawGradient ssize, cbm, defer data
        await darkExec action: 'encode', method: 'steg', buffer: data, \
            width: data?.width, height: data?.height, cbm, defer ans
        return cb fail "Cannot encode", ans if not okay ans
        cbm? type: 'probe', width: data.width, height: data.height, \
            rate: 100 * ans.csize / size
        break if ans.csize >= size
        ssize *= 1.2 * size / ans.csize
    return cb data if okay(data) && ans?.csize >= size
    cb fail "Error probing container", obj

processRequest = (dict, cbm, cb) ->
    @aborted = false
    data = dict.data
    pass = dict.pass ? ''
    args = dict.data? && dict.method?
    cbm? type: 'progress', name: 'init', request: dict
    return cb fail "Missing argument", \
        JSON.stringify dict if not args
    return cb fail "Empty password not allowed" \
        if dict.method == 'steg' && pass == ''
    if data != 'rand' && data != 'grad'
        if data not instanceof Blob
            await downloadFile data, cbm, defer data
            data = objectToBlob data    
        if dict.action == 'encode' && dict.method == 'steg'
            await blobToImageData data, defer data
        else await blobToArrayBuffer data, defer data
        return cb fail "Bad data", data if not okay data
    if dict.hide
        if dict.hide instanceof Blob
            await blobToArrayBuffer dict.hide, defer hide
        else return cb fail "Encoding by URL not supported", dict.hide
        return cb fail "Bad data", hide if not okay hide
    if dict.action == 'encode'
        await darkExec action: 'encrypt', name: dict.hide.name, \
            pass: pass, buffer: hide, cbm, defer ans
        return cb fail "Cannot encrypt", ans if not okay ans
        await probeContainerJoin data, dict.safe, \
            ans.size, cbm, defer ans if dict.method != 'steg'
        await probeContainerSteg data, \
            ans.size, cbm, defer ans if dict.method == 'steg'
        await darkExec action: 'encode', \
            method: dict.method, buffer: ans, \
            width: ans?.width, height: ans?.height, cbm, defer ans
        return cb fail "Cannot encode", ans if not okay ans
        return cb blobRandomName objectToBlob ans
    if dict.action == 'decode'
        await darkExec action: 'decode', \
            buffer: data, method: dict.method, cbm, defer ans
        return cb fail "Cannot decode", ans if not okay ans 
        await darkExec action: 'decrypt', pass: pass, cbm, defer ans
        return cb fail "Cannot decrypt", ans if not okay ans
        blob = objectToBlob ans, objectToMimeType ans
        blob.name = ans.name; return cb blob
    return cb fail "Bad action", JSON.stringify dict
