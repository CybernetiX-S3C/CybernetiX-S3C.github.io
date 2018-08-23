
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

global = 
    optAction: null, fileData: null, dropDown:  null,
    optMethod: null, fileJpeg: null, dropTimer: null,
    optData:   null, prvData:  null, dropTarg:  null,
    optJpeg:   null, prvJpeg:  null, 
    optSafe:   null,
    optPass:   null

testBrowser = (error) ->
    nav = navigator.appName
    ua  = navigator.userAgent
    ans = ua.match /(opera|chrome|safari|firefox|msie)\/?\s*(\.?\d+(\d+)*)/i
    tem = ua.match /version\/([\d]+)/i if ans?
    ans[2] = tem[1] if tem?
    ans = [ans[1], parseInt ans[2]] if ans?
    ans = [nav, navigator.appVersion] if not ans?
    if ans[0] == 'Safari' and ans[1] > 5  or
       ans[0] == 'Chrome' and ans[1] > 24  or
       ans[0] == 'Firefox' and ans[1] > 16
        return true
    window.location.replace error

eventVoid = (event) ->
    event.stopPropagation()
    event.preventDefault()

controlAbort = (event) ->
    if event.which == 27
        eventVoid event
        return abort()

controlDrop = (event) ->
    eventVoid event
    return if global.fileData
    dataTransfer = event.dataTransfer
    if dataTransfer?.files
        for file in dataTransfer.files
            global.fileData = file
            return $('form').submit()

controlFile = ->
    $('<input type="file">').click().change ->
        if @files?.length > 0
            global.fileData = @files[0]
            $('form').submit()

controlPreview = (file, key) -> async ->
    global[key] = null
    return if not file or not /image/.test file.type
    await blobToImageData file, defer ans
    [w, h] = probeContainerQuot ans?.width, ans?.height, 150
    await imageDataToImageData ans, w, h, defer ans
    return if not okay ans
    cvs = document.createElement 'canvas'
    cvs.width = ans.width
    cvs.height = ans.height
    ctx = cvs.getContext '2d'
    ctx.putImageData ans, 0, 0
    await dataURLToImage cvs.toDataURL(), defer image
    global[key] = image if okay image

controlColor = (obj, delta) ->
    color = obj.css('background-color')
    color = color.match /rgb\(([\d]+), ([\d]+), ([\d]+)\)/
    return if not color
    color[1] = parseInt(color[1]) + delta
    color[2] = parseInt(color[2]) + delta
    color[3] = parseInt(color[3]) + delta
    color = "rgb(#{color[1]}, #{color[2]}, #{color[3]})"
    obj.css('background-color', color)
    obj.next().css('border-left-color', color) \
        if /ctr-from/.test obj.next().attr('class')
    obj.prev().css('border-top-color', color)
        .css('border-bottom-color', color) \
        if /ctr-to/.test obj.prev().attr('class')

controlAdd = (cls, text, cb) ->
    return $('<div>').addClass(cls).appendTo('#control') if !text
    $('<div>')
        .html(text)
        .addClass('ctr-float ' + cls)
        .appendTo($('#control'))
        .mouseenter(-> controlColor $(this), -30)
        .mouseleave(-> controlColor $(this), +30)
        .click(cb, controlDown)

controlRefresh = ->
    offset = $('#control div.ctr-float:last').position()?.left | 0
    $('input').css('padding-left', 10 + offset)
    $('input').css('width', 410 - offset)

controlInput = (type, val) ->
    keypress = (event) ->
        input = $(event.target)
        if event.which == 13 and type != 'password' and
           (input.val() == val or input.val() == '')
            controlFile(); return eventVoid event
        if input.prop('type') != type
            input.removeAttr('type').prop('type', type).val('')
            input.focus().select()
    blur = (input) ->
        if input.val() == ''
            input.removeAttr('type').prop('type', 'text').val(val)
    paste = (input) ->
        if input.prop('type') == 'text'
            setTimeout (-> $('form').submit()), 100
    $('input')
        .clone().val(val).attr('type', 'text')
        .keypress(keypress)
        .blur(-> blur $(this))
        .click(-> $(this).select())
        .on('paste', -> paste $(this))
        .on('drop', controlDrop)
        .insertBefore($('input'))
        .focus().select().next().remove()

controlDown = (event) ->
    remove = ->
        global.dropDown.remove() if global.dropDown
        global.dropDown = null
    clear = ->
        clearTimeout global.dropTimer if global.dropTimer
        global.dropTimer = global.dropTarg = null
    timeout = ->
        clear(); global.dropDown?.fadeOut(200).queue(remove)
    set = ->
        clear(); global.dropTimer = setTimeout timeout, 3000
    return timeout() if global.dropTarg == event.target
    return event.data($(event.target)) && timeout() \
        if event.data == controlAction
    remove() || set()
    html = $('<div>').addClass('drop-arrow').add \
           $('<div>').addClass('drop-content').html \
           event.data $(event.target)
    global.dropTarg = event.target
    global.dropDown = $('<div>')
        .html(html)
        .css('position', 'absolute')
        .css('top', event.pageY + 20)
        .css('left', event.pageX - 75)
        .mouseenter(clear).mouseleave(set)
        .click(timeout).appendTo('body')
        .hide().fadeIn(200)

