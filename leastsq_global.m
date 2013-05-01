classdef leastsq_global < handle
    
    properties 
        % RA given in degrees, all other angles in radians
        
        % some defaults
        x0 = 2128
        y0 = 1416
        ISS_period = 93.0 % minutes
        f = 28.0
        p = 0.00845
        
        % Set by constructor.
        theta_steps = 0;
        d0_steps = 0;
        
        theta_grid = 0;
        d0_grid = 0;
        
        degtorad = pi/180.0;
        
    end
    
    methods 
        
        % ISS_period in minutes.
        function obj = leastsq_global(img_size, ISS_period_in, focal_length)
            
           obj.theta_steps = int16(1.0*10.0^2.0);
           obj.d0_steps = int16(0.5*10.0^2.0);
        
           obj.theta_grid = linspace(0,2.0*pi, obj.theta_steps);
           obj.d0_grid = linspace(-pi/2.0, pi/2.0, obj.d0_steps);
           
           obj.x0 = img_size(1)/2;
           obj.y0 = img_size(2)/2;
           obj.ISS_period = ISS_period_in;
           obj.f = focal_length;
            
        end
        
        function [ RA_x ] = RA_x_calc(obj, x, y, theta, d0)
           RA_x = (180.0*obj.p*(-obj.f*cos(d0)*cos(theta)+obj.p*(y-obj.y0)*sin(d0)))/ ...
                    (pi*(obj.f*cos(d0)+obj.p*sin(d0)*((obj.y0-y)*cos(theta)+(x-obj.x0)*sin(theta)))^2.0* ...
                    (1.+(obj.p^2.0*((x-obj.x0)*cos(theta)+(y-obj.y0)*sin(theta))^2.0)/ ... 
                    (obj.f*cos(d0)+obj.p*sin(d0)*((obj.y0-y)*cos(theta)+(x-obj.x0)*sin(theta)))^2.0));
        end
        
        function [ RA_y ] = RA_y_calc(obj, x, y, theta, d0)
           RA_y = -(180.0*obj.p*(obj.p*(x-obj.x0)*sin(d0)+obj.f*cos(d0)*sin(theta)))/(pi*((obj.f*cos(d0)+obj.p*sin(d0)*((obj.y0-y)*cos(theta)+(x-obj.x0)*sin(theta)))^2)*(1.0+(obj.p^2*((x-obj.x0)*cos(theta)+(y-obj.y0)*sin(theta))^2)/(obj.f*cos(d0)+obj.p*sin(d0)*((obj.y0-y)*cos(theta)+(x-obj.x0)*sin(theta)))^2));
        end
        
        function [ DEC_x ] = DEC_x_calc(obj, x, y, theta, d0)
           DEC_x = -180./pi*((obj.p*(obj.f*obj.p*(x-obj.x0)*sin(d0)+cos(d0)*(obj.p^2.*(x-obj.x0)*(y-obj.y0)*cos(theta)+(obj.f^2.0+obj.p^2.0*(y-obj.y0)^2.0)*sin(theta))))/(obj.f^3.0*(obj.f^-2.0*(obj.f^2.0+obj.p^2.0*(x^2.0-2.0*x*obj.x0+obj.x0^2.+(y-obj.y0)^2.0)))^(3.0/2.0)*(1.-(obj.f*sin(d0)+obj.p*cos(d0)*((y-obj.y0)*cos(theta)+(obj.x0-x)*sin(theta)))^2.0/(obj.f^2.0+obj.p^2.0*(x^2.0-2.0*x*obj.x0+obj.x0^2.0+(y-obj.y0)^2.0)))^0.5)); 
        end
        
        function [ DEC_y ] = DEC_y_calc(obj, x, y, theta, d0)
            DEC_y = 180./pi*((obj.p*(obj.f*obj.p*(obj.y0-y)*sin(d0)+cos(d0)*((obj.f^2.0+obj.p^2.0*(x-obj.x0)^2.0)*cos(theta)+obj.p^2.0*(x-obj.x0)*(y-obj.y0)*sin(theta))))/(obj.f^3.0*(obj.f^-2.0*(obj.f^2.0+obj.p^2.0*(x^2.0-2.0*x*obj.x0+obj.x0^2.0+(y-obj.y0)^2.0)))^(3.0/2.0)*(1.0-(obj.f*sin(d0)+obj.p*cos(d0)*((y-obj.y0)*cos(theta)+(obj.x0-x)*sin(theta)))^2.0/(obj.f^2.0+obj.p^2.0*(x^2.0-2.0*x*obj.x0+obj.x0^2.0+(y-obj.y0)^2.0)))^0.5));
        end
        
        function [ minimal_residual x y residual_sq_vector ] = calc_residuals(obj, data)
            
            residual_sq_vector = zeros(obj.theta_steps, obj.d0_steps);
            
            [data_rows data_cols] = size(data);
            
            x_diff_vector = zeros(data_rows,1);
            y_diff_vector = zeros(data_rows,1);
            x_avg_vector = zeros(data_rows,1);
            y_avg_vector = zeros(data_rows,1);
            
            minimal_residual = [inf, 0, 0];
            
            x = obj.theta_grid./obj.degtorad;
            y = obj.d0_grid./obj.degtorad;
            
            
            for n = 1:data_rows
                x_diff_vector(n) = data(n,3)-data(n,1);
                y_diff_vector(n) = data(n,4)-data(n,2);
                x_avg_vector(n) = (data(n,3)+data(n,1))/2.0;
                y_avg_vector(n) = (data(n,4)+data(n,2))/2.0;
            end
            
            for i = 1:obj.theta_steps
                for j = 1:obj.d0_steps
                    residual_sq_sum = 0.0;
                    
                    for n = 1:data_rows
                        if j == 1 && n == 1
                            display(strcat(num2str(double(i)/(double(obj.theta_steps))*100.0), '% complete'));
                        end
                        RA_x = x_diff_vector(n)*obj.RA_x_calc(x_avg_vector(n), y_avg_vector(n), obj.theta_grid(i), obj.d0_grid(j));
                        RA_y = y_diff_vector(n)*obj.RA_y_calc(x_avg_vector(n), y_avg_vector(n), obj.theta_grid(i), obj.d0_grid(j));
                        DEC_x = x_diff_vector(n)*obj.DEC_x_calc(x_avg_vector(n), y_avg_vector(n), obj.theta_grid(i), obj.d0_grid(j));
                        DEC_y= y_diff_vector(n)*obj.DEC_y_calc(x_avg_vector(n), y_avg_vector(n), obj.theta_grid(i), obj.d0_grid(j));
                        residual_sq_sum = residual_sq_sum + (RA_x+RA_y+360.0/obj.ISS_period)^2.0+(DEC_x+DEC_y)^2.0;
                    end
                    
                    residual_sq_vector(i,j) = residual_sq_sum;
                    
                    if residual_sq_sum < minimal_residual(1)
                       minimal_residual(1) = residual_sq_sum;
                       minimal_residual(2) = obj.theta_grid(i)/obj.degtorad;
                       minimal_residual(3) = obj.d0_grid(j)/obj.degtorad;
                    end
                end
            end
            
            
        end
        
        function t = test(obj, data)
            display(data);
            t = zeros(200,200);
            xvals = linspace(0,4000, 200)         
            yvals = linspace(0,2000, 200)   
            for i = 1:200
                for j = 1:200
                    t(j,i) = obj.RA_y_calc(xvals(i),yvals(j),pi/3, pi/4);
                end
            end
            
        end
    end
    
end

