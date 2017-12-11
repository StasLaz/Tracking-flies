# Tracking-flies

Code for tracking flies in glass tubes.

## Features
--------

* Video stabilization for shaking or shifting videos
* Background substraction on a greyscale video
* Finding flies in regions of interest
* Tracking flies coordinates

## Algorithm
---------
Run:

1. regionmask.m with number of tubes to define the masks
   - Choose combination of colors
   - select rectangles of interest by clicking two verteces. 

2. readfr.m with option 2 to find flies in one frame. 
   - Ajust parameters to find all flies and make onelog file not too noisy. 
   - Check bg file to find if any of the flies died.
   - Test multiple random flies for check.
   - Use delete_mask.m to delete masks with dead flies

3. colorpref.m with all videos to find number of flies in regions of interest defined buy masks.
   - Select video files to go through
   - Select video for the reference frame to eliminate shaking
   - Select masks from regionmask.m

4. plot_colorpref.m to plot the fractions of flies in each region of interest as a timeseries
   - Define binning of data and how many bins to skip
   - Select color_preference file from colorpref.m and flies in the file

5. preference_calculation.m to find average fractions of flies during day and average avoidance
   - Define binning of data and how many bins to skip and length of the day
   - Select color_preference file from colorpref.m and flies in the file
   - Choose interval in data for averaging
   - Choose interval in averaged data for mean avoidance of second color (blue)

6. trackfly.m to find coordinates of flies 
   - Select video files to go through
   - Select video for the reference frame to eliminate shaking
   - Select masks from regionmask.m 

## Examples
### Frame with flies
<img src="/examples/Frame.png" width="500">

### Background frame with flies substracted
<img src="/examples/Background.png" width="500">

### Substracted flies without backgound with noise
<img src="/examples/Onelog.png" width="500">

### Flies found on the background after eliminating noise
<img src="/examples/Flies.png" width="500">
