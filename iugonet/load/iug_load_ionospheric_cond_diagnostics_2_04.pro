; docformat = 'IDL'

;+
;
;Name:
;IUG_LOAD_IONOSPHERIC_COND_DIAGNOSTICS_2_04
;
;Purpose:
;
;Syntax:
;
;Keywords:
;
;Code:
;Yukinobu KOYAMA, 05/01/2012
;
;Modifications:
;
;Acknowledgment:
;
;Example:
; IDL> thm_init
; THEMIS> iug_load_ionospheric_cond_diagnostics_2_04
;-

pro iug_load_ionospheric_cond_diagnostics_2_04

;
  tmp_dir = '/tmp/'+string(iug_getpid(),format='(i0)')+'/'
  result_file_test = file_test(tmp_dir)
  if file_test(tmp_dir) eq 0 then begin
     file_mkdir, tmp_dir
  endif
;

  height_bottom=100
  height_top=400
  height_step=10
  glat=44.6 ; this parameter is from figure 9.2.3 of Richmond's textbook
  glon=2.2  ; this parameter is from figure 9.2.3 of Richmond's textbook
  ltut=0
  yyyy=1985 ; Make a choice the year which is small solar activity.
  time=12
  mmdd=321  ; this parameter is from figure 9.2.3 of Richmond's textbook

  if height_top ne height_bottom then begin
     num_height = (height_top-height_bottom)/height_step+1
  endif else begin
     num_height = 1
  endelse

  height_array=fltarr(num_height)

  for i=0L,num_height-1 do begin
     height_array(i)=height_bottom+height_step*i
  endfor

; definition of physical constants 
  e_charge = 1.60217733E-19          ; (C)                                    
  m_e = 9.1093817E-31                ; (kg)                                  
  m_p = 1.6726231E-27                ; (kg)  

; Calculation of IRI2012 model
  iug_load_iri2012_array, yyyy=yyyy, mmdd=mmdd, ltut=ltut, time=time, glat=glat, glon=glon, height_bottom=height_bottom, height_top=height_top, height_step=height_step, result=result_iri

;
; Calculation of NRLMSISE for getting composition of atmosphere
;
  iug_load_nrlmsise00, yyyy=yyyy, mmdd=mmdd, height_bottom=height_bottom,height_top=height_top, height_step=height_step,time=time,glat=glat,glon=glon,result=result_msis

;
; IGRF11
; 
  iug_load_igrf11_array, height_bottom=height_bottom, height_top=height_top, height_step=height_step, yyyy=yyyy, glat=glat, glon=glon, r_d=r_d, r_i=r_i, r_h=r_h,r_x=r_x,r_y=r_y,r_z=r_z,r_f=r_f

;
; Calculation based on Kenichi Maeda's equation
;
  result = fltarr(6,num_height)

  for i=0L,num_height-1 do begin
     r_e=result_iri[i,13]/300.
     nu_en_perp=iug_collision_freq2_en_perp(r_e,result_msis[i,4]*1E6,result_msis[i,5]*1E6,result_msis[i,3]*1E6)
     nu_en_para=iug_collision_freq2_en_para(r_e,result_msis[i,4]*1E6,result_msis[i,5]*1E6,result_msis[i,3]*1E6)
     nu_ei_para=iug_collision_freq2_ei_para(result_iri[i,9]*1E6,result_iri[i,13])
     nu_e_para=nu_en_para+nu_ei_para
     nu_e=nu_e_para

     r_i=(result_iri[i,11]+result_iri[i,12])/1000.
     nu_i=iug_collision_freq2_in(r_i,result_msis[i,4]*1.E6,result_msis[i,5]*1E6,result_msis[i,3]*1.E6,result_iri[i,19]*1.E6,result_iri[i,18]*1.E6,result_iri[i,14]*1.E6)
     
