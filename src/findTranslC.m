function [rowShift, colShift, varT] = findTranslC(cO, fO, cTest, fTest, r, c)
    
    R = size(cO,1); C = size(cO,2);
    cO = double(rgb2gray(uint8(cO))); cTest = double(rgb2gray(uint8(cTest)));
%     cO(fO>0) = 0;
%     cTest(fTest>0) = 255;
    if(nargin==4)
        r = -5:5; c = -5:5;
    end
    varT = 100*ones(length(r), length(c));
    i=0; count=0;
    figure, subplot(121), imshow(uint8(cO)), subplot(122), plot(varT(:));
    for rShift=r
        color = rand(1, 3);
        i = i+1;
        j=0;
        for cShift=c
            j = j+1; count = count+1;
            im = zeros(size(cO));
            if(rShift>=0 && cShift>=0)
                test = cO(rShift+1:end, cShift+1:end) - cTest(1:end-rShift, 1:end-cShift);
                test(fO(rShift+1:end, cShift+1:end)>0 | fTest(1:end-rShift, 1:end-cShift)>0) = [];
                im(rShift+1:end, cShift+1:end) = cTest(1:end-rShift, 1:end-cShift);
            else if(rShift<0 && cShift>=0)
                    test = cO(1:end+rShift, cShift+1:end) - cTest(-rShift+1:end, 1:end-cShift);
                    test(fO(1:end+rShift, cShift+1:end)>0 | fTest(-rShift+1:end, 1:end-cShift)>0) = [];                    
                    im(1:end+rShift, cShift+1:end) = cTest(-rShift+1:end, 1:end-cShift);
                else if(rShift>=0 && cShift<0)
                        test = cO(rShift+1:end, 1:end+cShift) - cTest(1:end-rShift, -cShift+1:end);
                        test(fO(rShift+1:end, 1:end+cShift)>0 | fTest(1:end-rShift, -cShift+1:end)>0) = [];
                        im(rShift+1:end, 1:end+cShift) = cTest(1:end-rShift, -cShift+1:end);
                    else test = cO(1:end+rShift, 1:end+cShift) - cTest(-rShift+1:end, -cShift+1:end);
                        test(fO(1:end+rShift, 1:end+cShift)>0 | fTest(-rShift+1:end, -cShift+1:end)>0) = [];
                        im(1:end+rShift, 1:end+cShift) = cTest(-rShift+1:end, -cShift+1:end);
                    end
                end
            end
            varT(i,j) = var(test(:))/((R-abs(rShift))*(C-abs(cShift)))^4.6; varTT = varT(i,1:j);
            subplot(121), imshow(uint8(.6*im + .4*cO)), text(0,0,sprintf('r=%d c=%d',rShift,cShift),'color','white','fontsize',20)
            subplot(122), plot(varTT, 'color', color),
            pause(.0005)
        end
        hold on
        i/length(r)
    end
    
    [rowShift, colShift] = find(varT==min(min(varT)));
    rowShift = r(rowShift), colShift = c(colShift)
    
    % Shift downwards is positive row shift
    % Shift to the right is positive column shift
    
    %% Check shifts
    
    test = zeros(size(cO));
    if(rowShift>=0 && colShift>=0)
        test(rowShift+1:end, colShift+1:end) = cTest(1:end-rowShift, 1:end-colShift);
    else if(rowShift<0 && colShift>=0)
            test(1:end+rowShift, colShift+1:end) = cTest(-rowShift+1:end, 1:end-colShift);
        else if(rowShift>=0 && colShift<0)
                test(rowShift+1:end, 1:end+colShift) = cTest(1:end-rowShift, -colShift+1:end);
            else test(1:end+rowShift, 1:end+colShift) = cTest(-rowShift+1:end, -colShift+1:end);
            end
        end
    end
    
    figure, imshow(uint8(.7*test + .3*cO))
    
%     figure, surf(varT)
    
end


% Random Sampling & Consensus: ransac