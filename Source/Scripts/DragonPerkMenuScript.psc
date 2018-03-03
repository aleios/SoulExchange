scriptname DragonPerkMenuScript extends SKI_ConfigBase

; Properties
Actor Property PlayerRef Auto

GlobalVariable Property ae_dragonPerkExchangeSliderMax Auto
GlobalVariable Property ae_dragonPerkPerksSliderMax Auto
GlobalVariable Property ae_dragonPerkAttribSliderMax Auto

; Script locals
Float _perksPerSoul = 1.0
Float _soulsPerPerkExchange = 1.0

Int _perksPerSoulSlider
Int _soulsPerPerkExchangeSlider
Int _convertPerkButton


Float _attribPerSoul = 20.0
Float _soulsPerAttribExchange = 1.0
Int _currentAttrib = 0

Int _attribPerSoulSlider
Int _soulsPerAttribExchangeSlider
Int _convertAttribSelector
Int _convertAttribButton

String[] _attribList

int function GetVersion()
	return 2
endFunction

event OnConfigInit()
	Pages = new string[2]
	Pages[0] = "Souls to Perks"
	Pages[1] = "Souls to Attributes"
	
	_attribList = new String[4]
	_attribList[0] = "Health"
	_attribList[1] = "Magicka"
	_attribList[2] = "Stamina"
	_attribList[3] = "Carry Weight"
	
endEvent

event OnVersionUpdate(int version)
	; Not currently used but maybe someday required.
endEvent

event OnPageReset(string page)
	if(page == "" || page == Pages[0])
		;SetCursorFillMode(TOP_TO_BOTTOM)
		
		AddHeaderOption("Options")
		AddHeaderOption("Stats")
		
		_perksPerSoulSlider = AddSliderOption("Perks per Exchange", _perksPerSoul, "{0}")
		
		AddTextOption("Souls: ", ((PlayerRef.GetActorValue("DragonSouls") as Int) as String)) ; Seriously no implicit cast to String available? wtf
		
		_soulsPerPerkExchangeSlider = AddSliderOption("Souls per Exchange", _soulsPerPerkExchange, "{0}")
		
		AddTextOption("Perks: ", (Game.GetPerkPoints() as String))
		
		_convertPerkButton = AddTextOption("Convert Souls to Perks", "")
		
	elseIf(page == Pages[1])
		
		AddHeaderOption("Options")
		AddHeaderOption("Stats")
		
		_attribPerSoulSlider = AddSliderOption("Points per Exchange", _attribPerSoul, "{0}")
		
		AddTextOption("Souls: ", ((PlayerRef.GetActorValue("DragonSouls") as Int) as String))
		
		_soulsPerAttribExchangeSlider = AddSliderOption("Souls per Exchange", _soulsPerAttribExchange, "{0}")
		
		AddTextOption("Health: ", (PlayerRef.GetBaseActorValue("health") as String))
		
		_convertAttribSelector = AddMenuOption("Attribute", _attribList[_currentAttrib])
		
		AddTextOption("Magicka: ", (PlayerRef.GetBaseActorValue("magicka") as String))
		
		_convertAttribButton = AddTextOption("Convert Souls to Attribute", "")
		
		AddTextOption("Stamina: ", (PlayerRef.GetBaseActorValue("stamina") as String))
		
		AddEmptyOption()
		
		AddTextOption("Carry Weight: ", (PlayerRef.GetBaseActorValue("carryweight") as String))
		
	endIf
endEvent


