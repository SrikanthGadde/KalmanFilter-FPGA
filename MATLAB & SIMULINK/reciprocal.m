%a.WordLength

function [y_out,m_out] = reciprocal(x)
%x=3;
    x_comp = x*(2^8);
    x_bin = dec2bin(x_comp);
    a = fi(0,true,16,8,'bin',x_bin);
    b = fi(0,true,16,8,'bin','0100000000000000');
    count = 0;
    c = 0;
    while(c==0)
        count = count+1;
        bit = bitand(a,b);
        if (bit == 0)
            b = bitsrl(b,1);
        else
            c = 1;
        end
    end

    m = 8-count;
    if (m < 0)
        m = 0;
    end

    y = 2^(-m);

    err = 1;
    while(err>0.001)
    %Iterative eq
        %disp(y)
        y_k = y*(2-x*y);
        err = abs(y_k - y);
        y = y_k;
    end
    y_out = y;
    m_out = m;
end