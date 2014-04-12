function [ meanAccuracy ] = calcMeanAccuracy(numScenes, testLblVector, predicted_label)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

display(numScenes);
meanAccuracies = zeros(2, numScenes);
for j=1:length(testLblVector)
	actualLabel = testLblVector(j);
	meanAccuracies(1,actualLabel) = meanAccuracies(1,actualLabel) + 1;
	if predicted_label(j) == actualLabel
		meanAccuracies(2,actualLabel) = meanAccuracies(2,actualLabel) + 1;
	end
end

meanAccuracy = 0;
for column = 1:size(meanAccuracies,2)
	if (meanAccuracies(1,column) ~= 0)
		meanAccuracy = meanAccuracy + (meanAccuracies(2,column) / meanAccuracies(1,column)); 
	end
end
meanAccuracy = meanAccuracy / size(meanAccuracies,2);

end

