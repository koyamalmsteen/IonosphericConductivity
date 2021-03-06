; docformat = 'IDL'

;*
;
;Name:
;IUG_LOAD_IONOSPHERIC_COND_DIAGNOSTICS_1_07
;
;Purpose:
;
;Syntax:
;
;Keywords:
;
;Code:
;Yukinobu KOYAMA, 07/03/2012
;
;Modifications:
;
;Acknowledgment:
;
;Example:
; IDL> thm_init
; THEMIS> iug_load_ionospheric_cond_diagnostics_1_07
;-
pro iug_load_ionospheric_cond_diagnostics_1_07
  
;
  tmp_dir = '/tmp/'+string(iug_getpid(),format='(i0)')+'/'
  result_file_test = file_test(tmp_dir)
  if file_test(tmp_dir) eq 0 then begin
     file_mkdir, tmp_dir
  endif

  gamma_h=[314.991,355.503,396.034,436.545,477.057,522.041,562.552,603.044,648.028,688.519,733.503,773.994,818.958,859.45,904.414,944.885,989.849,1030.32,1075.28,1115.76,1160.7,1205.66,1246.14,1291.1,1331.55,1376.52,1421.46,1461.93,1506.88,1551.82,1596.76,1637.23,1682.18,1727.12,1767.57,1812.52,1857.46,1902.41,1942.86,1987.8,2032.75,2077.69,2122.63,2167.56,2208.01,2252.97,2293.41,2338.35,2383.29,2428.22,2468.67,2513.61,2558.56,2603.5,2648.43,2688.9,2733.82,2778.77,2823.71,2868.65,2913.58,2954.03,2998.95,3043.9,3088.82,3133.77,3178.71]

  expected_h=[2.17E-10,2.26E-10,2.38E-10,2.48E-10,2.58E-10,2.66E-10,2.77E-10,2.85E-10,2.94E-10,3.03E-10,3.12E-10,3.22E-10,3.28E-10,3.38E-10,3.45E-10,3.52E-10,3.59E-10,3.66E-10,3.74E-10,3.81E-10,3.85E-10,3.93E-10,4.01E-10,4.09E-10,4.13E-10,4.21E-10,4.25E-10,4.34E-10,4.38E-10,4.42E-10,4.47E-10,4.56E-10,4.60E-10,4.65E-10,4.69E-10,4.74E-10,4.78E-10,4.83E-10,4.88E-10,4.92E-10,4.97E-10,5.02E-10,5.07E-10,5.07E-10,5.12E-10,5.22E-10,5.22E-10,5.27E-10,5.32E-10,5.32E-10,5.37E-10,5.42E-10,5.47E-10,5.53E-10,5.52E-10,5.64E-10,5.63E-10,5.69E-10,5.74E-10,5.80E-10,5.80E-10,5.85E-10,5.85E-10,5.91E-10,5.90E-10,5.96E-10,6.02E-10]

  gamma_he=[315.888,356.399,396.931,437.442,477.953,522.937,563.429,603.94,648.924,689.416,734.399,774.891,819.855,860.346,905.31,950.294,990.766,1035.73,1076.18,1121.15,1161.62,1206.58,1251.52,1292,1336.94,1377.41,1422.38,1467.32,1507.77,1552.74,1597.68,1642.62,1683.08,1728.02,1772.96,1813.44,1858.38,1903.32,1948.27,1988.72,2033.66,2078.59,2123.53,2168.5,2208.95,2253.87,2294.32,2334.77,2379.7,2424.66,2465.11,2510.04,2550.49,2595.43,2635.89,2680.81,2725.75,2770.7,2815.64,2856.09,2901.02,2945.96,2990.91,3035.85,3080.79,3121.23,3166.17]

  expected_he=[3.44E-10,3.58E-10,3.77E-10,3.92E-10,4.08E-10,4.21E-10,4.34E-10,4.52E-10,4.65E-10,4.80E-10,4.94E-10,5.10E-10,5.20E-10,5.36E-10,5.47E-10,5.63E-10,5.75E-10,5.86E-10,5.92E-10,6.04E-10,6.16E-10,6.28E-10,6.34E-10,6.47E-10,6.54E-10,6.67E-10,6.80E-10,6.87E-10,6.94E-10,7.07E-10,7.14E-10,7.21E-10,7.28E-10,7.35E-10,7.43E-10,7.58E-10,7.65E-10,7.72E-10,7.80E-10,7.88E-10,7.95E-10,7.95E-10,8.03E-10,8.19E-10,8.27E-10,8.26E-10,8.35E-10,8.43E-10,8.42E-10,8.59E-10,8.68E-10,8.67E-10,8.76E-10,8.84E-10,8.93E-10,8.92E-10,9.01E-10,9.10E-10,9.19E-10,9.28E-10,9.27E-10,9.36E-10,9.45E-10,9.55E-10,9.64E-10,9.64E-10,9.73E-10]

  gamma_n2=[311.874,352.405,392.916,433.448,473.959,514.45,559.454,599.946,640.457,685.421,725.913,770.877,811.368,856.332,896.824,941.788,982.259,1027.2,1067.67,1112.62,1157.58,1198.05,1243.02,1287.96,1328.43,1373.38,1418.32,1458.79,1503.74,1548.68,1589.15,1634.1,1679.04,1719.49,1764.44,1809.38,1854.33,1899.27,1935.23,1980.17,2025.12,2070.06,2114.98,2155.44,2200.38,2245.32,2290.27,2335.21,2380.14,2420.59,2465.53,2510.48,2555.42,2595.87,2640.82,2685.74,2726.19,2771.14,2816.06,2861,2905.95,2946.4,2991.32,3036.27,3081.19,3126.12,3171.06]

  expected_n2=[4.39E-10,4.62E-10,4.81E-10,5.06E-10,5.27E-10,5.43E-10,5.66E-10,5.83E-10,6.07E-10,6.19E-10,6.38E-10,6.51E-10,6.71E-10,6.85E-10,7.06E-10,7.20E-10,7.34E-10,7.41E-10,7.56E-10,7.64E-10,7.79E-10,7.95E-10,8.11E-10,8.19E-10,8.35E-10,8.43E-10,8.52E-10,8.69E-10,8.77E-10,8.86E-10,9.04E-10,9.12E-10,9.21E-10,9.30E-10,9.39E-10,9.49E-10,9.58E-10,9.67E-10,9.77E-10,9.86E-10,9.96E-10,1.01E-09,1.00E-09,1.01E-09,1.02E-09,1.03E-09,1.04E-09,1.05E-09,1.05E-09,1.06E-09,1.08E-09,1.09E-09,1.10E-09,1.11E-09,1.12E-09,1.12E-09,1.13E-09,1.14E-09,1.14E-09,1.15E-09,1.16E-09,1.17E-09,1.17E-09,1.18E-09,1.18E-09,1.18E-09,1.19E-09]

  gamma_n=[300,400,500,600,700,800,900,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900,2000,2100,2200,2300,2400,2500,2600,2700,2800,2900,3000,3100,3200]

