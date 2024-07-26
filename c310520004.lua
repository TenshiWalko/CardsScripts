--Magician's Book
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1, {id, 1})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Banish Spell and add a card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_REMOVE + CATEGORY_TOHAND + CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id, 2})
	e2:SetCondition(s.effectcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

s.listed_names={CARD_DARK_MAGICIAN}
s.listed_series={0x13a}

-- Condition for Special Summon
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.spfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_DARK_MAGICIAN) or (c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(4) and not c:IsCode(id)))
end

-- Target for Special Summon
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- Operation for Special Summon
function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

-- Condition for effect activation
function s.effectcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- Cost to banish a Normal or Quick-Play Spell
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_HAND + LOCATION_GRAVE, 0, 1, 1, nil)
	if #g > 0 then
		Duel.Remove(g, POS_FACEUP, REASON_COST)
		e:SetLabelObject(g:GetFirst())
	end
end

function s.cfilter(c)
	return c:IsType(TYPE_SPELL)
		and not (c:IsType(TYPE_CONTINUOUS) or c:IsType(TYPE_RITUAL) or c:IsType(TYPE_EQUIP) or c:IsType(TYPE_FIELD))
		and c:IsAbleToRemoveAsCost()
end

-- Target for adding a card
function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e:GetLabelObject() and e:GetLabelObject():GetCode()) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end
	 
function s.thfilter(c, code)
	return c:IsAbleToHand() and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:ListsCode(CARD_DARK_MAGICIAN) and not c:IsCode(code)
end

-- Operation to add a card
function s.operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = e:GetLabelObject()
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, tc:GetCode())
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
