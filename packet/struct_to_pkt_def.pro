function struct_to_pkt_def,in_str
  t=tag_names(in_str)
  pos=0
  for i=0,n_elements(t)-1 do begin
    this_field={name:t[i],type:size(in_str.(i),/type),pos:pos,shift:0,length:0}    
    if n_elements(fields) eq 0 then fields=this_field else fields=[fields,this_field]
  end
  return,{name:'',apid:0,length:0,fields:ptr_new(fields)}
end


      
