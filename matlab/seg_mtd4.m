%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        		%    
% MTD4 - método com janela deslizante para detecção de BEP e EEP de segmentos	%
%	utilizando thresholding                                						%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%	W - comprimento da janela deslizante utilizada pelo método					%
%   T - valor de threshold                                      				%
%                                                                               %
% Retorno:                                                                      %
%   x_seg - cell array com os canais segmentados                                %
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd4(x, W, T)

    % Obtém comprimento do sinal e número de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

    % Array lógico para BEPs e EEPs detectados
    BEPsFlags = false(L,1);
    EEPsFlags = false(L,1);
    
    % Indicador se a janela procura por BEP ou EEP
    searchBEP = true;
    
	% Janela deslizante
	for w0 = 1:L-W
        if( ~(max(x_sum(w0:w0+W-1)) < T) && searchBEP ) % Detecção de BEP
            BEPsFlags(w0) = 1;
            searchBEP = false;
        end
        if( (max(x_sum(w0:w0+W-1)) < T) && ~searchBEP ) % Detecção de EEP
            EEPsFlags(w0+W-1) = 1;
            searchBEP = true;
        end
	end
    
    % Posições de EEPs e BEPs
    BEPsLocs = find(BEPsFlags);
    EEPsLocs = find(EEPsFlags);
    
    % Caso tenha sido detectada uma BEP sem respectivo EEP, elimina último BEP
    numberOfSegments = length(BEPsLocs);
    if( numBEPs > length(EEPsLocs))
        BEPsLocs(end) = [];
    end

    % Segmentação dos canais
    x_seg = cell(numberOfSegments,numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:numberOfSegments
            x_seg{currentSegment,currentChannel} = ...
                x(BEPsLocs(currentSegment):EEPsLocs(currentSegment));
        end
    end

end