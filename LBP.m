%function image = LBP(row_shifts,col_shifts,Y_Obs,fence,name)
    % Implementing Loopy Belief Proapagation for image defencing
    % using multiple shifted frames where fence is static
    % and background moves with global motion.

	
	%% initialization steps here
    tic
    T = 2; % set T = no. of iterations +1.

    lambda_im_bg = 0.00005; %This is good smoothness parameter -->% 0.0005;
    vec = 0:1:255;
    no_obs = 4;
    
    [rows cols]= size(squeeze(Y_Obs(1,:,:)));

    Y_Obs=double(Y_Obs);

    defenced_img = zeros(rows,cols);
    init_mesgs = zeros(T,rows,cols,size((vec),2)); % Intitalizing all messages to be zero vectors of length 256.
    belief = zeros(rows,cols,size((vec),2));

    temp_var1 = zeros(rows,cols,size((vec),2));
    temp_var2 = zeros(rows,cols,size((vec),2));
    temp_var3 = zeros(rows,cols,size((vec),2));
    temp_var4 = zeros(rows,cols,size((vec),2));


    count_label_p = 1;
    count_label_q = 1;

%% backwarped images created here
    %--------------------------------------------------------------------------
                        for i = 1:no_obs-1
                            temp_img = squeeze(Y_Obs(i+1,:,:));
                            temp1 = func_motion_shift_warp(temp_img, -row_shifts(i), -col_shifts(i));
                            Y_Obs(i+1,:,:) = temp1; 
                            temp_img = squeeze(fence(i+1,:,:));
                            temp1 = func_motion_shift_warp(temp_img, -row_shifts(i), -col_shifts(i));
                            fence(i+1,:,:) = temp1; 
                        end
    %-------------------------------------------------------------------------

    im_fg_arr = ones(4,rows,cols);

