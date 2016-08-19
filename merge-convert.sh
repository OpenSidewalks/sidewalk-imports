# expected arguments
nargs=2
if [ "$#" -ne "$nargs" ]; then
  echo "Usage: merge-convert.sh <CHUNK-DIR> <OUTPUT-DIR>"
  exit 0
fi

CHUNKS=$1
CONVERTED=$2


# filenames for sidewalks, curbramps, crossings
sidewalks="sidewalks.geojson"
curbramps="curbramps.geojson"
crossings="crossings.geojson"

sidewalks_osm="sidewalks.osm"
curbramps_osm="curbramps.osm"
crossings_osm="crossings.osm"
temp="temp.osm"

#echo "running $0 $1 $2"

for d in "$CHUNKS"*/; do	
	# build output path for merged file from directory name
	outfile=$(basename $d)
	outpath="$OUTPUT$outfile.osm"
	
	# file paths for testing and converting
	sidewalks_in="$d$sidewalks"
	sidewalks_out="$d$sidewalks_osm"
	curbramps_in="$d$curbramps"
	curbramps_out="$d$curbramps_osm"
	crossings_in="$d$crossings"
	crossings_out="$d$crossings_osm"
	temp_merge="$d$temp"

	# if sidewalks
	if [ -f "$sidewalks_in" ]; then
		echo "osmizer convert sidewalks $sidewalks_in $sidewalks_out"
		osmizer convert sidewalks "$sidewalks_in" "$sidewalks_out"
		if [ -f "$curbramps_in" ]; then		
			osmizer convert curbramps "$curbramps_in" "$curbramps_out"
			osmizer merge "$sidewalks_out" "$curbramps_out" "$temp_merge"
			if [ -f "$crossings_in" ]; then
				osmizer convert crossings "$crossings_in" "$crossings_out"
				osmizer merge "$temp_merge" "$crossings_out" "$outpath"
				echo "sidewalks, curbramps, and crossings"
			else
				echo "sidewalks and curbramps only"
				mv "$temp_merge" "$outpath"
			fi
		elif [ -f "$crossings_in" ]; then
			echo "sidewalks and crossings only"
		else
			echo "sidewalks only"
			mv "$sidewalks_out" "$outpath"
		fi
	elif [ -f "$curbramps_in" ]; then	
		if [ -f "$crossings_in" ]; then
			echo "curbramps and crossings only"
		else
			echo "curbramps only"
			mv "$curbramps_out" "$outpath"
		fi
	elif [ -f "$crossings_in" ]; then	
		echo "crossings only"
		mv $crossings_out $outpath
	fi
	# so that it doesn't run too long before it's ready
	break
done