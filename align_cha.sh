#!/bin/bash

# Copyright 2016  er1k
# Apache 2.0

# Given audio and CHA transcript, generate a new CHA transcript
# with word-level timings, using Eesen decoder & models
# Calls:
#   scripts/parse_cha_xml.py
#   scripts/merge_align_cha.py

BASEDIR=$(dirname $0)

filename=$(basename "$1")
basename="${filename%.*}"
dirname=$(dirname "$1")
extension="${filename##*.}"

cd $BASEDIR

if [ $# -ne 1 ]; then
  echo "Usage: align_cha.sh <basename>.{wav,mp3,mp4,sph}'"
  echo "  requires that <basename>.cha exists in same folder"
  echo "Produces: word level alignments in   build/output/<basename>.cha"
  echo "  plaintext word level alignments in build/output/<basename>.ali"
  echo "  chatter XML in                     build/output/<basename>.xml"
  exit 1
fi

mkdir -p $BASEDIR/build/audio/base build/output

# Requires <basename>.xml CHATTER-ified conversion of <basename>.cha
if [ ! -f $dirname/$basename.xml ]; then
 ~/bin/lib/zulu8.17.0.3-jdk8.0.102-linux_x64/bin/java -cp lib/chatter.jar org.talkbank.chatter.App -inputFormat cha -outputFormat xml -output build/trans/$basename/$basename.xml /vagrant/$basename.cha
fi

./align.sh $1 # produces /vagrant/$basename.xml as side effect needed by next step
python scripts/merge_align_cha.py /vagrant/$basename.xml build/output/$basename.ali >build/trans/$basename/$basename.xml

# convert back to CHA format

 ~/bin/lib/zulu8.17.0.3-jdk8.0.102-linux_x64/bin/java -cp lib/chatter.jar org.talkbank.chatter.App -inputFormat xml -outputFormat cha -output build/output/$basename.cha build/trans/$basename/$basename.xml

# Don't copy intermediate files to output folder

#cp $dirname/$basename.stm build/output
#mv $dirname/$basename.xml build/output

