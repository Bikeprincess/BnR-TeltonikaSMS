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
					
				teltonikaReqType_ReadMsg:
					
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

