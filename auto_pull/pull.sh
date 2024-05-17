#!/bin/bash

# Perform a regular 'git pull origin main'
git pull origin main

# If an error occurs, perform a forced pull 'git pull -f origin main'
if [ $? -ne 0 ]; then
  git pull -f origin main
fi