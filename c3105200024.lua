--Red-Eyes Fury Flame
local s,id=GetID()

s.listed_names={CARD_REDEYES_B_DRAGON}
s.listed_names={CARD_FLAME_SWORDSMAN}

function s.initial_effect(c)
	--Special Summon 1 "Red-Eyes" monster from your Deck, GY, or banishment
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Fusion Summon 1 Fusion Monster including a "Red-Eyes" monster as material
	local params={handler=c,extrafil=s.fmatextra}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCost(aux.selfbanishcost)
	e2:SetTarget(Fusion.SummonEffTG(params))
	e2:SetOperation(Fusion.SummonEffOP(params))
	c:RegisterEffect(e2)
end

function s.spfilter(c,e,tp,any)
	return (c:IsSetCard(0x3b) or c:ListsCode(CARD_FLAME_SWORDSMAN))  and (any or c:IsCode(CARD_REDEYES_B_DRAGON))
		and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local any=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REDEYES_B_DRAGON),tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,any) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Dragon monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WARRIOR) or c:IsRace(RACE_MACHINE)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Clock Lizard check
	aux.addTempLizardCheck(c,tp,function(e,c) return not (c:IsOriginalRace(RACE_DRAGON) or c:IsOriginalRace(RACE_WARRIOR) or c:IsOriginalRace(RACE_MACHINE))  end)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local any=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REDEYES_B_DRAGON),tp,LOCATION_ONFIELD,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,any)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

function s.fmatextra(e,tp,mg)
	return nil,s.extramatcheck
end

function s.extramatcheck(tp,sg,fc)
	return sg:IsExists(s.fusionfilter,1,nil,fc)
end

function s.fusionfilter(c,fc)
	return c:IsSetCard(0x3b) or (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE))
end
