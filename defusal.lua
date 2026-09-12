--[[ DEFUSAL HUB  •  Premium UI v3.0
     Executor: Delta / Synapse / KRNL        ]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- ══════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════
local Cfg = {
    Aimbot=false, AimbotKey=Enum.KeyCode.Q,
    FOV=150, Smooth=0.18, HitPart="Head",
    TeamCheck=true, ShowFOV=true, Prediction=0.10, SilentAim=false,
    ESP=false, BoxESP=true, NameESP=true,
    HealthBar=true, Tracers=false, DistESP=true,
    ESPColor=Color3.fromRGB(130,90,255),
    TeamColor=Color3.fromRGB(70,160,255),
    WalkSpeed=16, JumpPower=50, NoClip=false, InfJump=false,
}

-- ══════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════
local T = {
    BG     = Color3.fromRGB(8,   8,  13),
    Surf   = Color3.fromRGB(13,  13,  21),
    Surf2  = Color3.fromRGB(19,  19,  31),
    Surf3  = Color3.fromRGB(25,  25,  40),
    Bord   = Color3.fromRGB(42,  42,  68),
    Acc    = Color3.fromRGB(110, 80, 235),
    AccLt  = Color3.fromRGB(155, 120, 255),
    Pink   = Color3.fromRGB(215, 75,  155),
    Teal   = Color3.fromRGB(70,  200, 180),
    Text   = Color3.fromRGB(238, 238, 250),
    Sub    = Color3.fromRGB(118, 118, 155),
    Muted  = Color3.fromRGB(55,  55,  85),
    Green  = Color3.fromRGB(75,  210, 115),
    Red    = Color3.fromRGB(220, 70,  70),
    Yellow = Color3.fromRGB(255, 185, 50),
    W      = Color3.new(1,1,1),
    B      = Color3.new(0,0,0),
}

-- ══════════════════════════════════════════════
--  UTILS
-- ══════════════════════════════════════════════
local function N(cls,props,par)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if par then o.Parent=par end
    return o
end
local function TI(t,s,d) return TweenInfo.new(t,Enum.EasingStyle[s or"Quart"],Enum.EasingDirection[d or"Out"]) end
local function Tw(o,t,p,s,d) TweenService:Create(o,TI(t,s,d),p):Play() end
local function Crn(r,p) N("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function Str(t,c,p,tr) local s=N("UIStroke",{Thickness=t,Color=c,Transparency=tr or 0},p) return s end
local function Pad(l,r,t,b,p) N("UIPadding",{PaddingLeft=UDim.new(0,l),PaddingRight=UDim.new(0,r),PaddingTop=UDim.new(0,t),PaddingBottom=UDim.new(0,b)},p) end
local function List(gap,p) N("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,gap)},p) end
local function Grid(cx,cy,p) N("UIGridLayout",{CellSize=UDim2.new(0,cx,0,cy),SortOrder=Enum.SortOrder.LayoutOrder},p) end
local function Grad(cs,rot,p) N("UIGradient",{Color=cs,Rotation=rot},p) end
local function CS(...) local t={} for i,v in ipairs({...}) do t[i]=ColorSequenceKeypoint.new((i-1)/math.max(#({...})-1,1),v) end return ColorSequence.new(t) end

-- Ripple
local function Ripple(parent,x,y)
    local rip=N("Frame",{
        Size=UDim2.new(0,0,0,0),
        Position=UDim2.new(0,x,0,y),
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=T.W,
        BackgroundTransparency=.75,
        BorderSizePixel=0,
        ZIndex=99,
        ClipsDescendants=false,
    },parent) Crn(999,rip)
    Tw(rip,.5,{Size=UDim2.new(0,160,0,160),BackgroundTransparency=1},"Quad")
    task.delay(.5,function() rip:Destroy() end)
end

-- Hover highlight
local function Hover(btn,norm,hot)
    btn.MouseEnter:Connect(function() Tw(btn,.12,{BackgroundColor3=hot}) end)
    btn.MouseLeave:Connect(function() Tw(btn,.12,{BackgroundColor3=norm}) end)
end

-- ══════════════════════════════════════════════
--  NOTIFICATION
-- ══════════════════════════════════════════════
local NotifHolder
local function MakeNotif(title,msg,ntype)
    if not NotifHolder then return end
    local col = ntype=="success" and T.Green or ntype=="warn" and T.Yellow or T.Acc
    local f=N("Frame",{
        Size=UDim2.new(0,240,0,58),
        BackgroundColor3=T.Surf2,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Position=UDim2.new(0,260,0,0),
    },NotifHolder) Crn(8,f) Str(1,T.Bord,f)
    -- accent stripe
    local stripe=N("Frame",{Size=UDim2.new(0,3,1,0),BackgroundColor3=col,BorderSizePixel=0},f) Crn(4,stripe)
    N("TextLabel",{Size=UDim2.new(1,-16,0,20),Position=UDim2.new(0,12,0,8),
        BackgroundTransparency=1,Text=title,TextColor3=T.Text,
        Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},f)
    N("TextLabel",{Size=UDim2.new(1,-16,0,18),Position=UDim2.new(0,12,0,26),
        BackgroundTransparency=1,Text=msg,TextColor3=T.Sub,
        Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},f)
    -- progress bar
    local bar=N("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=col,BorderSizePixel=0},f)
    Tw(bar,2.5,{Size=UDim2.new(0,0,0,2)},"Linear")
    task.delay(2.7,function() Tw(f,.3,{BackgroundTransparency=1}) task.delay(.3,function() f:Destroy() end) end)
end

-- ══════════════════════════════════════════════
--  ESP
-- ══════════════════════════════════════════════
local Pool={}
local function D(t,p) local o=Drawing.new(t) for k,v in pairs(p) do o[k]=v end return o end
local function MkESP(pl)
    if pl==LocalPlayer then return end
    Pool[pl]={
        BoxOL =D("Square",{Visible=false,Thickness=3,Color=T.B,Filled=false}),
        Box   =D("Square",{Visible=false,Thickness=1.5,Filled=false,Color=Cfg.ESPColor}),
        Name  =D("Text",  {Visible=false,Size=13,Color=T.W,Outline=true,OutlineColor=T.B,Center=true,Font=Drawing.Fonts.UI}),
        HPbg  =D("Square",{Visible=false,Thickness=1,Color=T.B,Filled=true}),
        HP    =D("Square",{Visible=false,Thickness=1,Filled=true,Color=T.Green}),
        Tracer=D("Line",  {Visible=false,Thickness=1,Color=Cfg.ESPColor}),
        Dist  =D("Text",  {Visible=false,Size=10,Color=T.Yellow,Outline=true,OutlineColor=T.B,Center=true,Font=Drawing.Fonts.UI}),
    }
end
local function KillESP(pl) if Pool[pl] then for _,o in pairs(Pool[pl]) do if o and o.Remove then o:Remove() end end Pool[pl]=nil end end
local function HideAll(t) for _,o in pairs(t) do if o then o.Visible=false end end end
local FOVCircle=D("Circle",{Visible=false,Thickness=1.5,NumSides=80,Color=T.AccLt,Filled=false,Radius=150})
local function HPCol(h,m) local r=h/m return r>.6 and T.Green or r>.3 and T.Yellow or T.Red end

local function UpdESP()
    for _,pl in pairs(Players:GetPlayers()) do
        if pl==LocalPlayer then continue end
        if not Pool[pl] then MkESP(pl) end
        local o=Pool[pl] local ch=pl.Character
        if not Cfg.ESP or not ch then HideAll(o) continue end
        local root=ch:FindFirstChild("HumanoidRootPart")
        local head=ch:FindFirstChild("Head")
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if not root or not head or not hum or hum.Health<=0 then HideAll(o) continue end
        local tp,tv=Camera:WorldToViewportPoint(head.Position+Vector3.new(0,head.Size.Y/2+.1,0))
        local bp,_ =Camera:WorldToViewportPoint(root.Position-Vector3.new(0,2.8,0))
        if not tv then HideAll(o) continue end
        local t2=Vector2.new(tp.X,tp.Y) local b2=Vector2.new(bp.X,bp.Y)
        local h=math.abs(b2.Y-t2.Y) local w=h*.55
        local dist=(Camera.CFrame.Position-root.Position).Magnitude
        local col=(Cfg.TeamCheck and pl.Team==LocalPlayer.Team)and Cfg.TeamColor or Cfg.ESPColor
        if Cfg.BoxESP then
            local bx,by=t2.X-w/2,t2.Y
            o.BoxOL.Position=Vector2.new(bx-1,by-1) o.BoxOL.Size=Vector2.new(w+2,h+2) o.BoxOL.Visible=true
            o.Box.Position=Vector2.new(bx,by) o.Box.Size=Vector2.new(w,h) o.Box.Color=col o.Box.Visible=true
        else o.Box.Visible=false o.BoxOL.Visible=false end
        if Cfg.NameESP then o.Name.Position=Vector2.new(t2.X,t2.Y-17) o.Name.Text=pl.DisplayName o.Name.Visible=true
        else o.Name.Visible=false end
        if Cfg.HealthBar then
            local bx2=t2.X-w/2-7 local ratio=hum.Health/hum.MaxHealth
            o.HPbg.Position=Vector2.new(bx2,t2.Y) o.HPbg.Size=Vector2.new(4,h) o.HPbg.Visible=true
            o.HP.Position=Vector2.new(bx2,t2.Y+h*(1-ratio)) o.HP.Size=Vector2.new(4,h*ratio) o.HP.Color=HPCol(hum.Health,hum.MaxHealth) o.HP.Visible=true
        else o.HPbg.Visible=false o.HP.Visible=false end
        if Cfg.Tracers then local vp=Camera.ViewportSize o.Tracer.From=Vector2.new(vp.X/2,vp.Y) o.Tracer.To=b2 o.Tracer.Color=col o.Tracer.Visible=true
        else o.Tracer.Visible=false end
        if Cfg.DistESP then o.Dist.Position=Vector2.new(t2.X,b2.Y+3) o.Dist.Text=string.format("%.0fm",dist) o.Dist.Visible=true
        else o.Dist.Visible=false end
    end
end

-- ══════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════
local function Closest()
    local best,bD=nil,Cfg.FOV
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _,pl in pairs(Players:GetPlayers()) do
        if pl==LocalPlayer then continue end
        if Cfg.TeamCheck and pl.Team==LocalPlayer.Team then continue end
        local ch=pl.Character if not ch then continue end
        local part=ch:FindFirstChild(Cfg.HitPart) or ch:FindFirstChild("HumanoidRootPart")
        local hum=ch:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health<=0 then continue end
        local sp,vis=Camera:WorldToViewportPoint(part.Position)
        if not vis then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<bD then bD=d best=pl end
    end
    return best
end

local function UpdAim()
    local vp=Camera.ViewportSize
    FOVCircle.Visible=Cfg.Aimbot and Cfg.ShowFOV
    FOVCircle.Position=Vector2.new(vp.X/2,vp.Y/2)
    FOVCircle.Radius=Cfg.FOV
    if not Cfg.Aimbot or not UserInputService:IsKeyDown(Cfg.AimbotKey) then return end
    local tgt=Closest() if not tgt then return end
    local ch=tgt.Character if not ch then return end
    local part=ch:FindFirstChild(Cfg.HitPart) or ch:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local ap=part.Position+(part.Velocity*Cfg.Prediction)
    Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,ap),1-Cfg.Smooth)
end

-- ══════════════════════════════════════════════
--  MISC
-- ══════════════════════════════════════════════
local ncC,ijC
local function SetNC(v) if ncC then ncC:Disconnect() ncC=nil end if v then ncC=RunService.Stepped:Connect(function() local ch=LocalPlayer.Character if ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end end) end end
local function SetIJ(v) if ijC then ijC:Disconnect() ijC=nil end if v then ijC=UserInputService.JumpRequest:Connect(function() local ch=LocalPlayer.Character if ch then local h=ch:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end) end end
local function ApplySpd() local ch=LocalPlayer.Character if ch then local h=ch:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed=Cfg.WalkSpeed h.JumpPower=Cfg.JumpPower end end end
LocalPlayer.CharacterAdded:Connect(ApplySpd)

-- ══════════════════════════════════════════════
--  BUILD GUI
-- ══════════════════════════════════════════════
if game.CoreGui:FindFirstChild("DHub3") then game.CoreGui.DHub3:Destroy() end

local Gui=N("ScreenGui",{Name="DHub3",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},game.CoreGui)

-- Notif container (bottom-right)
NotifHolder=N("Frame",{
    Size=UDim2.new(0,245,0,300),
    Position=UDim2.new(1,-255,1,-310),
    BackgroundTransparency=1,
    AnchorPoint=Vector2.new(0,0),
},Gui)
List(6,NotifHolder)

-- ─── MAIN FRAME ──────────────────────────────
local Main=N("Frame",{
    Size=UDim2.new(0,1,0,1),           -- starts tiny for open anim
    AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,0,.5,0),
    BackgroundColor3=T.BG,
    BorderSizePixel=0,
    ClipsDescendants=true,
},Gui)
Crn(10,Main)
local mainStroke=Str(1,T.Bord,Main)

-- animated border glow
local glowTick=0
RunService.RenderStepped:Connect(function(dt)
    glowTick=glowTick+dt*.8
    local s=math.sin(glowTick)*.5+.5
    mainStroke.Color=T.Acc:Lerp(T.Pink, s)
    mainStroke.Transparency = .4 - s*.3
end)

-- shadow
N("ImageLabel",{
    Size=UDim2.new(1,40,1,40),Position=UDim2.new(0,-20,0,-20),
    BackgroundTransparency=1,
    Image="rbxassetid://5028857084",
    ImageColor3=T.B,ImageTransparency=.45,
    ScaleType=Enum.ScaleType.Slice,SliceCenter=Rect.new(24,24,276,276),
    ZIndex=0,
},Main)

-- ─── TOP BAR ─────────────────────────────────
local Top=N("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.Surf,BorderSizePixel=0,ZIndex=3},Main)
Crn(10,Top)
N("Frame",{Size=UDim2.new(1,0,.5,0),Position=UDim2.new(0,0,.5,0),BackgroundColor3=T.Surf,BorderSizePixel=0,ZIndex=2},Top)
N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Bord,BorderSizePixel=0,ZIndex=4},Top)

-- gradient on topbar
Grad(CS(T.Acc,T.Pink),0,Top)

-- logo cluster
local LogoBg=N("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),BackgroundColor3=T.BG,ZIndex=5},Top)
Crn(8,LogoBg) Str(1,T.AccLt,LogoBg)
N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="◈",TextColor3=T.AccLt,Font=Enum.Font.GothamBold,TextSize=15,ZIndex=6},LogoBg)

N("TextLabel",{
    Size=UDim2.new(0,160,0,22),Position=UDim2.new(0,44,0,6),
    BackgroundTransparency=1,Text="DEFUSAL HUB",
    TextColor3=T.W,Font=Enum.Font.GothamBold,TextSize=14,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
},Top)
N("TextLabel",{
    Size=UDim2.new(0,80,0,14),Position=UDim2.new(0,45,0,24),
    BackgroundTransparency=1,Text="v3.0  •  premium",
    TextColor3=Color3.fromRGB(220,220,255),Font=Enum.Font.Gotham,TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
},Top)

-- top bar buttons
local function TopBtn(sym,xOff,col)
    local b=N("TextButton",{
        Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,xOff,.5,-13),
        BackgroundColor3=Color3.fromRGB(28,28,44),
        Text=sym,TextColor3=col,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=6,
    },Top) Crn(7,b) Hover(b,Color3.fromRGB(28,28,44),Color3.fromRGB(40,40,60)) return b
