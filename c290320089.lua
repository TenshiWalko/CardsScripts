-- Nakaizoku Ship - Thousand Dawn
local s,id=GetID()
function s.initial_effect(c)
	-- Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),8,2,nil,nil,7)
	
	-- Alternative Xyz Summon using Rank 4 with 5 or more materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.xyzcon)
	e0:SetTarget(s.xyztg)
	e0:SetOperation(s.xyzop)
	e0:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e0)

	-- Quick Effect: Special Summon 1 "Nakaizoku" monster attached as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Attach 1 "Nakaizoku" monster from hand, Deck, or GY to this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,2})
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)

	-- Opponent discards 1 card or takes 1000 damage when this card destroys an opponent's card
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(aux.bdocon)
	e3:SetOperation(s.opdmgop)
	c:RegisterEffect(e3)
end

s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"

-- Alternative Xyz Summon condition: Rank 4 "Nakaizoku" Xyz monster with 5 or more materials
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x315) and c:IsRank(4) and c:GetOverlayCount()>=5
end
function s.xyzcon(e,c,og)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.xyzfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		e:SetLabelObject(g:GetFirst())
		return true
	end
	return false
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og)
	local mg=e:GetLabelObject():GetOverlayGroup()
	if #mg>0 then
		Duel.Overlay(c,mg)
	end
	Duel.Overlay(c,e:GetLabelObject())
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

-- Efecto 2: Puedes adjuntar 1 monstruo "Nakaizoku" desde la mano, Deck o Cementerio a esta carta como material
function s.matfilter(c)
	return c:IsSetCard(0x315) and not c:IsType(TYPE_XYZ) and c:IsType(TYPE_MONSTER)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.Overlay(e:GetHandler(),g)
	end
end

-- Efecto 3: Si esta carta destruye una carta del adversario, debe descartar 1 carta o recibir 1000 puntos de daño
function s.opdmgop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(1-tp,aux.Stringid(id,2),aux.Stringid(id,3))
	if op==0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DISCARD)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsDiscardable,1-tp,LOCATION_HAND,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT)
	else
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end


