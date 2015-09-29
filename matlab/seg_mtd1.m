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

    T0 = max(x); % M�ximo dos canais � o valor inicial de threshold
    [L, num_channels] = size(x); % Obt�m comprimento de sinais e n�mero de canais
        
    for current_channel = 1:num_canais % Segmenta��o para cada um dos canais

		T_k = T0(current_channel); % Threshold inicial
        
		% Processo iterativo:
        target_reached = false;
		while ~target_reached
		
            T_k = q*T_k; % Calcula threshold desta itera��o
            
            if T_k < T_lim % Limite de valor de threshold atingido
                break
            end
                
            % Identifica os poss�veis candidatos para centros de segmentos
            [~, centers_locs_current_channel] = findpeaks(x(:,current_channel), ...
               'MinPeakHeight', T_k, 'MinPeakDistance',l);
            
            % Determina o encerramento do processo iterativo
             target_reached = (length(centers_locs_current_channel)/L > N);

		end
    end
end