event OnOptionSelect(int optionCode)
	
	; TODO: Place soul evaluation into function for reuse.
	
	if(optionCode == _convertPerkButton)
		
		; Validate available souls
		Float numSouls = PlayerRef.GetActorValue("DragonSouls")
		if((numSouls - _soulsPerPerkExchange) >= 0)
			
			; Add perks
			Game.ModPerkPoints((_perksPerSoul as Int))
			PlayerRef.ModActorValue("DragonSouls", -_soulsPerPerkExchange)
			
			ShowMessage("Perk(s) added. Dragon soul removed.")
			
			; Force a page reset to show updated perks/souls stats.
			ForcePageReset()
		else
			
			ShowMessage("You do not have enough dragon souls.")
			
		endIf
	
	elseIf(optionCode == _convertAttribButton) ; Attribute conversion.
	
		
		; Validate available souls
		Float numSouls = PlayerRef.GetActorValue("DragonSouls")
		if((numSouls - _soulsPerAttribExchange) >= 0)
		
			
			; Find which value to use.
			string modval = "health"
			
			if(_currentAttrib == 0)
				modval = "health"
			elseIf(_currentAttrib == 1)
				modval = "magicka"
			elseIf(_currentAttrib == 2)
				modval = "stamina"
			elseIf(_currentAttrib == 3)
				modval = "carryweight"
			else
				modval = ""
			endIf
			
			
			if(modval == "")
			
				ShowMessage("Error: Invalid attribute selected.")
			
			else
			
				; Modify selected attribute value.
				PlayerRef.SetActorValue(modval, PlayerRef.GetBaseActorValue(modval) + _attribPerSoul)
			
				; Modify dragon soul count.
				PlayerRef.ModActorValue("DragonSouls", -_soulsPerAttribExchange)
				
				ShowMessage("Attribute added. Dragon soul removed.")
				
				ForcePageReset()
			
			endIf
		else
		
			ShowMessage("You do not have enough dragon souls.")
		
		endIf
		
	endIf
	
endEvent

; Performs a simple clamp between (min, inf) inclusive.
Float function SanitizeGlobal(float value, float min)
	if(value < min)
		value = min
	endIf
	return value
endFunction

event OnOptionSliderOpen(int optionCode)
	
	if(optionCode == _perksPerSoulSlider)
	
		SetSliderDialogStartValue(_perksPerSoul)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, SanitizeGlobal(ae_dragonPerkPerksSliderMax.GetValue(), 1)) ; DefaultMax = 20
		SetSliderDialogInterval(1)
		
	elseIf(optionCode == _soulsPerPerkExchangeSlider)
		
		SetSliderDialogStartValue(_soulsPerPerkExchange)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, SanitizeGlobal(ae_dragonPerkExchangeSliderMax.GetValue(), 1)) ; DefaultMax = 20
		SetSliderDialogInterval(1)
		
	elseIf(optionCode == _attribPerSoulSlider)
	
		SetSliderDialogStartValue(_attribPerSoul)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, SanitizeGlobal(ae_dragonPerkAttribSliderMax.GetValue(), 1)) ; DefaultMax = 400
		SetSliderDialogInterval(1)
	
	elseIf(optionCode == _soulsPerAttribExchangeSlider)
	
		SetSliderDialogStartValue(_soulsPerAttribExchange)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, SanitizeGlobal(ae_dragonPerkExchangeSliderMax.GetValue(), 1)) ; DefaultMax = 20
		SetSliderDialogInterval(1)
	
	endIf
	
endEvent

event OnOptionSliderAccept(int optionCode, float value)
	
	if(optionCode == _perksPerSoulSlider)
		
		_perksPerSoul = value
		SetSliderOptionValue(optionCode, value, "{0}")
		
	elseIf(optionCode == _soulsPerPerkExchangeSlider)
	
		_soulsPerPerkExchange = value
		SetSliderOptionValue(optionCode, value, "{0}")
	
	elseIf(optionCode == _attribPerSoulSlider)
		
		_attribPerSoul = value
		SetSliderOptionValue(optionCode, value, "{0}")
		
	elseIf(optionCode == _soulsPerAttribExchangeSlider)
	
		_soulsPerAttribExchange = value
		SetSliderOptionValue(optionCode, value, "{0}")
	
	endIf
	
endEvent


event OnOptionMenuOpen(int optionCode)

	if(optionCode == _convertAttribSelector)
		SetMenuDialogStartIndex(_currentAttrib)
		SetMenuDialogDefaultIndex(0)
		SetMenuDialogOptions(_attribList)
	endIf

endEvent


event OnOptionMenuAccept(int optionCode, int index)

	if(optionCode == _convertAttribSelector)
		
		_currentAttrib = index
		SetMenuOptionValue(optionCode, _attribList[_currentAttrib])
		
	endIf

endEvent