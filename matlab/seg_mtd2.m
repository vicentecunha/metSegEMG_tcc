%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                        		%    
% MTD2 - m�todo n�o iterativo utilizando thresholding para detec��o de 			%
% 	centros de segmentos de comprimento constante                           	%
%                                                                           	%
% Argumentos:                                                               	%
%   x - matriz column-wise com os canais do sinal a ser segmentado           	%
%   l - comprimento desejado para os segmentos                              	%
%   A - coeficiente utilizado para decis�o de m�todo de c�lculo de threshold	%
%   B - m�ltiplo da m�dia aritm�tica do sinal x para obten��o de threshold		%
%   C - fra��o do valor m�ximo do sinal x para c�lculo de threshold				%
%                                                                           	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd2(x, l, A, B, C)

	% Obt�m comprimento do sinal e n�mero de canais
    [L, numberOfChannels] = size(x);

    % Soma dos canais
    x_sum = zeros(L,1);
    for currentChannel = 1:numberOfChannels
        x_sum = x_sum + x(:,currentChannel);
    end

	% C�lculo do threshold
    if(max(x_sum) > A*mean(x_sum))
		T = B*mean(x_sum);
	else
		T = max(x_sum)/C;
    end
	
	% Identifica centros de segmentos
        [centerValues, centerLocs] = findpeaks(x_sum, ...
           'MinPeakHeight', T, 'MinPeakDistance',l);
    
    % Elimina��o de centros que est�o muito aos extremos do sinal
    if(centerLocs(1) < l/2)
        centerLocs(1) = [];
        centerValues(1) = [];
    end
    if(L - centerLocs(end) < l/2)
        centerLocs(end) = [];
        centerValues(end) = [];
    end
    
    % Segmenta��o dos canais
    x_seg = cell(length(centerLocs),numberOfChannels);
    for currentChannel = 1:numberOfChannels
        for currentSegment = 1:length(centerLocs)
            x_seg{currentSegment,currentChannel} = ...
                x(centerLocs - l/2: centerLocs+l/2-1,currentChannel);
        end
    end
	
end