function [  ] = autoTest( mainDir ,imgCount )
    for dict = [200 1024 2048]
        for pry = [2 3 4]
            for k = [5 9 13]
                testNameNai=strcat('nai_',num2str(dict),'_',num2str(pry),'_',num2str(k));
                testNameLLC=strcat('llc_',num2str(dict),'_',num2str(pry),'_',num2str(k));
            end
        end
    end
end

