/**
 * topbar 2.0.0 - https://buunguyen.github.io/topbar
 * Minimal progress bar for Phoenix LiveView page navigation.
 */
;(function(window, document) {
  "use strict"

  var canvas, progressTimerId, fadeTimerId, currentProgress, showing
  var delayTimerId
  var addEvent = function(elem, type, handler) {
    if (elem.addEventListener) elem.addEventListener(type, handler, false)
    else if (elem.attachEvent) elem.attachEvent("on" + type, handler)
    else elem["on" + type] = handler
  }

  var options = {
    autoRun: true,
    barThickness: 3,
    barColors: {
      0: "rgba(26,  188, 156, .9)",
      ".25": "rgba(52,  152, 219, .9)",
      ".50": "rgba(241, 196,  15, .9)",
      ".75": "rgba(230,  126,  34, .9)",
      "1.0": "rgba(211,  84,   0, .9)"
    },
    shadowBlur: 10,
    shadowColor: "rgba(0,   0,   0, .6)",
    className: null
  }

  var repaint = function() {
    canvas.width = window.innerWidth
    canvas.height = options.barThickness * 5
    var ctx = canvas.getContext("2d")
    ctx.shadowBlur = options.shadowBlur
    ctx.shadowColor = options.shadowColor
    var lineGradient = ctx.createLinearGradient(0, 0, canvas.width, 0)
    for (var stop in options.barColors)
      lineGradient.addColorStop(stop, options.barColors[stop])
    ctx.lineWidth = options.barThickness
    ctx.beginPath()
    ctx.moveTo(0, options.barThickness / 2)
    ctx.lineTo(Math.ceil(currentProgress * canvas.width), options.barThickness / 2)
    ctx.strokeStyle = lineGradient
    ctx.stroke()
  }

  var createCanvas = function() {
    canvas = document.createElement("canvas")
    var style = canvas.style
    style.position = "fixed"
    style.top = style.left = style.right = style.margin = style.padding = 0
    style.zIndex = 100001
    style.display = "none"
    if (options.className) canvas.classList.add(options.className)
    document.body.appendChild(canvas)
    addEvent(window, "resize", repaint)
  }

  var topbar = {
    config: function(opts) {
      for (var key in opts)
        if (options.hasOwnProperty(key)) options[key] = opts[key]
    },
    show: function(delay) {
      if (showing) return
      if (delay) {
        if (delayTimerId) return
        delayTimerId = setTimeout(() => topbar.show(), delay)
        return
      }
      showing = true
      if (fadeTimerId !== null) window.clearInterval(fadeTimerId)
      if (!canvas) createCanvas()
      currentProgress = 0
      canvas.style.opacity = 1
      canvas.style.display = "block"
      repaint()
      if (options.autoRun) {
        progressTimerId = window.setInterval(function() {
          topbar.progress("+.01")
          repaint()
        }, 50)
      }
    },
    progress: function(to) {
      if (to === undefined) return currentProgress
      if (typeof to === "string") {
        to =
          (to.indexOf("+") >= 0 || to.indexOf("-") >= 0
            ? currentProgress
            : 0) + parseFloat(to)
      }
      currentProgress = to > 1 ? 1 : to
      repaint()
      return currentProgress
    },
    hide: function() {
      clearTimeout(delayTimerId)
      delayTimerId = null
      if (!showing) return
      showing = false
      if (progressTimerId) {
        window.clearInterval(progressTimerId)
        progressTimerId = null
      }
      ;(function loop() {
        if (topbar.progress("+.1") >= 1) {
          canvas.style.opacity -= 0.05
          if (canvas.style.opacity <= 0.05) {
            canvas.style.display = "none"
            fadeTimerId = null
            return
          }
        }
        fadeTimerId = window.setTimeout(loop, 50)
      })()
    }
  }

  if (typeof module === "object" && typeof module.exports === "object") {
    module.exports = topbar
  } else if (typeof define === "function" && define.amd) {
    define(function() { return topbar })
  } else {
    this.topbar = topbar
  }
}.call(this, window, document))
