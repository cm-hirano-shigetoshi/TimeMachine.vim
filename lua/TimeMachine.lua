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

local function get_hash_ids(buf_name)
    local cmd = "git log --oneline " .. buf_name .. " | awk '{print $1}'"
    return split(vim.fn.system(cmd), "\n")
end

local function get_output_path(dirname, hash_id)
    return dirname .. "/" .. hash_id
end

local function save_snapshot(buf_name, hash_id, output_path)
    local cmd = "git show " .. hash_id .. ":$(git rev-parse --show-prefix)" .. buf_name .. " > " .. output_path
    os.execute("mkdir -p " .. output_path:match("(.*/)"))
    os.execute(cmd)
end

local function get_hash_id(result)
    local pattern = "%w%w%w%w%w%w%w*"
    local match = string.match(result, pattern)
    if match then
        return match
    end
    return ""
end

local function dump_history(buf_name, hash_id, dirname)
    local output_path = get_output_path(dirname, hash_id)
    save_snapshot(buf_name, hash_id, output_path)
    return output_path
end

local function dump_histories(buf_name, dirname)
    os.execute("rm -fr " .. dirname)
    local hash_ids = get_hash_ids(buf_name)
    for _, hash_id in ipairs(hash_ids) do
        dump_history(buf_name, hash_id, dirname)
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

local function execute_fzf(buf_name_, query_, tmpdir_)
    coroutine.wrap(function(buf_name, query, tmpdir)
        local results = fzf.fzf("git log --oneline --graph --color=always " .. buf_name,
            "--multi --ansi --reverse --query '" .. query .. "'")
        if results then
            for _, result in ipairs(results) do
                local hash_id = get_hash_id(result)
                if hash_id then
                    os.execute("rm -fr " .. tmpdir)
                    local output_path = dump_history(buf_name_, hash_id, tmpdir)
                    vim.api.nvim_command("next " .. output_path)
                end
            end
            --[[
            local positions_to_open = get_positions_to_open(dirname, results)
            for _, position in ipairs(positions_to_open) do
                vim.api.nvim_command("next " .. position[1])
                vim.api.nvim_win_set_cursor(0, { position[2], 0 })
            end
            ]]
            --
        end
        --os.execute("rm -fr " .. dirname)
    end)(buf_name_, query_, tmpdir_)
end

local function call(query)
    local tmpdir = os.tmpname()
    local buf_name = get_buf_name()
    --dump_histories(buf_name, tmpdir)
    execute_fzf(buf_name, query, tmpdir)
end

M.run = function(query)
    call(query)
end

return M
