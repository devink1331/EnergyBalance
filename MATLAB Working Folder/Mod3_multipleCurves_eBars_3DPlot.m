% this function creates a 3D surface where temperature is on the z axis. It
% has you pick a thermal image first, uses importr to obtain matrix of temp
% data and then plots the the temp data to a surface. 


% taken from EX 5 in mod 3 of tutorials here: C:\LearningMatlab
    % 3-D mesh surface can be plotted using the functions mesh and surf.
    % mesh(X,Y,Z,C) plots the colored parametric mesh defined by four matrix
    % arguments. The view point is specified by VIEW. The axis labels are determined
    % by the range of X, Y and Z, or by the current setting of AXIS. The color scaling is
    % determined by the range of C, or by the current setting of CAXIS. The scaled color values are used as indices into the current COLORMAP.
    % Example: present the function sin(r)/r using the mesh function

% [X,Y] = meshgrid(-8:.5:8); % creates mesh of values where x and y both range from -8 to 8 and step by .5. 
importr
A = ans
x = 1:size(A,2);
y = 1:size(A,1);
[X,Y] = meshgrid(x,y)

C = gradient(A);
surf(X,Y,A);