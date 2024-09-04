local Character = require 'classes.hud.character'
local WindowState = require 'classes.hud.windowstate'
local utils = require 'utils.utils'
local state = require 'state'

--- @type Mq
local mq = require 'mq'

function WindowState:refreshPeers()
    self.PeerRefreshCount = self.PeerRefreshCount + 1
    if self.PeerRefreshCount < 20 then
        -- default interval .25, refresh peers every 20 loops, so every 5 seconds
        return
    else
        self.PeerRefreshCount = 0
    end
    local windowSettings = state.Settings.Windows[self.Name]
    if windowSettings.PeerGroup == 'zone' then
        self.PeerGroup = utils.GetZonePeerGroup()
    elseif windowSettings.PeerGroup == 'group' then
        self.PeerGroup = utils.GetGroupPeerGroup()
    elseif self.PeerGroup ~= windowSettings.PeerGroup then
        self.PeerGroup = windowSettings.PeerGroup
    end
    local t = {}
    if state.PeerSource == 'dannet' then
        t = utils.Split(mq.TLO.DanNet.Peers(self.PeerGroup)())
    else
        t = utils.Split(mq.TLO.NetBots.Client(), ' ')
    end

    if not self.Peers or not utils.DoTablesMatch(self.Peers, t) then
        self.Peers = t
        self.PeersDirty = true
    end
    for _,peerName in ipairs(self.Peers) do
        if not state.Characters[peerName] then
            state.Characters[peerName] = Character(peerName,nil)
        end
    end
end
