%% Cropping script gen for all brains
% Samik Banerjee Aug 18, 2022
% crop_Brains(nz, brainID, prefix, spec)
% nz --> NanoZomer Number (1/2/3)
% Usage: crop_Brains(1, 'MD915', 'MD', 'Mouse1')
% Run crop_logs.m after this to get the duplicate and missing sections
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function crop_Brains(nz, brainID, prefix, spec)
    %     nz = 1;
    %     brainID = 'PMD3897&3898';
    %     prefix = 'PMD'
    %     spec = 'Mouse2';
    %% 3 sections/slide; 1 brain/slide
    if strcmp(spec, 'Mouse1')        
        crop_mouse_single(nz, brainID, prefix);
    end
    %% 6 sections/slide; 2 brains/slide
    if strcmp(spec, 'Mouse2')
        crop_mouse_double(nz, brainID, prefix);
    end
    %% 2 sections/slide; 1 brain/slide
    if strcmp(spec, 'Marmoset')
        crop_marmoset(nz, brainID, prefix);
    end
    %% 4 sections/slide; 1 brain/slide
    if strcmp(spec, 'Sagittal')
        crop_sagital_quad(nz, brainID, prefix);
    end
    
end