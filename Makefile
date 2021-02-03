
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

PREFIX        ?= /usr/local/sml
LIBDIR        ?= lib/libsha3sml.cm
DOCDIR        ?= doc/libsha3sml

SRC           := $(wildcard src/*)
TEST_SRC      := $(wildcard test/*)

TEST_TARGET   ?= bin/Sha3Test.$(HEAP_SUFFIX)

all: libsha3sml-nodoc


.PHONY: libsha3sml-nodoc
libsha3sml-nodoc: .cm/$(HEAP_SUFFIX)


.PHONY: libsha3sml
libsha3sml: .cm/$(HEAP_SUFFIX) doc


.cm/$(HEAP_SUFFIX):
	@echo 'CM.stabilize true "libsha3sml.cm";' | $(SML) $(SML_BITMODE) $(SML_DULIST)


libsha3sml.d: libsha3sml.cm src/sources.cm
	@touch $@
	$(MLDEPENDS) $(MLDEPENDS_FLAGS) $(SML_BITMODE) $(SML_DULIST) -f $@ $< .cm/$(HEAP_SUFFIX)
	@sed -i -e "s|^[^#]\([^:]\+\):|\1 $@:|" $@


ifeq (,$(findstring $(MAKECMDGOALS),clean))
  include libsha3sml.d
endif


.PHONY: install-nodoc
install-nodoc: libsha3sml-nodoc
	@install -d $(PREFIX)/$(LIBDIR)
	@cp -R .cm $(PREFIX)/$(LIBDIR)/.cm
	@echo "================================================================"
	@echo "libsha3sml has been installed to:"
	@echo "\t$(PREFIX)/$(LIBDIR)"
	@echo "Add an entry to the file ~/.smlnj-pathconfig such like:"
	@echo "\tlibsha3sml.cm $(PREFIX)/libsha3sml.cm"
	@echo "Then you can load the library like"
	@echo "\t\"CM.make \"$$/libsha3sml.cm\";\"."
	@echo "================================================================"


.PHONY: install
install: install-nodoc install-doc


.PHONY: doc
doc:
	@$(RM) -r doc
	@mkdir doc
	@$(SMLDOC) -c UTF-8 \
		--builtinstructure=Word8 \
		--builtinstructure=TextIO \
		--builtinstructure=VectorSlice \
		--hidebysig \
		--recursive \
		--linksource \
		-d doc \
		libsha3sml.cm


.PHONY: install-doc
install-doc: doc
	@install -d $(PREFIX)/$(DOCDIR)
	@cp -prT doc $(PREFIX)/$(DOCDIR)
	@echo "================================================================"
	@echo "Generated API Documents of Sha3SML"
	@echo "\t$(PREFIX)/$(DOCDIR)"
	@echo "================================================================"


$(TEST_TARGET): $(TEST_SRC)
	$(MLBUILD) $(SML_BITMODE) $(SML_DULIST) $(MLBUILD_FLAGS) test/sources.cm Sha3Test.main $@


.PHONY: test
test: $(TEST_TARGET)
	@$(SML) $(SML_BITMODE) $(SML_DULIST) $(SML_FLAGS) @SMLload=$<


.PHONY: clean
clean:
	-$(RM) libsha3sml.d
	-$(RM) -r doc
	-$(RM) $(TEST_TARGET)
	-$(RM) -r .cm
	-$(RM) -r src/.cm
	-$(RM) -r test/.cm

