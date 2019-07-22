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
//measure average intensity in 96/384-wells ratio series
//writes a log file
//this text file imports into Excel (through import) and generates for each well a column with cell fluorescence points x2
//created input dialog and optional output of multiwell images representing ratios of fluorescence
//
//============================================
//Version history:
//Version7 Dorus 16-7-2019 included optional meandering mode for acquisition/display
//version6 Dorus 15-7-2019 included optional flatfield correction
//version5 Dorus 27-5-2019 minor bug fixes
//version4 Dorus 13-5-2016 included better background options, cell segmentations
//version3 Dorus 3-9-2015 included 3 manual ratios
//Version2 Dorus 10-7-2015 included triple ratio option & un-normalized output
//version1  Dorus 5-5-2015 based on Bleach_96 wells v8
//--------------------------------------------------
//--------------------------------------------------
Dialog.create("Input dialog for Multiwell ratio analysis");
//Dialog.addChoice("Work on current image or load from directory :",newArray("current image","load from directory"),"load from directory");
Dialog.addChoice("96 wells or 384 wells:",newArray("96 wells","384 wells"),"96 wells");
Dialog.addChoice("Fixed background value or rolling ball background",newArray("Fixed","rolling ball"),"rolling ball");
Dialog.addNumber("In case of fixed background, what is background intensity:", 411);
Dialog.addChoice("Fixed threshold value or modal value threshold",newArray("Fixed","modal"),"Fixed");
Dialog.addNumber("In case of fixed threshold, what intensity over the background:", 50);
Dialog.addNumber("Lower Threshold=number*Stdev+modal:",1.5);
Dialog.addNumber("Upper Threshold:",20000);
Dialog.addNumber("Smallest cell to analyze (pixels):",2500);
Dialog.addNumber("Minimal circularity to analyze as cell (0.0-0.90):",0.4);
Dialog.addCheckbox("Include flatfield correction:", false);
Dialog.addCheckbox("Normalize output for extended logfile to max CFP intensity:", false);
Dialog.addCheckbox("Simple logfile with just cell average not normalized intensity:", false);
Dialog.addCheckbox("Keep cell ROIs:", true);
Dialog.addCheckbox("Create output 96/384 well ratio image:", true);
Dialog.addNumber("Low threshold for ratio RFP/CFP:", 0);
Dialog.addNumber("High threshold for ratio RFP/CFP:", 0.7);
Dialog.addNumber("Low threshold for ratio GFP/CFP:", 0);
Dialog.addNumber("High threshold for ratio GFP/CFP:", 0.07);
Dialog.addNumber("Low threshold for ratio GFP/RFP:", 0);
Dialog.addNumber("High threshold for ratio GFP/RFP:", 0.6);
Dialog.addCheckbox("Automatic determination of ratio thresholds:", false);
Dialog.addCheckbox("Create output 96/384 well initial intensity image:", true);
row_arr=newArray("A","B","C","D", "E","F", "G","H","I","J","K","L", "M","N", "O","P")    
Dialog.addChoice("Start row:",row_arr,row_arr[2]); 
Dialog.addNumber("Start column:",9);
Dialog.addCheckbox("Acquisition in meandering mode: ",true);
Dialog.show();
//openfromdir=Dialog.getChoice();
wellplate=Dialog.getChoice();
backgroundmode=Dialog.getChoice();
background= Dialog.getNumber();
thresholdmode=Dialog.getChoice();
threshold_offset=Dialog.getNumber();
thresset=Dialog.getNumber();
threshigh=Dialog.getNumber();
psize=Dialog.getNumber();
lowc=Dialog.getNumber();
flat_choice=Dialog.getCheckbox();
norm_output=Dialog.getCheckbox();
simpleoutput=Dialog.getCheckbox();
keepROIs=Dialog.getCheckbox();
well96=Dialog.getCheckbox();
ratiolow1=Dialog.getNumber();
ratiohigh1=Dialog.getNumber();
ratiolow2=Dialog.getNumber();
ratiohigh2=Dialog.getNumber();
ratiolow3=Dialog.getNumber();
ratiohigh3=Dialog.getNumber();
ratio_auto=Dialog.getCheckbox();
int_im=Dialog.getCheckbox();
srow=Dialog.getChoice();
scolumn=Dialog.getNumber();
meander=Dialog.getCheckbox();
num_wells=96;
num_rows=8;
num_columns=12;
max_cells=4000;
if(wellplate=="384 wells") {
	num_wells=384;
	num_rows=16;
	num_columns=24;
}
for (i=1;i<=16;i++){
	j=i-1;
	if (srow==row_arr[j]) sro=i;
}
st=num_columns*(sro-1)+scolumn;
if (flat_choice==true){
	waitForUser("Please select a Flatfield.tif image for flatfield correction");
	open();
	rename("Flatfield.tif");
}
setBatchMode(true);

