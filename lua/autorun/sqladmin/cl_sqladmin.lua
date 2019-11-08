local sqladmin = {
    ["ui"] = {},
    ["panel"] = {"tables"},
    ["list"] = {["tables"] = {}, ["values"] = {}}
}

local requests = {
    ["gettables"] = "SELECT name FROM sqlite_master WHERE type ='table' AND name NOT LIKE 'sqlite_%' LIMIT -1",
    ["getcolumns"] = "PRAGMA table_info(%s)",
    ["gettable"] = "SELECT * FROM %s"
}

local function query(q, cb)
    net.Start("sqladmin.request")
    net.WriteString(q)
    net.SendToServer()
    
    net.Receive("sqladmin.request", function(_, _)
        local qtype = net.ReadString()
        
        if qtype == "table" then
            cb(net.ReadTable())
        elseif qtype == "string" then
            cb(net.ReadString())
        end
    end)
end

sqladmin.ui.pTabs = {
    ["Tables"] = function(sheet)
        local info = {}
        
        local panel, lPanel = sqladmin.panel.tables()
        
        sqladmin.list.tables.create(panel)
        
        info.panel = panel
        info.icon = "icon16/table.png"
        
        return info
    end
}

function sqladmin.panel.tables()
        local panel = vgui.Create("DPanel", sheet)
        
        local lPanel = vgui.Create("DPanel", panel)
        
        return panel, lPanel
end

function sqladmin.list.tables.update(tList)
    query(requests.gettables, function(r)
        for k, v in pairs(r) do
            tList:AddLine(v.name)
        end
    end)
end

function sqladmin.list.tables.create(panel)
    local tList = vgui.Create( "DListView", panel )
    tList:Dock( FILL )
    tList:SetMultiSelect( false )
    tList:AddColumn( "name" )
    
    tList.OnRowSelected = function(_, _, row)
        sqladmin.list.values.create(panel, tList, row)
    end
    
    sqladmin.list.tables.update(tList)
    
    return tList
end

function sqladmin.list.values.create(panel, tList, row)
    tList:Remove()
    local val =  row:GetValue(1)
    
    tList = vgui.Create( "DListView", panel )
    tList:Dock( FILL )
    tList:SetMultiSelect( false )
    
    sqladmin.list.values.update(val, tList)
    
    return tList
end

function sqladmin.list.values.update(val, tList)
    query(string.format(requests.getcolumns, val), function(r)
        for k, v in pairs(r) do
            tList:AddColumn(v.name)
        end
           
        query(string.format(requests.gettable, val), function(r)
            for k, v in pairs(r) do
                tList:AddLine(v.key, v.value)
            end
        end)
   end)
end

function sqladmin.panel.frame()
    local frame = vgui.Create( "DFrame" )
    frame:SetSize( 500, 300 )
    frame:Center()
    frame:MakePopup()
    
    return frame
end

function sqladmin.panel.sheet(f)
    local sheet = vgui.Create( "DPropertySheet", f )
    sheet:Dock( FILL )
    
    return sheet
end

function sqladmin.panel.addTabs(s)
    for key, v in pairs(sqladmin.ui.pTabs) do
        local sheet = v(s)
        
        s:AddSheet(key, sheet.panel, sheet.icon)
    end
end

function sqladmin.panel.show()
    local frame = sqladmin.panel.frame()
    local sheet = sqladmin.panel.sheet(frame)
    
    sqladmin.panel.addTabs(sheet)
end

net.Receive("sqladmin.open", sqladmin.panel.show)

concommand.Add("sqladmin", function(ply)
    net.Start("sqladmin.open")
    net.SendToServer()
end)