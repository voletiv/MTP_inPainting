function [rowShift, colShift, corrR, corrC, cTest] = findTranslC_fast(cO, fO, cTest, fTest)
    
    cO = double(rgb2gray(cO)); cTest = double(rgb2gray(cTest));
    fO = round(double(fO)); fTest = round(double(fTest));
    R = size(cO,1); C = size(cO,2);
    fig1 = figure('name', 'nfdifnk');
    
    % ROW SHIFTS
    i=1; corrR = zeros(1, 2*round(R/3)+1);
    rShift=-round(R/3):round(R/3);
    for r = rShift
        i/(round(2*R/3)+1)
        test = zeros(size(cO));
        if(r>=0)
                test(r+1:end,:) = cTest(1:end-r,:);
                corrR(i) = sum(sum((cO(r+1:end,:) - cTest(1:end-r,:)).^2))/((R-abs(r))*C) + (sum(sum(fO(r+1:end,:).*fTest(1:end-r,:)))/(sum(sum(fO))+sum(sum(fTest))))^1.5;
        else
            test(1:end+r,:) = cTest(-r+1:end,:);
            corrR(i) = sum(sum((cO(1:end+r,:) - cTest(-r+1:end,:)).^2))/((R-abs(r))*C) + (sum(sum(fO(1:end+r,:).*fTest(-r+1:end,:)))/(sum(sum(fO))+sum(sum(fTest))))^1.5;
        end
%         size(sum(sum((((test>0).*cO)-test).^2)))
%         corrR(i) = sum(sum(((double(test>0).*cO)-test).^2))/((R-abs(r))*C);
        figure(fig1), imshow(uint8(.5*test + .5*cO)), text(0,0,sprintf('r=%f',r),'color','white','fontsize',20);
        i = i+1;
    end
    
%     corrRs = findpeaks(-corrR);
    rowShift = rShift(corrR==min(corrR));
    if(rowShift>=0)
        cTest(rowShift+1:end,:) = cTest(1:end-rowShift,:);
    else cTest(1:end+rowShift,:) = cTest(-rowShift+1:end,:);
    end
    
    % COLUMN SHIFTS
%     figure, imshow(uint8(255*(.3*fO + .7*fTest)))
    i=1; corrC = zeros(1, 2*round(C/3)+1);
    cShift=-round(C/3):round(C/3);
    for c = cShift
        i/(round(2*C/3)+1)
        test = zeros(size(cO));
        if(c>=0)
%                 test(1:end-100,c+1:end) = cTest(1:end-100,1:end-c);
                corrC(i) = sum(sum((cO(1:end-100,c+1:end) - cTest(1:end-100,1:end-c)).^2))/(R-abs(rowShift))*(C-abs(c));
        else
%             test(1:end-100,1:end+c) = cTest(1:end-100,-c+1:end);
            corrC(i) = sum(sum((cO(1:end-100,1:end+c) - cTest(1:end-100,-c+1:end)).^2))/(R-abs(rowShift))*(C-abs(c));
        end
%         corrC(i) =
%         sum(sum(((test>0).*cO-test).^2))/((R-abs(rShift))*(C-abs(c)));
%         subplot(121), imshow(uint8(255*(.3*fO + .7*test))), pause(.0001)
%         subplot(122), plot(corrC) 
        i = i+1;
    end
    
    colShift = cShift(corrC==min(corrC));
    if(colShift>=0)
        cTest(:,colShift+1:end) = cTest(:,1:end-colShift);
    else cTest(:,1:end+colShift) = cTest(:,-colShift+1:end);
    end
    
    figure, imshow(uint8(.4*cO + .6*cTest))
    figure, subplot(121), plot(rShift, corrR, 'color', 'k', 'linewidth', 2), title('Row translations', 'fontsize', 18), hold on, plot(rowShift, min(corrR), '*', 'color', 'k', 'markerSize', 20),...
%     xlim([1 2*round(R/3)+1]), set(gca, 'XTick', linspace(1, 2*round(R/3)+1, round((r(end)-r(1))/20+1)), 'XTickLabel', r(1):20:r(end)), ylabel('Correlation'),...
    subplot(122), plot(cShift, corrC, 'color', 'k', 'linewidth', 2), title('Column translations', 'fontsize', 18), hold on, plot(colShift, min(corrC), '*', 'color', 'k', 'markerSize', 20),...
%     xlim([1 2*round(C/3)+1]), set(gca, 'XTick', linspace(1, 2*round(C/3)+1, round((c(end)-c(1))/20+1)), 'XTickLabel', c(1):20:c(end)), ylabel('Correlation')
    
    clearvars -except rowShift colShift corrR corrC cTest

    rowShift, colShift
    
end