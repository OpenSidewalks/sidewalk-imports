# Meg Drouhard
# 8/10/16
# split geojson files into sections specified in another geojson file


import sys
# import os, os.path
import geojson
import argparse
from rtree import index
from shapely.geometry import asShape
from shapely import speedups
from pprint import pprint

speedups.enable()


###############################################################################

def chunk(sectionFileName, featureFileName, pattern, key=None):
  # Load and index
  with open(featureFileName, "r") as featureFile:
      featureData = geojson.load(featureFile)

      featureType = featureData.type
      
      # Set specified crs if present; otherwise use default
      if "crs" in featureData:
          featureCrs = featureData.crs
      else:
          featureCrs = { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } }


      featureIdx = index.Index()
      features = []
      # Store features with indices so that they can be purged, not included multiply
      featuresPurged = {}
      for feature in featureData.features:
          try:
              shape = asShape(feature["geometry"])
              features.append(feature)

              featureIndex = len(features) - 1
              featureIdx.add(featureIndex, shape.bounds)
              featuresPurged[featureIndex] = feature
          except ValueError:
              print ("Error parsing feature")
              pprint(feature)
      # Break up by sections and export
      with open(sectionFileName, "r") as sectionFile:
          sectionData = geojson.load(sectionFile)

          i = 0
          sectionFeatures = []
          for section in sectionData.features:
              fileName = pattern % i
              if key:
                  fileName = pattern % str(section.properties[key])
                  try:
                      with open(fileName, "w") as exportFile:
                          sectionShape = asShape(section["geometry"])
                          for j in featureIdx.intersection(sectionShape.bounds):
                              # only considered features that haven't been deleted from purged dict
                              if j in featuresPurged:
                                  if asShape(features[j]["geometry"]).intersects(sectionShape):
                                      sectionFeatures.append(features[j])
                                      del featuresPurged[j]
                          #only export non-empty FeatureCollections:
                          if len(sectionFeatures) > 0:
                              sectionGeojson = geojson.FeatureCollection(sectionFeatures)
                              sectionGeojson["crs"] = featureCrs

                              # write geojson to file
                              geojson.dump(sectionGeojson, exportFile)
                              print ("Exported %s" % fileName)

                          i = i + 1
                  except ValueError:
                      print ("Error exporting " + fileName)
                      print (sectionGeojson)
                      break
  return


###################################################

# Parse arguments
parser = argparse.ArgumentParser(description="OSM data chunker")

parser.add_argument("-s",
                        "--section-file",
                        dest="sectionFile",
                        required=True,
                        help="bounding box file (bounding boxes as list of features)")

parser.add_argument("-f",
                        "--featureFile",
                        dest="featureFile",
                        required=True,
                        help="file with features")

parser.add_argument("-o",
                        "--output-pattern",
                        dest="outputpattern",
                        required=True,
                        help="output path name")

parser.add_argument("-k",
                        "--key",
                        dest="key",
                        required=False,
                        help="key for file identification")

args = parser.parse_args()

# setup the arguments
if args.sectionFile:
    sectionFile = args.sectionFile
else:
    sys.exit("Error: missing section file.")

if args.featureFile:
    featureFile = args.featureFile
else:
    sys.exit("Error: missing input OSM feature file.")

if args.outputpattern:
    pattern = args.outputpattern
else:
    sys.exit("Error: missing output file pattern.")

# process and chunk using key if provided
if args.key:
    chunk(sectionFile, featureFile, pattern, args.key)
else:
	  chunk(sectionFile, featureFile, pattern)



	
			


