function [image defenced_img] = LBP2_ed4(row_shifts,col_shifts,Y_Obs,fence,T,no_obs)
    % Implementing Loopy Belief Proapagation for image defencing
    % using multiple shifted frames where fence is static
    % and background moves with global motion.
    
    % Y_Obs = n x rows x cols uint8
    % fence = n x rows x cols logical
    
    % Shift downwards is positive row shift
    % Shift to the right is positive column shift
    
    % fence image: 1==Background, 0==Fence!!!!
    
    tic
    if(nargin<5) T = 2; end %No. of iterations
    if(nargin<6) no_obs = 4; end %No. of observations

    lambda_im_bg = 0.05; %This is good smoothness parameter -->% 0.0005;
    vec = 0:5:255;
    
    [rows, cols]= size(squeeze(Y_Obs(1,:,:)));

%     Y_Obs=double(Y_Obs);

    defenced_img = zeros(rows,cols);
    init_mesgs_p1 = zeros(T,rows,cols,size((vec),2)); % Intitalizing all messages to be zero vectors of length 256.
    init_mesgs_p2 = zeros(T,rows,cols,size((vec),2)); % Intitalizing all messages to be zero vectors of length 256.
    init_mesgs_p3 = zeros(T,rows,cols,size((vec),2)); % Intitalizing all messages to be zero vectors of length 256.
    init_mesgs_p4 = zeros(T,rows,cols,size((vec),2)); % Intitalizing all messages to be zero vectors of length 256.
    belief = zeros(rows,cols,size((vec),2));

    temp_var1 = zeros(rows,cols,size((vec),2));
    temp_var2 = zeros(rows,cols,size((vec),2));
    temp_var3 = zeros(rows,cols,size((vec),2));
    temp_var4 = zeros(rows,cols,size((vec),2));


    % Shifting images and fences to Y_Obs(1,:,:)'s position
    for i = 1:no_obs-1
        temp_img = squeeze(Y_Obs(i+1,:,:));
        temp1 = func_motion_shift_warp(temp_img, -row_shifts(i), -col_shifts(i));
        Y_Obs(i+1,:,:) = temp1;
        temp_img = squeeze(fence(i+1,:,:));
        temp1 = func_motion_shift_warp(temp_img, -row_shifts(i), -col_shifts(i));
        fence(i+1,:,:) = temp1;
    end

    im_fg_arr = fence;

