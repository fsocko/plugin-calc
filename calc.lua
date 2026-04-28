VERSION = "0.1.1"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")

--------------------------------------------------
-- STATE
--------------------------------------------------

local ans = 0

--------------------------------------------------
-- ENV
--------------------------------------------------

local env = {
    pi = math.pi,
    e = math.exp(1),
    pow = math.pow,

    abs = math.abs,
    sqrt = math.sqrt,
    floor = math.floor,
    ceil = math.ceil,

    sin = math.sin,
    cos = math.cos,
    tan = math.tan,

    asin = math.asin,
    acos = math.acos,
    atan = math.atan,

    ans = 0,
}

setmetatable(env, { __index = function() return nil end })

--------------------------------------------------
-- SELECTION HELPERS
--------------------------------------------------

local function getTextLoc(c)
    local v = micro.CurPane()
    local a, b

    if c:HasSelection() then
        a = c.CurSelection[1]
        b = c.CurSelection[2]
    else
        local eol = string.len(v.Buf:Line(c.Loc.Y))
        a = c.Loc
        b = buffer.Loc(eol, c.Loc.Y)
    end

    return a, b
end

local function getText(a, b)
    local buf = micro.CurPane().Buf
    local out = {}

    if a.Y == b.Y then
        return buf:Line(a.Y):sub(a.X + 1, b.X)
    end

    table.insert(out, buf:Line(a.Y):sub(a.X + 1))
    for i = a.Y + 1, b.Y - 1 do
        table.insert(out, buf:Line(i))
    end
    table.insert(out, buf:Line(b.Y):sub(1, b.X))

    return table.concat(out, "\n")
end

--------------------------------------------------
-- SANITIZE
--------------------------------------------------

local function sanitize(expr)
    expr = tostring(expr)
    expr = expr:gsub("×", "*")
    expr = expr:gsub("÷", "/")
    expr = expr:gsub("\r", "")
    return expr
end

--------------------------------------------------
-- EVAL
--------------------------------------------------

local function eval_expr(expr)
    expr = sanitize(expr)

    if expr:match("%de[%+%-]?%d*%.%d+") then
        return nil, "invalid scientific notation (exponent must be integer)"
    end

    if not expr:match("^[%d%+%-%*/%^%.%(%) %a_]+$") then
        return nil, "invalid characters"
    end

    local fn, err = loadstring("return " .. expr)
    if not fn then
        return nil, err
    end

    setfenv(fn, env)

    env.ans = ans

    local ok, result = pcall(fn)
    if not ok then
        return nil, result
    end

    ans = result

    return result, nil
end

--------------------------------------------------
-- MAIN COMMAND
--------------------------------------------------

function calc()
    local v = micro.CurPane()
    local cs = v.Buf:GetCursors()

    for i = 1, #cs do
        local c = cs[i]

        local a, b = getTextLoc(c)
        local text = getText(a, b)

        text = text:gsub("^%s+", ""):gsub("%s+$", "")

        local result, err = eval_expr(text)

        if err then
            micro.InfoBar():Error(err)
            goto continue
        end

        local out = tostring(result)

        local a2 = buffer.Loc(a.X, a.Y)
        local b2 = buffer.Loc(b.X, b.Y)

        local insertText = " = " .. out

        local existingLine = v.Buf:Line(b.Y)
        local suffix = existingLine:sub(b.X + 1, b.X + 3)

        if suffix == " = " then
            local lineEnd = buffer.Loc(string.len(existingLine), b.Y)
            v.Buf:Replace(b2, lineEnd, insertText)
        else
            v.Buf:Insert(b2, insertText)
        end

        ::continue::
    end
end

--------------------------------------------------
-- INIT
--------------------------------------------------

function init()
    config.MakeCommand("calc", calc, config.NoComplete)
end