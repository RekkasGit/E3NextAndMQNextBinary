-- Tests are ran against the following standard:
-- LVL 85 Male Troll
-- Location The Plane of Knowledge
-- Do not click any equipment for buffs or AAs
-- Do not cast any spells

-- @ToDo Create spell list just in case.
-- @ToDo SetUp should remove any buffs


local args = { ... }

local test = require('TestSuite.mqTest')
test.arguments(args)

local mq = require('mq')
local Me = mq.TLO.Me

test.spawn.AARank = function()
    test.equal(Me.AARank(), 3)
end

test.spawn.AATitle = function()
    test.equal(Me.AATitle(), '')
end

test.spawn.ActorDef = function()
    test.equal(Me.ActorDef(), 'TRM_ACTORDEF')
end

test.spawn.Address = function()
    test.is_nil(Me.Address())
end

test.spawn.AFK = function()
    if(Me.AFK()) then
        mq.cmd.afk()
    end
    test.is_false(Me.AFK())
    mq.cmd.afk()
end

test.spawn.Agressive = function()
    test.is_false(Me.Aggressive())
end

test.spawn.Animation = function()
    test.is_number(Me.Animation())
end

test.spawn.Anonymous = function()
    if(Me.Anonymous()) then
        mq.cmd.anon()
    end
    test.is_false(Me.Anonymous())
end

test.spawn.Assist = function()
    test.is_false(Me.Assist())
end

test.spawn.AssistName = function()
    test.equal(Me.AssistName(), '')
end

test.spawn.bAlwaysShowAura = function()
    test.is_false(Me.bAlwaysShowAura())
end

test.spawn.bBetaBuffed = function()
    test.is_false(Me.bBetaBuffed())
end

test.spawn.BearingToTarget = function()
    ---Issue with this member.  Always returns 0
    ---See Issue #330
end

test.spawn.Binding = function()
    test.is_false(Me.Binding())
end

test.spawn.Blind = function()
    test.equal(Me.Blind(),0)
end

test.spawn.Body = function()
    test.equal(Me.Body(), 1)
end

test.broken.skip = true
test.broken.bShowHelm = function()
    test.is_true(Me.bShowHelm())
end

test.spawn.bStationary = function()
    test.is_false(Me.bStationary())
end

test.spawn.bTempPet = function()
    test.is_false(Me.bTempPet())
end

test.spawn.Buyer = function()
    test.is_false(Me.Buyer())
end

test.spawn.bWaitingForPort = function()
    test.is_false(Me.bWaitingForPort())
end

test.spawn.CachedBuff = function()
    mq.cmd.target() -- need to target a spawn (character) to cache buffs
    mq.cmd.cast(1)
    mq.delay(5000)
    test.equal(Me.CachedBuff('Gather Shadows').ID(), 522)
    mq.delay(500)
    mq.cmd.removebuff('Gather Shadows')
    mq.cmd.keypress('esc')
end

test.spawn.CachedBuffCount = function()
    test.not_equal(Me.CachedBuffCount(), 0)
end

test.spawn.CanSplashLand = function()
    test.is_true(Me.CanSplashLand())
end

test.spawn.Casting = function()
    test.is_nil(Me.Casting())
end

test.spawn.CeilingHeightAtCurrLocation = function()
    test.is_number(Me.CeilingHeightAtCurrLocation())
end

test.spawn.Class = function()
    test.equal(Me.Class(), 5)
end

test.spawn.CleanName = function()
    test.is_string(Me.CleanName())
end

test.spawn.CollisionCounter = function()
    test.is_number(Me.CollisionCounter())
end

test.spawn.CombatSkillTicks = function()
    test.is_nil(Me.CombatSkillTicks())
end

test.spawn.ConColor = function()
    test.equal(Me.ConColor(), 'WHITE')
end

test.spawn.ContractorID = function()
    test.equal(Me.ContractorID(), 0)
end

test.spawn.CorpseDragCount = function()
    test.equal(Me.CorpseDragCount(), 0)
end

test.spawn.CurrentEndurance = function()
    test.equal(Me.CurrentEndurance(), 29423)
