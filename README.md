# ESPN Fantasy Football Aggregator

Produce a csv of weekly scores from an ESPN Fantasy Football league.

## Method

### 0 - Get ready

```sh
make setup      # creates dirs
make install    # installs jq, htmlq
```

### 1 - Fetch data

Log in on a desktop browser and copy the html content from each week into its own file in the `raw/` directory, e.g. `raw/week-03.html`.

This is automatable but requires fiddling with cookies etc. Manual pulling using Chrome Devtools > Elements > right click `<body>` > Copy Element is easy enough.

### 2 - Build all-scores.csv

```sh
make all-scores.csv
```

This parses all the garbage obfuscated HTML and returns a single clean csv file with all weekly scores.

### 3 - Pay out your annoying friends

Plop the csv into Sheets or Excel and do a pivot table or something to figure out the weekly high scores if that's one of the pots in your fantasy league, then tell Will his team sucks as you identify that his "really awesome team" hasn't even won the pot half of the weeks, and that the Giants suck too.

## Motivation

I am commish this year and am behind on paying out the weekly high score pot, so needed the scores. I went to grab it manually but I've recently done a bunch of web scraping and decided to leverage that methodology instead, to good effect. One downside of course is that now I will be badgered to produce payments even quicker given I have used my 1337 skills to create such a tool, but such is life.

## Tech

I have been more and more reaching exclusively for a unix-y approach to data pipelines, using only CLI tools orchestrated with `make`, and am very happy to have not needed to reach for python at all to fill in any of the gaps.
