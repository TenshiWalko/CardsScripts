-- Nakaizoku Swordsman
local s,id=GetID()
function s.initial_effect(c)
	-- Monsters your opponent controls cannot target face-up "Nakaizoku" monsters for attacks, except this one.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atklimit)
	c:RegisterEffect(e1)
	
	-- Xyz Material Effect: Attack up to the number of materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(s.matcon)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
end

s.listed_series={0x315} -- Código del arquetipo "Nakaizoku"

-- Efecto 1: Los monstruos de tu adversario no pueden seleccionar otros monstruos "Nakaizoku" boca arriba para ataques, excepto a este.
function s.atklimit(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:IsSetCard(0x315) -- Solo pueden atacar a este, si hay otros "Nakaizoku"
end

-- Efecto 2: El monstruo Xyz que tenga esta carta como material puede atacar hasta el número de materiales que tenga.
function s.matcon(e)
	return e:GetHandler():IsType(TYPE_XYZ) and e:GetHandler():IsSetCard(0x315)
end
function s.atkval(e,c)
	return c:GetOverlayCount() - 1
end