%% rudimentary fence detection code. wud work for artificial fence images having integer shifts.
    for i = 1:no_obs
        for R = 1:rows
            for C = 1:cols
                if Y_Obs(i,R,C) ==0||fence(i,R,C)==0
                    im_fg_arr(i,R,C) = 0;
                end
            end
        end

    end

 %% BP loop for T-1 iterations
    for iter = 2:T
        for count_rows = 3:rows-2
            count_rows

            for count_cols = 3:cols-2
    %             count_cols

                for label_q = vec % 0:0.05:1 % 1:255
                    for label_p = vec % 0:0.05:1 % 1:255

                        smoothness_cost = lambda_im_bg*abs(label_p - label_q); % 100*abs(label_p - label_q);

                        %                     smoothness_cost = 1e6*min(abs(label_p - label_q),10);


                        %                  s1 |p2
                        %                  |  |
                        %             s2__p1__|q__p3
                        %                  |  |
                        %                 s3  |p4
                        %

                        site_p_1 = [count_rows,(count_cols-1)];
                        site_q = [count_rows,count_cols];
                        site_p_2 = [(count_rows-1),count_cols];
                        site_p_3 = [count_rows,(count_cols + 1)];
                        site_p_4 = [(count_rows + 1),count_cols];

                        data_cost_p1 = (im_fg_arr(1,count_rows,count_cols-1)*label_p - Y_Obs(1,count_rows,count_cols-1) )^2 + (im_fg_arr(2,count_rows,count_cols-1)*label_p - Y_Obs(2,count_rows,count_cols-1) )^2 ...
                            + (im_fg_arr(3,count_rows,count_cols-1)*label_p - Y_Obs(3,count_rows,count_cols-1) )^2 + (im_fg_arr(4,count_rows,count_cols-1)*label_p - Y_Obs(4,count_rows,count_cols-1) )^2 ;

                        data_cost_p2 =  (im_fg_arr(1,count_rows-1,count_cols)*label_p - Y_Obs(1,count_rows-1,count_cols) )^2 + (im_fg_arr(2,count_rows-1,count_cols)*label_p - Y_Obs(2,count_rows-1,count_cols) )^2 ...
                            + (im_fg_arr(3,count_rows-1,count_cols)*label_p - Y_Obs(3,count_rows-1,count_cols))^2 + (im_fg_arr(4,count_rows-1,count_cols)*label_p - Y_Obs(4,count_rows-1,count_cols) )^2 ;

                        data_cost_p3 =  (im_fg_arr(1,count_rows,count_cols+1)*label_p - Y_Obs(1,count_rows,count_cols+1) )^2 + (im_fg_arr(2,count_rows,count_cols+1)*label_p - Y_Obs(2,count_rows,count_cols+1) )^2 ...
                            + (im_fg_arr(3,count_rows,count_cols+1)*label_p - Y_Obs(3,count_rows,count_cols+1) )^2 + (im_fg_arr(4,count_rows,count_cols+1)*label_p - Y_Obs(4,count_rows,count_cols+1) )^2;

                        data_cost_p4 =  (im_fg_arr(1,count_rows+1,count_cols)*label_p - Y_Obs(1,count_rows+1,count_cols) )^2 + (im_fg_arr(2,count_rows+1,count_cols)*label_p - Y_Obs(2,count_rows+1,count_cols) )^2 ...
                            + (im_fg_arr(3,count_rows+1,count_cols)*label_p - Y_Obs(3,count_rows+1,count_cols) )^2 + (im_fg_arr(4,count_rows+1,count_cols)*label_p - Y_Obs(4,count_rows+1,count_cols) )^2;



                        sum_mesgs_except_q_at_p1 = init_mesgs(iter-1,count_rows-1,count_cols-1,count_label_p) +  init_mesgs(iter-1,count_rows,count_cols-2,count_label_p) + init_mesgs(iter-1,count_rows+1,count_cols-1,count_label_p);
                        sum_mesgs_except_q_at_p2 = init_mesgs(iter-1,count_rows-2,count_cols,count_label_p) +  init_mesgs(iter-1,count_rows-1,count_cols-1,count_label_p) + init_mesgs(iter-1,count_rows-1,count_cols+1,count_label_p);
                        sum_mesgs_except_q_at_p3 = init_mesgs(iter-1,count_rows-1,count_cols + 1,count_label_p) +  init_mesgs(iter-1,count_rows+1,count_cols+1,count_label_p) + init_mesgs(iter-1,count_rows,count_cols+2,count_label_p);
                        sum_mesgs_except_q_at_p4 = init_mesgs(iter-1,count_rows + 1,count_cols - 1,count_label_p) +  init_mesgs(iter-1,count_rows + 2,count_cols,count_label_p) + init_mesgs(iter-1,count_rows + 1,count_cols + 1,count_label_p);


                        temp_var1(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p1 +  sum_mesgs_except_q_at_p1;
                        temp_var2(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p2 +  sum_mesgs_except_q_at_p2;
                        temp_var3(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p3 +  sum_mesgs_except_q_at_p3;
                        temp_var4(count_rows,count_cols,count_label_p) = smoothness_cost + data_cost_p4 +  sum_mesgs_except_q_at_p4;
                        
                        count_label_p = count_label_p + 1;

                    end % End of label_p loop.

                    count_label_p = 1;

                    init_mesgs(iter,count_rows,count_cols-1, count_label_q) = min(temp_var1(count_rows,count_cols,:)); % This is m_{p1 q}(f_q)
                    init_mesgs(iter,count_rows-1,count_cols, count_label_q) = min(temp_var2(count_rows,count_cols,:)); % This is m_{p2 q}(f_q)
                    init_mesgs(iter,count_rows,count_cols+1, count_label_q) = min(temp_var3(count_rows,count_cols,:)); % This is m_{p3 q}(f_q)
                    init_mesgs(iter,count_rows+1 ,count_cols, count_label_q) = min(temp_var4(count_rows,count_cols,:)); % This is m_{p4 q}(f_q)
                    count_label_q = count_label_q + 1;
                end % End of label_q loop.
                count_label_q = 1;
            end  % End of count_cols loop.
        end  % End of count_rows loop.
    end
	% End of iter loop.

        count_label_q = 1;

%% Belief computation
        for count_rows = 3:rows-2
            for count_cols = 3:cols-2
                for label_q = vec 
                    
                    belief(count_rows,count_cols,count_label_q) =  (im_fg_arr(1,count_rows,count_cols)*label_q - Y_Obs(1,count_rows,count_cols) )^2 + (im_fg_arr(2,count_rows,count_cols)*label_q - Y_Obs(2,count_rows,count_cols) )^2 ...
                        + (im_fg_arr(3,count_rows,count_cols)*label_q - Y_Obs(3,count_rows,count_cols) )^2 + (im_fg_arr(4,count_rows,count_cols)*label_q - Y_Obs(4,count_rows,count_cols) )^2 ...
                        + init_mesgs(iter,count_rows,count_cols-1, count_label_q)...
                        + init_mesgs(iter,count_rows-1,count_cols, count_label_q) + init_mesgs(iter,count_rows,count_cols+1, count_label_q)...
                        + init_mesgs(iter,count_rows+1 ,count_cols, count_label_q);

                    count_label_q = count_label_q +1;

                end

                count_label_q = 1;

                [min_val min_index] = min(belief(count_rows,count_cols,:));

                defenced_img(count_rows,count_cols) = min_index;
            end
        end
        figure, imshow(mat2gray(( defenced_img))), title(strcat('Original',num2str(iter)))
% % %         imwrite(mat2gray( defenced_img),[name '.tiff'],'TIFF');
% % %         pause(5)

    imwrite(mat2gray( defenced_img),[name '.tiff'],'TIFF');
    toc
    image=mat2gray(defenced_img);
% end