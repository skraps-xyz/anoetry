random_in_interval = (a, b) -> a + Math.floor(Math.random() * (b - a))
timers =
  random: (init_delay, low_ms, high_ms) ->
    init_delay: init_delay
    next: (w, t) -> random_in_interval low_ms, high_ms
