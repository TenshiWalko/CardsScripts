-- Nakaizoku Ship - Going Anny
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,4,2,nil,nil,99)

	-- Attach 1 "Nakaizoku" monster from hand or Deck as material during each Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1)
	e1:SetTarget(s.mttg)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)

	-- Quick Effect: Special Summon 1 "Nakaizoku" monster attached as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

-- Target: Prepare to attach a "Nakaizoku" monster from hand or Deck
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
end

-- Filter: Check for "Nakaizoku" monsters in hand or Deck
function s.mtfilter(c)
	return c:IsSetCard(0x315) and not c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER)
end

-- Operation: Attach 1 "Nakaizoku" monster from hand or Deck as Xyz material
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.mtfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(e:GetHandler(),g)
	end
end

-- Target: Prepare to Special Summon a "Nakaizoku" monster attached as material
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayCount()>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_OVERLAY)
end

-- Operation: Special Summon 1 "Nakaizoku" monster attached as material
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=c:GetOverlayGroup()
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		end
	end
end
