-- vim:ts=2:sw=2:et:
-- 
-- Archive all mail that is read, unflagged, and older than AGE.
-- 
-- Named Args:
--    account (table) - IMAP account connection.
--    age (number)    - Days after which emails are archived
-- 
-- Returns: void
-- 
-- Requires:
--    util.mailbox_exists
-- 
function archive(t)
  assert(type(t) == "table", "Function expects a single table of named arguments.")

  local params = {
    ["account"] = t.account,
    ["age"]     = t.age or 14,
  }

  -- Validate user input
  assert(type(params.account) == "table", "'account' must be an IMAP connection")
  assert(type(params.age) == "number", "'age' must be a number or nil")
  if params.age < 1 then
    params.age = 14
  end

  -- Select and move messages
  local inbox  = params.account.inbox
  local results = inbox:is_unflagged() *
                  inbox:is_seen() *
                  inbox:is_older(params.age)
  
  if #results == 0 then
    return
  end

  results:move_messages(params.account["Archive"]);

  -- Report on how many messages were moved
  print(string.format('Archived messages: %d', #results))
end