end

test.spawn.CurrentHps = function()
    test.equal(Me.CurrentHPs(), 34736)
end

test.spawn.CurrentMana = function()
    --- Casting spells during testing means we have to use some fuzzy logic
    test.almost_equal(Me.CurrentMana(), 29000, 2000)
end

test.spawn.D = function()
    test.is_number(Me.D())
end

test.spawn.Dead = function()
    test.is_false(Me.Dead())
end

test.spawn.Diety = function()
    test.equal(Me.Deity(), 203)
end

test.spawn.DisplayName = function()
    test.is_string(Me.DisplayName())
end

test.spawn.Distance = function()
    test.equal(Me.Distance(), 0)
end

test.spawn.Distance3D = function()
    test.equal(Me.Distance3D(), 0)
end

test.spawn.DistanceN = function()
    test.equal(Me.DistanceN(), 0)
end

test.spawn.DistancePredict = function()
    test.equal(Me.DistancePredict(), 0)
end

test.spawn.DistanceU = function()
    test.equal(Me.DistanceU(), 0)
end

test.spawn.DistanceW = function()
    test.equal(Me.DistanceW(), 0)
end

test.spawn.DistanceX = function()
    test.equal(Me.DistanceX(), 0)
end

test.spawn.DistanceY = function()
    test.equal(Me.DistanceY(), 0)
end

test.spawn.DistanceZ = function()
    test.equal(Me.DistanceZ(), 0)
end

test.spawn.DraggingPlayer = function()
    test.is_false(Me.DraggingPlayer())
end

test.spawn.DragName = function()
    test.is_nil(Me.DragNames())
end

test.spawn.Ducking = function()
    test.is_false(Me.Ducking())
end

test.spawn.E = function()
    test.is_number(Me.E())
end

test.spawn.EQLoc = function()
    test.equal(Me.EQLoc(), string.match(Me.EQLoc(), "^%D?%d+%.%d+,%D+%d+%.%d+,%D+%d+%.%d+"))
end

test.spawn.Equipment = function()
    test.is_nil(Me.Equipment())
end

test.spawn.FD = function()
    test.equal(Me.FD(), 0)
end

test.spawn.FeetWet = function()
    test.is_false(Me.FeetWet())
end

test.spawn.Feigning = function()
    test.is_false(Me.Feigning())
end

test.spawn.Fleeing = function()
    --This member is better suited for mobs, and  has inconsitent output for characters.
    test.is_boolean(Me.Fleeing())
end

test.spawn.FloorZ = function()
    test.is_number(Me.FloorZ())
end

test.spawn.following = function()
    test.is_nil(Me.Following())
end

test.spawn.Gender = function()
    test.equal(Me.Gender(), 'male')
end

test.spawn.GM = function()
    test.is_false(Me.GM())
end

test.spawn.GMRank = function()
    test.equal(Me.GMRank(), 0)
end

test.spawn.GroupLeader = function()
    test.is_false(Me.GroupLeader())
end

test.spawn.Guild = function()
    test.is_nil(Me.Guild())
end

test.spawn.GuildStatus = function()
    test.is_nil(Me.GuildStatus())
end

test.spawn.Heading = function()
    test.almost_equal(Me.Heading(), 180, 180)
end

test.spawn.HeadingTo = function()
    test.equal(Me.HeadingTo(), 90)
end

test.spawn.HeadingToLoc = function()
    test.almost_equal(Me.HeadingToLoc(0,0)(), 180, 180)
end

test.spawn.Height = function()
    test.is_number(Me.Height())
end

test.spawn.Holding = function()
    test.is_true(Me.Holding())
end

test.spawn.HoldingAnimation = function()
    test.equal(Me.HoldingAnimation(), 3)
end

test.spawn.Hovering = function()
    test.is_false(Me.Hovering())
end

test.spawn.ID = function()
    test.is_number(Me.ID())
end

test.spawn.InPvPArea = function()
    test.equal(Me.InPvPArea(), 0)
end

test.spawn.Invis = function()
    test.is_false(Me.Invis())
