# utility functions
# _ = underscore
random_array_value = (arr) ->
  keys = Object.keys arr
  arr[keys[Math.floor(Math.random() * keys.length)]]
random_leaf = (json_ob) ->
  return json_ob if typeof json_ob is "string"
  random_leaf json_ob[random_array_value Object.keys json_ob]

# initialization
cells = {}
for layer in Object.keys word_layers
  cells[layer] = word_layers[layer].map (t, m) -> text: t, ele: $("span[id='#{layer}-#{m}']").eq(0)
rnd = (layer) ->
  random_array_value Object.keys cells[layer]
grab = (layer, word_num) ->
  cells[layer][word_num].ele
set_text = (layer, word_num, text) -> -> grab(layer, word_num).html(text)

mutations = {}

# mutation: class
classes = (layer) -> config[layer].classes
set_class = (layer, word_num, cls) -> ->
  grab(layer, word_num).removeClass(classes(layer).join " ")
  grab(layer, word_num).addClass(cls)
mutations.class = (layer, word_num) ->
  set_class(layer, word_num, random_array_value(classes layer))()
# mutations.class = (layer) -> class_randomly layer, rnd(layer)

# mutation: thesaurus
mutations.thesaurus = (layer, word_num) ->
  thesaurus_entry = thesaurus[word_layers[layer][word_num]]
  set_text(layer, word_num, random_leaf(thesaurus_entry) or word_layers[layer][word_num])()
# mutations.thesaurus = (layer) -> thesaurus_randomly layer, rnd(layer)

# mutation: translate
mutations.translate = (layer, word_num) ->
  translations_for_word = translations[word_layers[layer][word_num]]
  set_text(layer, word_num, random_array_value(translations_for_word) or word_layers[layer][word_num])()
# mutations.translate = (layer) -> translator_randomly layer, rnd(layer)

# mutation: change class and set to original word
mutations.english_class = (layer, word_num) ->
  @["class"] layer, word_num
  set_text layer, word_num, word_layers[layer][word_num]

# mutation: permantently
mutations.permanently = (layer, word_num) ->
  delete cells[layer][word_num]

time = 0
initial_time = new Date().getTime()
timer = timers[config.primary["timer"]].apply @, config["primary"]["timer_args"]
changer_iterator = (layer) -> ->
  word_num = rnd layer
  return unless word_num
  for index, mutation of random_array_value config[layer].changes
    mutations[mutation] layer, word_num
  time = new Date().getTime() - initial_time
  setTimeout changer_iterator(layer), timer.next(word_layers, time)

setTimeout changer_iterator("primary"), timer.init_delay
