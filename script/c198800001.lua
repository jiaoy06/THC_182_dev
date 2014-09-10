require "nef/dss"
--东方 M·U·G·E·N
function c10000.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--defup
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x208))
	e2:SetValue(600)
	c:RegisterEffect(e2)
	--Destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c10000.desrepcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
function c10000.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x208)
end
function c10000.desrepcon(e)
	return Duel.IsExistingMatchingCard(c10000.filter1,e:GetHandler():GetControler(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end