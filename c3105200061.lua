--Elemental HERO Divinity Neos
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,false,false,CARD_NEOS,1,s.ffilter,4)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	--Must be Fusion Summoned
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)

	--Cannot be fusion material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	--Cannot be Tributed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e3)

	--Cannot be Destroyed by card effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(1)
	c:RegisterEffect(e4)

	-- Once per turn (Quick Effect): Gain 1000 ATK and copy the effect of a Fusion Monster that lists "Elemental HERO Neos" as material from your Extra Deck or GY.
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.copytg)
	e5:SetOperation(s.copyop)
	c:RegisterEffect(e5)

end

s.listed_names={CARD_NEOS}

function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return (c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and not c:IsCode(CARD_NEOS)) and c:GetAttribute(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp)) and not c:IsType(TYPE_FUSION)
end

function s.fusfilter(c,attr,fc,sumtype,tp)
	return (c:IsRace(RACE_WARRIOR,fc,sumtype,tp) and not c:IsCode(CARD_NEOS)) and c:IsAttribute(attr,fc,sumtype,tp) and not c:IsHasEffect(511002961)
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil)
end

function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

-- Target a Fusion Monster in your GY or Extra Deck that lists "Elemental HERO Neos" as material
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	local b1=Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) -- Check if there are valid targets in the GY
	local b2=Duel.IsExistingMatchingCard(s.extrafilter,tp,LOCATION_EXTRA,0,1,nil) -- Check if there are valid targets in the Extra Deck
	if chk==0 then return b1 or b2 end

	local opt=0
	if b1 and b2 then
		-- If both options are available (GY and Extra Deck), allow the player to choose
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)) -- Option 1: GY, Option 2: Extra Deck
	elseif b2 then
		-- If only Extra Deck is available, automatically select it
		opt=1
	end

	if opt==0 then
		-- Select from Graveyard
		local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	else
		-- Select from Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.extrafilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.SetTargetCard(g)
	end
end

-- Filter for Fusion Monsters that list "Elemental HERO Neos" as material
function s.filter(c)
	return c:IsType(TYPE_FUSION) and c:ListsCode(CARD_NEOS)
end

-- Filter for Fusion Monsters in Extra Deck that list "Elemental HERO Neos" as material
function s.extrafilter(c)
	return c:IsType(TYPE_FUSION) and c:ListsCode(CARD_NEOS) and not c:IsForbidden()
end

-- Gain 1000 ATK and copy the effects of the selected Fusion Monster
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		-- Gain 500 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		c:RegisterEffect(e1)

		-- Copy the effects of the selected Fusion Monster
		local code=tc:GetOriginalCodeRule()
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)

		-- Reset the effect at the end of the turn
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetLabel(cid)
		e2:SetOperation(s.rstop)
		c:RegisterEffect(e2)
	end
end

-- Reset the copied effect
function s.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
