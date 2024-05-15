#Include "APWEBSRV.CH"
#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRGW002 - WEBSERVICE
Montagem da Estrutura do WebService
@aParam
@author	David Ferreira Quadras
@since		20/10/2014
/*/
//--------------------------------------------------------------------        
User Function PRGW002()
ALERT('OK')
Return

//Edt's 
//====================================================================
WSSERVICE NEWEDT DESCRIPTION "INCLUSAO DE EDT"
	WSDATA KEY					As String
	WSDATA _cEmp				As String
	WSDATA _cFilial				As String
	WSDATA _cCodpsp				As String
	WSDATA _cDescricao			As String 		OPTIONAL
	WSDATA _cRevisa				As String
	WSDATA _cEdt   				As String
	WSDATA _cEdtPai				As String		OPTIONAL
	WSDATA _cNivel				As String		OPTIONAL
	WSDATA _fOrcProj			As Float		OPTIONAL
	WSDATA _fVenProj			As Float		OPTIONAL
	WSDATA _fOrcReem			As Float		OPTIONAL
	WSDATA _fVenReem			As Float		OPTIONAL
	WSDATA _fMeta 				As Float		OPTIONAL
	WSDATA _cMsg				As String
	WSMETHOD WSincEdt       	DESCRIPTION "Método Gravacao Cadastro EDT"
	WSMETHOD WSaltEdt       	DESCRIPTION "Método Alteração Cadastro EDT"
	WSMETHOD WSexcEdt       	DESCRIPTION "Método Exclusão Cadastro EDT"
ENDWSSERVICE

//-------------------------------------------------------------------
/*/{Protheus.doc} WSincEdt
Metodo Cadastro Edt 
@aParam
@author	David Ferreira
@since		20/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSincEdt WSRECEIVE KEY,_cEmp,_cFilial,_cCodpsp,_cDescricao,_cRevisa,_cEdt,_cEdtPai,_cNivel,_fOrcProj,_fVenProj,_fOrcReem,_fVenReem,_fMeta WSSEND _cMsg WSSERVICE NEWEDT
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.
	
	::_cMsg:=""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsIncEdt]"
			_lRet:= .f.
		EndIf
	EndIf*/
	
	If _lRet
		RecLock("AFC",.T.)
		AFC->AFC_FILIAL  := ::_cFilial
		AFC->AFC_PROJET  := ::_cCodpsp
		AFC->AFC_DESCRI  := ::_cDescricao
		AFC->AFC_REVISA  := ::_cRevisa
		AFC->AFC_EDT     := ::_cEdt
		AFC->AFC_EDTPAI  := ::_cEdtPai
		AFC->AFC_NIVEL   := ::_cNivel
		AFC->AFC_CUSTPV  := ::_fOrcProj
		AFC->AFC_TVPVI   := ::_fVenProj
		AFC->AFC_TVPVBV  := ::_fVenProj
		AFC->AFC_CUSTRE  := ::_fOrcReem
		AFC->AFC_TVRE    := ::_fVenReem
		AFC->AFC_TVBRBV  := ::_fVenReem
		
		If ::_fOrcReem > 0
			AFC->AFC_CUSTO   := ::_fOrcProj + ::_fOrcReem
		ElseIf ::_fVenReem > 0 	
			AFC->AFC_CUSTO   := ::_fVenProj + ::_fVenReem
		EndIf	
		AFC->AFC_CALEND  := "001"
		
		IF ::_fVenProj > 0 .AND. ::_fOrcProj > 0
			AFC->AFC_TVPVC   := ::_fVenProj / ::_fOrcProj
		ENDIF
		
		IF ::_fVenReem > 0 .AND. ::_fOrcReem > 0
			AFC->AFC_TVRECO  := ::_fVenReem / ::_fOrcReem
		ENDIF
		
		AFC->AFC_X_META  := ::_fMeta
		AFC->AFC_METUNI  := ::_fMeta
		AFC->AFC_METTOT  := ::_fMeta
		AFC->(MsUnlock())
		::_cMsg+="***Inclusao da Edt Realizada com Sucesso"+::_cCodpsp+"-"+::_cEdt
	EndIf

	If _lRet
		RecLock("PB1",.T.)
		PB1->PB1_FILIAL  := ::_cFilial
		PB1->PB1_ORCAME  := ::_cCodpsp
		PB1->PB1_DESCRI  := ::_cDescricao
		PB1->PB1_REVISA  := ::_cRevisa
		PB1->PB1_EDT     := ::_cEdt
		PB1->PB1_EDTPAI  := ::_cEdtPai
		PB1->PB1_NIVEL   := ::_cNivel
		PB1->PB1_CUSTPV  := ::_fOrcProj
		PB1->PB1_TVPVI   := ::_fVenProj
		PB1->PB1_TVPVBV  := ::_fVenProj
		PB1->PB1_CUSTRE  := ::_fOrcReem
		PB1->PB1_TVRE    := ::_fVenReem
		PB1->PB1_TVBRBV  := ::_fVenReem
		
		If ::_fOrcReem > 0
			PB1->PB1_CUSTO   := ::_fOrcProj + ::_fOrcReem
		ElseIf ::_fVenReem > 0 	
			PB1->PB1_CUSTO   := ::_fVenProj + ::_fVenReem
		EndIf	
		PB1->PB1_CALEND  := "001"
		
		IF ::_fVenProj > 0 .AND. ::_fOrcProj > 0
			PB1->PB1_TVPVC   := ::_fVenProj / ::_fOrcProj
		ENDIF
		
		IF ::_fVenReem > 0 .AND. ::_fOrcReem > 0
			PB1->PB1_TVRECO  := ::_fVenReem / ::_fOrcReem
		ENDIF
		
		PB1->PB1_XMETA   := ::_fMeta
		PB1->PB1_METUNI  := ::_fMeta
		PB1->PB1_METTOT  := ::_fMeta
		PB1->(MsUnlock())
		::_cMsg+="***Inclusao da Edt Realizada com Sucesso"+::_cCodpsp+"-"+::_cEdt
	EndIf	

