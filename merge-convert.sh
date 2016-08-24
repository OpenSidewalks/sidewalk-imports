# expected arguments
nargs=2
if [ "$#" -ne "$nargs" ]; then
  echo "Usage: merge-convert.sh <CHUNK-DIR/> <OUTPUT-DIR/>"
  exit 0
fi

CHUNKS=$1
OUTPUT=$2


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
		osmizer convert sidewalks "$sidewalks_in" "$sidewalks_out"
		
		# if sidewalks & curbramps
		if [ -f "$curbramps_in" ]; then		
			osmizer convert curbramps "$curbramps_in" "$curbramps_out"
			osmizer merge "$sidewalks_out" "$curbramps_out" "$temp_merge"

			# if sidewalks, curbramps, and crossings
			if [ -f "$crossings_in" ]; then
				osmizer convert crossings "$crossings_in" "$crossings_out"
				osmizer merge "$temp_merge" "$crossings_out" "$outpath"
				rm "$temp_merge"
				# echo "CASE 1 - sidewalks, curbramps, and crossings"
			
			# if sidewalks & curbramps only
			else
				mv "$temp_merge" "$outpath"
				# echo "CASE 2 - sidewalks and curbramps only"
			fi
		
		# if sidewalks & crossings only
		elif [ -f "$crossings_in" ]; then
			osmizer convert crossings "$crossings_in" "$crossings_out"
			osmizer merge "$sidewalks_out" "$crossings_out" "$outpath"
			# echo "CASE 3 - sidewalks and crossings only"
		
		# if sidewalks only
		else
			mv "$sidewalks_out" "$outpath"
			# echo "CASE 4 - sidewalks only"
		fi
	
	# if curbramps (and NOT sidewalks)
	elif [ -f "$curbramps_in" ]; then	
		osmizer convert curbramps "$curbramps_in" "$curbramps_out"

		# if curbramps and crossings only
		if [ -f "$crossings_in" ]; then
			osmizer convert crossings "$crossings_in" "$crossings_out"
			osmizer merge "$curbramps_out" "$crossings_out" "$outpath"
			# echo "CASE 5 - curbramps and crossings only"
		
		# if curbramps only
		else
			mv "$curbramps_out" "$outpath"
			# echo "CASE 6 - curbramps only"
		fi
	
	# if crossings only
	elif [ -f "$crossings_in" ]; then
		osmizer convert crossings "$crossings_in" "$outpath"
		# echo "CASE 7 - crossings only"
	fi
done