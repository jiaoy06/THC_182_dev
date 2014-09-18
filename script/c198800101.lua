require "nef/dss"
-- 芙兰朵露✿伯恩斯坦
function c198800101.initial_effect(c)
	-- 添加苏生限制
	c:EnableReviveLimit()

	-- 不能“普通”特殊召唤
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)

	-- 黑暗同调召唤
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	-- 特殊召唤的手续
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c198800101.syncon)
	e2:SetOperation(c198800101.synop)
	e2:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e2)

	-- 特殊召唤不能无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e3)

	-- 不能成为同调素材
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)

	-- 不能成为XYZ素材
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e5)

	-- 添加指示物
	local e6 = Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_TRIGGER_F + EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EVENT_BATTLE_END)
	e6:SetCondition(c198800101.atcon)
	e6:SetOperation(c198800101.atop)
	c:RegisterEffect(e6)

	-- 去除指示物伤害或者直接胜利
	local e7 = Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_COUNTER + CATEGORY_DAMAGE)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCost(c198800101.dmgcost)
	e7:SetCondition(c198800101.dmgcon)
	e7:SetOperation(c198800101.dmgop)
	c:RegisterEffect(e7)

	-- 黑暗同调成功时破坏场上所有魔陷
	local e8 = Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_SPSUMMON_SUCCESS)
	e8:SetCondition(c198800101.descon)
	e8:SetTarget(c198800101.destg)
	e8:SetOperation(c198800101.desop)
	c:RegisterEffect(e8)

end

----------------------------------------
function c198800101.syncon(e,c,tuner)
	if c == nil then return true end
	local tp = c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE) < -1 then return false end
	-- 不知为何sama代码里面还包括了对方LOCATION_MZONE的卡片，这里删除
	local g1 = Duel.GetMatchingGroup(c198800101.matfilter1,tp,LOCATION_MZONE,0,nil,c)
	local g2 = Duel.GetMatchingGroup(c198800101.matfilter2,tp,LOCATION_MZONE,0,nil,c)
	-- 得到同调怪兽的lv
	local lv = c:GetLevel()
	-- 在g2（调整以外group）内寻找满足synfilter1（lv使得g1中存在满足黑暗同调条件的黑暗调整怪兽）的怪兽
	return g2:IsExists(c198800101.synfilter1,1,nil,lv,g1,g2)
end

function c198800101.matfilter1(c,syncard)
	-- 黑暗调整group
	return c:IsSetCard(0x6208) and c:IsType(TYPE_TUNER) and c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard)
end

function c198800101.matfilter2(c,syncard)
	-- 调整以外，名字带有✿group
	return c:IsSetCard(0x208) and not c:IsType(TYPE_TUNER) and c:IsFaceup() and c:IsCanBeSynchroMaterial(syncard)
end

function c198800101.synfilter1(c,lv,g1,g2)
	local tlv = c:GetLevel()
	-- 在g1（黑暗调整group）内寻找满足synfilter3（等级等于同调等级lv与target怪兽等级tlv之和）的怪兽
	return g1:IsExists(c198800101.synfilter3,1,nil,lv+tlv)
end

function c198800101.synfilter3(c,lv)
	return c:GetLevel() == lv
end

function c198800101.synop(e,tp,eg,ep,ev,re,r,rp,c,tuner)
	-- 黑暗同调“模拟”实际同调过程
	local g = Group.CreateGroup()
	local g1 = Duel.GetMatchingGroup(c198800101.matfilter1,tp,LOCATION_MZONE,0,nil,c)
	local g2 = Duel.GetMatchingGroup(c198800101.matfilter2,tp,LOCATION_MZONE,0,nil,c)
	local lv = c:GetLevel()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local m3 = g2:FilterSelect(tp,c198800101.synfilter1,1,1,nil,lv,g1,g2)
	local mt1 = m3:GetFirst()
	g:AddCard(mt1)
	local lv1 = mt1:GetLevel()

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
	local t1=g1:FilterSelect(tp,c198800101.synfilter3,1,1,nil,lv+lv1)
	g:Merge(t1)

	c:SetMaterial(g)
	Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
end

-------------------------------------------------
function c198800101.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end

function c198800101.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end

function c198800101.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c198800101.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(c198800101.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end

function c198800101.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c198800101.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if g:GetCount() > 0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

-------------------------------------------------
function c198800101.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end

function c198800101.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- TODO: 修改指示物的序号
		c:AddCounter(0x208b,1)
	end
end

-------------------------------------------------
function c198800101.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCurrentPhase() == PHASE_MAIN1 end
	local e1 = Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	-- 契约效果EFFECT_FLAG_OATH，无效之后被reset
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c198800101.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	return c:GetCounter(0x208b) > 0
end

function c198800101.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local c = e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local num = c:GetCounter(0x208b)
		c:RemoveCounter(tp,0x208b,num,nil)
		if num >= 10 then
			-- TODO: 选择数目；判断是否胜利；给予伤害；移除指示物
			local WIN_REASON_FULAN = 0x0
			c:RemoveCounter(tp,0x208b,10,nil)
			Duel.SetLP(1-tp,233)
			Duel.SetLP(1-tp,123456789)
			Duel.SetLP(1-tp,233)
			Duel.SetLP(1-tp,123456789)
			Duel.SetLP(1-tp,233)
			Duel.SetLP(1-tp,123456789)
			Duel.SetLP(1-tp,233)
			Duel.SetLP(1-tp,123456789)
			Duel.SetLP(1-tp,233)
			Duel.SetLP(1-tp,123456789)
			Duel.SetLP(1-tp,233)
			Duel.Win(tp,WIN_REASON_FULAN)
		else
			Duel.Damage(1-tp,800*num,REASON_EFFECT)
		end
	end
end