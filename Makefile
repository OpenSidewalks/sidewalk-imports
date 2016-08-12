all: data directories chunks merged osm links

clean:
	rm -rf data
	rm -rf output

CensusTracts: 
	rm -f data/census-tracts.geojson
	curl -L "https://raw.githubusercontent.com/OpenSidewalks/data/master/census-tracts.geojson" --create-dirs -o data/census-tracts.geojson

Sidewalks.zip:
	curl -L "https://raw.githubusercontent.com/OpenSidewalks/data/master/seattle-sidewalks.zip" --create-dirs -o data/sidewalks.zip

Sidewalks: Sidewalks.zip
	rm -rf data/sidewalks
	unzip data/sidewalks.zip -d data/sidewalks
	rm -rf data/sidewalks/__MACOSX
	rm -f data/sidewalks.zip

data: CensusTracts Sidewalks

chunks: data directories
	# python chunk.py AddressPt/addresses.shp BlockGroupPly/blockgroups.shp chunks/addresses-%s.shp GEOID
	# python chunk.py BldgPly/buildings.shp BlockGroupPly/blockgroups.shp chunks/buildings-%s.shp GEOID

merged: directories
#	python merge.py

osm: merged
#	python convert.py merged/*

links: osm
	python section-links.py -s data/census-tracts.geojson -p https://taskfiles.opensidewalks.com/task/%s.osm -k geoid -o output/links/census-tracts-links.geojson

directories:
	mkdir -p output
	mkdir -p output/chunks
	mkdir -p output/merged
	mkdir -p output/osm
	mkdir -p output/links