filedir = getDirectory("Choose Source Directory ");
list = getFileList(filedir);
pos= list.length;
i=0;
run("Bio-Formats (Windowless)", "open=["+filedir+list[i]+"]");
filein=filedir+getTitle(); fname=getTitle();fileout=filein+".tiff";
rename("timestack");
getDimensions(x,y,ch,z,nt);
//print(x,y,ch,z,nt);
selectWindow("timestack");
selectWindow("timestack");

run("Close");

//total output define
arr_length=pos*ch*max_cells+1;

if(keepROIs==true)	newImage("CellROIs", "8-bit white", x,y,pos);
out=newArray(arr_length);
for (i=0;i<arr_length;i++) {
	out[i]=0;
}



npos=pos+1;
ratio=newArray(npos);
s_ratio=newArray(npos);
rc=newArray(npos);
init_int=newArray(npos);
cellnum=newArray(npos);
max_c=newArray(npos);
max_r=newArray(npos);
max_g=newArray(npos);
ratio_gc=newArray(npos);
s_ratio_gc=newArray(npos);
rc=newArray(npos);
rc_gc=newArray(npos);
ratio_gr=newArray(npos);
s_ratio_gr=newArray(npos);
rc_gr=newArray(npos);



stot=st+npos;
if (stot>num_wells) {
	st=1;
	sro=1;
	scolumn=1;
}
if (pos>num_wells) exit("More positions in hyperstack than wells");
ind=newArray(385);
i=0;
highnumber=0;
totcells=0;
ch1=newArray(100000);
ch2=newArray(100000);
ch3=newArray(100000);
totind=0;



