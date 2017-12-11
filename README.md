Tracking-flies
==============
code for tracking flies in glass tubes.

FEATURES
--------

* Video stabilization for shaking or shifting videos
* Background substraction on a greyscale video
* Finding flies in regions of interest
* Tracking flies coordinates

ALGORITHM
---------
Run:
1) regionmask.m with number of tubes to define the masks 
2) readfr.m with option 2 to find flies in one frame. Ajust parameters to find all flies and make onelog file not too noisy. Check bg file to find if any of the flies died. Test multiple random flies for check.
3) colorpref.m with all videos to find number of flies in regions of interest defined buy masks.
4) plot_colorpref.m to plot the fractions of flies in each region of interest as a timeseries
5) preference_calculation.m to find average fractions of flies during day and average avoidance
6) trackfly.m to find coordinates of flies 
