function [ meanAccuracy ] = calcMeanAccuracy(numScenes, testLblVector, predicted_label)
% Returns meanAccuracy in percentage form
%   Detailed explanation goes here

%display(numScenes);
%first row will be actual number of test label, and second will be
%correct num of predictions
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
meanAccuracy = meanAccuracy * 100;

end