Return _lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSaltEdt
Metodo Cadastro Edt 
@aParam
@author	David Ferreira
@since		20/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSaltEdt WSRECEIVE KEY, _cEmp,_cFilial,_cCodpsp,_cDescricao,_cRevisa,_cEdt,_fOrcProj,_fVenProj,_fOrcReem,_fVenReem,_fMeta WSSEND _cMsg WSSERVICE NEWEDT
	
	Local _lRet	:=.T.
	Local cMsgEmp	:= u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.

	::_cMsg:=""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsAltEdt]"
			_lRet:= .f.
		EndIf
	EndIf*/

	DBSELECTAREA('PB1')
	PB1->(DbSetOrder(1))
	If PB1->( DbSeek(alltrim(::_cFilial)+AVKEY(alltrim(::_cCodpsp),'PB1_ORCAME')+AVKEY(alltrim(::_cEdt),'PB1_EDT')) )

		RecLock("PB1",.F.)
			
			PB1->PB1_DESCRI  := ::_cDescricao
			PB1->PB1_CUSTPV  := ::_fOrcProj
			PB1->PB1_TVPVI   := ::_fVenProj
			PB1->PB1_TVPVBV  := ::_fVenProj
			PB1->PB1_CUSTRE  := ::_fOrcReem
			PB1->PB1_TVRE    := ::_fVenReem
			PB1->PB1_TVBRBV  := ::_fVenReem
			
			If ::_fOrcReem > 0
				PB1->PB1_CUSTO   := ::_fOrcProj + ::_fOrcReem
				PB1->PB1_X_RERI  := "RE"
			ElseIf ::_fVenReem > 0
				PB1->PB1_CUSTO   := ::_fVenProj + ::_fVenReem
				PB1->PB1_X_RERI  := "RE"							
			EndIf

			PB1->PB1_CALEND  := "001"

			IF ::_fVenProj > 0 .AND. ::_fOrcProj > 0
				PB1->PB1_TVPVC   := ::_fVenProj / ::_fOrcProj
			ENDIF

			IF ::_fVenReem > 0 .AND. ::_fOrcReem > 0
				PB1->PB1_TVRECO  := ::_fVenReem / ::_fOrcReem
			ENDIF
	
			PB1->PB1_XMETA  := ::_fMeta
			PB1->PB1_METUNI  := ::_fMeta
			PB1->PB1_METTOT  := ::_fMeta

		PB1->(MsUnlock())

		::_cMsg+="***Alteracao da Edt Realizada com Sucesso"+::_cCodpsp+"-"+::_cEdt
	Else
		::_cMsg+="***Nao foi possivel realizar a alteracao "+::_cCodpsp+"-"+::_cEdt
	EndIf

Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSexcEdt
Metodo Cadastro Edt 
@aParam
@author	David Ferreira
@since		20/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSexcEdt WSRECEIVE KEY, _cEmp,_cFilial,_cCodpsp,_cRevisa,_cEdt WSSEND _cMsg WSSERVICE NEWEDT
	Local _lRet	 := .T.
	Local cMsgEmp	 := u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.
	Private _lRetpc:= .T.

	::_cMsg:=""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsExcEdt]"
			_lRet:= .f.
		EndIf
	EndIf*/
	
	If _lRet

		//Exclui as Edt's e Tarefas Filhas que estão abaixo 
		::_cMsg := WS002PC(::_cFilial,::_cCodpsp,::_cEdt,::_cRevisa)
		
		If Empty(::_cMsg)
			DBSELECTAREA('AFC')
			AFC->(DBSETORDER(1))
			If DBSEEK(alltrim(::_cFilial)+AVKEY(alltrim(::_cCodpsp),'AF8_PROJET')+AVKEY(alltrim(::_cRevisa),'AF8_REVISA')+AVKEY(alltrim(::_cEdt),'AFC_EDT'))
				RecLock("AFC",.F.)
				DBDELETE()
				MSUNLOCK()
				::_cMsg+="***Exclusao da Edt Realizada com Sucesso "+::_cCodpsp+"-"+::_cEdt
			Else
				::_cMsg+="***A Edt nao foi encontrada "+::_cCodpsp+"-"+::_cEdt
				_lRet := .f.
			EndIf
		Else
			_lRet := .f.
		EndIf
	EndIf
	
	If !_lRet
		SetSoapFault("WSALTEDT",::_cMsg)
	Endif
