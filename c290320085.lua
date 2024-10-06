-- Nakaizoku Shipwright
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon itself from hand if you control a "Nakaizoku" monster (except "Nakaizoku Shipwright")
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Special Summon 1 "Nakaizoku" monster from your hand during the Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.mphcon)
	e2:SetTarget(s.mptg)
	e2:SetOperation(s.mpop)
	c:RegisterEffect(e2)

	-- Xyz Material effect: The first time this card would be destroyed by battle or card effect, it is not destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCondition(s.addcon)
	e3:SetValue(s.indct)
	c:RegisterEffect(e3)
end
s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"

-- Special Summon condition: If you control a "Nakaizoku" monster, except "Nakaizoku Shipwright"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsSetCard(0x315) and not c:IsCode(id)
end

-- Special Summon itself target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon itself operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Condition to Special Summon from hand during the Main Phase
function s.mphcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase()
end

-- Special Summon "Nakaizoku" monster from hand target
function s.mptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

-- Special Summon "Nakaizoku" monster from hand operation
function s.mpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Filter for Special Summon from hand
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x315) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Condition to check if attached to "Nakaizoku" Xyz Monster
function s.addcon(e)
	return e:GetHandler():IsSetCard(0x315) and e:GetHandler():IsType(TYPE_XYZ) 
end
-- Xyz Material effect: Indestructible by battle or card effect once per turn
function s.indct(e,re,r,rp)
	if (r&REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
