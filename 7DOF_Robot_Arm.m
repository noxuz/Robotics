n = 7; % DOF

% Inicializacion de coordenadas y parametros del brazo robótico
q = sym('q', [n 1], 'real'); 
d = sym('d', [n 1], 'real'); 
syms a1

q0 = [0 3*pi/2 0 pi 0 pi 3*pi/2];
d0 = [317 192.5 400 168.5 400 136.3 133.75];
a10 = 81;

Ti = cell(n,1); 

% Computar matrices de transformación homogenneas
% según convención Denavit-Hatenberg
T01 = MatrizDH(q(1),d(1),a1,-sym(pi/2));
T12 = MatrizDH(q(2),d(2),0,-sym(pi/2));
T23 = MatrizDH(q(3),d(3),0,-sym(pi/2));
T34 = MatrizDH(q(4),d(4),0,-sym(pi/2));
T45 = MatrizDH(q(5),d(5),0,-sym(pi/2));
T56 = MatrizDH(q(6),d(6),0,-sym(pi/2));
T67 = MatrizDH(q(7),d(7),0,0);


Ti{1} = T01;
Ti{2} = T01 * T12;
Ti{3} = T01 * T12 * T23;
Ti{4} = T01 * T12 * T23 * T34;
Ti{5} = Ti{4} * T45;
Ti{6} = Ti{5} * T56;
Ti{7} = Ti{6} * T67;



function trans = MatrizDH(theta,d,a,alpha)
    Rz = [cos(theta) -sin(theta) 0 0;...
          sin(theta)  cos(theta) 0 0;...
              0           0      1 0;...
              0           0      0 1];
          
    Tz = [1 0 0 0;...
          0 1 0 0;...
          0 0 1 d;...
          0 0 0 1]; 
      
    Tx = [1 0 0 a;...
          0 1 0 0;...
          0 0 1 0;...
          0 0 0 1]; 
      
    Rx = [    1      0           0      0;...
              0  cos(alpha) -sin(alpha) 0;...
              0  sin(alpha) cos(alpha)  0;...
              0      0           0     1];
    
    trans = Rz*Tz*Tx*Rx;
end
