function [rShift, cShift, corrR, corrC, fTest] = findTranslF_fast(fO, fTest)

    fO = double(fO>0); fTest = double(fTest>0);
    R = size(fO,1); C = size(fO,2);
    
    % ROW SHIFTS
    i=1; corrR = zeros(1, 2*round(R/3)+1);    
    for rShift=-round(R/3):round(R/3)
        i/(round(2*R/3)+1)
        test = zeros(size(fO));
        if(rShift>=0)
                test(rShift+1:end,:) = fTest(1:end-rShift,:);
        else test(1:end+rShift,:) = fTest(-rShift+1:end,:);
        end
        corrR(i) = sum(sum(test.*fO))*((R-abs(rShift))*C);
        i = i+1;
    end
    
    rShift = -round(R/3):round(R/3); rShift = rShift(corrR==max(corrR));
    if(rShift>=0)
        fTest(rShift+1:end,:) = fTest(1:end-rShift,:);
    else fTest(1:end+rShift,:) = fTest(-rShift+1:end,:);
    end
    
    % COLUMN SHIFTS
%     figure, imshow(uint8(255*(.3*fO + .7*fTest)))
    i=1; corrC = zeros(1, 2*round(C/3)+1);
    for cShift=-round(C/3):round(C/3)
        i/(round(2*C/3)+1)
        test = zeros(size(fO));
        if(cShift>=0)
                test(1:end-100,cShift+1:end) = fTest(1:end-100,1:end-cShift);
        else test(1:end-100,1:end+cShift) = fTest(1:end-100,-cShift+1:end);
        end
        corrC(i) = sum(sum(test.*fO))*((R-abs(rShift))*(C-abs(cShift)));
%         subplot(121), imshow(uint8(255*(.3*fO + .7*test))), pause(.0001)
%         subplot(122), plot(corrC)
        i = i+1;
    end
    
    cShift = -round(C/3):round(C/3); cShift = cShift(corrC==max(corrC));
    if(cShift>=0)
        fTest(:,cShift+1:end) = fTest(:,1:end-cShift);
    else fTest(:,1:end+cShift) = fTest(:,-cShift+1:end);
    end
    
    clearvars -except R C corrR corrC rShift cShift
    r = -round(R/3):round(R/3); c = -round(C/3):round(C/3);
    figure, subplot(121), plot(corrR, 'color', 'k', 'linewidth', 2), title('Row translations', 'fontsize', 18), hold on, plot(find(corrR==max(corrR),1), max(corrR), '*', 'color', 'k', 'markerSize', 20),...
    xlim([1 2*round(R/3)+1]), set(gca, 'XTick', linspace(1, 2*round(R/3)+1, round((r(end)-r(1))/20+1)), 'XTickLabel', r(1):20:r(end)), ylabel('Correlation'),...
    subplot(122), plot(corrC, 'color', 'k', 'linewidth', 2), title('Column translations', 'fontsize', 18), hold on, plot(find(corrC==max(corrC),1), max(corrC), '*', 'color', 'k', 'markerSize', 20),...
    xlim([1 2*round(C/3)+1]), set(gca, 'XTick', linspace(1, 2*round(C/3)+1, round((c(end)-c(1))/20+1)), 'XTickLabel', c(1):20:c(end)), ylabel('Correlation')
%     figure, imshow(uint8(255*(.3*fO + .7*fTest)))

    rShift, cShift
    
end
