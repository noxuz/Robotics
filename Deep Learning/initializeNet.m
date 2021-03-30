% Initializes neural net with regression output layer. i.e.
% for continuos output vales, not categorical given a 
% specified architecture, uses intermediate batch normalization 
% layers and glorot uniform initializer for 
% the learnable parameters.
% 
% Arguments:
%   arch: Vector definining the architecture of the net.
%         example [30 50 20 1]
% Outputs
%   nn: Neural net structure containing the initialized weights and
%       parameters
function nn = initializeNet(arch)

% Input assertions
assert(arch(end) == 1, 'The last layer must be of size 1 for regression nets');    

nn.numLayers = length(arch)-1; % Number of layers in the network (excluding the output)

% Initialization of learnable parameters with glorot and intermediate
% batchnorm of all layers except the regression output together
% with the initialization of the gradient of the loss wrt that param
% and the momemtum of that parameter for backpropagation.
for i = 1:nn.numLayers-1
    
    % Weight matrix
    nn.layer{i}.W = -sqrt(6)/sqrt(arch(i)+arch(i+1)) + ...
                    2*(sqrt(6)/sqrt(arch(i)+arch(i+1)))*rand(arch(i),arch(i+1));
    
    nn.layer{i}.gradW = zeros(size(nn.layer{i}.W));
    nn.layer{i}.VW = zeros(size(nn.layer{i}.W));

    % Parameters for BatchNorm
    nn.layer{i}.variance = 0; % Mini-batch variance
    nn.layer{i}.gradvariance = 0;
    nn.layer{i}.Vvariance = 0;
    
    nn.layer{i}.mu = 0; % Mini-batch mean
    nn.layer{i}.gradmu = 0; 
    nn.layer{i}.Vmu = 0; 
    
    % Batch normalization learnable paramaters initialization
    nn.layer{i}.gamma = ones(1,arch(i+1));
    nn.layer{i}.gradgamma = 0;
    nn.layer{i}.Vgamma = 0;
    
    nn.layer{i}.beta = zeros(1,arch(i+1));
    nn.layer{i}.gradbeta = 0;
    nn.layer{i}.Vbeta = 0;
           
end

% Initialization with glorot of the regression output layer 
% learnable parameters, together with gradient
nn.layer{nn.numLayers}.W = -sqrt(6)/sqrt(arch(end-1)+1) + ...
                            2*(sqrt(6)/sqrt(arch(end-1)+1))*rand(arch(end-1),1);

nn.layer{nn.numLayers}.gradW = zeros(size(nn.layer{nn.numLayers}.W));                     
nn.layer{nn.numLayers}.VW = zeros(size(nn.layer{nn.numLayers}.W));

% Regression output layer bias
nn.layer{nn.numLayers}.b = 0;
nn.layer{nn.numLayers}.gradb = 0; 
nn.layer{nn.numLayers}.Vb = 0; 

end
