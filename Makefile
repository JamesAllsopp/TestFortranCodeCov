#!/bin/bash
# -----------------------------------------------------------------------------
#
# Copyright (c) 2009 - 2012 Chris Martin, Kasia Boronska, Jenny Young,
# Peter Jimack, Mike Pilling
#
# Copyright (c) 2017 Sam Cox, Roberto Sommariva
#
# This file is part of the AtChem2 software package.
#
# This file is covered by the MIT license which can be found in the file
# LICENSE.md at the top level of the AtChem2 distribution.
#
# -----------------------------------------------------------------------------

# Makefile for AtChem2

# choose fortran compiler
# 1. "gnu" for gfortran
# 2. "intel" for ifort
FORTC = "gnu"

# set the dependencies paths
# N.B.: use the FULL PATHS, not the relative paths
CVODELIB     = /rds/homes/a/allsoppj/AtChem/AtChem2/cvode/cvode/lib
OPENLIBMDIR  = /rds/homes/a/allsoppj/AtChem/AtChem2/openlibm/openlibm-0.8.1
FRUITDIR     = /rds/homes/a/allsoppj/atchem-lib/fruit_3.4.3


# default location of the chemical mechanism shared library (mechanism.so)
# use the second argument of the build script to override $SHAREDLIBDIR
SHAREDLIBDIR = model/configuration

# ================================================================== #
# DO NOT MODIFY BELOW THIS LINE
# ================================================================== #

.SUFFIXES:
.SUFFIXES: .f90 .o
.PHONY: all test

# detect operating system
OS := $(shell uname -s)

# if on GitHub Actions
ifeq ($(GITHUB_ACTIONS),true)
ifeq ($(RUNNER_OS),Linux)
# if linux, pass gfortran
FORT_COMP    = gfortran-$(FORT_VERSION)
FORT_LIB     = ""
else
# if macOS, pass homebrew gfortran
FORT_COMP    = /usr/local/bin/gfortran-$(FORT_VERSION)
FORT_LIB     = ""
endif
# if not on GitHub Actions, set the fortran compiler
else
ifeq ($(FORTC),"gnu")
FORT_COMP    = gfortran
FORT_LIB     = ""
endif
ifeq ($(FORTC),"intel")
FORT_COMP    = ifort
FORT_LIB     = ""
endif
endif

# set compilation flags for each compiler
ifeq ($(FORTC),"gnu")
FFLAGS       =  -O2 -fprofile-arcs -ftest-coverage -ffree-form -fimplicit-none -Wall -Wpedantic -fcheck=all -fPIC
FSHAREDFLAGS =  -ffree-line-length-none -ffree-form -fimplicit-none -Wall -Wpedantic -Wno-unused-dummy-argument -fcheck=all -fPIC -shared
endif
ifeq ($(FORTC),"intel")
FFLAGS       = -free -warn
FSHAREDFLAGS =
endif

# set rpath flag
ifeq ($(OS),Linux)
RPATH_OPTION = -R
else
RPATH_OPTION = -rpath
endif

# set other compiler flags
LDFLAGS = -L$(CVODELIB) -L$(OPENLIBMDIR) -Wl,$(RPATH_OPTION),/usr/lib/:$(CVODELIB):$(OPENLIBMDIR) -lopenlibm -lsundials_fcvode -lsundials_cvode -lsundials_fnvecserial -lsundials_nvecserial -ldl

# object files and source files directories
OBJ = obj
SRC = src

# executable
AOUT = hello

# source files
UNITTEST_SRCS = $(SRC)/dataStructures.f90 $(SRC)/solarFunctions.f90
SRCS = $(UNITTEST_SRCS) $(SRC)/hello.f90

# prerequisite is $(SRCS), so this will be rebuilt everytime any source file in $(SRCS) changes
$(AOUT): $(SRCS)
	$(FORT_COMP) -o $(AOUT) -J$(OBJ) -I$(OBJ) $(SRCS) $(FFLAGS) $(LDFLAGS)

