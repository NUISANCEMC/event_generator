#!/bin/bash

# Setup UPS/CVFMS
source /cvmfs/minerva.opensciencegrid.org/minerva/NUISANCE_080117/nuisance/v2r6/builds/genie2126-nuwrov11qrw/Linux/setupcvmfs.sh

# Setup Running Options
FLUX=@@FLUX@@
TARGET=@@TARGET@@
ENERGY=@@ENERGY@@
XSECPATH=@@XSECPATH@@
XSEC=@@XSEC@@
EVGENLIST=@@EVGENLIST@@
MODEL=@@MODEL@@
OUTPUT=gnuistp.$FLUX.$TARGET.$MODEL.$EVGENLIST.$EVENTS.ghep.root
OUTPUTDIR=@@OUTPUTDIR@@

# Show Gevgen NUISANCE FLux Target List
gevgen_nuisance -h

# Actually run gevgen_nuisance
export GXMLPATH=$XSECPATH
gevgen_nuisance -f $FLUX -t $TARGET -e $ENERGY -n $EVENTS --cross-sections $XSEC  --event-generator-list $EVGENLIST \
    -o $OUTPUT | grep --ignore-case error

# Copy the outputs back to the working directory requested.
source /cvmfs/fermilab.opensciencegrid.org/products/common/etc/setups.sh
setup ifdhc
ifdh cp $OUTPUT $OUTPUTDIR
