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

## Screenshot of input dialog for Macro_96wells_Ratio_v7.ijm
<img src="https://github.com/molcyto/MC-Ratio-96-wells/blob/master/Screenshot%20Ratio_96wells_macro_v7.png" width="600">

## Explanation input dialog for Macro_96wells_Ratio_v7.ijm
- 96 wells or 384 wells: here the well plate format can be selected.
- Fixed background value or rolling ball background: these are options to correct for background in the ratio images. Rolling ball uses the ImageJ rolling ball (radius 100 pixels) background subtraction. Fixed uses a fixed grey value that is subtracted from each ratio image.
- In case of fixed background, what is background intensity: In case the previous input selected 'rolling ball' this is a dummy input, otherwise it sets the background grey value that is subtracted from the images prior to analysis.
- Fixed threshold value or modal value threshold: Here you can choose how cells are recognized in the image, either by selecting a fixed threshold intensity above which you assume there are cells, or a modal value determination that determines the modal (background) grey value and uses a statistical evaluation of pixels above this background.
- In case of fixed threshold, what intensity over the background: in case the previous choice was fixed, this is the lower intensity threshold for selecting cells in the analysis, otherwise this is a dummy input.
- Lower Threshold=number x Stdev + modal: In case a modal threshold was chosen for analysis, this value sets the lower intensity threshold for analysis based on the modal value + this input times the standard deviation found in the image. In case a fixed intensity threshold is chosen this is a dummy input.
- Upper threshold: this is the upper threshold intensity for cell analysis. Pixel values above this threshold (e.g. due to overexposure) are rejected.
- Smallest cell to analyze (pixels): this determines the smallest area in number of pixels to be analyzed. This can effectively reject small objects or cell debris interfering with the analysis.
- Minimal circularity to analyze as cell (0.0-0.90): This option selects the minimal circularity that is required for each object detected in the image above the intensity threshold in order to be included in analysis. A value of 0.4 will automatically reject small fibers.
- Include flatfield correction: If this box is ticked, a flatfield ratio image must be recorded and processed using the macro_process_flatfield3.ijm macro. This flatfield correction will correct for spatial differences in excitation or detection efficiencies. The flatfield image should be stored in a separate directory.
- Normalize output for extended logfile to max CFP intensity: If selected, for each well the CFP (and RFP and/or GFP) intensity values per cell are normalized to the cell with maximal CFP intensity in the output logfile. 
- Simple logfile with just cell average not normalized intensity: If selected, a simple logfile is created with just the average statistics per well and not all the single cell RFP, CFP (and GFP) data per well.
- Keep cell ROIs: if selected an output image stack is generated with all analyzed cell ROIs per well.
- Create output 96/384 well ratio image: if selected a colored ratio multiwell image is generated.
- Low/high threshold (6x): sets the minimal/maximal ratio for display in the colored ratio image. This contrast can be individually set for the three ratio images.
- Automatic determination of ratio thresholds: If selected, the previous 6 inputs will be overruled and the macro will scale the ratio multiwell output image according to the minimal and maximal measured ratio(s).
- Create output 96/384 well initial intensity image: If selected, a multiwell image is added of the detected average RFP intensity. This is useful for inspecting wells with very bright or dim cells.
- Start row/Column: In case not an entire 96 well or 384 well is screened but a subsection of the plate, the first well (row, column) can be chosen. In case a 24 well plate is used, a 24 well plate output can be made by selecting E7 as first well.
- Acquisition in meandering mode: If selected the sequence of ratio images is assumed to be in the order A1-A12, B12-B1, C1-C12, D12-D1, E1-E12, F12-F1, G1-G12, H12-H1 for a 96 well plate. If not selected it assumes an order A1-A12, B1-B12, C1-C12, D1-D12, E1-E12, F1-F12, G1-G12, H1-H12.

## Screenshot of input dialog for Macro_process_flatfield_v3.ijm
<img src="https://github.com/molcyto/MC-Ratio-96-wells/blob/master/Screenshot%20macro_process_flatfield3.png" width="600">

## Explanation input dialog for Macro_process_flatfield_v3.ijm
- Work on current image or load from directory: Here you can choose to either use the current image already displayed in ImageJ as flatfield image, or you load a stored image as flatfield image. This should be a ratiometric image from a spatially uniform object (such as a fluorescent plastic slide).
- Background: Here you can choose the background correction for the flatfield image. You can select a stored background ratiometric image (i.e. a dark ratio image with the same uniform object imaged without excitation light), a fixed background value (e.g. the camera bias), or no background correction of the flatfield image.
- Threshold ratio for selecting boundary of flatfield image: This selects a threshold for flatfield correction if the detected fluorescence in the image of a homogeneous object is this factor lower than the maximal value detected in the respective channel. This will reject ratiometric analysis of cells in areas of the image that suffer from strong vignetting artefacts.

The flatfield macro will produce a ratiometric floating point image with a correction value per pixel by which the ratiometric images of the multiwell plate will be multiplied to correct for vignetting and filter cube dependent intensity deviations.


## links
[Visualizing heterogeneity](http://thenode.biologists.com/visualizing-heterogeneity-of-imaging-data/research/)