end
local CloseBtn=TopBtn("✕",-10,T.Red)
local MinBtn  =TopBtn("▬",-42,T.Sub)
local PinBtn  =TopBtn("⊕",-74,T.Sub)

local Body=N("Frame",{Name="Body",Size=UDim2.new(1,0,1,-42),Position=UDim2.new(0,0,0,42),BackgroundTransparency=1},Main)

CloseBtn.MouseButton1Click:Connect(function()
    Tw(Main,.25,{Size=UDim2.new(0,1,0,1)},"Back","In")
    task.delay(.3,function() Main.Visible=false Main.Size=UDim2.new(0,560,0,380) end)
end)
local mini=false
MinBtn.MouseButton1Click:Connect(function()
    mini=not mini
    Tw(Main,.25,{Size=mini and UDim2.new(0,560,0,42) or UDim2.new(0,560,0,380)},"Quart")
    Body.Visible=not mini
end)

-- ─── SIDEBAR ─────────────────────────────────
local Side=N("Frame",{Size=UDim2.new(0,130,1,-8),Position=UDim2.new(0,6,0,4),BackgroundColor3=T.Surf,BorderSizePixel=0},Body)
Crn(8,Side) Str(1,T.Bord,Side)
local SideInner=N("Frame",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1},Side)
List(3,SideInner) Pad(0,0,8,8,SideInner)

