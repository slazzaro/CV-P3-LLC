function [ predictLblVector ] = multiSVM( trainfeatureVector,trainLblVector,testfeatureVector,testName)

    u=unique(trainLblVector);
    numClasses=length(u);
    predictLblVector = zeros(length(testfeatureVector(:,1)),1);

    %build models
    for k=1:numClasses
        %Vectorized statement that binarizes Group
        %where 1 is the current class and 0 is all other classes
        G1vAll=(trainLblVector==u(k));
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] Training Model #',num2str(k))); 
        models(k) = svmtrain(trainfeatureVector,G1vAll,'kernel_function','rbf');
    end
    save(strcat('../vars/',testName,'_models.mat'),'models');

    %classify test cases
    for j=1:size(testfeatureVector,1)
        isFound=0;
        for k=1:numClasses
            if(svmclassify(models(k),testfeatureVector(j,:))) 
                isFound=1;
                break;
            end
        end
        if(isFound==0 && k==numClasses)
            %k=1 + (15-1).*randi(100,1);
            k=randi(15,1);
        end
        
        predictLblVector(j) = k;
        display(strcat(datestr(now,'HH:MM:SS'),' [INFO] test #',num2str(j))); 
    end

end