controlAction = (ctr) ->
    set = (action) ->
        return if action == global.optAction
        if action == 'decode'
            $('.ctr-color-3').addClass('ctr-stop')
            $('.ctr-color-4').remove()
            return $('.ctr-to-4').remove()
        $('.ctr-color-3').removeClass('ctr-stop').next().remove()
        controlAdd 'ctr-from-3 ctr-to-4', null, null
        controlAdd 'ctr-color-4 ctr-stop', global.optJpeg, controlJpeg
        controlAdd 'ctr-float', null, null
    return if global.optData != 'file'
    action = 'encode' if global.optAction == 'decode'
    action = 'decode' if global.optAction == 'encode'
    if action == 'encode'
        $('.ctr-color-3').removeClass('ctr-stop').next().remove()
        controlAdd 'ctr-from-3 ctr-to-4', null, null
        controlAdd 'ctr-color-4 ctr-stop', global.optJpeg, controlJpeg
        controlAdd 'ctr-float', null, null
    else $('.ctr-color-3').addClass('ctr-stop'); \
         $('.ctr-color-4').remove(); $('.ctr-to-4').remove()
    global.optAction = action
    ctr.html(action); controlRefresh()

controlMethod = (ctr) ->
    check = (obj, text) ->
        obj.html(text)
        'checked' if text == global.optMethod 
    click = (event) ->
        global.optMethod = event.target.textContent
        ctr.html event.target.textContent
        controlRefresh()
    checkS = (obj, text) ->
        obj.html(text)
        'checked' if not global.optSafe
    clickS = (event) ->
        global.optSafe = !global.optSafe; true
    [a, b, c, d] = [$('<li>'), $('<li>'), $('<li>'), $('<li>')]
    a.click(click).addClass(check(a, 'auto'))
    b.click(click).addClass(check(b, 'join'))
    c.click(click).addClass(check(c, 'steg'))
    d.click(clickS).addClass(checkS(d, 'unsafe'))
    $('<ul>').append a.add b.add c.add $('<hr>').add d

controlData = (ctr) ->
    ul = $('<ul>')
    click = -> controlInit controlProcess
    if global.prvData
        ul.append $(global.prvData)
    if global.optData == 'file'
        ul.append $('<li>').html(global.fileData.name).add \
        $('<li>').html((global.fileData.size >> 10) + " Kb")
    else ul.append $('<li>').html(global.fileData)
    ul.append $('<hr>').add $('<li>').click(click).html('reset')

controlJpeg = (ctr) ->
    check = (obj, text) ->
        obj.html(text)
        'checked' if text == global.optJpeg
    input = '<input type="file" accept="image/*">'
    file = -> $(input).click().change ->
        return if @files?.length == 0
        return if not /image/.test @files[0].type
        global.fileJpeg = @files[0]
        controlPreview @files[0], 'prvJpeg'
        global.optJpeg = 'image'
        ctr.html 'image'
        controlRefresh()  
    click = (event) ->
        selected = event.target.textContent
        selected = 'rand' if selected == 'image'
        global.optJpeg = selected
        ctr.html selected
        controlRefresh()
        global.fileJpeg = global.prvJpeg = null
        file() if event.target.textContent == 'image'    
    [a, b, c, ul] = [$('<li>'), $('<li>'), $('<li>'), $('<ul>')]
    if global.prvJpeg
        ul.append \
        $(global.prvJpeg).add \
        $('<li>').html(global.fileJpeg.name).add \
        $('<li>').html((global.fileJpeg.size >> 10) + ' Kb').add \
        $('<hr>')
    a.click(click).addClass(check(a, 'rand'))
    b.click(click).addClass(check(b, 'grad'))
    c.click(click).addClass(check(c, 'image'))
    ul.append a.add b.add c

