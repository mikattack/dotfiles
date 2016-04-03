-- vim:ts=2:sw=2:et:
-- 
-- Organizes Alex Mikitik's personal email.
-- 
-- This configuration organizes mail by the following:
-- 
--   1. Moves any mail from "important" people into their own mailbox.
--      These contacts and their mailbox associations are located in a
--      separate file (~/.imapfilter/contacts.lua).  That file should
--      not be under version control.
--   2. Any mail which is older than a certain threshold (defaults to 14 days)
--      and is not flagged or unread gets moved to a top level "Archives"
--      mailbox, where it is organized by year.
-- 
-- The accounts definition is defined in a separate file
-- (~/.imapfilter/accounts.lua), which looks something like this:
--[[
  
  home = IMAP {
    server = 'server.hostname.com',
    username = 'my@email.com',
    password = 'my-secret-password',
    ssl = 'ssl3'
  };

]]
-- The accounts file should not be under version control.


--[ Setup ]------------------------------------------------------------------


options.timeout = 120;

FIRST_YEAR = 2004;                      -- First year to sort old emails by
THIS_YEAR = tonumber(os.date('%Y'));    -- Capt'n Obvious
AGE = 14;                               -- Days after which emails are archived

-- Load account credentials and contact mappings
HOME = os.getenv("HOME");
loadfile(HOME .. "/.imapfilter/accounts.lua")();
loadfile(HOME .. "/.imapfilter/contacts.lua")();


--[ Functions ]--------------------------------------------------------------


-- 
-- Find and sort messages from designated contacts into their configured
-- mailboxes.
-- 
function sort_designated_contact_messages(mailbox, contacts)
  local inbox = mailbox.inbox
  local hasMailbox = false

  -- Create the "People" mailboxe if it doesn't exist
  local boxes, folders = mailbox:list_all();
  for index, box in pairs(boxes) do
    if box == 'People' then
      hasMailbox = true
    end
  end
  if hasMailbox == false then
    mailbox:create_mailbox('People')
  end

  return
  
  --[[
  -- Sort known commit messages
  for subject, box in pairs(filters) do
    local results = inbox:contain_subject(subject)
    if #results > 0 then
      --print(box)
      --print('Messages: ' .. #results .."\n")
      results:move_messages(mailbox[box]);
    end
  end

  -- Otherwise, stick all commit looking messages into 'Unaligned'
  local unaligned = inbox:match_subject('\\[.+\\]')   -- Double '\' required
  if #unaligned > 0 then
    unaligned:move_messages(mailbox['Commits/Unaligned'])
  end
--]]
end


-- 
-- Archive all mail that is read, unflagged, and older than AGE by year.
-- 
function archive_by_year(mailbox)
  local inbox  = mailbox.inbox
  local results = inbox:is_unflagged() *
                  inbox:is_seen() *
                  inbox:is_older(AGE)
  
  if #results == 0 then
    return
  end

  -- Create any mailboxes necessary for archives

  
  for y = FIRST_YEAR, THIS_YEAR do
    -- Build up a search for messages falling within the given year
    local meta =
      results:arrived_before("31-Dec-" .. y) *
      results:arrived_since("1-Jan-" .. y)
    meta:move_messages(mailbox["Archives/" .. y]);
  end
end


--[ Execution ]--------------------------------------------------------------

sort_designated_contact_messages(home, mapping)
--archive_by_year(home)
