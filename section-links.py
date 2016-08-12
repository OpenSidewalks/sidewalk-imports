# Meg Drouhard
# 8/12/16
# generate links for osm files using specified pattern and add to section file as property


import sys
import geojson
import argparse
# from pprint import pprint


###############################################################################

def addLinks(sectionFileName, pattern, key, outputpath):
	# Load section data
  with open(sectionFileName, "r") as sectionFile:     
      sectionData = geojson.load(sectionFile)

      # Add link pattern as property in each section
      for section in sectionData.features:   
          if key in section.properties:
              linkString = pattern % str(section.properties[key])
              section.properties["link"] = linkString
          else:
              sys.exit("Error: invalid key for geojson file.")

      try:
      	  with open(outputpath, "w") as outFile:
              geojson.dump(sectionData, outFile)
              print ("Links added in %s" % outputpath)
      except ValueError:
          print ("Error exporting " + fileName)
          print (sectionData)
          
  return


###################################################

# Parse arguments
parser = argparse.ArgumentParser(description="Generate links for sections in geojson file")

parser.add_argument("-s",
                        "--section-file",
                        dest="sectionFile",
                        required=True,
                        help="bounding box file (bounding boxes as list of features)")

parser.add_argument("-p",
                        "--pattern",
                        dest="pattern",
                        required=True,
                        help="pattern for file links")

parser.add_argument("-k",
                        "--key",
                        dest="key",
                        required=True,
                        help="geojson key for file identification")

parser.add_argument("-o",
                        "--output-path",
                        dest="outputpath",
                        required=False,
                        help="path for file output")

args = parser.parse_args()

# setup the arguments
if args.sectionFile:
    sectionFile = args.sectionFile
else:
    sys.exit("Error: missing section file.")

if args.pattern:
    pattern = args.pattern
else:
    sys.exit("Error: missing file link pattern.")

if args.key:
    key = args.key
else:
    sys.exit("Error: missing geojson key.")

if args.outputpath:
    outputpath = args.outputpath
else:
    outputpath = "links-out.geojson"


addLinks(sectionFile, pattern, key, outputpath)



	
			