-- sidebar user badge
local UserBadge=N("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.Surf3,LayoutOrder=99},SideInner)
Crn(7,UserBadge) Str(1,T.Bord,UserBadge)
local ava=N("Frame",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,7,.5,-13),BackgroundColor3=T.Acc},UserBadge)
Crn(13,ava)
local avaTxt=N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=string.sub(LocalPlayer.Name,1,1):upper(),TextColor3=T.W,Font=Enum.Font.GothamBold,TextSize=11},ava)
N("TextLabel",{Size=UDim2.new(1,-42,0,16),Position=UDim2.new(0,38,0,7),BackgroundTransparency=1,Text=LocalPlayer.Name,TextColor3=T.Text,Font=Enum.Font.GothamSemibold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},UserBadge)
N("TextLabel",{Size=UDim2.new(1,-42,0,12),Position=UDim2.new(0,38,0,23),BackgroundTransparency=1,Text="● online",TextColor3=T.Green,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left},UserBadge)

-- ─── CONTENT AREA ────────────────────────────
local ContentBg=N("Frame",{Size=UDim2.new(1,-148,1,-8),Position=UDim2.new(0,142,0,4),BackgroundColor3=T.Surf,BorderSizePixel=0},Body)
Crn(8,ContentBg) Str(1,T.Bord,ContentBg)

