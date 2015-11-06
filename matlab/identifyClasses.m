%%
%   Identificacao das classes de movimentos
%%

function targetDataArray = identifyClasses(centerLocs, stimulus)

%% Remodela o vetor de estimulo, removendo trechos de 0

reshapedStimulus = stimulus;
currentMovement = 1;
for index = 1:length(stimulus)
    if reshapedStimulus(index) ~= 0
        currentMovement = reshapedStimulus(index);
    else
        reshapedStimulus(index) = currentMovement;
    end
end

%% Gera a matriz de identificacao das classes

numberOfSegments = length(centerLocs);
numberOfClasses = 17;
targetDataArray = false(numberOfSegments, numberOfClasses);
for currentSegment = 1:numberOfSegments
    targetDataArray(currentSegment,...
        reshapedStimulus(centerLocs(currentSegment))) = true;
end

end