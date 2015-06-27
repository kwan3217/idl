pro plot_SensorLog,infn,hasdate=hasdate
  swindow,1
  if strpos(infn,'.sav') ge 0 then begin
    restore,infn
  end else begin
    if keyword_set(hasdate) then begin
      a={ $
        VERSION: 1.0000000e+000, $
        DATASTART: 0L, $
        DELIMITER: 44B, $
        MISSINGVALUE: !values.f_nan, $
        COMMENTSYMBOL: '', $
        FIELDCOUNT: 6L, $
        FIELDTYPES: [15L,7L,3L,4L,4L,4L], $
        FIELDNAMES: ['Timestamp','Date','SensorType','SensorX','SensorY','SensorZ'], $
        FIELDLOCATIONS: [0L,15L,28L,30L,40L,49L], $
        FIELDGROUPS: [0L,1L,2L,3L,4L,5L] $
      }
    end else begin
      a={ $
        VERSION: 1.0000000e+000, $
        DATASTART: 0L, $
        DELIMITER: 44B, $
        MISSINGVALUE: !values.f_nan, $
        COMMENTSYMBOL: '', $
        FIELDCOUNT: 5L, $
        FIELDTYPES: [15L,3L,4L,4L,4L], $
        FIELDNAMES: ['Timestamp','SensorType','SensorX','SensorY','SensorZ'], $
        FIELDLOCATIONS: [0L,17L,19L,29L,39L], $
        FIELDGROUPS: [0L,1L,2L,3L,4L] $
      }
    end
    data=read_ascii(infn,template=a)
  end
  wa=where(data.sensortype eq 1)
  wg=where(data.sensortype eq 4)
  ta=data.timestamp[wa]-data.timestamp[0]
  tg=data.timestamp[wg]-data.timestamp[0]
  sax=data.sensorx[wa]
  sconst=10
  ssax=smooth(sax,sconst)
  say=data.sensory[wa]
  ssay=smooth(say,sconst)
  saz=data.sensorz[wa]
  ssaz=smooth(saz,sconst)
  sgx=data.sensorx[wg]
  ssgx=smooth(sgx,sconst)
  sgy=data.sensory[wg]
  ssgy=smooth(sgy,sconst)
  sgz=data.sensorz[wg]
  ssgz=smooth(sgz,sconst)
  sat=sqrt(sax^2+say^2+saz^2)
  ssat=smooth(sat,sconst)
  sgt=sqrt(sgx^2+sgy^2+sgz^2)
  ssgt=smooth(sgt,sconst)
  yarange=[-max(ssat),max(ssat)]/9.80665
  ygrange=[-max(ssgt),max(ssgt)]*!radeg
  for i=0,0 do begin
    !p.multi=[0,1,2]
    xrange=i*5+[0,5]
    plot,ta/60d9,sat/9.80665,yrange=yarange,xrange=xrange,/nodata
    oplot,ta/60d9,sat/9.80665,color='808080'x
    oplot,ta/60d9,sax/9.80665,color='000080'x
    oplot,ta/60d9,say/9.80665,color='008000'x
    oplot,ta/60d9,saz/9.80665,color='800000'x
    oplot,ta/60d9,ssat/9.80665,color='ffffff'x
    oplot,ta/60d9,ssax/9.80665,color='0000ff'x
    oplot,ta/60d9,ssay/9.80665,color='00ff00'x
    oplot,ta/60d9,ssaz/9.80665,color='ff0000'x
    plot,tg/60d9,sgt*!radeg,yrange=ygrange,xrange=[i*5,(i+1)*5],/nodata
    oplot,tg/60d9,sgt*!radeg,color='808080'x
    oplot,tg/60d9,sgx*!radeg,color='000080'x
    oplot,tg/60d9,sgy*!radeg,color='008000'x
    oplot,tg/60d9,sgz*!radeg,color='800000'x
    oplot,tg/60d9,ssgt*!radeg,color='ffffff'x
    oplot,tg/60d9,ssgx*!radeg,color='0000ff'x
    oplot,tg/60d9,ssgy*!radeg,color='00ff00'x
    oplot,tg/60d9,ssgz*!radeg,color='ff0000'x
    wait,5
  end
  stop
end