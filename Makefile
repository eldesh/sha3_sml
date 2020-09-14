
SMLDOC ?= smldoc

DOCDIR := doc

SRC := $(wildcard src/*)


all: doc


.PHONY: doc
doc: sources.cm $(SRC)
	$(RM) -r $(DOCDIR)
	mkdir $(DOCDIR)
	$(SMLDOC) -c UTF-8 \
		--builtinstructure=Word8 \
		--builtinstructure=TextIO \
		--recursive \
		--linksource \
		-d $(DOCDIR) \
		sources.cm

.PHONY: clean
clean:
	$(RM) -r $(DOCDIR)

