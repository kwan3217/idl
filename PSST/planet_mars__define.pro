function planet_mars::init,lframe_i
  super=self->planet::init(499,lframe_i)
  if ~super then return,super
  
  tau=2d*!dpi ; tau manifesto

  t_aeroid=create_struct('VERSION'         , 1.0, $
                         'TEMPLATENAME'    ,  '', $
                         'ENDIAN'          ,'big', $
                         'FIELDCOUNT'      ,1, $
                         'TYPECODES'       ,2, $
                         'NAMES'           ,'_', $
                         'OFFSETS'         ,'>0', $
                         'NUMDIMS'         ,2, $
                         'DIMENSIONS'      ,transpose(['5760','2880','','','','','','']), $
                         'REVERSEFLAGS'    ,transpose([0,1,0,0,0,0,0,0]), $
                         'ABSOLUTEFLAGS'   ,0, $
                         'RETURNFLAGS'     ,[1], $
                         'VERIFYFLAGS'     ,[0], $
                         'DIMALLOWFORMULAS',  1, $
                         'OFFSETALLOWFORMULAS',   1, $
                         'VERIFYVALS',    '')
  t_topo  =t_aeroid
  t_topo.dimensions[0]='11520'
  t_topo.dimensions[1]='5760'
  a=read_binary('../icy/data/generic_tables/mega90n000eb.img',template=t_aeroid)
  a=(temporary(a))._
  self.aeroid=ptr_new(temporary(a))
  t=read_binary('../icy/data/generic_tables/megt90n000fb.img',template=t_topo  )
  t=(temporary(t))._
  self.topo  =ptr_new(temporary(t))
    
  self.Htable=ptr_new(1000d*[ $ Table is in km, final array is in m
  -10d, -9, -8, -7, -6, -5, -4, -3, -2, -1, $
     0,  1,  2,  3,  4,  5,  6,  7,  8,  9, $
    10, 11, 12, 13, 14, 15, 16, 17, 18, 19, $
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29, $
    30, 31, 32, 33, 34, 35, 36, 37, 38, 39, $
    40, 41, 42, 43, 44, 45, 46, 47, 48, 49, $
    50, 51, 52, 53, 54, 55, 56, 57, 58, 59, $
    60, 61, 62, 63, 64, 65, 66, 67, 68, 69, $
    70, 71, 72, 73, 74, 75, 76, 77, 78, 79, $
    80, 81, 82, 83, 84, 85, 86, 87, 88, 89, $
    90, 91, 92, 93, 94, 95, 96, 97, 98, 99, $
   100,101,102,103,104,105,106,107,108,109, $
   110,111,112,113,114,115,116,117,118,119, $
   120,121,122,123,124,125,126,127,128,129, $
               130,140,150,160,170,180,190, $
   200,210,220,230,240,250,260,270,280,290, $
   300,310,320,330,340,350,360])
  self.Ttable=ptr_new([ $ ;table and final array are in K
214.0d,214.0,214.0,214.0,214.0,214.0,214.0,214.0,214.0,214.0, $   //-10
214.0,213.9,213.8,213.6,213.4,212.9,212.4,210.8,209.2,207.1,  $   //  0
205.0,203.2,201.4,199.6,197.8,196.2,194.6,193.0,191.5,189.9,  $   // 10
188.3,186.8,185.2,183.8,182.5,181.2,180.0,178.7,177.5,176.2,  $   // 20
175.0,173.7,172.5,171.2,170.0,168.7,167.5,166.1,164.8,163.6,  $   // 30
162.4,161.2,160.0,159.0,158.0,157.0,156.0,155.0,154.1,153.1,  $   // 40
152.2,151.2,150.3,149.5,148.7,147.9,147.2,146.4,145.7,144.9,  $   // 50
144.2,143.6,143.0,142.5,142.0,141.5,141.0,140.5,140.0,139.7,  $   // 60
139.5,139.2,139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,  $   // 70
139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,  $   // 80
139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,139.0,  $   // 90
139.0,140.0,141.1,142.1,143.2,144.2,145.2,146.3,147.3,148.4,  $   //100
149.4,150.4,151.5,152.5,153.5,154.6,155.6,156.6,157.7,158.7,  $   //110
159.7,160.8,161.8,162.8,163.8,164.9,165.9,166.9,167.9,169.0,  $   //120
                  170.0,245.1,288.6,314.0,328.8,337.5,342.6,  $   //130
345.6,346.4,347.3,348.1,348.9,349.7,349.8,349.8,349.9,349.9,  $   //200
350.0,350.0,350.0,350.0,350.0,350.0,350.0])                   ;   //300
  self.Ptable=ptr_new(alog([ $ Table values are in Pa, final array is in ln(Pa)
1.57d+03,1.44E+03,1.31E+03,1.20E+03,1.09E+03,1.00E+03,9.16E+02,8.36E+02,7.63E+02,6.96E+02, $//-10
6.36E+02,5.80E+02,5.30E+02,4.84E+02,4.41E+02,4.03E+02,3.68E+02,3.35E+02,3.06E+02,2.79E+02, $//  0
2.54E+02,2.31E+02,2.09E+02,1.90E+02,1.73E+02,1.56E+02,1.42E+02,1.28E+02,1.16E+02,1.05E+02, $// 10
9.47E+01,8.54E+01,7.70E+01,6.94E+01,6.25E+01,5.62E+01,5.05E+01,4.54E+01,4.07E+01,3.66E+01, $// 20
3.28E+01,2.94E+01,2.63E+01,2.35E+01,2.10E+01,1.88E+01,1.68E+01,1.49E+01,1.33E+01,1.19E+01, $// 30
1.06E+01,9.38E+00,8.33E+00,7.39E+00,6.56E+00,5.81E+00,5.15E+00,4.56E+00,4.03E+00,3.56E+00, $// 40
3.15E+00,2.78E+00,2.45E+00,2.16E+00,1.90E+00,1.67E+00,1.47E+00,1.30E+00,1.14E+00,1.00E+00, $// 50
8.78E-01,7.70E-01,6.75E-01,5.92E-01,5.19E-01,4.54E-01,3.98E-01,3.48E-01,3.04E-01,2.66E-01, $// 60
2.33E-01,2.04E-01,1.78E-01,1.56E-01,1.36E-01,1.19E-01,1.04E-01,9.09E-02,7.95E-02,6.95E-02, $// 70
6.08E-02,5.32E-02,4.65E-02,4.07E-02,3.56E-02,3.11E-02,2.72E-02,2.38E-02,2.09E-02,1.83E-02, $// 80
1.60E-02,1.40E-02,1.22E-02,1.07E-02,9.39E-03,8.22E-03,7.20E-03,6.30E-03,5.52E-03,4.83E-03, $// 90
4.23E-03,3.71E-03,3.26E-03,2.86E-03,2.52E-03,2.21E-03,1.95E-03,1.72E-03,1.52E-03,1.34E-03, $//100
1.19E-03,1.05E-03,9.33E-04,8.28E-04,7.35E-04,6.53E-04,5.81E-04,5.18E-04,4.61E-04,4.11E-04, $//110
3.67E-04,3.28E-04,2.94E-04,2.63E-04,2.35E-04,2.11E-04,1.89E-04,1.70E-04,1.53E-04,1.37E-04, $//120
                           1.23E-04,5.20E-05,2.70E-05,1.53E-05,9.04E-06,5.52E-06,3.45E-06, $//130
2.19E-06,1.43E-06,9.53E-07,6.49E-07,4.51E-07,3.19E-07,2.30E-07,1.71E-07,1.29E-07,9.93E-08, $//200
7.77E-08,6.17E-08,4.97E-08,4.06E-08,3.35E-08,2.79E-08,2.35E-08]));                          //300
  self.rhotable=ptr_new(alog(1000d*[ $ Table values are in g/cm^3, final array is in ln(kg/m^3)
3.85d-05,3.52E-05,3.21E-05,2.94E-05,2.68E-05,2.45E-05,2.24E-05,2.04E-05,1.87E-05,1.70E-05, $//-10
1.55E-05,1.42E-05,1.30E-05,1.18E-05,1.08E-05,9.90E-06,9.06E-06,8.32E-06,7.65E-06,7.04E-06, $//  0
6.47E-06,5.94E-06,5.44E-06,4.99E-06,4.56E-06,4.17E-06,3.81E-06,3.48E-06,3.17E-06,2.89E-06, $// 10
2.63E-06,2.39E-06,2.18E-06,1.97E-06,1.79E-06,1.62E-06,1.47E-06,1.33E-06,1.20E-06,1.09E-06, $// 20
9.80E-07,8.84E-07,7.97E-07,7.19E-07,6.47E-07,5.82E-07,5.24E-07,4.71E-07,4.23E-07,3.79E-07, $// 30
3.40E-07,3.04E-07,2.72E-07,2.43E-07,2.17E-07,1.94E-07,1.73E-07,1.54E-07,1.37E-07,1.22E-07, $// 40
1.08E-07,9.60E-08,8.52E-08,7.55E-08,6.69E-08,5.92E-08,5.23E-08,4.63E-08,4.09E-08,3.61E-08, $// 50
3.18E-08,2.80E-08,2.47E-08,2.17E-08,1.91E-08,1.68E-08,1.48E-08,1.30E-08,1.14E-08,9.97E-09, $// 60
8.73E-09,7.65E-09,6.70E-09,5.85E-09,5.12E-09,4.47E-09,3.91E-09,3.42E-09,2.99E-09,2.62E-09, $// 70
2.29E-09,2.00E-09,1.75E-09,1.53E-09,1.34E-09,1.17E-09,1.03E-09,8.97E-10,7.85E-10,6.87E-10, $// 80
6.01E-10,5.26E-10,4.61E-10,4.03E-10,3.53E-10,3.09E-10,2.71E-10,2.37E-10,2.08E-10,1.82E-10, $// 90
1.59E-10,1.39E-10,1.21E-10,1.05E-10,9.17E-11,8.01E-11,7.01E-11,6.13E-11,5.38E-11,4.72E-11, $//100
4.14E-11,3.64E-11,3.21E-11,2.82E-11,2.49E-11,2.20E-11,1.94E-11,1.72E-11,1.52E-11,1.35E-11, $//110
1.19E-11,1.06E-11,9.41E-12,8.36E-12,7.44E-12,6.63E-12,5.91E-12,5.27E-12,4.70E-12,4.20E-12, $//120
                           3.76E-12,1.09E-12,4.73E-13,2.43E-13,1.35E-13,7.90E-14,4.74E-14, $//130
2.92E-14,1.80E-14,1.14E-14,7.42E-15,4.92E-15,3.33E-15,2.24E-15,1.55E-15,1.10E-15,7.94E-16, $//200
5.87E-16,4.39E-16,3.34E-16,2.59E-16,2.03E-16,1.61E-16,1.30E-16]));                          //300   

  return,1
