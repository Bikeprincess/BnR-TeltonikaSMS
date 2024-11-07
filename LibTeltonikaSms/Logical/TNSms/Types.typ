
TYPE
	teltonikaReqType_e : 
		(
		teltonikaReqType_EnMobileData,
		teltonikaReqType_SetSimPin,
		teltonikaReqType_ViewMsgList,
		teltonikaReqType_ReadMsg,
		teltonikaReqType_SendMsg,
		teltonikaReqType_SendMsgGroup,
		teltonikaReqType_ViewMsgTotal,
		teltonikaReqType_DeleteMsg
		);
	teltonikaSmsStatus_e : 
		(
		teltonikaSmsStatus_NotEnabled,
		teltonikaSmsStatus_Wait,
		teltonikaSmsStatus_Busy,
		teltonikaSmsStatus_Error,
		teltonikaSmsStatus_Ok
		);
END_TYPE

(*Internal automation states*)

TYPE
	tnIntState_e : 
		(
		tnIntState_Wait,
		tnIntState_EncodeMsgText,
		tnIntState_CreateReq,
		tnIntState_SendReq,
		tnIntState_WaitForResponse,
		tnIntState_DecodeResponse,
		tnIntState_ParseResponse
		);
END_TYPE
