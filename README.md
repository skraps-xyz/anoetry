## Anoetry

Animated poetry.

## Getting started

#### How to git Anoetry

You will need node, npm and git installed. For example, with homebrew:

```
brew install node
brew install npm
brew install git
cd ~/art
git clone https://github.com/skraps-xyz/anoetry.git
cd anoetry
npm install
```

#### How to make an anoem

1. Store the body of text you want to be your anoem in a `.txt` file.

2. Navigate to the anoetry folder.

3. `./make.sh -n "name of your anoem" <path to your .txt file>`

4. This should create a file in `./anoems` called `"name of your anoem.html"`. Open it in a web browser to see what it looks like.

## Documentation

Customizing your anoem is done by creating a config `.json` file of the form

``` json
{
  "master": {
    "main_div": "div.main {<custom css>}",
    "custom_css": "span.custom_class {<custom css>}; ..."
  },
  "primary": {
    "delineator": "",
    "timer": "<name of timer>",
    "timer_args": "<depends on the timer chosen>",
    "classes": [
      "list",
      "of",
      "classes"
    ],
    "changes": [
      ["change1"],
      ["change2", "change3"],
      ["change4"],
      ["etc", "etc", "etc"]
    ]
  }
}
```
* `master` is optional, if you want to add custom classes for spans or modify the main div that contains your anoem, do it there.
* `primary.delineator` for now, it's gotta be `""`.
* `primary.timer` the name of a timer (see "Timers" below)
* `primary.timer_args` the arguments for the timer chosen (see "Timers" below)
* `primary.classes` a list of names of the classes chosen by the "class" mutation.
* `primary.changes` a list of lists of mutations. When the timer determines that it is time to make a change, a word is randomly selected from your text, and a list of changes is randomly selected from `primary.changes`. Each of the changes in this list will happen to the randomly selected word. (See "Mutations" below.)

#### Timers

###### Random

After an initial delay, changes happen a random amount of time after one another. You set the initial delay, and lower and upper bounds for the amount of time between changes.

```
"timer": "random",
"timer_args": [initial_delay, lower_bound, upper_bound],
```

initial_delay, lower_bound and upper_bound are integers in milliseconds.

For example, if you want to wait three seconds, and then make a change every .5 to 1.5 seconds, you would use

```
"timer_args": [3000, 500, 1500],
```

###### Bursts

After an initial delay, changes happen periodically in bursts.  You specify a range of time (upper and lower bounds) that will occur between bursts, a number of mutations/changes to make during a burst, and a number of milliseconds between changes in a burst.

```
"timer": "bursts",
"timer_args": [initial_delay, lower_bound, upper_bound, changes_per_burst, burst_speed]
```

Each of the timer args is an integer measuring milliseconds, except for `changes_per_burst` which is the number of changes made during a burst. For example, if you want the first burst to occur after 4 seconds, and to have 2-3 seconds between bursts, and each burst to consist of 10 changes 15 milliseconds apart, you would use

```
"timer_args": [4000, 2000, 3000, 10, 15],
```

###### Exponential Acceleration

After an initial delay, changes occur exponentially more frequently, until the hit a lower bound frequency, and then will occur with that frequency thereafter.

```
"timer": "exponential_acceleration",
"timer_args": [initial_delay, initial_duration, lower_bound, percent_decrease],
```

This one is a bit more mathematical, but let's say that you want to initially delay by 2 seconds, and then begin a sequence of changes separated by 2 seconds, then 75% of 2 seconds, then 75% of 75% of 2 seconds, and so on, but never to go faster than 1 change per .2 seconds, you would use

```
"timer_args": [2000, 2, 200, 0.75],
```

Keep in mind that exponential acceleration is... exponential.

#### Classes

Classes are used by the "class" mutation below. They determine the color/shape/font/etc of a word. You can define your own classes in `master.custom_css`, but the ones that come stock are: "red", "blue", "green", "strikethrough", "none", and, for each of black, white, red, yellow, blue and orange "all_color".

#### Mutations

###### Class

"class"

sets the css class of the span containing the word to a random class as specified by your "classes" in your config. For example if your config had

```
"classes": ["red", "strikethrough", "none"],
"changes": [["class"]]
```

The only types of changes that would happen would be changes of class, to a random word, to one of "red", "strikethrough" or "none" (also randomly).

###### Permanently

"permanently"

This makes it so that after this change is executed on a given word, that word will never change after that. One typical use for it might be something like:

```
"changes": [
  ["class"],
  ["class"],
  ["obfuscate", "class", "linethrough", permanently"]
]
```

so that each change/mutation would have two thirds chance of changing the class, and a one third chance of obfuscating the text, changing the class, adding the strikethrough class as well, and then protecting that word from being changed by future changes/mutations.

###### Obfuscate

"obfuscate"

Replaces the word (let's say it's length is n) with the first n characters of the utf8 encoding of the md5 hash of the word. I.e., it becomes nonsensical symbols, but deterministically based on the word.

###### Linethrough

"linethrough"

Adds the "strikethrough" class to the word.

###### Thesaurus

"thesaurus"

Replaces the word with a random synonym, antonym, or related word. In order to use this mutation/change, you will need to open `anoetry/make.sh` and uncomment the thesaurus API key line near the top and provide an API key. To obtain an API key, go to [https://words.bighugelabs.com/api.php](https://words.bighugelabs.com/api.php).

###### Translate

"translate"

Replaces the word with a random translation amongst Mandarin, French, Hebrew, Hindi and Russian. Similarly to Thesaurus, you will need to uncomment the line in `anoetry/make.sh` and provide an API key. Translate API keys can be obatained at [https://cloud.google.com/translate](https://cloud.google.com/translate).

## Todo

* When compiling an anoem, look for a config in the directory of the source file, and use that one. Otherwise, use the default config.

#### Attributions

Note that Anoetry relies on

* base64.js by dankogai
* JavaScript md5 by Sebastian Tschan
* bighugelabs thesaurus API
* Google Translate API
