%% NGR2TIF Read an RGB image from Hamamatsu NGR file.
%   A = NGR2TIF(FILENAME, precision) reads an RGB file stored in Hamamatsu's NGR
%   format from the file specified by the string FILENAME. Each image file
%   is stored in a n-bit format for the red, green and blue channels.
%   
%   precision -- {'uint16', 'uint8'}
%
%   The return value A is an array containing the image data. A is an
%   M-by-N-by-3 array with each array element of type 'Precision'.
%
%   Tomasz Piech - August 2010
%   Modified : Samik Banerjee - August 2022
%% Extra info for NGR for further development 
    % (https://openslide.org/formats/hamamatsu/)
    % The NGR file contains uncompressed (16/8)-bit RGB data, 
    % with a small header. The files we have encountered start with GN,
    % two more bytes, and then width, height, and column width 
    % in little endian 32-bit format. 
    % The column width must divide evenly into the width. 
    % Column width is important, since NGR files are generated in columns, 
    % where the first column comes first in the file, 
    % followed by subsequent files. Columns are painted left-to-right.
    %
    % At offset 24 is another 32-bit integer 
    % which gives the offset in the file to the start of the image data. 
    % The image data we have encountered is in 16-bit little endian format.

%% Function body
function A = ngr2tif(filename, precision)

iptchecknargin(1, 3, nargin, mfilename);
iptcheckinput(filename, {'char'}, {'nonempty'}, mfilename, 'filename', 1);
checkfileexists(filename);

fid = fopen(filename, 'r'); % 'r' - read is the default
if fid ~= -1
    
    try
        tag      = fread(fid, 2, 'uint8=>char');
        assert(strcmpi(tag', 'GN'));
        blank    = fread(fid, 2, 'uint8=>char');
        width    = fread(fid, 1, 'uint32');
        height   = fread(fid, 1, 'uint32');
        colwidth = fread(fid, 1, 'uint32');
                
        %% get data offset at offset 24
        fseek(fid, 24, 'bof');
        dataoffset = fread(fid, 1, 'uint32');
        fseek(fid, dataoffset, 'bof');
       
        
        %% read each channel, RGB
        A = zeros(height, width, 3, precision);
        
        %% find divs of column width
        divs = width/colwidth;
        
        for i = 1 : divs
            disp(['Reading column ' num2str(i)]);
            img = fread(fid, 3 * colwidth * height, precision);
            A(1:height, (i-1)*colwidth+1:i*colwidth, 1) = ...
                reshape(img(1:3:end), colwidth, height)';
            A(1:height, (i-1)*colwidth+1:i*colwidth, 2) = ...
                reshape(img(1:3:end), colwidth, height)';
            A(1:height, (i-1)*colwidth+1:i*colwidth, 3) = ...
                reshape(img(1:3:end), colwidth, height)';
        
        end
        
    catch ME
        
        %% finally, close the filename
        fclose(fid);
        rethrow(ME);
    end
    
    fclose(fid);
end

    function checkfileexists(filename)
        if exist(filename, 'file') ~= 2
            error('TP:ngr2tif:FileDoesNotExist', 'Specified NGR file does not exist:\n%s', filename);
        end
    end
end