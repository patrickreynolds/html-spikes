// Generated by CoffeeScript 1.8.0
var Canvas;

Canvas = Canvas || {};

(function($, Canvas) {
  var AnnotationColors, AnnotationSizes, AnnotationTools, addClick, clear, clearImage, clearSelectedColors, clickColor, clickDrag, clickSize, clickTool, clickX, clickY, destination, imageLayers, loadImage, loadLayer, loadLayerInfo, markSelected, redraw, removeSelected, saveLayer, saveLayerInfo, whiteboard;
  $(function() {
    return Canvas.bindEvents();
  });
  Canvas.bindEvents = function() {
    $('#whiteboard').mousedown(function(ev) {
      var mouseX, mouseY;
      mouseX = ev.pageX - this.offsetLeft;
      mouseY = ev.pageY - this.offsetTop;
      Canvas.isPainting = true;
      addClick(ev.pageX - this.offsetLeft, ev.pageY - this.offsetTop);
      return redraw();
    });
    $('#whiteboard').mousemove(function(ev) {
      if (Canvas.isPainting) {
        addClick(ev.pageX - this.offsetLeft, ev.pageY - this.offsetTop, true);
        return redraw();
      }
    });
    $('#whiteboard').mouseup(function(ev) {
      return Canvas.isPainting = false;
    });
    $('#whiteboard').mouseleave(function(ev) {
      return Canvas.isPainting = false;
    });
    $('#clear').mouseup(function(ev) {
      return clear();
    });
    $('.Control-color').mouseup(function(ev) {
      clearSelectedColors();
      markSelected(ev.target);
      return Canvas.currentColor = AnnotationColors[ev.target.id];
    });
    $('.Control-size').mouseup(function(ev) {
      return Canvas.currentSize = AnnotationSizes[ev.target.id];
    });
    $('.Control-tool').mouseup(function(ev) {
      return Canvas.currentTool = AnnotationTools[ev.target.id];
    });
    $('#load-image').mouseup(function(ev) {
      return loadImage();
    });
    $('#clear-image').mouseup(function(ev) {
      return clearImage();
    });
    $('#load-layer-info').mouseup(function(ev) {
      return loadLayerInfo();
    });
    $('#load-layer-confirm').mouseup(function(ev) {
      return loadLayer();
    });
    $('#save-layer-info').mouseup(function(ev) {
      return saveLayerInfo();
    });
    return $('#save-layer').mouseup(function(ev) {
      return saveLayer();
    });
  };
  whiteboard = $('#whiteboard').get(0).getContext('2d');
  AnnotationColors = {
    black: "#212121",
    gray: "#CCCCCC",
    red: "#BA3D2D",
    green: "#8CBC30",
    blue: "#92B8BF"
  };
  AnnotationSizes = {
    small: 2,
    normal: 6,
    large: 12
  };
  AnnotationTools = {
    eraser: 'eraser',
    marker: 'marker'
  };
  clickX = new Array();
  clickY = new Array();
  clickDrag = new Array();
  clickColor = new Array();
  clickSize = new Array();
  clickTool = new Array();
  imageLayers = new Array();
  destination = new Array();
  Canvas.currentColor = AnnotationColors.black;
  Canvas.currentSize = AnnotationSizes.normal;
  Canvas.currentTool = AnnotationTools.marker;
  Canvas.isPainting = null;
  markSelected = function(el) {
    return $(el).addClass('is-selected');
  };
  removeSelected = function() {
    return $(this).removeClass('is-selected');
  };
  clearSelectedColors = function() {
    return $('.Control-color').each(removeSelected);
  };
  addClick = function(x, y, dragging) {
    clickX.push(x);
    clickY.push(y);
    clickDrag.push(dragging);
    clickSize.push(Canvas.currentSize);
    if (Canvas.currentTool === "eraser") {
      clickColor.push('rgb(0, 0, 0, 0)');
      return destination.push('destination-out');
    } else {
      clickColor.push(Canvas.currentColor);
      return destination.push('source-over');
    }
  };
  redraw = function() {
    var i, _i, _ref, _results;
    whiteboard.clearRect(0, 0, whiteboard.canvas.width, whiteboard.canvas.height);
    whiteboard.lineJoin = "round";
    if (imageLayers.length) {
      whiteboard.drawImage(imageLayers[0], 0, 0);
    }
    _results = [];
    for (i = _i = 0, _ref = clickX.length; _i <= _ref; i = _i += 1) {
      whiteboard.beginPath();
      if (clickDrag[i] && i) {
        whiteboard.moveTo(clickX[i - 1], clickY[i - 1]);
      } else {
        whiteboard.moveTo(clickX[i] - 1, clickY[i]);
      }
      whiteboard.lineTo(clickX[i], clickY[i]);
      whiteboard.closePath();
      whiteboard.strokeStyle = clickColor[i];
      whiteboard.lineWidth = clickSize[i];
      whiteboard.globalCompositeOperation = destination[i] || 'source-over';
      _results.push(whiteboard.stroke());
    }
    return _results;
  };
  loadImage = function(ev) {
    return $('.Canvas-container').css('background', 'url(' + 'adobe-xd.png' + ') center no-repeat');
  };
  clearImage = function(ev) {
    return $('.Canvas-container').css('background', 'none');
  };
  loadLayerInfo = function(ev) {
    var index, layer, _i, _ref, _results;
    $('.Layer-container-load').css('display', 'inline-block');
    $('#layer-list').find('select').empty();
    _results = [];
    for (index = _i = 0, _ref = localStorage.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; index = 0 <= _ref ? ++_i : --_i) {
      layer = localStorage.key(index);
      _results.push($('#layer-list').find('select').append(new Option(layer, layer)));
    }
    return _results;
  };
  loadLayer = function(ev) {
    var image, imageString, layer;
    $('.Layer-container-load').css('display', 'none');
    layer = $('#layer-list').find('select').val();
    imageString = localStorage.getItem(layer);
    image = new Image();
    image.src = imageString;
    imageLayers = [];
    imageLayers.push(image);
    return redraw();
  };
  saveLayerInfo = function(ev) {
    return $('.Layer-container-save').css('display', 'inline-block');
  };
  saveLayer = function(ev) {
    var layer, layerName;
    layerName = $('#layer-name').val().trim();
    layer = whiteboard.canvas.toDataURL();
    if (layerName) {
      $('.Layer-container-save').css('display', 'none');
      localStorage.setItem(layerName, layer);
      return $('#layer-name').val('');
    } else {
      alert("No layer name!");
      return $('#layer-name').focus();
    }
  };
  return clear = function() {
    whiteboard.clearRect(0, 0, whiteboard.canvas.width, whiteboard.canvas.height);
    clickX = [];
    clickY = [];
    clickDrag = [];
    clickColor = [];
    clickSize = [];
    clickTool = [];
    imageLayers = [];
    return destination = [];
  };
})(jQuery, Canvas);