for (well=1;well<=pos;well++) {
	showProgress(well, pos+1);
	j=well-1;
	run("Bio-Formats (Windowless)", "open=["+filedir+list[j]+"]");
	rename("timestack");
	run("32-bit");
	
//	
	run("Mean...", "radius=3 stack");	
	if (backgroundmode=="rolling ball") {
		run("Subtract Background...", "rolling=100 stack");
	}else{
		run("Subtract...", "value="+background+" stack");
	}
	inum=well;
	if (flat_choice==true) {
		imageCalculator("Multiply stack", "timestack","Flatfield.tif");
	}

	run("Duplicate...", "duplicate");
	rename("timestack2");

	selectWindow("timestack2");
	setSlice(2);
	run("Mean...", "radius=11 stack");	
	run("Find Maxima...", "noise=1 output=[Segmented Particles] exclude");
	rename("temp2");
	close("timestack2");
	selectWindow("timestack");



	if (thresholdmode=="modal") {

		run("Set Measurements...", "  mean standard modal min redirect=None decimal=9");
		setSlice(2);
		run("Measure");
		headings = split(String.getResultsHeadings);
		mod=getResult(headings[2],0);
		std=getResult(headings[1],0);
		max=getResult(headings[4],0);

//the median pixel value (usually background) is determined (mod) and the standard deviation of pixel values in the image is determined (stdev)
		selectWindow("Results");
		run("Close");
// The lower analysis threshold is set to the modal pixel value of the image (is usually background)+thresset x the standard deviation within the imge
		threslow=mod+thresset*std;
	} else {
		threslow=threshold_offset;
	}
//	threslow=463;
	selectWindow("timestack");
	
	run("Duplicate...", "duplicate");
	rename("temp");
	setSlice(2);


	setThreshold(threslow,threshigh);
	setThreshold(threslow,threshigh);
	setThreshold(threslow,threshigh);

	run("Convert to Mask", "method=Default background=Default");
	imageCalculator("AND create", "temp","temp2");
	rename("cell roi");
	close("temp");
	close("temp2");
	selectWindow("cell roi");
	roiManager("reset"); 
	run("Set Measurements...", "  mean redirect=None decimal=9");
	setAutoThreshold("Default dark");
	
	run("Analyze Particles...", "size="+psize+"-Infinity pixel circularity="+lowc+"-0.90 show=Nothing exclude add");
	selectWindow("timestack");
	roiManager("Show All");
	roiManager("Multi Measure");
	selectWindow("cell roi");
	run("Select All");
	roiManager("Add");
	run("Flatten", "slice");
	selectWindow("cell roi");
	close();



	if (nResults >0){
		selectWindow("Results");
//The lines below takes the results out of the result image window. First it analyzes the number of columns (=cells) in the results window
		headings = split(String.getResultsHeadings);
		cellcount=lengthOf(headings);
		if (cellcount>max_cells) cellcount=max_cells;
		if (cellcount>highnumber) highnumber=cellcount;
		max_c[well]=0;
		max_r[well]=0;
		max_g[well]=0;
		if (cellcount>0){
			init_inte=newArray(cellcount);
			totcells=totcells+cellcount;
//Below the initial intensity per well is copied
			x1=0;x2=0;xy=0;y1=0;y2=0;
			z1=0;z2=0;xz=0;yz=0;
			for (col=0; col<cellcount; col++) {
		    		inten1=getResult(headings[col],0);
				inten2=getResult(headings[col],1);
				ch1[totind]=inten1;
				ch2[totind]=inten2;
				if (max_r[well]<inten1) max_r[well]=inten1;
				if(max_c[well]<inten2) max_c[well]=inten2;
				init_int[well]=init_int[well]+inten1;
				if(ch>2) {
					inten3=getResult(headings[col],2);
					if(max_g[well]<inten3) max_g[well]=inten3;
					ch3[totind]=inten3;

				}
				totind=totind+1;

		  	}

			cellnum[well]=cellcount;
			init_int[well]=init_int[well]/cellcount;
//Below all time points are copied per cell (each row in the result image is a channel, each column is a cell).
		     	for (col=0; col<cellcount; col++) {

		     		line = "";
				inum0=col*pos*ch+j*ch;
				inum1=inum0+1;
				inum2=inum0+2;
				if(norm_output==true){
				  	for (row=0; row<nResults; row++) {
						inum=inum0+row;
				 		out[inum]=getResult(headings[col],row)/max_c[well];
					}
				}else{
				  	for (row=0; row<nResults; row++) {
						inum=inum0+row;
				 		out[inum]=getResult(headings[col],row);					}
				}
				x1=x1+out[inum1];
				x2=x2+out[inum1]*out[inum1];
				xy=xy+out[inum0]*out[inum1];
				y1=y1+out[inum0];
				y2=y2+out[inum0]*out[inum0];
				if (ch>2){
					z1=z1+out[inum2];
					z2=z2+out[inum2]*out[inum2];
					xz=xz+out[inum1]*out[inum2];
					yz=yz+out[inum0]*out[inum2];
				}
			}
			if (ch>2){
				ratio_gc[well]=xz/x2;
				ratio_gr[well]=yz/y2;
			}
			ratio[well]=xy/x2;
			if (cellcount>1) {
				s_ratio[well]=sqrt((y2-xy^2/x2)/((cellcount-1)*x2));
				rc[well]=(cellcount*xy-x1*y1)/sqrt((cellcount*x2-x1*x1)*(cellcount*y2-y1*y1));
				if (ch>2){
					s_ratio_gc[well]=sqrt((z2-xz^2/x2)/((cellcount-1)*x2));
					rc_gc[well]=(cellcount*xz-x1*z1)/sqrt((cellcount*x2-x1*x1)*(cellcount*z2-z1*z1));
					s_ratio_gr[well]=sqrt((z2-yz^2/y2)/((cellcount-1)*y2));
					rc_gr[well]=(cellcount*yz-y1*z1)/sqrt((cellcount*y2-y1*y1)*(cellcount*z2-z1*z1));				}
			}else{
				s_ratio[well]=0;
				rc[well]=0;
				if (ch>2){
					s_ratio_gc[well]=0;
					rc_gc[well]=0;
					s_ratio_gr[well]=0;
					rc_gr[well]=0;				
				}	
			}
		}
//	print(inum,x1,x2,xy,y1,y2);
		run("Clear Results");
		selectWindow("Results");
		run("Close");
	}else{
		cellnum[well]=0;
		init_int[well]=0;
		for (i=1;i<=ch;i++) {
			inum=(i-1)+j*ch;
			out[inum]=0;
		}
		ratio[well]=0;
		s_ratio[well]=0;
		rc[well]=0;
		max_r[well]=0;
		max_c[well]=0;
		if (ch>2){
			s_ratio_gc[well]=0;
			rc_gc[well]=0;
			s_ratio_gr[well]=0;
			rc_gr[well]=0;	
			max_g[well]=0;			
		}	
	}
	selectWindow("cell roi-1");
//Below the cell mask is copied into a new image array
	if (keepROIs==true) {
		rename("temp");
		getDimensions(xx,yy,cho,z,nt);	
		if (xx>x) xx=x;
		if(yy>y) yy=y;
		makeRectangle(0, 0, xx, yy);	
		run("Copy");
		selectWindow("temp");
		run("Close");
		selectWindow("CellROIs");
		setSlice(well);		
		run("Paste");
	}else{
	close();
	}
	selectWindow("timestack");
	selectWindow("timestack");
	selectWindow("timestack");
	run("Close");
}



