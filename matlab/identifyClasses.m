function targetDataArray = identifyClasses(centerLocs, database, varargin)

if strcmp(database, 'ninapro')
    %% Remodela o vetor de estimulo, removendo trechos de 0
    stimulus = varargin{1};
    classLabel = stimulus;
    currentClass = 1;
    for index = 1:length(stimulus)
        if classLabel(index) ~= 0
            currentClass = classLabel(index);
        else
            classLabel(index) = currentClass;
        end
    end
end
if strcmp(database, 'iee')
    %% Divide temporalmente o sinal em 17 partes
    L = varargin{1};
    classLabel = zeros(L,1);
    for currentClass = 1:17
        for index = 1:L
            if index <= currentClass*L/17 && index > (currentClass-1)*L/17
                classLabel(index) = currentClass;
            end
        end
    end
end
%% Gera a matriz de identificacao das classes
numberOfSegments = length(centerLocs);
numberOfClasses = 17;
targetDataArray = false(numberOfSegments, numberOfClasses);
for currentSegment = 1:numberOfSegments
    targetDataArray(currentSegment,...
        classLabel(centerLocs(currentSegment))) = true;
end

end