Return(_lRet)

//Valida se Existem pedidos as Tarefas filhas da EDT
Static Function WS002PC(cFil,cProj,cEdt,cRevisa)

	Local cQuery := ""
	Local cQueryPc := ""
	Local aPedidos := {}
	Local aExctar := {}
	Local cMsgError := ""
	Local i := 0
	
	//Exclui as Tarefas do PSP
	cQuery := " SELECT AF9_PROJET,AF9_REVISA,AF9_TAREFA "
	cQuery += " FROM "+RETSQLNAME("AF9")+" AF9 "
	cQuery += " WHERE "
	cQuery += " AF9_PROJET = '"+ALLTRIM(cProj)+"' AND "
	cQuery += " SUBSTRING(AF9_EDTPAI,1,LEN('"+ALLTRIM(cEdt)+"')) = '"+ALLTRIM(cEdt)+"' AND "
	cQuery += " AF9_REVISA = '"+ALLTRIM(cRevisa)+"' "
	cQuery += " AND D_E_L_E_T_ = '' "

	TCQUERY cQuery NEW ALIAS "setTar"

	dbSelectArea('setTar')
	WHILE setTar->(!EOF())
		
		cQueryPc := " SELECT TOP 1 C7_NUM "
		cQueryPc += " FROM "+RETSQLNAME("SC7")+" "
		cQueryPc += " WHERE "
		cQueryPc += " C7_PROJET = '"+ALLTRIM(cProj)+"' AND "
		cQueryPc += " C7_TAREFA = '"+setTar->AF9_TAREFA+"' AND "
		cQueryPc += " D_E_L_E_T_ = '' "
		
		TCQUERY cQueryPc NEW ALIAS "setpc"
		
		DbSelectArea('setpc')
		IF setpc->(!EOF())
			AADD(aPedidos,{setpc->C7_NUM})
			setPc->(dbSkip())
		EndIf
		setPc->(dbCloseArea())

		AADD(aExctar,{setTar->AF9_PROJET,setTar->AF9_REVISA,setTar->AF9_TAREFA})
		setTar->(dbSkip())
	EndDO
	setTar->(dbCloseArea())
	
	IF LEN(aPedidos) > 0
		_lRetpc := .F.
		cMsgError := "***A Edt nao pode ser excluida possui pedido de compra vinculado."
	Else
		For i = 1 to Len(aExctar)
			DbSelectArea("AF9")
			AF9->(dbSetOrder(1))
			IF AF9->( DBSEEK(AVKEY(alltrim(cFil),'AF8_FILIAL')+AVKEY(alltrim(cProj),'AF8_PROJET')+AVKEY(alltrim(cRevisa),'AF8_REVISA')+AVKEY(alltrim(aExctar[i][3]),'AF9_TAREFA')) )
				RecLock("AF9", .f.)
					AF9->(DbDelete())
				AF9->(msUnLock())
			ENDIF
		Next i
	ENDIF
	
Return(cMsgError)