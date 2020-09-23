
SML           ?= sml
# -32 or -64
# empty is default
SML_BITMODE   ?=
SML_FLAGS     ?= $(SML_BITMODE)
HEAP_SUFFIX   ?= $(shell $(SML) $(SML_FLAGS) @SMLsuffix)

SMLDOC        ?= smldoc

MLBUILD       ?= ml-build
MLBUILD_FLAGS ?= $(SML_BITMODE)

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
	$(MLBUILD) $(MLBUILD_FLAGS) test/sources.cm Sha3Test.main $@


.PHONY: test
test: $(TEST_TARGET)
	@$(SML) $(SML_FLAGS) @SMLload=$<


.PHONY: clean
clean:
	-$(RM) -r $(DOCDIR)
	-$(RM) $(TEST_TARGET)
	-$(RM) -r .cm
	-$(RM) -r src/.cm
	-$(RM) -r test/.cm

