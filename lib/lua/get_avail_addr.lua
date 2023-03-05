handle = io.popen("ifconfig " .. arg[1])
ifconfig = handle:read("*a")
handle:close()

addrs = {}
for l in ifconfig:gmatch("[^\r\n]+") do
  if l:find("inet ") then
    line = {}
    for s in l:gmatch("%S+") do
      table.insert(line, s)
    end
    table.insert(addrs, line[2])
  end
end

lastbits = {}
for i = 1, #addrs do
  bits = {}
  for l in addrs[i]:gmatch("[^.]+") do
    table.insert(bits, l)
  end
  table.insert(lastbits, tonumber(bits[4]))
end

table.sort(lastbits)
for i = 1, #lastbits do
  if (lastbits[i]+1 ~= lastbits[i+1]) then
    print(bits[1] .. "." .. bits[2] .. "." .. bits[3] .. "." .. lastbits[i]+1)
    break
  end
end
