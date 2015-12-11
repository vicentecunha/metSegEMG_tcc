function [x_seg, finalCenterLocs] = seg_mtd3(x, l_min, l_max, step, W, B, C)
%   MTD3 - metodo com janela deslizante para deteccao de BEP e EEP de segmentos
%	utilizando variacao total                           		
%                                                                
% Argumentos: (para mais detalhes, refira a descricao do MTD3)                                                   
%   x - matriz cujas colunas sao canais do sinal a ser segmentado
%   l_min - compimento minimo para segmentos
%   l_max - compimento maximo para segmentos
%   step - numero de amostras a incrementr posicao de janela
%	W - comprimento da janela deslizante utilizada pelo metodo
%   B - valor limite para variacao total que determina um BEP
%   C - valor limite para variacao total que determina um EEP
%                                                                
% Retorno:                                                       
%   x_seg - cell array com os canais segmentados
%   finalCenterLocs - posicoes centrais dos segmentos

%% Preprocessamento
[L, numberOfChannels] = size(x); % comprimento do sinal e numero de canais
x_ret = abs(x); % retificacao
x_norm = zeros(L, numberOfChannels); % normalizacao
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

totalVariation = zeros(L-W,numberOfChannels);
BEPsLocsFlags = false(W,numberOfChannels);
EEPsLocsFlags = false(W,numberOfChannels);
BEPsLocsCell = cell(1,numberOfChannels);
EEPsLocsCell = cell(1,numberOfChannels);
searchBEP = true(numberOfChannels,1);
lastBEPloc = zeros(numberOfChannels,1);
for w0 = 1:step:L-W % janela deslizante para calculo de variacao total
    for currentChannel = 1:numberOfChannels
        totalVariation(w0, currentChannel) =...
            sum(diff(x_norm(w0:w0+W, currentChannel)));
        % Identificacao de BEPs e EEPs
        switch searchBEP(currentChannel)
            case true % deteccao de BEPs
                if totalVariation(w0, currentChannel) > B
                    BEPsLocsFlags(w0, currentChannel) = true;
                    lastBEPloc(currentChannel) = w0;
                    searchBEP(currentChannel) = false;
                end
            case false % deteccao de EEPs
                if (w0+W-lastBEPloc(currentChannel)) > l_max
                    % segmento excederia comprimento maximo
                    BEPsLocsFlags(lastBEPloc(currentChannel),currentChannel)=false;
                    searchBEP(currentChannel) = true;
                else if (totalVariation(w0, currentChannel) < C) && ...
                            (w0+W-lastBEPloc(currentChannel) > l_min)
                        EEPsLocsFlags(w0+W,currentChannel) = true;
                        searchBEP(currentChannel) = true;
                    end
                end
        end
    end
end
for currentChannel = 1:numberOfChannels
    BEPsLocsCell{1,currentChannel} = find(BEPsLocsFlags(:,currentChannel));
    EEPsLocsCell{1,currentChannel} = find(EEPsLocsFlags(:,currentChannel));
end

%% Clustering

BEPsLocsArray = sort(cell2mat(BEPsLocsCell'));
EEPsLocsArray = sort(cell2mat(EEPsLocsCell'));
[~, labscoreBEPs] = dbscan(BEPsLocsArray,2000,3);
[~, labscoreEEPs] = dbscan(EEPsLocsArray,2000,3);
numberOfBEPs = max(labscoreBEPs);
numberOfEEPs = max(labscoreEEPs);
% medias internas aos clusters
meanBEPs = zeros(numberOfBEPs,1);
for currentCluster = 1:numberOfBEPs 
    meanBEPs(currentCluster) = ...
        round(mean(BEPsLocsArray(labscoreBEPs == currentCluster)));
end
meanEEPs = zeros(numberOfEEPs,1);
for currentCluster = 1:numberOfEEPs
    meanEEPs(currentCluster) = ...
        round(mean(EEPsLocsArray(labscoreEEPs == currentCluster)));
end

%% Pareamento final de BEPs e EEPs
% (devem ocorrer alternadamente e atender requisitos de l_min e l_max)

allLocs = sortrows([meanBEPs,true(length(meanBEPs),1);...
    meanEEPs,false(length(meanEEPs),1)]);
locsDelta = diff(allLocs,1);
numberOfDeltas = length(locsDelta(:,1));
finalBEPsFlags = false(numberOfDeltas+1,1);
finalEEPsFlags = false(numberOfDeltas+1,1);
for currentDelta = 1:numberOfDeltas
    if (locsDelta(currentDelta,1) > l_min) && ...
            (locsDelta(currentDelta,1) < l_max) && ...
            locsDelta(currentDelta,2) == -1; % par BEP-EEP valido
        finalBEPsFlags(currentDelta) = true;
        finalEEPsFlags(currentDelta+1) = true;
    end
end
finalBEPs = allLocs(finalBEPsFlags, 1);
finalEEPs = allLocs(finalEEPsFlags, 1);

%% Segmentacao

numberOfSegments = length(finalBEPs);
finalCenterLocs = zeros(numberOfSegments,1);
x_seg = cell(numberOfSegments,numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        x_seg{currentSegment,currentChannel} = ...
            x(finalBEPs(currentSegment):finalEEPs(currentSegment),currentChannel);
        finalCenterLocs(currentSegment) = ...
            round(mean([finalBEPs(currentSegment),finalEEPs(currentSegment)]));
    end
end
end
