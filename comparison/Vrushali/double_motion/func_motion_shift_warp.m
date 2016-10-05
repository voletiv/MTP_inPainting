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
