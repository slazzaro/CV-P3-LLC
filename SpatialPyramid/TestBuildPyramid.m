function [ results ] = TestBuildPyramid()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%filePaths = ['p1010843.jpg'; 'p1010844.jpg'; 'p1010845.jpg'; 'p1010846.jpg'; 'p1010847.jpg'];
filePaths = ['image_0001.jpg'; 'image_0002.jpg'; 'image_0003.jpg'];
filePaths = cellstr(filePaths);
%outDir=strcat('TestPyramid_', datestr(now,'mmddyyyy_HHMMSSFFF'));
outDir=strcat('TestPyramid');
mkdir(outDir);
%imagePath = 'images/';
imagePath = '../scene_categories/bedroom/';

% dirData = dir('../scene_categories/bedroom');      %# Get the data for the current directory
% dirIndex = [dirData.isdir];  %# Find the index for directories
% fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
% validIndex = ~ismember(fileList,{'.db'});  %# Find index of subdirectories #   that are not '.' or '..'
% 
% for i = 1:size(fileList,1)
%     
% end
%addpath('./SpatialPyramid/');
results = BuildPyramidLLC(filePaths, imagePath, strcat(outDir, '/'));

end