local Pages={}
local ActiveName=nil

local function MkPage()
    local s=N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,
        ScrollBarImageColor3=T.Acc,AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false,
    },ContentBg)
    Pad(10,13,10,10,s) List(5,s)
    return s
end

local function GoTab(name)
    if ActiveName==name then return end
    if Pages[ActiveName] then
        Tw(Pages[ActiveName],.12,{BackgroundTransparency=1},"Quad")
        task.delay(.12,function() if Pages[ActiveName] then Pages[ActiveName].Visible=false end end)
    end
    ActiveName=name
    Pages[name].Visible=true
    Pages[name].BackgroundTransparency=1
    Tw(Pages[name],.18,{BackgroundTransparency=0},"Quad")
end

-- sidebar tab factory
local function MkTab(label,icon,order)
    local pg=MkPage() Pages[label]=pg

    local btn=N("TextButton",{
        Size=UDim2.new(1,0,0,38),BackgroundColor3=T.Surf2,
        Text="",LayoutOrder=order,
    },SideInner) Crn(7,btn)
    Hover(btn,T.Surf2,T.Surf3)

    -- left accent pill
    local pill=N("Frame",{Size=UDim2.new(0,3,0,18),Position=UDim2.new(0,2,.5,-9),BackgroundColor3=T.Acc,Visible=false},btn) Crn(2,pill)

    -- icon box
    local iconBox=N("Frame",{Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,8,.5,-12),BackgroundColor3=T.Muted},btn) Crn(6,iconBox)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,TextColor3=T.Sub,Font=Enum.Font.GothamBold,TextSize=13},iconBox)

    local lbl=N("TextLabel",{Size=UDim2.new(1,-46,1,0),Position=UDim2.new(0,40,0,0),BackgroundTransparency=1,Text=label,TextColor3=T.Sub,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},btn)

    local function Activate()
        GoTab(label)
        for _,b in pairs(SideInner:GetChildren()) do
            if b:IsA("TextButton") then
                local p2=b:FindFirstChildOfClass("Frame")
                local ib=b:FindFirstChild("Frame",true)
                local lb=b:FindFirstChildOfClass("TextLabel")
                if lb then Tw(lb,.12,{TextColor3=T.Sub}) end
                if p2 then p2.Visible=false end
            end
        end
        pill.Visible=true
        Tw(lbl,.15,{TextColor3=T.Text})
        Tw(iconBox,.15,{BackgroundColor3=T.Acc})
        local ic=iconBox:FindFirstChildOfClass("TextLabel")
        if ic then Tw(ic,.15,{TextColor3=T.W}) end
        local pos=btn.AbsolutePosition
        Ripple(btn,pos.X*.1+15,19)
    end
    btn.MouseButton1Click:Connect(Activate)
    return pg, Activate
