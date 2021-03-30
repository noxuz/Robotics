% Function for predict a value given a trained net and
% a example input, does forward propagation with a net
% already trained; for nets with regression output layers
% this means, with continous output values
%
% Arguments:
%   example: row vector of the example input for predicting the output
% Outputs    
%   prediction: scalar continuos value outputted by the net
function prediction = predictNet(example,nn)

    % Dataset 
    % Forward propagation up to before regression output
    
    % Kickstart
    nn.layer{1}.fPredict = example;
    
    % Normalize wrt de whole dataset
    nn.layer{1}.fPredict = normalizar(nn.layer{1}.fPredict,nn.datasetmu,nn.datasetvariance);
    
    
          % Forward propagation up to before regression output
        for l = 1:nn.numLayers-1
        
            % Fully connected step
            nn.layer{l}.zPredict = nn.layer{l}.fPredict * nn.layer{l}.W;
            
            % Input normalization step
            nn.layer{l}.znormPredict = normalizar(nn.layer{l}.zPredict,nn.layer{l}.mu,...
                                                  nn.layer{l}.variance);
            
            % Batch normalization step
            nn.layer{l}.zhatPredict = nn.layer{l}.znormPredict .* nn.layer{l}.gamma + ...
                                      nn.layer{l}.beta;
            
            % Sigmoid output
            nn.layer{l+1}.fPredict = sigmoide(nn.layer{l}.zhatPredict);
                      
        end
    
        % Output regression layer computation
        nn.layer{nn.numLayers}.zPredict = nn.layer{nn.numLayers}.fPredict*...
                                          nn.layer{nn.numLayers}.W + ...
                                          nn.layer{nn.numLayers}.b;

    % Return prediction
    prediction =  nn.layer{nn.numLayers}.zPredict;
                
    % Funcion auxiliar sigmoide
    function sig = sigmoide(z)
        sig = reshape((1./(1+exp(-z(:)))),size(z));
    end

    % Funcion auxiliar de normalizacion de features modificada
    % solamente agrega eps al denominador para estabilizacion
    % especificado por el paper de batchNorm
    function normal = normalizar(x,mu,var)
        for i = 1:size(x,2)
            x(:,i) = (x(:,i) - mu(i)) ./ (sqrt(var(i) + 1e-8));
        end
        normal = x;
    end
                                                            
end