; "O+=",result_iri[i,14]                                                        
; "N+=",result_iri[i,15]                                                        
; "H+=",result_iri[i,16]                                                        
; "He+=",result_iri[i,17]                                                       
; "O2+=",result_iri[i,18]                                                      
; "NO+=",result_iri[i,19]                                                      
; "Clust+=",result_iri[i,20]
     num_o_p = result_iri[i,9]*1.E6*result_iri[i,14] /100.       ; O+
     num_n_p = result_iri[i,9]*1.E6*result_iri[i,15] /100.       ; N+
     num_h_p = result_iri[i,9]*1.E6*result_iri[i,16] /100.       ; H+
     num_he_p= result_iri[i,9]*1.E6*result_iri[i,17] /100.       ; He+       
     num_o2_p= result_iri[i,9]*1.E6*result_iri[i,18]/100.       ; O2+      
     num_no_p= result_iri[i,9]*1.E6*result_iri[i,19]/100.       ; NO+        
     num_cluster_p = result_iri[i,9]*1.E6*result_iri[i,20]/100. ; Cluster+   
     num_ions= result_iri[i,9]*1.E6 ; Ne/m-3     

     m_i = ( 16.* num_o_p $
           + 14.* num_n_p $
           + 1. * num_h_p $
           + 4. * num_he_p $
           + 32.* num_o2_p $
           + 30.* num_no_p $
           + 82.* num_cluster_p) / num_ions * m_p

     omega_e=(e_charge*r_f[i]*1.E-9)/(m_e)
     omega_i=(e_charge*r_f[i]*1.E-9)/(m_i)
     kappa=(omega_e*omega_i)/(nu_e*nu_i)
     result[0,i]=height_array[i]
     result[1,i]=omega_i
     result[2,i]=omega_e
     result[3,i]=nu_i
     result[4,i]=nu_en_perp
     result[5,i]=nu_e_para
  endfor

  set_plot, 'ps'
  device, filename=tmp_dir+'iug_load_ionospheric_cond_diagnostics_2_04.eps', /color, /encapsulated

  plot,result[1,*],result[0,*],xtitle="Collision Frequencies and Gyrofrequencies (Hz)",ytitle="Altitude (km)",yrange=[0,400],xrange=[1E-2,1E8],/xlog,linestyle=0,color=0, title="GLAT=44.6, GLON=2.2, Solar-minimum conditions (Sa=75) on March 21"
  oplot, result[2,*],result[0,*],linestyle=0,color=6
  oplot, result[3,*],result[0,*],linestyle=0,color=2
  oplot, result[4,*],result[0,*],linestyle=0,color=1
  oplot, result[5,*],result[0,*],linestyle=0,color=3
  xyouts,5E2,350,"omega_i",color=0
  xyouts,2E5,350,"omega_e",color=6
  xyouts,2E-1,270,"nu_in",color=2
  xyouts,4E0,200,"nu_en_perp",color=1
  xyouts,9E-2,350,"nu_en_para+nu_ei_para",color=3
; digitized data plot

; omega_i
  a=[136.985,137.34,138.606,142.08,142.582,143.457,144.099,145.47,148.234,153.205,164.32,191.095,191.432,196.392,201.599,201.955,202.24,203.003,220.41,220.851,224.716,227,229.456,229.834,230.294,230.782,231.326,232.171,233.815,240.297,247.336,248.298]

  b=[129.032,112.334,53.1309,93.3586,70.5882,31.1195,2.27704,141.176,19.7343,6.83112,154.839,180.645,169.26,204.175,235.294,223.909,214.801,190.512,259.583,246.679,334.725,269.45,400,389.374,376.471,362.808,347.628,324.099,278.558,302.087,315.75,290.702]

; omega_e
  c=[6.54E+06,6.56E+06,6.58E+06,6.59E+06,6.60E+06,6.83E+06,6.89E+06,7.05E+06,7.07E+06,7.09E+06,7.12E+06,7.13E+06,7.17E+06,7.18E+06,7.21E+06,7.61E+06,7.68E+06,7.70E+06,7.71E+06,7.75E+06,7.77E+06,7.78E+06,7.80E+06,7.97E+06,8.06E+06,8.07E+06,8.09E+06,8.36E+06,8.38E+06]

  d=[398.482,381.025,362.049,349.905,337.002,324.858,267.173,311.954,296.774,281.594,255.028,239.089,208.729,197.343,175.332,222.391,164.706,148.008,135.104,106.262,91.8406,79.6964,63.7571,120.683,51.6129,41.7457,30.3605,15.1803,3.03605]

; nu_in
  e=[0.0124563,0.0145577,0.0170157,0.0198886,0.0225372,0.0263424,0.0307865,0.0359845,0.0420602,0.0476615,0.0557021,0.0671561,0.0784948,0.0917371,0.107226,0.125315,0.151084,0.176573,0.212856,0.248795,0.299919,0.350517,0.422544,0.509432,0.614114,0.740221,0.892328,1.07569,1.29658,1.56301,1.94327,2.34231,2.91251,3.62108,4.50204,5.7735,7.17726,9.20425,11.4408,14.6702,18.8089,24.8742,31.8916,42.1708,55.7632,73.7365,94.5165,124.966,155.277,205.301,271.441,358.846,489.328,646.893,882.114,1166.16,1541.85,2102.49,2779.17,3790.16,5010.61,6624.05,9031.6,11942.6,16283.2,21529,28461.5,37626.2,51313.7,67836.9,89691.3,118572,156772,207253,274021,373616,494038,673678,890605,1.18E+06,1.61E+06,2.12E+06,2.81E+06,3.71E+06,5.06E+06,1.00E+07,1.32E+07,1.75E+07,2.39E+07,3.16E+07,4.17E+07,5.69E+07,7.52E+07]
  f=[382.51,376.426,369.582,362.738,355.894,349.049,342.966,336.122,329.278,322.433,316.35,309.506,302.662,296.578,289.734,283.65,276.806,270.722,264.639,257.795,251.711,245.627,239.544,232.7,226.616,221.293,215.209,209.125,203.802,197.719,192.395,187.072,180.989,175.665,170.342,165.019,160.456,155.133,151.331,146.768,142.966,139.163,135.361,132.319,129.278,126.236,123.954,121.673,120.152,117.871,115.589,114.068,112.548,111.027,109.506,107.985,105.703,104.183,103.422,101.141,99.6198,98.0989,97.3384,94.2966,93.5361,91.2548,89.7338,88.2129,85.9316,84.4106,82.1293,80.6084,78.327,76.8061,74.5247,73.7643,70.7224,69.2015,67.6806,64.6388,62.3574,61.597,58.5551,57.0342,54.7529,50.1901,47.9087,46.3878,44.1065,42.5856,40.3042,38.0228,35.7414]

