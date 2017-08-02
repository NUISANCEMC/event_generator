#!/bin/sh

# Check external is setup correctly
if [ $NUISANCE_EXTERNAL != "" ]
then
    if [ -f $NUISANCE_EXTERNAL/setupexternal.sh ]
    then
	echo "Reading Externals from script $NUISANCE_EXTERNAL/setupexternal.sh"
	source $NUISANCE_EXTERNAL/setupexternal.sh
    else
	echo 'Cannot find $NUISANCE_EXTERNAL/setupexternal.sh script!'
	return -1
    fi
else
    echo "NUISANCE_EXTERNAL ENV Var not set! Point this at the external builds!"
    return -1
fi

# Checkout GENIE
VER=$1
if [[ "$VER" != "" && "$VER" != *"/" ]]; then  VER=${VER}/; fi
ALLGENIEVER=$(svn list http://genie.hepforge.org/svn/generator/branches)
if [[ "$VER" == "" || "$ALLGENIEVER" != *"$VER"* ]]
then
    echo "You must supply a GENIE version! Available Branches Below:"
    svn list http://genie.hepforge.org/svn/generator/branches
    return -1
fi
VER=${VER/\//}
DATE=`date +%Y-%m-%d`
GENIEBUILDDIR=genie-$VER-build
mkdir $VER
cd $VER
echo "Checking out GENIE $VER and saving to : $GENIEBUILDDIR"
svn co http://genie.hepforge.org/svn/generator/branches/$VER ./$GENIEBUILDDIR
cd $GENIEBUILDDIR

# Make a GENIE Setup Script
echo "Creating a new setup script."
echo "#!/bin/sh" > setup.sh
echo "export NUISANCE_EXTERNAL=$NUISANCE_EXTERNAL" >> setup.sh
echo 'source $NUISANCE_EXTERNAL/setupexternal.sh' >> setup.sh
echo 'export GENIE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"' >> setup.sh
echo 'export LD_LIBRARY_PATH=$GENIE/lib::$LD_LIBRARY_PATH' >> setup.sh
echo 'export PATH=$GENIE/bin:$PATH' >> setup.sh
echo 'export GENIE_LIBS=$GENIE/lib' >> setup.sh
echo 'export NUISANCE_BUILD_FLAGS="$NUISANCE_BUILD_FLAGS -DUSE_GENIE=1"' >> setup.sh
if [ $VER == 'R-2_12'* ]
then
    echo 'export NUISANCE_BUILD_FLAGS="$NUISANCE_BUILD_FLAGS -DBUILD_GEVGEN=1"' >> setup.sh
fi
source setup.sh

# Actually Build GENIE
./configure --disable-profiler  \
            --disable-validation-tools  \
            --disable-cernlib  \
            --enable-lhapdf \
            --with-lhapdf-lib=$LHAPDF_LIB \
            --with-lhapdf-inc=$LHAPDF_INC \
            --enable-flux-drivers \
            --enable-geom-drivers \
            --disable-doxygen \
            --enable-test  \
            --enable-mueloss \
            --enable-dylibversion  \
            --enable-t2k \
            --enable-fnal \
            --enable-atmo \
            --enable-nucleon-decay \
            --enable-rwght \
            --disable-masterclass \
            --disable-debug \
            --with-optimiz-level=O2 \
            --with-pythia6-lib=$PYTHIA6 \
            --with-log4cpp-inc=$LOG4CPP_INC \
            --with-log4cpp-lib=$LOG4CPP_LIB \
            --with-libxml2-inc=/usr/include/libxml2/ \
            --with-libxml2-lib=/usr/lib/  

make

# Now move up one directory and make an event folder for splines
#cd ../
#mkdir DefaultPlusMECWithNC
#cd DefaultPlusMECWithNC
#mkdir config
#cd config/
#wget https://www.hepforge.org/archive/genie/data/2.12.6/genie_xsec-2.12.6-noarch-DefaultPlusMECWithNC.tar.bz2
#tar -x genie_xsec-2.12.6-noarch-DefaultPlusMECWithNC.tar.bz2
#rm genie_xsec-2.12.6-noarch-DefaultPlusMECWithNC.tar.bz2
