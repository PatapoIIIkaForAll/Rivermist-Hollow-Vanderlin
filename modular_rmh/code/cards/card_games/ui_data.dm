/datum/card_table_session/proc/build_card_data(list/cards, hidden = FALSE)
	var/list/out = list()
	for(var/i = 1, i <= cards.len, i++)
		var/list/card = cards[i]
		out += list(list(
			"index" = i,
			"label" = hidden ? "??" : card_table_card_label(card),
			"rank" = hidden ? "?" : card["rank"],
			"suit" = hidden ? "?" : card["suit"],
			"hidden" = hidden,
			"value" = hidden ? null : blackjack_card_nominal(card),
		))
	return out

/datum/card_table_session/proc/build_xylix_peek_cards(mob/user) as /list
	var/count = min(xylix_peek_count(user), deck.len)
	if(count <= 0)
		return list()
	var/list/cards = list()
	for(var/i = 1, i <= count, i++)
		cards += list(deck[i])
	return build_card_data(cards, FALSE)

/datum/card_table_session/proc/build_solitaire_tableau() as /list
	var/list/out = list()
	for(var/i = 1, i <= solitaire_tableau.len, i++)
		var/list/column = solitaire_tableau[i]
		var/list/cards = list()
		for(var/j = 1, j <= column.len, j++)
			var/list/card = column[j]
			var/hidden = !card["face_up"]
			var/list/card_data = build_card_data(list(card), hidden)
			cards += list(card_data[1])
		out += list(list(
			"index" = i,
			"cards" = cards,
		))
	return out

/datum/card_table_session/proc/build_solitaire_foundations() as /list
	var/list/out = list()
	for(var/suit in list("H", "D", "C", "S"))
		var/list/foundation = solitaire_foundations[suit]
		var/list/top_card = (islist(foundation) && foundation.len) ? foundation[foundation.len] : null
		var/list/card_data = top_card ? build_card_data(list(top_card), FALSE) : null
		out += list(list(
			"suit" = suit,
			"card" = card_data ? card_data[1] : null,
			"count" = islist(foundation) ? foundation.len : 0,
		))
	return out

/datum/card_table_session/proc/build_fool_table_pairs() as /list
	var/list/out = list()
	for(var/i = 1, i <= table_pairs.len, i++)
		var/list/pair = table_pairs[i]
		var/list/attack = pair["attack"]
		var/list/defense = pair["defense"]
		var/list/attack_data = attack ? build_card_data(list(attack), FALSE) : null
		var/list/defense_data = defense ? build_card_data(list(defense), FALSE) : null
		out += list(list(
			"index" = i,
			"attack" = attack_data ? attack_data[1] : null,
			"defense" = defense_data ? defense_data[1] : null,
		))
	return out

