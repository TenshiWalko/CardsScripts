-- Elemental HERO Incandescent Neos
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- Quick effect: Destroy and apply effects based on type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end

s.listed_names={CARD_NEOS}

-- Fusion materials: "Elemental HERO Neos" + 1 Warrior LIGHT monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
end

-- Contact Fusion condition (shuffling into Deck)
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

-- Quick effect condition (only during Main Phase)
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

-- Target 1 card your opponent controls to destroy
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Destroy and apply effect based on the destroyed card's type
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		if tc:IsType(TYPE_MONSTER) then
			-- If it's a monster, gain 500 ATK
			local c=e:GetHandler()
			if c:IsFaceup() and c:IsRelateToEffect(e) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(500)
				c:RegisterEffect(e1)
			end
		elseif tc:IsType(TYPE_SPELL) then
			-- If it's a Spell, reveal the entire Extra Deck and then banish 1 card face-down
			local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
			if #g>0 then
				Duel.ConfirmCards(tp,g) -- Reveal all cards in the Extra Deck
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local sg=g:Select(tp,1,1,nil)
				Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)
			end
		elseif tc:IsType(TYPE_TRAP) then
			-- If it's a Trap, banish 1 card from the GY
			local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
			if #g>0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local rg=g:Select(tp,1,1,nil)
				Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
