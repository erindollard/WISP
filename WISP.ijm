// open directory with images to be analyzed
dir = getDirectory("Select a Directory with Images");

// select csv file for results to be written to
path = File.openDialog("Select Results.csv");

// Get the list of files in the selected directory
list = getFileList(dir);

// Initialize the Results table and ROI Manager
run("ROI Manager...");
roiManager("reset");

// open results file and add headings 
f = File.open(path);
print(f, "Filename, Region Name, Mean, Min, Max, Area");

// Loop through each file in the directory
for (i = 0; i < list.length; i++) {
	filename = list[i];
	open(dir + filename);
	selectImage(filename);
	
	// duplicate image, blur and grayscale image to select wing regions 
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=10");
	run("8-bit");
	
	// initialize wand tool
	setTool("wand");
	run("Wand Tool...", "tolerance=10 mode=Legacy");
	
	// prompt user to select regions by hand
	waitForUser("select 4 intervein regions, clicking 'add' in between ");
	
	// select results
	roiManager("Select", newArray(0,1,2,3));
	close();
	
	// measure selected ROIs on original image
	selectImage(filename);
	run("Set Measurements...", "mean min area redirect=None decimal=3");
	roiManager("Measure");
	
	// writes results to earlier selected file (order of regions is hard-coded)
	for (row = i*4; row < i*4+4; row++){ 
		one = getResult("Mean", row);
		two = getResult("Min", row);
		three = getResult("Max", row);
		four = getResult("Area", row);
		if (row % 4 == 0) {
			print(f, filename + ", Marginal," + one + "," + two + "," + three + "," + four);
		} else if (row % 4 == 1) {
			print(f, filename + ", Submarginal," + one + "," + two + "," + three + "," + four);
		} else if (row % 4 == 2) {
			print(f, filename + ", 1st Posterior," + one + "," + two + "," + three + "," + four);
		} else if (row % 4 == 3) {
			print(f, filename + ", Discal Cell," + one + "," + two + "," + three + "," + four);
		}  
		
	}
	// reset ROIs
	roiManager("Reset");
	close();
}
File.close(f);