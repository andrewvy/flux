--[[
  Currency Mod by andrewvy
]]

dofile(minetest.get_modpath("currency") .. "/settings.txt") -- Loading settings.

currency = {}

local accounts = {}
local input = io.open(minetest.get_worldpath() .. "/accounts", "r")
if input then
  accounts = minetest.deserialize(input:read("*l"))
  io.close(input)
end

function currency.save_accounts()
  local output = io.open(minetest.get_worldpath() .. "/accounts", "w")
  output:write(minetest.serialize(accounts))
  io.close(output)
end

function currency.set_currency(name, amount)
  accounts[name].balance = amount
  currency.save_accounts()
end

function currency.get_currency(name)
  return accounts[name].balance
end

function currency.account_exists(name)
  return accounts[name] ~= nil
end

function currency.format_currency(amount)
  return CURRENCY_SYMBOL .. amount .. " " .. CURRENCY_NAME
end

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()

  if not currency.account_exists(name) then
    accounts[name] = {balance = INITIAL_CURRENCY}
    currency.save_accounts()
  end
end)

minetest.register_privilege("currency", "Can use /currency [pay <account> <amount>] command")
minetest.register_privilege("currency_admin", {
  description = "Can modify currency settings and account balances.",
  give_to_singleplayer = false,
})

minetest.register_chatcommand("currency", {
  func = function(name, params)
    if not currency.account_exists(name) then
      return false, "Your server balance entry does not exist on the server"
    else
      local amount = currency.get_currency(name)
      return true, "Balance: " .. currency.format_currency(amount)
    end
  end
})

minetest.register_on_dignode(function(pos, oldnode, player)
  local name = player:get_player_name()

  if currency.account_exists(name) then
    local amount = currency.get_currency(name)
    currency.set_currency(name, amount + 5)
    local idx = player:hud_add({
      hud_elem_type = "text",
      position      = {x = 0.5, y = 0.5},
      offset        = {x = 0,   y = 0},
      text          = "Hello world!",
      alignment     = {x = 0, y = 0},  -- center aligned
      scale         = {x = 100, y = 100}, -- covered later
    })
  end
end)
