--Cantrell Draw
local s,id=GetID()

s.listed_names={CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}

function s.initial_effect(c)
	-- Place 1 card on top of the Deck from hand, Deck, or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- Add to hand during End Phase if in GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- Filter to find cards that list "Queen's Knight", "King's Knight", and "Jack's Knight"
function s.listfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) 
		and not c:IsCode(id) 
		and c:IsAbleToDeck()
		and c:ListsCode(25652259)
		and c:ListsCode(64788463)
		and c:ListsCode(90876561)
end

-- Place on top of the deck and set up for discarding
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.listfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		-- Coloca la carta en el tope del Deck, sin mezclar, desde cualquier zona
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
			Duel.MoveSequence(tc,SEQ_DECKTOP)
		else
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		Duel.ConfirmCards(1-tp,tc)

		-- Realiza el conteo de los "Queen's Knight", "King's Knight" y "Jack's Knight"
		local ct=s.knight_count(tp)
		if ct>0 then
			-- Selecciona hasta ct cartas para descartar y luego robar la misma cantidad
			local discard=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,0,ct,nil)
			if #discard>0 then
				Duel.SendtoGrave(discard,REASON_EFFECT+REASON_DISCARD)
				Duel.BreakEffect()
				Duel.Draw(tp,#discard,REASON_EFFECT)
			end
		end
	end
end


-- Counts the different names among "Queen's Knight", "King's Knight", and "Jack's Knight" the player controls or has in GY
function s.knight_count(tp)
	local knights={25652259, 64788463, 90876561}
	local count=0
	for _,code in ipairs(knights) do
		if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,code),tp,LOCATION_MZONE,0,1,nil)
			or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,code),tp,LOCATION_GRAVE,0,1,nil) then
			count=count+1
		end
	end
	return count
end

-- Return "Cantrell Draw" to the hand during the End Phase
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and c:IsAbleToDeck()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToHand()
		and Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

