-- vim:ts=2:sw=2:et:
-- 
-- Organizes Alex Mikitik's Message Systems Inc. email.
-- 
-- This imapfilter configuration organizes mail in two steps:
--   1. Moves anything that looks like a commit message into an appropriate
--      mailbox.
--   2. Any mail which is older than a certain threshold (defaults to 14 days)
--      and is not flagged or unread gets moved to a top level "Archives"
--      mailbox, that is in-turn organized by year.
-- 
-- The "msys" account definition is defined in a separate file
-- (~/.imapfilter/accounts.lua), which looks something like this:
--[[
  
  msys = IMAP {
    server = 'server.hostname.com',
    username = 'alex@messagesystems.com',
    password = 'my-secret-password',
    ssl = 'ssl3'
  };

]]
-- Do not check the 'accounts.lua' file into version control!

-------------------------------------------------------------------------------


options.timeout = 120;


FIRST_YEAR = 2004;                      -- First year to sort old emails by
THIS_YEAR = tonumber(os.date('%Y'));    -- Capt'n Obvious
AGE = 14;                               -- Days after which emails are archived


-- Commit message subject patterns => mail box
local filters = {
  ['[ec]'] = "Commits/Momentum",
  ['[mc]'] = "Commits/Message Central",
  ['[scope]'] = "Commits/Message Scope",
  ['[mobility]'] = "Commits/Momentum",
  ['[qa]'] = "Commits/QA",
  ['[docs]'] = "Commits/Unaligned",
  ['[docs ec mc mobility scope]'] = "Commits/Unaligned",
  ['[msweb]'] = "Commits/Msys Website",
  ['[Bug '] = "Bugzilla",
  ['[wiki]'] = "Commits/Unaligned",
  ['[ecinfra]'] = "Commits/Infrastructure",
  ['MC Continuous Integration Server'] = "Commits/Message Central",
  ['MC Build Candidate Server'] = "Commits/Message Central"
};


-- Load account credentials
HOME = os.getenv("HOME");
loadfile(HOME .. "/.imapfilter/accounts.lua")();


-------------------------------------------------------------------------------

-- Find and sort commit mail
function sort_commit_messages(mailbox, filters)
  local inbox = mailbox.inbox
  
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
end


-- Archive mail by it's year
function archive_by_year(mailbox)
  local inbox  = mailbox.inbox
  local results = inbox:is_unflagged() *
                  inbox:is_seen() *
                  inbox:is_older(AGE)
  
  if #results == 0 then
    return
  end
  
  for y = FIRST_YEAR, THIS_YEAR do
    -- build up a search for messages falling in this year
    local meta =
      results:arrived_before("31-Dec-" .. y) *
      results:arrived_since("1-Jan-" .. y)
    meta:move_messages(mailbox["Archives/" .. y]);
  end
end


-------------------------------------------------------------------------------

sort_commit_messages(msys, filters)
archive_by_year(msys)
