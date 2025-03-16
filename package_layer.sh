#!/bin/bash
set -e  # Stop script on error

# 1️ Create a new directory for dependencies
mkdir -p layer/python


pip install -r requirements.txt -t layer/python

# 3️ Zip the folder
cd layer && zip -r ../lambda_layer.zip . && cd ..
