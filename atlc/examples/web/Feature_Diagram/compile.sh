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

java -jar "${ATLC2TCSVG_PATH}"  \
    -i ./FeatureDiagram2TCSVG.atl \
    -o ./FeatureDiagram2TCSVG.svg \
    -v \
    --embedSVG ./FeatureDiagramSample.svguses \
    -M ../../../web/fr.eseo.atlc2tcsvg/resources/SVG.ecore \
    -M ./FeatureDiagram.ecore   \
    -H $HOST  \
    -p "$PROTOCOL" \
    -B $BASE
