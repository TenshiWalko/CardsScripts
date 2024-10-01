-- Elemental HERO Neos Blaze
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon rule (Contact Fusion)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- Cannot be destroyed by battle if there is a Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)

	-- Gain 300 ATK for each Spell/Trap on the field and in the GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Destroy all set cards during the End Phase if opponent controls more Set cards
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_NEOS}
-- Fusion materials: "Elemental HERO Neos" + 1 Warrior FIRE monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
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

-- Condition for indestructibility by battle (if a Field Spell is on the field)
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FIELD),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end


-- Gain 300 ATK for each Spell/Trap on the field and in the GY
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsType,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil,TYPE_SPELL+TYPE_TRAP)
	return g:GetCount()*300
end

-- End Phase condition: If opponent controls more Set cards than you
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tpSet = Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
	local oppSet = Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	return oppSet > tpSet
end

-- Target Set cards for destruction
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

-- Destroy all Set cards on the field
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
