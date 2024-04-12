# nwbPipeline
organize iEEG (neuralynx and blackrock) recordings and convert raw data to nwb format.

## config.m

This script contains the global parameters for the pipeline.

## Nlx2Mat

This is the code to read raw neuralynx files. 
https://www.urut.ch/new/serendipity/index.php?/pages/nlxtomatlab.html

## spikeSort

The code for spike sorting, modified from PDM (by Emily) and Multi-Exp Analysis (by Chris Dao)

## scripts

The scripts to unpack raw data, spike detection, spike clustering, and export data to nwb format.

## matnwb:

Code to export data to nwb format. 
https://github.com/NeurodataWithoutBorders/matnwb
