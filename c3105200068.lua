--Destruction Sword Tactics
local s,id=GetID()
function s.initial_effect(c)
	-- Activar efecto: Añadir carta "Destruction Sword" del Deck a la mano
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- Efecto en el Cementerio: Colocar esta carta en la Zona de Magia y Trampa
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.gycost)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)

	-- Seleccionar 1 efecto por turno y solo 1 vez ese turno
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.checkcon)
	e3:SetOperation(s.resetop)
	c:RegisterEffect(e3)
	
	-- Equipar un monstruo del Cementerio y otorgar ATK/DEF
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(s.limitcon)
	e4:SetTarget(s.eqtg)
	e4:SetOperation(s.eqop)
	c:RegisterEffect(e4)
	
end

-- Activar efecto: Añadir carta "Destruction Sword" del Deck a la mano
function s.filter(c)
	return (c:IsSetCard(0xd6) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand() 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

-- Efecto en el Cementerio: Coste para colocar la carta
function s.gyfilter(c)
	return c:IsSetCard(0xd6) and c:IsDiscardable()
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.gyfilter,1,1,REASON_COST+REASON_DISCARD)
end

-- Objetivo para colocar la carta desde el Cementerio
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

-- Operación para colocar la carta desde el Cementerio
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

-- Restricción de activación de los efectos (solo uno por turno)
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

-- Equipar un monstruo del Cementerio y otorgar ATK/DEF
function s.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToChangeControler()
end
function s.busterfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd7)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		and Duel.IsExistingMatchingCard(s.busterfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.busterfilter,tp,LOCATION_MZONE,0,nil)
	if tc and tc:IsRelateToEffect(e) and #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sc=g:Select(tp,1,1,nil):GetFirst()
		if Duel.Equip(tp,tc,sc,true) then
			-- Configurar la carta como equipo
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(s.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(sc)
			tc:RegisterEffect(e1)
			-- Ganancia de ATK/DEF
			local atk=tc:GetAttack()/2
			local def=tc:GetDefense()/2
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(atk)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_UPDATE_DEFENSE)
			e3:SetValue(def)
			tc:RegisterEffect(e3)
			-- Negar efectos de monstruos con el mismo nombre
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_DISABLE)
			e4:SetRange(LOCATION_MZONE)
			e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e4:SetTarget(s.distg)
			e4:SetLabel(tc:GetOriginalCode())
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e4)
			local e5=e4:Clone()
			e5:SetCode(EFFECT_DISABLE_EFFECT)
			sc:RegisterEffect(e5)
		end
	end
end

function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

function s.distg(e,c)
	return c:IsFaceup() and c:IsCode(e:GetLabel())
end




