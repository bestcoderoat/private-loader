-- PRIVATE LOADER - Fixed HttpPost
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local SUPABASE_URL = "https://qjrejecwprbrfwaocgac.supabase.co"
local SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcmVqZWN3cHJicmZ3YW9jZ2FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTIyOTI1MTgsImV4cCI6MjEwNzg2ODUxOH0.nrS2czNeewi4tXC4GId0PPuNzQBgMpVw1S-qsEvy9Zg"
local TABLE = "whitelist"

local function getHWID()
    local ok, id = pcall(function()
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end)
    return ok and id or "unknown"
end

local function httpRequest(method, endpoint, body)
    local url = SUPABASE_URL .. "/rest/v1/" .. endpoint
    
    local headers = {
        ["apikey"] = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json",
        ["Prefer"] = "return=representation"
    }

    local success, result = pcall(function()
        if method == "GET" then
            return game:HttpGet(url, true, headers)
        elseif method == "POST" then
            -- Different executors need different HttpPost styles
            if syn and syn.request then
                local r = syn.request({
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = HttpService:JSONEncode(body)
                })
                return r.Body
            elseif http_request then
                local r = http_request({
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = HttpService:JSONEncode(body)
                })
                return r.Body
            elseif request then
                local r = request({
                    Url = url,
                    Method = "POST",
                    Headers = headers,
                    Body = HttpService:JSONEncode(body)
                })
                return r.Body
            else
                return game:HttpPost(url, HttpService:JSONEncode(body), true, "application/json", headers)
            end
        end
    end)

    if success and result and result ~= "" then
        local ok, decoded = pcall(function()
            return HttpService:JSONDecode(result)
        end)
        if ok then return decoded end
    end
    return nil
end

local hwid = getHWID()
local username = lp.Name

-- Check existing
local existing = httpRequest("GET", TABLE .. "?hwid=eq." .. hwid .. "&select=*")

if existing and type(existing) == "table" and #existing > 0 then
    if existing[1].active == true then
        print("Access granted")
    else
        lp:Kick("Access revoked. Contact owner.")
        return
    end
else
    -- Register
    local data = {
        hwid = hwid,
        username = username,
        active = false,
        notes = "Auto registered"
    }

    local result = httpRequest("POST", TABLE, data)

    if result then
        lp:Kick("Registered. Wait for owner to approve you.")
    else
        lp:Kick("Registration failed.")
    end
    return
end

-- ============ KEY BYPASS ============
local OldLoadstring = loadstring
getgenv().loadstring = function(Chunk, ...)
    if type(Chunk) == "string" and Chunk:find("Settings.KeySystem") then
        Chunk = Chunk:gsub("if%s*%(Settings%.KeySystem%)%s*then", "if false then")
        Chunk = Chunk:gsub("if%s+Settings%.KeySystem%s+then", "if false then")
        Chunk = Chunk:gsub("has_key_system%s*=%s*Settings%.KeySystem%s*and%s*true%s*or%s*false", "has_key_system = false")
    end
    return OldLoadstring(Chunk, ...)
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/iamnotadingus/plutohub/refs/heads/main/RELEASED"))()
