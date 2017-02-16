local tracker = require('resty.fastdfs.tracker')
local storage = require('resty.fastdfs.storage')

local image_exts = {'.jpg', '.jpeg', '.png', '.bmp', '.gif'}

function file_exists(path)
    file, err = io.open(path, "r")
    if file then file:close() return true else return false end
end

function is_empty(str)
    return (not str) or (string.len(str) == 0)
end

function parse_uri(default_group)
    local index = string.find(ngx.var.path, "_[0-9]+x[0-9]+$")
    local path = ngx.var.path
    local size = nil
    if index then
        path = string.sub(ngx.var.path, 0, index-1)
        size = string.sub(ngx.var.path, index+1)
    end
    if not is_empty(ngx.var.group) then
        return ngx.var.group .. "/" .. path, size
    end
    if not is_empty(default_group) then
        return default_group .. "/" .. path, size
    end
    return path, size
end

function is_image(ext)
    for _, val in ipairs(image_exts) do
        if val == ext then return true end
    end
    return false
end

-- connect to tracker
local tk = tracker:new()
tk:set_timeout(3000) -- ms
local ok, err = tk:connect({host=ngx.var.tracker_host,port=ngx.var.tracker_port})
if not ok then
    ngx.log(ngx.ERR, "connect error:" .. err)
    ngx.exit(ngx.HTTP_BAD_GATEWAY)
end

-- query storage server
store_opts, err = tk:query_storage_store()
if not store_opts then
    ngx.log(ngx.ERR, "query storage error:" .. err)
    ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end
local st = storage:new()
st:set_timeout(3000)
local ok, err = st:connect(store_opts)
if not ok then
    ngx.log(ngx.ERR, "connect storage error:" .. err)
    ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
end

path, size = parse_uri(store_opts.group_name)
local uri = path .. ngx.var.ext
-- original file path
local o_path = ngx.var.cache_path .. "/" .. path .. ngx.var.ext
-- download original file if not exists
if not file_exists(o_path) then
    os.execute("mkdir -p " .. ngx.var.cache_path .. "/" .. uri:gsub("(.*)/(.*)", "%1"))
    local ofile = io.open(o_path, "w")
    if not ofile then
        ngx.log(ngx.ERR, "failed to open file:" .. o_path)
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    res, err = st:download_file_to_callback1(uri, function(data) ofile:write(data) end)
    ofile:close()
    if not res then
        ngx.log(ngx.ERR, "download file error:" .. err)
        os.remove(o_path)
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

if not is_empty(size) and is_image(ngx.var.ext) then
    -- thumbnail file path
    local t_path = ngx.var.cache_path .. "/" .. path .. "_" .. size .. ngx.var.ext
    if not file_exists(t_path) then
        os.execute(table.concat({"gm", "convert", "-size", size, o_path, "-resize", size, "+profile '*'", t_path}, " "))
    end
    if not file_exists(t_path) then
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
    uri = path .. "_" .. size .. ngx.var.ext
end

ngx.exec("/" .. uri)