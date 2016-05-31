_ = require 'underscore'
_ = _.extend _, require 'underscore.deep'
async = require 'async'
fs = require 'fs'

thesaurus = require './thesaurus/thesaurus.coffee'
dictionary = require './dictionary/dictionary.coffee'
translations = require './translations/translations.coffee'

JSON_variable = (var_name, json_object) ->
  "<script>#{var_name} = #{JSON.stringify json_object}</script>"

include_script = (script_name) ->
  fs.readFileSync("#{__dirname}/frontend/scripts/#{script_name}", "utf8") + ";\n"

module.exports =
  build: (anoem_name, config, input_text, cb) ->
    # separate out master config from the rest of the config
    master_config = config.master
    delete config.master

    # delineators maps a delinator back to the layer associated with it
    delineators = {}
    for layer in _.keys(config)
      delineators[config[layer].delinator] = layer

    # build span_words, all_words and word_layers
    all_words = []
    word_layers = _.object _.keys(config), _(_.keys config).map -> []
    lines = input_text.split ("\n")
    span_words = for line in lines
      _.map line.split(" "), (word) ->
        return "<span></span>" if word is ""
        layer = "primary"
        if word[0] is word[word.length-1] and word[0] in _.keys delineators
          layer = delinators[word[0]]
        word_layers[layer].push word
        all_words.push word
        "<span id='#{layer}-#{word_layers[layer].length - 1}'>#{word}</span>"

   # html stuff
    html_lines = for span_word in span_words
      "  " + span_word.join("&nbsp;") + "\n"
    default_span = """
span {
  padding-left: 3px;
  padding-right: 3px;
  font-family: Verdana, Helvetica, Arial;
  font-size: 15pt;
}\n """ # maybe font size varies with number of words?
    default_main_div = """
div.main {
  margin: 100px;
  margin-top: 70px;
  line-height: 250%;
  text-align: left;
}\n """
    colors = {white: "fff", black: "000", red: "f00", yellow: "ff0", blue: "00f"}
    all_colors = for color, hex of colors
      "span.all_#{color} {\n  background: ##{hex};\n  color: ##{hex}\n}\n"

    async.auto {
      translations: (cb_a) -> translations.build all_words, cb_a
      thesaurus: (cb_a) -> thesaurus.build all_words, cb_a
      html: ['translations', 'thesaurus'].concat (cb_a, {translations, thesaurus}) ->
        cb null, [
          '<html>'
          '<head>'
          '<meta charset="UTF-8">'
          "<title>#{anoem_name}</title>"
          '<style>'
          master_config?.main_div or default_main_div
          master_config?.default_span or default_span
          fs.readFileSync "#{__dirname}/frontend/style/style.css", "UTF-8"
          all_colors.join('\n')
          '</style>'
          '<script>'
          '\n'
          '<!-- jquery-2.2.3.min -->'
          include_script "jquery-2.2.3.min.js"
          '<!-- underscore -->'
          # include_script "underscore.js"
          '<!-- base64 -->'
          include_script "base64.js"
          '<!-- md5 -->'
          include_script "md5.js"
          include_script "timers.js"
          '</script>'
          '\n'
          JSON_variable("config", config)
          JSON_variable("word_layers", word_layers)
          JSON_variable("thesaurus", thesaurus)
          JSON_variable("translations", translations)
          "</head>"
          "\n\n\n"
          "<body>"
          "<center>"
          "<div class='main'>"
          html_lines.join("<br>\n")
          "</div>"
          "</center>"
          "</body>"
          "<script>"
          include_script "script.js" # make this body.onload
          "</script>"
          "</html>"
        ].join "\n"
    }
