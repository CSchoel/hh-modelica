#!/bin/bash
deploy=~/Documents/Promotion/code/modelica-deploy/HH-modelica
if [ -d "$deploy" ]; then
  echo Removing $deploy ...
  rm -rf "$deploy"
fi
echo Copying files from ../HHmodelica to $deploy
mkdir "$deploy"
cp -R ../HHmodelica "$deploy/"