end

function planet_mars::cleanup
  ptr_free,self.rhotable
  ptr_free,self.htable
  ptr_free,self.ptable
  ptr_free,self.ttable
  
  ptr_free,self.aeroid
  ptr_free,self.topo
end

function planet_mars::read_table,rv,l=l,table
  tau=2d*!dpi ; Tau manifesto
  if ~keyword_set(l) then llr=self->llr(rv) else llr=rv
  aclat=llr[0]
  lon_rel=llr[1]
  if lon_rel lt 0 then lon_rel+=tau
  sa=size(*table,/dim)
  return,interpolate(*table,linterp(0d,0d,tau,sa[0],lon_rel),linterp(-tau/4d,0d,tau/4d,sa[1],aclat))
  
end

;distance from center of Mars to aeroid under given relative position vector or aerocentric lat/lon 
function planet_mars::equipotential,rv,l=l
  return,double(self->read_table(rv,l=l,self.aeroid))+3396000d
end

;Difference between the planetocentric topography radius and the equipotential
;surface in meters, on earth the MSL height of a point on the ground, under 
;given relative position vector or aerocentric lat/lon
function planet_mars::topography,rv,l=l
  return,double(self->read_table(rv,l=l,self.topo))
end

;Atmospheric density in kg/m^3 (water=1000)
pro planet_mars::atm,rv,et,t=t,p=p,rho=rho,csound=csound,m=m,alt=alt,llr=llr_rel
  llr_rel=xyz_to_llr(self->i2rel(rv,et))
  alt=llr_rel[2]-self->equipotential(llr_rel,/l)
  t=interpol(*self.ttable,*self.htable,alt)
  p=exp(interpol(*self.ptable,*self.htable,alt))
  rho=exp(interpol(*self.rhotable,*self.htable,alt))
  rs=8314.32d;
  m=rho*rs*t/p; Final array is in kg/kmol
  gamma=1.31d ;measured spec heat ratio for CO2 at 0degC
  csound=sqrt(gamma*P/rho)
end

pro planet_mars__define
  struct={planet_mars, $
          rhotable:ptr_new(),htable:ptr_new(),ptable:ptr_new(),ttable:ptr_new(), $
          aeroid:ptr_new(), topo:ptr_new(), $
          inherits planet}
end