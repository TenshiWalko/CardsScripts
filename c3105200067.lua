--King's Court
local s,id=GetID()
function s.initial_effect(c)
	-- Activación
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- Protección para esta carta si controlas un monstruo Guerrero de LUZ (no puede ser seleccionada o destruida)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_FZONE,0)
	e1:SetCondition(s.protectcon)
	e1:SetValue(1) -- evita que sea seleccionada como objetivo
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_FZONE,0)
	e2:SetCondition(s.protectcon)
	e2:SetValue(1) -- evita que sea destruida por efectos
	c:RegisterEffect(e2)

	-- Protección para los monstruos especificados contra efectos activados del oponente
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.target)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end

-- Condición para la protección de la carta mágica de campo
function s.protectcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- Target de los monstruos especificados
function s.target(e,c)
	return c:IsCode(6150044,93880808,3105200066) or (c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:GetMaterialCount()==3 and c:GetMaterial():GetClassCount(Card.GetCode)==3)
end

-- Filtro para que los monstruos especificados solo sean afectados por efectos que los seleccionen
function s.efilter(e,re)
	return re:IsActivated() and re:GetOwnerPlayer()~=e:GetHandlerPlayer() and not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end
