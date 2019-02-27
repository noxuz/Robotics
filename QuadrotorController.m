function [f,M] = ControladorQuad(m,J,s,traj,t)


    % Cosechar valores de vector s de estado
    r = [s(1);s(2);s(3)]; % Posicion del quadrotor en el world frame
    v = [s(4);s(5);s(6)]; % Velocidad del quadrotor en el world frame
    R = [s(7) s(8) s(9);...
         s(10) s(11) s(12);...
         s(13) s(14) s(15)]'; % Matriz de rotacion desde el cuerpo del quadrotor al world frame
    omega = [s(16);s(17);s(18)]; % Velocidad angular del quadrotor en el body frame

    
    % Inicialización
    posicion = [1 t t^2 t^3 t^4 t^5 t^6 t^7];
    velocidad = [ 0, 1, 2*t, 3*t^2, 4*t^3, 5*t^4, 6*t^5, 7*t^6];
    aceleracion = [ 0, 0, 2, 6*t, 12*t^2, 20*t^3, 30*t^4, 42*t^5];
    b3 = [0;0;1];
    g = 9.81;
    
       % Ganancias a tunear
    kv1 = 35;
    kv2 = 35;
    kv3 = 25;
    kv = [kv1 0 0;0 kv2 0;0 0 kv3];
   
    kp1 = 10;
    kp2 = 115;
    kp3 = 220;
    kp = [kp1 0 0;0 kp2 0;0 0 kp3];

    k_R1 = 800;
    k_R2 = 700;
    k_R3 = 400;
    k_R = [k_R1 0 0;0 k_R2 0;0 0 k_R3];
    
    k_Omega1 = 40;
    k_Omega2 = 40;
    k_Omega3 = 250;
    k_Omega = [k_Omega1 0 0;0 k_Omega2 0;0 0 k_Omega3];

    % Cosechar con la matriz de traj los vectores r_des y rd_des y rdd_des
    
    r_des = [posicion * traj(:,1);...
             posicion * traj(:,2);...
             posicion * traj(:,3)];
         
    rd_des = [velocidad * traj(:,1);...
              velocidad * traj(:,2);...
              velocidad * traj(:,3)];
         
    rdd_des = [aceleracion * traj(:,1);...
               aceleracion * traj(:,2);...
               aceleracion * traj(:,3)];
    
    yaw_des = posicion*traj(:,4);
    yawd_des = velocidad*traj(:,4);
    
    % Calcular el vector trust t para el inner loop de orientacion
    trust = m*(rdd_des + kv*(rd_des-v) + kp*(r_des-r) + g*b3);
    
    u1 = dot(trust,R*b3);
    
    % Obtener R_Des
    z_b = trust/norm(trust);
    x_c = [cos(yaw_des);sin(yaw_des);0];
    y_b = cross(z_b,x_c)/norm(cross(z_b,x_c));
    x_b = cross(y_b,z_b);
    
    R_des = [x_b y_b z_b];
    
    % Calculo del error
    e_Rm = 1/2*(R_des'*R - R'*R_des);
    % Cosecha del error por skew symetry
    e_R = [e_Rm(3,2);e_Rm(1,3);e_Rm(2,1)];
    e_Omega = omega - yawd_des*b3 ;
    
    u2 = cross(omega,J*omega) + J*(-k_R*e_R - k_Omega*e_Omega);
    
    % Cómputo final

    f = [0;0;-m*g] + R*b3*u1;
    f = f(3);
    M = u2 - cross(omega,J*omega);
end
