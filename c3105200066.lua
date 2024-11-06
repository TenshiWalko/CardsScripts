--Arcana Glory Joker
local s,id=GetID()
function s.initial_effect(c)

s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}

	-- Invocación especial desde la mano o Cementerio
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- Ganar ATK basado en la cantidad de cartas en ambas manos
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)

	-- Reducción de ATK y destrucción de monstruos invocados en posición de ataque
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)

	-- Negación de efectos
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_NEGATE)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.negcon)
	e5:SetCost(s.negcost)
	e5:SetTarget(s.negtg)
	e5:SetOperation(s.negop)
	c:RegisterEffect(e5)
end

-- Función para el coste de la invocación especial: enviar cartas específicas al Cementerio
function s.cfilter2(c,code)
	return c:IsCode(code) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end

function s.rescon(sg,e,tp,mg)
	return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetClassCount(Card.GetCode)==3
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,CARD_QUEEN_KNIGHT)
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,CARD_KING_KNIGHT)
	local g3=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,CARD_JACK_KNIGHT)
	g1:Merge(g2)
	g1:Merge(g3)
	if chk==0 then return aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,0) end
	local g=aux.SelectUnselectGroup(g1,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(g,REASON_COST)
end

-- Objetivo de invocación especial
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Operación de invocación especial
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Valor de ATK basado en el número de cartas en las manos de ambos jugadores
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_HAND,LOCATION_HAND) * 500
end

-- Condición para activar el efecto de reducción de ATK al invocar monstruos en posición de ataque
function s.atkfilter(c,tp)
	return c:IsControler(1-tp) and c:IsPosition(POS_FACEUP_ATTACK)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkfilter,1,nil,tp)
end

-- Objetivo del efecto de reducción de ATK
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg:Filter(s.atkfilter,nil,tp))
end

-- Operación de reducción de ATK y destrucción
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
	local c=e:GetHandler()
	local dg=Group.CreateGroup()
	for tc in g:Iter() do
		local preatk=tc:GetAttack()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if preatk~=0 and tc:GetAttack()==0 then dg:AddCard(tc) end
	end
	if #dg>0 then
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

-- Condición: cuando se activa una carta o efecto que selecciona una carta boca arriba en el campo, excepto esta carta
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.IsChainNegatable(ev)
		and rp~=tp and re:GetHandler()~=c
		and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsExists(aux.TRUE,1,c)
end

-- Coste: descartar una carta del mismo tipo que la activada (Monstruo, Mágica o Trampa)
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local typ=re:GetActiveType() & 0x7 -- Obtener el tipo de carta (Monstruo, Mágica o Trampa)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,typ)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local typ=re:GetActiveType() & 0x7
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,typ)
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

function s.cfilter(c,typ)
	return c:IsType(typ) and c:IsDiscardable()
end

-- Objetivo de la negación
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Operación: Negar la activación del efecto
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		-- Puedes añadir efectos adicionales si es necesario
	end
end