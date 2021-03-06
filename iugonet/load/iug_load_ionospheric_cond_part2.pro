; docformat = 'IDL'

;+
;
;Name:
;IUG_LOAD_IONOSPHERIC_COND_PART2
;
;Purpose:
;
;
;Syntax:
;
;Keywords:
;
;
;Code:
;Yukinobu KOYAMA, 9/17/2011.
;
;Modifications:
;Yukinobu KOYAMA, 01/10/2011.
;Yukinobu KOYAMA, 01/04/2012.
;
;Acknowledgment:
;
;EXAMPLE:
; IDL> thm_init
; THEMIS> set_plot,'ps'
; THEMIS> device,filename='iug_ionospheric_cond.ps'
; THEMIS>
; THEMIS> station = iug_abb2coordinate('kak')
; THEMIS> print,station
; THEMIS> HEIGHT_BOTTOM=100
; THEMIS> HEIGHT_TOP=400
; THEMIS> HEIGHT_STEP=10
; THEMIS> iug_load_ionospheric_cond, height_bottom=height_bottom, $
;         height_top=height_top,;height_step=height_step,glat=station.glat,
;glon=station.glon,yyyy=2000,mmdd=130,ltut=0,time=12,result=result
; THEMIS>
; THEMIS> plot, result[1,*], result[0,*], xtitle="Conductivity !9s!30 (S/m)", 
;         ytitle="Height (km)", xrange=[0,1], yrange=[HEIGHT_BOTTOM,HEIGHT_TOP], /xlog
; THEMIS> plot, result[2,*], result[0,*], xtitle="Conductivity !9s!31 (S/m)",
;         ytitle="Height (km)", xrange=[0,1], yrange=[HEIGHT_BOTTOM,HEIGHT_TOP], /xlog
; THEMIS> plot, result[3,*], result[0,*], xtitle="Conductivity !9s!32 (S/m)",
;         ytitle="Height (km)", xrange=[0,1], yrange=[HEIGHT_BOTTOM,HEIGHT_TOP], /xlog
; THEMIS>
; THEMIS> set_plot,'x'
; THEMIS>
; THEMIS> print,format='(i4,e10.3,e10.3,e10.3)',result;
;
; iug_load_ionospheric_cond_part2, height_bottom=100, height_top=400, 
; height_step=10, glat=0, glon=0, yyyy=2000, mmdd=101, ltut=0,
; time=12, result=result
;-

pro iug_load_ionospheric_cond_part2, height_bottom=height_bottom, height_top=height_top, height_step=height_step, $
                                     glat=glat, glon=glon, yyyy=yyyy, mmdd=mmdd, ltut=ltut, time=time, result=result

  algorithm=2
; validate height_bottom
  if height_bottom lt 80 then begin
     dprint,"Satisfy this constraint 'height_bottom >= 80'."
;     dprint,"This procedure don't consider the cluster ion's influence under the altitude of 100km."
     return 
  endif
; validate height_top
  if height_top gt 2000 then begin
     dprint,"Specify height_top < 2000(km)."
     return 
  endif
; validate glat
  if glat lt -90 and glat gt 90 then begin
     dprint,"Specify glat in -90 to 90."
     return 
  endif
; validate glon
  if glon lt -180 and glon gt 180 then begin
     dprint,"Specify glon in -180 to 180."
     return 
  endif
; validate yyyy
  if yyyy lt 1958 and yyyy ge 2013 then begin
     dprint,"Specify yyyy in 1958 to 2012."
     return 
  endif
; validate mmdd
  if mmdd lt 101 and mmdd gt 1231 then begin
     dprint,"Specify mmdd correctly."
     return 
  endif
; validate ltut
  if ltut ne 0 and ltut ne 1 then begin
     dprint,"Specify ltut correctly."
     dprint,"   0:lt, 1:ut"
     return 
  endif
; validate time
  if time lt 0 and time gt 24 then begin
     dprint,"Specify time in 0 to 24."
     return 
  endif

  if height_top ne height_bottom then begin
     num_height = (height_top-height_bottom)/height_step+1
  endif else begin
     num_height = 1
  endelse 
  
  height_array=fltarr(num_height)

  for i=0L,num_height-1 do begin
     height_array(i)=height_bottom+height_step*i
  endfor

;
  tmp_dir = '/tmp/'+string(iug_getpid(),format='(i0)')+'/'
  result_file_test = file_test(tmp_dir)
  if file_test(tmp_dir) eq 0 then begin
     file_mkdir, tmp_dir
  endif
;

; definition of physical constants 
  e_charge = 1.60217733E-19          ; (C)
  m_e = 9.1093817E-31                ; (kg)
  m_p = 1.6726231E-27                ; (kg)

; Calculation of IRI2012 model
  iug_load_iri2012_array, yyyy=yyyy, mmdd=mmdd, ltut=ltut, time=time, $
                          glat=glat, glon=glon, $
                          height_bottom=height_bottom, height_top=height_top, height_step=height_step, $
                          result=result_iri

;
; Calculation of NRLMSISE for getting composition of atmosphere
;
  iug_load_nrlmsise00, yyyy=yyyy, mmdd=mmdd, time=time, $
                       glat=glat, glon=glon, $
                       height_bottom=height_bottom,height_top=height_top, height_step=height_step, $
                       result=result_msis
;
; IGRF11
; 
  iug_load_igrf11_array, yyyy=yyyy, glat=glat, glon=glon, $
                         height_bottom=height_bottom, height_top=height_top, height_step=height_step, $
                         r_d=r_d, r_i=r_i, r_h=r_h,r_x=r_x,r_y=r_y,r_z=r_z,r_f=r_f
;
; Calculation based on Kenichi Maeda's equation
;
  result = fltarr(num_height,7)

  for i=0L,num_height-1 do begin