%     for i = 1:no_obs
%         for R = 1:rows
%             for C = 1:cols
%                 if Y_Obs(i,R,C) ==0||fence(i,R,C)==0
%                     im_fg_arr(i,R,C) = 0;
%                 end
%             end
%         end
% 
%     end

    data_cost_p1=zeros(rows,cols,numel(vec));
    data_cost_p2=zeros(rows,cols,numel(vec));
    data_cost_p3=zeros(rows,cols,numel(vec));
    data_cost_p4=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p1=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p2=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p3=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p4=zeros(rows,cols,numel(vec));
    
    Y_Obs_u8 = Y_Obs;
    Y_Obs = double(Y_Obs);
    im_fg_arr = double(im_fg_arr);
    
    for count_rows = 3:rows-2
        clc
        disp('        ');
        disp('Loopy Belief');
        count_rows/(rows-2)
        for count_cols = 3:cols-2
            count_label_p = 1;
            for label_p=vec
                data_cost_p1(count_rows,count_cols,count_label_p) = 0;
                for n=1:no_obs
                    data_cost_p1(count_rows,count_cols,count_label_p) = ...
                        data_cost_p1(count_rows,count_cols,count_label_p) + im_fg_arr(n,count_rows,count_cols-1)*(label_p - Y_Obs(n,count_rows,count_cols-1))^2;
                end
                
                data_cost_p2(count_rows,count_cols,count_label_p) = 0;
                for n=1:no_obs
                    data_cost_p2(count_rows,count_cols,count_label_p) = data_cost_p2(count_rows,count_cols,count_label_p) + ...
                        im_fg_arr(n,count_rows-1,count_cols)*(label_p - Y_Obs(n,count_rows-1,count_cols) )^2;
                end
                
                data_cost_p3(count_rows,count_cols,count_label_p) = 0;
                for n=1:no_obs
                    data_cost_p3(count_rows,count_cols,count_label_p) = data_cost_p3(count_rows,count_cols,count_label_p) + ...
                        im_fg_arr(n,count_rows,count_cols+1)*(label_p - Y_Obs(n,count_rows,count_cols+1) )^2;
                end
                
                data_cost_p4(count_rows,count_cols,count_label_p) = 0;
                for n=1:no_obs
                    data_cost_p4(count_rows,count_cols,count_label_p) = data_cost_p4(count_rows,count_cols,count_label_p) + ...
                        im_fg_arr(n,count_rows+1,count_cols)*(label_p - Y_Obs(n,count_rows+1,count_cols) )^2;
                end
                
                count_label_p = count_label_p + 1;
            end
        end
    end
    
    for iter = 2:T
       
       for count_rows = 3:rows-2
           clc
           disp('     ');
           disp(['Iter ', num2str(iter)]);
           disp('1st loop in iter: sum_mesgs_except_q');
            count_rows/(rows-2)
            for count_cols = 3:cols-2
                for i=1:numel(vec)
                     sum_mesgs_except_q_at_p1(count_rows,count_cols,i) =    init_mesgs_p1(iter-1,count_rows,count_cols-1,i) + ...
                                                                            init_mesgs_p2(iter-1,count_rows,count_cols-1,i) + ...
                                                                            init_mesgs_p4(iter-1,count_rows,count_cols-1,i);
                                                                        
                     sum_mesgs_except_q_at_p2(count_rows,count_cols,i) =    init_mesgs_p1(iter-1,count_rows-1,count_cols,i) + ...
                                                                            init_mesgs_p2(iter-1,count_rows-1,count_cols,i) + ...
                                                                            init_mesgs_p3(iter-1,count_rows-1,count_cols,i);
                                                                        
                     sum_mesgs_except_q_at_p3(count_rows,count_cols,i) =    init_mesgs_p2(iter-1,count_rows,count_cols+1,i) + ...
                                                                            init_mesgs_p3(iter-1,count_rows,count_cols+1,i) + ...
                                                                            init_mesgs_p4(iter-1,count_rows,count_cols+1,i);
                                                                        
                     sum_mesgs_except_q_at_p4(count_rows,count_cols,i) =    init_mesgs_p1(iter-1,count_rows+1,count_cols,i) + ...
                                                                            init_mesgs_p3(iter-1,count_rows+1,count_cols,i) + ...
                                                                            init_mesgs_p4(iter-1,count_rows+1,count_cols,i);            
                end
            end
       end

       count_label_p = 1;
       count_label_q = 1;        
       smooth_arr = zeros(1,1,numel(vec));
       
       for count_rows = 3:rows-2
           clc
           disp('     ');
           disp(['Iter ', num2str(iter)]);
           disp('2nd loop in iter: smooth_arr');
           count_rows/(rows-2)
           for count_cols = 3:cols-2
               for label_q = vec % 0:0.05:1 % 1:255