/datum/card_table_session/proc/current_rules() as /list
	var/list/rules = list()
	switch(game_type)
		if(CARD_TABLE_GAME_FOOL)
			rules += "Goal: be the first to get rid of all your cards once the deck runs out."
			rules += "The attacker plays a card. The defender beats it with a higher card of the same suit or with a trump."
			if(fool_variant == CARD_TABLE_FOOL_THROW_IN || fool_variant == CARD_TABLE_FOOL_THROW_TRANSFER)
				rules += "Throwing in: you can throw in more cards that match the rank of any card already on the table. The first bout allows at most 5 attacks; after that you can keep throwing in while the defender still has cards in hand."
			if(fool_variant == CARD_TABLE_FOOL_TRANSFER || fool_variant == CARD_TABLE_FOOL_THROW_TRANSFER)
				rules += "Passing on: the defender can pass the attack on with a card of the same rank."
			if(fool_variant == CARD_TABLE_FOOL_CLASSIC)
				rules += "One attack and one defense per turn."
		if(CARD_TABLE_GAME_BLACKJACK)
			rules += "Goal: get as close to 21 as you can without going over."
			rules += "Hit takes a card. Stand locks in your hand."
			rules += "The dealer is always one of the players. [dealer_rotation_label()]."
			switch(blackjack_variant)
				if(CARD_TABLE_BLACKJACK_GRON)
					rules += "Icewind Dale: an Ace counts as 1; Jack, Queen and King count as 11."
				if(CARD_TABLE_BLACKJACK_VALORIA)
					rules += "Cormyr: Ace, Jack, Queen and King count as 10."
				if(CARD_TABLE_BLACKJACK_GRENZELHOFT)
					rules += "Baldur's Gate: an Ace counts as 10, but two Aces make 21; Jack, Queen and King count as 10."
				if(CARD_TABLE_BLACKJACK_KAZENGUN)
					rules += "Kara-Tur: Ace, Jack, Queen and King count as 1."
				else
					rules += "Duskmar: an Ace counts as 11, but two Aces make 21; Jack, Queen and King count as 10."
		if(CARD_TABLE_GAME_POKER)
			rules += "Goal: make the best hand."
			rules += "Betting: enter an amount. If it is not above the current bet, the Bet button checks or calls; if it is higher, it raises. All-in bets everything. Fold gives up your hand."
			switch(poker_variant)
				if(CARD_TABLE_POKER_TEXAS)
					rules += "Calimshan: each player holds 2 cards, with 5 community cards on the table."
				if(CARD_TABLE_POKER_OMAHA)
					rules += "Cormyr: each player holds 4 cards, with 5 community cards on the table."
				if(CARD_TABLE_POKER_STUD)
					rules += "Amn: each player gets 5 cards of their own and cannot exchange any."
				else
					rules += "Duskmar: each player gets 5 cards and may exchange one card once."
			rules += "The dealer is always one of the players. [dealer_rotation_label()]."
			if(poker_uses_community_cards())
				rules += "Community cards are revealed one at a time, with a new betting round after each card."
			else
				rules += "There are no community cards; only the players' hands are compared."
		if(CARD_TABLE_GAME_SOLITAIRE)
			rules += "Goal: sort all the cards into finished stacks."
			if(solitaire_variant == CARD_TABLE_SOLITAIRE_SPIDER)
				rules += "Spider: two decks, ten columns. Each deal from the stock puts one card on every column."
				rules += "You can move a face-up descending run of one suit. A full run of one suit from King down to Ace is removed."
			else
				rules += "Klondike: seven columns, a stock, and four foundations, one per suit, built from Ace up to King."
	return rules

