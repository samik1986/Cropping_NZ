%% Cropping logs to find Missing and Duplicate Sections
% Samik Banerjee Aug 18, 2022
% crop_logs(slideSet, brainID, stainType, secPerSlide, logDir)
% Usage: crop_logs('PMD3679&3680', 'PMD3679', 'F', 3, '.')
% OP: in cwd .
%     <brainID>_<stainType>_missingSections.txt
%     <brainID>_<stainType>_duplicateSections.txt
%     <brainID>_<stainType>_logs.csv -- Binary values for all data
% Requires cropping to complete before runnig this code
% Logs maybe stored in qcdisk005/croplogs/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function crop_logs(slideSet, brainID, stainType, secPerSlide, logDir)

% slideSet = 'PMD3679&3680';
% brainID = ''PMD3679'
% stainType = 'F';
% secPerSlide = 3;
% logDir = '/nfs/data/qc/qcdisk005/croplogs/'

cropBrainDir = ['/nfs/data/qc/qcdisk006/mba_converted_imaging_data/' ...
    slideSet '_manual/' brainID '/'];
cropDirecBrainLossy = dir(fullfile(cropBrainDir, ['*' stainType '*_lossy.jp2']));
cropDirecBrainLossless = dir(fullfile(cropBrainDir, ['*' stainType '*_lossless.jp2']));
cropDirecBrainTif = dir(fullfile(cropBrainDir, ['*' stainType '*.tif']));
cropDirecBrainPNG = dir(fullfile(cropBrainDir, ['*' stainType '*.png']));
cropDirecBrainMeta = dir(fullfile(cropBrainDir, ['meta_*' stainType '*.txt']));
cropList = [];

for i = 1 : length(cropDirecBrainLossy)
    file = strrep(cropDirecBrainLossy(i).name, '_lossy.jp2', '');
    cropSectionNo = str2double(file(end-3:end));
    slideLoc = strfind(file, stainType) + length(stainType);
    slideEnd = strfind(file, '-');
    slideNum = str2double(file(slideLoc:slideEnd(2)-1));
    if length(cropList) < cropSectionNo
        if ceil(cropSectionNo/secPerSlide) == slideNum
            cropList(cropSectionNo).lossy = true;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = '';
        else
            cropList(cropSectionNo).lossy = true;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    else
        if cropList(cropSectionNo).lossy
            cropList(cropSectionNo).duplicate = true;
        else
            cropList(cropSectionNo).lossy = true;
        end
        if ceil(cropSectionNo/secPerSlide) ~= slideNum
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    end
end

for i = 1 : length(cropDirecBrainLossless)
    file = strrep(cropDirecBrainLossless(i).name, '_lossless.jp2', '');
    cropSectionNo = str2double(file(end-3:end));
    slideLoc = strfind(file, stainType) + length(stainType);
    slideEnd = strfind(file, '-');
    slideNum = str2double(file(slideLoc:slideEnd(2)-1));
    if length(cropList) < cropSectionNo
        if ceil(cropSectionNo/secPerSlide) == slideNum
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = true;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = '';
        else
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = true;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    else
        
        if cropList(cropSectionNo).lossless
            cropList(cropSectionNo).duplicate = true;
        else
            cropList(cropSectionNo).lossless = true;
        end
        if ceil(cropSectionNo/secPerSlide) ~= slideNum
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    end
end


for i = 1 : length(cropDirecBrainTif)
    file = strrep(cropDirecBrainTif(i).name, '.tif', '');
    cropSectionNo = str2double(file(end-3:end));
    slideLoc = strfind(file, stainType) + length(stainType);
    slideEnd = strfind(file, '-');
    slideNum = str2double(file(slideLoc:slideEnd(2)-1));
    if length(cropList) < cropSectionNo
        if ceil(cropSectionNo/secPerSlide) == slideNum
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = true;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = '';
        else
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = true;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    else
        
        if cropList(cropSectionNo).tif
            cropList(cropSectionNo).duplicate = true;
        else
            cropList(cropSectionNo).tif = true;
        end
        if ceil(cropSectionNo/secPerSlide) ~= slideNum
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    end
end


