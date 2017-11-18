# Copyright (C) 2016 and later: Unicode, Inc. and others.
# License & terms of use: http://www.unicode.org/copyright.html
#**********************************************************************
#* Copyright (C) 1999-2015, International Business Machines Corporation
#* and others.  All Rights Reserved.
#**********************************************************************
#
#   03/19/2001  weiv, schererm  Created

.SUFFIXES : .res .txt

TESTPKG=testdata
TESTDT=$(TESTPKG)

!if "$(ICUNMAKE)" == "1"
DLL_OUTPUT = $(PROJECTDIR)\$(CFG)\$(PLAT)

GENBRK_PATH = $(DLL_OUTPUT)
GENCFU_PATH = $(DLL_OUTPUT)
GENCNVAL_PATH = $(DLL_OUTPUT)
GENDICT_PATH = $(DLL_OUTPUT)
GENNORM2_PATH = $(DLL_OUTPUT)
GENRB_PATH = $(DLL_OUTPUT)
GENSPREP_PATH = $(DLL_OUTPUT)
GENTEST_PATH = $(DLL_OUTPUT)
ICUPKG_PATH = $(DLL_OUTPUT)
MAKECONV_PATH = $(DLL_OUTPUT)
!else
GENBRK_PATH = $(ICUTOOLS)\genbrk\$(CFGTOOLS)
GENCFU_PATH = $(ICUTOOLS)\gencfu\$(CFGTOOLS)
GENCNVAL_PATH = $(ICUTOOLS)\gencnval\$(CFGTOOLS)
GENDICT_PATH = $(ICUTOOLS)\gendict\$(CFGTOOLS)
GENRB_PATH = $(ICUTOOLS)\genrb\$(CFGTOOLS)
GENNORM2_PATH = $(ICUTOOLS)\gennorm2\$(CFGTOOLS)
GENSPREP_PATH = $(ICUTOOLS)\gensprep\$(CFGTOOLS)
GENTEST_PATH = $(ICUTOOLS)\gentest\$(CFGTOOLS)
ICUPKG_PATH = $(ICUTOOLS)\icupkg\$(CFGTOOLS)
MAKECONV_PATH = $(ICUTOOLS)\makeconv\$(CFGTOOLS)
!endif


ALL : "$(TESTDATAOUT)\testdata.dat" 
	@echo Test data is built.

# old_l_testtypes.res is there for cintltst/udatatst.c/TestSwapData()
# I generated it with an ICU 4.2.1 build on Linux after removing
# testincludeUTF (which would make it large, unnecessarily for this test)
# and renaming the collations element to avoid build CollationElements
# (which will not work with a newer swapper)
# markus 2010jan15

# old_e_testtypes.res is the same, but icuswapped to big-endian EBCDIC

# the following file has $(TEST_RES_SOURCE)
!INCLUDE "$(TESTDATA)\tstfiles.mk"

TEST_RES_FILES = $(TEST_RES_SOURCE:.txt=.res)

"$(TESTDATAOUT)\testdata.dat" : $(TEST_RES_FILES) "$(TESTDATABLD)\casing.res" "$(TESTDATABLD)\conversion.res" "$(TESTDATABLD)\icuio.res" "$(TESTDATABLD)\mc.res" "$(TESTDATABLD)\structLocale.res" "$(TESTDATABLD)\root.res" "$(TESTDATABLD)\sh.res" "$(TESTDATABLD)\sh_YU.res"  "$(TESTDATABLD)\te.res" "$(TESTDATABLD)\te_IN.res" "$(TESTDATABLD)\te_IN_REVISED.res" "$(TESTDATABLD)\testaliases.res" "$(TESTDATABLD)\testtypes.res" "$(TESTDATABLD)\testempty.res" "$(TESTDATABLD)\encoded.res" "$(TESTDATABLD)\idna_rules.res" "$(TESTDATABLD)\test.icu" "$(TESTDATABLD)\testtable32.res" "$(TESTDATABLD)\test1.cnv" "$(TESTDATABLD)\test1bmp.cnv" "$(TESTDATABLD)\test2.cnv" "$(TESTDATABLD)\test3.cnv" "$(TESTDATABLD)\test4.cnv" "$(TESTDATABLD)\test4x.cnv" "$(TESTDATABLD)\test5.cnv" "$(TESTDATABLD)\ibm9027.cnv" "$(TESTDATABLD)\nfscsi.spp" "$(TESTDATABLD)\nfscss.spp" "$(TESTDATABLD)\nfscis.spp" "$(TESTDATABLD)\nfsmxs.spp" "$(TESTDATABLD)\nfsmxp.spp" "$(TESTDATABLD)\testnorm.nrm" "$(TESTDATABLD)\zoneinfo64.res"
	@echo Building test data
	@copy "$(TESTDATABLD)\te.res" "$(TESTDATAOUT)\$(TESTDT)\nam.typ"
	@copy "$(TESTDATA)\old_l_testtypes.res" "$(TESTDATABLD)"
	@copy "$(TESTDATA)\old_e_testtypes.res" "$(TESTDATABLD)"
	@copy "$(TESTDATABLD)\zoneinfo64.res" "$(TESTDATAOUT)\$(TESTDT)"
	"$(ICUPBIN)\pkgdata" -f -v -m common -c -p"$(TESTPKG)" -d "$(TESTDATAOUT)" -T "$(TESTDATABLD)" -s "$(TESTDATABLD)" <<
