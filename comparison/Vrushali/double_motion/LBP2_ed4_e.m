function image = LBP2_ed4_e(row_shifts, col_shifts, Y_Obs, fence, T)

    % Implementing Loopy Belief Proapagation for image defencing
    % using multiple shifted frames where fence is static
    % and background moves with global motion.
    
    % Updated: 1st April, 2014; Vikram Voleti, IIT Kharagpur
    
    % row_shifts = n x rows x cols double
    % col_shifts = n x rows x cols double
    % Y_Obs = n x rows x cols uint8
    % fence = n x rows x cols 0,1
    
    % Shift downwards is positive row shift
    % Shift to the right is positive column shift
    
    % fence image: 1==Background, 0==Fence!!!!
    
    tic
    if(nargin<5) T = 2; end %No. of iterations
    no_obs = size(Y_Obs,1); %No. of observations

    lambda_im_bg = 0.005; %This is good smoothness parameter -->% 0.0005;
    vec = 0:15:255;
    
    [rows, cols]= size(squeeze(Y_Obs(1,:,:)));
	
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
        temp1 = func_motion_shift_warp(temp_img, -row_shifts, -col_shifts, i);
        Y_Obs(i+1,:,:) = temp1;
        figure, imshow(uint8(temp1)), pause(.04)
        temp_img = squeeze(fence(i+1,:,:));
        temp1 = func_motion_shift_warp(temp_img, -row_shifts, -col_shifts, i);
        fence(i+1,:,:) = temp1;
    end

    im_fg_arr = fence;

    data_cost_p1=zeros(rows,cols,numel(vec));
    data_cost_p2=zeros(rows,cols,numel(vec));
    data_cost_p3=zeros(rows,cols,numel(vec));
    data_cost_p4=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p1=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p2=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p3=zeros(rows,cols,numel(vec));
    sum_mesgs_except_q_at_p4=zeros(rows,cols,numel(vec));
    
    Y_Obs = double(Y_Obs);
    im_fg_arr = double(im_fg_arr);
    
    count_rows = 3:rows-2; count_cols = 3:cols-2;
    count_label_p = 1;
    for label_p=vec
        
        clc, disp('Loop 1 of 3: label_p'), disp('')
        label_p/max(vec)
        
        data_cost_p1(count_rows,count_cols,count_label_p) = squeeze(sum(im_fg_arr(:,count_rows,count_cols-1).*(label_p - Y_Obs(:,count_rows,count_cols-1)).^2, 1));
        data_cost_p2(count_rows,count_cols,count_label_p) = squeeze(sum(im_fg_arr(:,count_rows-1,count_cols).*(label_p - Y_Obs(:,count_rows-1,count_cols)).^2, 1));
        data_cost_p3(count_rows,count_cols,count_label_p) = squeeze(sum(im_fg_arr(:,count_rows,count_cols+1).*(label_p - Y_Obs(:,count_rows,count_cols+1)).^2, 1));
        data_cost_p4(count_rows,count_cols,count_label_p) = squeeze(sum(im_fg_arr(:,count_rows+1,count_cols).*(label_p - Y_Obs(:,count_rows+1,count_cols)).^2, 1));
        count_label_p = count_label_p + 1;
        
    end
    
    for iter = 2:T
        
        sum_mesgs_except_q_at_p1(count_rows,count_cols,:) =    init_mesgs_p1(iter-1,count_rows,count_cols-1,:) + ...
                                                               init_mesgs_p2(iter-1,count_rows,count_cols-1,:) + ...
                                                               init_mesgs_p4(iter-1,count_rows,count_cols-1,:);

        sum_mesgs_except_q_at_p2(count_rows,count_cols,:) =    init_mesgs_p1(iter-1,count_rows-1,count_cols,:) + ...
                                                               init_mesgs_p2(iter-1,count_rows-1,count_cols,:) + ...
                                                               init_mesgs_p3(iter-1,count_rows-1,count_cols,:);

        sum_mesgs_except_q_at_p3(count_rows,count_cols,:) =    init_mesgs_p2(iter-1,count_rows,count_cols+1,:) + ...
                                                               init_mesgs_p3(iter-1,count_rows,count_cols+1,:) + ...
                                                               init_mesgs_p4(iter-1,count_rows,count_cols+1,:);

        sum_mesgs_except_q_at_p4(count_rows,count_cols,:) =    init_mesgs_p1(iter-1,count_rows+1,count_cols,:) + ...
                                                               init_mesgs_p3(iter-1,count_rows+1,count_cols,:) + ...
                                                               init_mesgs_p4(iter-1,count_rows+1,count_cols,:);

        count_label_q = 1;        
        smooth = zeros(1,1,numel(vec));
        smooth_arr = zeros(rows, cols, numel(vec));
        for label_q = vec % 0:0.5:255

            clc, disp('Loop 2 of 3: label_q');
            disp(['Iter ', num2str(iter), ' of ', num2str(T)]), disp('')
            label_q/max(vec)
            
            smooth(1,1,:) = lambda_im_bg * abs(vec - label_q);
            smooth_arr = repmat(smooth, [rows cols 1]);
            temp_var1 = smooth_arr + data_cost_p1 + sum_mesgs_except_q_at_p1;
            temp_var2 = smooth_arr + data_cost_p2 + sum_mesgs_except_q_at_p2;
            temp_var3 = smooth_arr + data_cost_p3 + sum_mesgs_except_q_at_p3;
            temp_var4 = smooth_arr + data_cost_p4 + sum_mesgs_except_q_at_p4;

            init_mesgs_p1(iter, :, :, count_label_q) = min(temp_var1, [], 3); % This is m_{p1 q}(f_q)
            init_mesgs_p2(iter, :, :, count_label_q) = min(temp_var2, [], 3); % This is m_{p2 q}(f_q)
            init_mesgs_p3(iter, :, :, count_label_q) = min(temp_var3, [], 3); % This is m_{p3 q}(f_q)
            init_mesgs_p4(iter, :, :, count_label_q) = min(temp_var4, [], 3); % This is m_{p4 q}(f_q)
            count_label_q = count_label_q + 1;

        end % End of label_q loop.
        
    
    end % End of iter loop.
    
    count_label_q = 1;
    for label_q = vec
        
        clc, disp('Loop 3 of 3: Belief'), disp('')
        label_q/max(vec)
        
        belief(:, :, count_label_q) =  squeeze(sum(im_fg_arr.*(label_q - Y_Obs).^2, 1))...
            + squeeze(init_mesgs_p1(T, :, :, count_label_q))...
            + squeeze(init_mesgs_p2(T, :, :, count_label_q))...
            + squeeze(init_mesgs_p3(T, :, :, count_label_q))...
            + squeeze(init_mesgs_p4(T, :, :, count_label_q));
        count_label_q = count_label_q +1;

    end

    [~, defenced_img] = min(belief, [], 3);

    image=defenced_img;
    a=find(image~=0);
    image(a)=(image(a)-1)*255/(length(vec)-1);
