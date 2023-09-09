--- @type Mq
local mq = require 'mq'
--[[
Leftover stuff i didn't squeeze into a class somewhere, mostly shared info
accessed from several places.
--]]
local state = {
    Version = '2.6.6',

    -- Get name once at startup so we don't get name while dead or anything weird
    MyName = mq.TLO.Me.CleanName(),

    -- Destination for content loaded from boxhud-settings.lua
    Settings = {},
    -- Table of observed character data
    Characters = {},
    -- Table of runtime window data such as peer group and list of peers
    WindowStates = {},

    -- Whether to anonymize data in the Name column
    Anonymize = false,
    -- Temporary storage for mq.cmd to be executed in main loop from a UI button
    StoredCommand = nil,
    -- Temporary storage for DanNet observer admin tasks to be performed in main loop
    AdminPeerName = nil,
    AdminAction = nil,
    AdminPeerItem = '',

    -- Default peer source
    PeerSource = 'dannet',
    -- Default observed property to use to determine characters class
    ClassVar = 'Me.Class.ShortName',
    -- Default observer polling interval (0.25 seconds)
    RefreshInterval = 250,
    -- Default stale observed data timeout (60 seconds)
    StaleDataTimeout = 60,

    IsUsingDanNet = false,
    IsUsingNetBots = false,
}

return state