casing.res
conversion.res
mc.res
root.res
testtable32.res
sh.res
sh_YU.res
te.res
te_IN.res
te_IN_REVISED.res
testtypes.res
old_l_testtypes.res
old_e_testtypes.res
testempty.res
testaliases.res
structLocale.res
icuio.res
encoded.res
test.icu
test1.cnv
test1bmp.cnv
test2.cnv
test3.cnv
test4.cnv
test4x.cnv
test5.cnv
ibm9027.cnv
idna_rules.res
nfscsi.spp
nfscss.spp
nfscis.spp
nfsmxs.spp
nfsmxp.spp
testnorm.nrm
$(TEST_RES_FILES:.res =.res
)
<<


# Inference rule for creating resource bundles
# Some test data resource bundles are known to have warnings and bad data.
# The -q option is there on purpose, so we don't see it normally.
{$(TESTDATA)}.txt.res:: 
	@echo Making Test Resource Bundle files $<
	@"$(GENRB_PATH)\genrb" -q -s"$(TESTDATA)" -d"$(TESTDATABLD)" $<

"$(TESTDATABLD)\encoded.res": "$(TESTDATA)\encoded.utf16be"
	@echo Making Test Resource Bundle file with encoding
	"$(GENRB_PATH)\genrb" -s"$(TESTDATA)" -eUTF-16BE -d"$(TESTDATABLD)" encoded.utf16be

"$(TESTDATABLD)\idna_rules.res": "$(TESTDATA)\idna_rules.txt"
	@echo Making Test Resource Bundle file for IDNA reference implementation
	@"$(GENRB_PATH)\genrb" -s"$(TESTDATA)" -d"$(TESTDATABLD)" idna_rules.txt


"$(TESTDATABLD)\test.icu" : {"$(GENTEST_PATH)"}gentest.exe
	"$(GENTEST_PATH)\gentest" -d"$(TESTDATABLD)"

# testtable32 resource file
"$(TESTDATABLD)\testtable32.txt" : {"$(GENTEST_PATH)"}gentest.exe
	"$(GENTEST_PATH)\gentest" -r -d"$(TESTDATABLD)"

"$(TESTDATABLD)\testtable32.res": "$(TESTDATABLD)\testtable32.txt"
	"$(GENRB_PATH)\genrb" -s"$(TESTDATABLD)" -d"$(TESTDATABLD)" testtable32.txt

# Targets for nfscsi.spp
"$(TESTDATABLD)\nfscsi.spp" : {"$(GENSPREP_PATH)"}gensprep.exe "$(TESTDATA)\nfs4_cs_prep_ci.txt"
	@echo Building $@
	@"$(GENSPREP_PATH)\gensprep" -s "$(TESTDATA)" -d "$(TESTDATABLD)\\" -b nfscsi -u 3.2.0 nfs4_cs_prep_ci.txt

# Targets for nfscss.spp
"$(TESTDATABLD)\nfscss.spp" : {"$(GENSPREP_PATH)"}gensprep.exe "$(TESTDATA)\nfs4_cs_prep_cs.txt"
	@echo Building $@
	@"$(GENSPREP_PATH)\gensprep" -s "$(TESTDATA)" -d "$(TESTDATABLD)\\" -b nfscss -u 3.2.0 nfs4_cs_prep_cs.txt

# Targets for nfscis.spp
"$(TESTDATABLD)\nfscis.spp" : {"$(GENSPREP_PATH)"}gensprep.exe "$(TESTDATA)\nfs4_cis_prep.txt"
	@echo Building $@
	@"$(GENSPREP_PATH)\gensprep" -s "$(TESTDATA)" -d "$(TESTDATABLD)\\" -b nfscis -u 3.2.0 -k -n "$(ICUTOOLS)\..\data\unidata" nfs4_cis_prep.txt

# Targets for nfsmxs.spp
"$(TESTDATABLD)\nfsmxs.spp" : {"$(GENSPREP_PATH)"}gensprep.exe "$(TESTDATA)\nfs4_mixed_prep_s.txt"
	@echo Building $@
	@"$(GENSPREP_PATH)\gensprep" -s "$(TESTDATA)" -d "$(TESTDATABLD)\\" -b nfsmxs -u 3.2.0 -k -n "$(ICUTOOLS)\..\data\unidata" nfs4_mixed_prep_s.txt

# Targets for nfsmxp.spp
"$(TESTDATABLD)\nfsmxp.spp" : {"$(GENSPREP_PATH)"}gensprep.exe "$(TESTDATA)\nfs4_mixed_prep_p.txt"
	@echo Building $@
	@"$(GENSPREP_PATH)\gensprep" -s "$(TESTDATA)" -d "$(TESTDATABLD)\\" -b nfsmxp -u 3.2.0 -k -n "$(ICUTOOLS)\..\data\unidata" nfs4_mixed_prep_p.txt


# Targets for test converter data
"$(TESTDATABLD)\test1.cnv": "$(TESTDATA)\test1.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test1bmp.cnv": "$(TESTDATA)\test1bmp.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test2.cnv": "$(TESTDATA)\test2.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test3.cnv": "$(TESTDATA)\test3.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test4.cnv": "$(TESTDATA)\test4.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test4x.cnv": "$(TESTDATA)\test4x.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\test5.cnv": "$(TESTDATA)\test5.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

"$(TESTDATABLD)\ibm9027.cnv": "$(TESTDATA)\ibm9027.ucm"
	@echo Building $@
	@"$(MAKECONV_PATH)\makeconv" --small -d"$(TESTDATABLD)" $**

# Target for test normalization data
"$(TESTDATABLD)\testnorm.nrm": "$(TESTDATA)\testnorm.txt"
	@echo Building $@
	@"$(GENNORM2_PATH)\gennorm2" -s "$(TESTDATA)" testnorm.txt -o $@