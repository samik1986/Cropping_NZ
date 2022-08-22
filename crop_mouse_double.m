%% Cropping script gen for dual coronal brains with 6 sections/slide
% Samik Banerjee Aug 18, 2022
% crop_mouse_double(<int>nz, <string>brainID, <string>prefix)
% nz --> NanoZomer Number (1/2/3)
% Usage: crop_mouse_double(3, 'PMD3679&3680', 'PMD')
% OP: in cwd .
%     PMD3679&3680.sh
% Slide Position : smallerIDnum=bottomRow ; higherIDnum=topRow
%                  PMD3679 at the bottom & PMD3680 at the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function crop_mouse_double(nz, brainID, prefix)
% prefix = 'PMD';
% nz = 3;
% brainID = 'PMD3679&3680';
addpath(genpath('natsortfiles'));
%% Read Directory
dirBrain = ['/nfs/data/qc/qcdisk005/NanoZoomer_' num2str(nz) '/' brainID '/']
species = 'Mouse';
direcBrain = natsortfiles(dir(fullfile(dirBrain, [brainID '*'])));

dirBrainB = strrep(dirBrain, '&', '\&');
cmdPre = '';
fidRun = fopen([brainID '.sh'], 'w');
cmdPre = [cmdPre '#! /bin/bash\n'];
cmdPre = [cmdPre 'INPUT_NGR_BASE_FOLDER='];
fprintf(fidRun, cmdPre);
fprintf(fidRun, '%s', dirBrainB);
fprintf(fidRun, '\nOUTPUT_JP2_BASE_FOLDER=/nfs/data/qc/qcdisk006/mba_converted_imaging_data\n');
fprintf(fidRun, 'CMD="./cropNGR"\n');
% fprintf(fidRun, cmdPre);

%% Brain Locations smallerIDnum=bottomRow ; higherIDnum=topRow
brainCounter = strfind(brainID, '&');
% brainPreCounter = strfind(brainID, prefix);
brain1 = str2double(strrep(brainID(1:brainCounter-1), prefix, ''));
brain2 = str2double(brainID(brainCounter+1:end));
if brain1 > brain2
    brainUP = [prefix num2str(brain1)];
    brainDN = [prefix num2str(brain2)];
else
    brainUP = [prefix num2str(brain2)];
    brainDN = [prefix num2str(brain1)];
end

% brainID = strrep(brainID, '&', '\&');

