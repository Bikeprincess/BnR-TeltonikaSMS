
FUNCTION_BLOCK teltonikaSms
	VAR_INPUT
		enable : BOOL := FALSE; (*Enable block*)
		pRouterAddress : UDINT; (*ADR to string of IP address or DNS name*)
		pUsername : UDINT; (*ADR to string with username*)
		pPassword : UDINT; (*ADR to string with password*)
		requestType : teltonikaReqType_e := teltonikaReqType_ViewMsgTotal; (*Requst type*)
		execute : BOOL := FALSE; (*Execute the command*)
		uEnableData : BOOL := TRUE; (*User - Enable/disable data*)
		upSimPin : UDINT; (*User - ADR of Sim pin to change as string*)
		uMsgId : UDINT; (*User - ID of message to Read or Delete*)
		upNumber : UDINT; (*User - Tel. number of receiver, must be like 0037012345678 (00 + country code + tel. number)*)
		upGroup : UDINT; (*User - group of receivers*)
		upMsgText : UDINT; (*User - ADR of message text*)
	END_VAR
	VAR_OUTPUT
		status : teltonikaSmsStatus_e := (0); (*State of executing. The error or Ok will be for execute state*)
		uMsgCount : INT; (*UserOut - total messages*)
		parsedSms : ARRAY[0..9] OF teltonikaSms_t;
	END_VAR
	VAR
		reExecute : R_TRIG; (*Rise edge for execute*)
		internalState : tnIntState_e; (*Internal state of FUB*)
		requestTypeInternal : teltonikaReqType_e := teltonikaReqType_ViewMsgTotal; (*Requst type*)
		msgTextEncodeUrl : httpEncodeUrl; (*Encoder for URL - change space to %20,...*)
		msgTextEncoded : STRING[3000]; (*It's 1-3 times longer than original*)
		request : STRING[3100]; (*Raw request*)
		requestNxtAddr : UDINT; (*Next address for creating request*)
		reqMsgIdStr : STRING[20]; (*String of message index for creating request*)
		routerSendReq : BOOL; (*Send request to router*)
		routerHttpClient : httpClient;
		routerHttpStatistic : httpStatistics_t;
		routerHttpReqHeader : httpRequestHeader_t;
		routerHttpRespHeader : httpResponseHeader_t;
		routerResponse : STRING[2000]; (*RAW router response*)
		resrponseDecoder : httpUtf8ToString; (*Response decoder from UTF-8 to STRING*)
		decodedResponse : STRING[2000]; (*Decoded router response*)
	END_VAR
END_FUNCTION_BLOCK

FUNCTION teltonikaParseSms : INT
	VAR_INPUT
		pIn : UDINT; (*ADR of input string received from router*)
		sizeIn : UDINT; (*max size of input*)
		pOut : UDINT; (*ADR for output buffer [teltonikaSms_t]*)
		sizeOut : UDINT; (*Array size of output buffer*)
	END_VAR
	VAR
		tmpMem : teltonikaSms_t;
		i : UDINT; (*actual buffer*)
		nextAdrRead : UDINT;
		tmpStrParse : STRING[30];
		tmpStrName : STRING[20];
	END_VAR
END_FUNCTION

FUNCTION tnExtractVal : UDINT
	VAR_INPUT
		pIn : UDINT;
		sizeIn : UDINT;
		pName : UDINT;
		sizeName : UDINT;
		pVal : UDINT;
		sizeVal : UDINT;
	END_VAR
	VAR
		iLen : UDINT;
		nextAddr : UDINT;
		tmpAddr : UDINT;
		actualChar : REFERENCE TO USINT;
	END_VAR
END_FUNCTION

FUNCTION tnFindEndOrLf : UDINT
	VAR_INPUT
		pIn : UDINT;
		sizeIn : UDINT;
	END_VAR
	VAR
		i : UDINT;
		tmpAddr : UDINT;
		actualChar : REFERENCE TO USINT;
	END_VAR
END_FUNCTION
