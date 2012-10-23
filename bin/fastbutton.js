(function() {
  var Clickbuster, FastButton, clickDistance, clickbuster, clickbusterDistance, clickbusterTimeout;
  clickbusterDistance = 25;
  clickbusterTimeout = 2500;
  clickDistance = 10;
  FastButton = (function() {
    function FastButton(selector, handler) {
      var handlers, that;
      this.selector = selector;
      this.handler = handler;
      if (!("ontouchstart" in window)) {
        return;
      }
      this.active = false;
      that = this;
      handlers = {
        touchstart: function(event) {
          return that.touchStart(event, this);
        },
        touchend: function(event) {
          return that.touchEnd(event, this);
        }
      };
      $(document).on(handlers, selector).on('touchmove', function() {
        return that.touchMove(event);
      });
    }
    FastButton.prototype.touchStart = function(event, element) {
      var touch;
      touch = event.originalEvent.touches[0];
      this.active = true;
      this.startX = touch.clientX;
      this.startY = touch.clientY;
      return event.stopPropagation();
    };
    FastButton.prototype.touchMove = function(event) {
      var dx, dy, touch;
      if (!this.active) {
        return;
      }
      touch = event.originalEvent.touches[0];
      dx = Math.abs(touch.clientX - this.startX);
      dy = Math.abs(touch.clientY - this.startY);
      if (dx > clickDistance || dy > clickDistance) {
        return this.active = false;
      }
    };
    FastButton.prototype.touchEnd = function(event, element) {
      if (!this.active) {
        return;
      }
      event.preventDefault();
      this.active = false;
      return this.handler.call(element, event);
    };
    return FastButton;
  })();
  Clickbuster = (function() {
    function Clickbuster() {
      this.coordinates = [];
    }
    Clickbuster.prototype.preventGhostClick = function(x, y) {
      this.coordinates.push(x, y);
      return window.setTimeout(clickbuster.pop, clickbusterDistance);
    };
    Clickbuster.prototype.pop = function() {
      return clickbuster.coordinates.splice(0, 2);
    };
    Clickbuster.prototype.onClick = function(event) {
      var coordinates, dx, dy, x, y, _results;
      coordinates = clickbuster.coordinates;
      _results = [];
      while (i < coordinates.length) {
        x = coordinates[i];
        y = coordinates[i + 1];
        dx = Math.abs(event.clientX - x);
        dy = Math.abs(event.clientY - y);
        _results.push(dx < clickbusterDistance && dy < clickbusterDistance ? (event.stopPropagation(), event.preventDefault()) : void 0);
      }
      return _results;
    };
    return Clickbuster;
  })();
  clickbuster = new Clickbuster();
  if ("ontouchstart" in window) {
    $(document).bind('click', clickbuster.onClick);
  }
  $.fn.extend({
    fastButton: function(handler) {
      return new FastButton(this.selector, handler);
    }
  });
  $('.use-fastclick a[data-remote],\
   .use-fastclick .fastClick').fastButton(function(ev) {
    var $this;
    ev.preventDefault();
    ev.stopPropagation();
    $this = $(this);
    history.pushState(null, "Notes State", $this.attr('href'));
    return $this.trigger('click');
  });
  $('.use-fastclick a:not([data-remote]):not(.fastClick)').fastButton(function(ev) {
    var $this, dispatch, target;
    ev.preventDefault();
    ev.stopPropagation();
    $this = $(this);
    target = $this.attr('target') || null;
    if (target === null) {
      return window.location = $this.attr('href');
    } else {
      dispatch = document.createEvent("HTMLEvents");
      dispatch.initEvent("click", true, true);
      return this.dispatchEvent(dispatch);
    }
  });
  $('.use-fastclick .submit,\
   .use-fastclick .input[type="submit"],\
   .use-fastclick button[type="submit"]').fastButton(function(ev) {
    ev.preventDefault();
    return $(this).closest('form').trigger('submit');
  });
  $('.use-fastclick input[type="text"]').fastButton(function(ev) {
    ev.preventDefault();
    $(this).trigger('focus');
    return false;
  });
}).call(this);
