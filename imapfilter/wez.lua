-- vim:ts=2:sw=2:et:

-----------------------------------------------------------------------------
-- Wez Furlong's IMAPFilter Old Configuration (for reference)
-----------------------------------------------------------------------------

options.timeout = 120;

-- This imapfilter configuration assumes that you have a folder under your
-- INBOX named 'archive', and that this folder is broken out by year, such
-- that 'INBOX/archive/2009' holds your inbox from 2009.
--
-- What this script does is move mail from your inbox to the appropriate
-- archive folder when it gets to a certain age.  It will not move flagged
-- or unread mail in this particular processing step.
--
-- It also has some steps for pruning out bulky folders that you keep on
-- hand in case you need to check up on something, but that are tracked
-- and reviewable in some other system of reference.  For instance,
-- commit and ticket mail.

-- Whether to perform a more in-depth check of your archive folders to see
-- if you've accidentally filed messages into the wrong year
FIX_MANUAL_MISFILE = false;
-- The oldest year that you have mail for
FIRST_YEAR = 2004;
-- Computes the current year
THIS_YEAR = tonumber(os.date('%Y'));
-- Messages older than this value in days will be subject for archival
OLD_AGE = 14;
-- These are the folders I consider to be "bulk" mail that I don't need to keep
BULKY = {
  "INBOX/jobs",
  "INBOX/support",
};

-- I keep my "msys" account definition in a separate file, so that I can
-- isolate my password from the logic that I keep in revision control
-- My accounts.lua file holds something like this:
--[[
-- Do not check this file into version control
-- vim:ts=2:sw=2:et:
msys = IMAP {
  server = 'zimbra.omniti.com',
  username = 'wez@messagesystems.com',
  password = 'my-secret-password',
  ssl = 'ssl3'
};
]]
HOME = os.getenv("HOME");
loadfile(HOME .. "/.imapfilter/accounts.lua")();

-- Given a set of messages, where we don't yet know the arrival date,
-- for each year in the range FIRST_YEAR through THIS_YEAR, filter
-- those messages into targetfolder/<YEAR>.
-- We iterate years because this may well be the first time that we're
-- archiving this folder, and it may span more than one year.
function archive_by_year(results, targetmailbox, targetfolder)
  if #results == 0 then
    return;
  end
  for y = FIRST_YEAR, THIS_YEAR do
    -- build up a search for messages falling in this year
    local meta =
      results:arrived_before("31-Dec-" .. y) *
      results:arrived_since("1-Jan-" .. y);
    local target = targetmailbox[targetfolder .. "/" .. y];
    meta:move_messages(target);
  end
end

-- A debugging helper that prints out the date and subject of a result set
function summarize_results(res)
  for _, msg in ipairs(res) do
    mailbox, uid = unpack(msg);
    local date = mailbox[uid]:fetch_date();
    local subj = mailbox[uid]:fetch_field('subject');
    print(date, subj);
  end
end

function find_commit_mail(item)
--  summarize_results(item);
  if #item == 0 then
    return
  end
  print("Sub-setting ", #item, "messages and looking for commit mail");
  return item:match_subject('^Subject:\\s*\\[[a-zA-Z0-9 ]+\\]\\s+\\S+\\s+commit');
end

-- In a given mailbox, look for commit mail that is not worth keeping;
-- delete it
function prune_commit_mail(mailbox, folder, prune_unread)
  print("Looking for commit mail in " .. folder);
  local m = mailbox[folder];
  -- do a rough approximation of the search we want on the server side
  -- to reduce the effort and time we need to spend here
  local results = m:send_query('SUBJECT "commit"');
  if prune_unread then
    results = find_commit_mail(
      results *
      m:is_unflagged() *
      m:is_older(OLD_AGE)
    );
  else
    results = find_commit_mail(
      results *
      m:is_unflagged() *
      m:is_seen() *
      m:is_older(OLD_AGE)
    );
  end
  if results then
  --  summarize_results(results);
    results:delete_messages();
  end
end

local INBOX = msys.inbox;

-- * = AND, + = OR, - = NOT

if FIX_MANUAL_MISFILE then
  -- Fixup duff archive folders, where mail had been manually filed into
  -- the wrong year folder
  for yr = FIRST_YEAR, THIS_YEAR do
    local af = msys["INBOX/archive/" .. yr];
    print("Looking for mail > " .. yr .. " archived in", yr);
    archive_by_year(af:arrived_since("31-Dec-" .. yr), msys, 'INBOX/archive');
    print("Looking for mail < " .. yr .. " archived in", yr);
    archive_by_year(af:arrived_before("1-Jan-" .. yr), msys, 'INBOX/archive');
  end
end
-- if commit mail landed in the archive, get rid of it
prune_commit_mail(msys, 'INBOX/archive/' .. THIS_YEAR, true);

-- Kill off read commit mail in the inbox
prune_commit_mail(msys, 'INBOX');

-- Kill off old mail in the commit folder
local commits = msys['INBOX/ec'];
(commits:is_older(OLD_AGE) * commits:is_unflagged()):delete_messages();

-- Kill off old mail in bulky folders that are not on my priority reading list
for _, bulk in ipairs(BULKY) do
  print("Pruning bulky folder " .. bulk);
  msys[bulk]:is_older(OLD_AGE):delete_messages();
end

-- Finally, move archivable mail to an appropriate archive location
archive_by_year(
  INBOX:is_unflagged() * INBOX:is_seen() * INBOX:is_older(OLD_AGE),
  msys, 'INBOX/archive');