ratiolowest=100000000;
ratiohighest=0;
ratio_gclowest=100000000;
ratio_gchighest=0;
ratio_grlowest=100000000;
ratio_grhighest=0;

itothigh=0;
for (well=1;well<=pos;well++) {
	if (init_int[well] > itothigh) itothigh=init_int[well];
    	if(ratio[well]>ratiohighest) ratiohighest=ratio[well];
	if(ratio[well]<ratiolowest) ratiolowest=ratio[well];
	if (ch>2){
  	  	if(ratio_gc[well]>ratio_gchighest) ratio_gchighest=ratio_gc[well];
		if(ratio_gc[well]<ratio_gclowest) ratio_gclowest=ratio_gc[well];
    		if(ratio_gr[well]>ratio_grhighest) ratio_grhighest=ratio_gr[well];
		if(ratio_gr[well]<ratio_grlowest) ratio_grlowest=ratio_gr[well];
	}	
}

	

setBatchMode("exit and display");

if(simpleoutput==true){
//write simple logfile output, just array with unnormalized values

	tts="\t";
	if(ch>2){
		print("#\t CFP \t RFP \t GFP\n");
		for (i=0;i<totcells;i++) {
			print(i+tts+ch2[i]+tts+ch1[i]+tts+ch3[i]+"\n");
		} 
	}else{
		print("#\t CFP \t RFP \n");
		for (i=0;i<totcells;i++) {
			print(i+tts+ch2[i]+tts+ch1[i]+"\n");
		} 
	}
}else{

	//write extended logfile output
	tts="\t";
	for (i=1;i<ch;i++) {
		tts=tts+"\t";
	}
	
	s1="Ratio #\t"; 
//below the well series number is written into a text string
	for (well=1;well<=pos;well++) {
		s1=s1+well+tts;
	}
	s1=s1+"\n";
	print(s1);
	s1="time/well #\t";
	tts="\t";
	for (i=1;i<ch;i++) {
		tts=tts+"\t";
	}

//below the well position on the microtiter plate is written into a text string
	j=0;i=0;
	for(y=sro;y<=num_rows;y++){
		k=y-1;
		j=j+1;
		odd=j/2-round(j/2);
		for(xxx=scolumn;xxx<=num_columns;xxx++){
			x=xxx;
			if(meander==1){
				if (odd==0) x=num_columns-xxx+scolumn;
			}
			i=i+1;
			if(i<=pos) s1=s1+row_arr[k]+x+tts;
		}
	}
	print(s1);
	s10="File_ID\t";
	for (well=1;well<=pos;well++) {
		j=well-1;
		s10=s10+list[j]+tts;
	}
	print(s10);
//below the average ratio/well is put out
	s3="Ratio RFP/CFP\t";
	s31="Ratio GFP/CFP\t";
	s32="Ratio GFP/RFP\t";
	s4="SD_ratio\t";
	s41="SD_ratio\t";
	s42="SD_ratio\t";
	s5="R(correlation)\t";
	s51="R(correlation)\t";
	s52="R(correlation)\t";
	s6="Average RFP intensity\t";
	s7="Maximum RFP intensity/cell\t";
	s8="Maximum CFP intensity/cell\t";
	s81="Maximum GFP intensity/cell\t";
	s9="Number of cells per well\t";
	for (well=1;well<=pos;well++) {
		s3=s3+ratio[well]+tts;	
		s4=s4+s_ratio[well]+tts;
		s5=s5+rc[well]+tts;			
		s6=s6+init_int[well]+tts;	
		s7=s7+max_r[well]+tts;	
		s8=s8+max_c[well]+tts;	
		if (ch>2) {
			s31=s31+ratio_gc[well]+tts;	
			s41=s41+s_ratio_gc[well]+tts;
			s51=s51+rc_gc[well]+tts;				
			s32=s32+ratio_gr[well]+tts;	
			s42=s42+s_ratio_gr[well]+tts;
			s52=s52+rc_gr[well]+tts;			
			s81=s81+max_g[well]+tts;	
		}
		s9=s9+cellnum[well]+tts;		
	}
	
	s9=s9+"\n";
	if (ch<=2){
		print(s3);print(s4);print(s5);print(s6);print(s7);print(s8);print(s9);
	}else{
		print(s3);print(s4);print(s5);print(s31);print(s41);print(s51);print(s32);print(s42);print(s52);print(s6);print(s7);print(s8);print(s81);print(s9);
	}

//below the average intensity/well per channel per cells is writen in a text string 
//print(highnumber,pos,ch);
	s2="Cell #\t";
	if (ch==3){
		for (well=1;well<=pos;well++) {
			s2=s2+"RFP\tCFP\tGFP\t";
			}
	}else if (ch==2){	
		for (well=1;well<=pos;well++) {
			s2=s2+"RFP\tCFP\t";
			}
	}
	print(s2);

	for (t=1;t<=highnumber;t++) {
		s2="";
		s2=s2+t+"\t";  
		for (well=1;well<=pos;well++) {
			for (channel=0;channel<ch;channel++) {
				inum=(t-1)*pos*ch+(well-1)*ch+channel;
				s2=s2+out[inum]+"\t";			

			}
		}
//		s2=s2+"\n";
		print(s2);
	}
	
}
if (flat_choice==true) close("Flatfield.tif");
//==create output multiwell image

