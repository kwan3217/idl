;Implements the PDS sinusoidal map projection
;input/output
;  lat= - latitude of pixel in degrees, may be array
;  lon= - longitude of pixel in degrees, may be array
;output/input
;  line=   - vertical map grid coordinate of pixel, may be array
;  sample= - horizontal map grid coordinate of pixel, may be array
;input
;  /inverse          - set to transform line,sample to lat,lon. 
;                      default is lat,lon to line,sample
;  po_line=          - line projection offset from PSD header
;  po_sample=        - sample projection offset from PSD header
;  map_resolution=   - map resolution from PSD header
;  center_longitude= - center_longitude from PSD header
;
; Map Projection Overview
;=======================
;The FMAP (Magellan Full Resolution Radar Mosaic) is presented in a Sinusoidal Equal-Area map
;projection. In this projection, parallels of latitude are straight lines, with constant
;distances between equal latitude intervals. Lines of constant longitude on either side of the
;projection meridian are curved since longitude intervals decrease with the cosine of latitude
;to account for their convergence toward the poles. This projection offers a number of
;advantages for storing and managing global digital data; in particular, it is computationally
;simple, and data are stored in a compact form.
;The Sinusoidal Equal-Area projection is characterized by a projection longitude, which is the
;center meridian of the projection, and a scale, which is given in units of pixels/degree. The
;center latitude for all FMAP's is the equator. Each FMAP contains its own central meridian.
;The tiles that make up an FMAP all have the same central meridian as the FMAP.
;Lat/Lon, Line/Sample Transformations
;------------------------------------
;The transformation from latitude and longitude to line and sample is given by the following
;equations:
;line = INT(LINE_PROJECTION_OFFSET - lat*MAP_RESOLUTION + 1.0)
;sample = INT(SAMPLE_PROJECTION_OFFSET - (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat) + 1.0)
;Note that integral values of line and sample correspond to center of a pixel. Lat and lon
;are the latitude and longitude of a given spot on the surface.
;Line Projection Offset
;----------------------
;LINE_PROJECTION_OFFSET is the line number minus one on which the map projection origin
;occurs. The map projection origin is the intersection of the equator and the projection
;longitude. The value of LINE_PROJECTION_OFFSET is positive for images starting north of the
;equator and is negative for images starting south of the equator.
;Sample Projection Offset
;------------------------
;SAMPLE_PROJECTION_OFFSET is the nearest sample number to the left of the projection
;longitude. The value of SAMPLE_PROJECTION_OFFSET is positive for images starting to the
;west of the projection longitude and is negative for images starting to the east of the
;projection longitude.
;Center Longitude
;----------------
;CENTER_LONGITUDE is the value of the projection longitude,which is the longitude that
;passes through the center of the projection.
pro sinusoidal,lat=lat,lon=lon,line=line,sample=sample,inverse=inverse, $
      po_line=line_projection_offset,po_sample=sample_projection_offset,map_resolution=map_resolution, $
      center_longitude=center_longitude
  if ~keyword_set(inverse) then begin
    line = LINE_PROJECTION_OFFSET - lat*MAP_RESOLUTION + 1.0
    sample = SAMPLE_PROJECTION_OFFSET - (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat*!dpi/180d) + 1.0
  end else begin
    
;    line = LINE_PROJECTION_OFFSET - lat*MAP_RESOLUTION + 1.0
;    line-line_projection_offset=-lat*map_resolution+1.0
;    line_projection_offset-line=lat*map_resolution-1.0
;    line_projection_offset-line+1.0=lat*map_resolution
    lat=(line_projection_offset-line+1.0d)/map_resolution
    
;    sample = SAMPLE_PROJECTION_OFFSET - (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat) + 1.0
;    sample-sample_projection_offset= - (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat) + 1.0
;    sample_projection_offset-sample= (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat) - 1.0
;    sample_projection_offset-sample+1.0= (lon - CENTER_LONGITUDE)*MAP_RESOLUTION*cos(lat)
;    (sample_projection_offset-sample+1.0)/(MAP_RESOLUTION*cos(lat))= (lon - CENTER_LONGITUDE)
    lon=(sample_projection_offset-sample+1.0d)/(MAP_RESOLUTION*cos(lat*!dpi/180d))+center_longitude
  end
end

function load_dtm

end