// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Copyright (C) 2019  Dorus Gadella
// electronic mail address: th #dot# w #dot# j #dot# gadella #at# uva #dot# nl
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//Dorus Gadella 1-6-2018 Macro_process_flatfield.ijm
//Dorus Gadella 15-5-2019 Version 2, upgraded with  3 channel flat field
//Dorus Gadella 10-7-2019 Version 3, updated with selectable threshold for vignetting correction
// Calculates a Flatfield image from a white and background ratiometric image
// 
//This needs a two or three channel fluorescence image  of a flat field (WHITE) object, corrected for camera bias and background;
//===========================

Dialog.create("Input dialog for flatfield image creation");
Dialog.addChoice("Work on current image or load from directory :",newArray("current image","load from directory"),"load from directory");
Dialog.addChoice("Background :", newArray("load from directory","no background", "subtract 32768"),"load from directory");

Dialog.addNumber("Threshold ratio for selecting boundary of flatfield image: ",2);
Dialog.show();
openfromdir=Dialog.getChoice();
background=Dialog.getChoice();
thr=Dialog.getNumber();

if (openfromdir=="load from directory") {
	waitForUser("Please select an image of a flat field (White) object");
	open();
}
rename("Flatfield");
selectWindow("Flatfield");
if  (background=="Load from directory"){
	waitForUser("Please select an image of the corresponding background");
	open();
	rename("Background");
	imageCalculator("Subtract create stack", "Flatfield", "Background");
	rename("Fl");
	selectWindow("Background");
	close();	
	selectWindow("Flatfield");
	close();
	selectWindow("Fl");
	rename("Flatfield");
}else{ if (background=="subtract 32768"){
	run("Subtract...", "value=32768 stack");
}
}
selectWindow("Flatfield");
rename("input");
z=nSlices;
run("Median...", "radius=20 stack");
run("Set Measurements...", "area mean standard min redirect=None decimal=9");
setSlice(1);
run("Measure");
headings = split(String.getResultsHeadings);
min1=getResult(headings[3],0);
mean1=getResult(headings[1],0);
max1=getResult(headings[4],0);
selectWindow("Results");
run("Close");
setSlice(2);
run("Measure");
headings = split(String.getResultsHeadings);
min2=getResult(headings[3],0);
mean2=getResult(headings[1],0);
max2=getResult(headings[4],0);
selectWindow("Results");
run("Close");
if (z==3) {
	
	setSlice(3);
	run("Measure");
	headings = split(String.getResultsHeadings);
	min3=getResult(headings[3],0);
	mean3=getResult(headings[1],0);
	max3=getResult(headings[4],0);
	selectWindow("Results");
	run("Close");

}
run("Duplicate...", "duplicate");
rename("thres");
min1=max1/thr;
setSlice(1);
run("Duplicate...", "use");
rename("temp");
setThreshold(min1, max1);
run("Make Binary");
run("Select All");
run("Copy");
selectWindow("thres");
run("Paste");
close("temp");
selectWindow("thres");
setSlice(2);
run("Duplicate...", "use");
rename("temp");
min2=max2/thr;
setThreshold(min2, max2);
run("Make Binary");
run("Select All");
run("Copy");
selectWindow("thres");
run("Paste");
close("temp");
if (z==3) {
	selectWindow("thres");
	setSlice(3);
	run("Duplicate...", "use");
	rename("temp");
	min3=max3/thr;
	setThreshold(min3, max3);
	run("Make Binary");
	run("Select All");
	run("Copy");
	selectWindow("thres");
	run("Paste");
	close("temp");
}
selectWindow("thres");

run("Z Project...", "projection=[Min Intensity]");
rename("t2");

run("Divide...", "value=255");
run("32-bit");
selectWindow("input");
run("32-bit");
run("Reciprocal", "stack");
setSlice(1);
run("Multiply...", "value=max1 slice");
setSlice(2);
run("Multiply...", "value=max2 slice");
if (z==3) {
	setSlice(3);
	run("Multiply...", "value=max3 slice");
}
imageCalculator("Multiply create 32-bit stack", "input","t2");
rename("Flatfield");
selectWindow("t2");
close();
selectWindow("input");
close();
selectWindow("thres");
close();

