#!/bin/bash

docker run --rm -it -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /media/andrei/0de85410-1d1d-4433-b5ba-177da71274fa/BiGit/GMD-backend/:/home/andrei/project/ \
    nix:latest