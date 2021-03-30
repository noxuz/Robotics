% Trains neural net using stochastic mini batch 
% gradient descent with momentum, the net has a
% regression output layer, i.e. continous output values.
% NOTE: The training examples that dont fit in a whole mini
% batch are discarded.
%
% Arguments:
%   dataset: the supervised learning dataset with examples as
%            as rows and features as columns, the output value
%            must be the last column of the matrix.
% outputs: 
%   net: The trained net 
function net = trainNet(dataset,nn) 

% Hyperparameters
nn.epoch = 300;          % Number of iterations through whole dataset
nn.alpha = 0.1;       % Learning rate
nn.m = length(dataset);             % Minibatch size
nn.betaMomentum = 0.9; % Momentum rate

% Extract the number of training examples from the dataset.
numDatos = size(dataset,1);

% Initialize vector for saving the cost
nn.J = zeros(nn.epoch*floor(numDatos/nn.m),1);

% Get dataset mean and variance
nn.datasetmu = mean(dataset);
nn.datasetvariance = var(dataset);

% Normalize target outputs
datasethat = normalizar(dataset,mean(dataset),var(dataset));
%datasethat  = dataset;
targethat = datasethat(:,end);

% Delete previous waitbars
F = findall(0,'type','figure','tag','TMWWaitbar');
close(F);

% Create waitbar
bar = waitbar(0,'Training neural network');

