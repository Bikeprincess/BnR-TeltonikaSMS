(* Get spot price of energy from OTE *)
FUNCTION_BLOCK teltonikaSms
	IF NOT enable THEN
		status := teltonikaSmsStatus_NotEnabled;
		RETURN;
	END_IF;
	
	reExecute(CLK := execute);
		
	CASE internalState OF
		tnIntState_Wait:
			IF reExecute.Q THEN
				requestTypeInternal := requestType;
				status := teltonikaSmsStatus_Busy;
				internalState := tnIntState_EncodeMsgText;
			END_IF;
			IF NOT execute THEN
				status := teltonikaSmsStatus_Wait;
			END_IF;
			
			
		tnIntState_EncodeMsgText:
			internalState := tnIntState_CreateReq;
			IF requestTypeInternal = teltonikaReqType_SendMsg OR requestTypeInternal = teltonikaReqType_SendMsgGroup THEN
				msgTextEncodeUrl(enable := TRUE, pSrc := upMsgText, pDest := ADR(msgTextEncoded), destSize := SIZEOF(msgTextEncoded));
				IF msgTextEncodeUrl.status <> ERR_OK THEN
					internalState := tnIntState_Wait;
					status := teltonikaSmsStatus_Error;	
				END_IF;
			END_IF;
			
			
		tnIntState_CreateReq:
			request := '';
			requestNxtAddr := ADR(request);
			internalState := tnIntState_SendReq;
			CASE requestTypeInternal OF
				teltonikaReqType_EnMobileData:// /cgi-bin/mobile_date?username=user1&password=user_pass&value=on/off 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/mobile_date?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					IF uEnableData THEN
						requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&value=on'));
					ELSE
						requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&value=off'));
					END_IF;
				teltonikaReqType_SetSimPin:// /cgi-bin/mobile_sim_pin?username=user1&password=user_pass&pin=0000 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/mobile_sim_pin?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&pin='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, upSimPin);
				teltonikaReqType_ViewMsgList:// /cgi-bin/sms_list?username=user1&password=user_pass 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_list?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
				teltonikaReqType_ReadMsg:// /cgi-bin/sms_read?username=user1&password=user_pass&number=1 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_read?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&number='));
					brsitoa(uMsgId, ADR(reqMsgIdStr));
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR(reqMsgIdStr));
				teltonikaReqType_SendMsg:// /cgi-bin/sms_send?username=user1&password=user_pass&number=0037060000001&text=testmessage 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_send?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&number='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, upNumber);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&text='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR(msgTextEncoded));
				teltonikaReqType_SendMsgGroup:// /cgi-bin/sms_send?username=user1&password=user_pass&group=group_name&text=testmessage 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_send?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&group='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, upGroup);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&text='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR(msgTextEncoded));
				teltonikaReqType_ViewMsgTotal:// /cgi-bin/sms_total?username=user1&password=user_pass 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_total?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
				teltonikaReqType_DeleteMsg:// /cgi-bin/sms_delete?username=user1&password=user_pass&number=1 
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('/cgi-bin/sms_delete?username='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pUsername);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&password='));
					requestNxtAddr := brsstrcpy(requestNxtAddr, pPassword);
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR('&number='));
					brsitoa(uMsgId, ADR(reqMsgIdStr));
					requestNxtAddr := brsstrcpy(requestNxtAddr, ADR(reqMsgIdStr));
				ELSE
					internalState := tnIntState_Wait;
					status := teltonikaSmsStatus_Error;	
			END_CASE;
			
			
		tnIntState_SendReq:
			routerSendReq := TRUE;
			internalState := tnIntState_WaitForResponse;
		
		
		tnIntState_WaitForResponse:
			IF DiffDT(routerHttpStatistic.timeOfLastResponse, routerHttpStatistic.timeOfLastRequest) <> 16#FFFFFFFF THEN
				IF (routerHttpClient.status = 0) THEN
					routerSendReq := FALSE;
					IF (routerHttpClient.httpStatus = 200) THEN //Ok
						internalState := tnIntState_DecodeResponse;
					ELSIF routerHttpClient.httpStatus <> 200 THEN //Server error - 400, 404,..
						internalState := tnIntState_Wait;
						status := teltonikaSmsStatus_Error;
					END_IF;
				END_IF;
			END_IF;
		
		tnIntState_DecodeResponse:
			resrponseDecoder(enable := TRUE, pSrc := ADR(routerResponse), pDest := ADR(decodedResponse), destSize := SIZEOF(decodedResponse), pMappingTable := 0);
			IF resrponseDecoder.status = ERR_OK THEN
				internalState := tnIntState_ParseResponse;
			ELSE
				internalState := tnIntState_Wait;
				status := teltonikaSmsStatus_Error;	
			END_IF;
			
		tnIntState_ParseResponse:
			CASE requestTypeInternal OF
				teltonikaReqType_EnMobileData:
					
				teltonikaReqType_SetSimPin:
					
				teltonikaReqType_ViewMsgList:
					uMsgCount := teltonikaParseSms(ADR(routerResponse), SIZEOF(routerResponse), ADR(parsedSms), SIZEOF(parsedSms)/SIZEOF(teltonikaSms_t));
					
				teltonikaReqType_ReadMsg:
					uMsgCount := teltonikaParseSms(ADR(routerResponse), SIZEOF(routerResponse), ADR(parsedSms), SIZEOF(parsedSms)/SIZEOF(teltonikaSms_t));
					
				teltonikaReqType_SendMsg:
					
				teltonikaReqType_SendMsgGroup:
					
				teltonikaReqType_ViewMsgTotal:
					
				teltonikaReqType_DeleteMsg:
			
				ELSE
					internalState := tnIntState_Wait;
					status := teltonikaSmsStatus_Error;	
			END_CASE;
			
			internalState := tnIntState_Wait;
			status := teltonikaSmsStatus_Ok;
			
			
		ELSE
			internalState := tnIntState_Wait;
	END_CASE;
	
	
	
	
	routerHttpClient(enable := TRUE, send := routerSendReq, abort := FALSE, option := httpOPTION_HTTP_11, pHost := pRouterAddress, hostPort := 80, method := httpMETHOD_GET, pUri := ADR(request), pResponseHeader := ADR(routerHttpRespHeader), pResponseData := ADR(routerResponse), responseDataSize := SIZEOF(routerResponse), pStatistics := ADR(routerHttpStatistic), pStruct := 0);