end

-- ─── COMPONENT LIBRARY ───────────────────────
local function Section(txt,parent,order)
    local f=N("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,LayoutOrder=order or 0},parent)
    N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=txt:upper(),TextColor3=T.Acc,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},f)
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Bord,BorderSizePixel=0},f)
    return f
end

local function Toggle(lbl,desc,page,cfgKey,order,cb)
    local row=N("Frame",{Size=UDim2.new(1,0,0,desc and 50 or 40),BackgroundColor3=T.Surf2,LayoutOrder=order or 0},page)
    Crn(7,row) Str(1,T.Bord,row) Pad(12,12,0,0,row)
    N("TextLabel",{Size=UDim2.new(1,-56,0,20),Position=UDim2.new(0,0,0,desc and 7 or 10),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamSemibold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
    if desc then N("TextLabel",{Size=UDim2.new(1,-56,0,16),Position=UDim2.new(0,0,0,27),BackgroundTransparency=1,Text=desc,TextColor3=T.Sub,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},row) end

    local track=N("Frame",{Size=UDim2.new(0,42,0,22),Position=UDim2.new(1,-42,.5,-11),BackgroundColor3=Cfg[cfgKey] and T.Acc or T.Muted},row) Crn(11,track)
    local thumb=N("Frame",{Size=UDim2.new(0,18,0,18),Position=Cfg[cfgKey] and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9),BackgroundColor3=T.W},track) Crn(9,thumb)
    -- thumb shadow glow when on
    local tStr=Str(2,T.AccLt,thumb,.5)

    local function Refresh()
        local on=Cfg[cfgKey]
        Tw(track,.18,{BackgroundColor3=on and T.Acc or T.Muted})
        Tw(thumb,.18,{Position=on and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)})
        tStr.Transparency= on and 0 or 1
        if on then Tw(row,.18,{BackgroundColor3=T.Surf3}) else Tw(row,.18,{BackgroundColor3=T.Surf2}) end
    end
    Refresh()

    N("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=""},row).MouseButton1Click:Connect(function()
        Cfg[cfgKey]=not Cfg[cfgKey] Refresh()
        MakeNotif(lbl, Cfg[cfgKey] and "Включено" or "Выключено", Cfg[cfgKey] and "success" or "warn")
        if cb then cb(Cfg[cfgKey]) end
    end)
    return row
