--Royal Straight Slasher
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,25652259,90876561,64788463)
	
	-- Enviar cartas específicas como coste para destruir todas las cartas del oponente
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)  -- Cambiado a un coste
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	
	-- Auto-baneo y robo de carta como efecto rápido
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end

-- Filtro para cada carta requerida
function s.tgfilter(c,code)
	return c:IsCode(code) and c:IsAbleToGraveAsCost()
end

function s.level10filter(c)
	return c:IsLevel(10) and c:IsAbleToGraveAsCost()
end

function s.level1filter(c)
	return c:IsLevel(1) and c:IsAbleToGraveAsCost()
end

-- Coste del efecto de destrucción
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.level10filter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,90876561) -- Jack's Knight
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,25652259) -- Queen's Knight
			and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,64788463) -- King's Knight
			and Duel.IsExistingMatchingCard(s.level1filter,tp,LOCATION_DECK,0,1,nil)
	end
	local g1=Duel.SelectMatchingCard(tp,s.level10filter,tp,LOCATION_DECK,0,1,1,nil)
	local g2=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,90876561)
	local g3=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,25652259)
	local g4=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,64788463)
	local g5=Duel.SelectMatchingCard(tp,s.level1filter,tp,LOCATION_DECK,0,1,1,nil)
	local g=Group.__add(g1,g2):__add(g3):__add(g4):__add(g5)
	
	if #g==5 then
		Duel.SendtoGrave(g,REASON_COST)  -- Ahora se envían como coste
		return true
	end
	return false
end

-- Target del efecto de destrucción
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) -- El oponente debe controlar al menos 1 carta
	end
	
	-- Obtener el grupo de cartas que se va a destruir y contar su tamaño
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)  -- especificar el grupo y el número de cartas
end

-- Operación del efecto de destrucción
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

-- Objetivo para el efecto de auto-baneo y robo
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- Operación para el efecto de auto-baneo y robo
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

-- Retorno del auto-baneo
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end





