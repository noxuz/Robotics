function x_dot = wheeled_control(t, state_vec) 
    
    % sprayer offset
    l = 0.1;
    
    % the position and orientation of the robot
    x = state_vec(1);
    y = state_vec(2);
    theta = state_vec(3);
     
    % Salida actual
    ye = [x + l*cos(theta);...
          y + l*sin(theta)];
    
    % Salida deseada
    ydes = [10*cos(pi*t/5) + 5*sin(pi*t/10);...
            10*sin(pi*t/10) - 5*cos(pi*t/10) + 5];
    
    % Derivada de la salida deseada    
    ydotdes = [-2*pi*sin(pi*t/5) + (pi/2)*cos(pi*t/10);...
               pi*cos(pi*t/10) + (pi/2)*sin(pi*t/10)];  
    
    % Ganancia proporcional
    k = 10;
    
    % Lgh desde matlab
    lgh = [cos(theta) -l*sin(theta);...
           sin(theta) l*cos(theta)];
    
    
   % Input linealizada
   u = inv(lgh)*(ydotdes + k*(ydes-ye));
   
   ge = [cos(theta) 0;...
            sin(theta) 0;...
            0          1];
   
   x_dot = ge*u;
          
    
               
end
