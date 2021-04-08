% Matlab simulation of a Jerboa Robot's hybrid dynamics performing 
% fore-aft and vertical hopping control.
%  
% From the UPenn Robotics Micromasters program at edX.org
%  
% Abraham Rodriguez Vazquez  
% 
% More information in the following links:
%
% https://www.youtube.com/watch?v=wvYthkpRFfk&ab_channel=kodlab
% https://kodlab.seas.upenn.edu/uploads/Main/compositionTR.pdf

% Robot parameters
param.d = 0.08;                 % ball diameter
param.g = 9.8;                  % acceleration of gravity
param.r = 0.3;                  % leg/ spring rest length
param.k = 5000;                 % virtual spring eleastic constant
param.b = 6.;                   % damping constant
param.mb = 2.0;                 % body mass
param.Ib = 1;                   % body inertia
param.lb = 0.3;                 % body length
param.mt = 0.1;                 % tail mass
param.lt = 0.4;                 % tail length
param.It = param.mt*param.lt^2; % tail inertia

% Control parameters
param.desiredpitch = 0;     % desired pitch
param.desireddpitch = 0;    % desired pitch velocity
param.Kp = 100;             % P gain for pitch/tail control
param.Kv = 15;              % D gain for pitch/tail control
param.thetatd = 0.;         % leg nominal touchdown angle
param.xddes = 0.8;          % desired forward speed
param.xdgain = 0.025;       % gain for Raibert's speed control

% Initial conditions Q0 = [x dx y dy phi1 dphi1 phi2 dphi2]
Q0 = [0 0.0 0.5 0 -pi/8 0 pi 0];
tbegin = 0;
tfinal = 2;
phase = 2;

% Position of the foot
xfoot = Q0(end,1) + param.r*sin(param.thetatd);
yfoot = Q0(end,3) - param.r*cos(param.thetatd);

% ODE solving
T = tbegin;
Q = Q0;
while T(end) < tfinal
    if phase == 1
        % stance phase
        stance_start = Ttemp(end);
        
        options = odeset('Events',@(t, Q)EventLiftOff(t, Q, param, xfoot_stance),'MaxStep',1e-4,'AbsTol',1e-4,'RelTol',1e-4);
        [Ttemp, Qtemp, te, Qe, ie] = ...
            ode45(@(t, Q)EOMStance(t, Q, param, xfoot_stance),[tbegin, tfinal], Q0,options);
        xfoot = xfoot_stance*ones(size(Ttemp,1),1);
        yfoot = zeros(size(Ttemp,1),1);
        
        % compute forward speed of the robot
        xd = Qtemp(end,2);
        
        % compute stance time
        stance_end = Ttemp(end);
        stance_duration = stance_end - stance_start;
        
        % Raibert's stepping control
        % --- COMPLETE THIS SECTION --- %
        % ---  USE WEEK 11 RESULTS  --- %
        param.thetatd = asin((xd*stance_duration)/(2*param.r) + (param.xdgain*(xd-param.xddes))/param.r);

        
        phase = 2;
    elseif phase == 2
        % flight phase
        options = odeset('Events',@(t, Q)EventTouchDown(t, Q, param),'MaxStep',1e-4,'AbsTol',1e-4,'RelTol',1e-4);
        [Ttemp, Qtemp, te, Qe, ie] = ode45(@(t, Q)EOMFlight(t, Q, param),[tbegin, tfinal], Q0, options);
        xfoot = Qtemp(:,1) + param.r*sin(param.thetatd);
        yfoot = Qtemp(:,3) - param.r*cos(param.thetatd);
        xfoot_stance = xfoot(end);
        phase = 1;
    end
    nT= length(Ttemp);
    T = [T; Ttemp(2:nT)];
    Q = [Q; Qtemp(2:nT,:)];
    Q0 = Qtemp(nT,:);
    tbegin = Ttemp(nT);
end

plot(T,Q)