end

test.spawn.Invited = function()
    test.is_false(Me.Invited())
end

test.spawn.Inviter = function()
    test.equal(Me.Inviter(), '')
end

test.spawn.IsBeserk = function()
    test.equal(Me.IsBerserk(), 0)
end

test.spawn.IsPassenger = function()
    test.equal(Me.IsPassenger(), 0)
end

test.spawn.IsSummoned = function()
    test.is_false(Me.IsSummoned())
end

test.spawn.LastCastNum = function()
    test.equal(Me.LastCastNum(), 0)
end

test.spawn.LastCastTime = function()
    test.is_number(Me.LastCastTime())
end

test.spawn.Levitating = function()
    test.is_false(Me.Levitating())
end

test.spawn.LFG = function()
    test.is_false(Me.LFG())
end

test.spawn.Light = function()
    test.equal(Me.Light(), 'LS')
end

test.spawn.LineOfSight = function()
    test.is_true(Me.LineOfSight())
end

test.spawn.Linkdead = function()
    test.is_false(Me.Linkdead())
end

test.spawn.Loc = function()
    test.equal(Me.Loc(), string.match(Me.Loc(), "^%D?%d+%.%d+,%D+%d+%.%d+"))
end

test.spawn.LocXY = function()
    test.equal(Me.LocYX(), string.match(Me.LocYX(), "^%D?%d+,%D+%d+"))
end

test.spawn.LocXYZ = function()
    test.equal(Me.LocYXZ(), string.match(Me.LocYXZ(), "^%D?%d+%.%d+,%D+%d+%.%d+,%D+%d+%.%d+"))
end

test.spawn.Look = function()
    test.almost_equal(Me.Look(), 0, 128)
end

test.spawn.Mark = function()
    test.is_nil(Me.Mark())
end

test.spawn.Master = function()
    test.is_nil(Me.Master())
end

test.spawn.maxEndurance = function()
    test.almost_equal(Me.MaxEndurance(), 29243, 2000)
end

test.spawn.MaxHPs = function()
    test.almost_equal(Me.MaxHPs(), 34736, 2500)
end

test.spawn.MaxMana = function()
    test.almost_equal(Me.MaxMana(), 29912, 2000)
end

test.spawn.MaxRange = function()
    test.equal(Me.MaxRange(), 16)
end

test.spawn.MaxRangeTo = function()
    test.equal(Me.MaxRangeTo(), 16)
end

test.spawn.MercID = function()
    test.equal(Me.MercID(), 0)
end

test.spawn.Mount = function()
    test.is_nil(Me.Mount())
end

test.spawn.Moving = function()
    test.is_false(Me.Moving())
end

test.spawn.MQLoc = function()
    test.equal(Me.MQLoc(), string.match(Me.MQLoc(), "^%D?%d+%.%d+,%D+%d+%.%d+,%D+%d+%.%d+"))
end

test.spawn.N = function()
    test.is_number(Me.N())
end

test.spawn.Named = function()
    test.is_false(Me.Named())
end

test.spawn.NearestSpawn = function()
    test.equal(Me.NearestSpawn('radius 0 pc')(), Me.CleanName())
end

test.broken.Next = function()
    --Issue #336
end

test.spawn.Owner = function()
    test.is_nil(Me.Owner())
end

test.spawn.PctEndurance = function()
    test.equal(Me.PctEndurance(), 100)
end

test.spawn.PctHPs = function()
    test.equal(Me.PctHPs(), 100)
end

test.spawn.PctMana = function()
    test.almost_equal(Me.PctMana(), 100, 5)
end

test.spawn.Pet = function()
    test.equal(Me.Pet(), 'NO PET')
end

test.spawn.PlayerState = function()
    test.equal(Me.PlayerState(), 64)
end

test.spawn.Prev = function()
    test.is_string(Me.Prev())
end

test.spawn.Primary = function()
    test.equal(Me.Primary(), 11801)
end

test.spawn.pTouchSwitch = function()
    test.equal(Me.pTouchingSwitch(), 0)
end

test.spawn.Race = function()
    test.equal(Me.Race(), 9)
