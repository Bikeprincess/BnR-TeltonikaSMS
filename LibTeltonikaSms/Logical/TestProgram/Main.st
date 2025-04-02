
PROGRAM _INIT
	
	 
END_PROGRAM

PROGRAM _CYCLIC
	tnSms0.pRouterAddress := ADR(routerIP);
	tnSms0.pUsername := ADR(routerSmsUser);
	tnSms0.pPassword := ADR(routerSmsPswd);
	
	tnSms0.requestType := ReqType;
	tnSms0.uEnableData := EnableData;
	tnSms0.upSimPin := ADR(SimPin);
	tnSms0.uMsgId := MsgId;
	tnSms0.upNumber := ADR(TelNumber);
	tnSms0.upGroup := ADR(Group);
	tnSms0.upMsgText := ADR(MsgText);
	
	
	
	tnSms0(enable := TRUE, execute := execute);
	
	IF enableParse THEN
		enableParse := FALSE;
		parsedSmsCount := teltonikaParseSms(ADR(testSmsRead), SIZEOF(testSmsRead), ADR(parsedSms), SIZEOF(parsedSms)/SIZEOF(teltonikaSms_t));
	END_IF;
	
	
END_PROGRAM
