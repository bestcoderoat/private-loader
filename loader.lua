local HttpService = game:GetService("HttpService")
local lp          = game:GetService("Players").LocalPlayer

local KEY     = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcmVqZWN3cHJicmZ3YW9jZ2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIyOTI1MTgsImV4cCI6MjEwNzg2ODUxOH0.nrS2czNeewi4tXC4GId0PPuNzQBgMpVw1S-qsEvy9Zg"
local BASE    = "https://qjrejecwprbrfwaocgac.supabase.co"
local SCRIPT  = "https://raw.githubusercontent.com/iamnotadingus/plutohub/refs/heads/main/RELEASED"
local WEBHOOK = "https://discord.com/api/webhooks/1556808035236843541/9Y90bQH1U0E1wT7mV_fOHp--151iQWVaxkbGyHQgeQA7LLscXGcL00Y8HRv41GTUykrq"

local req = (syn and syn.request) or (http and http.request) or http_request or request

local function post(url, body)
    local r = req({ Url = url, Method = "POST",
        Headers = { ["Content-Type"] = "application/json",
                    ["apikey"] = KEY, ["Authorization"] = "Bearer " .. KEY },
        Body = body })
    return r and (r.Body or r.body)
end

local function rpc(fn, body)
    local raw = post(BASE .. "/rest/v1/rpc/" .. fn, HttpService:JSONEncode(body))
    if not raw then return nil end
    local ok, d = pcall(HttpService.JSONDecode, HttpService, raw)
    return ok and d or nil
end

local ok, id = pcall(function() return game:GetService("RbxAnalyticsService"):GetClientId() end)
id = ok and id or "unknown"

-- register; notify you only the first time
if rpc("register_hwid", { p_hwid = id, p_username = lp.Name }) == "registered" then
    pcall(post, WEBHOOK, HttpService:JSONEncode({
        content = "**New loader request**\nUser: `" .. lp.Name .. "`\nHWID: `" .. id .. "`\nApprove: https://supabase.com/dashboard/project/qjrejecwprbrfwaocgac/editor"
    }))
end

if rpc("check_hwid", { p_hwid = id }) ~= true then
    pcall(function() lp:Kick("Access denied. Wait for owner's approval.") end)
    return
end

local old = loadstring
getgenv().loadstring = function(c, ...)
    if type(c) == "string" and c:find("Settings.KeySystem") then
        c = c:gsub("if%s*%(Settings%.KeySystem%)%s*then", "if false then")
        c = c:gsub("if%s+Settings%.KeySystem%s+then", "if false then")
        c = c:gsub("has_key_system%s*=%s*Settings%.KeySystem%s*and%s*true%s*or%s*false", "has_key_system = false")
    end
    return old(c, ...)
end

loadstring(game:HttpGet(SCRIPT))()
