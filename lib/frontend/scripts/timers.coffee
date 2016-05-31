random_in_interval = (a, b) -> a + Math.floor(Math.random() * (b - a))

# timers
window.timers =

  random: (init_delay, low_ms, high_ms) ->
    init_delay: init_delay
    next: (w, t) -> random_in_interval low_ms, high_ms

  bursts: (init_delay, low_ms, high_ms, bursts, burst_ms) ->
    n: 0
    init_delay: init_delay
    next: (w, t) ->
      @.n++
      if @.n % bursts is 0
        random_in_interval low_ms, high_ms
      else
        burst_ms
