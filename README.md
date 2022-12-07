# Cropping codes

  Entry : crop_brains.m

  Individual codes:

      For 3 sections/slide; 1 brain/slide --> crop_mouse_single.m
      
      For 6 sections/slide; 2 brains/slide --> crop_mouse_double.m
      
      For 2 sections/slide; 1 brain/slide --> crop_marmoset.m
      
      For 4 sections/slide; 1 brain/slide --> crop_sagital_quad.m
      
      For CSV basesd Heterogeneous # sections in the slides (1-4 sections / slide) --> crop_list.m
      
      For CSV basesd Rescanned sections in the slides (1-4 sections / slide) --> crop_list_rescan.m

  Cropping Logs: crop_logs.m --> to find Missing or Duplicate sections
  
  Read NGRS in Matlab to image file: ngr2tif.m --> fully modified for any NGR file.
  
  ```SlideInfo.csv``` Format for ```crop_list.m```:
 
      | SlideNo	| NoOfTissues |	Tracer |
       
      
  ```SlideInfoReScan.csv``` Format for ```crop_list_rescan.m```:
  
      | SlideNo | NoOfTissues | Tracer | StartSection |
