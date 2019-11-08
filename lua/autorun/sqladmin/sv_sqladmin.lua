local sqladmin = {}

util.AddNetworkString("sqladmin.open")
util.AddNetworkString ("sqladmin.request")

function _hasAccess(ply)
    if not IsValid(ply) and not ply:IsSuperAdmin() then return ; end
    return true
end

function sqladmin.open(_, ply)
    if not _hasAccess(ply) then return ; end
    
    net.Start("sqladmin.open")
    net.Send(ply)
end

function sqladmin.request(_, ply)
    if !_hasAccess(ply) then return ; end
    
    local string = net.ReadString()
    local result
    local err
    
    sql.Begin()
    q = sql.Query(string)
    sql.Commit()
    
    result = q
    err = sql.LastError()
    
    net.Start("sqladmin.request")
    net.WriteString(type(result))
    
    if type(result) == "string" then
        net.WriteString(result)
    elseif type(result) == "table" then
        net.WriteTable(result)
    end
    
    net.Send(ply)
end

net.Receive("sqladmin.open", sqladmin.open)
net.Receive("sqladmin.request", sqladmin.request)