end

test.spawn.Roleplaying = function()
    test.is_false(Me.Roleplaying())
end

test.spawn.S = function()
    test.is_number(Me.S())
end

test.spawn.Secondary = function()
    test.equal(Me.Secondary(), 11706)
end

test.spawn.SeeInvis = function()
    test.is_nil(Me.SeeInvis())
end

test.spawn.Sitting = function()
    test.is_false(Me.Sitting())
end

test.spawn.Sneaking = function()
    test.is_false(Me.Sneaking())
end

test.spawn.SpawnStatus = function()
    test.is_nil(Me.SpawnStatus())
end

test.spawn.Speed = function()
    test.equal(Me.Speed(), 0)
end

test.spawn.Standing = function()
    test.is_true(Me.Standing())
end

test.spawn.StandState = function()
    test.equal(Me.StandState(), 100)
end

test.spawn.State = function()
    test.equal(Me.State(), 'STAND')
end

test.spawn.Stuck = function()
    test.is_false(Me.Stuck())
end

test.spawn.Stunned = function()
    test.is_false(Me.Stunned())
end

test.spawn.Suffix = function()
    test.equal(Me.Suffix(), '')
end

test.spawn.Surname = function()
    test.equal(Me.Surname(), '')
end

test.spawn.Targetable = function()
    test.is_true(Me.Targetable())
end

test.spawn.TargetOfTarget = function()
    mq.cmd.target()
    mq.delay(1500)
    test.equal(Me.TargetOfTarget(), Me.CleanName())
    mq.cmd.keypress('esc')
    mq.delay(1000)
    test.is_nil(Me.TargetOfTarget())
end

test.spawn.TimeBeenDead = function()
    test.is_number(Me.TimeBeenDead())
end

test.spawn.Title = function()
    test.equal(Me.Title(), '')
end

test.spawn.Trader = function()
    test.is_false(Me.Trader())
end

test.spawn.Type = function()
    test.equal(Me.Type(), 'PC')
end

test.spawn.U = function()
    test.is_number(Me.U())
end

test.spawn.Underwater = function()
    test.is_false(Me.Underwater())
end

test.spawn.W = function()
    test.is_number(Me.W())
end

test.spawn.WarCry = function()
    test.is_number(Me.WarCry())
end

test.spawn.X = function()
    test.is_number(Me.X())
end

test.spawn.Y = function()
    test.is_number(Me.X())
end

test.spawn.Z = function()
    test.is_number(Me.Z())
end

test.character.setup = function()
    mq.cmd.notify('ActionsWindow ACP_FirstAbilityButton rightmouseup')
    mq.delay('1s')
    mq.cmd.notify('SkillsSelectWindow SKSW_SkillSelectorList listselect 1')
    mq.delay('1s')
end

test.character.AAExp = function()
    test.equal(Me.AAExp(),0)
end

test.character.AAPoints = function()
    test.equal(Me.AAPoints(), 0)
end

test.character.AAPointsAssigned = function()
    test.equal(Me.AAPointsAssigned(), 5615)
end
test.character.AAPointsSpent = function()
    test.equal(Me.AAPointsSpent(), 0)
end

test.character.AAPointsTotal = function()
    test.equal(Me.AAVitality(), 0)
end

test.character.AAVitality = function()
    test.equal(Me.AAVitality(), 0)
end

test.character.Ability = function()
    test.equal(Me.Ability('Bind Wound')(), 9)
    test.equal(Me.Ability(9)(), 'Bind Wound')
end

test.character.AbilityReady = function()
    test.is_true(Me.AbilityReady('Bind Wound')())
    test.is_true(Me.AbilityReady(9)())
    test.is_false(Me.AbilityReady(2)()) -- Button 2 not set expect false
end

test.character.AccuracyBonus = function()
    test.equal(Me.AccuracyBonus(), 150)
end

test.character.ActiveDisc = function()
    test.is_nil(Me.ActiveDisc())
end

test.character.ActiveFavorCost = function()
    test.is_nil(Me.ActiveFavorCost())
end

