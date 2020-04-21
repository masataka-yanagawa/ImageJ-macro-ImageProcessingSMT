macro "ImageProcessingSMT"{

//Set folder
input_dir = getDirectory("Choose directory");
output_dir = input_dir;

//Get file list
filelist = getFileList(input_dir);

//Set parameters

Dialog.create("Parameters");
Dialog.addCheckbox("Subtract BG",true);
Dialog.addNumber("SB",25,0,8,"pix");
Dialog.addNumber("BC_Min",0,0,8,"tone");
Dialog.addNumber("BC_Max",1200,0,8,"tone");
Dialog.addCheckbox("Run. Avg.",true);
Dialog.addNumber("Running",2,0,8,"frames");
Dialog.addCheckbox("Save tif",true);
Dialog.addCheckbox("Save avi",true);
Dialog.addNumber("FrameRate",33,1,8,"fps");
Dialog.show();

SBflag = Dialog.getCheckbox();
SB = Dialog.getNumber();
BC_Min = Dialog.getNumber();
BC_Max = Dialog.getNumber();
RAflag = Dialog.getCheckbox();
RunAvg = Dialog.getNumber();
SaveTif = Dialog.getCheckbox();
SaveAvi = Dialog.getCheckbox();
FrameRate = Dialog.getNumber();

//Batch processing
 
for (i=0; i<filelist.length; i++) {
     if(SBflag == 1){
          output_file = filelist[i]+"_SB"+SB+"_BC"+BC_Min+"-"+BC_Max+"_"+FrameRate+"fps.avi";
     }else{
          output_file = filelist[i]+"_BC"+BC_Min+"-"+BC_Max+"_"+FrameRate+"fps.avi";
     }

     output_path = output_dir+output_file;
     open(input_dir + filelist[i]);
     //run("Delete Slice");
     
     if(SBflag == 1){
          run("Subtract Background...", "rolling=SB stack");
          }

     if(RAflag == 1){
          run("Running ZProjector", "running=RunAvg projection=[Average Intensity]");
          selectWindow(filelist[i]);
          close();
          selectWindow(filelist[i]+"-RunAv(2)");
          }

     run("Brightness/Contrast...");
     setMinAndMax(BC_Min, BC_Max);

     if(SaveTif == 1){
           saveAs("Tiff", output_path);
          }

     if(SaveAvi == 1){
          run("AVI... ", "compression=Uncompressed frame=FrameRate save=[output_path]");
          }

     close();
     }

}

macro "Split2ch"{

//Set Folder
input_dir = getDirectory("Choose directory");
output_dir = input_dir;

//Get File list
filelist = getFileList(input_dir);

//Batch processing
for (i=0; i<filelist.length; i++) {

output_file = filelist[i]+"-ch1.tif";
output_path = output_dir+output_file;
open(input_dir + filelist[i]);
run("Specify...", "width=512 height=512 x=0 y=0 slice=1");
run("Crop");

saveAs("Tiff", output_path);
close();

output_file = filelist[i]+"-ch2.tif";
output_path = output_dir+output_file;
open(input_dir + filelist[i]);
run("Specify...", "width=512 height=512 x=512 y=0 slice=1");
run("Crop");

saveAs("Tiff", output_path);
close();

}

}


macro "Composite2ch"{

//Set Folder
input_dir = getDirectory("Choose directory");
output_dir = input_dir;

input_ch1 = input_dir+"\C1\\";
input_ch2 = input_dir+"\C2\\";

//Get file lists from C1 and C2 folders
filelist1 = getFileList(input_ch1);
filelist2 = getFileList(input_ch2);
NumImage = filelist1.length;


//Batch processing
for (i=0; i<NumImage; i=i+1) {

filename1 = filelist1[i];
filename2 = filelist2[i];

output_file_avi = filename1+"_composite.avi";
output_file_tif = filename1+"_composite.tif";

output_path_avi = output_dir+output_file_avi;
output_path_tif = output_dir+output_file_tif;

open(input_ch1 + filelist1[i]);
selectWindow(filename1);
//run("Brightness/Contrast...");
//setMinAndMax(0, 800);

open(input_ch2 + filelist2[i]);
selectWindow(filename2);
//run("Brightness/Contrast...");
//setMinAndMax(0, 800);

run("Merge Channels...", "red=[" + filename2 + "] green=[" + filename1 + "] create");
selectWindow("Composite");

//run("AVI... ", "compression=Uncompressed frame=33.3 save=[output_path_avi]"); //Activate this line if you want to save avi files.
saveAs("Tiff", output_path_tif);

close();
}

}

