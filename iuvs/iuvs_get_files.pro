function iuvs_get_files
  files=file_search('sci_file_*.dat')
  files=file_basename(files,'.dat')
  files=strmid(files,strlen('sci_file_'))
  return,files
end
