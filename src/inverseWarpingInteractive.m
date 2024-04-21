% __________________________________________
% Source: Adam Czajka, Toan Q. Nguyen, February 2016
% Modified: AB, October 2020

% load an example image
[filename, path] = uigetfile('*');
I = imread([path filename]);
[rows, cols, ndims] = size(I);

% Show an input image
figure; imshow(I);

% Get four source points
% NOTE: start with upper-left corner and go clockwise (!)
[~,~,~,xSource,ySource] = roipoly;

% I_transformed will contain our resulting image
I_transformed = uint8(zeros(size(I)));

% And we want to have them in the image corners:
xDest = [1, cols, cols, 1];
yDest = [1, 1, rows, rows];

% Let's calculate the projective matrix H:
disp('Calculating the projective matrix H ...')
H = getHmatrix(xSource, ySource, xDest, yDest);

H_inv = inv(H);  % Calculate the inverse of the matrix H

% Having matrix H we may do our transformation for each pixel:
disp('Transforming the pixels ...')
count = 0;
for x_dest = 1:cols  % Change to iterate over destination pixels
    for y_dest = 1:rows

        % Compute source coordinates using the inverse transformation
        destPX = [double(x_dest); double(y_dest); 1];
        sourcePX = H_inv * destPX; 
        x_source = sourcePX(1) / sourcePX(3);
        y_source = sourcePX(2) / sourcePX(3);
        x_source_round = round(x_source);
        y_source_round = round(y_source);

        if x_source_round > 0 && y_source_round > 0 && x_source_round <= cols && y_source_round <= rows
            count = count + 1;
            for n = 1:ndims
                I_transformed(y_dest, x_dest, n) = I(y_source_round, x_source_round, n);  % Assigning pixel values
            end
        end

    end
end

% Show the result
figure; imshow(I_transformed);
imwrite(I_transformed,'panorama_inverse_warping.png');

disp(['This version of warping calculated new values for ' num2str(100*count/(rows*cols)) '% of destination pixels.'])
