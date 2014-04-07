function [ results ] = TestBuildPyramid()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

filePaths = ['p1010843.jpg'; 'p1010844.jpg'; 'p1010845.jpg'; 'p1010846.jpg'; 'p1010847.jpg'];
filePaths = cellstr(filePaths);
%outDir=strcat('TestPyramid_', datestr(now,'mmddyyyy_HHMMSSFFF'));
outDir=strcat('TestPyramid');
mkdir(outDir);
results = BuildPyramid(filePaths, 'images/', strcat(outDir, '/'));

end