test.character.Aego = function()
    test.is_nil(Me.Aego())
end

test.character.AggroLock = function()
    test.is_nil(Me.AggroLock())
end

test.character.AGI = function()
    test.equal(Me.AGI(), 612)
end

test.character.AltAbility = function()
    test.equal(Me.AltAbility('Leech Touch').ID(), 87)
    test.equal(Me.AltAbility(87).Name(), 'Leech Touch')
end

test.character.AltAbilityReady = function()
    test.is_true(Me.AltAbilityReady('Leech Touch')())
    mq.cmd.alt('act 1212')
    mq.delay(1000)
    test.is_false(Me.AltAbilityReady(1212)())
end

test.character.AltAbilityTimer = function()
    -- Should be 0 since it is not on cooldown
    test.equal(Me.AltAbilityTimer('Leech Touch')(), 0)

    -- Cast Summon Clockwork Banker if not already summoned
    mq.cmd.alt('act 8130')
    mq.delay(2000)
    test.assert(Me.AltAbilityTimer(8130)() > 0)
end

test.character.AltCurrency = function()
    test.equal(Me.AltCurrency('Orux')(), 0)
end

test.broken.AltTimerReady = function()
    -- We don't use this in our tests, so
    -- should be true since it is never on cooldown
    test.is_true(Me.AltTimerReady('Leech Touch')())

    -- Cast Summon Clockwork Banker if not already summoned
    mq.cmd.alt('act 8130')
    mq.delay(5000)
    test.is_false(Me.AltTimerReady(8130)())
end

test.character.AmIGroupLeader = function()
    test.is_nil(Me.AmIGroupLeader())
end

test.character.AssistComplete = function()
    test.is_false(Me.AssistComplete())
end

test.character.AttackBonus = function()
    test.equal(Me.AttackBonus(), 484)
end

test.character.AttackSpeed = function()
    test.equal(Me.AttackSpeed(), 143)
end

test.character.Aura = function()
    test.is_nil(Me.Aura())
end

test.character.AutoFire = function()
    test.is_false(Me.AutoFire())
end

test.character.AvoidanceBonus = function()
    test.equal(Me.AvoidanceBonus(), 100)
end

test.character.Bank = function()
    test.equal(Me.Bank(1)(), 'Backpack*')
end

test.character.BaseAGI = function()
    test.equal(Me.BaseAGI(), 83)
end

test.character.BaseCHA = function()
    test.equal(Me.BaseCHA(), 45)
end

test.character.BaseDEX = function()
    test.equal(Me.BaseDEX(), 75)
end

test.character.BaseINT = function()
    test.equal(Me.BaseINT(), 62)
end

test.character.BaseSTA = function()
    test.equal(Me.BaseSTA(), 134)
end

test.character.BaseSTR = function()
    test.equal(Me.BaseSTR(), 118)
end

test.character.BaseWIS = function()
    test.equal(Me.BaseWIS(), 60)
end

test.character.Beneficial = function()
    test.equal(Me.Beneficial(), 0)
end

test.character.Book = function()
    test.equal(Me.Book(1)(), 'Gather Shadows')
    test.equal(Me.Book('Gather Shadows')(), 1)
end

test.character.BoundLocation = function()
    test.is_nil(Me.BoundLocation())
end

test.character.Brells = function()
    test.is_nil(Me.Brells())
end

test.character.Buff = function()
    mq.cmd.cast(1)
    repeat mq.delay(100) until Me.SpellReady(1)()
    test.equal(Me.Buff(1).Name(), 'Gather Shadows')
    test.equal(Me.Buff('Gather Shadows').ID(), 1)
    mq.cmd.removebuff('Gather Shadows')
end

test.character.CareerFavor = function()
    test.equal(Me.CareerFavor(), 0)
end

test.character.Cash = function()
    test.equal(Me.Cash(), 0)
end

test.character.CashBank = function()
    test.equal(Me.CashBank(), 0)
end

test.character.CHA = function()
    test.equal(Me.CHA(), 609)
end

test.character.Charmed = function()
    test.is_nil(Me.Charmed())
end

