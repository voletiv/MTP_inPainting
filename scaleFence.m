function [f, corrI1, corrI2, corrI3, corrI4, corrI5] = scaleFence(cI, f)

    %% SCALING cI ACC TO f
    % cI could be colour in uint8 or double
    % f is can be binary, uint8 or double of binary values: 0 & 1
    % cI = c2; f = f2;
    % figure, imshow(.5*cI);
    f = double(f); if(max(max(f))==1) f = 255*f; end
    if(size(cI,3)==3)
        cI = double(rgb2gray(uint8(cI)));
    end
%     if(max(max(f))==255) f = double(f==255); end
%     f = round(imfilter(double(f), ones(11))/121*255); f = imerode(f, ones(3));
%     figure, imshow(uint8(f))
    % Now f: 0-255
    
    %% Scaling in proportion
    i=0; clear r fR corr corrI
    1
    fig1 = figure('name', 'image+fence, var plot'), subplot(121), imshow(uint8(.5*cI)), title('Scaling in proportion', 'fontsize', 20)
%     pos = get(gcf, 'position'); pos(1) = 0; set(gcf, 'position', pos);
%     figP = figure('name', 'plot'), pos = get(gcf, 'position'); pos(1) = screensize(3)*2/3; set(gcf, 'position', pos);
    rValues = .9:.001:1;
    for r=rValues
        i = i+1;
        fR = round(imresize(f, r));
        fR(fR<0)=0; fR(fR>255) = 255;
        test = zeros(size(cI));
        if(r>1) test = fR(end-size(cI,1)+1:end, 1:size(cI,2));
        else test(end-size(fR,1)+1:end, 1:size(fR,2)) = fR; end
        corrI(i) = var(test(:).*cI(:));
        subplot(121), imshow(uint8(.5*cI + .5*test)), title('Scaling in proportion', 'fontsize', 20)
        text(0,0,sprintf('r=%f',r),'color','white','fontsize',20)
        subplot(122), plot(corrI), xlabel('r'), ylabel('variance', 'fontsize', 16), xLim = get(gca, 'xlim');
