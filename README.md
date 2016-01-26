# Leap-Coord_Calib
This repository contains a set of matlab scripts, which provide a straightforward absolute orientation algorithm for determining the transformation between the Leap Motion cooridnate frame and a secondary reference source (such as a camera, IR tracker, etc.).

The base script is the CalibrateLeapToART.m matlab script. This file contains a single matlab function, which reads in point data from the Leap Motion and secondary source and calls an absolute orientation function to calculate the transformation between the two. The script file: absoluteOrientationSVD.m actually contains the absolute orientation calculation code, though is not intended to be called in isolation.

The code for the absoluteOrientationSVD. is taken from Nishanth Koganti during his time at NAIST in 2015/02/05. The original source for his implementation, which is based on Umeyama's absolute orientation method, can be found at:
http://math.stackexchange.com/questions/745234/calculate-rotation-translation-matrix-to-match-measurement-points-to-nominal-poi

Explicit usage instrations for the CalibrateLeapToART.m function is provided within the script file itself.

A set of sample data is provided in the DataPoints.calib file. This file contains example Leap Motion point data and a second set of tracked positions taken from an ART IR tracking camera pair.

The example data and source code in both script files is completely open source and free to use for any purpose. It is my desire that this software be used to the fullest extent to promote the development of novel and exciting new applications for the Leap Motion controller.
