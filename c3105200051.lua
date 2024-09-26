-- Crystal Cluster - Gryphon
local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- Fusion Materials
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
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

	-- Quick Effect: Destroy 1 "Crystal Beast" and return 1 opponent's card to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
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
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD,0,nil)
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

-- Quick Effect: Destroy 1 "Crystal Beast" from S/T Zone and return 1 card
function s.thfilter(c)
	return c:IsSetCard(0x1034) and c:IsFaceup() and c:IsLocation(LOCATION_SZONE) and c:IsDestructable()
end

function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_SZONE,0,1,nil)
			and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil)
	end
	-- Select the "Crystal Beast" to destroy
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_SZONE,0,1,1,nil)
	if #g > 0 then
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	-- Select the opponent's card to return to hand
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local tg=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,1,0,0)
end

function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- Destroy the selected "Crystal Beast" from S/T Zone
	local destroyCard=dg:Filter(s.thfilter,nil):GetFirst()
	if destroyCard and Duel.Destroy(destroyCard,REASON_EFFECT) > 0 then
		-- Send the opponent's card to the hand if destruction was successful
		local rthCard=dg:Filter(Card.IsControler,nil,1-tp):GetFirst()
		if rthCard then
			Duel.SendtoHand(rthCard,nil,REASON_EFFECT)
		end
	end
end

