files = {}
for f in lfs.dir("/etc/jail.conf.d/") do
  if f:match(".conf") then
    table.insert(files, f)
  end
end

ids = {}
for i = 1, #files do
  jconfs = io.open("/etc/jail.conf.d/" .. files[i])
  jconf = jconfs:read("*a")
  for l in jconf:gmatch("[^\r\n]+") do
    if l:find(" $id ") then
      idl = {}
      for p in l:gmatch("[^;=\"%s]+") do
        table.insert(idl, p)
      end
      table.insert(ids, tonumber(idl[2]))
    end
  end
  jconfs:close()
end

table.sort(ids)
if (#ids == 0) then
  print(0)
else
  for i = 1, #ids do
    if (ids[i]+1 ~= ids[i+1]) then
      print(ids[i]+1)
      break
    end
  end
end
