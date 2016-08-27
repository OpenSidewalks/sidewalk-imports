# sidewalk-imports
Pre-processing and splitting sidewalk data for OSM tasking manager

These scripts support the preprocessing of sidewalk, curbramp, and crossing data 
in geojson format for import as tasks into the OSM-tasking manager.  They 
can be used to split geojson files into regions (we used census tracts), 
validated and convert geojson files to osm files that conform to this 
[proposed sidewalk schema](http://wiki.openstreetmap.org/wiki/Proposed_features/sidewalk_schema).  
Our [import proposal](http://wiki.openstreetmap.org/wiki/Seattle,_Washington/Sidewalk_Import) 
includes more details about our import plan and discussions with the OSM community.

### About this project
Learn more about OpenSidewalks [here](http://www.opensidewalks.com).

This repository and our import workflow are heavily based on the [LA 
Building Import](https://github.com/osmlab/labuildings).

## Prerequisites

    Python>=3.4
    pip
    virtualenv
    libxml2
    libxslt
    spatialindex
    GDAL

### Installing prerequisites on Mac OSX

    # install brew http://brew.sh

    brew install libxml2
    brew install libxslt
    brew install spatialindex
    brew install gdal

### Installing prerequisites on Ubuntu

    apt-get install python-pip
    apt-get install python-virtualenv
    apt-get install gdal-bin
    apt-get install libgdal-dev
    apt-get install libxml2-dev
    apt-get install libxslt-dev
    apt-get install python-lxml
    apt-get install python-dev
    apt-get install libspatialindex-dev
    apt-get install unzip

## Set up Python virtualenv and get dependencies
    # may need to easy_install pip and pip install virtualenv
    virtualenv -p python3 ~/venvs/sidewalks
    source ~/venvs/sidewalks/bin/activate
    pip install -r requirements.txt
    
   
## Usage

Run all stages:

    # Download data & run all data prep steps
    make all

Or run stages separately, like so:

    # Download and expand all data files
    make data
    
    # Create output directories
    make directories
    
    # Validate appropriate data for sidewalk geometry
    # Uses osmizer python module
    make validate

    # Chunk sidewalk, curbramp, and crossing files 
    # Chunked by census tract currently
    # (this will take a relatively long time)
    make chunks

    # Generate merged, importable .osm files.
    # Uses osmizer python module
    # This will populate the merged/ directory with one .osm file per
    # census tract group.
    # (this will probably take quite a long time)
    make merged

    # Clean all input and output data files:
    make clean

    # Create geojson file with data file links
    # For OSM Tasking Manager
    make links



