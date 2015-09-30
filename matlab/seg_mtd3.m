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

	% Janela deslizante
	for w0 = 1:L-W
		if( mean(diff(x_sum(w0:w0+W-1))) > B ) % Detec��o de BEP
			
		end
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