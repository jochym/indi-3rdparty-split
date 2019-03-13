#!/bin/bash

set -x -e


sudo add-apt-repository -y ppa:mutlaqja/ppa
sudo apt-get -qq update
sudo apt-get -qq install libindi-dev