Canvas = Canvas || {}

(($, Canvas) ->

    $(() ->
        Canvas.bindEvents()
        Canvas.positionCanvas Canvas.whiteboard.canvas
        Canvas.redraw Canvas.whiteboard
    )

    Canvas.bindEvents = () ->

        # Resize Events
        $(window).resize ->
            Canvas.positionCanvas Canvas.whiteboard.canvas
            Canvas.redraw Canvas.whiteboard

        # Whiteboard Events
        $('#whiteboard').mousedown (ev) ->
            mouseX = ev.pageX - @offsetLeft
            mouseY = ev.pageY - @offsetTop
            Canvas.isPainting = true
            addClick ev.pageX - @offsetLeft, ev.pageY - @offsetTop
            Canvas.redraw Canvas.whiteboard

        $('#whiteboard').mousemove (ev) ->
            if Canvas.isPainting
                addClick ev.pageX - @offsetLeft, ev.pageY - @offsetTop, true
                Canvas.redraw Canvas.whiteboard

        $('#whiteboard').mouseup (ev) ->
            Canvas.isPainting = false

        $('#whiteboard').mouseleave (ev) ->
            Canvas.isPainting = false


        # Whiteboard Modifier Events
        $('#clear').mouseup (ev) ->
            clear Canvas.whiteboard


        # Annotation Color Event
        $('.Control-color').mouseup (ev) ->
            clearSelectedColors()
            markSelected ev.target
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
    

    Canvas.whiteboard = $('#whiteboard').get(0).getContext '2d'

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

    Canvas.points = []

    Canvas.currentColor = AnnotationColors.black
    Canvas.currentSize  = AnnotationSizes.normal
    Canvas.currentTool  = AnnotationTools.marker
    Canvas.isPainting = null

    Point = () ->
        x         = null
        y         = null
        dragState = null
        size      = null
        color     = null
        gpo       = null

    markSelected = (el) ->
        $(el).addClass 'is-selected'

    removeSelected = () ->
        $(this).removeClass 'is-selected'

    clearSelectedColors = () -> 
        $('.Control-color').each removeSelected

    Canvas.positionCanvas = (canvas) ->
        canvas.style.height = '100%'
        canvas.style.width  = '100%'
        canvas.width  = canvas.offsetWidth
        canvas.height = canvas.offsetHeight

    addClick = (x, y, dragging) ->
        point = new Point
        point.x         = x
        point.y         = y
        point.dragState = dragging
        point.size      = Canvas.currentSize

        if Canvas.currentTool == "eraser"
            point.color = 'rgb(0, 0, 0, 0)'
            point.gpo   = 'destination-out'
        else
            point.color = Canvas.currentColor
            point.gpo   = 'source-over'

        Canvas.points.push point

    Canvas.redraw = (whiteboard) ->
        whiteboard.clearRect 0, 0, whiteboard.canvas.width, whiteboard.canvas.height
        whiteboard.lineJoin = "round"

        if Canvas.points.length
            for i in [0...Canvas.points.length] by 1
                whiteboard.beginPath()
                point = Canvas.points[i]
                if point.dragState && i
                    whiteboard.moveTo Canvas.points[i - 1].x, Canvas.points[i - 1].y
                else
                    whiteboard.moveTo point.x - 1, point.y

                whiteboard.lineTo point.x, point.y
                whiteboard.closePath()
                whiteboard.strokeStyle = point.color
                whiteboard.lineWidth   = point.size
                whiteboard.globalCompositeOperation = point.gpo || 'source-over'
                whiteboard.stroke()


    loadImage = (ev) ->
        $('.Canvas-container').css 'background', 'url(' + 'adobe-xd.png' + ') center no-repeat'

    clearImage = (ev) ->
        $('.Canvas-container').css 'background', 'none'

    loadLayerInfo = (ev) ->
        $('.Layer-container-load').css 'display', 'inline-block'
        $('#layer-list').find('select').empty()
        for index in [0...localStorage.length]
            layer = localStorage.key index
            $('#layer-list').find('select').append new Option layer, layer 

    loadLayer = (ev) ->
        $('.Layer-container-load').css 'display', 'none'
        layer = $('#layer-list').find('select').val()
        layerPoints   = localStorage.getItem layer
        Canvas.points = Canvas.points.concat JSON.parse layerPoints
        Canvas.redraw Canvas.whiteboard

    saveLayerInfo = (ev) ->
        $('.Layer-container-save').css 'display', 'inline-block'

    saveLayer = (ev) ->
        layerName = $('#layer-name').val().trim()
        layer = Canvas.points
        if layerName
            $('.Layer-container-save').css 'display', 'none'    
            localStorage.setItem layerName, JSON.stringify layer
            $('#layer-name').val ''
        else
            alert("No layer name!")
            $('#layer-name').focus()

    clear = (whiteboard) ->
        whiteboard.clearRect 0, 0, whiteboard.canvas.width, whiteboard.canvas.height
        Canvas.points = []

)(jQuery, Canvas)