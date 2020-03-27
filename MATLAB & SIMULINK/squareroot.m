function [y_out] = squareroot(x)

    [x_reciprocal, m] = reciprocal(x);
    
    y = 2^(floor(m/2));
    err = 1;
    while(err>0.01)
        %Iterative eq
         %disp(y)
        y_k = (y*0.5)*(3-((y^2)*x_reciprocal));
        err = abs(y_k - y);
        y = y_k;
    end
    y_out = y;
end