# setup FRUIT
UNITTESTDIR = tests/unit_tests
fruit_code = $(FRUITDIR)/src/fruit.f90
unittest_code = $(UNITTEST_SRCS) $(shell ls tests/unit_tests/*_test.f90 )
unittest_code_gen = $(UNITTESTDIR)/fruit_basket_gen.f90 $(UNITTESTDIR)/fruit_driver_gen.f90
all_unittest_code = $(fruit_code) $(unittest_code) $(unittest_code_gen)
fruit_driver = $(UNITTESTDIR)/fruit_driver.exe

# copy fruit_generator.rb to the unit tests directory and replace the path of FRUIT with $(FRUITDIR)
$(UNITTESTDIR)/fruit_basket_gen.f90 : $(unittest_code)
	@cp tests/fruit_generator.rb $(UNITTESTDIR)
	@cd $(UNITTESTDIR); sed -i "18s,.*,load \"$(FRUITDIR)/rake_base.rb\"," fruit_generator.rb; ruby fruit_generator.rb

# build fruit_driver.exe from the individual unit tests
$(fruit_driver) : $(all_unittest_code)
	$(FORT_COMP) -o $(fruit_driver) -J$(OBJ) -I$(OBJ) $(all_unittest_code) $(FFLAGS) $(LDFLAGS)

# search tests/tests/ for all subdirectories, which should reflect the full list of tests
OLDTESTS := $(shell ls -d tests/tests/*/ | sed 's,tests/tests/,,g' | sed 's,/,,g')

# search tests/model_tests/ for all subdirectories, which should reflect the full list of tests
MODELTESTSDIR = tests/model_tests
MODELTESTS := $(shell ls -d tests/model_tests/*/ | sed 's,tests/model_tests/,,g' | sed 's,/,,g')

# ================================================================== #
# Makefile rules

all: $(AOUT)

indenttest:
	@./tests/run_indent_test.sh

styletest:
	@./tests/run_style_test.sh

unittests: $(fruit_driver)
	@echo "Fruit Driver ${fruit_driver}"
	@export DYLD_LIBRARY_PATH=$(FORT_LIB):$(CVODELIB):$(OPENLIBMDIR) ; $(fruit_driver)

oldtests:
	@echo "Make: Running the following tests:" $(OLDTESTS)
	@./tests/run_tests.sh "$(OLDTESTS)" "$(FORT_LIB):$(CVODELIB):$(OPENLIBMDIR)"

modeltests:
	@echo "Make: Running the following tests:" $(MODELTESTS)
	@echo "$(FORT_LIB)"
	@./tests/run_model_tests.sh "$(MODELTESTS)" "$(FORT_LIB):$(CVODELIB):$(OPENLIBMDIR)"

alltests: indenttest styletest unittests oldtests modeltests

sharedlib:
	$(FORT_COMP) -c $(SHAREDLIBDIR)/mechanism.f90 $(FSHAREDFLAGS) -o $(SHAREDLIBDIR)/mechanism.o -J$(OBJ)
	$(FORT_COMP) -shared -o $(SHAREDLIBDIR)/mechanism.so $(SHAREDLIBDIR)/mechanism.o

clean:
	rm -f *.o
	rm -f *.gcda *.gcno *.xml
	rm -f $(AOUT)
	rm -f $(OBJ)/*.mod
	rm -f tests/tests/*/*.out tests/tests/*/*.output tests/tests/*/reactionRates/*[0-9]
	rm -f $(MODELTESTSDIR)/*/*.out $(MODELTESTSDIR)/*/output/*.output $(MODELTESTSDIR)/*/output/reactionRates/*[0-9]
	rm -f $(UNITTESTDIR)/fruit_basket_gen.f90 $(UNITTESTDIR)/fruit_driver_gen.f90 $(fruit_driver)
	rm -f model/configuration/mechanism.{f90,o,prod,reac,ro2,so,species}
	rm -f tests/unit_tests/fruit*

# ================================================================== #
# Dependencies
hello.o : hello.f90 solarFunctions.o dataStructures.o
solarFunctions.o : solarFunctions.f90 dataStructures.o
dataStructures.o : dataStructures.f90

