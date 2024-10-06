-- Nakaizoku Captain
local s,id=GetID()
function s.initial_effect(c)
	-- Set "All Hands!" Spell/Trap from Deck or GY when Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	
	-- Attach 1 face-up monster to a "Nakaizoku" Xyz Monster as material (Quick Effect)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.xyztg)
	e2:SetOperation(s.xyzop)
	c:RegisterEffect(e2)
	
	-- Xyz Material Effect: Negate and destroy when a card or effect is activated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCountLimit(1)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end

s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"
s.listed_names={0x3151} -- Código de "All Hands!"

-- Efecto 1: Set "All Hands!" desde el Deck o Cementerio
function s.setfilter(c)
	return c:IsSetCard(0x3151) and c:IsSSetable() and c:IsType(TYPE_SPELL+TYPE_TRAP)  -- Verifica que sea "All Hands!" y se pueda Colocar
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE) -- Asegura que se puede "setear"
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SSet(tp,tc) -- "Setea" la carta en el campo
		Duel.ConfirmCards(1-tp,g) -- Confirma al oponente que la carta fue colocada
	end
end

-- Efecto 2: Selecciona un monstruo boca arriba y un monstruo Xyz "Nakaizoku" para adjuntar como material
function s.xyzfilter(c)
	return c:IsSetCard(0x315) and c:IsType(TYPE_XYZ)
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCanBeEffectTarget),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g>0 and #xyz>0 then
		Duel.Overlay(xyz:GetFirst(),g:GetFirst())
	end
end

-- Efecto 3: Negar activación de cartas/efectos y destruir
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSetCard(0x315) and e:GetHandler():IsType(TYPE_XYZ)
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainNegatable(ev) end
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end


