fs = require 'fs'

module.exports =
  build: (cb) ->
    return cb null
    fs.readFile 'dictionary.json', 'utf8', (err, data) ->
      cb null,
      "    <script>\n" +
      "      dictionary = data\n"
      "    </script>\n"
