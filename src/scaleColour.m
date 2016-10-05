function [test, cI] = scaleColour(cI, f)

    %% SCALING cI ACC TO f
    % cI could be colour in uint8 or double
    % f is binary
    % cI = c2; f = f2;
    % figure, imshow(.5*cI);
    
    if(size(cI,3)==3)
        cI = round((double(cI(:,:,1)) + 2*double(cI(:,:,2)) + double(cI(:,:,3)))/4);
    end
    if(max(max(f))==255) f = f==255; end
    
    testRange = 0.9:.001:1.1;
    
    % Scaling in proportion
    i=1; clear r cR test corrI a
    1
    for r=testRange
        if(r*size(cI,1)>size(f,1)) break; end
        cR = round(imresize(cI, r));
        test = zeros(size(f));
        test(end-size(cR,1)+1:end, end-size(cR,2)+1:end) = cR;
    %     imshow(uint8(.5*double(f) + .5*(test)));
    %     pause(.01);
        test = test(:).*double(f(:));
        corrI(i) = var(test)/(sum(sum(test)));
        i = i+1;
    end

    i = find(corrI==min(corrI));
    r = .9:.001:1; r = mean(r(i));
    cI = round(imresize(cI, r));

    % Scaling horizontally
    i=1; clear corrI
    2
    for r=testRange
        if (r*size(cI,2)>size(f,2)) break; end
        cR = round(imresize(cI,[size(cI,1) round(r*size(cI,2))]));
        test = zeros(size(f));
        test(end-size(cR,1)+1:end, end-size(cR,2)+1:end) = cR;
    %     imshow(uint8(.5*double(f) + .5*(test)));
    %     pause(.01);
        test = test(:).*double(f(:));
        corrI(i) = var(test)/(sum(sum(test)))*255;
        i = i+1;
    end

    i = find(corrI==min(corrI));
    r = .9:.001:1.1; r = mean(r(i));
    cI = round(imresize(cI,[size(cI,1) round(r*size(cI,2))]));

    % Scaling vertically
    i=1; clear corrI
    3
    for r=testRange
        if (r*size(cI,1)>size(f,1)) break; end
        cR = round(imresize(cI,[round(r*size(cI,1)) size(cI,2)]));
        test = zeros(size(f));
        test(end-size(cR,1)+1:end, end-size(cR,2)+1:end) = cR;
    %     imshow(uint8(.5*double(f) + .5*(test)));
    %     pause(.01);
        test = test(:).*double(f(:));
        corrI(i) = var(test)/(sum(sum(test)))*255;
        i = i+1;
    end

    i = find(corrI==min(corrI));
    r = .9:.001:1.1; r = mean(r(i));
    cI = imresize(cI,[round(r*size(cI,1)) size(cI,2)]);

    test = zeros(size(f));
    test(end-size(cI,1)+1:end, end-size(cI,2)+1:end) = cI;
    fenceOnColour = test.*double(f);
    figure, imshow(uint8(.7*fenceOnColour + .3*test))
    
    %{
    test = scaleColour(c4, f4);
    onlyFence = round(test.*double(imdilate(f, ones(13))));
    fenceEdge = edge(onlyFence, 'canny', .4);
    fenceEdge = fenceEdge.*double(imdilate(f, ones(7)));
    figure, imshow(fenceEdge), shg
    %}
    
end