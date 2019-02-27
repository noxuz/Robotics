function [ik_sol] = cinematica_inversa_PUMA( x, y, z, R )

% Abraham Rodriguez Vazquez
%
% Funcion para calcular la solución directa para el
% brazo robotico PUMA de 6 grados de libertad.

% Inicializacion
ik_sol = ones(1, 6);
    
% Parametros de robot PUMA  
a = 13;
b = 2.5;
c = 8;
d = 2.5;
e = 8;
f = 2.5;
    
z = z-13;
x = x + eps;
   
 % Coordenadas de penultima articulacion   
 Pcx = x - f*R(1,3);
 Pcy = y - f*R(2,3);
 Pcz = z - f*R(3,3);
 
    
% Solución a cinemática inversa 

theta1 = atan2(-Pcx,Pcy) - atan2(sqrt(Pcy^2 + (-Pcx)^2 - 5^2),5);

sintheta3 = - Pcx^2/128 - Pcy^2/128 - Pcz^2/128 + 153/128;;

theta3 = asin(sintheta3);

theta2 = atan2( (Pcz*sin(theta3) - Pcz + Pcx*cos(theta1)*cos(theta3) + Pcy*cos(theta3)*sin(theta1))/(16*(sin(theta3) - 1))...
                ,-(Pcx*cos(theta1) + Pcz*cos(theta3) + Pcy*sin(theta1) - Pcx*cos(theta1)*sin(theta3) - Pcy*sin(theta1)*sin(theta3))/(16*(sin(theta3) - 1)));
        
theta4 = atan2(-1*(R(2,3)*cos(theta1) - R(1,3)*sin(theta1)),...
                -1*(R(3,3)*(cos(theta2)*sin(theta3) + cos(theta3)*sin(theta2)) - R(2,3)*(sin(theta1)*sin(theta2)*sin(theta3) - cos(theta2)*cos(theta3)*sin(theta1)) - R(1,3)*(cos(theta1)*sin(theta2)*sin(theta3) - cos(theta1)*cos(theta2)*cos(theta3))));  
            
theta5 = acos(R(3,3)*(cos(theta2)*cos(theta3) - sin(theta2)*sin(theta3)) - R(2,3)*(cos(theta2)*sin(theta1)*sin(theta3) + cos(theta3)*sin(theta1)*sin(theta2)) - R(1,3)*(cos(theta1)*cos(theta2)*sin(theta3) + cos(theta1)*cos(theta3)*sin(theta2)));  

theta6 = atan2(-1*(R(3,2)*(cos(theta2)*cos(theta3) - sin(theta2)*sin(theta3)) - R(2,2)*(cos(theta2)*sin(theta1)*sin(theta3) + cos(theta3)*sin(theta1)*sin(theta2)) - R(1,2)*(cos(theta1)*cos(theta2)*sin(theta3) + cos(theta1)*cos(theta3)*sin(theta2)))   ...
                ,R(3,1)*(cos(theta2)*cos(theta3) - sin(theta2)*sin(theta3)) - R(2,1)*(cos(theta2)*sin(theta1)*sin(theta3) + cos(theta3)*sin(theta1)*sin(theta2)) - R(1,1)*(cos(theta1)*cos(theta2)*sin(theta3) + cos(theta1)*cos(theta3)*sin(theta2))  );

% Vector de retorno
ik_sol = [theta1 theta2 theta3 theta4 theta5 theta6];
    
   
end
