-- Elemental HERO Abyssal Neos
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon rule (Contact Fusion)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- Opponent cannot banish cards from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.rmlimit)
	c:RegisterEffect(e1)

	-- Discard 1 card, look at your opponent's hand, and destroy 1 monster with lower ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.discardcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_NEOS}
-- Fusion materials: "Elemental HERO Neos" + 1 Warrior WATER monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
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

-- Prevent opponent from banishing cards from their GY
function s.rmlimit(e,c,tp,r)
	return c:IsLocation(LOCATION_GRAVE)
end

-- Cost: Discard 1 card
function s.discardcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

-- Target: Look at opponent's entire hand and target a monster with lower ATK than this card
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_HAND)
end

-- Operation: Reveal the opponent's entire hand and destroy 1 monster with lower ATK than this card
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g) -- Revela todas las cartas de la mano
		local dg=g:Filter(Card.IsType,nil,TYPE_MONSTER):Filter(Card.IsAttackBelow,nil,c:GetAttack()) -- Filtra los monstruos con ATK menor
		if #dg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=dg:Select(tp,1,1,nil)
			Duel.Destroy(sg,REASON_EFFECT)
		end
		Duel.ShuffleHand(1-tp) -- Baraja la mano del oponente después de seleccionar
	end
end
