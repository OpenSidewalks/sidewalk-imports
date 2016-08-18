all: data directories validate chunks convert merge osm links

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

validate: directories data/sidewalks/seattle-sidewalks/sidewalks.geojson data/sidewalks/seattle-sidewalks/curbramps.geojson data/sidewalks/seattle-sidewalks/crossings.geojson
	osmizer validate sidewalks data/sidewalks/seattle-sidewalks/sidewalks.geojson
	osmizer validate curbramps data/sidewalks/seattle-sidewalks/curbramps.geojson
	osmizer validate crossings data/sidewalks/seattle-sidewalks/crossings.geojson


chunks: data/census-tracts.geojson data/sidewalks/seattle-sidewalks/sidewalks.geojson data/sidewalks/seattle-sidewalks/curbramps.geojson data/sidewalks/seattle-sidewalks/crossings.geojson
	python chunk.py -s data/census-tracts.geojson -f data/sidewalks/seattle-sidewalks/sidewalks.geojson -o output/chunks/sidewalks/sidewalks-%s.geojson -k geoid
	python chunk.py -s data/census-tracts.geojson -f data/sidewalks/seattle-sidewalks/curbramps.geojson -o output/chunks/curbramps/curbramps-%s.geojson -k geoid
	python chunk.py -s data/census-tracts.geojson -f data/sidewalks/seattle-sidewalks/crossings.geojson -o output/chunks/crossings/crossings-%s.geojson -k geoid

osm: output/chunks/sidewalks/sidewalks-*.geojson
	# sidewalks
	for f in output/chunks/sidewalks/sidewalks-*.geojson; do \ 
	fout="${f##*/}"; \
	fout="${fout%%.*}"; \
	fout="output/osm/sidewalks/${fout}.osm"; \
	osmizer convert sidewalks f fout; \
	done
	# curbramps
	# crossings

merge: convert
#	python merge.py

links: merge
	python section-links.py -s data/census-tracts.geojson -p https://taskfiles.opensidewalks.com/task/%s.osm -k geoid -o output/links/census-tracts-links.geojson

directories:
	mkdir -p output
	mkdir -p output/chunks/sidewalks
	mkdir -p output/chunks/crossings
	mkdir -p output/chunks/curbramps
	mkdir -p output/osm/sidewalks
	mkdir -p output/osm/crossings
	mkdir -p output/osm/curbramps
	mkdir -p output/merged
	mkdir -p output/links
