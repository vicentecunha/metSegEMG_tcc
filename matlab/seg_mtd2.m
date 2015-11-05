%%
%   MTD2 - metodo nao iterativo utilizando thresholding para deteccao de
% 	centros de segmentos de comprimento constante                           
%                                                                           
% Argumentos: (para mais detalhes, refira a descricao do MTD2)                                                              
%   x - matriz cujas colunas sao canais do sinal a ser segmentado           
%   l - comprimento desejado para os segmentos
%       (deve ser inteiro maior que zero)                             
%   A - coeficiente utilizado para decisao de metodo de calculo de threshold
%       (deve ser maior ou igual a 1)
%   B - multiplo da media aritmetica do sinal x para obtencao de threshold
%       (deve ser maior ou igual a 1)	
%   C - fracao do valor maximo do sinal x para calculo de threshold	
%       (deve ser maior ou igual a 1)
%                                                                           
% Retorno:                                                                   
%   x_seg - cell array com os canais segmentados
%   centerLocs - posicoes centrais dos segmentos
%%

function [x_seg, centerLocs] = seg_mtd2(x, l, A, B, C)

%% Preprocessamento

% Obtem comprimento do sinal e numero de canais
[L, numberOfChannels] = size(x);

% Retificacao
x_ret = abs(x);

% Normalizacao
x_norm = zeros(L, numberOfChannels);
for currentChannel = 1:numberOfChannels
    x_norm(:,currentChannel) = ...
        x_ret(:,currentChannel)./max(x_ret(:,currentChannel));
end

%% Metodo

% Cell array para armazenar posicoes dos segmentos identificados
centerLocsCell = cell(1,numberOfChannels);

for currentChannel = 1:numberOfChannels
    
    % Calculo do threshold
    maxValue = 1; % sinais normalizados
    meanValue = mean(x_norm(:,currentChannel));
    if maxValue > (A*meanValue)
        T = B*meanValue;
    else
        T = maxValue/C;
    end
    
    % Identifica centros de segmentos
    [~, centerLocsCell{1,currentChannel}] = ...
        findpeaks(double(x_norm(:,currentChannel)), ...
        'MinPeakHeight', T, 'MinPeakDistance',l);
end

%% Segmentacao dos canais

% Maximo numero de segmentos detectados
numberOfSegments = 0;
for currentChannel = 1:numberOfChannels
    currentChannelNumberOfSegments = length(centerLocsCell{1,currentChannel});
    if  currentChannelNumberOfSegments > numberOfSegments
        numberOfSegments = currentChannelNumberOfSegments;
    end
end

% Clustering dos centros de segmentos detectados
centerLocsArray = cell2mat(centerLocsCell');
idx = kmeans(centerLocsArray,numberOfSegments);

% Clustering dos centros de segmentos detectados
centerLocsArray = cell2mat(centerLocsCell');
[~,C] = kmeans(centerLocsArray,numberOfSegments);
centerLocs = sort(round(C));

% Segmentacao
x_seg = cell(numberOfSegments,numberOfChannels);
for currentChannel = 1:numberOfChannels
    for currentSegment = 1:numberOfSegments
        if mod(l,2) == 0 % se l for par
            if (centerLocs(currentSegment)-l/2) < 1 % segmento muito a esquerda
                x_seg{currentSegment,currentChannel} = ...
                    x(1:centerLocs(currentSegment)+l/2 - 1, currentChannel);
            else if (centerLocs(currentSegment)+l/2 - 1) > L % segmento muito a direita
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2:L, currentChannel);
                else
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2: ...
                        centerLocs(currentSegment)+l/2 - 1, currentChannel);
                end
            end
        else % se l for impar
            if (centerLocs(currentSegment)-(l+1)/2) < 1 % segmento muito a esquerda
                x_seg{currentSegment,currentChannel} = ...
                    x(1:centerLocs(currentSegment)+l/2 - 1, currentChannel);
            else if (centerLocs(currentSegment)+(l+1)/2 - 1) > L % segmento muito a direita
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-l/2:L, currentChannel);
                else
                    x_seg{currentSegment,currentChannel} = ...
                        x(centerLocs(currentSegment)-(l+1)/2: ...
                        centerLocs(currentSegment)+(l+1)/2 - 1, currentChannel);
                end
            end
        end
    end
end

end