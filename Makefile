RAW_WEEKS := $(wildcard raw/*.html)
TIDY_WEEKS := $(RAW_WEEKS:raw/%.html=build/tidy-weeks/%.html)
TEAMS_WEEKS := $(TIDY_WEEKS:build/tidy-weeks/%.html=build/teams/%.txt)
SCORES_WEEKS := $(TEAMS_WEEKS:build/teams/%.txt=build/scores/%.txt)
SUMMARY_WEEKS := $(SCORES_WEEKS:build/scores/%.txt=build/summary/%.csv)

all-scores.csv : $(SUMMARY_WEEKS)
	echo "team,score,week,index" > $@
	cat $^ >> $@

build/summary/%.csv : build/teams/%.txt build/scores/%.txt
	paste -d ',' $^ \
		| jq -R 'split(",")' \
		| jq '. += ["$*"]' -c \
		| jq -s 'to_entries | .[] | .value + [.key + 1]' -c \
		| jq 'join(",")' -r \
		> $@

build/scores/%.txt : build/tidy-weeks/%.html
	cat $< \
		| htmlq '.matchup-teams-score-container ul li .ScoreCell__Score' --text \
		| awk 'NF > 0' \
		| sed -e 's/^[ ]*//' \
		> $@

build/teams/%.txt : build/tidy-weeks/%.html
	cat $< \
		| htmlq '.matchup-teams-score-container ul li .ScoreCell__TeamName' --text \
		| awk 'NF > 0' \
		| sed -e 's/^[ ]*//' \
		> $@

build/tidy-weeks/%.html : raw/%.html
	tidy -i -q $< > $@ 2>/dev/null || true

.PHONY : setup debug install

setup :
	mkdir -p raw
	mkdir -p build/tidy-weeks
	mkdir -p build/teams
	mkdir -p build/scores
	mkdir -p build/summary

debug :
	@echo "RAW: $(RAW_WEEKS)"
	@echo "TIDY: $(TIDY_WEEKS)"
	@echo "TEAMS: $(TEAMS_WEEKS)"
	@echo "SCORES: $(SCORES_WEEKS)"
	@echo "SUMMARY: $(SUMMARY_WEEKS)"

install :
	brew install jq htmlq
