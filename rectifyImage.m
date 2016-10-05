function xy = rectifyImage(f)
    
%     edgeCI = edge(cI, 'canny');
    edgeF = edge(f, 'canny');
%     [H,theta,rho] = hough(edgecI, 'Theta',[45:0.5:89.5 -90:.5:-44.5]);
    
    [H,theta,rho] = hough(edgeF(1:size(f,1)/5, :), 'Theta',[80:0.5:89.5 -90:.5:-80.5]);
    houghPeaks = houghpeaks(H);
%     t = theta(houghPeaks(:,2)); sign(t).*(90-abs(t))
    lines = houghlines(edgeF,theta,rho,houghPeaks,'FillGap',5,'MinLength',7);
    minR1 = 0; minC1 = 0; maxR1 = 0; maxC1 = 0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(k==1) minC1 = xy(1,1); minR1 = xy(1,2); end
        if(k==length(lines)) maxC1 = xy(2,1); maxR1 = xy(2,2); end
%         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
%         plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    [H,theta,rho] = hough(edgeF(end-round(size(f,1)/3):end, :), 'Theta',[80:0.5:89.5 -90:.5:-80.5]);
    houghPeaks = houghpeaks(H);
%     t = theta(houghPeaks(:,2)); sign(t)*(90-abs(t))
    lines = houghlines(edgeF(end-round(size(f,1)/3):end, :),theta,rho,houghPeaks,'FillGap',5,'MinLength',7);
    minR2 = 0; minC2 = 0; maxR2 = 0; maxC2 = 0;
    for k=1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
        if(k==1) minC2 = xy(1,1); minR2 = round(size(f,1)*2/3)+xy(1,2); end
        if(k==length(lines)) maxC2 = xy(2,1); maxR2 = round(size(f,1)*2/3)+xy(2,2); end
%         plot(xy(:,1),round(size(f,1)*2/3)+xy(:,2),'LineWidth',2,'Color','blue');
%         plot(xy(1,1),round(size(f,1)*2/3)+xy(1,2),'x','LineWidth',2,'Color','yellow');
%         plot(xy(2,1),round(size(f,1)*2/3)+xy(2,2),'x','LineWidth',2,'Color','red');
    end
    
    xy = [minC1 minR1; maxC1 maxR1; minC2 minR2; maxC2 maxR2];
    
%     figure, imshow(f), hold on
%     plot(xy(1:2,1),xy(1:2,2),'LineWidth',2,'Color','green');
%     plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%     plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');   
%     plot(xy(3:4,1),xy(3:4,2),'LineWidth',2,'Color','blue');
%     plot(xy(3,1),xy(3,2),'x','LineWidth',2,'Color','yellow');
%     plot(xy(4,1),xy(4,2),'x','LineWidth',2,'Color','red');
%     hold off, shg
    
end