function cmdROI = crop_1(endCounter, startX, startY, endX, endY, ...
    offsetX, offsetY, offsetW, offsetH, RPM, ...
    secName, secfind, ...
    cmdROI, brainName, noOfSecs, noOfSlides)

for i = 1:endCounter
    startX(i) = max((startX(i)-offsetX)/offsetW,0);
    startY(i) = max((startY(i)-offsetY)/offsetH,0);
    endX(i) = min((endX(i)-offsetX)/offsetW,1);
    endY(i) = min((endY(i)-offsetY)/offsetH,1);
    if length(RPM)==noOfSecs
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