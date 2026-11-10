/datum/enterprise
	var/book_balance = 0
	var/earned_round = 0
	var/earned_today = 0

/datum/enterprise/proc/get_bank_balance(mob/user)
	return (user && (user in SStreasury.bank_accounts)) ? SStreasury.bank_accounts[user] : 0

/datum/enterprise/proc/earn(amount)
	amount = round(amount)
	if(amount <= 0)
		return FALSE
	book_balance += amount
	earned_round += amount
	earned_today += amount
	write_journal()
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/can_pay(mob/user, cost)
	return book_balance + get_bank_balance(user) >= cost

/datum/enterprise/proc/pay(mob/user, cost, reason)
	cost = round(cost)
	if(cost <= 0)
		return TRUE
	if(!can_pay(user, cost))
		return FALSE
	var/from_book = min(book_balance, cost)
	var/from_bank = cost - from_book
	book_balance -= from_book
	if(from_bank)
		SStreasury.bank_accounts[user] -= from_bank
		SStreasury.log_to_steward("-[from_bank] from [user.real_name] ([reason])")
	SStgui.update_uis(src)
	return TRUE

/datum/enterprise/proc/take_from_account(mob/payer, cost)
	cost = round(cost)
	if(cost <= 0)
		return TRUE
	if(get_bank_balance(payer) < cost)
		return FALSE
	SStreasury.bank_accounts[payer] -= cost
	return TRUE

/datum/enterprise/proc/new_day()
	collect_patron_rent()
	earned_today = 0
	rested_today = list()
	SStgui.update_uis(src)
