;
;	sd_parse_file
;
;	Separate out different instrument data into multiple files
;
;	Usage:
;		sd_parse_file, filename  [, /raw]
;
;		/raw option will just save the raw data packets without conversions
;
;	History:  T. Woods,  6/8/12, original file for reading CSCC SD Card June 2012
;

;
;	convert_hex_to_float()
;
;   procedure to convert hex array of IEEE 754 (32-bit) float bytes into number
;	(needed for VN100 data conversion)
;
function convert_hex_to_float, array, debug=debug
;debug=1
if (n_params() lt 1) then return, 0.0
if (n_elements(array) ne 8) then return, 0.0
bytearr = bytarr(4)
CHAR_A = (byte('A'))[0]
CHAR_F = (byte('F'))[0]
CHAR_Alower = (byte('a'))[0]
CHAR_Flower = (byte('f'))[0]
CHAR_ZERO = (byte('0'))[0]
CHAR_NINE = (byte('9'))[0]
; first convert 8 HEX values into 4 bytes, also reverse byte order
for k=0,6,2 do begin
  if (array[k] ge CHAR_A) and (array[k] le CHAR_F) then c1 = 10B + array[k] - CHAR_A $
  else if (array[k] ge CHAR_Alower) and (array[k] le CHAR_Flower) then c1 = 10B + array[k] - CHAR_Alower $
  else if (array[k] ge CHAR_ZERO) and (array[k] le CHAR_NINE) then c1 = array[k] - CHAR_ZERO $
  else c1 = 0B
  if (array[k+1] ge CHAR_A) and (array[k+1] le CHAR_F) then c2 = 10B + array[k+1] - CHAR_A $
  else if (array[k+1] ge CHAR_Alower) and (array[k+1] le CHAR_Flower) then c2 = 10B + array[k+1] - CHAR_Alower $
  else if (array[k+1] ge CHAR_ZERO) and (array[k+1] le CHAR_NINE) then c2 = array[k+1] - CHAR_ZERO $
  else c2 = 0B
  kk = 3 - k/2
  bytearr[kk] = ishft(c1,4) + c2
endfor
;  sign is in Bit 32 (MSB)
if (bytearr[0] ge '80'X) then begin
  sign=-1.0
end else begin
  sign = 1.0
end

;  exponent is in Bits 24-31  minus 127
exponent = (ishft(long(bytearr[0] and '7F'X),1) + ishft(long(bytearr[1] and '80'X),-7)) - 127.
;  mantissa is in Bits 1-23 as fraction (divide by 2^23) plus 1.0 (so 1.0 - 2 range)
mantissa = 1.0 + (ishft(long(bytearr[1] and '7F'X),16) + ishft(long(bytearr[2]),8) + $
		long(bytearr[3])) / (2.^23.)
if (exponent eq -127.) then mantissa -= 1.0	; special case for mantissa (so can have 0.0)
number = sign * (2.^exponent) * mantissa
if keyword_set(debug) then begin
    print, 'CONVERT_HEX_TO_FLOAT: Input=', string(array), ', ', array
    print, '    BYTES: ', bytearr, format='(A10,4Z4)'
    print, '    SIGN=', strtrim(sign,2), ', EXP=', strtrim(exponent,2), ', MAN=', strtrim(mantissa,2)
    print, '  FLOAT = ', strtrim(number,2)
     print, '  float(bytearr,0) = ',float(reverse(bytearr),0)  
    ; stop, 'STOPPED:  DEBUG ...'
endif
return, number
end

pro sd_parse_file2, filename, debug=debug, raw=raw

if n_params() lt 1 then begin
  filename='g:\RCKT0094.DAT'
  ;filename = dialog_pickfile( /READ, FILTER='*.DAT' )
endif

if (strlen(filename) lt 2) then begin
  print, 'SD_PARSE_FILE:  a  filename must be selected.'
  return
endif

if keyword_set(debug) then doDebug = debug else doDebug = 1

;
;	open the files (one file to read, two files to write)
;
on_ioerror, errexit
openr, lun, filename, /get_lun
on_ioerror, errclose3

vFilename = filename + '.VN100'
if keyword_set(raw) then vFilename += '_RAW'
openw, vlun, vFilename, /get_lun
if (doDebug ne 0) then print, 'VN100 data saved into ', vFilename
on_ioerror, errclose2
if keyword_set(raw) then begin
  printf, vlun, 'Time_GPS Sync  ID  Yaw     Pitch   Roll    Mag-X   Mag-Y   Mag-Z   Accel-X Accel-Y Accel-Z Gyro-X  Gyro-Y  Gryo-Z  CRC'