END_FUNCTION_BLOCK


//parse received SMS
FUNCTION teltonikaParseSms
	//Check inputs
	IF sizeIn = 0 OR sizeOut = 0 OR pIn = 0 OR pOut = 0 THEN
		teltonikaParseSms := -1;
		RETURN;
	END_IF;
	
	teltonikaParseSms := 0;
	brsmemset(pOut, 0, sizeOut * SIZEOF(teltonikaSms_t));//clear output buffer
	nextAdrRead := pIn;
	
	
	FOR i := 0 TO sizeOut BY 1 DO
		brsmemset(ADR(tmpMem), 0, SIZEOF(tmpMem));//clear temp data buffer
		//index
		nextAdrRead := tnExtractVal(nextAdrRead, (pIn + sizeIn) - nextAdrRead, ADR(tmpStrName), SIZEOF(tmpStrName), ADR(tmpStrParse), SIZEOF(tmpStrParse));
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := -1;
		END_IF;
		tmpMem.index := DINT_TO_USINT(brsatoi(ADR(tmpStrParse)));
		
		//date
		nextAdrRead := tnExtractVal(nextAdrRead, (pIn + sizeIn) - nextAdrRead, ADR(tmpStrName), SIZEOF(tmpStrName), ADR(tmpMem.date), SIZEOF(tmpMem.date));
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := -1;
		END_IF;
		//tmpMem.date := STRING_TO_DT(tmpStrParse);
		
		//sender
		nextAdrRead := tnExtractVal(nextAdrRead, (pIn + sizeIn) - nextAdrRead, ADR(tmpStrName), SIZEOF(tmpStrName), ADR(tmpMem.sender), SIZEOF(tmpMem.sender));
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := -1;
		END_IF;

		//text
		nextAdrRead := tnExtractVal(nextAdrRead, (pIn + sizeIn) - nextAdrRead, ADR(tmpStrName), SIZEOF(tmpStrName), ADR(tmpMem.text), SIZEOF(tmpMem.text));
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := -1;
		END_IF;
		
		//status
		nextAdrRead := tnExtractVal(nextAdrRead, (pIn + sizeIn) - nextAdrRead, ADR(tmpStrName), SIZEOF(tmpStrName), ADR(tmpStrParse), SIZEOF(tmpStrParse));
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := -1;
		END_IF;
		tmpMem.status := brsmemcmp(ADR(tmpStrParse), ADR('read'), 4) = 0;
		
		brsmemcpy(pOut + i * SIZEOF(teltonikaSms_t), ADR(tmpMem), SIZEOF(teltonikaSms_t));//copy data to buffer
		
		nextAdrRead := tnFindEndOrLf(nextAdrRead, (pIn + sizeIn) - nextAdrRead);
		IF nextAdrRead = 0 THEN
			teltonikaParseSms := UDINT_TO_INT(i);
			RETURN;
		END_IF;
		
	END_FOR;
