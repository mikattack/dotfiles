-- vim:ts=2:sw=2:et:
-- 
-- Archive all mail that is read, unflagged, and older than AGE by year.
-- 
-- Named Args:
--    account (table) - IMAP account connection.
--    age (number)    - Days after which emails are archived
--    first (number)  - First year to sort old emails by
--    last (number)   - Last year to sort emails
-- 
-- Returns: void
-- 
-- Requires:
--    util.mailbox_exists
-- 
function archive_by_year(t)
  assert(type(t) == "table", "Function expects a single table of named arguments.")

  local params = {
    ["account"] = t.account,
    ["age"]     = t.age or 14,
    ["first"]   = t.first or 2004,
    ["last"]    = t.last or tonumber(os.date('%Y')),
  }

  -- Validate user input
  assert(type(params.account) == "table", "'account' must be an IMAP connection")
  assert(type(params.age) == "number", "'age' must be a number or nil")
  assert(type(params.first) == "number", "'first' must be a number or nil")
  assert(type(params.last) == "number", "'last' must be a number or nil")
  if params.age < 1 then
    params.age = 14
  end
  if params.first > params.last then
    params.first, params.last = params.last, params.first
  end

  local inbox  = params.account.inbox
  local results = inbox:is_unflagged() *
                  inbox:is_seen() *
                  inbox:is_older(params.age)
  
  if #results == 0 then
    return
  end

  local resultCounts = {}

  for y = params.first, params.last do
    resultCounts[y] = 0

    -- Build up a search for messages falling within the given year
    local meta =
      results:arrived_before("31-Dec-" .. y) *
      results:arrived_since("1-Jan-" .. y)

    if #meta > 0 then
      -- Create any mailboxes necessary for archives
      if not mailbox_exists(params.account, 'Archive', string.format('%d', y)) then
        params.account:create_mailbox('Archive/' .. y)
      end

      -- Move messages to archive directory
      resultCounts[y] = resultCounts[y] + #meta
      meta:move_messages(params.account["Archive/" .. y]);
    end
  end

  -- Report on how many messages were moved
  print('Yearly archived messages:')
  for year = params.first, params.last do
    print(string.format('%s - %d', year, resultCounts[year]))
  end
end