test.character.Chronobines = function()
    test.equal(Me.Chronobines(), 0)
end

test.character.ClairvoyanceBonus = function()
    test.equal(Me.ClairvoyanceBonus(), 261)
end

test.character.Clarity = function()
    test.is_nil(Me.Clarity())
end

test.character.Combat = function()
    test.is_false(Me.Combat())
end

test.character.CombatAbility = function()
    test.equal(Me.CombatAbility(1)(), 'Leechcurse Discipline')
    test.equal(Me.CombatAbility('Leechcurse Discipline')(), 1)
end

test.character.CombatAbilityReady = function()
    test.is_true(Me.CombatAbilityReady(1)())
end

test.character.CombatAbilityTimer = function()
    test.equal(Me.CombatAbilityTimer(1)(), 0)
end

test.character.CombatEffectsBonus = function()
    test.equal(Me.CombatEffectsBonus(), 100)
end

test.character.CombatState = function()
    test.equal(Me.CombatState(), 'ACTIVE')
    mq.cmd.sit()
    mq.delay(1000) -- This short delay only works in POK?
    test.equal(Me.CombatState(), 'RESTING')
    mq.cmd.stand()
end

test.character.Commemoratives = function()
    test.equal(Me.Commemoratives(), 0)
end

test.character.Copper = function()
    test.equal(Me.Copper(), 0)
end

test.character.CopperBank = function()
    test.equal(Me.CopperBank(), 0)
end

test.character.Corrupted = function()
    test.is_nil(Me.Corrupted())
end

test.character.CountBuffs = function()
    -- Clean up any buffs
    for i = 1, 40, 1 do
        mq.cmd.removebuff(Me.Buff(i).Name())
    end

    test.equal(Me.CountBuffs(), 0)

end

test.character.Counters = function()
    test.is_nil(Me.Counters())
end

test.character.CountSongs = function()
    test.equal(Me.CountSongs(), 0)
end

test.character.Crippled = function()
    test.is_nil(Me.Crippled())
end

test.character.CurrentEndurance = function()
    test.equal(Me.CurrentEndurance(), 29423)
end

test.character.CurrentFavor = function()
    test.equal(Me.CurrentFavor(), 0)
end

test.character.CurrentHPs = function()
    test.equal(Me.CurrentHPs(), 34736)
end

test.character.CurrentMana = function()
    test.almost_equal(Me.CurrentMana(), 29912, 2500)
end

test.character.CurrentWeight = function()
    test.equal(Me.CurrentWeight(), 49)
end

test.character.Cursed = function()
    test.is_nil(Me.Cursed())
end

test.character.CursorCopper = function()
    test.equal(Me.CursorCopper(), 0)
end

test.character.CursorGold = function()
    test.equal(Me.CursorGold(), 0)
end

test.character.CursorPlatinum = function()
    test.equal(Me.CursorPlatinum(), 0)
end

test.character.CursorSilver = function()
    test.equal(Me.CursorSilver(), 0)
end

test.character.DamageShieldBonus = function()
    test.equal(Me.DamageShieldBonus(), 35)
end

test.character.DamageShieldMitigationBonus = function()
    test.equal(Me.DamageShieldMitigationBonus(), 25)
end

test.character.Dar = function()
    test.equal(Me.Dar(), 0)
end

test.character.DEX = function()
    test.equal(Me.DEX(), 616)
end

test.character.Diseased = function()
    test.is_nil(Me.Diseased())
end

test.character.DoTShieldBonus = function()
    test.equal(Me.DoTShieldBonus(), 35)
end

test.character.Doubloons = function()
    test.equal(Me.Doubloons(), 0)
end

test.character.Downtime = function()
    test.equal(Me.Downtime(), 0)
end

test.character.Drunk = function()
    test.equal(Me.Drunk(), 0)
end

test.character.DSed = function()
    test.is_nil(Me.DSed())
end

test.character.EbonCrystals = function()
    test.equal(Me.EbonCrystals(),0)
end

test.character.Endurance = function()
    test.equal(Me.Endurance(), 29423)
end

