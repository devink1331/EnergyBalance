clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 15;


%===============================================================================
% Get the name of the image the user wants to use.
baseFileName = 'thermal test.jpg'; % Assign the one on the button that they clicked on.
% Get the full filename, with path prepended.
folder = 'C:\Users\Brian\Desktop\'
fullFileName = fullfile(folder, baseFileName);
%===============================================================================


% Read in a demo image.
originalRGBImage = imread(fullFileName);


% Display the image.
subplot(2, 3, 1);
imshow(originalRGBImage, []);
axis on;
caption = sprintf('Original Pseudocolor Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;




grayImage = min(originalRGBImage, [], 3); % Useful for finding image and color map regions of image.
% Get the dimensions of the image.  numberOfColorChannels should be = 3.
[rows, columns, numberOfColorChannels] = size(originalRGBImage);




% Crop off the surrounding clutter to get the colorbar.
colorBarImage = imcrop(originalRGBImage, []);
b = colorBarImage(:,:,3);


imshow(colorBarImage, []);
axis on;
caption = sprintf('ColorBar Image, %s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Column', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Row', 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;




% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off') 
% Get the color map.
storedColorMap = colorBarImage(:,1,:);
% Need to call squeeze to get it from a 3D matrix to a 2-D matrix.
% Also need to divide by 255 since colormap values must be between 0 and 1.
storedColorMap = double(squeeze(storedColorMap)) / 255
% Need to flip up/down because the low rows are the high temperatures, not the low temperatures.
storedColorMap = flipud(storedColorMap);
% Convert from an RGB image to a grayscale, indexed, thermal image.
indexedImage = rgb2ind(originalRGBImage, storedColorMap);
% Display the thermal image.
subplot(2, 3, 4);
imshow(indexedImage, []);
axis on;
caption = sprintf('Indexed Image (Gray Scale Image)');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
drawnow;
% Define the temperature at the top end of the scale
% This will probably be the high temperature.
highTemp = 53.9;
% Define the temperature at the dark end of the scale
% This will probably be the low temperature.
lowTemp = 26.1;
% Scale the image so that it's actual temperatures
thermalImage = lowTemp + (highTemp - lowTemp) * mat2gray(indexedImage);
subplot(2, 3, 5);
imshow(thermalImage, []);
axis on;
colorbar;
title('Floating Point Thermal (Temperature) Image', 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo(); % Let user mouse around and see temperatures.
hp.Units = 'normalized';
hp.Position = [0.45, 0.03, 0.25, 0.05];
% Get the histogram of the indexed image
subplot(2, 3, 6);
histogram(thermalImage, 'Normalization', 'probability');
axis on;
grid on;
caption = sprintf('Histogram of Thermal Temperature Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
xlabel('Temperature', 'FontSize', fontSize, 'Interpreter', 'None');
ylabel('Frequency', 'FontSize', fontSize, 'Interpreter', 'None');