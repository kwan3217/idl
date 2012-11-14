;input:
;  fn - array of filenames of L1A files to combine into this L1B
;Side-effect:
;  Creation of an L1B file with its name matching that of the first L1A file passed to it
pro iuvs_to_fits_1B,fn
  for i=0,n_elements(fn)-1 do begin
    this_fits=eve_read_whole_Fits(fn[i])
    if n_elements(cube) eq 0 then cube=[[[this_fits.primary]]] else cube=[[[cube]],[[this_fits.primary]]]
;    T=tag_names(this_fits.engineering)
;;    if n_elements(eng) eq 0 then begin
;      for j=0,n_elements(t)-1 do begin
 ;       if j eq 0 then begin
  ;;;        eng=create_struct(t[j],make_array(n_elements(fn),value=this_fits.engineering.(j)))
 ;       end else begin
 ;         eng=create_struct(eng,t[j],make_array(n_elements(fn),value=this_fits.engineering.(j)))
 ;       end
 ;     end
 ;   end
 ;   for j=0,n_elements(t)-1 do begin
 ;     eng.(j)[i]=this_fits.engineering.(j)
 ;   end
    if n_elements(eng) eq 0 then eng=this_fits.engineering else eng=[eng,this_fits.engineering]
    if n_elements(geo) eq 0 then geo=this_fits.Geometry else geo=[geo,this_fits.Geometry]
  end
  keywords=iuvs_make_keyword(eng[0],'1B')
  L1B_fn=strmid(fn[0],0,10)+'B'+strmid(fn[0],11)
  silent=1
  mwrfits,double(cube),  L1B_fn,keywords,/create,silent=silent
  
  mwrfits,create_struct('precision',double(cube)*!values.d_nan,'accuracy',double(cube)*!values.d_nan),l1b_fn,["EXTNAME = 'uncertainty'","END"],silent=silent
  keyword=["EXTNAME = 'Engineering'","END"]
  mwrfits,eng,                         l1b_fn,keyword,silent=silent
  if this_fits.engineering.bin_type ne 'LINEAR' then mwrfits,this_fits.NonlinearBinning,  l1b_fn,["EXTNAME = 'NonlinearBinning'","END"],silent=silent
  mwrfits,geo,l1b_fn,["EXTNAME = 'Geometry'","END"],silent=silent
  mwrfits,this_fits.observation,l1b_fn,["EXTNAME = 'Observation'","END"],silent=silent
end