test.character.EnduranceBonus = function()
    test.equal(Me.EnduranceBonus(), 18473)
end

test.character.EnduranceRegen = function()
    test.equal(Me.EnduranceRegen(), 33)
end

test.character.EnduranceRegenBonus = function()
    test.equal(Me.EnduranceRegenBonus(), 0)
end

test.character.EnergyCrystals = function()
    test.equal(Me.EnergyCrystals(), 0)
end

test.character.Exp = function()
    test.equal(Me.Exp(), 60733)
end

test.character.ExpansionFlags = function()
    test.equal(Me.ExpansionFlags(), 33554431)
end

test.character.Faycites = function()
    test.equal(Me.Faycites(), 0)
end

test.character.Fellowship = function()
    test.equal(Me.Fellowship(), 'FALSE')
end

test.character.Fists = function()
    test.equal(Me.Fists(), 0)
end

test.character.Focus = function()
    test.is_nil(Me.Focus())
end

test.character.FreeBuffSlots = function()
    test.equal(Me.FreeBuffSlots(), 30)
    mq.cmd.cast(1)
    repeat mq.delay(100) until Me.SpellReady(1)()
    test.equal(Me.FreeBuffSlots(), 29)
    mq.cmd.removebuff('Gather Shadows')
end

test.character.FreeInventory = function()
    test.equal(Me.FreeInventory(), 52)
end

test.character.Gem = function()
    test.equal(Me.Gem(1)(), 'Gather Shadows')
end

test.character.GemTimer = function()
    test.equal(Me.GemTimer(1)(), 0)
    mq.cmd.cast(1)
    mq.delay(1000)
    test.not_equal(Me.GemTimer(1)(), 0)
    repeat mq.delay(100) until Me.SpellReady(1)()
    mq.cmd.removebuff('Gather Shadows')
end

test.character.Gold = function()
    test.equal(Me.Gold(), 0)
end

test.character.GoldBank = function()
    test.equal(Me.GoldBank(), 0)
end

test.character.GroupAssistTarget = function()
    test.is_nil(Me.GroupAssistTarget())
end

test.character.Grouped = function()
    test.is_false(Me.Grouped())
end

test.character.GroupList = function()

end

test.character.GroupMarkNPC = function()

end

test.character.GroupSize = function()

end

test.character.Growth = function()

end

test.character.GuildID = function()

end

test.character.GukEarned = function()

end

test.character.Haste = function()

end

test.character.Hasted = function()

end

test.character.HaveExpansion = function()

end

test.character.HealAmountBonus = function()

end

test.character.HeroicAGIBonus = function()

end

test.character.HeroicCHABonus = function()

end

test.character.HeroicDEXBonus = function()

end

test.character.HeroicINTBonus = function()

end

test.character.HeroicSTABonus = function()

end

test.character.HeroicSTRBonus = function()

end

test.character.HeroicWISBonus = function()

end

test.character.HPBonus = function()

end

test.character.HPRegen = function()

end

test.character.HPRegenBonus = function()

end

test.character.Hunger = function()

end

test.character.HybridHP = function()

end

test.character.InInstance = function()

end

test.character.Instance = function()

end

test.character.INT = function()

end

test.character.Inventory = function()

end

test.character.ItemReady = function()

end

test.character.Krono = function()

end

test.character.LADelegateMA = function()

end

test.character.LADelegateMarkNPC = function()

end

test.character.LAFindPathPC = function()

end

test.character.LAHealthEnhancement = function()

end

test.character.LAHealthRegen = function()

end

test.character.LAHoTT = function()

end

test.character.LAInspectBuffs = function()

end

test.character.LAManaEnhancement = function()

end

test.character.LAMarkNPC = function()

end

test.character.Language = function()

end

test.character.LanguageSkill = function()

end

test.character.LANPCHealth = function()

end

test.character.LAOffenseEnhancement = function()

end

test.character.LargestFreeInventory = function()

end

test.character.LASpellAwareness = function()

end

test.character.LDoNPoints = function()

end

test.character.Malod = function()

end

test.character.ManaBonus = function()

end