;  expected_n is not shown in the "Aeronomy"

  gamma_o2=[315.001,355.513,396.044,436.555,477.067,522.051,562.562,603.054,648.037,688.509,733.493,773.965,818.928,859.42,904.384,944.856,989.819,1030.29,1075.26,1120.22,1160.69,1205.63,1246.11,1291.07,1336.01,1376.49,1421.43,1466.37,1506.85,1551.81,1596.75,1637.21,1682.15,1727.09,1772.04,1812.49,1857.43,1902.38,1947.32,1992.27,2032.72,2077.66,2122.58,2167.53,2212.47,2252.92,2297.87,2342.81,2387.74,2432.68,2477.61,2518.06,2563,2607.92,2652.87,2697.81,2738.24,2783.19,2828.11,2868.56,2913.49,2958.43,3003.38,3048.3,3093.24,3138.17,3178.62]

  expected_o2=[2.18E-09,2.27E-09,2.39E-09,2.49E-09,2.59E-09,2.67E-09,2.78E-09,2.87E-09,2.96E-09,3.01E-09,3.11E-09,3.17E-09,3.23E-09,3.33E-09,3.40E-09,3.47E-09,3.54E-09,3.61E-09,3.68E-09,3.76E-09,3.83E-09,3.87E-09,3.95E-09,4.03E-09,4.07E-09,4.15E-09,4.19E-09,4.23E-09,4.31E-09,4.40E-09,4.44E-09,4.49E-09,4.53E-09,4.57E-09,4.62E-09,4.66E-09,4.71E-09,4.76E-09,4.80E-09,4.85E-09,4.90E-09,4.94E-09,4.94E-09,4.99E-09,5.04E-09,5.09E-09,5.14E-09,5.19E-09,5.19E-09,5.24E-09,5.23E-09,5.28E-09,5.34E-09,5.33E-09,5.39E-09,5.44E-09,5.44E-09,5.49E-09,5.49E-09,5.54E-09,5.54E-09,5.59E-09,5.64E-09,5.64E-09,5.70E-09,5.69E-09,5.75E-09]

  gamma_o=[312.71,353.222,393.733,438.717,479.228,519.72,564.704,605.195,650.179,690.671,735.635,780.599,821.09,866.054,906.526,951.49,996.454,1036.93,1081.87,1122.34,1167.28,1212.23,1252.7,1297.64,1338.1,1383.06,1428.02,1468.48,1513.42,1558.36,1603.31,1643.76,1688.7,1733.65,1774.12,1819.06,1864.01,1908.95,1949.4,1994.35,2039.29,2084.24,2124.69,2169.63,2214.59,2259.54,2299.99,2344.93,2389.88,2434.82,2479.75,2520.2,2565.14,2610.07,2655.01,2699.93,2744.88,2789.8,2834.73,2879.65,2920.1,2965.03,3009.95,3054.9,3099.82,3140.27,3185.19]

  expected_o=[6.75E-10,7.03E-10,7.32E-10,7.54E-10,7.85E-10,8.09E-10,8.34E-10,8.59E-10,8.86E-10,9.13E-10,9.31E-10,9.50E-10,9.79E-10,9.99E-10,1.02E-09,1.04E-09,1.06E-09,1.08E-09,1.09E-09,1.11E-09,1.13E-09,1.14E-09,1.16E-09,1.17E-09,1.18E-09,1.21E-09,1.23E-09,1.24E-09,1.25E-09,1.27E-09,1.28E-09,1.29E-09,1.30E-09,1.32E-09,1.34E-09,1.36E-09,1.37E-09,1.38E-09,1.40E-09,1.41E-09,1.42E-09,1.44E-09,1.45E-09,1.47E-09,1.49E-09,1.51E-09,1.52E-09,1.54E-09,1.55E-09,1.57E-09,1.57E-09,1.58E-09,1.60E-09,1.60E-09,1.61E-09,1.61E-09,1.63E-09,1.63E-09,1.63E-09,1.63E-09,1.64E-09,1.64E-09,1.64E-09,1.66E-09,1.66E-09,1.67E-09,1.67E-09]