% Train for each epoch
for e = 1:nn.epoch
tic
    % Get a random order of the mini-batches
    shuff = randperm(floor(numDatos/nn.m),floor(numDatos/nn.m));
    
    % Train for each mini-batch
    for n = 1:length(shuff)
        
        % Update waitbar
        waitbar(((e-1)*floor(numDatos/nn.m) + n)...
                                        /(nn.epoch*floor(numDatos/nn.m)));
        
        % Get a example batch and target values vector
        BatchRange = ((shuff(n)-1)*nn.m + 1):(shuff(n)*nn.m);
        exampleMiniBatch = datasethat( BatchRange,1:end-1);
        targetMiniBatch = targethat(BatchRange,end);
        
        % Kickstart activation in first layer for forward prop in for loop
        nn.layer{1}.f = exampleMiniBatch;
        
        % Forward propagation up to before regression output
        for l = 1:nn.numLayers-1
        
            % Fully connected step
            nn.layer{l}.z = nn.layer{l}.f * nn.layer{l}.W;
            
            % Input normalization step
            nn.layer{l}.variance = var(nn.layer{l}.z);
            nn.layer{l}.mu = mean(nn.layer{l}.z);
            nn.layer{l}.znorm = normalizar(nn.layer{l}.z,nn.layer{l}.mu,...
                                          nn.layer{l}.variance);
            
            % Batch normalization step
            nn.layer{l}.zhat = nn.layer{l}.znorm .* nn.layer{l}.gamma + ...
                               nn.layer{l}.beta;
            
            % Sigmoid output
            nn.layer{l+1}.f = sigmoide(nn.layer{l}.zhat);
                      
        end
    
        % Output regression layer computation
        nn.layer{nn.numLayers}.z = nn.layer{nn.numLayers}.f*...
                                   nn.layer{nn.numLayers}.W + ...
                                   nn.layer{nn.numLayers}.b;
                               
        % Output Mean Squared Error (MSE) computation
        nn.J(((e-1)*length(shuff)) + n) = ...
                   sum( (nn.layer{nn.numLayers}.z - targetMiniBatch ).^2 );
                                      
        % Backward propagation
        nn.layer{nn.numLayers}.gradz = nn.layer{nn.numLayers}.z - ...
                                       targetMiniBatch;
                          
        % Propagate throughout the output regression layer
        nn.layer{nn.numLayers-1}.gradzhat = (nn.layer{nn.numLayers}.gradz *...
                                           nn.layer{nn.numLayers}.W') .*...
                                (sigmoide(nn.layer{nn.numLayers-1}.z).*...
                              (1-sigmoide(nn.layer{nn.numLayers-1}.z)));
        
        % Backprop throughout BatchNorm
        nn.layer{nn.numLayers-1}.gradznorm = nn.layer{nn.numLayers-1}.gradzhat .*...
                                             nn.layer{nn.numLayers-1}.gamma;
                          
        % Temporal gradients for batchnorm backprop
        nn.layer{nn.numLayers-1}.gradvariance = ...
        sum(nn.layer{nn.numLayers-1}.gradznorm .* ...
        (nn.layer{nn.numLayers-1}.z - nn.layer{nn.numLayers-1}.mu ) ) .* ...
        (-0.5*(( nn.layer{nn.numLayers-1}.variance + 1e-8 ).^(-3/2)));
         
        nn.layer{nn.numLayers-1}.gradmu = ...
        sum(nn.layer{nn.numLayers-1}.gradznorm .* ...
        (-1./(sqrt( nn.layer{nn.numLayers-1}.variance + 1e-8))) ) + ...
        ( nn.layer{nn.numLayers-1}.gradvariance .* ...
        mean( -2*(nn.layer{nn.numLayers-1}.z - ...
        nn.layer{nn.numLayers-1}.mu) ));
        
        nn.layer{nn.numLayers-1}.gradz  = ... 
        (nn.layer{nn.numLayers-1}.gradznorm .* ...
        (1./(sqrt( nn.layer{nn.numLayers-1}.variance + 1e-8)))) + ...
        (nn.layer{nn.numLayers-1}.gradvariance .* ...
        ((2*(nn.layer{nn.numLayers-1}.z - nn.layer{nn.numLayers-1}.mu) ./ nn.m)) ) + ...
        (nn.layer{nn.numLayers-1}.gradmu ./ nn.m );
        % End of batchnorm backprop
        
        nn.layer{nn.numLayers-1}.gradf = nn.layer{nn.numLayers-1}.gradz *...
                                            nn.layer{nn.numLayers-1}.W';
                                        
        nn.layer{nn.numLayers-2}.gradzhat = ...
        nn.layer{nn.numLayers-1}.gradf .* ...
        (sigmoide(nn.layer{nn.numLayers-2}.zhat ) .* ...
        (1-sigmoide(nn.layer{nn.numLayers-2}.zhat )));
        
                                       
        % Propagate throughout rest of layers                  
        for l = nn.numLayers-2:-1:1

        nn.layer{l}.gradznorm = nn.layer{l}.gradzhat .*...
                                             nn.layer{l}.gamma;
                          
        % Temporal gradients for batchnorm backprop
        nn.layer{l}.gradvariance = ...
        sum(nn.layer{l}.gradznorm .* ...
        (nn.layer{l}.z - nn.layer{l}.mu ) ) .* ...
        (-0.5*(( nn.layer{l}.variance + 1e-8 ).^(-3/2)));
         
        nn.layer{l}.gradmu = ...
        sum(nn.layer{l}.gradznorm .* ...
        (-1./(sqrt( nn.layer{l}.variance + 1e-8))) ) + ...
        ( nn.layer{l}.gradvariance .* ...
        mean( -2*(nn.layer{l}.z - ...
        nn.layer{l}.mu) ));
        
        nn.layer{l}.gradz  = ... 
        (nn.layer{l}.gradznorm .* ...
        (1./(sqrt( nn.layer{l}.variance + 1e-8)))) + ...
        (nn.layer{l}.gradvariance .* ...
        ((2*(nn.layer{l}.z - nn.layer{l}.mu) ./ nn.m)) ) + ...
        (nn.layer{l}.gradmu ./ nn.m );
        % End of batchnorm backprop
        
        % Rest is not really needed if its the first layer
        if(l~=1) 
            nn.layer{l}.gradf = nn.layer{l}.gradz *...
                                            nn.layer{l}.W';
                                       
            nn.layer{l-1}.gradzhat = ...
            nn.layer{l}.gradf .* ...
            (sigmoide(nn.layer{l-1}.zhat ) .* ...
            (1-sigmoide(nn.layer{l-1}.zhat )));
        end
        
        end
        
        % Parameters update with momentum of fully connected layers with BN
        for j = 1:nn.numLayers-1
        
            % Update W
            nn.layer{j}.gradW = nn.layer{j}.f' * nn.layer{j}.gradz;
            nn.layer{j}.VW = nn.betaMomentum * nn.layer{j}.VW + ...
                             (1-nn.betaMomentum) * nn.layer{j}.gradW;
            nn.layer{j}.W = nn.layer{j}.W - (nn.alpha/nn.m)*nn.layer{j}.VW;
            
            % Update gamma
            nn.layer{j}.gradgamma = sum(nn.layer{j}.gradzhat .* ...
                                    nn.layer{j}.znorm);
            nn.layer{j}.Vgamma = nn.betaMomentum * nn.layer{j}.Vgamma + ...
                                (1-nn.betaMomentum)*nn.layer{j}.gradgamma;
            nn.layer{j}.gamma = nn.layer{j}.gamma - ...
                                (nn.alpha/nn.m)*nn.layer{j}.Vgamma;
                                
           % Update beta        
           nn.layer{j}.gradbeta = sum(nn.layer{j}.gradzhat);
           nn.layer{j}.Vbeta = nn.betaMomentum * nn.layer{j}.Vbeta + ...
                                (1-nn.betaMomentum)*nn.layer{j}.gradbeta;
           nn.layer{j}.beta = nn.layer{j}.beta - ...
                              (nn.alpha/nn.m)*nn.layer{j}.Vbeta;           
        end
        
        % Parameters update of output regression layer
        % Update W
        nn.layer{nn.numLayers}.gradW = nn.layer{nn.numLayers}.f' * ...
                                       nn.layer{nn.numLayers}.gradz;
        nn.layer{nn.numLayers}.VW = nn.betaMomentum * ...
                      nn.layer{nn.numLayers}.VW + (1-nn.betaMomentum) * ...
                      nn.layer{nn.numLayers}.gradW;
        nn.layer{nn.numLayers}.W = nn.layer{nn.numLayers}.W - ...
                                   (nn.alpha/nn.m)*nn.layer{nn.numLayers}.VW;
        
        % Update bias b
        nn.layer{nn.numLayers}.gradb =  sum(nn.layer{nn.numLayers}.gradz);
        nn.layer{nn.numLayers}.Vb = nn.betaMomentum * ...
                        nn.layer{nn.numLayers}.Vb + (1-nn.betaMomentum)*...
                        nn.layer{nn.numLayers}.gradb;
        nn.layer{nn.numLayers}.b = nn.layer{nn.numLayers}.b - ...
                        (nn.alpha/nn.m)*nn.layer{nn.numLayers}.Vb;
                        
    end
   toc                                                 
end
    
% Delete waitbar
close(bar)

% Return the trained net
net = nn;

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