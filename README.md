# MC-Ratio-96-wells
ImageJ macro for analyzing fluorescence data obtained in 96 wells plates
blabla
## Requirements
Runs on 2019 FIJI and ImageJ 
The macros were tested on MacOS Mojave (10.14.5) running:
ImageJ v1.52p with Java 1.8.0_101 (64-bit) and on Fiji Version 2.0.0-rc-69/1.52p.

The macros were tested also on Windows 10 (version 1803 for x64-based systems) running:
ImageJ v1.52p with Java 1.8.0_112 (64-bit) and on Fiji version 1.52p running with Java 1.8.0 172 (64-bit)

BioFormats v.6.1.1 or v 6.1.0 (https://www.openmicroscopy.org/bio-formats/) must be installed in ImageJ. In Fiji this is installed automatically.

For usage see main manuscript Secondary screen - Cellular brightness in mammalian cells.

## Usage
ImageJ & FIJI macro's can be dragged and droppped on the toolbar, which opens the editor from which the macros can be started.
Macros can also be loaded via Plugins->Macros menu, either use Edit or Run.

## Test data
Test can be downloaded from following zenodo repository : https://doi.org/10.5281/zenodo.3338150

[download test data](https://zenodo.org/record/3338150/files/Testdata_SupSoftw_5_Ratio_96wells.zip?download=1)

## images
<img src="https://github.com/molcyto/MC-Ratio-96-wells/blob/master/Screenshot%20Ratio_96wells_macro_v7.png" width="600">

### Explanation input dialog
- 96 wells or 384 wells: please choose well plate format
- Fixed background valuw or rolling ball background: these are options to correct for background. Rolling ball uses the ImageJ rolling ball (radius 100 pixels) background subtraction. Fixed uses a fixed gray value that is subtracted from each ratio image.
- In case of fixed background, what is background intensity: In case the previous input selected 'rolling ball' this is a dummy input, otherwise it sets the background gray value that is subtracted from the images prior to analysis.
- Fixed threshold value or modal value threshold: Here you can choose how cells are recognized in the image, either by selecting a fixed threshold intensity above which you assume there are cells, or a modal value determination that determines the modal (background) gray value and uses a statistical evaluation of pixels above this background.
- In case of fixed threshold, what intensity over the background: in case the previous choice was fixed this is the intensity threshold for selecting cells in the analysis, otherwise this is a dummy input.
- Lower Threshold=number x sStdev + modal: In case a modal threshold was chosen for analysis, this value sets the threshold for analysis based on the modal value + this input times the standard deviation found in the image. In case a fixed threshold is chosen this is a dummy input.
- Upper threshold: this is the upper threshold intensity for cell analysis. Pixel values above this threshold (e.g. due to overexposure) are rejected.
- Smallest cell to analyze (pixel) this determines the smallest area in number of pixels to be analyzed. This can effectively reject small object or cell debris for interfering with the analysis.
- Minimal circularity to analyze as cell (0.0-0.90): This option selects the minimal circularity that is required for each object detected in the image above the intensity threshold in order to be included in analysis. A value of 0.4 will automatically reject small fibers
- Inlude flatfield correction: If this box is ticked a flatfield ratio image must be recorded and processed using the flatfield3 macro
- 

## links
[Visualizing heterogeneity](http://thenode.biologists.com/visualizing-heterogeneity-of-imaging-data/research/)
