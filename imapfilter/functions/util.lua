--[[ vim:ts=2:sw=2:et:
  Utility functions for accounts and mailboxes.
--]]


-- 
-- Displays a list of all mailboxes for an account.
-- 
-- Args:
--    account (object) - IMAP account connection.
-- 
-- Returns: void
-- 
function info(account)
  local boxes, folders = account:list_all()
  for k,v in pairs(boxes) do
    print('['..k..'] '..v)
  end
end


-- 
-- Checks whether a subfolder exists within the given mailbox.
-- 
-- Args:
--    account (object)    - IMAP account connection.
--    mailbox (string)    - Name of mailbox to search.  Pass an empty string
--                          to search at the top level.  Pass a "folder"-style
--                          string to search within an existing folder
--                          (ex: 'archives' or 'archives/2016').
--    subfolder (string)  - The folder to search for.
-- 
-- Returns: BOOLEAN
-- 
function mailbox_exists(account, mailbox, subfolder)
    local result = account:list_all(mailbox, subfolder)
    if #result > 0 then
      return true
    else
      return false
    end
end
