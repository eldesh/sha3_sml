
SML           ?= sml
# -32 or -64
# empty is default
SML_BITMODE   ?=
SML_FLAGS     ?=
HEAP_SUFFIX   ?= $(shell $(SML) $(SML_BITMODE) @SMLsuffix)

SMLDOC        ?= smldoc

MLBUILD       ?= ml-build
MLBUILD_FLAGS ?=

MLDEPENDS       ?= ml-makedepend
MLDEPENDS_FLAGS ?= -n

SML_DULIST    ?=

DOCDIR        ?= doc

SRC           := $(wildcard src/*)
TEST_SRC      := $(wildcard test/*)

TEST_TARGET   ?= bin/Sha3Test.$(HEAP_SUFFIX)

all: libsha3sml test doc


.PHONY: libsha3sml
libsha3sml: .cm/$(HEAP_SUFFIX)


.cm/$(HEAP_SUFFIX):
	echo 'CM.stabilize true "sources.cm";' | $(SML) $(SML_BITMODE) $(SML_DULIST)


libsha3sml.d: sources.cm src/sources.cm
	@touch $@
	$(MLDEPENDS) $(MLDEPENDS_FLAGS) $(SML_BITMODE) $(SML_DULIST) -f $@ $< .cm/$(HEAP_SUFFIX)
	@sed -i -e "s|^[^#]\([^:]\+\):|\1 $@:|" $@


ifeq (,$(findstring $(MAKECMDGOALS),clean))
  include libsha3sml.d
endif


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
	-$(RM) libsha3sml.d
	-$(RM) -r $(DOCDIR)
	-$(RM) $(TEST_TARGET)
	-$(RM) -r .cm
	-$(RM) -r src/.cm
	-$(RM) -r test/.cm

