local hudscale = TacRP.ConVars["hudscale"]
function TacRP.SS(i)
    return ScrW() / 640 * i * hudscale:GetFloat()
end

local sizes_to_make = {
    4,
    5,
    6,
    8,
    10,
    11,
    12,
    14,
    16,
    20,
    32
}

local italic_sizes_to_make = {
    8,
}

local unscaled_sizes_to_make = {
    24,
    32,
    48
}

local fonts_to_make = {
    "Myriad Pro",
    "HD44780A00 5x8"
}

-- TacRP_HD44780A00_5x8_32

local function generatefonts()

    for ind, font in ipairs(fonts_to_make) do
        local fontname = string.Replace(font, " ", "_")

        if GetConVar("tacrp_font" .. ind) and GetConVar("tacrp_font" .. ind):GetString() ~= "" then
            font = GetConVar("tacrp_font" .. ind):GetString()
        else
            font = TacRP:GetPhrase("font." .. ind) or font
        end

        for _, i in pairs(sizes_to_make) do

            surface.CreateFont( "TacRP_" .. fontname .. "_" .. tostring(i), {
                font = font,
                size = TacRP.SS(i),
                weight = 0,
                antialias = true,
                extended = true, -- Required for non-latin fonts
            } )

            surface.CreateFont( "TacRP_" .. fontname .. "_" .. tostring(i) .. "_Glow", {
                font = font,
                size = TacRP.SS(i),
                weight = 0,
                antialias = true,
                blursize = 6,
                extended = true,
            } )
        end

        for _, i in pairs(italic_sizes_to_make) do
            surface.CreateFont( "TacRP_" .. fontname .. "_" .. tostring(i) .. "_Italic", {
                font = font,
                size = TacRP.SS(i),
                weight = 0,
                antialias = true,
                extended = true,
                italic = true,
            } )
        end

        for _, i in pairs(unscaled_sizes_to_make) do

            surface.CreateFont( "TacRP_" .. fontname .. "_" .. tostring(i) .. "_Unscaled", {
                font = font,
                size = i,
                weight = 0,
                antialias = true,
                extended = true,
            } )

        end
    end

end

generatefonts()

function TacRP.Regen(full)
    if full then
        generatefonts()
    end
end

hook.Add( "OnScreenSizeChanged", "TacRP.Regen", function() TacRP.Regen(true) end)
cvars.AddChangeCallback("tacrp_hudscale", function() TacRP.Regen(true) end, "tacrp_hudscale")

function TacRP.MultiLineText(text, maxw, font)
    local content = {}
    local tline = ""
    local x = 0
    surface.SetFont(font)

    local ts = surface.GetTextSize(" ")

    local newlined = string.Split(text, "\n")

    for _, line in ipairs(newlined) do
        local words = string.Split(line, " ")

        for _, word in ipairs(words) do
            local tx = surface.GetTextSize(word)

            if x + tx > maxw then
                local dashi = string.find(word, "-")
                if dashi and surface.GetTextSize(utf8.sub(word, 0, dashi)) <= maxw - x then
                    -- cut the word at the dash sign if possible
                    table.insert(content, tline .. utf8.sub(word, 0, dashi))
                    tline = ""
                    x = 0
                    word = utf8.sub(word, dashi + 1)
                    tx = surface.GetTextSize(word)
                else
                    -- move whole word to new line
                    table.insert(content, tline)
                    tline = ""
                    x = 0

                -- else
                --     -- cut the word down from the middle
                --     while x + tx > maxw do
                --         local cut = ""
                --         for i = 2, utf8.len(word) do
                --             cut = utf8.sub(word, 0, -i)
                --             tx = surface.GetTextSize(cut)
                --             if x + tx < maxw then
                --                 table.insert(content, tline .. cut)
                --                 tline = ""
                --                 word = utf8.sub(word, utf8.len(word) - i + 2)
                --                 x = 0
                --                 tx = surface.GetTextSize(word)
                --                 break
                --             end
                --         end
                --     end
                end
            end

            tline = tline .. word .. " "

            x = x + tx + ts
        end

        table.insert(content, tline)
        tline = ""
        x = 0
    end

    return content
end