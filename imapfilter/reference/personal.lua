--[[ vim:ts=2:sw=2:et:

Organizes Alex Mikitik's personal email.

This configuration organizes mail by the following:

  1. Moves any mail from "important" people into their own mailbox.
     These contacts and their mailbox associations are located in a
     separate file (~/.imapfilter/contacts.lua).  That file should
     not be under version control.
  2. Any mail which is older than a certain threshold (defaults to 14 days)
     and is not flagged or unread gets moved to a top level "Archives"
     mailbox, where it is organized by year.

The mail account(s) for this configuration are defined within a file
(~/.imapfilter/accounts.lua).  Multiple accounts are supported, included
unrelated accounts.  Each account is assigned to a variable which is operated
on explicitly (see "Execution" section).

An account looks like the following:
  
    my_account = IMAP {
      server = 'server.hostname.com',
      username = 'my@email.com',
      password = 'my-secret-password',
      ssl = 'ssl3'
    };

NOTE: The accounts file should NOT be under version control.

The "important" people for this configuration are defined within a file
(~/.imapfilter/accounts.lua).  This file defines a single variable ("mapping")
which is a table value defining an email-address-to-folder mapping.  All
messaages from the defined addresses will be moved from the inbox to the
"People/NAME" folder.

An example contact mapping looks like the following:

    mapping = {
      -- Friends
      ['james@example.com']   = 'James',
      ['sarah@example.com']   = 'Sarah',
      ['beeker@example.com']  = 'Mark',

      -- Family
      ['mother@example.com']  = 'Parents',
      ['father@example.com']  = 'Parents',
      ['sister@example.com']  = 'Jenny',
    }

NOTE: The contacts file should NOT be under version control.
--]]


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
      return false end
end


-- 
-- Find and sort messages from designated contacts into their configured
-- mailboxes.
-- 
function sort_designated_contact_messages(mailbox, contacts)
  local inbox = mailbox.inbox
  local hasMailbox = false

  if not mailbox_exists(mailbox, '', 'People') then
    mailbox:create_mailbox('People')
  end

  -- Define all folders to sort contact messages from
  local sourceBoxes = {
    mailbox.inbox,
    -- Had messages from people filed in archives that I wanted to re-file
    --mailbox['Archive/2007'],
    --mailbox['Archive/2008'],
    --mailbox['Archive/2009'],
    --mailbox['Archive/2010'],
    --mailbox['Archive/2011'],
    --mailbox['Archive/2012'],
    --mailbox['Archive/2013'],
    --mailbox['Archive/2014'],
    --mailbox['Archive/2015'],
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
      local target = 'People/' .. dbox
      if not mailbox_exists(mailbox, 'People', dbox) then
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

  local resultCounts = {}

  for y = FIRST_YEAR, THIS_YEAR do
    resultCounts[y] = 0

    -- Build up a search for messages falling within the given year
    local meta =
      results:arrived_before("31-Dec-" .. y) *
      results:arrived_since("1-Jan-" .. y)

    if #meta > 0 then
      -- Create any mailboxes necessary for archives
      if not mailbox_exists(mailbox, 'Archive', string.format('%d', y)) then
        mailbox:create_mailbox('Archive/' .. y)
      end

      -- Move messages to archive directory
      resultCounts[y] = resultCounts[y] + #meta
      meta:move_messages(mailbox["Archive/" .. y]);
    end
  end

  -- Report on how many messages were moved
  print('Yearly archived messages:')
  for year = FIRST_YEAR, THIS_YEAR do
    print(string.format('%-4d - %s', resultCounts[year], year))
  end
end


--[ Execution ]--------------------------------------------------------------

sort_designated_contact_messages(home, mapping)
archive_by_year(home)
