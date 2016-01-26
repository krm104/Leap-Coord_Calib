%{
This function is used to calibrate the coordinate system transformation
between a Leap Motion controller and an ART IR tracking system. The
functions works by performing an aboslute orientation calculation (using
Umeyama's method) between a set of points captured by the Leap Motion and
the same set of points as recorded by the ART system.

There are several options for inputs to the function:

('path to DATAPOINTS file', length_of_stylus, leap-to-ART-transform)

(length_of_stylus, leap-to-ART-transform)

(length_of_stylus)

The length_of_stylus input is required in all three methods. This function
presumes that the input points from the leap motion are stylus tip points
and that the ART points are centered below the stylus offset by a
distance of (length_of_stylus). This value needs to be determined off-line
and is dependent on your particular stylus-marker setup. See :----: for
more information about creating a stylus-marker arrangement for this
calibration.

'path to DATAPOINTS file' is an optional sting input that provides the path
to the DATAPOINTS file created by the calibration software :----:. More
information about the formatting of this file can be found at the github
repositroy :----:. If this option is excluded, it is presumed that the file
exists in the current directory and is named 'DataPoints.calib'.

leap-to-ART-transform is a boolean value that specifies whether the
output provides the transformation for Leap points into the ART
coordinate frame, or for ART points into the Leap coordinate frame. The
default value is true (transform Leap points to the ART coordinate
frame) since this is the most likely case of why you're doing the
claibration. Passing in False will give the opposite transformation for
whatever reason you may need that.

//////////////////////////////////////////////

The output arguments are:

Tmat - 4 x 4 transformation matrix, in column major order, describing the
transformation from the Leap motion points into the ART coordinate
frame. This matrix can be directly used in OpenGL for performing the
transformations or for whatever purpose you need.

R - 3 x 3 rotation matrix in row major order used for column vector
multiplication (post mulitply). This describes the rotational difference
between the two coordinate frames.

t - 3 x 1 translation matrix in row major order describing the translation
offset between the two coordinate frames.

c - single scalar value describing the scale difference between the two
coordinate frames.

error - single scalar number describing the error in the obsolute
orientation results. Lower is better with values below 1 being ideal, but
between 1 and 2 may also be acceptable.

The transformation between Leap Point LP and ART point AP can be
described by: AP = c*R*LP + t

The absolute orientation calculation is performed using Umeyama's method
for Singular Value Decomposition. The accompanying script
'absoluteOrientationSVD' was created by Nishanth Koganti (currently at
NAIST at the time of this writing).
%}
function [Tmat, R, t, c, err] = CalibrateLeapToART(varargin)

DATAPOINTSFILE = 'DataPoints.calib';
length_of_stylus = 0.0;
leap2ARTTransform = true;

%%Determine Which Input Set Was Selected%%
switch nargin
    case 1
        length_of_stylus = varargin{1};
    case 2
        length_of_stylus = varargin{1};
        leap2ARTTransform = varargin{2};
    case 3
        DATAPOINTSFILE = varargin{1};
        length_of_stylus = varargin{2};
        leap2ARTTransform = varargin{3};
    otherwise
        error('Improper argument usage!\n Verify Input Arguments');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Read in the DATAPOINTS File%%
%% Check if the Input Data File is valid %%
fileID = fopen(DATAPOINTSFILE, 'r');
if fileID == -1 %% file not found %%
    error('Calibration Data File Not Fount! %s\n', DATAPOINTSFILE);
end

%% Read Calibration Data  %%
DATAPOINTS = csvread(DATAPOINTSFILE, 1, 0)';

%% Close the Input Data File %%
if fclose(fileID) == -1
    fprintf('Error Closing Calibration Data File: %s\n', DATAPOINTSFILE);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Split the LeapPoints and ARTPoints%%
LPPoints = zeros(3, 0); %%Leap Motion Points
ARTPoints = zeros(3, 0); %%ART Points

for datai = 1:size(DATAPOINTS, 2)
    transformLPPoint = DATAPOINTS(1:3, datai) - DATAPOINTS(4:6, datai)*length_of_stylus;
    LPPoints = [LPPoints transformLPPoint];
    MarkerTrans = DATAPOINTS(19:21, datai);
    ARTPoints = [ARTPoints MarkerTrans];
end %%End for loop%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Perform Absolute Orientation Calculation between point clouds%%
if leap2ARTTransform
    [R, t, c, err, xout] = absoluteOrientationSVD(LPPoints, ARTPoints);
    Tmat = [[c*R t];[0 0 0 1]]';
else
    [R, t, c, err, xout] = absoluteOrientationSVD(ARTPoints, LPPoints);
    Tmat = [[c*R t];[0 0 0 1]]';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Generate Graphs showing the two point clouds%%
fontSize = 12;
markerSize = 5;

%%Both Sets of Points Un Transformeed%%
figure('Name', 'Leap and Camera Points');
xlabel('X', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Y', 'FontSize', fontSize, 'FontWeight', 'bold');
zlabel('Z', 'FontSize', fontSize, 'FontWeight', 'bold');
title('Leap and Camera Points',  'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', fontSize, 'FontWeight', 'bold');  
plot3(LPPoints(1, :), LPPoints(2, :), LPPoints(3, :), '.b', 'MarkerSize', markerSize);
hold on;
plot3(ARTPoints(1, :), ARTPoints(2, :), ARTPoints(3, :), '.r', 'MarkerSize', markerSize);
legend('Leap Points', 'ART Points');
grid on;
hold off;

%%Both Sets of Points With the corresponding Set transformed%%
figure('Name', 'Leap and Camera Points Transformed');
xlabel('X', 'FontSize', fontSize, 'FontWeight', 'bold');
ylabel('Y', 'FontSize', fontSize, 'FontWeight', 'bold');
zlabel('Z', 'FontSize', fontSize, 'FontWeight', 'bold');
title('Leap and Camera Points Transformed',  'FontSize', fontSize, 'FontWeight', 'bold');
set(gca, 'FontSize', fontSize, 'FontWeight', 'bold');  
if leap2ARTTransform
plot3(xout(1, :), xout(2, :), xout(3, :), '.b', 'MarkerSize', markerSize);
hold on;
plot3(ARTPoints(1, :), ARTPoints(2, :), ARTPoints(3, :), '.r', 'MarkerSize', markerSize);
legend('Leap Points Transformed', 'ART Points');
else
plot3(LPPoints(1, :), LPPoints(2, :), LPPoints(3, :), '.b', 'MarkerSize', markerSize);
hold on;
plot3(xout(1, :), xout(2, :), xout(3, :), '.r', 'MarkerSize', markerSize);
legend('Leap Points', 'ART Points Transformed');
end
grid on;
hold off;

end %[Tmat, R, t, c, err] = CalibrateLeapToART(DATAPOINTS)%