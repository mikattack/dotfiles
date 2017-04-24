--[[ vim:ts=2:sw=2:et:

Organizes Alex Mikitik's personal and work email.

The mail account(s) for this configuration are defined within a file
(~/.imapfilter/accounts.lua).  Multiple accounts are supported, included
unrelated accounts.  Each account is assigned to a variable which is operated
on explicitly.

An account file looks like the following:
  
  my_account = IMAP {
    server = 'server.hostname.com',
    username = 'my@email.com',
    password = 'my-secret-password',
    ssl = 'ssl3'
  };

--]]

options.timeout = 120

local settings = {
  ["age"]       = 14,
  ["first"]     = 2016,
  ["last"]      = tonumber(os.date('%Y')),
  ["contacts"]  = {},
}

local HOME = os.getenv("HOME")
loadfile(HOME .. "/.imapfilter/functions/archive.lua")()
loadfile(HOME .. "/.imapfilter/functions/archive_by_year.lua")()
loadfile(HOME .. "/.imapfilter/functions/util.lua")()

loadfile(HOME .. "/.imapfilter/accounts.lua")()   -- Imports 'home' and 'work'
--loadfile(HOME .. "/.imapfilter/contacts.lua")()

-- Personal
options.starttls = false
settings.account = home
-- settings.contacts = contacts_mapping
-- file_designated_contact_messages(settings)
archive_by_year(settings)

-- Work
options.starttls = true
settings.account = work
archive(settings)
