# directory vars
INPUT=data
OUTPUT=output
CHUNKS=$(OUTPUT)/chunks
OSM=$(OUTPUT)/osm

SIDEWALK-DATA=$(INPUT)/sidewalks/seattle-sidewalks

# SIDEWALK-CHUNKS=$(OUTPUT)/chunks/sidewalks
# CURBRAMP-CHUNKS=$(OUTPUT)/chunks/curbramps
# CROSSING-CHUNKS=$(OUTPUT)/chunks/crossings

# SIDEWALK-OSM=$(OUTPUT)/osm/sidewalks
# CURBRAMP-OSM=$(OUTPUT)/osm/curbramps
# CROSSING-OSM=$(OUTPUT)/osm/crossings

MERGED=$(OUTPUT)/merged
LINKS=$(OUTPUT)/links

# functions (expand file and directory vars from foreach function and run osmizer from shell)
CONVERT-SIDEWALKS=$(shell osmizer convert sidewalks $(wildcard $(f)) $(SIDEWALK-OSM)/`basename $(wildcard $(f)) .geojson`.osm)
CONVERT-CURBRAMPS=$(shell osmizer convert curbramps $(wildcard $(f)) $(CURBRAMP-OSM)/`basename $(wildcard $(f)) .geojson`.osm)
CONVERT-CROSSINGS=$(shell osmizer convert crossings $(wildcard $(f)) $(CROSSING-OSM)/`basename $(wildcard $(f)) .geojson`.osm)


all: data directories validate chunks convert merge osm links

clean:
	rm -rf $(INPUT)
	rm -rf $(OUTPUT)

CensusTracts: 
	rm -f $(INPUT)/census-tracts.geojson
	curl -L "https://raw.githubusercontent.com/OpenSidewalks/data/master/census-tracts.geojson" --create-dirs -o $(INPUT)/census-tracts.geojson

Sidewalks.zip:
	curl -L "https://raw.githubusercontent.com/OpenSidewalks/data/master/seattle-sidewalks.zip" --create-dirs -o $(INPUT)/sidewalks.zip

Sidewalks: Sidewalks.zip
	rm -rf $(INPUT)/sidewalks
	unzip $(INPUT)/sidewalks.zip -d $(INPUT)/sidewalks
	rm -rf $(INPUT)/sidewalks/__MACOSX
	rm -f $(INPUT)/sidewalks.zip

data: CensusTracts Sidewalks

# validate using osmizer
validate: directories $(SIDEWALK-DATA)/*.geojson
	osmizer validate sidewalks $(SIDEWALK-DATA)/sidewalks.geojson
	osmizer validate curbramps $(SIDEWALK-DATA)/curbramps.geojson
	osmizer validate crossings $(SIDEWALK-DATA)/crossings.geojson

chunks: $(INPUT)/census-tracts.geojson $(SIDEWALK-DATA)/sidewalks.geojson $(SIDEWALK-DATA)/curbramps.geojson $(SIDEWALK-DATA)/crossings.geojson
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/sidewalks.geojson -o $(SIDEWALK-CHUNKS)/sidewalks-%s.geojson -k geoid
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/curbramps.geojson -o $(CURBRAMP-CHUNKS)/curbramps-%s.geojson -k geoid
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/crossings.geojson -o $(CROSSING-CHUNKS)/crossings-%s.geojson -k geoid

# convert to osm files using osmizer
osm: $(SIDEWALK-CHUNKS)/sidewalks-*.geojson $(CURBRAMP-CHUNKS)/curbramps-*.geojson) $(CROSSING-CHUNKS)/crossings-*.geojson)
	$(foreach f, $(wildcard $(SIDEWALK-CHUNKS)/sidewalks-*.geojson), $(CONVERT-SIDEWALKS))
	$(foreach f, $(wildcard $(CURBRAMP-CHUNKS)/curbramps-*.geojson), $(CONVERT-CURBRAMPS))
	$(foreach f, $(wildcard $(CROSSING-CHUNKS)/crossings-*.geojson), $(CONVERT-CROSSINGS))

# merge sidewalks, curbramps, and crossings using osmizer
merge: $(INPUT)/census-tracts.txt
	bash merge-census-tracts.sh $(INPUT)/census-tracts.txt t

links: 
	python section-links.py -s $(INPUT)/census-tracts.geojson -p https://taskfiles.opensidewalks.com/task/%s.osm -k geoid -o $(LINKS)/census-tracts-links.geojson

directories:
	mkdir -p $(OUTPUT)
	mkdir -p $(CHUNKS)
	mkdir -p $(OSM)
	# mkdir -p $(SIDEWALK-CHUNKS)
	# mkdir -p $(CURBRAMP-CHUNKS)
	# mkdir -p $(CROSSING-CHUNKS)
	# mkdir -p $(SIDEWALK-OSM)
	# mkdir -p $(CURBRAMP-OSM)
	# mkdir -p $(CROSSING-OSM)
	mkdir -p $(MERGED)
	mkdir -p $(LINKS)