END_FUNCTION


FUNCTION tnExtractVal
	IF pIn = 0 OR sizeIn = 0 OR pName = 0 OR sizeName = 0 OR pVal = 0 OR sizeVal = 0 THEN
		tnExtractVal := 0;
		RETURN;
	END_IF;
	brsmemset(pName, 0, sizeName);
	brsmemset(pVal, 0, sizeVal);
	
	nextAddr := pIn;
	tmpAddr := pIn;
	
	iLen := 0;
	
	//Name
	WHILE tmpAddr < (pIn + sizeIn) DO
		actualChar ACCESS tmpAddr;
		IF actualChar = 58 THEN
			EXIT;
		END_IF;
		tmpAddr := tmpAddr + 1;
		iLen := iLen + 1;
	END_WHILE;
	IF iLen >= sizeName THEN
		tnExtractVal := 0;
		RETURN;
	END_IF;
	brsmemcpy(pName, nextAddr, iLen);
	//
	nextAddr := nextAddr + iLen + 2;
	tmpAddr := tmpAddr + 2;
	iLen := 0;
	//Value
	WHILE tmpAddr < (pIn + sizeIn) DO
		actualChar ACCESS tmpAddr;
		IF actualChar = 10 THEN
			EXIT;
		END_IF;
		tmpAddr := tmpAddr + 1;
		iLen := iLen + 1;
	END_WHILE;
	IF iLen >= sizeVal THEN
		tnExtractVal := 0;
		RETURN;
	END_IF;
	brsmemcpy(pVal, nextAddr, iLen);
	
	tnExtractVal := nextAddr + iLen + 1;
END_FUNCTION


FUNCTION tnFindEndOrLf
	//Input check
	IF pIn = 0 OR sizeIn = 0 THEN
		tnFindEndOrLf := 0;
		RETURN;
	END_IF;
	//find end char
	tmpAddr := pIn;
	FOR i := 2 TO sizeIn BY 1 DO
		actualChar ACCESS tmpAddr;
		tmpAddr := tmpAddr + 1;
		IF actualChar = 10 OR actualChar = 0 THEN
			tnFindEndOrLf := tmpAddr;
			RETURN;
		END_IF;
	END_FOR;
	tnFindEndOrLf := 0;
END_FUNCTION
