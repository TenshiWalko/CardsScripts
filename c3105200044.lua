--VW-Catapult Tigerjet
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- Fusion Materials
	Fusion.AddProcMix(c,true,true,3105200042,3105200043) -- "V-Tiger Ultrajet" + "W-Wing Megacatapult"
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	
	-- Negate and Return to Hand (Quick Effect)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	
	-- Special Summon up to 2 materials mentioned on a Level 6 LIGHT Machine Fusion Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.listed_names={3105200042,3105200043} --"V-Tiger Ultrajet", "W-Wing Megacatapult"

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.matfilter(c)
	return c:IsAbleToRemoveAsCost() and (c:IsLocation(LOCATION_ONFIELD) or aux.SpElimFilter(c,false,true))
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
end

function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST+REASON_MATERIAL)
end

-- Negate and Return to Hand (Quick Effect)
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_MONSTER) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- Special Summon materials mentioned on a Level 6 LIGHT Machine Fusion Monster
function s.revealfilter(c,e,tp)
	return c:IsLevel(6) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION) and c.material
		and not c:IsPublic() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c)
end

function s.spfilter(c,e,tp,fc)
	return c:IsCode(table.unpack(fc.material)) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,rc)
	Duel.ShuffleExtra(tp)
	e:SetLabelObject(rc)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft==0 then return end
	ft=math.min(ft,2)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ft,nil,e,tp,e:GetLabelObject())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
