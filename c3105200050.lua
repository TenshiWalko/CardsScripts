-- Crystal Cluster - Chimera
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- Fusion Materials
	Fusion.AddProcMixN(c,true,true,s.ffilter,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)

	-- Protection from battle and card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	
	-- ATK boost for each "Crystal Beast" treated as a Spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x1034,fc,sumtype,tp) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end

function s.fusfilter(c,code,fc,sumtype,tp)
	return c:IsSummonCode(fc,sumtype,tp,code) and not c:IsHasEffect(511002961)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.matfilter(c)
	return c:IsSetCard(0x1034) and c:IsFaceup() and (c:IsLocation(LOCATION_ONFIELD))
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
end

function s.contactop(g)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

-- Protection effect: replace destruction by destroying a "Crystal Beast"
function s.repfilter(c)
	return c:IsSetCard(0x1034) and c:IsFaceup() and c:IsDestructable() and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_SZONE))
end

function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT) 
			and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,nil)
	end
	return true
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
			return true
		end
	end
	return false
end

-- ATK boost effect
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_SZONE,0,nil,0x1034)*500
end