for nD = 1 : length(direcBrain)
    try
        %% set file directory name
        dirName1 = direcBrain(nD).name
        if ~strcmp(dirName1(end),'/')
            dirName1 = [dirName1 '/'];
        end
        
        %% get directory of files .ngr file
        flist = dir(fullfile([dirBrain dirName1], '*.ngr'));
        
        %get name of .ngr file
        f_ind_ngr = 1;
        fname_ngr = flist(f_ind_ngr).name;
        
        %% get directory of files .vmu file
        flist = dir(fullfile([dirBrain dirName1], '*.vmu'));
        
        %get name of .vmu file
        f_ind_vmu = 1;
        fname_vmu = flist(f_ind_vmu).name;
        %% get name of blobmap.raw file
        flist = dir(fullfile([dirBrain dirName1], '*.raw'));
        
        %get name of blobmap.raw file
        f_ind_blob = 1;
        fname_blobmap = flist(f_ind_blob).name;
        
        %% get name of macro image (.jpg) file
        flist = dir(fullfile([dirBrain dirName1], '*.jpg'));
        
        %get name of macro image (.jpg) file
        f_ind_macro = 1;
        fname_macro = flist(f_ind_macro).name;
        
        %% get directory of files Calibration
        flist = dir(fullfile([dirBrain dirName1], '*_calibration.txt'));
        
        %get name of _calibration.txt file
        f_ind_cal = 1;
        fname_cal = flist(f_ind_cal).name;
        
        %% Read NGR Map
        flist = dir(fullfile([dirBrain dirName1], '*_map.ngr'));
        f_ind_mapNGR = 1;
        fname_mapNGR = flist(f_ind_mapNGR).name;
        
        % read in macro image (.jpg) file contents
        macro = imread([dirBrain dirName1 fname_macro]);
        
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
        
        % reshape blobmap.raw according to dimensions from .vmu
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
        
               
        %% open and read calibration file
        % % %         fid = fopen([dirBrain dirName1 fname_cal],'r');
        % % %         calib = textscan(fid,'%s');
        % % %         fclose(fid);
        
        % % %         %% parse calib text
        % % %         clear RPM startX startY endX endY barcodeSeps barcodeDimsString
        % % %         isbarcodeDims = strfind(calib{1},'roi.barcode.macro');
        % % %         barcodeDims = find(~(cellfun('isempty',isbarcodeDims)));
        % % %         barcodeDimStart = strfind(calib{1}{barcodeDims},'=');
        % % %         barcodeDimsString = calib{1}{barcodeDims}(barcodeDimStart+1:end);
        % % %         barcodeSeps = strsplit(barcodeDimsString, ',');
        % % %
        % % %
        % % %         %% Input Reading Complete......
        % % %         %% -----------------------------------------
        % % %
        % % %         %% read barcode and tissue ROI
        % % %
        % % %         offsetX = str2double(barcodeSeps{3}) - str2double(barcodeSeps{1}) + 1;
        % % %         offsetY = inf;
        % % %         offsetXend = 0;
        % % %         offsetYend = 0;
        % % %
        % % %         barcodeImg = macro(:, 1:offsetX-1,:);
        % % %         nobarcodeSlide = macro(:, offsetX:end,:);
        
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
        
        currImg = macro(round(offsetY)-5:round(offsetYend)-5, ...
            round(offsetX)+10: round(offsetXend)+10,:);
        
        
        %% Correction for Offset
        offsetX = round(offsetX) + 10;
        offsetY = round(offsetY) - 5;
        offsetXend = round(offsetXend) + 10;
        offsetYend = round(offsetYend) - 5;
        
        
        %% SanityCheck
        corrCenterXmap = (corrCentreNGRX - offsetX)*samplingRatioMap2macroX;
        corrCenterYmap = (corrCentreNGRY - offsetY)*samplingRatioMap2macroY;
        
        %% Region Properties of blobmap
        
        
        RP = regionprops(blobimg_aligned, 'BoundingBox', 'Area');
        
        clear RPM startX startY endX endY
      
        %% Get Crop Boxes now (in Macro)
        if species == 'Mouse'
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
        
        secName = strrep(dirName1, '/', '');
        secName = strrep(secName, 'MY', 'My');
        cmdIP = '';
        cmdROI = '';
        secfind = strfind(secName, ' ');
        brainName = secName(1:secfind(1)-1);
        %         brainName = strrep(brainName, '&', '\&');
        cmdIP = [cmdIP '$CMD -input "$INPUT_NGR_BASE_FOLDER/'];
        cmdIP = [cmdIP dirName1];
        cmdIP = [cmdIP fname_ngr '" -macroOffset "'];
        cmdIP = [cmdIP num2str(round(offsetX)) ',' num2str(round(offsetY)) ',' ];
        cmdIP = [cmdIP num2str(round(offsetW)) ',' num2str(round(offsetH)) '"'];
        %% Divide Top and Bottom row
        clear RPMU RPMD startXU startXD startYU startYD endXU endXD endYU endYD
        iU = 1;
        iD = 1;
        for i = 1:length(RPM)
            if startY(i) <= 175
                RPMU(iU) = RPM(i);
                startXU(iU) = startX(i);
                startYU(iU) = startY(i);
                endXU(iU) = endX(i);
                endYU(iU) = endY(i);
                iU = iU + 1;
            else
                RPMD(iD) = RPM(i);
                startXD(iD) = startX(i);
                startYD(iD) = startY(i);
                endXD(iD) = endX(i);
                endYD(iD) = endY(i);
                iD = iD + 1;
            end
        end
        
        
        %% Upper Row
        if length(RPMU)<=3
            endCounter = length(RPMU);
        else
            endCounter = 3;
        end
        
        for i = 1:endCounter
            startXU(i) = max((startXU(i)-offsetX)/offsetW,0);
            startYU(i) = max((startYU(i)-offsetY)/offsetH,0);
            endXU(i) = min((endXU(i)-offsetX)/offsetW,1);
            endYU(i) = min((endYU(i)-offsetY)/offsetH,1);
            if length(RPMU)<3
                if RPMU(i).BoundingBox(1)<900 && RPMU(i).BoundingBox(1)>=600
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+2;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainUP '_' num2str(2) ...
                        '_' secNum_ad{1}];
                end
                if RPMU(i).BoundingBox(1)<600 && RPMU(i).BoundingBox(1)>=300
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+3;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainUP '_' num2str(3) ...
                        '_' secNum_ad{1}];
                end
                if RPMU(i).BoundingBox(1) >= 900
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+1;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainUP '_' num2str(1) ...
                        '_' secNum_ad{1}];
                end
            else
                nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+i;
                secNum_ad = compose('%04d', nb);
                secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                    strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                    '-' secName(secfind(6)+1:end) '_' brainUP '_' num2str(i) ...
                    '_' secNum_ad{1}];
            end
            
            cmdROI = [cmdROI ' -roi "$OUTPUT_JP2_BASE_FOLDER/'];
            cmdROI = [cmdROI brainName '/' brainUP '/'];
            cmdROI = [cmdROI secNum];
            cmdROI = [cmdROI ','];
            cmdROI = [cmdROI num2str(startXU(i)) ','  num2str(endXU(i)) ','];
            cmdROI = [cmdROI num2str(startYU(i)) ','  num2str(endYU(i)) '"'];
        end
        
        %% Lower Row
        if length(RPMD)<=3
            endCounter = length(RPMD);
        else
            endCounter = 3;
        end
        for i = 1:endCounter
            startXD(i) = max((startXD(i)-offsetX)/offsetW,0);
            startYD(i) = max((startYD(i)-offsetY)/offsetH,0);
            endXD(i) = min((endXD(i)-offsetX)/offsetW,1);
            endYD(i) = min((endYD(i)-offsetY)/offsetH,1);
            if length(RPMD)<3
                if RPMD(i).BoundingBox(1)<900 && RPMD(i).BoundingBox(1)>=600
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+2;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainDN '_' num2str(2) ...
                        '_' secNum_ad{1}];
                end
                if RPMD(i).BoundingBox(1)<600 && RPMD(i).BoundingBox(1)>=300
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+3;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainDN '_' num2str(3) ...
                        '_' secNum_ad{1}];
                end
                if RPMD(i).BoundingBox(1) >= 900
                    nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+1;
                    secNum_ad = compose('%04d', nb);
                    secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                        strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                        '-' secName(secfind(6)+1:end) '_' brainDN '_' num2str(1) ...
                        '_' secNum_ad{1}];
                end
            else
                nb = ((str2num(secName(secfind(3)+1:secfind(4)-1))-1)*3)+i;
                secNum_ad = compose('%04d', nb);
                secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                    strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                    '-' secName(secfind(6)+1:end) '_' brainDN '_' num2str(i) ...
                    '_' secNum_ad{1}];
            end
            
            cmdROI = [cmdROI ' -roi "$OUTPUT_JP2_BASE_FOLDER/'];
            cmdROI = [cmdROI brainName '/' brainDN '/'];
            cmdROI = [cmdROI secNum];
            cmdROI = [cmdROI ','];
            cmdROI = [cmdROI num2str(startXD(i)) ','  num2str(endXD(i)) ','];
            cmdROI = [cmdROI num2str(startYD(i)) ','  num2str(endYD(i)) '"'];
        end
        %% Write out cmd ROI
        cmdROI = [cmdROI '\n'];
        fprintf(fidRun, [cmdIP cmdROI]);
    catch
        continue
    end
    
end

fclose(fidRun);
end