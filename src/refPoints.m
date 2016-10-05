function xy = refPoints(f)
    
%     figure, imshow(uint8(f)); hold on
%     edgeCI = edge(cI, 'canny');
    edgeF = edge(f, 'canny');
%     [H,theta,rho] = hough(edgecI, 'Theta',[45:0.5:89.5 -90:.5:-44.5]);
    
    % FOR THE TOP THIRD
    [H,theta,rho] = hough(edgeF(1:size(f,1)/3, :), 'Theta',[80:0.5:89.5 -90:.5:-80.5]);
    houghPeaks = houghpeaks(H);
%     t = theta(houghPeaks(:,2)); sign(t).*(90-abs(t))
    lines = houghlines(edgeF(1:size(f,1)/3, :),theta,rho,houghPeaks,'FillGap',5,'MinLength',7);
    minR1 = 0; minC1 = 0; maxR1 = 0; maxC1 = 0;
    figure, imshow(uint8(.5*f)), hold on
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(k==1) minC1 = xy(1,1); minR1 = xy(1,2); end
        if(k==length(lines)) maxC1 = xy(2,1); maxR1 = xy(2,2); end
        plot(xy(:,1),xy(:,2),'LineWidth',4,'Color','green');
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    % FOR THE BOTTOM THIRD
    [H,theta,rho] = hough(edgeF(end-round(size(f,1)/3):end, :), 'Theta',[80:0.5:89.5 -90:.5:-80.5]);
    houghPeaks = houghpeaks(H);
%     t = theta(houghPeaks(:,2)); sign(t)*(90-abs(t))
    lines = houghlines(edgeF(end-round(size(f,1)/3):end, :),theta,rho,houghPeaks,'FillGap',5,'MinLength',7);
    minR2 = 0; minC2 = 0; maxR2 = 0; maxC2 = 0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(k==1) minC2 = xy(1,1); minR2 = round(size(f,1)*2/3)+xy(1,2); end
        if(k==length(lines)) maxC2 = xy(2,1); maxR2 = round(size(f,1)*2/3)+xy(2,2); end
        plot(xy(:,1),round(size(f,1)*2/3)+xy(:,2),'LineWidth',4,'Color','blue');
        plot(xy(1,1),round(size(f,1)*2/3)+xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),round(size(f,1)*2/3)+xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    xy = [minC1 minR1; maxC1 maxR1; minC2 minR2; maxC2 maxR2];
    
    xIn = xy(:,1); yIn = xy(:,2);
    x1 = 1; x2 = 640; x3 = 1; x4 = 640;
    y1 = (yIn(2)-yIn(1))/(xIn(2)-xIn(1))*(1-xIn(1)) + yIn(1);
    y2 = (yIn(2)-yIn(1))/(xIn(2)-xIn(1))*(640-xIn(1)) + yIn(1);
    y3 = (yIn(4)-yIn(3))/(xIn(4)-xIn(3))*(1-xIn(3)) + yIn(3);
    y4 = (yIn(4)-yIn(3))/(xIn(4)-xIn(3))*(640-xIn(3)) + yIn(3);
    xy = [x1 y1; x2 y2; x3 y3; x4 y4];
    
    figure, imshow(uint8(.5*f)), hold on
    plot(xy(1:2,1),xy(1:2,2),'LineWidth',4,'Color','green');
    plot(xy(1,1),xy(1,2),'x','LineWidth',8,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',8,'Color','red');   
    plot(xy(3:4,1),xy(3:4,2),'LineWidth',4,'Color','blue');
    plot(xy(3,1),xy(3,2),'x','LineWidth',8,'Color','yellow');
    plot(xy(4,1),xy(4,2),'x','LineWidth',8,'Color','red');
    hold off, shg
    
end