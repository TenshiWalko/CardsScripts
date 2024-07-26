-- Dark Magical Dimension
local s,id=GetID()

s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	c:RegisterEffect(e1)
end

function s.immfilter(c)
	return c:IsFaceup() and (c:IsCode(46986414) or c:ListsCode(46986414))
end

function s.rmfilter1(c,tp)
	return c:IsFaceup() and c:ListsCode(46986414) and Duel.IsExistingMatchingCard(s.rmfilter2,tp,0,LOCATION_MZONE,1,nil)
end

function s.rmfilter2(c)
	return c:IsFaceup() 
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if e:GetLabel()==0 then
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.immfilter(chkc)
		else
			return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.rmfilter1(chkc,tp)
		end
	end
	local b1=Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	end
	e:SetLabel(op)
	if op==0 then 
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g1=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
		local g2=Duel.SelectTarget(tp,s.rmfilter2,tp,0,LOCATION_MZONE,1,1,nil)
		g1:Merge(g2)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetDescription(3110)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g1=tg:Filter(Card.IsControler,nil,tp)
		local g2=tg:Filter(Card.IsControler,nil,1-tp)
		if #g1>0 and #g2>0 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 and Duel.SendtoGrave(g2,REASON_EFFECT)>0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end

function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.spfilter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

