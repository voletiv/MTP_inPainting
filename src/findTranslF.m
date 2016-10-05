function [rShift3, cShift3, corr3] = findTranslF(fO, fTest)
    
    fO = round(fO/255); fTest = round(fTest/255);
    R = size(fO,1); C = size(fO,2);
    i=1; corr3 = zeros(2*round(R/3)+1,2*round(C/3)+1);
%     figure, imshow(uint8(fO));
    for rShift=-round(R/3):round(R/3)
        j=1;
        for cShift=-round(C/3):round(C/3)
            test = zeros(size(fO));
            if(rShift>=0 && cShift>=0)
                test(rShift+1:end, cShift+1:end) = fTest(1:end-rShift, 1:end-cShift);
            else if(rShift<0 && cShift>=0)
                    test(1:end+rShift, cShift+1:end) = fTest(-rShift+1:end, 1:end-cShift);
                else if(rShift>=0 && cShift<0)
                        test(rShift+1:end, 1:end+cShift) = fTest(1:end-rShift, -cShift+1:end);
                    else test(1:end+rShift, 1:end+cShift) = fTest(-rShift+1:end, -cShift+1:end);
                    end
                end
            end
%             imshow(uint8(.3*fO*255 + .7*test*255)), pause(.001)
%             corr1(i,j) = sum(sum(test(round(R/3):round(2*R/3)-1,round(C/3):round(2*C/3)-1).*fO(round(R/3):round(2*R/3)-1,round(C/3):round(2*C/3)-1)));
            corr3(i,j) = sum(sum(test.*fO))*((R-abs(rShift))*(C-abs(cShift)));
%             corr4(i,j) = sum(sum(test.*fO))/log((R-abs(rShift))*(C-abs(cShift)));
            j = j+1;
        end
        i = i+1;
        disp('finding translation from fences');
        (i-1)/(round(2*R/3)+1)
    end
%     figure, subplot(221), plot(corr1), subplot(222), plot(corr2), subplot(223), plot(corr3), subplot(224), plot(corr4)
%     [rShift1, cShift1] = find(corr1==max(max(corr1)));
%     rShift1 - round(R/3) - 1, cShift1 - round(C/3) - 1
    [rShift3, cShift3] = find(corr3==max(max(corr3)));
    rShift3 = rShift3 - round(R/3) - 1
    cShift3 = cShift3 - round(C/3) - 1
%     [rShift4, cShift4] = find(corr4==max(max(corr4)));
%     rShift4 - round(R/3) - 1, cShift4 - round(C/3) - 1

    % Shift downwards is positive row shift
    % Shift to the right is positive column shift
    
    
%     figure, surf(corr3)
%     title('Correlation of C translated by row translations & col translations, and C1', 'fontsize', 18)
%     xlabel('col translations', 'fontsize', 15)
%     ylabel('row translations', 'fontsize', 15)
%     xlim([1 2*round(C/3)+1])
%     ylim([1 2*round(R/3)+1])
%     set(gca, 'XTick', linspace(1, 427, 26), 'XTickLabel', -round(C/3):17:round(C/3))
%     set(gca, 'YTick', linspace(1, 321, 21), 'YTickLabel', -round(R/3):16:round(R/3))
        
end