end

local function Slider(lbl,page,cfgKey,mn,mx,order,cb,suffix)
    suffix=suffix or ""
    local row=N("Frame",{Size=UDim2.new(1,0,0,54),BackgroundColor3=T.Surf2,LayoutOrder=order or 0},page)
    Crn(7,row) Str(1,T.Bord,row) Pad(12,12,0,0,row)
    N("TextLabel",{Size=UDim2.new(.7,0,0,20),Position=UDim2.new(0,0,0,8),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamSemibold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},row)
    local valL=N("TextLabel",{Size=UDim2.new(.3,0,0,20),Position=UDim2.new(.7,0,0,8),BackgroundTransparency=1,Text=tostring(Cfg[cfgKey])..suffix,TextColor3=T.AccLt,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},row)
    local trk=N("Frame",{Size=UDim2.new(1,0,0,6),Position=UDim2.new(0,0,0,38),BackgroundColor3=T.Muted},row) Crn(3,trk)
    local r0=math.clamp((Cfg[cfgKey]-mn)/(mx-mn),0,1)
    local fill=N("Frame",{Size=UDim2.new(r0,0,1,0),BackgroundColor3=T.Acc,BorderSizePixel=0},trk) Crn(3,fill)
    Grad(CS(T.Acc,T.Pink),0,fill)
    local knob=N("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(r0,0,.5,-8),AnchorPoint=Vector2.new(.5,0),BackgroundColor3=T.W},trk) Crn(8,knob) Str(2,T.AccLt,knob)
    local drag=false
    knob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=true Tw(knob,.1,{Size=UDim2.new(0,20,0,20)}) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false Tw(knob,.1,{Size=UDim2.new(0,16,0,16)}) end end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local rel=math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
            local val=math.round(mn+(mx-mn)*rel)
            Cfg[cfgKey]=val valL.Text=tostring(val)..suffix
            fill.Size=UDim2.new(rel,0,1,0) knob.Position=UDim2.new(rel,0,.5,-8)
            if cb then cb(val) end
        end
    end)
    return row
