function reverse_array_struct,old_result
  names=tag_names(old_result)
  for i=0,n_tags(old_result)-1 do begin
    if i eq 0 then begin
      result=create_struct(names[i],(old_result.(i))[0])
    end else begin
      result=create_struct(result,names[i],(old_result.(i))[0])
    end
  end
  result=make_array(value=result,n_elements(old_result.(0)))
  for i=0,n_tags(old_result)-1 do begin
    result[*].(i)=old_result.(i)
  end
  return,result
end