if(well96==true){
	zz=50;
//==ratio multiwell image	
	// mode 2, Wells A1-A12,B12-B1,C1-C12---H12-H1
	low=ratiolow1;
	high=ratiohigh1;
	if (ratio_auto==true){
		low=ratiolowest;
		high=ratiohighest;
	}
	if (ch>2){
		if(int_im==false){
			newImage("multiwell", "8-bit white", 1000, 1400, 1);
		}else{
			newImage("multiwell", "8-bit white", 1000, 1850, 1);
		}
	}else{	
		if(int_im==false){
			newImage("multiwell", "8-bit white", 1000, 500, 1);   
		}else{
			newImage("multiwell", "8-bit white", 1000, 950, 1);
		}
	}
	
	cs=50;
	if (num_wells==96) {
		cs=50;
		ccs=45;
	}else{
		cs=25;
		ccs=20;
	}
	i=0;j=0;
	for(y=sro;y<=num_rows;y++){
		j=j+1;
		odd=j/2-round(j/2);
		for(xxx=scolumn;xxx<=num_columns;xxx++){
			i=i+1;
			if (i<=pos){
				val=ratio[i];
				val=255*(val-low)/(high-low);
				val=round(val);
				if (val<0) val=0;
				if(val>255) val=255;
				setColor(val);
				x=xxx;
				if(meander==1){
					if (odd==0) x=num_columns-xxx+scolumn;
				}
				xx=cs*x;yy=cs*y+50-cs;
				fillOval(xx, yy, ccs, ccs);
				setColor(0);
				drawOval(xx,yy,ccs,ccs);
			}	
		}
	}

   	if(num_wells==96){
		setColor(0);
		setFont("SansSerif", 32, "bold");
		for(x=1;x<=num_columns;x++) {
			xx=cs*x;
			drawString(x,xx,zz);
		}
		for (k=1;k<=8; k++){
			kk=k-1;kz=zz+k*50;
			drawString(row_arr[kk],0,kz);
		}
	}else{
		setFont("SansSerif" , 16, "bold");
		setColor(0);
		for(x=1;x<=num_columns;x++) {
			xx=cs*x;
			drawString(x,xx,zz);
		}
		for (k=1;k<=16; k++){
			kk=k-1;kz=zz+k*25;
			drawString(row_arr[kk],0,kz);
		}
	}
	setFont("SansSerif" , 36, "bold");	
	newImage("rampje", "8-bit ramp", 400, 50, 1);
	run("Rotate 90 Degrees Left");
	run("Copy");
	close();
	selectWindow("multiwell");
	makeRectangle(650, 50, 50, 400);
	run("Paste");
	drawRect(650, 50, 50, 400);
	drawString(low,700,450);
	drawString(high,700,100);
	drawString("Ratio RFP/CFP",700,275);
	zz=500;


// make GFP/CFP well ratio image
	zzz=0;

	if(ch>2) {

		low=ratiolow2;
		high=ratiohigh2;
		if (ratio_auto==true){
			low=ratio_gclowest;
			high=ratio_gchighest;
		}
		i=0;j=0;
		for(y=sro;y<=num_rows;y++){
			j=j+1;
			odd=j/2-round(j/2);
			for(xxx=scolumn;xxx<=num_columns;xxx++){
				i=i+1;
				if (i<=pos){
					val=ratio_gc[i];
					val=255*(val-low)/(high-low);
					val=round(val);
					if (val<0) val=0;
					if(val>255) val=255;
					setColor(val);
					x=xxx;
					if(meander==1){

						if (odd==0) x=num_columns-xxx+scolumn;
					}
					xx=cs*x;yy=cs*y+zz-cs;
					fillOval(xx, yy, ccs, ccs);
					setColor(0);
					drawOval(xx,yy,ccs,ccs);
				}	
			}
		}

   		if(num_wells==96){
			setColor(0);
			setFont("SansSerif", 32, "bold");
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=8; k++){
				kk=k-1;kz=zz+k*50;
				drawString(row_arr[kk],0,kz);
			}
		}else{
			setFont("SansSerif" , 16, "bold");
			setColor(0);
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=16; k++){
				kk=k-1;kz=zz+k*25;
				drawString(row_arr[kk],0,kz);
			}
		}
		setFont("SansSerif" , 36, "bold");
		makeRectangle(650, zz, 50, 400);	
		run("Paste");
		zz1=zz+400;
		drawRect(650, zz, 50, 400);
		drawString(low,700,zz1);
		zz1=zz+50;
		itothigh=round(itothigh);
		drawString(high,700,zz1);
		zz1=zz+225;		
		drawString("Ratio GFP/CFP",700,zz1);

