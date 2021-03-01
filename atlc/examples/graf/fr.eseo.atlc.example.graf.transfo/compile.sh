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
    -i src/fr/eseo/atlc/example/graf/transfo/Graf2TCSVG-noXML.atl \
    -o resources/Graf.svg \
    -E resources/Graf2TCSVG.css \
    -js resources/Graf2TCSVG.js \
    -v \
    -n \
    -M ../../../web/fr.eseo.atlc2tcsvg/resources/SVG.ecore \
    -M Graf=../fr.eseo.atlc.example.graf/model/graf.xcore  \
    -H $HOST  \
    -p "$PROTOCOL" \
    -B $BASE

