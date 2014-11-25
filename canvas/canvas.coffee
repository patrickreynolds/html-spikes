Canvas = Canvas || {}

(($, Canvas) ->

    $(() ->
        Canvas.bindEvents()
    )

    Canvas.bindEvents = () ->

        # Whiteboard Events
        $('#whiteboard').mousedown (ev) ->
            mouseX = ev.pageX - @offsetLeft
            mouseY = ev.pageY - @offsetTop
            Canvas.isPainting = true
            addClick(ev.pageX - @offsetLeft, ev.pageY - @offsetTop)
            redraw()

        $('#whiteboard').mousemove (ev) ->
            if Canvas.isPainting
                addClick(ev.pageX - @offsetLeft, ev.pageY - @offsetTop, true)
                redraw()

        $('#whiteboard').mouseup (ev) ->
            Canvas.isPainting = false

        $('#whiteboard').mouseleave (ev) ->
            Canvas.isPainting = false


        # Whiteboard Modifier Events
        $('#clear').mouseup (ev) ->
            clear()

        # Annotation Color Event
        $('.Control-color').mouseup (ev) ->
            clearSelectedColors()
            markSelected(ev.target)
            Canvas.currentColor = AnnotationColors[ev.target.id]

        # Annotation Size Events
        $('.Control-size').mouseup (ev) ->
            Canvas.currentSize = AnnotationSizes[ev.target.id]

        # Annotation Tool Events 
        $('.Control-tool').mouseup (ev) ->
            Canvas.currentTool = AnnotationTools[ev.target.id]

        $('#load-image').mouseup (ev) ->
            loadImage()

        $('#clear-image').mouseup (ev) ->
            clearImage()

        $('#load-layer-info').mouseup (ev) ->
            loadLayerInfo()

        $('#load-layer-confirm').mouseup (ev) ->
            loadLayer()

        $('#save-layer-info').mouseup (ev) ->
            saveLayerInfo()

        $('#save-layer').mouseup (ev) ->
            saveLayer()



    whiteboard = $('#whiteboard').get(0).getContext '2d'

    AnnotationColors = {
        black: "#212121",
        gray:  "#CCCCCC",
        red:   "#BA3D2D",
        green: "#8CBC30",
        blue:  "#92B8BF"
    }

    AnnotationSizes = {
        small:  2,
        normal: 6,
        large:  12
    }

    AnnotationTools = {
        eraser: 'eraser',
        marker: 'marker'
    }

    clickX       = new Array()
    clickY       = new Array()
    clickDrag    = new Array()
    clickColor   = new Array()
    clickSize    = new Array()
    clickTool    = new Array()
    imageLayers  = new Array()
    destination  = new Array()

    Canvas.currentColor = AnnotationColors.black
    Canvas.currentSize  = AnnotationSizes.normal
    Canvas.currentTool  = AnnotationTools.marker

    Canvas.isPainting = null

    markSelected = (el) ->
        $(el).addClass 'is-selected'

    removeSelected = () ->
        $(this).removeClass 'is-selected'

    clearSelectedColors = () -> 
        $('.Control-color').each removeSelected


    addClick = (x, y, dragging) ->
        clickX.push x
        clickY.push y
        clickDrag.push dragging
        clickSize.push Canvas.currentSize

        if Canvas.currentTool == "eraser"
            clickColor.push 'rgb(0, 0, 0, 0)'
            destination.push 'destination-out'
        else
            clickColor.push Canvas.currentColor
            destination.push 'source-over'


    redraw = () ->
        whiteboard.clearRect 0, 0, whiteboard.canvas.width, whiteboard.canvas.height
        whiteboard.lineJoin = "round"
        
        if imageLayers.length
            whiteboard.drawImage imageLayers[0], 0, 0

        for i in [0..clickX.length] by 1
            whiteboard.beginPath()
            if clickDrag[i] && i
                whiteboard.moveTo clickX[i-1], clickY[i-1]
            else
                whiteboard.moveTo clickX[i]-1, clickY[i]

            whiteboard.lineTo clickX[i], clickY[i]
            whiteboard.closePath()
            whiteboard.strokeStyle = clickColor[i]
            whiteboard.lineWidth = clickSize[i]
            whiteboard.globalCompositeOperation = destination[i] || 'source-over'
            whiteboard.stroke()


    loadImage = (ev) ->
        $('.Canvas-container').css 'background', 'url(' + 'adobe-xd.png' + ') center no-repeat'

    clearImage = (ev) ->
        $('.Canvas-container').css 'background', 'none'

    loadLayerInfo = (ev) ->
        $('.Layer-container-load').css 'display', 'inline-block'
        $('#layer-list').find('select').empty()
        for index in [0..localStorage.length-1]
            layer = localStorage.key index
            $('#layer-list').find('select').append(new Option(layer, layer))

    loadLayer = (ev) ->
        $('.Layer-container-load').css 'display', 'none'
        layer = $('#layer-list').find('select').val()
        imageString = localStorage.getItem layer
        image = new Image()
        image.src = imageString
        imageLayers = []
        imageLayers.push image
        redraw()

    saveLayerInfo = (ev) ->
        $('.Layer-container-save').css 'display', 'inline-block'

    saveLayer = (ev) ->
        layerName = $('#layer-name').val().trim()
        layer = whiteboard.canvas.toDataURL()
        if (layerName)
            $('.Layer-container-save').css 'display', 'none'    
            localStorage.setItem layerName, layer
            $('#layer-name').val('')
        else
            alert("No layer name!")
            $('#layer-name').focus()

    clear = () ->
        whiteboard.clearRect 0, 0, whiteboard.canvas.width, whiteboard.canvas.height
        clickX      = []
        clickY      = []
        clickDrag   = []
        clickColor  = []
        clickSize   = []
        clickTool   = []
        imageLayers = []
        destination = []
        
)(jQuery, Canvas)