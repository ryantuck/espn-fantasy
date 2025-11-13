RAW_WEEKS := $(wildcard weeks/*.html)
CLEAN_WEEKS := $(RAW_WEEKS:weeks/%.html=build/%.html)
TEAM_WEEKS := $(CLEAN_WEEKS:build/%.html=teams/%.txt)
SCORES_WEEKS := $(TEAM_WEEKS:teams/%.txt=scores/%.txt)
SUMMARY_WEEKS := $(SCORES_WEEKS:scores/%.txt=summary/%.csv)

all-scores.csv : $(SUMMARY_WEEKS)
	echo "team,score,week,index" > $@
	cat $^ >> $@

summary/%.csv : teams/%.txt scores/%.txt
	paste -d ',' $^ \
		| jq -R 'split(",")' \
		| jq '. += ["$*"]' -c \
		| jq -s 'to_entries | .[] | .value + [.key + 1]' -c \
		| jq 'join(",")' -r \
		> $@

scores/%.txt : build/%.html
	cat $< \
		| htmlq '.matchup-teams-score-container ul li .ScoreCell__Score' --text \
		| awk 'NF > 0' \
		| sed -e 's/^[ ]*//' \
		> $@

teams/%.txt : build/%.html
	cat $< \
		| htmlq '.matchup-teams-score-container ul li .ScoreCell__TeamName' --text \
		| awk 'NF > 0' \
		| sed -e 's/^[ ]*//' \
		> $@

build/%.html : weeks/%.html
	tidy -i -q $< > $@ 2>/dev/null || true

.PHONY : setup debug

setup :
	mkdir -p build
	mkdir -p teams
	mkdir -p scores
	mkdir -p summary

debug :
	@echo "RAW: $(RAW_WEEKS)"
	@echo "CLEAN: $(CLEAN_WEEKS)"
	@echo "TEAMS: $(TEAM_WEEKS)"
	@echo "SCORES: $(SCORES_WEEKS)"
	@echo "SUMMARY: $(SUMMARY_WEEKS)"