controlInit = (cb) ->
    controlDown target: global.dropTarg
    for key of global then global[key] = null
    $(document).off('keyup').keyup(controlAbort)
    document.ondrop = controlDrop; document.onclick = null
    document.ondragover = document.ondragenter = eventVoid
    $('#control').remove(); $('figure').remove()
    $('#progress').remove(); $('form').fadeIn(400)
    $('h2').fadeIn(400); $('ul').fadeIn(400)
    $('h1').off('click').click(-> controlInit controlProcess)
    $('h3').html('').off('click').show()
    $('input').prop('disabled', false); abort();
    $('input').css('width', 410).css('padding-left', 10)
    controlInput 'text', 'Paste a URL or add a file here'
    $('<div>').prop('id', 'control').appendTo('form')
    $('<div>').prop('id', 'button').addClass('btn-upload')
        .appendTo('#control').off('click')
        .click(controlFile).hide().fadeIn(400)
    $('form').off('submit').submit (event) ->
        eventVoid event
        controlPreview global.fileData, 'prvData'
        pass = -> controlInput 'password', 'Enter password'
        done = ->
            localStorage.setItem 'method', global.optMethod
            localStorage.setItem 'wikisafe', global.optSafe
            localStorage.setItem 'container', \
                if global.fileJpeg then 'rand' else global.optJpeg
            localStorage.setItem 'action', global.optAction \
                if global.optData != 'url'
            $('h3').html(''); global.optPass = $('input').val() \
                if $('input').attr('type') == 'password'
            return $('h3').css('opacity', 0) \
                .off('click').stop().animate(opacity: 1, 400) \
                .html('Empty password not allowed').delay(1000)
                .animate(opacity: 0, 400) \
                if !global.optPass && global.optMethod != 'join'
            $('#control').fadeOut(400).queue ->
                controlDown target: global.dropTarg
                global.fileJpeg ?= global.optJpeg
                $('#control').remove(); global.prvData = null
                $('input').css('width', 410).css('padding-left', 10)
                controlInput 'password'; global.prvJpeg = null
                $('input').prop('disabled', true);
                $('<div>').prop('id', 'progress').appendTo('form')
                cb $('form').off('submit').submit (e) -> eventVoid e;
        global.optAction = localStorage.getItem('action') ? 'encode'
        global.optAction = 'decode' if not global.fileData
        global.optData = global.fileData && 'file' || 'url'
        global.fileData = global.fileData || $('input').val()
        global.optMethod = localStorage.getItem('method') ? 'auto'
        global.optJpeg = localStorage.getItem('container') ? 'rand'
        global.optSafe = localStorage.getItem('wikisafe') ? 'true'
        global.optSafe = global.optSafe == 'true'
        controlAdd 'ctr-color-1 ctr-start', global.optAction, controlAction
        controlAdd 'ctr-from-1 ctr-to-2', null, null
        controlAdd 'ctr-color-2', global.optMethod, controlMethod
        controlAdd 'ctr-from-2 ctr-to-3', null, null
        if global.optAction == 'encode'
            controlAdd 'ctr-color-3', global.optData, controlData
            controlAdd 'ctr-from-3 ctr-to-4', null, null
            controlAdd 'ctr-color-4 ctr-stop', global.optJpeg, controlJpeg
        else controlAdd 'ctr-color-3 ctr-stop', global.optData, controlData
        controlAdd 'ctr-float', null, null
        $('input').val(''); controlRefresh()
        $('#button').removeClass('btn-upload').off('click')
        $('#button').addClass('btn-process').click(done)
        $('form').off('submit').submit (e) -> eventVoid e; done()
        if global.optData == 'file' then pass() else \
        setTimeout(pass, 100) && $('#control').hide().fadeIn(400)

controlProgress = (dict) ->
    text = dict.name ? dict.type
    prog = Math.min(Math.max(dict.progress ? 0, 18), 100) * 4.41 | 0
    return $('#progress').html(text) if dict.type != 'progress'
    $('#progress').stop().animate(width: prog, 400).html(text)

controlProcess = ->
    done = (image, blob) ->
        str = blob.name + '<br><span dir="ltr">' +
            ((blob.size >> 10) + 1) + ' Kb</span>'
        $('<figure>').append(image).appendTo('section')
            .append($('<figcaption>').html(str)
            .css('max-width', $(image).width() - 6))
            .click(-> dataURLSave url, blob.name)
            .css(opacity: 0).animate(opacity: 1, 400)
    error = (url) ->
        err = trace(url, true)?.error ? 'Some error occured'
        $('h3').stop().css('opacity', 1).html("Oops! #{err} :(")
        document.onclick = -> controlInit controlProcess
    safari = /^(?!.*Chrome).*Safari.*$/.test navigator.userAgent
    dict = action: global.optAction, pass: global.optPass, \
           method: global.optMethod, safe: global.optSafe
    dict.data = global.fileData if global.optAction == 'decode'
    dict.data = global.fileJpeg if global.optAction == 'encode'
    dict.hide = global.fileData if global.optAction == 'encode'
    await processRequest dict, controlProgress, defer blob
    await blobToDataURL blob, safari, defer url
    return error url if not okay url
    await dataURLToImage url, defer image if /image/.test blob.type
    image = $('<div>') if not image? or not okay image
    $('h2').fadeOut(400); $('form').fadeOut(400)
    $('h3').fadeOut(400); $('ul').fadeOut(400)
    setTimeout (-> done image, blob), 450

testBrowser '//browser-update.org/update.html'
jQuery.event.props.push 'dataTransfer'
controlInit controlProcess

console.log """
            Privacy is necessary for an open society in the electronic age.
            ... We cannot expect governments, corporations, or other large,
            faceless organizations to grant us privacy ... We  must  defend
            our own privacy if we expect to have any. ... Cypherpunks write
            code.  We know  that someone has to  write  software  to defend
            privacy, and ... we're going to write it. (c) Eric Hughes, 1993
            """