endif else begin
  printf, vlun, ' Time_GPS   Yaw     Pitch   Roll    Mag-X   Mag-Y   Mag-Z   Accel-X Accel-Y Accel-Z Gyro-X    Gyro-Y    Gryo-Z    Error'
endelse

xFilename = filename + '.X123'
if keyword_set(raw) then xFilename += '_RAW'
openw, xlun, xFilename, /get_lun
if (doDebug ne 0) then print, 'X123 data saved into ', xFilename
on_ioerror, errclose1

;
;	start reading the data and parse between CR-LF ending
;
;	first create data records for VN100 and Amptek X123
;
sync1 = (byte('>'))[0]
vsync = (byte('V'))[0]
xsync = (byte('S'))[0]

CHAR_CR = (byte('0D'X))[0]
CHAR_LF = (byte('0A'X))[0]

CHAR_ONE = (byte('1'))[0]
CHAR_F = (byte('F'))[0]

vreclen = 120L
vrecord = bytarr(vreclen)
;  VN100 data for register 240
;		yaw, pitch, roll in degrees
;		mag: magnetometer X, Y, Z in inertial space (unitless)
;		accel: accelerometer X, Y, Z in inertial space (m/s^2)
;		gyro: angular rate X, Y, Z in body space (rad/s)
;		error =0 if full record else record length (not full record)
;		time = GPS seconds from PIC18 MCU
vstruct = { vn100_struct, time: 0L, yaw: 0.0, pitch: 0.0, roll: 0.0, $
		mag: fltarr(3), accel: fltarr(3), gyro: fltarr(3), $
		error: 0L }
vdata = replicate(vstruct,1)
varray = replicate(vstruct,20000)
vcount = 0L

xreclen = 68L
xrecord = bytarr(xreclen)
xstruct = { x123_struct, status: bytarr(256L), spectrum: lonarr(256), error: 0L }
xdata = replicate(xstruct,1)
xcount = 0L

;
;	read full SD-Card file into byte array
;
sdstat = fstat(lun)
sdfilelen = sdstat.size
if (doDebug ne 0) then print, 'SD-Card File Size = ', sdfilelen, ' bytes.'
sdblock = bytarr(sdfilelen)
readu, lun, sdblock

;
;	parse SD-Card block of data for all VN100 records
;
k=10L
while k le (sdfilelen-110L) do begin
;for k=10L, (sdfilelen-110L) do begin
  if (sdblock[k] eq sync1) and (sdblock[k+1] eq vsync) then begin
      ; got VN100 record to process
      vdata.time=long(string(sdblock[k-9:k-1]))
      kend = k+2
      for j=k+2L,sdfilelen-110L do begin
        if (sdblock[j] eq CHAR_CR) and (sdblock[j+1] eq CHAR_LF) then break;
      endfor
      kend = j-1
      if keyword_set(raw) then begin
        ; save the RAW data record only
        printf, vlun, string(sdblock[k-9:kend])
        vcount += 1L
        if (doDebug ge 2) then print, 'VN100: ', strtrim(kend-k+11,2), ', ', $
      		vdata.time, '=',string(sdblock[k-9:k-1]), $
      		', ', string(sdblock[k+2:k+9]), ', ', $
      		string(sdblock[k+10:k+17]), '=', strtrim(convert_hex_to_float( sdblock[k+10:k+17] ),2)
      endif else if (sdblock[k+5] eq CHAR_ONE) and (sdblock[k+6] eq CHAR_F) then begin
        ; do conversion to float numbers, but only if have valid record
        if ((kend-k+11) lt 118) then begin
          vdata.error = (kend-k+11)
          ; do nothing - just drop the data
        endif else begin
          ; fill the vdata record and then print to VN100 file
          vdata.error = 0
          vdata.yaw = convert_hex_to_float(sdblock[k+10:k+17])
          vdata.pitch = convert_hex_to_float(sdblock[k+18:k+25])
          vdata.roll = convert_hex_to_float(sdblock[k+26:k+33])
          vdata.mag[0] = convert_hex_to_float(sdblock[k+34:k+41])
          vdata.mag[1] = convert_hex_to_float(sdblock[k+42:k+49])
          vdata.mag[2] = convert_hex_to_float(sdblock[k+50:k+57])
          vdata.accel[0] = convert_hex_to_float(sdblock[k+58:k+65])
          vdata.accel[1] = convert_hex_to_float(sdblock[k+66:k+73])
          vdata.accel[2] = convert_hex_to_float(sdblock[k+74:k+81])
          vdata.gyro[0] = convert_hex_to_float(sdblock[k+82:k+89])
          vdata.gyro[1] = convert_hex_to_float(sdblock[k+90:k+97])
          vdata.gyro[2] = convert_hex_to_float(sdblock[k+98:k+105])
          printf, vlun, vdata, format='(I10, 3F8.3, 3F8.4, 3F8.3, 3F10.6, I4)'
          varray[vcount]=vdata
          vcount += 1L
        endelse
      endif
      k = kend + 2
  endif
  k=k+1
