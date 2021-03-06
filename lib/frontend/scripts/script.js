// Generated by CoffeeScript 1.6.3
(function() {
  var add_class, cells, changer_iterator, classes, grab, initial_time, layer, mutations, random_array_value, random_leaf, remove_classes, rnd, set_class, set_text, time, timer, _i, _len, _ref;

  random_array_value = function(arr) {
    var keys;
    keys = Object.keys(arr);
    return arr[keys[Math.floor(Math.random() * keys.length)]];
  };

  random_leaf = function(json_ob) {
    if (typeof json_ob === "string") {
      return json_ob;
    }
    return random_leaf(json_ob[random_array_value(Object.keys(json_ob))]);
  };

  cells = {};

  _ref = Object.keys(word_layers);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    layer = _ref[_i];
    cells[layer] = word_layers[layer].map(function(t, m) {
      return {
        text: t,
        ele: $("span[id='" + layer + "-" + m + "']").eq(0)
      };
    });
  }

  rnd = function(layer) {
    return random_array_value(Object.keys(cells[layer]));
  };

  grab = function(layer, word_num) {
    return cells[layer][word_num].ele;
  };

  set_text = function(layer, word_num, text) {
    return grab(layer, word_num).html(text);
  };

  mutations = {};

  classes = function(layer) {
    return config[layer].classes;
  };

  remove_classes = function(layer, word_num) {
    return grab(layer, word_num).removeClass(classes(layer).join(" "));
  };

  add_class = function(layer, word_num, cls) {
    return grab(layer, word_num).addClass(cls);
  };

  set_class = function(layer, word_num, cls) {
    remove_classes(layer, word_num);
    return add_class(layer, word_num, cls);
  };

  mutations["class"] = function(layer, word_num) {
    return set_class(layer, word_num, random_array_value(classes(layer)));
  };

  mutations.thesaurus = function(layer, word_num) {
    var thesaurus_entry;
    thesaurus_entry = thesaurus[word_layers[layer][word_num]];
    return set_text(layer, word_num, random_leaf(thesaurus_entry) || word_layers[layer][word_num]);
  };

  mutations.translate = function(layer, word_num) {
    var translations_for_word;
    translations_for_word = translations[word_layers[layer][word_num]];
    return set_text(layer, word_num, random_array_value(translations_for_word) || word_layers[layer][word_num]);
  };

  mutations.english_class = function(layer, word_num) {
    this["class"](layer, word_num);
    return set_text(layer, word_num, word_layers[layer][word_num]);
  };

  mutations.permanently = function(layer, word_num) {
    return delete cells[layer][word_num];
  };

  mutations.linethrough = function(layer, word_num) {
    console.log("linethrough");
    return add_class(layer, word_num, "linethrough");
  };

  mutations.obfuscate = function(layer, word_num) {
    var md5_text, new_text, original_text, utf8_text;
    remove_classes(layer, word_num);
    original_text = word_layers[layer][word_num];
    console.log(original_text);
    md5_text = md5(original_text);
    console.log(md5_text);
    utf8_text = Base64.decode(md5_text);
    console.log(utf8_text);
    new_text = utf8_text.slice(0, original_text.length);
    console.log(new_text);
    return set_text(layer, word_num, new_text);
  };

  time = 0;

  initial_time = new Date().getTime();

  timer = timers[config.primary["timer"]].apply(this, config["primary"]["timer_args"]);

  changer_iterator = function(layer) {
    return function() {
      var index, mutation, word_num, _ref1;
      word_num = rnd(layer);
      if (!word_num) {
        return;
      }
      _ref1 = random_array_value(config[layer].changes);
      for (index in _ref1) {
        mutation = _ref1[index];
        mutations[mutation](layer, word_num);
      }
      time = new Date().getTime() - initial_time;
      return setTimeout(changer_iterator(layer), timer.next(word_layers, time));
    };
  };

  setTimeout(changer_iterator("primary"), timer.init_delay);

}).call(this);
