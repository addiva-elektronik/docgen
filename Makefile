.PHONY: all clean release preview serve

srcs    := $(shell find . -mindepth 2 -path "./docgen/*.md" -o -name '*.md' -print | sort)
objs    := $(srcs:.md=.html) $(srcs:.md=.pdf)

docgen  := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
origin  := $(shell git config remote.origin.url)
repo    := $(shell basename $(origin) .git)
objhash  = $(shell git rev-parse --short `git hash-object $<` || echo "AEL")
gitrev   = $(shell git log -n 1 --pretty=format:-%h -- $< 2>/dev/null)
gitver   = $(repo):$(objhash)$(gitrev)
args     = --standalone --data-dir=$(docgen) --template=addiva -f markdown+implicit_figures
args    += --resource-path $(shell dirname $<) -V data-dir="$(docgen)" -V gitrev="$(gitrev)"
args    += -V gitversion="$(gitver)" -V today="$(shell date --iso)" -V year=$(shell date +'%Y')

%.html: %.md
	pandoc -t html $(args) -o $@ $<

%.pdf: %.md
	pandoc -t pdf $(args) -o $@ $<

all: build

build: $(objs)
	mkdir -p output
	for obj in $(objs); do						\
		dir=`dirname $$obj`;					\
		mkdir -p output/$$dir;					\
		mv $$obj output/$$dir/;					\
		cp -f $(docgen)/templates/logo.png output/$$dir/;		\
		for img in `find $$dir -name '*.png'`; do		\
			cp -vf $$img output/$$dir/$$igmp;		\
		done;							\
	done

upload: all
	rsync -vr --delete output/ 172.21.104.40:/var/www/addiva/

clean:
	-$(RM) $(objs) head.html

distclean: clean
	-$(RM) -r output
	-$(RM) *~ *.bak DEADJOE

preview: $(objs)
	x-www-browser file://`pwd`/output/

serve: $(objs)
	./server.sh $(srcs)