endwhile
varray=varray[0:vcount-1]
;
;Plot
;

  status = DIALOG_MESSAGE( 'Would you like to plot?',/Question, TITLE='VN100 Data')
if (status EQ 'Yes') THEN BEGIN
  status1 = DIALOG_MESSAGE( 'Yaw, Pitch, Roll',/Question, TITLE='VN100 Data')
if(status1 EQ 'Yes')THEN BEGIN
    Pitch=plot(varray.time-630720021,xtitle='GPS Time (sec)',varray.pitch,ytitle='Angle (Degrees)',$
    SYMBOL='dot',COLOR='green',THICK=2,TITLE='Yaw, Pitch and Roll vs Time')
    Yaw=plot(varray.time-630720021,varray.yaw,OVERPLOT=1,SYMBOL='dot',COLOR='blue')
    Roll=plot(varray.time-630720021,varray.roll,OVERPLOT=1,SYMBOL='dot',COLOR='red')
    Pitch.name = 'Pitch'
    Yaw.name = 'Yaw'
    Roll.name = 'Roll'
    YPR_lgd=legend(target=[Pitch,Yaw,Roll],position=[4500,60],/data)
;else(status1 EQ 'No')THEN BEGIN
endif
  status2 = DIALOG_MESSAGE( 'Accelerometer',/Question, TITLE='VN100 Data')
if(status2 EQ 'Yes')THEN BEGIN
    AccelX=plot(varray.time-630720021,xtitle='GPS Time (sec)',varray.accel[0],ytitle='Acceleration (m/s!E2!N)',$
    SYMBOL='dot',COLOR='green',THICK=2,TITLE='Acceleration in X,Y,Z vs Time')
    AccelY=plot(varray.time-630720021,varray.accel[1],OVERPLOT=1,SYMBOL='dot',COLOR='blue')
    AccelZ=plot(varray.time-630720021,varray.accel[2],OVERPLOT=1,SYMBOL='dot',COLOR='red')
    AccelX.name = 'Accel X'
    AccelY.name = 'Accel Y'
    AccelZ.name = 'Accel Z'
    Accel_lgd=legend(target=[AccelX,AccelY,AccelZ],position=[4500,1],/data)
endif
  status3 = DIALOG_MESSAGE( 'Magnetometer',/Question, TITLE='VN100 Data')
if(status3 EQ 'Yes')THEN BEGIN
    MagX=plot(varray.time-630720021,xtitle='GPS Time (sec)',varray.mag[0],ytitle='Magnetic Field',$
    SYMBOL='dot',COLOR='green',THICK=2,TITLE='Magnetic Field in X,Y,Z vs Time')
    MagY=plot(varray.time-630720021,varray.mag[1],OVERPLOT=1,SYMBOL='dot',COLOR='blue')
    MagZ=plot(varray.time-630720021,varray.mag[2],OVERPLOT=1,SYMBOL='dot',COLOR='red')
    MagX.name = 'Mag X'
    MagY.name = 'Mag Y'
    MagZ.name = 'Mag Z'
   Mag_lgd=legend(target=[MagX,MagY,MagZ],position=[4500,5],/data)
endif
endif
;plot,varray.time,varray.pitch
;oplot,varray.time,varray.yaw
;oplot,varray.time,varray.roll

;
;Colors Defined
;


;
;	parse SD-Card block of data for X123 Status and Spectrum records
;		(still be done +++++++)
;

errclose1:
if (doDebug ne 0) then print, 'X123 records written = ', strtrim(xcount,2)
close, xlun
free_lun, xlun
errclose2:
if (doDebug ne 0) then print, 'VN100 records written = ', strtrim(vcount,2)
close, vlun
free_lun, vlun
errclose3:
close, lun
free_lun, lun

errexit:
return
end
   
;plot,vdata.yaw,vdata.time,psym=7,xrange[630720021,630724655],yrange[0.000,180.000],/xstyle,/ystyle,$
 ;  xtitle='GPS Time (Seconds)',$
  ; ytitle='Yaw (Degrees)',$
   ;title='Yaw angle vs Time'