%                     for label_p = vec % 0:0.05:1 % 1:255
% 
%                         smoothness_cost = lambda_im_bg*abs(label_p - label_q); % 100*abs(label_p - label_q);
% 
%                         %                     smoothness_cost = 1e6*min(abs(label_p - label_q),10);
% 
% 
%                         %                  s1 |p2
%                         %                  |  |
%                         %             s2__p1__|q__p3
%                         %                  |  |
%                         %                 s3  |p4
%                         %
% 
%                         %               site_p_1 = [count_rows,(count_cols-1)];
%                         %               site_q = [count_rows,count_cols];
%                         %               site_p_2 = [(count_rows-1),count_cols];
%                         %               site_p_3 = [count_rows,(count_cols + 1)];
%                         %               site_p_4 = [(count_rows + 1),count_cols];
% 
%                         temp_var1(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p1(count_rows,count_cols,count_label_p) +  sum_mesgs_except_q_at_p1(count_rows,count_cols,count_label_p);
%                         temp_var2(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p2(count_rows,count_cols,count_label_p) +  sum_mesgs_except_q_at_p2(count_rows,count_cols,count_label_p);
%                         temp_var3(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p3(count_rows,count_cols,count_label_p) +  sum_mesgs_except_q_at_p3(count_rows,count_cols,count_label_p);
%                         temp_var4(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p4(count_rows,count_cols,count_label_p) +  sum_mesgs_except_q_at_p4(count_rows,count_cols,count_label_p);
%                         
%                         count_label_p = count_label_p + 1;
% 
%                     end % End of label_p loop.
% 
%                     count_label_p = 1;
                    
                    smooth_arr(1,1,:) = lambda_im_bg * abs(vec - label_q);
                    
                    temp_var1(count_rows,count_cols,:) =    smooth_arr + data_cost_p1(count_rows,count_cols,:) + ...
                                                            sum_mesgs_except_q_at_p1(count_rows,count_cols,:);
                                                        
                    temp_var2(count_rows,count_cols,:) =    smooth_arr + data_cost_p2(count_rows,count_cols,:) + ...
                                                            sum_mesgs_except_q_at_p2(count_rows,count_cols,:);
                                                        
                    temp_var3(count_rows,count_cols,:) =    smooth_arr + data_cost_p3(count_rows,count_cols,:) + ...
                                                            sum_mesgs_except_q_at_p3(count_rows,count_cols,:);
                                                        
                    temp_var4(count_rows,count_cols,:) =    smooth_arr + data_cost_p4(count_rows,count_cols,:) + ...
                                                            sum_mesgs_except_q_at_p4(count_rows,count_cols,:);

                    init_mesgs_p1(iter,count_rows,count_cols, count_label_q) = min(temp_var1(count_rows,count_cols,:)); % This is m_{p1 q}(f_q)
                    init_mesgs_p2(iter,count_rows,count_cols, count_label_q) = min(temp_var2(count_rows,count_cols,:)); % This is m_{p2 q}(f_q)
                    init_mesgs_p3(iter,count_rows,count_cols, count_label_q) = min(temp_var3(count_rows,count_cols,:)); % This is m_{p3 q}(f_q)
                    init_mesgs_p4(iter,count_rows ,count_cols, count_label_q) = min(temp_var4(count_rows,count_cols,:)); % This is m_{p4 q}(f_q)
                    count_label_q = count_label_q + 1;
                    
                end % End of label_q loop.
                count_label_q = 1;
            end  % End of count_cols loop.
        end  % End of count_rows loop.
    
    end % End of iter loop.
    
    count_label_q = 1;

    for count_rows = 3:rows-2
        clc
        disp('     ');
%         disp(['After Iter ', num2str(iter)]);
        disp('Belief');
        count_rows/(rows-2)
        for count_cols = 3:cols-2
            for label_q = vec
                belief(count_rows,count_cols,count_label_q) = 0;
                for n=1:no_obs
                    belief(count_rows,count_cols,count_label_q) =  belief(count_rows,count_cols,count_label_q) + ...
                        im_fg_arr(n,count_rows,count_cols)*(label_q - Y_Obs(n,count_rows,count_cols))^2;
                end
                belief(count_rows,count_cols,count_label_q) = belief(count_rows,count_cols,count_label_q) ...
                    + init_mesgs_p1(T,count_rows,count_cols, count_label_q)...
                    + init_mesgs_p2(T,count_rows,count_cols, count_label_q)...
                    + init_mesgs_p3(T,count_rows,count_cols, count_label_q)...
                    + init_mesgs_p4(T,count_rows ,count_cols, count_label_q);

                count_label_q = count_label_q +1;

            end

            count_label_q = 1;

            [~, min_index] = min(belief(count_rows,count_cols,:));

            defenced_img(count_rows,count_cols) = min_index;
        end
    end
% % %         figure, imshow(mat2gray(defenced_img*0.02), title(strcat('Original',num2str(iter)))
% % %         imwrite(mat2gray( defenced_img),[name '.tiff'],'TIFF');
% % %         pause(5)

% % %     imwrite(hsv2rgb(defenced_img*0.02),[name '.tiff'],'TIFF');
    
    image=defenced_img;
    a=find(image~=0);
    image(a)=(image(a)-1)*255/(length(vec)-1);
%     save output.mat image defenced_img
    figure, subplot(121), imshow(uint8(squeeze(Y_Obs(1,:,:)))), subplot(122), imshow(uint8(image)), truesize
    
    toc
    
end



function [warp_image] = func_motion_shift_warp(image, row_shift, col_shift)

    % function [warp_image] = func_motion_shift_warp(image, coord_row, coord_col, row_shift, col_shift)

    [rows_image, cols_image] = size(image);

    warp_image = zeros(rows_image, cols_image);

    for coord_row = 1:rows_image  % ceil(1 + row_shift):rows_image - ceil( row_shift)-1

        for coord_col = 1:cols_image   % ceil(1 + col_shift):cols_image - ceil(row_shift)-1

            shifted_row = coord_row + row_shift;

            shifted_col = coord_col + col_shift;

            if floor(shifted_row) >= 1 && ceil(shifted_row) <=rows_image-1 && floor(shifted_col) >= 1 && ceil(shifted_col) <= cols_image-1

                q11 = [floor(shifted_row) ,floor(shifted_col) ];

                q12 = [floor(shifted_row) , floor(shifted_col) + 1];

                q21 = [floor(shifted_row) + 1, floor(shifted_col) ];

                q22 = [floor(shifted_row) + 1, floor(shifted_col) + 1];


                warp_image(coord_row,coord_col) = ...
                      image(q11(1),q11(2))*(q22(1) - shifted_row)*(q22(2) - shifted_col)...
                    + image(q12(1),q12(2))*(q22(1) - shifted_row)*(shifted_col - q11(2))...
                    + image(q21(1),q21(2))*(shifted_row - q11(1))*(q22(2) - shifted_col )...
                    + image(q22(1),q22(2))*(shifted_row - q11(1))*(shifted_col - q11(2) );

            end
        end
    end
end