%     save output.mat image defenced_img
    figure, subplot(121), imshow(uint8(squeeze(Y_Obs(1,:,:)))), subplot(122), imshow(uint8(image)), truesize
    
    toc
    
end



function [warp_image] = func_motion_shift_warp(image, row_shifts, col_shifts, temp_img_no)

	[rows, cols] = size(image);

	[coord_col, coord_row] = meshgrid(1:cols, 1:rows);

	if size(row_shifts,3)==1
		row_shift = row_shifts(temp_img_no)*ones(rows,cols); col_shift = col_shifts(temp_img_no)*ones(rows,cols);
	else
		row_shift = squeeze(row_shifts(temp_img_no,:,:)); col_shift = squeeze(col_shifts(temp_img_no,:,:));
	end

	shifted_row = coord_row + row_shift;
	shifted_col = coord_col + col_shift;

	condition = floor(shifted_row)>0 & ceil(shifted_row)<rows & floor(shifted_col)>0 & ceil(shifted_col)<cols;

	q11r = floor(shifted_row); q11r(~condition) = coord_row(~condition); q11c = floor(shifted_col); q11c(~condition) = coord_col(~condition);
	q12r = floor(shifted_row); q12r(~condition) = coord_row(~condition); q12c = floor(shifted_col)+1; q12c(~condition) = coord_col(~condition);
	q21r = floor(shifted_row)+1; q21r(~condition) = coord_row(~condition); q21c = floor(shifted_col); q21c(~condition) = coord_col(~condition);
	q22r = floor(shifted_row)+1; q22r(~condition) = coord_row(~condition); q22c = floor(shifted_col)+1; q22c(~condition) = coord_col(~condition);

	elem11 = q11r + (q11c-1)*rows; elem12 = q12r + (q12c-1)*rows; elem21 = q21r + (q21c-1)*rows; elem22 = q22r + (q22c-1)*rows;

	warp_image = ...
		image(elem11).*(q22r - shifted_row).*(q22c - shifted_col) + ...
		image(elem12).*(q22r - shifted_row).*(shifted_col - q11c) + ...
		image(elem21).*(shifted_row - q11r).*(q22c - shifted_col) + ...
		image(elem22).*(shifted_row - q11r).*(shifted_col - q11c);

end
