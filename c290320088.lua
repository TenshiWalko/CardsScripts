-- Nakaizoku Chefmaster
local s,id=GetID()
function s.initial_effect(c)
	-- If a "Nakaizoku" monster inflicts battle damage: return 1 card to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id) -- Solo se puede usar una vez por turno
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- Xyz Material Effect: Gains 300 ATK for each material attached if Chefmaster is material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.matcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"

-- Efecto 1: Si un monstruo "Nakaizoku" inflige daño de batalla, devuelve 1 carta al adversario a la mano.
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	return ep~=tp and bc:IsSetCard(0x315) and bc:IsControler(tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

-- Efecto 2: El monstruo Xyz que tenga esta carta como material gana 300 ATK por cada material, si "Nakaizoku Chefmaster" está como material.
function s.matcon(e)
	return e:GetHandler():IsType(TYPE_XYZ) and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, id)
end

function s.atkval(e,c)
	return c:GetOverlayCount() * 200
end

