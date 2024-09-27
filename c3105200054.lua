-- Crystal Reset
local s,id=GetID()
function s.initial_effect(c)
	-- Activate: Shuffle all cards in both Banish Zones into the deck, then draw 2 cards
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

-- Check if you have at least 7 "Crystal Beast" cards with different names in your Banish Zone
function s.cfilter(c)
	return c:IsSetCard(0x1034) and c:IsMonster() and c:IsFaceup() and c:IsLocation(LOCATION_REMOVED)
end

-- Function to check if there are at least 7 different "Crystal Beast" names in the group
function s.hasDifferentNames(group)
	local names = {}
	local count = 0
	for tc in aux.Next(group) do
		local code = tc:GetCode()
		if not names[code] then
			names[code] = true
			count = count + 1
		end
	end
	return count >= 7
end

-- Condition to activate the card
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_REMOVED,0,nil)
	return s.hasDifferentNames(g)
end

-- Target: Shuffle all cards in both Banish Zones into the deck, then draw 2 cards
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,PLAYER_ALL,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end

-- Operation: Shuffle all cards in both Banish Zones into the deck, then draw 2 cards
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,LOCATION_REMOVED)
	if #g > 0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Draw(tp,2,REASON_EFFECT)
	end
end

