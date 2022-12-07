function crop_list(nz, brainID, prefix)
%     prefix = 'MD';
%     nz = 2;
%     brainID = 'MD850';
% clear all;
% close all;
addpath(genpath('natsortfiles'));
dirBrain = ['/nfs/data/qc/qcdisk005/NanoZoomer_' num2str(nz) '/' brainID '/'];
typeCross = 'List';
direcBrain = natsortfiles(dir(fullfile(dirBrain, [brainID '*'])));

cmdPre = '';
fidRun = fopen([brainID '.sh'], 'w');
cmdPre = [cmdPre '#! /bin/bash\n'];
cmdPre = [cmdPre 'INPUT_NGR_BASE_FOLDER=' dirBrain '\n'];
cmdPre = [cmdPre 'OUTPUT_JP2_BASE_FOLDER=/nfs/data/qc/qcdisk006/mba_converted_imaging_data\n'];
cmdPre = [cmdPre 'CMD="./cropNGR"\n'];
fprintf(fidRun, cmdPre);

slideInfo = ['/nfs/data/qc/qcdisk005/NanoZoomer_' num2str(nz) '/' brainID '/slideInfo.csv'];
slideMat = readtable(slideInfo);

trcUnq = unique(slideMat{:,3});

%% Find the start section numbers (-1) for each slide
for trcr = 1 : length(trcUnq)
    slideAll(trcr).tracer = trcUnq{trcr,1};
    slideAll(trcr).trcAll = find(ismember(slideMat{:,3}, ...
        slideAll(trcr).tracer));
    slideAll(trcr).trcTab = slideMat(slideAll(trcr).trcAll,:);
    slideAll(trcr).maxSlides = max(slideAll(trcr).trcTab{:,1});
    
    secCounter = 0;
    slideCnt = 0;
    for cnt = 1 : slideAll(trcr).maxSlides
        secCntExists  = find(ismember(slideAll(trcr).trcTab{:,1}, cnt));
        
        if secCntExists
            slideAll(trcr).trcTab{secCntExists,4} = secCounter;
            slideCnt = slideAll(trcr).trcTab{secCntExists,2};
        end
        secCounter = secCounter + slideCnt;
    end
end



