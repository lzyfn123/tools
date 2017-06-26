Timer = (function (window) {
    function Timer(selector, stepCallback, finishCallback) {
      var defaultCallback = function () {
      };
      this.$selector = selector + ':not(.finish)';
      this.$finishCallback = finishCallback || defaultCallback;
      this.$stepCallback = stepCallback || defaultCallback;
      this.$step = 1000;
      this.$timer = undefined;
    }

    Timer.prototype._addZero = function (i) {
      if (i >= 0 && i < 10) {
        i = "0" + i;
      }
      return i + '';
    };

    Timer.prototype._formatCountdown = function (countdown) {
      if (!(countdown > 0)) {
        countdown = 0
      }
      var hours = parseInt(countdown / 3600, 10); //计算剩余的小时
      var minutes = parseInt(countdown / 60 % 60, 10);//计算剩余的分钟
      var seconds = parseInt(countdown % 60, 10);//计算剩余的秒数
      return this._addZero(hours) + ':' + this._addZero(minutes) + ':' + this._addZero(seconds)
    };

    Timer.prototype._countdown = function () {
      var $this = this;
      $($this.$selector).each(function (k, v) {
        var $tag = $(v);
        var seconds = parseInt($tag.data('seconds'), 10);
        $tag.html($this._formatCountdown(seconds));

        if (seconds > 0) {
          seconds--;
          $tag.data('seconds', seconds);
          $this.$stepCallback($tag, $this);
        } else {
          $tag.addClass('finish');
          $this.$finishCallback($tag, $this);
        }
      });

      if ($($this.$selector).length <= 0) {
        window.clearInterval($this.$timer);
      }
    };

    Timer.prototype.run = function () {
      var $this = this;

      $this.$timer = window.setInterval(function () {
        $this._countdown()
      }, $this.$step);
    };

    return Timer;
  })(window);

  (new Timer('td .countdown')).run();