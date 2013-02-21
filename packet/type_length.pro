function type_length,type
          ; 0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15
  n_bytes=[ 0, 1, 2, 4, 4, 8,-1, 1,-1,-1,-1,-1, 2, 4, 8, 8]
  return,n_bytes[type]
end
