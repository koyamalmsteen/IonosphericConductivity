; docformat = 'IDL'

;+
;
;Name:
;IUG_CREATE_QUERY_IGRF11
;
;Purpose:
;To create query for iug_igrf11.db
;
;Keywords:
;
;Code:
;Yukinobu KOYAMA, 10/01/2013
;
;Acknowledgment:
;
;EXAMPLE:
;  iug_create_query_igrf11,1,2000,0,0,100
;-
pro iug_create_query_igrf11,coordinate_system,yyyy,glat,glon,height
  openw,unit,'/tmp/iug_igrf11_query.sql',/get_lun ; create query file
  printf,unit,'select * from iug_igrf11 where coordinate_system=',strtrim(string(coordinate_system),1),' and yyyy=',strtrim(string(yyyy),1),' and glat=',strtrim(string(glat),1),' and glon=',strtrim(string(glon),1),' and height=',strtrim(string(height),1),";"
  free_lun, unit
end