;
  actual_h  = fltarr(n_elements(gamma_h))        ; H
  actual_he = fltarr(n_elements(gamma_he))       ; He
  actual_n2 = fltarr(n_elements(gamma_n2))       ; N2
  actual_n  = fltarr(n_elements(gamma_n))        ; N
  actual_o2 = fltarr(n_elements(gamma_o2))       ; O2
  actual_o  = fltarr(n_elements(gamma_o))        ; O
;
  for i=0L,n_elements(gamma_h)-1 do begin
     actual_h[i] = (1.9E-12 *sqrt(gamma_h[i])*(14.4-1.17*alog10(gamma_h[i]))^2.)/2.
  endfor

  for i=0L,n_elements(gamma_he)-1 do begin
     actual_he[i] = (9.7E-13 *sqrt(gamma_he[i])*(11.6-1.05*alog10(gamma_he[i]))^2.)/2.
  endfor

  for i=0L,n_elements(gamma_n2)-1 do begin
     actual_n2[i] = (3.7E-13 *sqrt(gamma_n2[i])*(14.3-0.96*alog10(gamma_n2[i]))^2.)/2.
  endfor

  for i=0L,n_elements(gamma_n)-1 do begin
     actual_n[i] = (5.2E-13 *sqrt(gamma_n[i])*(10.4-0.64*alog10(gamma_n[i]))^2.)/2.
  endfor

  for i=0L,n_elements(gamma_o2)-1 do begin
     actual_o2[i] = (3.4E-13 *sqrt(gamma_o2[i])*(10.6-0.76*alog10(gamma_o2[i]))^2.)/2.
  endfor

  for i=0L,n_elements(gamma_o)-1 do begin
     actual_o[i] = (4.8E-13 *sqrt(gamma_o[i])*(10.6-0.67*alog10(gamma_o[i]))^2.)/2.
  endfor
