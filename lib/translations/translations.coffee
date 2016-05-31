_ = require 'underscore'
async = require 'async'
fs = require 'fs'
quest = require 'quest'

api_key = process.env["TRANSLATE_API_KEY"]
host = "https://www.googleapis.com/language/translate/v2"

try
  data_store = fs.readFileSync "#{__dirname}/translations.json", "UTF8"
  data_store = JSON.parse data_store
catch e
  data_store = {}

module.exports =
  languages: ["zh-TW", "fr", "iw", "hi", "ru"]

  get_translation: (word, cb) ->
    word_lc = word.toLowerCase()
    cached = data_store[word_lc]
    return cb null, data_store[word_lc] if cached
    translations = []
    async.mapSeries @languages, (language, cb_ms) ->
      quest
        url: host
        json: true
        qs:
          key: api_key
          q: word_lc
          source: "en"
          target: language
      , (err, resp, {data}) ->
        translations = data?.translations or []
        translations = _.map translations, (translation) ->
          translation.translatedText
        cb_ms null, translations
    , (err, translations) ->
      translations = _.flatten translations
      data_store[word_lc] = translations
      cb null, translations

  build: (words, cb) ->
    async.series _.object(words, _.map words, (word) ->
      (cb_s) ->
        module.exports.get_translation word, cb_s
    ), (err, output) ->
      for english_word, translations of output
        for translation in translations
          output[translation] = _.map translations.concat(english_word)
      fs.writeFileSync "#{__dirname}/translations.json", JSON.stringify data_store
      cb null, output
