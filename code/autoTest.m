function [  ] = autoTest( mainDir ,imgCount )
    for dict = [200 1024 2048]
        for pry = [2 3 4]
            for k = [5 9 13]
                testNameNai=strcat('N_',num2str(dict),'_',num2str(pry),'_',num2str(k));
                testNameLLC=strcat('L_',num2str(dict),'_',num2str(pry),'_',num2str(k));
                
                MainSuper( mainDir ,imgCount, testName, useLLC, useKer, ...
                           isSaved, dictionarySize, pyramidLevels, ...
                           numTextonImages, patchSize, gridSpacing, k)
            end
        end
    end
end