end

local function Separator(page,order)
    N("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Bord,BorderSizePixel=0,LayoutOrder=order or 0},page)
end

-- ─── POPULATE PAGES ──────────────────────────

-- AIMBOT
local AimPg, AimAct = MkTab("Аимбот","🎯",1)
Section("Основное",    AimPg,1)
Toggle("Аимбот",           "Q — зажать для прицела",AimPg,"Aimbot",2)
Toggle("Silent Aim",       "Незаметный выстрел",    AimPg,"SilentAim",3)
Toggle("Team Check",       "Пропускать союзников",  AimPg,"TeamCheck",4)
Toggle("Показать FOV",     nil,                     AimPg,"ShowFOV",5)
Separator(AimPg,6)
Section("Точность",    AimPg,7)
Slider("FOV",          AimPg,"FOV",      40,400,8,nil," px")
Slider("Плавность",    AimPg,"Smooth",   1,20, 9, function(v) Cfg.Smooth=v/100 end,"")
Slider("Предсказание", AimPg,"Prediction",0,30,10,function(v) Cfg.Prediction=v/100 end,"")

-- ESP
local EspPg, EspAct = MkTab("Визуал","👁",2)
Section("ESP",         EspPg,1)
Toggle("Включить ESP", nil,                    EspPg,"ESP",      2)
Toggle("Рамки (Box)",  "Квадрат вокруг врага", EspPg,"BoxESP",   3)
Toggle("Имена",        nil,                    EspPg,"NameESP",  4)
Toggle("Полоска HP",   nil,                    EspPg,"HealthBar",5)
Toggle("Трейсеры",     "Линии к ногам врага",  EspPg,"Tracers",  6)
Toggle("Дистанция",    nil,                    EspPg,"DistESP",  7)

-- MISC
local MscPg, MscAct = MkTab("Разное","⚙",3)
Section("Движение",    MscPg,1)
Slider("Скорость",     MscPg,"WalkSpeed",16,200,2,function() ApplySpd() end," ws")
Slider("Высота прыжка",MscPg,"JumpPower",50,400,3,function() ApplySpd() end," jp")
Separator(MscPg,4)
Toggle("NoClip",           "Проходить сквозь стены",MscPg,"NoClip",  5,SetNC)
Toggle("Бесконечный прыжок",nil,                    MscPg,"InfJump", 6,SetIJ)

-- INFO
local InfoPg, _ = MkTab("Инфо","ℹ",4)
local card=N("Frame",{Size=UDim2.new(1,0,0,100),BackgroundColor3=T.Surf3,LayoutOrder=1},InfoPg)
Crn(8,card) Str(1,T.Bord,card) Pad(14,14,14,14,card)
Grad(CS(T.Surf3,T.Surf2),135,card)
N("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text="DEFUSAL HUB v3.0\n\n🎯  Аимбот  —  Q (зажать)\n👁  ESP  —  в настройках\n⌨  Insert  —  скрыть/показать",
    TextColor3=T.Sub,Font=Enum.Font.Gotham,TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true},card)

-- activate first tab
AimAct()

-- ─── OPEN ANIMATION ──────────────────────────
Main.Size=UDim2.new(0,1,0,1)
Main.Visible=true
Tw(Main,.45,{Size=UDim2.new(0,560,0,380)},"Back")
task.delay(.5,function()
    MakeNotif("DEFUSAL HUB","Загружено успешно!","success")
end)

-- ─── HOTKEY ──────────────────────────────────
UserInputService.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.Insert then
        Main.Visible=not Main.Visible
        if Main.Visible then Tw(Main,.3,{Size=UDim2.new(0,560,0,380)},"Back") end
    end
end)

-- ─── PLAYER EVENTS ───────────────────────────
Players.PlayerAdded:Connect(MkESP)
Players.PlayerRemoving:Connect(KillESP)
for _,p in pairs(Players:GetPlayers()) do MkESP(p) end

-- ─── MAIN LOOP ───────────────────────────────
RunService.RenderStepped:Connect(function()
    UpdESP() UpdAim() ApplySpd()