%         if(r<1.08)
%             set(gca, 'XTick', linspace(1, xLim(2), round((rValues(xLim(2))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
%         else set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end))
%         end
        set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
        hold on, plot(find(corrI==min(corrI),1), min(corrI), '*', 'color', 'k', 'markerSize', 12), hold off
        pause(.0001);
    end
    corrI1 = corrI;
    
    r = mean(rValues(corrI==min(corrI)));
    f = round(imresize(f, r));
    f(f<0)=0; f(f>255) = 255;
    if(r>1) f = f(end-size(cI,1)+1:end, 1:size(cI,2));
    else test = zeros(size(cI)); test(end-size(f,1)+1:end, 1:size(f,2)) = f; f = test; end
    test = zeros(size(cI));
    if(r>1) test = f(end-size(test,1)+1:end, 1:size(test,2));
    else test(end-size(f,1)+1:end, 1:size(f,2)) = f; end
    f = test;

    %% Scaling horizontally rightwards
    i=0; clear corr corrI
    subplot(121), title('Scaling horizontally rightwards', 'fontsize', 20)
    2
    rValues = .95:.001:1.05;
    for r=rValues
        i = i+1;
        fR = round(imresize(f,[size(f,1) round(r*size(f,2))]));
        fR(fR<0)=0; fR(fR>255) = 255;
        test = zeros(size(cI));
        if(r>1) test = fR(:, 1:size(cI,2));
        else test(:, 1:size(fR,2)) = fR; end
        corrI(i) = var(test(:).*cI(:));
        subplot(121), imshow(uint8(.5*cI + .5*test)), title('Scaling horizontally rightwards', 'fontsize', 20)
        text(0,0,sprintf('r=%f',r),'color','white','fontsize',20)
        subplot(122), plot(corrI), xlabel('r'), ylabel('variance', 'fontsize', 16), xLim = get(gca, 'xlim');
        set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
        hold on, plot(find(corrI==min(corrI),1), min(corrI), '*', 'color', 'k', 'markerSize', 12), hold off
        pause(.0001);
    end
    corrI4 = corrI;

    r = mean(rValues(corrI==min(corrI)));
    f = round(imresize(f,[size(f,1) round(r*size(f,2))]));
    f(f<0)=0; f(f>255) = 255;
    test = zeros(size(cI));
    if(r>1) test = f(:, 1:size(cI,2));
    else test(:, 1:size(f,2)) = f; end
    f = test;
    
    %% Scaling vertically upwards
    i=0; clear corr corrI
    subplot(121), title('Scaling vertically upwards', 'fontsize', 20)
    3
    rValues = .95:.001:1.05;
    for r=rValues
        i = i+1;
        fR = round(imresize(f,[round(r*size(f,1)) size(f,2)]));
        fR(fR<0)=0; fR(fR>255) = 255;
        test = zeros(size(cI));
        if(r>1) test = fR(end-size(cI,1)+1:end, :);
        else test(end-size(fR,1)+1:end, :) = fR; end
        corrI(i) = var(test(:).*cI(:));
        subplot(121), imshow(uint8(.5*cI + .5*test)), title('Scaling vertically upwards', 'fontsize', 20)
        text(0,0,sprintf('r=%f',r),'color','white','fontsize',20)
        subplot(122), plot(corrI), xlabel('r'), ylabel('variance', 'fontsize', 16), xLim = get(gca, 'xlim');
        set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
        hold on, plot(find(corrI==min(corrI),1), min(corrI), '*', 'color', 'k', 'markerSize', 12), hold off
        pause(.0001);
    end
    corrI3 = corrI;

    r = mean(rValues(corrI==min(corrI)));
    f = imresize(f,[round(r*size(f,1)) size(f,2)]);
    f(f<0)=0; f(f>255) = 255;
    test = zeros(size(cI));
    if(r>1) test = f(end-size(cI,1)+1:end, :);
    else test(end-size(f,1)+1:end, :) = f; end
    f = test;
    
    %% Scaling horizontally leftwards
    i=0; clear corr corrI
    subplot(121), title('Scaling horizontally leftwards', 'fontsize', 20)
    4
    rValues = 0.95:.001:1.05;
    for r=rValues
        i = i+1;
        fR = round(imresize(f,[size(f,1) round(r*size(f,2))]));
        fR(fR<0)=0; fR(fR>255) = 255;
        test = zeros(size(cI));
        if(r>1) test = fR(:, end-size(cI,2)+1:end);
        else test(:, end-size(fR,2)+1:end) = fR; end
        corrI(i) = var(test(:).*cI(:));
        subplot(121), imshow(uint8(.5*cI + .5*test)), title('Scaling horizontally leftwards', 'fontsize', 20)
        text(0,0,sprintf('r=%f',r),'color','white','fontsize',20)
        figure(fig1), subplot(122), plot(corrI), xlabel('r'), ylabel('variance', 'fontsize', 16), xLim = get(gca, 'xlim');
        set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
        hold on, plot(find(corrI==min(corrI),1), min(corrI), '*', 'color', 'k', 'markerSize', 12), hold off
        pause(.0001);
    end
    corrI2 = corrI;

    r = mean(rValues(corrI==min(corrI)));
    f = round(imresize(f,[size(f,1) round(r*size(f,2))]));
    f(f<0)=0; f(f>255) = 255;
    test = zeros(size(cI));
    if(r>1) test = f(:, end-size(cI,2)+1:end);
    else test(:, end-size(f,2)+1:end) = f; end
    f = test;
    
    %% Scaling vertically downwards
    i=0; clear corr corrI
    subplot(121), title('Scaling vertically downwards','fontsize', 20)
    5
    rValues = .95:.001:1.05;
    for r=rValues
        i = i+1;
        fR = round(imresize(f,[round(r*size(f,1)) size(f,2)]));
        fR(fR<0)=0; fR(fR>255) = 255;
        test = zeros(size(cI));
        if(r>1) test = fR(1:size(cI,1), :);
        else test(1:size(fR,1), :) = fR; end
        corrI(i) = var(test(:).*cI(:));
        subplot(121), imshow(uint8(.5*cI + .5*test)), title('Scaling vertically downwards','fontsize', 20)
        text(0,0,sprintf('r=%f',r),'color','white','fontsize',20)
        subplot(122), plot(corrI), xlabel('r'), ylabel('variance', 'fontsize', 16), xLim = get(gca, 'xlim');
%         if(r<1.08)
%             set(gca, 'XTick', linspace(1, xLim(2), round((rValues(xLim(2))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
%         else set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end))
%         end
        set(gca, 'XTick', linspace(1, xLim(2), round((rValues(min(xLim(2),end))-rValues(1))/.01+1)), 'XTickLabel', rValues(1):.01:rValues(end))
        hold on, plot(find(corrI==min(corrI),1), min(corrI), '*', 'color', 'k', 'markerSize', 12), hold off
        pause(.0001);
    end
    corrI5 = corrI;
%     close
    
    r = mean(rValues(corrI==min(corrI)));
    f = imresize(f,[round(r*size(f,1)) size(f,2)]);
    f(f<0)=0; f(f>255) = 255;
    test = zeros(size(cI));
    if(r>1) test = f(1:size(cI,1), :);
    else test(1:size(f,1), :) = f; end
    f = test;
    
    f = imerode(f, ones(3));
    f(f<128) = 0;
    f(f>127) = 255;    
    
    %% Final result 
    fenceOnColour = round(cI.*f/255);
    figure, imshow(uint8(.7*fenceOnColour + .3*cI))
    title('Highlighting Depth Image Fence in Colour Image')
    
    figure, suptitle({'Scaling Depth Image to match Colour Image';'';''}), ...
        subplot(231), plot(corrI1, 'color', 'k', 'lineWidth', 2), hold on, plot(find(corrI1==min(corrI1),1), min(corrI1), '*', 'color', 'k', 'markerSize', 12), xlabel('r'), ylabel('variance'), ...
        title('Scaling in proportion'), xlim([1 201]), set(gca, 'XTick', linspace(1, 201, round((rValues(end)-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end)), ...
        subplot(232), plot(corrI2, 'color', 'k', 'lineWidth', 2), hold on, plot(find(corrI2==min(corrI2),1), min(corrI2), '*', 'color', 'k', 'markerSize', 12), xlabel('r'), ylabel('variance'), ...
        title('Scaling horizontally leftwards'), xlim([1 201]), set(gca, 'XTick', linspace(1, 201, round((rValues(end)-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end)), ...
        subplot(233), plot(corrI3, 'color', 'k', 'lineWidth', 2), hold on, plot(find(corrI3==min(corrI3),1), min(corrI3), '*', 'color', 'k', 'markerSize', 12), xlabel('r'), ylabel('variance'), ...
        title('Scaling vertically upwards'), xlim([1 201]), set(gca, 'XTick', linspace(1, 201, round((rValues(end)-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end)), ...
        subplot(234), plot(corrI4, 'color', 'k', 'lineWidth', 2), hold on, plot(find(corrI4==min(corrI4),1), min(corrI4), '*', 'color', 'k', 'markerSize', 12), xlabel('r'), ylabel('variance'), ...
        title('Scaling horizontally rightwards'), xlim([1 201]), set(gca, 'XTick', linspace(1, 201, round((rValues(end)-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end)), ...
        subplot(235), plot(corrI5, 'color', 'k', 'lineWidth', 2), hold on, plot(find(corrI5==min(corrI5),1), min(corrI5), '*', 'color', 'k', 'markerSize', 12), xlabel('r'), ylabel('variance'), ...
        title('Scaling vertically downwards'), xlim([1 201]), set(gca, 'XTick', linspace(1, 201, round((rValues(end)-rValues(1))/.02+1)), 'XTickLabel', rValues(1):.02:rValues(end))
       
end