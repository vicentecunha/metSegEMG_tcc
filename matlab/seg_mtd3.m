%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        		%    
% MTD3 - m�todo com janela deslizante para detec��o de BEP e EEP de segmentos	%
%	utilizando varia��o total                           						%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%	W - comprimento da janela deslizante utilizada pelo m�todo					%
%   B - valor limite para declividade m�dia que determina um BEP				%
%   C - valor limite para varia��o total que determina um EEP					%
%                                                                           	%
% Retorno:                                                                      %
%   x_seg - cell array com os canais segmentados                                %
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd3(x, B, C)

    % Obt�m comprimento do sinal e n�mero de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

    % Array l�gico para BEPs e EEPs detectados
    BEPsFlags = false(L,1);
    EEPsFlags = false(L,1);
    
    % Indicador se a janela procura por BEP ou EEP
    searchBEP = true;
    
	% Janela deslizante
	for w0 = 1:L-W
        if( (mean(diff(x_sum(w0:w0+W-1))) > B) && searchBEP) % Detec��o de BEP
            BEPsFlags(w0) = 1;
            searchBEP = false;
        end
        if( (sum(diff(x_sum(w0:w0+W-1))) < C) && ~searchBEP) % Detec��o de EEP
            EEPsFlags(w0+W-1) = 1;
            searchBEP = true;
        end
	end
    
    % Posi��es de EEPs e BEPs
    BEPsLocs = find(BEPsFlags);
    EEPsLocs = find(EEPsFlags);
    
    % Caso tenha sido detectada uma BEP sem respectivo EEP, elimina �ltimo BEP
    numberOfSegments = length(BEPsLocs);
    if( numBEPs > length(BEPsLocs))
        BEPsLocs(end) = [];
    end

    % Segmenta��o dos canais
    x_seg = cell(numberOfSegments,numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:numberOfSegments
            x_seg{currentSegment,currentChannel} = ...
                x(BEPsLocs(currentSegment):EEPsLocs(currentSegment));
        end
    end
    
end