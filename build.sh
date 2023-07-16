#!/bin/sh

python -m pip install --upgrade pip
python -m pip install pip-tools
# make requirements.txt from requirements.in
pip-compile