% Equations of motion
function dQ = EOMFlight(t,Q,param)
    % tail torque
    % --- COMPLETE THIS SECTION --- %
    tau_t = -param.Kp*(Q(5) + Q(7) - pi) - param.Kv*(Q(6) + Q(8));
    
    % Describe the system equations of motion
    % Reminder: the state Q = [x dx y dy phi1 dphi1 phi2 dphi2]; 
    % state output dQ = [dx ddx dy ddy dphi1 ddphi1 dphi2 ddphi2]
    dQ = zeros(8,1);
    
    % --- COMPLETE THIS SECTION --- %
  M = [param.Ib + param.It, param.It;param.It,param.It];
    phidots = inv(M)*[0;tau_t];
 
    dQ(1) = Q(2);
    dQ(2) = (tau_t/(param.mb*param.lt))*sin(Q(5)+Q(7));
    dQ(3) = Q(4);
    dQ(4) = -param.g - (tau_t/(param.mb*param.lt))*cos(Q(5)+Q(7));
    dQ(5) = Q(6);
    dQ(6) = phidots(1);
    dQ(7) = Q(8);
    dQ(8) = phidots(2); 
end

function dQ = EOMStance(t, Q, param, xfoot)
    % leg angle
    theta = atan2(xfoot-Q(1),Q(3));
    
    % leg length
    r = sqrt((Q(1)-xfoot)^2+Q(3)^2);
    
    % leg angle velocity
    thetadot = (Q(2)*cos(theta)+Q(4)*sin(theta))/r;
    
    % leg length velocity
    rdot = -Q(2)*sin(theta)+Q(4)*cos(theta);
    
    % tail torque
    % --- COMPLETE THIS SECTION --- %
    tau_t = -param.mb*param.lt*r*sqrt(param.k/param.mb)*cos(angle(Q(3) + 1i*Q(4))); 
    
    % hip torque
    % --- COMPLETE THIS SECTION --- %
    tau_h = param.Kp*Q(5) + 2*sqrt(param.Kp)*Q(6); 
    
    % Describe the system equations of motion
    % Reminder: the state Q = [x dx y dy phi1 dphi1 phi2 dphi2]; 
    % state output dQ = [dx ddx dy ddy dphi1 ddphi1 dphi2 ddphi2]
    dQ = zeros(8,1);
    
    % --- COMPLETE THIS SECTION --- %
    lddot = (param.k*(param.r-r)/param.mb)-...
            (param.b*rdot)/param.mb - param.g*cos(theta) + r*thetadot^2 - (tau_t/(param.mb*param.lt))*cos(theta-Q(5));
        
    thetaddot = tau_h/(param.mb*r^2) + param.g*sin(theta)/r - 2*rdot*thetadot/r + ...
                (tau_t/(param.mb*param.lt*r))*sin(theta-Q(5));
    
    M = [param.Ib + param.It, param.It;param.It,param.It];
    phidots =inv(M)*[-tau_h;tau_t];
    
    dQ(1) = Q(2);
    dQ(2) = -lddot*sin(theta) - r*thetaddot*cos(theta) - 2*rdot*thetadot*cos(theta) + r*thetadot^2*sin(theta);
    dQ(3) = Q(4);
    dQ(4) = lddot*cos(theta) - r*thetaddot*sin(theta) - 2*rdot*thetadot*sin(theta) - r*thetadot^2*cos(theta);
    dQ(5) = Q(6);
    dQ(6) = phidots(1);
    dQ(7) = Q(8);
    dQ(8) = phidots(2);
end

% Touchdown Event function
function [value,isterminal,direction] = EventTouchDown(t, Q, param)
    % --- COMPLETE THIS SECTION --- %
    % ---  USE WEEK 11 RESULTS  --- %
    value = Q(3) - param.r*cos(param.thetatd);
    direction = -1;
    isterminal = [1];                            % stop the integration
end

% Liftoff Event function
function [value,isterminal,direction] = EventLiftOff(t, Q, param, xfoot)
    % Leg length
    r = sqrt((Q(1)-xfoot)^2+Q(3)^2);
    
    % --- COMPLETE THIS SECTION --- %
    % ---  USE WEEK 11 RESULTS  --- %
    value = r-param.r;
    direction = 1;
    isterminal = [1];           % stop the integration
end
