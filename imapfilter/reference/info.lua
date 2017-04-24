-- vim:ts=2:sw=2:et:
-- 
-- Displays a list of all mailboxes for configured accounts.
-- 

options.timeout = 120;

-- Load account definition file
HOME = os.getenv("HOME");
loadfile(HOME .. "/.imapfilter/accounts.lua")();

-- Display everything for the "msys" account
local boxes, folders = msys:list_all();
for k,v in pairs(boxes) do
   print('[' .. k .. '] ' .. v);
end