#!/bin/bash

ATLC2TCSVG_PATH=/tmp/ATLC2TCSVG.jar

HOST=eseo-tech.github.io
BASE=ecmfa2021-atlc-web/
PROTOCOL=https

if [ -e .env ] ; then
	source .env
fi

if [[ ! -e ${ATLC2TCSVG_PATH} ]];
then
    echo "set \$ATLC2TCSVG_PATH env var with correct path"
    exit 0
fi


process() {
	java -jar "${ATLC2TCSVG_PATH}"  \
	    -i ./Sequence2TCSVG.atl \
	    -o ./Sequence2TCSVG-uses$1.svg \
	    -v \
	    -n \
	    -g \
	    -s markers.svg \
	    --embedSVG ./uses$1.svg \
	    -M ../../../web/fr.eseo.atlc2tcsvg/resources/SVG.ecore \
	    -M ./Seq.ecore  \
	    -E Sequence2TCSVG.css \
	    -H "$HOST" \
	    -p "$PROTOCOL" \
	    -B "$BASE"
}


process 1
process 2
process 3