for i = 1 : length(cropDirecBrainPNG)
    file = strrep(cropDirecBrainPNG(i).name, '.png', '');
    cropSectionNo = str2double(file(end-3:end));
    cslideLoc = strfind(file, stainType) + length(stainType);
    slideEnd = strfind(file, '-');
    slideNum = str2double(file(slideLoc:slideEnd(2)-1));
    if length(cropList) < cropSectionNo
        if ceil(cropSectionNo/secPerSlide) == slideNum
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = true;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = '';
        else
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = true;
            cropList(cropSectionNo).meta = false;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    else
        
        if cropList(cropSectionNo).png
            cropList(cropSectionNo).duplicate = true;
        else
            cropList(cropSectionNo).png = true;
        end
        if ceil(cropSectionNo/secPerSlide) ~= slideNum
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    end
end

for i = 1 : length(cropDirecBrainMeta)
    file = strrep(cropDirecBrainMeta(i).name, 'meta_', '');
    file = strrep(file, '.txt', '');
    cropSectionNo = str2double(file(end-3:end));
    slideLoc = strfind(file, stainType) + length(stainType);
    slideEnd = strfind(file, '-');
    slideNum = str2double(file(slideLoc:slideEnd(2)-1));
    if length(cropList) < cropSectionNo
        if ceil(cropSectionNo/secPerSlide) == slideNum
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = true;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = '';
        else
            cropList(cropSectionNo).lossy = false;
            cropList(cropSectionNo).lossless = false;
            cropList(cropSectionNo).tif = false;
            cropList(cropSectionNo).png = false;
            cropList(cropSectionNo).meta = true;
            cropList(cropSectionNo).duplicate = false;
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    else
        
        if cropList(cropSectionNo).meta
            cropList(cropSectionNo).duplicate = true;
        else
            cropList(cropSectionNo).meta = true;
        end
        if ceil(cropSectionNo/secPerSlide) ~= slideNum
            cropList(cropSectionNo).error = ...
                ['Slide ' num2str(slideNum) ' and Section ' ...
                num2str(cropSectionNo) ' Mismatch'];
        end
    end
end

for i = 1 : length(cropList)
    if isempty(cropList(i).lossy)
        cropList(i).lossy = false;
    end
    if isempty(cropList(i).lossless)
        cropList(i).lossless = false;
    end
    if isempty(cropList(i).meta)
        cropList(i).meta = false;
    end
    if isempty(cropList(i).tif)
        cropList(i).tif = false;
    end
    if isempty(cropList(i).png)
        cropList(i).png = false;
    end
    if isempty(cropList(i).duplicate)
        cropList(i).duplicate = false;
    end
end

fid_miss = fopen([logDir '/' brainID '_' stainType '_missingSections.txt'], 'w');
fid_dup = fopen([logDir '/' brainID '_' stainType '_duplicateSections.txt'], 'w');
fid_log = fopen([logDir '/' brainID '_' stainType '_log.csv'], 'w');

fprintf(fid_log, 'SectionNo,Lossy,Lossless,Tiff,PNG,MetaData,Duplicate,ErrorMsg\n');

cnt_missing =0;
cnt_dup = 0;

for i = 1 : length(cropList)
    
    if ~cropList(i).lossy
        fprintf(fid_miss, [num2str(i) '\n']);
        cnt_missing = cnt_missing + 1;
    end
    
    if cropList(i).duplicate
        fprintf(fid_dup, [num2str(i) '\n']);
        cnt_dup = cnt_dup + 1;
    end
    
    fprintf(fid_log, [num2str(i) ',']);
    fprintf(fid_log, [num2str(cropList(i).lossy) ',']);
    fprintf(fid_log, [num2str(cropList(i).lossless) ',']);
    fprintf(fid_log, [num2str(cropList(i).tif) ',']);
    fprintf(fid_log, [num2str(cropList(i).png) ',']);
    fprintf(fid_log, [num2str(cropList(i).meta) ',']);
    fprintf(fid_log, [num2str(cropList(i).duplicate) ',']);
    fprintf(fid_log, [cropList(i).error '\n']);
end

fprintf(fid_dup, ['Total duplicate Sections = ' num2str(cnt_dup) '\n']);
fprintf(fid_miss, ['Total missing Sections = ' num2str(cnt_missing) '\n']);
fclose(fid_dup); fclose(fid_miss); fclose(fid_log);
end


