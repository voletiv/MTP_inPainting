function [C, F] = homoDLT(c, f, xy)
    
    xIn = xy(:,1); yIn = xy(:,2);
    
    xOut = xIn;
    yOut = yIn; yOut(2) = yOut(1); yOut(4) = yOut(3);
    
%     mx=max(xOut(:));
%     my=max(yOut(:));
    mx = 640; my = 480;

    % Computing Homography matrix By using the DLT algorithm
    
    A=zeros(8,8);
    A(1,:)=[xIn(1),yIn(1),1,0,0,0,-1*xIn(1)*xOut(1),-1*yIn(1)*xOut(1)];
    A(2,:)=[0,0,0,xIn(1),yIn(1),1,-1*xIn(1)*yOut(1),-1*yIn(1)*yOut(1)];
    A(3,:)=[xIn(2),yIn(2),1,0,0,0,-1*xIn(2)*xOut(2),-1*yIn(2)*xOut(2)];
    A(4,:)=[0,0,0,xIn(2),yIn(2),1,-1*xIn(2)*yOut(2),-1*yIn(2)*yOut(2)];
    A(5,:)=[xIn(3),yIn(3),1,0,0,0,-1*xIn(3)*xOut(3),-1*yIn(3)*xOut(3)];
    A(6,:)=[0,0,0,xIn(3),yIn(3),1,-1*xIn(3)*yOut(3),-1*yIn(3)*yOut(3)];
    A(7,:)=[xIn(4),yIn(4),1,0,0,0,-1*xIn(4)*xOut(4),-1*yIn(4)*xOut(4)];
    A(8,:)=[0,0,0,xIn(4),yIn(4),1,-1*xIn(4)*yOut(4),-1*yIn(4)*yOut(4)];
    v = [xOut(1);yOut(1);xOut(2);yOut(2);xOut(3);yOut(3);xOut(4);yOut(4)];

    u = A\v;
    U = reshape([u;1],3,3)';
    T = maketform('projective',U');
    
    F = round(imtransform(f,T,'XData',[1 mx],'YData',[1 my]));
    C = round(imtransform(c,T,'XData',[1 mx],'YData',[1 my]));
    
    figure, subplot(221), imshow(uint8(c)), subplot(222), imshow(uint8(f)), subplot(223), imshow(uint8(C)), subplot(224), imshow(uint8(F))
    
end