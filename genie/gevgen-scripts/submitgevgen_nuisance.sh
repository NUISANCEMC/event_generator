#!/bin/sh
DATE=`date +%Y-%m-%d`
SCRIPTDIR=$PWD

# Get CVMFS PATH to XSec

# Setup Global Model Choices
XSECPATH=/path/to/xsec/
XSEC=$XSECPATH/gxspl-FNALsmall.xml
EVGENLIST=Default
MODEL=DefaultPlusMECWithNC-Default

# Make a model folder
mkdir $MODEL
cd $MODEL

# Loop Over Target/Flux Combos
for flux in MINERvA_fhc_numu MINERvA_rhc_numubar MINERvA_fhc_nuenuebar
do
    for target in C CH Fe Pb
    do

	# Skip weird combos
	if [[ "$target" != "CH" && "$flux" != "MINERvA_fhc_numu" ]]
	then
	    continue
	fi

	# Setup Inputs for specific event file
	FLUX=$flux
	TARGET=$target
	ENERGY=0.0,100.0
	OUTPUTDIR=$PWD

        # Make new script ( should use different one for SHEF/FNAL )
	SCRIPT=rungevgen_nuisance.$FLUX.$TARGET.$MODEL.$DATE.sh
	cp $SCRIPTDIR/base_gevgen_nuisance.sh $SCRIPT
	echo $SCRIPT

        # Replace FLUX, etc in the scripts
	sed -i -e "s#\@\@FLUX\@\@#$FLUX#g" $SCRIPT
	sed -i -e "s#\@\@TARGET\@\@#$TARGET#g" $SCRIPT
	sed -i -e "s#\@\@ENERGY\@\@#$ENERGY#g" $SCRIPT
	sed -i -e "s#\@\@XSECPATH\@\@#$XSECPATH#g" $SCRIPT
	sed -i -e "s#\@\@XSEC\@\@#$XSEC#g" $SCRIPT
	sed -i -e "s#\@\@EVGENLIST\@\@#$EVGENLIST#g" $SCRIPT
	sed -i -e "s#\@\@MODEL\@\@#$MODEL#g" $SCRIPT
	sed -i -e "s#\@\@OUTPUTDIR\@\@#$OUTPUTDIR#g" $SCRIPT
	rm ${SCRIPT}-e

	# Submit the script to the QUEUE ( should use different command for SHEF/FNAL )
	
    done
done