;;;
     height = height_bottom+height_step*i
     iug_create_query_ionospheric_cond, yyyy=yyyy, mmdd=mmdd, ltut=ltut, atime=time, $
                                        glat=glat, glon=glon, height=height, algorithm=algorithm
     spawn, 'sqlite3 ${UDASEXTRA_HOME}/iugonet/load/ionospheric_cond.db < '+tmp_dir+'ionospheric_cond.sql'
     query_result = file_info(tmp_dir+'ionospheric_cond.result')

     if query_result.size eq 0 then begin ; calculate by using model    
;;;
        re = result_iri[i,13]/300.
        nu_en_perp = iug_collision_freq2_en_perp(re,result_msis[i,4]*1.E6, $
                                                 result_msis[i,5]*1.E6,result_msis[i,3]*1.E6)
        nu_en_para = iug_collision_freq2_en_para(re,result_msis[i,4]*1.E6, $
                                                 result_msis[i,5]*1.E6,result_msis[i,3]*1.E6)
        nu_ei_para = iug_collision_freq2_ei_para(result_iri[i,9]*1.E6,result_iri[i,13])
        ri = (result_iri[i,11]+result_iri[i,12])/1000.
        nu_in = iug_collision_freq2_in(ri,result_msis[i,4]*1.E6, $
                                       result_msis[i,5]*1.E6, result_msis[i,3]*1.E6, result_iri[i,19]*1.E6, $
                                       result_iri[i,18]*1.E6, result_iri[i,14]*1.E6)

; result[0,*]: simga_0, parallel conductivity
; result[1,*]: sigma_1, pedarsen conductivity
; result[2,*]: sigma_2, hole conductivity
; result[3,*]: simga_xx, parallel conductivity
; result[4,*]: sigma_yy, pedarsen conductivity
; result[5,*]: sigma_xy, hole conductivity
; result[6,*]: height
        
        num_o_p = result_iri[i,9]*1.E6*result_iri[i,14] /100.      ; O+
        num_n_p = result_iri[i,9]*1.E6*result_iri[i,15] /100.      ; N+
        num_h_p = result_iri[i,9]*1.E6*result_iri[i,16] /100.      ; H+
        num_he_p = result_iri[i,9]*1.E6*result_iri[i,17] /100.     ; He+
        num_o2_p = result_iri[i,9]*1.E6*result_iri[i,18]/100.      ; O2+
        num_no_p = result_iri[i,9]*1.E6*result_iri[i,19]/100.      ; NO+
        num_cluster_p = result_iri[i,9]*1.E6*result_iri[i,20]/100. ; Cluster+
        num_ions = result_iri[i,17]*1.E6                           ; Ne/m-3

        m_i = ( 16.* num_o_p $
                + 14.* num_n_p $
                + 1. * num_h_p $
                + 4. * num_he_p $
                + 32.* num_o2_p $
                + 30.* num_no_p $
                + 82.* num_cluster_p) / num_ions * m_p

        omega_e = (e_charge*r_f[i]*1.E-9)/(m_e)
        omega_i = (e_charge*r_f[i]*1.E-9)/(m_i)

        result[i,0] = e_charge^2. * ( result_iri(i,9) * 1.E6 ) $
                      /( m_e * (nu_en_para+nu_ei_para) )
        result[i,1] = ( result_iri(i,9)*1.E6*e_charge/(r_f[i]*1.E-9) ) $
                      * ( (nu_in*omega_i)/(nu_in^2. +omega_i^2.)  $
                          + (nu_en_perp*omega_e)/(nu_en_perp^2. + omega_e^2.) )
        result[i,2] = ( result_iri(i,9)*1.E6*e_charge/(r_f[i]*1.E-9) ) $
                      * ( (omega_e^2.)/(nu_en_perp^2. +omega_e^2. ) $
                          + (omega_i^2.)/(nu_in^2. + omega_i^2. ) )
; 2 dimensional conductivity
        result[i,3] = ( result[i,0]*result[i,1] ) $
                      / ( result[i,1]*cos(!dpi/180.*r_i[i])^2. $
                          + result[i,0]*sin(!dpi/180.*r_i[i])^2. )
        result[i,4]=( result[i,0]*result[i,1]*sin(!dpi/180.*r_i[i])^2. $
                      + ( result[i,1]^2. + result[i,2]^2.) $
                      *cos(!dpi/180.*r_i[i])^2. ) $
                    /( result[i,1]*cos(!dpi/180.*r_i[i])^2. $
                       + result[i,0]*sin(!dpi/180.*r_i[i])^2. )
        result[i,5]=( result[i,0]*result[i,2]*sin(!dpi/180.*r_i[i])) $
                    /( result[i,1]*cos(!dpi/180.*r_i[i])^2. $
                       + result[i,0]*sin(!dpi/180.*r_i[i])^2. )
        result[i,6] = height_array[i]

       iug_insert_ionospheric_cond, sigma_0=result[i,0], sigma_1=result[i,1], sigma_2=result[i,2], $
                                    sigma_xx=result[i,3], sigma_yy=result[i,4], sigma_xy=result[i,5], $
                                    height=result[i,6], glat=glat, glon=glon, $
                                    yyyy=yyyy, mmdd=mmdd, ltut=ltut, atime=time, algorithm=algorithm

     endif else begin           ; retrieve from DB
        openr, unit, tmp_dir+'ionospheric_cond.result', /get_lun
        array = fltarr(7)
        readf, unit, array

        result[i,0] = array(0)
        result[i,1] = array(1)
        result[i,2] = array(2)
        result[i,3] = array(3)
        result[i,4] = array(4)
        result[i,5] = array(5)
        result[i,6] = array(6)

        free_lun, unit

     endelse
  endfor

end
