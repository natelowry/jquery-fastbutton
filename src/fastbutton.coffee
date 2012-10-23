# Original paper:
# https://developers.google.com/mobile/articles/fast_buttons
#
# Original implementation
# https://github.com/alexblack/google-fastbutton

#################
# Configuration #
#################

# These options should generally not be modified.
# If some Google engineers did their research and said they were ok like that,
# they probably are.

# If a "click" event is fired this close to a recent "touchend" event,
# we consider it an automatic, not-human-generated click and disregard it.
clickbusterDistance = 25

# Interval in milliseconds that defines how recent is a "recent" event.
clickbusterTimeout = 2500

# If a touch moves more than this many pixels,
# we no longer consider it an intentional "click"
clickDistance = 10

#############
# T3h codez #
#############

# Construct the FastButton with a reference to the element and click handler.
class FastButton
  constructor: (@selector, @handler) ->
    return unless ("ontouchstart" in window)
    # this.active == true if we're currently expecting a fastClick
    this.active = false
    that = this

    handlers = {
      touchstart: (event) -> that.touchStart(event, this)
      touchend: (event) -> that.touchEnd(event, this)
    }
    $(document)
      .on(handlers, selector)
      .on('touchmove', -> that.touchMove(event))

  # begins a "click"
  touchStart: (event, element) ->
    touch = event.originalEvent.touches[0]
    this.active = true
    this.startX = touch.clientX
    this.startY = touch.clientY

    event.stopPropagation()

  # Checks if the user is dragging, instead of clicking.
  # If so, cancels the "click".
  touchMove: (event) ->
    return unless this.active

    touch = event.originalEvent.touches[0]
    dx = Math.abs(touch.clientX - this.startX)
    dy = Math.abs(touch.clientY - this.startY)

    if dx > clickDistance || dy > clickDistance
      # if she did, then cancel the touch event
      this.active = false

  # Invokes the actual click handler and prevents ghost clicks
  touchEnd: (event, element) ->
    return unless this.active

    event.preventDefault()
    this.active = false
    return this.handler.call(element, event)

class Clickbuster
  constructor: ->
    this.coordinates = []

  preventGhostClick: (x, y) ->
    this.coordinates.push(x, y)
    window.setTimeout(clickbuster.pop, clickbusterDistance)

  pop: () ->
    clickbuster.coordinates.splice(0, 2)

  # If we catch a click event inside the given radius and time threshold,
  # that event will be considered a ghost click (and will be ignored).
  onClick: (event) ->
    coordinates = clickbuster.coordinates
    while i < coordinates.length
      x = coordinates[i]
      y = coordinates[i+1]
      dx = Math.abs(event.clientX - x)
      dy = Math.abs(event.clientY - y)
      if dx < clickbusterDistance and dy < clickbusterDistance
        event.stopPropagation()
        event.preventDefault()

clickbuster = new Clickbuster()
if ("ontouchstart" in window)
  # Only setup event hanlders on mobile devices
  $(document).bind('click', clickbuster.onClick)

##################
# jQuery binding #
##################

$.fn.extend
  fastButton: (handler) ->
    new FastButton(this.selector, handler)

########################
# Zero-config defaults #
########################

# Handle remote links
# This assumes the Rails convention that links with JS logic
# will have data-remote=true
$('a[data-remote], .fastClick').fastButton (ev) ->
  ev.preventDefault()
  ev.stopPropagation()
  $this = $(this)
  history.pushState(null, "Notes State", $this.attr('href'))
  $this.trigger('click')

# Handle normal links
$('a:not([data-remote])').fastButton (ev) ->
  ev.preventDefault()
  ev.stopPropagation()
  $this = $(this)
  target = $this.attr('target') or null

  if target is null
    # Open normal links... eh, normally
    window.location = $this.attr('href')
  else
    # Links opened in new tabs require some special care on iOS.
    # http://stackoverflow.com/questions/7930001
    # Not tested on android, though.
    dispatch = document.createEvent("HTMLEvents")
    dispatch.initEvent("click", true, true)
    this.dispatchEvent(dispatch)

# Submit all forms via ajax.
# (Assumes all forms can be submitted via ajax)
$('.submit, input[type="submit"], button[type="submit"]').fastButton (ev) ->
  ev.preventDefault()
  $(this).closest('form').trigger('submit')

# Quickly focus all input selectors
# There doesn't need to be any JS associated with the input fields.
$('input[type="text"]').fastButton (ev) ->
  ev.preventDefault()
  $(this).trigger('focus')
  false

