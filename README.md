# docker-wine-py2-py3
This repository contains a Dockerfile to create a docker container with
Python 2.7 and Python 3 for Windows running on wine for cross compiling with
py2exe and Visual Stution 2008 Express to build external modules.

This Dockerfile has been published as a trusted build to the public Docker Registry.

## Supported tags
* latest: for master branches

## What is wine-debian-py2-py3?
This image is intended to be used as part of a CICD build system to help you
compile your python projects in a controlled environment for Windows platform.

By [Patrik Dufresne Service Logiciel inc.](http://www.patrikdufresne.com)

## Usages

`python`, `pip`, `pyinstaller` command line are configured as aliases to run
there corresponding executable in wine.

To install more dependecies, you can use pip directly like this:

    pip install jinja2

To compile your python script into an `.exe` file:

    python setup.py py2exe --single-file
    
External C++ modules should also be build using Visual Studio 2008 compiler.