/datum/card_table_session/proc/build_ui_data(mob/user) as /list
	var/datum/card_table_player/me = player_for_user(user)
	var/list/player_rows = list()
	for(var/datum/card_table_player/player in players)
		var/list/player_row = player_public_data_for(player, me, user)
		var/show_hand = (stage == CARD_TABLE_STAGE_FINISHED || player == me)
		player_row["hand_value"] = (show_hand && game_type == CARD_TABLE_GAME_BLACKJACK) ? hand_value(player.hand) : null
		player_row["is_dealer"] = (player == dealer_player())
		player_rows += list(player_row)
	var/list/observer_rows = list()
	for(var/ckey in observers)
		var/mob/M = card_table_find_mob_by_ckey(ckey)
		observer_rows += M ? card_table_display_name(M) : ckey
	var/list/my_hand = me ? build_card_data(me.hand, FALSE) : list()
	var/list/waste_card = null
	if(discard.len)
		var/list/waste_data = build_card_data(list(discard[discard.len]), FALSE)
		waste_card = waste_data[1]
	var/fool_is_playing = (stage == CARD_TABLE_STAGE_PLAYING && game_type == CARD_TABLE_GAME_FOOL)
	var/datum/card_table_player/current_attacker = fool_is_playing ? fool_current_attacker() : null
	var/datum/card_table_player/current_defender = fool_is_playing ? fool_current_defender() : null
	var/datum/card_table_player/table_dealer = dealer_player()
	var/my_ckey = user ? user.ckey : null
	var/is_host = (me && player_index(me) == 1)
	var/xylix_level = xylix_tier(user)
	return list(
		"game_type" = game_type,
		"game_label" = game_label(),
		"fool_variant" = fool_variant,
		"fool_variant_label" = fool_variant_label(),
		"poker_variant" = poker_variant,
		"poker_variant_label" = poker_variant_label(),
		"blackjack_variant" = blackjack_variant,
		"blackjack_variant_label" = blackjack_variant_label(),
		"solitaire_variant" = solitaire_variant,
		"solitaire_variant_label" = solitaire_variant_label(),
		"dealer_rotates" = dealer_rotates,
		"dealer_rotation_label" = dealer_rotation_label(),
		"dealer_name" = table_dealer ? table_dealer.name : null,
		"rules" = current_rules(),
		"stage" = stage,
		"message" = message,
		"players" = player_rows,
		"observers" = observer_rows,
		"my_ckey" = my_ckey,
		"is_player" = !!me,
		"is_host" = is_host,
		"is_observer" = is_observer(user),
		"my_hand" = my_hand,
		"deck_count" = deck.len,
		"discard_count" = discard.len,
		"min_players" = min_players(),
		"max_players" = max_players(),
		"can_start" = (stage == CARD_TABLE_STAGE_LOBBY && is_host && game_type != CARD_TABLE_GAME_NONE && players.len >= min_players()),
		"can_pack" = can_pack(),
		"dealer_value" = (table_dealer && stage == CARD_TABLE_STAGE_FINISHED) ? hand_value(table_dealer.hand) : null,
		"community_cards" = (game_type == CARD_TABLE_GAME_POKER && poker_uses_community_cards()) ? build_card_data(community_cards, FALSE) : list(),
		"poker_turn" = (game_type == CARD_TABLE_GAME_POKER && stage == CARD_TABLE_STAGE_PLAYING && poker_current_player()) ? poker_current_player().name : null,
		"poker_current_bet" = (game_type == CARD_TABLE_GAME_POKER) ? poker_current_bet : 0,
		"poker_pot" = (game_type == CARD_TABLE_GAME_POKER) ? poker_pot : 0,
		"poker_betting_round" = (game_type == CARD_TABLE_GAME_POKER) ? poker_betting_round : 0,
		"blackjack_action_seq" = blackjack_action_seq,
		"blackjack_action_player_index" = blackjack_action_player_index,
		"blackjack_action_bust" = blackjack_action_bust,
		"fool_action_seq" = fool_action_seq,
		"fool_action_kind" = fool_action_kind,
		"fool_action_player_index" = fool_action_player_index,
		"fool_action_target_index" = fool_action_target_index,
		"my_value" = me ? hand_value(me.hand) : null,
		"solitaire_tableau" = build_solitaire_tableau(),
		"solitaire_stock_count" = solitaire_stock.len,
		"solitaire_waste" = waste_card,
		"solitaire_foundations" = build_solitaire_foundations(),
		"solitaire_completed_sets" = solitaire_completed_sets,
		"attacker" = current_attacker ? current_attacker.name : null,
		"defender" = current_defender ? current_defender.name : null,
		"table_attack" = (fool_is_playing && table_attack) ? card_table_card_label(table_attack) : null,
		"table_defense" = (fool_is_playing && table_defense) ? card_table_card_label(table_defense) : null,
		"table_pairs" = fool_is_playing ? build_fool_table_pairs() : list(),
		"trump" = fool_is_playing ? trump_suit : null,
		"xylix" = list(
			"enabled" = (stage == CARD_TABLE_STAGE_PLAYING && xylix_level >= XYLIX_TIER_0 && game_type != CARD_TABLE_GAME_SOLITAIRE),
			"tier" = xylix_level,
			"skill" = xylix_holy_skill(user),
			"caught_chance" = xylix_caught_chance(user),
			"can_choose" = xylix_can_choose_card(user),
			"cards" = build_xylix_peek_cards(user),
		),
	)
