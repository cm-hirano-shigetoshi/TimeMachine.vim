local M = {}
local fzf = require("fzf")

require("fzf").default_options = {
    window_on_create = function()
        vim.cmd("set winhl=Normal:Normal")
    end
}

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local function contains(array, element)
    for _, e in ipairs(array) do
        if e == element then
            return true
        end
    end
    return false
end

local function get_buf_name()
    local fullpath = vim.api.nvim_buf_get_name(0)
    if string.len(fullpath) > 0 then
        return vim.fn.fnamemodify(fullpath, ":~:.")
    else
        return nil
    end
end

local function get_hash_ids()
    local cmd = "git log --oneline " .. get_buf_name() .. " | awk '{print $1}'"
    return split(vim.fn.system(cmd), "\n")
end

local function get_output_path(dirname, hash_id)
    return dirname .. "/" .. hash_id
end

local function save_snapshot(hash_id, output_path)
    local cmd = "git show " .. hash_id .. ":$(git rev-parse --show-prefix)" .. get_buf_name() .. " > " .. output_path
    os.execute("mkdir -p " .. output_path:match("(.*/)"))
    os.execute(cmd)
end

local function dump_histories(dirname)
    os.execute("rm -fr " .. dirname)
    local hash_ids = get_hash_ids()
    for _, hash_id in ipairs(hash_ids) do
        local output_path = get_output_path(dirname, hash_id)
        save_snapshot(hash_id, output_path)
    end
end

local function get_positions_to_open(dirname, results)
    local positions = {}
    local known_files = {}
    for _, result in ipairs(results) do
        local sp = split(result, ":")
        local filepath = dirname .. "/" .. sp[1]
        if not contains(known_files, filepath) then
            table.insert(known_files, filepath)
            table.insert(positions, { filepath, tonumber(sp[2]) })
        end
    end
    return positions
end

local function execute_fzf(dirname_, query_)
    coroutine.wrap(function(dirname, query)
        local results = fzf.fzf("(cd " .. dirname .. " && rg --color always -L -n ^)",
            "--multi --ansi --reverse --delimiter ':' --query '" .. query .. "' " ..
            "--preview '(cd " .. dirname .. " && bat --plain --number --color always --highlight-line {2} {1})' " ..
            "--preview-window 'right:60%' --preview-window '+{2}+1/2'")
        if results then
            local positions_to_open = get_positions_to_open(dirname, results)
            for _, position in ipairs(positions_to_open) do
                vim.api.nvim_command("next " .. position[1])
                vim.api.nvim_win_set_cursor(0, { position[2], 0 })
            end
        end
        --os.execute("rm -fr " .. dirname)
    end)(dirname_, query_)
end

local function call(query)
    local tmpdir = os.tmpname()
    dump_histories(tmpdir)
    execute_fzf(tmpdir, query)
end

M.run = function(query)
    call(query)
end

return M
