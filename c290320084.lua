-- Nakaizoku Destroyer
local s,id=GetID()
function s.initial_effect(c)
	-- Quick Effect: Send this card from hand to GY to destroy a card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)

	-- Xyz material effect: Once per turn, destroy 1 face-up card your opponent controls
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.addcon)
	e2:SetTarget(s.xyztarget)
	e2:SetOperation(s.xyzoperation)
	c:RegisterEffect(e2)
end
s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"

-- Condition: Check if a monster's effect or a Spell/Trap is activated on the field
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and (re:IsActiveType(TYPE_MONSTER) or re:IsActiveType(TYPE_SPELL+TYPE_TRAP)) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Filter for "Nakaizoku" Xyz Monsters
function s.xyzfilter(c)
	return c:IsSetCard(0x315) and c:IsType(TYPE_XYZ)
end

-- Cost: Send this card from the hand to the GY
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-- Target: Destroy the card that activated its effect
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
end

-- Operation: Destroy the activated card if it's still on the field
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(re:GetHandler(),REASON_EFFECT)
	end
end
--Condition to check if attached to "Nakaizoku" Xyz Monster
function s.addcon(e)
	return e:GetHandler():IsSetCard(0x315) and e:GetHandler():IsType(TYPE_XYZ) 
end
-- Xyz Effect: Target 1 face-up card your opponent controls and destroy it
function s.xyztarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- Xyz Operation: Destroy the targeted face-up card
function s.xyzoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
