# directory vars
INPUT=data
OUTPUT=output
CHUNKS=$(OUTPUT)/chunks/
SIDEWALK-DATA=$(INPUT)/sidewalks/seattle-sidewalks/
MERGED=$(OUTPUT)/merged/
LINKS=$(OUTPUT)/links/

# download data & run all data prep steps
all: data directories validate chunks merged links

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
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/sidewalks.geojson -o $(CHUNKS)/%s/sidewalks.geojson -k geoid
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/curbramps.geojson -o $(CHUNKS)/%s/curbramps.geojson -k geoid
	python chunk.py -s $(INPUT)/census-tracts.geojson -f $(SIDEWALK-DATA)/crossings.geojson -o $(CHUNKS)/%s/crossings.geojson -k geoid

# convert to osm files and merge all features using osmizer
merged:
	bash merge-convert.sh $(CHUNKS) $(MERGED)

links: 
	python section-links.py -s $(INPUT)/census-tracts.geojson -p https://import.opensidewalks.com/seattle_import/merged-%s.osm -k geoid -o $(LINKS)/census-tracts-links.geojson

directories:
	mkdir -p $(OUTPUT)
	mkdir -p $(CHUNKS)
	mkdir -p $(MERGED)
	mkdir -p $(LINKS)