test.character.ManaRegen = function()

end

test.character.ManaRegenBonus = function()

end

test.character.MaxBuffSlots = function()

end

test.character.MaxEndurance = function()

end

test.character.MaxHPs = function()

end

test.character.MaxMana = function()

end

test.character.MercAAExp = function()

end

test.character.Mercenary = function()

end

test.character.MercenaryStance = function()

end

test.character.MercListInfo = function()

end

test.character.Mezzed = function()

end

test.character.MirEarned = function()

end

test.character.MMEarned = function()

end

test.character.Moving = function()

end

test.character.Nobles = function()

end

test.character.NumGems = function()

end

test.character.Orux = function()

end

test.character.PctAAExp = function()

end

test.character.PctAAVitality = function()

end

test.character.PctAggro = function()

end

test.character.PctEndurance = function()

end

test.character.PctExp = function()

end

test.character.PctHPs = function()

end

test.character.PctMana = function()

end

test.character.PctMercAAExp = function()

end

test.character.PctVitality = function()

end

test.character.PetBuff = function()

end

test.character.Phosphenes = function()

end

test.character.Phosphites = function()

end

test.character.PiecesofEight = function()

end

test.character.Platinum = function()

end

test.character.PlatinumBank = function()

end

test.character.PlatinumShared = function()

end

test.character.Poisoned = function()

end

test.character.PracticePoints = function()

end

test.character.Pred = function()

end

test.character.RadiantCrystals = function()

end

test.character.RaidAssistTarget = function()

end

test.character.RaidMarkNPC = function()

end

test.character.RangedReady = function()

end

test.character.Regen = function()

end

test.character.RevDSed = function()

end

test.character.Rooted = function()

end

test.character.RujEarned = function()

end

test.character.Running = function()

end

test.character.SE = function()

end

test.character.SecondaryAggroPlayer = function()

end

test.character.SecondaryPctAggro = function()

end

test.character.ShieldingBonus = function()

end

test.character.Shining = function()

end

test.character.Shrouded = function()

end

test.character.Silver = function()

end

test.character.SilverBank = function()

end

test.character.Skill = function()

end

test.character.SkillBase = function()

end

test.character.SkillCap = function()

end

test.character.Skin = function()

end

test.character.Slowed = function()

end

test.character.Snared = function()

end

test.character.Song = function()

end

test.character.SPA = function()

end

test.character.Spawn = function()

end

test.character.SpellDamageBonus = function()

end

test.character.SpellInCooldown = function()

end

test.character.SpellReady = function()

end

test.character.SpellShieldBonus = function()

end

test.character.STA = function()

end

test.character.STR = function()

end

test.character.Strength = function()

end

test.character.StrikeThroughBonus = function()

end

test.character.Stunned = function()

end

test.character.StunResistBonus = function()

end

test.character.Subscription = function()

end

test.character.SV = function()

end

test.character.svChromatic = function()

end

test.character.svCold = function()

end

test.character.svCorruption = function()

end

test.character.svDisease = function()

end

test.character.svFire = function()

end

test.character.svMagic = function()

end

test.character.svPoison = function()

end

test.character.svPrismatic = function()

end

test.character.Symbol = function()

end

test.character.TakEarned = function()

end

test.character.TargetOfTarget = function()
    mq.cmd.target()
    mq.delay(1500)
    test.equal(Me.TargetOfTarget(), Me.CleanName())
    mq.cmd.keypress('esc')
    mq.delay(1000)
    test.is_nil(Me.TargetOfTarget())
end

test.character.Tashed = function()

end

test.character.Thirst = function()

end

test.character.TributeActive = function()

end

test.character.TributeTimer = function()

end

test.character.UseAdvancedLooting = function()

end

test.character.Vitality = function()

end

test.character.WIS = function()

end

test.character.XTarget = function()

end

test.character.XTargetSlots = function()

end

test.character.ZoneBound = function()

end

test.character.ZoneBoundX = function()

end

test.character.ZoneBoundY = function()

end

test.character.ZoneBoundZ = function()

end

test.character.Zoning = function()

end

test.summary()