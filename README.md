# HDR_scene_detection
octave code for algorithm to detect HDR scene and suggest appropriate frame for fusion.
Source this .m file for testing this algorithm. 
This code loops through all folders with images..images to be named as 1.JPG, 2.JPG, 3.JPG.
As a result, user gets two files IC.csv and unique.csv.
IC.csv gives detailed region-wise comparison for the three AEB images for MV
unique.csv gives algo outcome, i.e. which frames are needed for perticular scene
