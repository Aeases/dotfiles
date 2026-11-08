local fcitx = require("fcitx")

local function zip(keys, values, map)
    map = map or {}
    local i = 1
    for _, cp in utf8.codes(values) do
        map[keys:sub(i, i)] = utf8.char(cp)
        i = i + 1
    end
    return map
end

local sup = zip("0123456789+-=()", "⁰¹²³⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾")
zip("abcdefghijklmnopqrstuvwxyz", "ᵃᵇᶜᵈᵉᶠᵍʰⁱʲᵏˡᵐⁿᵒᵖ𐞥ʳˢᵗᵘᵛʷˣʸᶻ", sup)
zip("ABCDEFGHIJKLMNOPQRTUVW", "ᴬᴮꟲᴰᴱꟳᴳᴴᴵᴶᴷᴸᴹᴺᴼᴾꟴᴿᵀᵁⱽᵂ", sup)
for name, char in pairs({
    alpha = "ᵅ", beta = "ᵝ", gamma = "ᵞ", delta = "ᵟ", epsilon = "ᵋ", varepsilon = "ᵋ",
    theta = "ᶿ", iota = "ᶥ", phi = "ᵠ", varphi = "ᵠ", chi = "ᵡ",
}) do sup["\\" .. name] = char end

local sub = zip("0123456789+-=()", "₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎")
zip("aehijklmnoprstuvxy", "ₐₑₕᵢⱼₖₗₘₙₒₚᵣₛₜᵤᵥₓᵧ", sub) -- y: subscript gamma lookalike
for name, char in pairs({
    beta = "ᵦ", gamma = "ᵧ", rho = "ᵨ", phi = "ᵩ", varphi = "ᵩ", chi = "ᵪ",
}) do sub["\\" .. name] = char end

local function convert(map, s)
    local out, i = {}, 1
    while i <= #s do
        local tok = s:match("^\\%a+", i) or s:match("^" .. utf8.charpattern, i) or s:sub(i, i)
        out[#out + 1] = map[tok] or map[tok:lower()] or tok
        i = i + #tok
    end
    return table.concat(out)
end

function subsup_handler(input)
    local map = ({ ["^"] = sup, ["_"] = sub })[input:sub(1, 1)]
    if not map then
        return nil
    end
    local result = convert(map, input:sub(2))
    if result == "" then
        return { { "", "", fcitx.QuickPhraseAction.NoneSelection } }
    end
    return {
        -- digits are part of the sequence, not candidate selectors
        { "", "", fcitx.QuickPhraseAction.NoneSelection },
        { result, result, fcitx.QuickPhraseAction.Commit },
        { "", "", fcitx.QuickPhraseAction.Break },
    }
end

fcitx.addQuickPhraseHandler("subsup_handler")
