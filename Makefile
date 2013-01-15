include include.mk
SHELL:=/bin/bash -e
export SHELLOPTS=pipefail

python_version_full := $(wordlist 2,4,$(subst ., ,$(shell python --version 2>&1)))
python_version_major := $(word 1,${python_version_full})
python_version_minor := $(word 2,${python_version_full})
##############################
# These modules are dependent and are
# only included if their depedencies exist!
ifeq ($(wildcard ../sonLib/Makefile),)
	Comparator = 
	TransitiveClosure = 
	Stats = 
	ToFasta = 
$(warning Because dependency ../sonLib is missing mafComparator and mafTransitiveClosure will not be built / tested / cleaned. See README.md for information about dependencies.)
else
	Comparator = mafComparator
	Stats = mafStats
	ToFasta = mafToFastaStitcher
ifeq ($(wildcard ../sonLib/lib/stPinchesAndCacti.a),)
	TransitiveClosure = 
$(warning Because dependency ../pinchesAndCacti is missing mafTransitiveClosure will not be built / tested / cleaned. See README.md for information about dependencies.)
else
	TransitiveClosure = mafTransitiveClosure
endif # sonlib
endif # pinches
ifeq (0, $(shell python -c 'import numpy;' >> /dev/null 2>&1 && echo $$?))
ifeq (0, $(shell python -c 'import scipy;' >> /dev/null 2>&1 && echo $$?))
	CoveragePickles = mafCoveragePickles
else
	CoveragePickles = 
$(warning Because dependency python: scipy is missing mafCoveragePickles will not be built / tested / cleaned. See README.md for information about dependencies.)
endif # scipy
else
	CoveragePickles = 
$(warning Because dependency python: numpy is missing mafCoveragePickles will not be built / tested / cleaned. See README.md for information about dependencies.)
endif # numpy
##############################
dependentModules= ${Comparator} ${TransitiveClosure} ${CoveragePickles} ${Stats}

modules = include ${dependentModules} mafValidator mafPositionFinder mafExtractor mafSorter mafDuplicateFilter mafFilter mafStrander mafRowOrderer mafToFastaStitcher

.PHONY: all %.all clean %.clean test %.test

all: ${modules:%=%.all}

%.all:
	cd $* && make all

# python :
# 	@echo ${python_version_full}
# 	@echo ${python_version_major}
# 	@echo ${python_version_minor}

clean: ${modules:%=%.clean}

%.clean:
	cd $* && make clean

test : ${modules:%=%.test} ${Warnings:%=%.warn}

%.test:
	cd $* && make test
