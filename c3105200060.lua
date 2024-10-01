-- Elemental HERO Colossal Neos
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- Your opponent cannot target Set cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetValue(s.efflimit)
	c:RegisterEffect(e1)

	-- Quick Effect: Discard 1 card to return 1 opponent's card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

s.listed_names={CARD_NEOS}

-- Fusion materials: "Elemental HERO Neos" + 1 Warrior EARTH monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
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

-- Opponent cannot target Set cards
function s.efflimit(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandlerPlayer()~=e:GetHandlerPlayer()
end

-- Discard 1 card as cost
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Target 1 card your opponent controls to return to the hand
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

-- Return 1 card your opponent controls to the hand
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
