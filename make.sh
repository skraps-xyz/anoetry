#!/bin/bash

# export TRANSLATE_API_KEY=<your key> # see https://cloud.google.com/translate
# export THESAURUS_API_KEY=<your key> # see https://words.bighugelabs.com/api.php

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo ""
      echo "Compiles your anoem"
      echo " "
      echo "Usage:   ./make.sh [options] [source]"
      echo "Example: ./make.sh --name trees --source ~/poems/trees"
      echo ""
      echo "options:"
      echo ""
      echo "-h, --help      there is a fixed point in any map that is"
      echo "                located inside of the thing it is a map of"
      echo "                https://en.wikipedia.org/wiki/Banach_fixed-point_theorem"
      echo ""
      echo "-cfg            location of config file for your anoem; if unspecified,"
      echo "                will use ./lib/default_config.json"
      echo ""
      echo "-n              the name of your anoem"
      echo ""
      exit 0
      ;;
    -cfg)
      shift
      if test $# -gt 0; then
        export CFG=$1
      else
        echo "No config specified"
        exit 1
      fi
      shift
      ;;
    -n)
      shift
      if test $# -gt 0; then
        export NAME=$1
      else
        echo "No name specified"
        exit 1
      fi
      shift
      ;;
    *)
      break
      ;;
  esac
done

coffee -c ./lib/frontend/scripts/*.coffee
coffee main.coffee $1 > ./anoems/$NAME.html

