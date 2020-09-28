
SML           ?= sml
# -32 or -64
# empty is default
SML_BITMODE   ?=
SML_FLAGS     ?=
HEAP_SUFFIX   ?= $(shell $(SML) $(SML_BITMODE) @SMLsuffix)

SMLDOC        ?= smldoc

MLBUILD       ?= ml-build
MLBUILD_FLAGS ?=

SML_DULIST    ?=

DOCDIR        ?= doc

SRC           := $(wildcard src/*)
TEST_SRC      := $(wildcard test/*)

TEST_TARGET   ?= bin/Sha3Test.$(HEAP_SUFFIX)

all: test doc


.PHONY: doc
doc: sources.cm $(SRC)
	$(RM) -r $(DOCDIR)
	mkdir $(DOCDIR)
	$(SMLDOC) -c UTF-8 \
		--builtinstructure=Word8 \
		--builtinstructure=TextIO \
		--builtinstructure=VectorSlice \
		--hidebysig \
		--recursive \
		--linksource \
		-d $(DOCDIR) \
		sources.cm


$(TEST_TARGET): $(TEST_SRC)
	$(MLBUILD) $(SML_BITMODE) $(SML_DULIST) $(MLBUILD_FLAGS) test/sources.cm Sha3Test.main $@


.PHONY: test
test: $(TEST_TARGET)
	@$(SML) $(SML_BITMODE) $(SML_DULIST) $(SML_FLAGS) @SMLload=$<


.PHONY: clean
clean:
	-$(RM) -r $(DOCDIR)
	-$(RM) $(TEST_TARGET)
	-$(RM) -r .cm
	-$(RM) -r src/.cm
	-$(RM) -r test/.cm

