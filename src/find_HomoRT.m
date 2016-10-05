function [Iout, R, t] = find_HomoRT(I1, I2)
    
    %% Find 3 points in each image
    if(nargin==0)
        path = imgetfile();
        I1 = imread(path);
    end
    figure, imshow(I1), title('First Image');
    [X1, Y1] = ginput(3);
    
    if(nargin==0)
        path = imgetfile();
        I2 = imread(path);
    end
    imshow(I2), title('Second Image');
    [X2, Y2] = ginput(3);
    
    close
    
    %% Finding Centroids
    Xa = mean(X1); Ya = mean(Y1);
    Xb = mean(X2); Yb = mean(Y2);
    
    %% Finding Optimal Rotation
    H = [X1 - Xa, Y1 - Ya]*[X2 - Xb, Y2 - Yb]';
    [U, ~, V] = svd(H);
    if(det(V)<0) V(:,3)=-V(:,3); end
    R = V*U';
    
    %% Finding Translation
    t = -R*[Xa,Ya,1]' + [Xb,Yb,1]';
    
    %% Result
    Iout = zeros(size(I1));
    for y=1:size(I1,1)
        for x=1:size(I1,2)
            p = round(R*[x,y,1]' + t); X=p(1); Y=p(2);
            if(X>0 && X<size(I1,2) && Y>0 && Y<size(I1,1)) Iout(Y,X,:) = I1(y,x,:); end
        end
    end
    figure, imshow(.3*I2 + .7*uint8(Iout))
    
%     p11out = round(R*[X1(1); Y1(1); 0] + t);
%     X11out = p11out(1); Y11out = p11out(2);
%     p12out = round(R*[X1(2); Y1(2); 0] + t);
%     X12out = p12out(1); Y12out = p12out(2);
%     p13out = round(R*[X1(3); Y1(3); 0] + t);
%     X13out = p13out(1); Y13out = p13out(2);
%     a = I2;
%     a(Y11out-5:Y11out+5, X11out-5:X11out+5, :) = 255;
%     a(Y12out-5:Y12out+5, X12out-5:X12out+5, :) = 255;
%     a(Y13out-5:Y13out+5, X13out-5:X13out+5, :) = 255;
%     figure, imshow(a)
    
end