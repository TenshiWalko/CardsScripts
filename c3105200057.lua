-- Elemental HERO Windstorm Neos
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_NEOS,s.matfilter)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	--Take no effect damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
	--update atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.val)
	c:RegisterEffect(e3)
	-- Cannot be destroyed by battle if there is a Field Spell
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetCondition(s.indcon)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
end

s.listed_names={CARD_NEOS}

-- Fusion materials: "Elemental HERO Neos" + 1 Warrior WIND monster
function s.matfilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
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

function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end
--update atk
function s.val(e,c)
	local tp=c:GetControler()
	local lp_diff = Duel.GetLP(tp) - Duel.GetLP(1-tp)  
	if lp_diff > 0 then
		return lp_diff  
	else
		return 0 
	end
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_FIELD),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() 
end