;
  set_plot,'ps'
  device,filename = tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07.eps', /color, /encapsulated

  plot,gamma_o2[*],actual_h[*],xtitle="TEMPERATURES (Ti+Tn) K",ytitle="COLLISION FREQUENCY RATE COEFFICIENT (cm^3 Hz)",xrange=[300,3300],yrange=[1E-10,1E-8],/ylog,linestyle=0,color=0,title="Charge exchange collision frequencies for the atmospheric gases"

  oplot,gamma_o[*],actual_o[*],linestyle=0,color=0
  oplot,gamma_n2[*],actual_n2[*],linestyle=0,color=0
  oplot,gamma_he[*],actual_he[*],linestyle=0,color=0
  oplot,gamma_h[*],actual_o2[*],linestyle=0,color=0
  oplot,gamma_n[*],actual_n[*],linestyle=0,color=0
  xyouts,3300,5E-9,"H"
  xyouts,3300,1.8E-9,"He"
  xyouts,3300,1.3E-9,"N2"
  xyouts,3300,1E-9,"N"
  xyouts,3300,8E-10,"O"
  xyouts,3300,5E-10,"O2"
  xyouts,300,7E-9,"  solid line - Actual   by Koyama"
  xyouts,300,6E-9,"dotted line - Expected by Aeronomy pt. A"

  oplot,gamma_o2[*],expected_o2[*],linestyle=1,color=0
  oplot,gamma_o[*],expected_o[*],linestyle=1,color=0
  oplot,gamma_n2[*],expected_n2[*],linestyle=1,color=0
; expected_n is not shown in "Aeronomy".
  oplot,gamma_he[*],expected_he[*],linestyle=1,color=0
  oplot,gamma_h[*],expected_h[*],linestyle=1,color=0

  device,/close
  set_plot,'x'

  openw, unit, tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07_h.txt',/get_lun
  for i=0L,n_elements(gamma_o2)-1 do begin
     printf,unit,expected_o2[i],actual_h[i],(actual_h[i] -expected_o2[i]) $
            /expected_o2[i] * 100., format='(e10.2,e10.2,i4)'
  endfor
  free_lun,unit

  openw, unit, tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07_he.txt',/get_lun
  for i=0L,n_elements(gamma_o)-1 do begin
     printf,unit,expected_o[i],actual_he[i],(actual_he[i]-expected_o[i]) $
            /expected_o[i] * 100., format='(e10.2,e10.2,i4)'
  endfor
  free_lun,unit

  openw, unit, tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07_n2.txt',/get_lun
  for i=0L,n_elements(gamma_n2)-1 do begin
     printf,unit,expected_n2[i],actual_n2[i],(actual_n2[i]-expected_n2[i]) $
            /expected_n2[i] * 100., format='(e10.2,e10.2,i4)'
  endfor
  free_lun,unit
; expected_n is not shown in "Aeronomy".
  openw, unit, tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07_o.txt',/get_lun
  for i=0L,n_elements(gamma_he)-1 do begin
     printf,unit,expected_he[i],actual_o[i] ,(actual_o[i] -expected_he[i]) $
            /expected_he[i] * 100., format='(e10.2,e10.2,i4)'
  endfor
  free_lun,unit

  openw, unit, tmp_dir+'iug_load_ionospheric_cond_diagnostics_1_07_o2.txt',/get_lun
  for i=0L,n_elements(gamma_h)-1 do begin
     printf,unit,expected_h[i],actual_o2[i],(actual_o2[i]-expected_h[i]) $
            /expected_h[i] * 100., format='(e10.2,e10.2,i4)'
  endfor
  free_lun,unit

end
