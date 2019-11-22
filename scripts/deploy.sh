#!/bin/bash
# copies current version of modelica files to deploy directory
# must be run from within this folder

deploy=~/Documents/Promotion/code/modelica-deploy/HH-modelica
if [ -d "$deploy" ]; then
  echo "Removing $deploy ..."
  rm -rf "$deploy"
fi
echo "Copying files from ../HHmodelica to $deploy"
mkdir "$deploy"
cp -R ../HHmodelica "$deploy/"