//make GFP/RFP ratio image
		zz=950;
		low=ratiolow3;
		high=ratiohigh3;
		if (ratio_auto==true){
			low=ratio_grlowest;
			high=ratio_grhighest;
		}
		cs=50;
		if (num_wells==96) {
			cs=50;
			ccs=45;
		}else{
			cs=25;
			ccs=20;
		}
		i=0;j=0;
		for(y=sro;y<=num_rows;y++){
			j=j+1;
			odd=j/2-round(j/2);
			for(xxx=scolumn;xxx<=num_columns;xxx++){
				i=i+1;
				if (i<=pos){
					val=ratio_gr[i];
					val=255*(val-low)/(high-low);
					val=round(val);
					if (val<0) val=0;
					if(val>255) val=255;
					setColor(val);
					x=xxx;
					if(meander==1){
						if (odd==0) x=num_columns-xxx+scolumn;
					}
					xx=cs*x;yy=cs*y+zz-cs;
					fillOval(xx, yy, ccs, ccs);
					setColor(0);
					drawOval(xx,yy,ccs,ccs);
				}	
			}
		}

   		if(num_wells==96){
			setColor(0);
			setFont("SansSerif", 32, "bold");
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=8; k++){
				kk=k-1;kz=zz+k*50;
				drawString(row_arr[kk],0,kz);
			}
		}else{
			setFont("SansSerif" , 16, "bold");
			setColor(0);
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=16; k++){
				kk=k-1;kz=zz+k*25;
				drawString(row_arr[kk],0,kz);
			}
		}



		setFont("SansSerif" , 36, "bold");
		makeRectangle(650, zz, 50, 400);	
		run("Paste");
		zz1=zz+400;
		drawRect(650, zz, 50, 400);
		drawString(low,700,zz1);
			zz1=zz+50;
		itothigh=round(itothigh);
		drawString(high,700,zz1);
		zz1=zz+225;		
		drawString("Ratio GFP/RFP",700,zz1);
		zzz=900;

	}
	z=475+zzz;

