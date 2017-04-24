-- vim:ts=2:sw=2:et:
-- 
-- Find and files messages from designated contacts into their configured
-- mailboxes.
-- 
-- All filed messages will be placed within the "People" mailbox by default.
-- This value is configurable.
-- 
-- The contact mapping does not need to include the mailbox prefix.
-- 
-- An example contact mapping looks like the following:
-- 
--     mapping = {
--       -- Friends
--       ['james@example.com']   = 'James',
--       ['sarah@example.com']   = 'Sarah',
--       ['beeker@example.com']  = 'Mark',
-- 
--       -- Family
--       ['mother@example.com']  = 'Parents',
--       ['father@example.com']  = 'Parents',
--       ['sister@example.com']  = 'Jenny',
--     }
-- 
-- NOTE: The contacts file should NOT be under version control.
-- 
-- Named Args:
--    account (table)       - IMAP account connection.
--    contacts (table)      - Mapping of email addresses to mailboxes.
--    destination (string)  - Name of the mailbox messages should be filed
--                            into (default: "People").
--    mailboxes (table)     - Optional list of additional mailboxes to examine
--                            for contact messages. The "inbox" mailbox is
--                            always checked and does not need to be included.
-- 
-- Returns: void
-- 
-- Requires:
--    util.mailbox_exists
-- 
function file_designated_contact_messages(t)
  assert(type(t) == "table", "Function expects a single table of named arguments.")

  local params = {
    ["account"]     = t.account,
    ["contacts"]    = t.contacts or {},
    ["destination"] = t.destination or "People",
    ["mailboxes"]   = t.mailboxes or {},
  }

  -- Validate user input
  assert(type(params.account) == "table", "'account' must be an IMAP connection")
  assert(type(params.contacts) == "table", "'contacts' must be a email/mailbox mapping")
  assert(type(params.destination) == "string", "'destination' must be a string")
  assert(type(params.mailboxes) == "table", "'mailboxes' must be a list of strings or nil")

  local inbox = account.inbox
  local hasMailbox = false

  if not mailbox_exists(account, "", params.destination) then
    account:create_mailbox(params.destination)
  end

  -- Define all folders to sort contact messages from
  local sourceBoxes = { account.inbox }
  for i = 1, #params.mailboxes do
    if mailbox[params.mailboxes[i]] ~= nil then
      table.insert(sourceBoxes, mailbox[params.mailboxes[i]])
    end
  }

  -- Debug information
  local resultCounts = {}
  for address, _ in pairs(contacts) do
    resultCounts[address] = 0
  end

  -- Loop through folders and evaluate the "FROM" address of each message
  -- against the contacts lookup.  If a match is found, move the message
  -- to the appropriate directory.
  for _, sbox in ipairs(sourceBoxes) do
    local all = sbox:select_all()
    for address, dbox in pairs(contacts) do
      local target = params.destination .. '/' .. dbox
      if not mailbox_exists(mailbox, params.destination, dbox) then
        mailbox:create_mailbox(target)
      end
      local set = all:contain_from(address)
      resultCounts[address] = resultCounts[address] + #set
      set:move_messages(mailbox[target])
    end
  end

  -- Report on how many messages were moved
  print('Contact messages:')
  for address, count in pairs(resultCounts) do
    print(string.format('%-4d - %s', count, address))
  end
end
