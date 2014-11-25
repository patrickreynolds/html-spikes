(function($, S) {

  $(function() {
    bindEvents()
  })

  function bindEvents() {
    $('.play-button').on('click', handlePlayVideoEvent)
    $('.video').on('timeupdate', updateProgressBar)
    pauseOnTappedElement($('.video').get(0))
    initScrubWithElement($('.video').get(0))
  }

  function pauseOnTappedElement(element) {
    new S(element, {recognizers:['tap']}).on('tap', function(ev) {
        handlePauseVideoEvent(ev)
        var interval = setInterval(function() {
            clearInterval(interval)
        }, 100)
    })
  }

  var INITIAL_TIME = 0

  function initScrubWithElement(element) {
    new Sistine(element, {
        recognizers: [
            new S.Pan({eventName:'panHorizontal', direction:S.DIRECTION_HORIZONTAL})
        ]
    }).on('panHorizontal', function(ev) {
        if (ev.state === S.STATE_STARTED) {
          var video = ev.target
          INITIAL_TIME = video.currentTime
        }
        else if (ev.state === S.STATE_CHANGED) {
          var video = ev.target
          
          if (!video.paused) {
            var width = $(ev.target).width()
            var duration = video.duration
            var translation = ev.translation[0]
            console.log("Translation: (" + ev.translation[0] + "," + ev.translation[1] + ")")

            video.currentTime = INITIAL_TIME + (((width / duration) / 100 ) * (translation * 2))
          }
        }
        else if (ev.state === S.STATE_ENDED) {
          var video = ev.target
          
          if (!video.paused) {
            $(video).siblings(".play-button").trigger("click")
          }
        }
    })
  }

  function handlePlayVideoEvent(ev) {
    var video = $(ev.target).siblings(".video").get(0)
    var playButton = ev.target
    $(playButton).css('display', 'none')
    play(video)
  }

  function handlePauseVideoEvent(ev) {
    var video = ev.target
    var playButton = $(video).siblings('.play-button').get(0)
    $(playButton).css('display', 'block')
    pause(video)
  }

  function play(video) {
    video.play()
  }

  function pause(video) {
    video.pause()
  }

  function updateProgressBar(ev) {
    var video = ev.target
    var progressBar = $(video).siblings('.progress-bar').get(0)
    var percentage = (100 / video.duration) * video.currentTime
    progressBar.value = percentage
  }

}(jQuery, Sistine))