//==create initial intensity multiwell image
	j=0;i=0;
	if(int_im==true){
		zz=500+zzz;
		for(y=sro;y<=num_rows;y++){
			j=j+1;		
			odd=j/2-round(j/2);
			for(xxx=scolumn;xxx<=num_columns;xxx++){
				i=i+1;
				if(i<=pos) {
					val=init_int[i];
					val=255*val/itothigh; 
					val=round(val);
					if (val<0) val=0;
					if(val>255) val=255;
					setColor(val);
					x=xxx;
					if(meander==1){
						if (odd==0) x=num_columns-xxx+scolumn;
					}
					xx=cs*x;yy=cs*y+zz-cs;
					iii=iii+1;
					fillOval(xx, yy, ccs, ccs);
					setColor(0);
					drawOval(xx,yy,ccs,ccs);
				}
			}
		}
	
		if(num_wells==96){
			setFont("SansSerif" , 32, "bold");
			setColor(0);
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=8; k++){
				kk=k-1;kz=zz+k*50;
				drawString(row_arr[kk],0,kz);
			}
		}else{
			setFont("SansSerif" , 16, "bold");
			setColor(0);
			for(x=1;x<=num_columns;x++) {
				xx=cs*x;
				drawString(x,xx,zz);
			}
			for (k=1;k<=16; k++){
				kk=k-1;kz=zz+k*25;
				drawString(row_arr[kk],0,kz);
			}
		}
		setFont("SansSerif" , 36, "bold");
		makeRectangle(650, zz, 50, 400);	
		run("Paste");
		zz1=zz+400;
		drawRect(650, zz, 50, 400);
		drawString("0",700,zz1);
		zz1=zz+50;
		itothigh=round(itothigh);
		drawString(itothigh,700,zz1);
		zz1=zz+225;		
		drawString("Init int",700,zz1);
		z=zz+425;
	}
//===put date and filename=================


	setFont("SansSerif" , 19, "bold");
	getDateAndTime(year,month,dw,dm,hr,mi,sec,msec);
	month=month+1;
	string="Date: "+dm+"-"+month+"-"+year;
	drawString(string,5,z);
	z=z+25;
	drawString(filein,5,z);
	run("Fire");
}
getDateAndTime(year,month,dw,dm,hr,mi,sec,msec);
month=month+1;
string="Date: "+dm+"-"+month+"-"+year;

print("\n");
print(string);
print(filein);
print(wellplate);
print(backgroundmode+" background\n");
if (backgroundmode=="fixed") print("Fixed background value: "+background);
print(thresholdmode+" threshold mode\n");
if (backgroundmode=="modal") {
	print("Number*stdev:"+thresset);
}else{
	print("Fixed offset threshold value: "+threshold_offset );
}
print("Flatfield correction: "+flat_choice);
print("Upper threshold value: "+threshigh );
print("Smallest cell to analyze (pixels): "+psize);
print("Minimal circularity to analyze as cell: "+lowc);
print("Low threshold for ratio RFP/CFP: "+ratiolow1);
print("High threshold for ratio RFP/CFP: "+ratiohigh1);
print("Low threshold for ratio GFP/CFP: "+ratiolow2);
print("High threshold for ratio GFP/CFP: "+ratiohigh2);
print("Low threshold for ratio GFP/RFP: "+ratiolow3);
print("High threshold for ratio GFP/RFP: "+ratiohigh3);
print("Automatic determination of thresholds: "+ratio_auto);
print("start row: "+ srow );    
print("Start column: "+scolumn);



