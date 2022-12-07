function cmdROI = crop_3(endCounter, startX, startY, endX, endY, ...
    offsetX, offsetY, offsetW, offsetH, RPM, ...
    secName, secfind, ...
    cmdROI, brainName, noOfSecs, noOfSlides)

for i = 1:endCounter
    startX(i) = max((startX(i)-offsetX)/offsetW,0);
    startY(i) = max((startY(i)-offsetY)/offsetH,0);
    endX(i) = min((endX(i)-offsetX)/offsetW,1);
    endY(i) = min((endY(i)-offsetY)/offsetH,1);
    if length(RPM)<noOfSecs
        if RPM(i).BoundingBox(1)<900 && RPM(i).BoundingBox(1)>=600
            nb = noOfSlides+2;
            secNum_ad = compose('%04d', nb);
            secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                '-' secName(secfind(6)+1:end) '_' brainName '_' num2str(2) ...
                '_' secNum_ad{1}];
        end
        if RPM(i).BoundingBox(1)<600 && RPM(i).BoundingBox(1)>=300
            nb = noOfSlides+3;
            secNum_ad = compose('%04d', nb);
            secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                '-' secName(secfind(6)+1:end) '_' brainName '_' num2str(3) ...
                '_' secNum_ad{1}];
        end
        if RPM(i).BoundingBox(1) >= 900
            nb = noOfSlides+1;
            secNum_ad = compose('%04d', nb);
            secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
                strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
                '-' secName(secfind(6)+1:end) '_' brainName '_' num2str(1) ...
                '_' secNum_ad{1}];
        end
    else
        nb = noOfSlides+i;
        secNum_ad = compose('%04d', nb);
        secNum = [strrep(secName(1:secfind(5)-1), ' ', '') ...
            strrep(secName(secfind(5)+1:secfind(6)-1), '-', '.') ...
            '-' secName(secfind(6)+1:end) '_' brainName '_' num2str(i) ...
            '_' secNum_ad{1}];
    end
    
    cmdROI = [cmdROI ' -roi "$OUTPUT_JP2_BASE_FOLDER/'];
    cmdROI = [cmdROI brainName '/' brainName '/'];
    cmdROI = [cmdROI secNum];
    cmdROI = [cmdROI ','];
    cmdROI = [cmdROI num2str(startX(i)) ','  num2str(endX(i)) ','];
    cmdROI = [cmdROI num2str(startY(i)) ','  num2str(endY(i)) '"'];
end