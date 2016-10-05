function [rShift, cShift, varT] = findTranslCol(cO, fO, cTest, fTest)
    
    cO(fO>0) = 0; cTest(fTest>0) = 255;
    R = size(cO,1); C = size(cO,2);
    varT = zeros(41, 101);
    i=0;
%     figure, subplot(121), imshow(uint8(cO)), subplot(122), plot(varT(:)); count=0;
    for rShift=-20:20
        i = i+1;
        j=0;
        for cShift=-50:50
            j = j+1;
            test1 = zeros(size(cO));
            if(rShift>=0 && cShift>=0)
                test1 = cO(rShift+1:end, cShift+1:end) - cTest(1:end-rShift, 1:end-cShift);
%                 im(rShift+1:end, cShift+1:end) = cTest(1:end-rShift, 1:end-cShift); subplot(121), imshow(uint8(.6*im + .4*cO));
            else if(rShift<0 && cShift>=0)
                    test1 = cO(1:end+rShift, cShift+1:end) - cTest(-rShift+1:end, 1:end-cShift);
%                     im(1:end+rShift, cShift+1:end) = cTest(-rShift+1:end, 1:end-cShift); subplot(121), imshow(uint8(.6*im + .4*cO));
                else if(rShift>=0 && cShift<0)
                        test1 = cO(rShift+1:end, 1:end+cShift) - cTest(1:end-rShift, -cShift+1:end);
%                         im(rShift+1:end, 1:end+cShift) = cTest(1:end-rShift, -cShift+1:end); subplot(121), imshow(uint8(.6*im + .4*cO));
                    else test1 = cO(1:end+rShift, 1:end+cShift) - cTest(-rShift+1:end, -cShift+1:end);
%                         im(1:end+rShift, 1:end+cShift) = cTest(-rShift+1:end, -cShift+1:end); subplot(121), imshow(uint8(.6*im + .4*cO));
                    end
                end
            end
            test1 = test1(:);
            varT(i,j) = test1'*test1/((R-abs(rShift))*(C-abs(cShift)))^4.6;
%             subplot(122), plot(varTT), pause(.0001)
        end
        i/41
    end
    
    [rShift, cShift] = find(varT==min(min(varT)));
    rShift = rShift - 21, cShift = cShift - 51
    
    % Shift downwards is positive row shift
    % Shift to the right is positive column shift
    
    %% Check shifts
    
    test1 = zeros(size(cO));
    if(rShift>=0 && cShift>=0)
        test1(rShift+1:end, cShift+1:end) = cTest(1:end-rShift, 1:end-cShift);
    else if(rShift<0 && cShift>=0)
            test1(1:end+rShift, cShift+1:end) = cTest(-rShift+1:end, 1:end-cShift);
        else if(rShift>=0 && cShift<0)
                test1(rShift+1:end, 1:end+cShift) = cTest(1:end-rShift, -cShift+1:end);
            else test1(1:end+rShift, 1:end+cShift) = cTest(-rShift+1:end, -cShift+1:end);
            end
        end
    end
    
    figure, imshow(uint8(.5*test1 + .5*cO))
    
%     figure, surf(varT)
    
end