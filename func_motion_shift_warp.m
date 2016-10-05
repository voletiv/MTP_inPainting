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
