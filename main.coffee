_ = require 'underscore'
async = require 'async'
fs = require 'fs'
anoetry = require './lib/anoetry.coffee'

anoem_name = process.env['NAME']
config_file = process.env['CFG'] or "./lib/default_config.json"
source_file = process.argv[2]

unless source_file? and anoem_name?
  console.log "Unspecified source file"
  process.exit 1

dest_file = "/tmp/anoems/#{anoem_name}/index.html"

async.auto {
  'src': (cb_a) ->
    fs.readFile source_file, 'utf8', cb_a
  'cfg': (cb_a) ->
    fs.readFile config_file, 'utf8', cb_a
  'cfg_ob': ['cfg'].concat (cb_a, {cfg}) ->
    try cb_a null, JSON.parse cfg
    catch e then cb_a e
  'html': ['src', 'cfg_ob'].concat (cb_a, {src, cfg_ob}) ->
    anoetry.build anoem_name, cfg_ob, src, cb_a
}, (err, results) ->
  console.log err or results.html
