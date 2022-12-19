# Cropping codes

  Entry : crop_brains.m

  Individual codes:

      Mouse1: For 3 sections/slide; 1 brain/slide --> crop_mouse_single.m
      
      Mouse2: For 6 sections/slide; 2 brains/slide --> crop_mouse_double.m
      
      Mouse2i: For 6 sections/slide with inverted Clubbed Name; 2 brains/slide --> crop_mouse_double_inv.m
      
      Marmoset: For 2 sections/slide; 1 brain/slide --> crop_marmoset.m
      
      Sagittal: For 4 sections/slide; 1 brain/slide --> crop_sagital_quad.m
      
      List: For CSV based Heterogeneous # sections in the slides (1-4 sections / slide) --> crop_list.m
      
      ReScan: For CSV based Rescanned sections in the slides (1-4 sections / slide) --> crop_list_rescan.m

  
  Cropping Logs: crop_logs.m --> to find Missing or Duplicate sections
  
  Read NGRS in Matlab to image file: ngr2tif.m --> fully modified for any NGR file.
  
  
  ```SlideInfo.csv``` format for ```crop_list.m```:
 
      | SlideNo	| NoOfTissues |	Tracer |
       
      
  
  ```SlideInfoReScan.csv``` format for ```crop_list_rescan.m```:
  
      | SlideNo | NoOfTissues | Tracer | StartSection |
