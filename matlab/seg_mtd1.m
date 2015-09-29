%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% MTD1 - m�todo iterativo utilizando thresholding para detec��o de centros    %
% 	de segmentos de comprimento constante                                     %
%                                                                             %
% Argumentos:                                                                 %
%   x - matriz column-wise com os sinais a serem segmentados                  %
%   l - comprimento desejado para os segmentos                                %
%   q - raz�o de atualiza��o entre itera��es para valor de threshold          %
%   r_target - raz�o m�nima esperada entre n�mero de segmentos e comprimento  %
%		total de sinal                                                        %
%   T_lim - valor de limite inferior para threshold                           %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x_seg = seg_mtd1(x, l, q, r_target, T_lim)

	% M�ximo dos canais � o valor inicial de threshold
    T0 = max(x); 
	
	% Obt�m comprimento do sinal e n�mero de canais
    [L, numberOfChannels] = size(x);
	
	% Array utilizado para armazenar o n�mero de candidatos a centro de
	% 	segmentos identificados por canal
	numberOfCandidates = zeros(1, numberOfChannels); 
	
	% Cell array utilizado para armazenar as localiza��es de candidatos
	%	a centro de segmentos identificados por canal
	locsOfCandidates = cell(1, numberOfChannels);
	
    % Plot dos centros identificados
    figure(1)
    
	% Identifica��o de candidatos a centro para cada um dos canais
    for currentChannel = 1:numberOfChannels 

		% Threshold inicial
		T_k = T0(currentChannel); 
        		
		% Processo iterativo
        targetReached = false;
		while ~targetReached

			% Calcula threshold desta itera��o
            T_k = q*T_k; 
            
			% Verifica se limite de valor de threshold foi atingido
            if T_k < T_lim
                warning(['Threshold limit reached on channel ', ...
                    num2str(currentChannel), '. Stopping iterations.'])
                break
            end
                
            % Identifica candidatos para centros de segmentos
            [centerValues, centerLocs] = findpeaks(x(:,currentChannel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
            
            % Determina o encerramento do processo iterativo
             targetReached = (length(centerLocs)/L > r_target);
			 
		end
		
		% Armazena o n�mero de candidatos identificados para este canal
		numberOfCandidates(currentChannel) = (length(centerLocs));

        % Armazena os locais dos candidatos identificados para este canal
        locsOfCandidates{currentChannel} = centerLocs;
        
        % Plot dos centros identificados
        subplot(5,2,currentChannel), plot(x(:,currentChannel)), hold on, ...
            plot(centerLocs,centerValues,'r*'), hold off
        
    end
end