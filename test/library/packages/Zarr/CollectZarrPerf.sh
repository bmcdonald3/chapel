#!/bin/bash

scales="strong weak"
chunkSizes="0.001 0.01 0.3"
compressionLevels="0 5 9"
threadCounts="1 4"
locales="1 2 4 8"
echo "Scaling,Locales,Compression Level,Blosc Threads,Array Size,Chunk Size"

for scale in $scales; do
  for arraySize in $arraySizes; do
    for chunkSize in $chunkSizes; do
      for compressionLevel in $compressionLevels; do
        for threadCount in $threadCounts; do
          for locale in $locales; do
            ./ZarrPerf -nl $locale --scaling=$scale --arrayGBs=$arraySize --chunkGBs=$chunkSize --compressionLevel=$compressionLevel --bloscThreads=$threadCount
          done
        done
      done
    done
  done
done