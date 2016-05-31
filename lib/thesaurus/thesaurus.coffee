async = require 'async'
fs = require 'fs'
quest = require 'quest'

api_key = process.env["THESAURUS_API_KEY"]
host = "http://words.bighugelabs.com"

try
  data_store = fs.readFileSync "#{__dirname}/thesaurus.json", "UTF8"
  data_store = JSON.parse data_store
catch e
  data_store = {}

module.exports =
  get_thesaurus: (word, cb) ->
    cb null, word unless api_key
    word_lc = word.toLowerCase()
    cached = data_store[word_lc]
    return cb null, data_store[word_lc] if cached
    quest
      url: "#{host}/api/2/#{api_key}/#{word}/json"
    , (err, response, body) ->
      try
        cb null, JSON.parse body
      catch e
        cb null, [word] # or ? , consider random

  build: (words, cb) ->
    output = {}
    async.forEachSeries words, (word, cb_fe) ->
      module.exports.get_thesaurus word, (err, thesaurus_entry) ->
        output[word] = thesaurus_entry
        data_store[word.toLowerCase()] = thesaurus_entry
        cb_fe()
    , ->
      fs.writeFileSync "#{__dirname}/thesaurus.json", JSON.stringify data_store
      cb null, output