for nD = 1 : length(direcBrain)
    try
        %% set file directory name
        dirName1 = direcBrain(nD).name;
        disp(dirName1);
        if ~strcmp(dirName1(end),'/')
            dirName1 = [dirName1 '/'];
        end
        
        %% Check if the slideInfo exists
        slideExists = 0;
        trcExists = 0;
        secName = strrep(dirName1, '/', '');
        %         secName = strrep(secName, 'MY', 'My');
        secfind = strfind(secName, ' ');
        tracerType = secName(secfind(2)+1:secfind(3)-1);
        slideNo = str2num(secName(secfind(3)+1:secfind(4)-1));
        
        %% Gather the tracer Table
        for chk = 1 : length(slideAll)
            if strcmp(slideAll(chk).tracer, tracerType)
                slideTab = slideAll(chk).trcTab;
            end
        end
         
        slideExists = ismember(slideTab{:,1}, slideNo);        
        tempSlideMat = slideTab(slideExists,:);        
        trcExists =  ismember(tempSlideMat{:,3}, tracerType);
        
        if trcExists
            
            noOfSlides = tempSlideMat{trcExists,4};
            noOfSecs = tempSlideMat{trcExists,2};
            
            %% get directory of files NGR
            flist = dir(fullfile([dirBrain dirName1], '*.ngr'));
            
            %get name of .ngr file
            f_ind_ngr = 1;
            fname_ngr = flist(f_ind_ngr).name;
            
            %% get directory of files VMU
            flist = dir(fullfile([dirBrain dirName1], '*.vmu'));
            
            %get name of .vmu file
            f_ind_vmu = 1;
            fname_vmu = flist(f_ind_vmu).name;
            
            %% get directory of files Calibration
            flist = dir(fullfile([dirBrain dirName1], '*_calibration.txt'));
            
            %get name of _calibration.txt file
            f_ind_cal = 1;
            fname_cal = flist(f_ind_cal).name;
            
            %% get directory of files blobmap
            flist = dir(fullfile([dirBrain dirName1], '*.raw'));
            
            %get name of blobmap.raw file
            f_ind_blob = 1;
            fname_blobmap = flist(f_ind_blob).name;
            
            %% get directory of files macro
            flist = dir(fullfile([dirBrain dirName1], '*.jpg'));
            
            %get name of macro image (.jpg) file
            f_ind_macro = 1;
            fname_macro = flist(f_ind_macro).name;
            
            
            %% read in macro image (.jpg) file contents
            macro = imread([dirBrain dirName1 fname_macro]);
            
            %% Read NGR Map
            flist = dir(fullfile([dirBrain dirName1], '*_map.ngr'));
            f_ind_mapNGR = 1;
            fname_mapNGR = flist(f_ind_mapNGR).name;
            
            %% open and read .vmu file
            fid = fopen([dirBrain dirName1 fname_vmu],'r');
            vmu = textscan(fid,'%s');
            fclose(fid);
            
            %% parse blobmap size out of .vmu file
            isblobdim = strfind(vmu{1},'BlobMap');
            blobdiminds = find(~(cellfun('isempty',isblobdim)));
            widthloc = strfind(vmu{1}{blobdiminds(1)},'=');
            heightloc = strfind(vmu{1}{blobdiminds(2)},'=');
            blobwidth = str2double(vmu{1}{blobdiminds(1)}(widthloc+1:end));
            blobheight = str2double(vmu{1}{blobdiminds(2)}(heightloc+1:end));
            
            %% open and read blobmap.raw file
            fid = fopen([dirBrain dirName1 fname_blobmap],'r');
            blobmap = fread(fid);
            fclose(fid);
            
            %reshape blobmap.raw according to dimensions from .vmu
            blobimg = reshape(blobmap,blobwidth,blobheight);
            
            blobimg_aligned = imresize(fliplr(imrotate(blobimg>0, -90)),2);
            
            
            %% parse physical/pixel sizes out of .vmu file
            isPixelWidth =  strfind(vmu{1},'PixelWidth');
            PixelWidthDims = find(~(cellfun('isempty',isPixelWidth)));
            PixelWidthLoc = strfind(vmu{1}{PixelWidthDims(1)},'=');
            PixelWidth = str2double(vmu{1}{PixelWidthDims(1)}(PixelWidthLoc+1:end));
            
            isPixelHeight =  strfind(vmu{1},'PixelHeight');
            PixelHeightDims = find(~(cellfun('isempty',isPixelHeight)));
            PixelHeightLoc = strfind(vmu{1}{PixelHeightDims(1)},'=');
            PixelHeight = str2double(vmu{1}{PixelHeightDims(1)}(PixelHeightLoc+1:end));
            
            isPhysicalWidth = strfind(vmu{1},'PhysicalWidth');
            PhysicalWidthDims = find(~(cellfun('isempty',isPhysicalWidth)));
            PhysicalWidthLoc = strfind(vmu{1}{PhysicalWidthDims(1)},'=');
            PhysicalWidth = str2double(vmu{1}{PhysicalWidthDims(1)}(PhysicalWidthLoc+1:end));
            
            isPhysicalHeight = strfind(vmu{1},'PhysicalHeight');
            PhysicalHeightDims = find(~(cellfun('isempty',isPhysicalHeight)));
            PhysicalHeightLoc = strfind(vmu{1}{PhysicalHeightDims(1)},'=');
            PhysicalHeight = str2double(vmu{1}{PhysicalHeightDims(1)}(PhysicalHeightLoc+1:end));
            
            isPhysicalMacroWidth = strfind(vmu{1},'PhysicalMacroWidth');
            PhysicalMacroWidthDims = find(~(cellfun('isempty',isPhysicalMacroWidth)));
            PhysicalMacroWidthLoc = strfind(vmu{1}{PhysicalMacroWidthDims(1)},'=');
            PhysicalMacroWidth = str2double(vmu{1}{PhysicalMacroWidthDims(1)}(PhysicalMacroWidthLoc+1:end));
            
            isPhysicalMacroHeight = strfind(vmu{1},'PhysicalMacroHeight');
            PhysicalMacroHeightDims = find(~(cellfun('isempty',isPhysicalMacroHeight)));
            PhysicalMacroHeightLoc = strfind(vmu{1}{PhysicalMacroHeightDims(1)},'=');
            PhysicalMacroHeight = str2double(vmu{1}{PhysicalMacroHeightDims(1)}(PhysicalMacroHeightLoc+1:end));
            
            PixelMacroWidth = size(macro,2);
            PixelMacroHeight = size(macro,1);
            
            %% parse centre offsets sizes out of .vmu file
            
            isXoffset =  strfind(vmu{1},'XOffsetFromSlideCentre');
            XoffsetDims = find(~(cellfun('isempty',isXoffset)));
            XoffsetLoc = strfind(vmu{1}{XoffsetDims(1)},'=');
            XoffsetFromSlideCentre = str2double(vmu{1}{XoffsetDims(1)}(XoffsetLoc+1:end));
            
            isYoffset =  strfind(vmu{1},'YOffsetFromSlideCentre');
            YoffsetDims = find(~(cellfun('isempty',isYoffset)));
            YoffsetLoc = strfind(vmu{1}{YoffsetDims(1)},'=');
            YoffsetFromSlideCentre = str2double(vmu{1}{YoffsetDims(1)}(YoffsetLoc+1:end));
            
            %% Read Map scale from VMU
            isMapScale =  strfind(vmu{1},'MapScale');
            mapScaleDims = find(~(cellfun('isempty',isMapScale)));
            mapScaleLoc = strfind(vmu{1}{mapScaleDims(1)},'=');
            mapScale = str2double(vmu{1}{mapScaleDims(1)}(mapScaleLoc+1:end));
            
            
            %% Calculate correspondence between Macro and NGR image
            
            macroPixelResX = (PhysicalMacroWidth/PixelMacroWidth);
            macroPixelResY = (PhysicalMacroHeight/PixelMacroHeight);
            
            ngrPixelResX = (PhysicalWidth/PixelWidth);
            ngrPixelResY = (PhysicalHeight/PixelHeight);
            mapPixelResX = ngrPixelResX * mapScale;
            mapPixelResY = ngrPixelResY * mapScale;
            
            samplingRatioNGR2macroX = macroPixelResX/ngrPixelResX;
            samplingRatioNGR2macroY = macroPixelResY/ngrPixelResY;
            samplingRatioMap2macroX = macroPixelResX/mapPixelResX;
            samplingRatioMap2macroY = macroPixelResY/mapPixelResY;
            
            
            
            macroCenterX = PixelMacroWidth/2;
            macroCenterY = PixelMacroHeight/2;
            ngrCenterX = PixelWidth/2;
            ngrCenterY = PixelHeight/2;
            
            corrCentreNGRX = macroCenterX + (XoffsetFromSlideCentre/macroPixelResX);
            corrCentreNGRY = macroCenterY + (YoffsetFromSlideCentre/macroPixelResY);
            
            offsetX = corrCentreNGRX - (ngrCenterX/samplingRatioNGR2macroX);
            offsetY = corrCentreNGRY - (ngrCenterY/samplingRatioNGR2macroY);
            offsetXend = corrCentreNGRX + (ngrCenterX/samplingRatioNGR2macroX);
            offsetYend = corrCentreNGRY + (ngrCenterY/samplingRatioNGR2macroY);
            currImg = macro(round(offsetY):round(offsetYend), ...
                round(offsetX)+10: round(offsetXend)+10,:);
            
            
            %% Correction for Offset
            offsetX = round(offsetX) + 10;
            offsetY = round(offsetY) - 10;
            offsetXend = round(offsetXend) + 10;
            offsetYend = round(offsetYend) - 10;
            
            
            %% SanityCheck
            corrCenterXmap = (corrCentreNGRX - offsetX)*samplingRatioMap2macroX;
            corrCenterYmap = (corrCentreNGRY - offsetY)*samplingRatioMap2macroY;
            
            
            %% Region Properties of blobmap
            
            RP = regionprops(blobimg_aligned, 'BoundingBox', 'Area');
            
            clear RPM startX startY endX endY
            %% Get Crop Boxes now (in Macro)
            if typeCross == 'List'
                cntM = 1;
                for i = length(RP):-1:1
                    if RP(i).Area < 1000
                        RP(i) = [];
                    else
                        RPM(cntM) = RP(i);
                        RPM(cntM).BoundingBox(1) = RPM(cntM).BoundingBox(1) - 5;
                        RPM(cntM).BoundingBox(2) = RPM(cntM).BoundingBox(2) - 5;
                        RPM(cntM).BoundingBox(3) = RPM(cntM).BoundingBox(3) + 10;
                        RPM(cntM).BoundingBox(4) = RPM(cntM).BoundingBox(4) + 10;
                        
                        startX(cntM) = (RPM(cntM).BoundingBox(1));
                        startY(cntM) = (RPM(cntM).BoundingBox(2));
                        endX(cntM) = (RPM(cntM).BoundingBox(1) + RPM(cntM).BoundingBox(3));
                        endY(cntM) = (RPM(cntM).BoundingBox(2) + RPM(cntM).BoundingBox(4));
                        cntM = cntM + 1;
                    end
                end
            end
            
            offsetW = offsetXend - offsetX;
            offsetH = offsetYend - offsetY;
            
            
            cmdIP = '';
            cmdROI = '';
            brainName = secName(1:secfind(1)-1);
            %         brainName = strrep(brainName, '&', '\&');
            cmdIP = [cmdIP '$CMD -input "$INPUT_NGR_BASE_FOLDER/'];
            cmdIP = [cmdIP dirName1];
            cmdIP = [cmdIP fname_ngr '" -macroOffset "'];
            cmdIP = [cmdIP num2str(round(offsetX)) ',' num2str(round(offsetY)) ',' ];
            cmdIP = [cmdIP num2str(round(offsetW)) ',' num2str(round(offsetH)) '"'];
            
            if length(RPM)<=noOfSecs
                endCounter = length(RPM);
            else
                endCounter = noOfSecs;
            end
            
            %% Run for list value (# brains in the slide)
            switch noOfSecs
                case 1
                    disp("1 brain tissue on a slide / single row");
                    cmdROI = crop_1(endCounter, startX, startY, endX, endY, ...
                        offsetX, offsetY, offsetW, offsetH, RPM, ...
                        secName, secfind, ...
                        cmdROI, brainName, noOfSecs, noOfSlides);
                    
                    
                case 2
                    disp("2 brain tissues on a slide / single row");
                    % same as crop_marmoset.m
                    cmdROI = crop_2(endCounter, startX, startY, endX, endY, ...
                        offsetX, offsetY, offsetW, offsetH, RPM, ...
                        secName, secfind, ...
                        cmdROI, brainName, noOfSecs, noOfSlides);
                    
                    
                case 3
                    disp("3 brain tissues on a slide / single row");
                    % same as crop_mouse1.m
                    cmdROI = crop_3(endCounter, startX, startY, endX, endY, ...
                        offsetX, offsetY, offsetW, offsetH, RPM, ...
                        secName, secfind, ...
                        cmdROI, brainName, noOfSecs, noOfSlides);
                    
                    
                case 4
                    disp("4 brain tissues on a slide / single row");
                    % same as crop_sagittal.m
                    cmdROI = crop_4(endCounter, startX, startY, endX, endY, ...
                        offsetX, offsetY, offsetW, offsetH, RPM, ...
                        secName, secfind, ...
                        cmdROI, brainName, noOfSecs, noOfSlides);
                    
                otherwise
                    disp('Values can be between 1-4')
            end
            
            cmdROI = [cmdROI '\n'];
            fprintf(fidRun, [cmdIP cmdROI]);
        else
            disp("No matching slide info present in CSV")
        end
    catch
        continue
    end
    
    
end
fclose(fidRun);
end