;  nu_en_perp
  g=[0.699186,0.842861,0.985054,1.11663,1.34609,1.72848,2.08367,2.51184,2.84702,3.43205,4.01105,4.68938,5.65299,6.81382,7.72306,9.30896,11.2218,13.5326,16.8249,20.2822,22.9859,28.5781,35.5349,41.5396,51.6455,64.2101,77.4319,96.27,135.647,163.501,314.479,390.942,429.385,533.785,663.648,906.241,1091.69,1795.18,2300.82,2949.22,4150.63,5486.5,7482.36,12293.9,16250.6,22159.6,30227.9,41209.5,54479.1,69840.4,89501.3,122045,200455,265003,339685,508448,672092,1.18E+06,1.51E+06,1.93E+06,3.37E+06,4.46E+06,5.89E+06,8.55E+06,1.13E+07,1.54E+07,2.04E+07,2.78E+07,3.68E+07,4.86E+07,6.63E+07,8.76E+07]
  h=[389.354,383.27,377.186,368.061,361.977,348.289,342.205,336.122,327.757,321.673,315.589,307.224,301.141,295.817,287.452,282.129,276.046,267.681,262.357,256.274,248.669,243.346,237.262,229.658,224.335,219.011,210.646,205.323,192.395,187.072,165.779,161.217,155.894,151.331,146.008,135.361,133.84,123.954,122.433,120.152,114.829,114.068,111.787,107.224,106.464,104.943,101.141,101.141,99.6198,96.5779,95.8175,94.2966,92.0152,90.4943,88.2129,85.1711,84.4106,79.0875,79.0875,77.5665,74.5247,73.0038,70.7224,67.6806,66.1597,63.8783,60.8365,59.3156,57.0342,54.7529,53.2319,50.9506]

; nu_e_para
  ii=[48.7423,51.9077,55.2658,58.848,62.6698,66.732,73.2854,73.3457,83.1035,85.7797,88.563,97.2717,103.577,106.925,113.829,121.221,129.094,129.17,141.888,146.492,151.227,161.01,166.215,171.608,177.301,182.753,194.759,194.919,195.08,207.749,221.58,228.742,228.931,236.414,236.581,244.229,244.401,260.304,268.75,286.136,304.683,355.999,471.408,533.935,684.888,800.147,934.912,1126.49,1315.92,1635.48,2032.65,2301.71,2860,3446.07,4416.7,5320.51,6611.79,8215.5,10208.2,13495.3,16768.6,19581.3,25889.6,30232.3,37565.3,48146,57984.8,72049.1,89524.9,114741,142571,182728,213404,273480,329444,396813,508581,651829,785217,975558,1.21E+06,1.51E+06,1.87E+06,2.40E+06,2.98E+06,3.70E+06,4.75E+06,5.90E+06,7.56E+06,9.39E+06,1.13E+07,1.41E+07,1.69E+07,2.17E+07,2.61E+07,3.05E+07,3.68E+07,4.30E+07,5.02E+07,5.86E+07,6.63E+07,7.51E+07,8.77E+07]
  jj=[397.723,391.651,387.097,381.784,375.712,370.398,365.844,360.531,354.459,349.905,343.833,338.52,333.207,327.894,324.099,318.027,311.954,308.159,302.087,296.015,290.702,286.148,280.835,274.763,264.137,268.691,258.065,252.751,247.438,241.366,225.427,220.114,214.801,207.211,202.657,197.343,192.789,185.958,179.886,175.332,170.019,165.465,153.321,149.526,142.694,138.899,134.345,131.309,128.273,125.237,122.201,119.924,118.406,115.37,113.852,112.334,110.057,108.539,107.021,105.503,103.985,103.226,100.949,100.19,98.6717,97.1537,97.1537,95.6357,94.1176,92.5996,91.0816,89.5636,88.0455,87.2865,85.7685,85.0095,83.4915,81.9734,80.4554,79.6964,78.1784,76.6603,75.9013,74.3833,72.8653,71.3472,69.8292,69.0702,67.5522,65.2751,62.9981,61.4801,60.7211,59.203,57.685,56.167,55.408,53.8899,53.1309,51.6129,50.8539,49.3359,49.3359]

  oplot,a,b,linestyle=1,color=0
  oplot,c,d,linestyle=1,color=6
  oplot,e,f,linestyle=1,color=2
  oplot,g,h,linestyle=1,color=1
  oplot,ii,jj,linestyle=1,color=3

  device, /close
  set_plot, 'x'

end
