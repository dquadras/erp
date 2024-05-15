#Include "APWEBSRV.CH"
#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PRGW003 - WebServices para Crud de Tarefas de um 
Projeto
@aParam
@author	David Ferreira Quadras
@since		20/10/2014
/*/
//--------------------------------------------------------------------        
User Function PRGW003()
	alert("info debug")
Return(Nil)

//Definição de WebServices.
WSSERVICE NEWTRF DESCRIPTION "MANUTENÇÃO DE TAREFAS"
	WSDATA KEY				As String
	WSDATA _cEmp			As String
	WSDATA _cFilial		As String
	WSDATA _cCodpsp		As String
	WSDATA _cTarefa		As String
	WSDATA _cDescricao	As String 		OPTIONAL
	WSDATA _cRevisa		As String
	WSDATA _cEdtPai		As String		OPTIONAL
	WSDATA _cNivel		As String		OPTIONAL
	WSDATA _fOrcProj		As Float		OPTIONAL
	WSDATA _fVenProj		As Float		OPTIONAL
	WSDATA _fOrcReem		As Float		OPTIONAL
	WSDATA _fVenReem		As Float		OPTIONAL
	WSDATA _fMeta 		As Float		OPTIONAL
	WSDATA _cMsg			As String

	//WSDATA Produto		As String
	//WSDATA ItensTarefa	As  aItensTarefa // Itens da Tarefa.
	
	WSMETHOD WSincTarefa DESCRIPTION "Método de Inclusão Tarefas do Projeto."
	WSMETHOD WSaltTarefa DESCRIPTION "Método de Alteração de Tarefas do Projeto."
	WSMETHOD WSexcTarefa DESCRIPTION "Método de Exclusão de tarefas do Projeto."

	//WSMETHOD putTarefa 	DESCRIPTION "Método para inputar tarefas do Projeto."
	
ENDWSSERVICE


//Define Estrutura de Dados.
/*
WSSTRUCT aItensTarefa
	WSDATA Projeto		As String	//char(10)	
	WSDATA Revisao		As String  //char(04)			
	WSDATA Tarefa			As String  //char(12)
	WSDATA Itens 			As Array Of ListItensTarefa
ENDWSSTRUCT

WSSTRUCT ListItensTarefa
	WSDATA Item			As String	OPTIONAL //char(02)
	WSDATA Produto		As String	//char(15)
	WSDATA Quantidade		As Float	//Float(8)	
	//WSDATA CustoUnit		As Float	//Float(15,2)
	//WSDATA MetaQuant		As Float	//Float(8,2)		
	//WSDATA MetaVlrUnit 	As Float	//Float(15,2)	
ENDWSSTRUCT
*/

//-------------------------------------------------------------------
/*/ {Protheus.doc} WSincTarefa
Metodo inclusao de tarefas 
@aParam
@author	David Ferreira
@since		20/10/2014
/*/
//--------------------------------------------------------------------
WSMETHOD WSincTarefa WSRECEIVE KEY,_cEmp,_cFilial,_cCodpsp,_cTarefa,_cDescricao,_cRevisa,_cEdtPai,_cNivel,_fOrcProj,_fVenProj,_fOrcReem,_fVenReem,_fMeta /*,;Produto,ItensTarefa */ WSSEND _cMsg WSSERVICE NEWTRF

	Local _lRet	 :=.T.
	Local _aDados	 :={}
	Local _cCdGest :=""
	Local cMsgEmp	 := u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.
	
	::_cMsg := ""
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
	
		DbSelectArea("AF8")
		AF8->(dbSetOrder(1))
		_lRet := AF8->(dbSeek( AvKey(::_cFilial, "AF8_FILIAL")+AvKey(::_cCodpsp,'AF8_PROJET') ))
		If !_lRet
			::_cMsg := "Projeto não Localizado"
		EndIf
	EndIf	

	If _lRet
		
		DbSelectArea("AF9")
	
		RecLock("AF9",.T.)

		AF9->AF9_FILIAL  	:= ::_cFilial
		AF9->AF9_PROJET  	:= ::_cCodpsp
		AF9->AF9_TAREFA	:= ::_cTarefa
		AF9->AF9_DESCRI  	:= ::_cDescricao
		AF9->AF9_REVISA  	:= ::_cRevisa
		AF9->AF9_EDTPAI  	:= ::_cEdtPai
		AF9->AF9_NIVEL   	:= ::_cNivel
		
		AF9->AF9_START	:= dDataBase
		AF9->AF9_FINISH	:= dDataBase		

		AF9->AF9_CUSTPV  	:= ::_fOrcProj
		AF9->AF9_TVPVI   	:= ::_fVenProj
		AF9->AF9_TVPVBV  	:= ::_fVenProj
		AF9->AF9_CUSTRE  	:= ::_fOrcReem
		AF9->AF9_TVRE    	:= ::_fVenReem
		AF9->AF9_TVBRBV  	:= ::_fVenReem
		AF9->AF9_CUSTO   	:= ::_fOrcProj + ::_fOrcReem
		AF9->AF9_CUSTO   	:= ::_fVenProj + ::_fVenReem
		AF9->AF9_CALEND  	:= "001"
		
		If ::_fVenProj > 0 .AND. ::_fOrcProj > 0
			AF9->AF9_TVPVC   := ::_fVenProj / ::_fOrcProj
		EndIf
		
		If ::_fVenReem > 0 .AND. ::_fOrcReem > 0
			AF9->AF9_TVRECO  := ::_fVenReem / ::_fOrcReem
		EndIf
		
		AF9->AF9_X_META  := ::_fMeta
		AF9->AF9_METUNI  := ::_fMeta
		AF9->AF9_METTOT  := ::_fMeta

		AF9->(MsUnlock())
		
		dbSelectArea("AFA")
		RecLock("AFA",.t.)
			AFA->AFA_FIX   := "2"
			AFA->AFA_PRODUT:= '0000001255' //'0000000011' //::Produto //
			AFA->AFA_QUANT := 1
			AFA->AFA_CUSTD := ::_fOrcProj + ::_fOrcReem
			AFA->AFA_CUSTOT:= (::_fOrcProj + ::_fOrcReem) * 1
			AFA->AFA_METUNI:= ::_fMeta
			AFA->AFA_METQTD:= 1 
			AFA->AFA_METTOT:= ::_fMeta * 1
			AFA->AFA_MOEDA := 1
			AFA->AFA_PLNPOR:= "1"				
			AFA->AFA_ACUMUL:= "4"
		AFA->(MsUnLock())		
		
		/***
		nItensAFA	:= Len(::ItensTarefa:Itens)
		For i := 1 to nItensAFA
		
			If !Empty(::ItensTarefa:Itens[i]:Produto)
		
				RecLock("AFA",.T.)
				AFA->AFA_FILIAL:= ::_cFilial
				AFA->AFA_PROJET:= ::ItensTarefa:Projeto
				AFA->AFA_TAREFA:= ::ItensTarefa:Tarefa
				AFA->AFA_REVISA:= ::ItensTarefa:Revisao				
				AFA->AFA_FIX   := "2"
				AFA->AFA_ITEM  := strzero(i,2)
				AFA->AFA_PRODUT:= ::ItensTarefa:Itens[i]:Produto
				AFA->AFA_QUANT := 1 //::ItensTarefa:Itens[i]:Quantidade
				AFA->AFA_CUSTD := ::ItensTarefa:Itens[i]:CustoUnit
				AFA->AFA_CUSTOT:= (::ItensTarefa:Itens[i]:Quantidade * ::ItensTarefa:Itens[i]:CustoUnit) 
				AFA->AFA_METUNI:= ::ItensTarefa:Itens[i]:MetaVlrUnit
				AFA->AFA_METQTD:= ::ItensTarefa:Itens[i]:Quantidade
				AFA->AFA_METTOT:= ( ::ItensTarefa:Itens[i]:MetaVlrUnit * ::ItensTarefa:Itens[i]:Quantidade )
				AFA->AFA_DATPRF:= dDatabase
				AFA->AFA_MOEDA := 1
				AFA->AFA_PLNPOR:= "1"				
				AFA->AFA_START	:= dDataBase
				AFA->AFA_FINISH	:= dDataBase
				AFA->AFA_ACUMUL := "4"
				AFA->(MsUnLock())
			EndIf	
		Next i
		****/
		::_cMsg+= "***Inclusao de Tarefa Realizada com Sucesso"+::_cCodpsp+"-"+::_cTarefa
	EndIf

	If !_lRet
		SetSoapFault("WSincTarefa",::_cMsg)
	Endif		
	
Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSaltTarefa
Metodo Cadastro Edt 
@aParam
@author	David Ferreira
@since		20/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSaltTarefa WSRECEIVE KEY, _cEmp,_cFilial,_cCodpsp, _cRevisa, _cTarefa, _cDescricao,_fOrcProj,_fVenProj,_fOrcReem,;
									_fVenReem,_fMeta /*, Produto,ItensTarefa*/ WSSEND _cMsg WSSERVICE NEWTRF
	Local _lRet	:=.T.
	Local cMsgEmp	:= u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.
	
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
	
	DbSelectArea("AF8")
	AF8->(dbSetOrder(1))
	_lRet := AF8->(dbSeek( AvKey(::_cFilial, "AF8_FILIAL")+AvKey(::_cCodpsp,'AF8_PROJET') ))
	If !_lRet
		::_cMsg := "Projeto não Localizado"
	EndIf

	DBSELECTAREA('AF9')
	AF9->(DbSetOrder(1)) /// AF9_FILIAL, AF9_PROJET, AF9_REVISA, AF9_TAREFA, AF9_ORDEM, R_E_C_N_O_, D_E_L_E_T_
	If AF9->( DbSeek( AvKey(::_cFilial, "AF9_FILIAL") + AvKey(alltrim(::_cCodpsp),'AF9_PROJET')+AvKey(alltrim(::_cRevisa),'AF9_REVISA')+AvKey(alltrim(::_cTarefa),'AF9_TAREFA')) )
		RecLock("AF9",.F.)
		
		AF9->AF9_DESCRI  := ::_cDescricao
		AF9->AF9_CUSTPV  := ::_fOrcProj
		AF9->AF9_TVPVI   := ::_fVenProj
		AF9->AF9_TVPVBV  := ::_fVenProj
		AF9->AF9_CUSTRE  := ::_fOrcReem
		AF9->AF9_TVRE    := ::_fVenReem
		AF9->AF9_TVBRBV  := ::_fVenReem

		AF9->AF9_CUSTO   := ::_fOrcProj + ::_fOrcReem
		AF9->AF9_CUSTO   := ::_fVenProj + ::_fVenReem

		AF9->AF9_CALEND  := "001"
		
		IF ::_fVenProj > 0 .AND. ::_fOrcProj > 0
			AF9->AF9_TVPVC   := ::_fVenProj / ::_fOrcProj
		ENDIF
		
		IF ::_fVenReem > 0 .AND. ::_fOrcReem > 0
			AF9->AF9_TVRECO  := ::_fVenReem / ::_fOrcReem
		ENDIF
				
		AF9->AF9_X_META  := ::_fMeta
		AF9->AF9_METUNI  := ::_fMeta
		AF9->AF9_METTOT  := ::_fMeta

		AF9->(MsUnlock())
		
		dbSelectArea("AFA")
		AFA->(DbSetOrder(1)) // AFA_FILIAL, AFA_PROJET, AFA_REVISA, AFA_TAREFA, AFA_ITEM, AFA_PRODUT
		If AFA->(DbSeek( AvKey(::_cFilial, "AFA_FILIAL")+AvKey(::_cCodpsp, "AFA_PROJET")+ AvKey(::_cRevisa,"AFA_REVISA")+ AvKey(::_cTarefa,"AFA_TAREFA")+ AvKey( "01","AFA_ITEM") ))
			RecLock("AFA",.f.)
				AFA->AFA_FIX   := "2"
				AFA->AFA_PRODUT:= ::Produto //'0000000011'
				AFA->AFA_QUANT := 1
				AFA->AFA_CUSTD := ::_fOrcProj + ::_fOrcReem
				AFA->AFA_CUSTOT:= (::_fOrcProj + ::_fOrcReem) * 1
				AFA->AFA_METUNI:= ::_fMeta
				AFA->AFA_METQTD:= 1 
				AFA->AFA_METTOT:= ::_fMeta * 1
				AFA->AFA_MOEDA := 1
				AFA->AFA_PLNPOR:= "1"				
				AFA->AFA_ACUMUL:= "4"
			AFA->(MsUnLock())
		EndIf

		/*
		nItensAFA	:= Len(::ItensTarefa:Itens)
		For i := 1 to nItensAFA
		
			If !Empty(::ItensTarefa:Itens[i]:Produto)
				AFA->(DbSetOrder(1)) // AFA_FILIAL, AFA_PROJET, AFA_REVISA, AFA_TAREFA, AFA_ITEM, AFA_PRODUT
				If AFA->(DbSeek( AvKey(::_cFilial, "AFA_FILIAL")+AvKey(::ItensTarefa:Projeto, "AFA_PROJET")+ AvKey(::ItensTarefa:Revisao,"AFA_REVISA")+ AvKey(::ItensTarefa:Tarefa,"AFA_TAREFA")+ AvKey( ::ItensTarefa:Itens[i]:Item,"AFA_ITEM") ))
					RecLock("AFA",.f.)
						AFA->AFA_FILIAL:= ::_cFilial
						AFA->AFA_FIX   := "2"
						AFA->AFA_PRODUT:= ::ItensTarefa:Itens[i]:Produto
						AFA->AFA_QUANT := 1 //::ItensTarefa:Itens[i]:Quantidade
						AFA->AFA_CUSTD := ::ItensTarefa:Itens[i]:CustoUnit
						AFA->AFA_CUSTOT:= (::ItensTarefa:Itens[i]:Quantidade * ::ItensTarefa:Itens[i]:CustoUnit) 
						AFA->AFA_METUNI:= ::ItensTarefa:Itens[i]:MetaVlrUnit
						AFA->AFA_METQTD:= 1 // ::ItensTarefa:Itens[i]:Quantidade
						AFA->AFA_METTOT:= ( ::ItensTarefa:Itens[i]:MetaVlrUnit * ::ItensTarefa:Itens[i]:Quantidade )
						AFA->AFA_MOEDA := 1
						AFA->AFA_PLNPOR:= "1"				
						AFA->AFA_ACUMUL:= "4"
					AFA->(MsUnLock())
				EndIf
			EndIf
		Next i
		*/
		::_cMsg+="***Alteracao de Tarefa Realizada com Sucesso"+::_cCodpsp+"-"+::_cTarefa
	Else
		::_cMsg+="***Nao foi possivel realizar a alteracao "+::_cCodpsp+"-"+::_cTarefa
		_lRet := .f.
	EndIf
	
	if !_lRet
		SetSoapFault("WSaltTarefa",::_cMsg)
	Endif	
	

Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSexcTarefa
Metodo Exclusão de Tarefas. 
@aParam
@author	David Ferreira
@since		20/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSExcTarefa WSRECEIVE KEY,_cEmp,_cFilial,_cCodpsp, _cRevisa, _cTarefa /*,ItensTarefa*/ WSSEND _cMsg WSSERVICE NEWTRF
	Local _lRet	 	:= .T.
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::_cEmp), Alltrim(::_cFilial))  // Posiciona na Empresa.
	Private _lRetpc	:= .T.	
	
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
	
		//Valida se Edt pode ser excluida
		::_cMsg := WS002PC(::_cCodpsp, ::_cTarefa)
		If Empty(::_cMsg)
			DbSelectArea('AF9')
			AF9->(DbSetOrder(1))
			If DbSeek(alltrim(::_cFilial)+AvKey(alltrim(::_cCodpsp),'AF9_PROJET')+AvKey(alltrim(::_cRevisa),'AF9_REVISA')+AvKey(alltrim(::_cTarefa),'AF9_TAREFA'))

				RecLock("AF9",.F.)
					AF9->(DbDelete())
				MsUnLock()
				
				dbSelectArea("AFA")
				AFA->(DbSetOrder(1)) // AFA_FILIAL, AFA_PROJET, AFA_REVISA, AFA_TAREFA, AFA_ITEM, AFA_PRODUT
				If AFA->(DbSeek( AvKey(::_cFilial, "AFA_FILIAL")+AvKey(::_cCodpsp, "AFA_PROJET")+ AvKey(::_cRevisa,"AFA_REVISA")+ AvKey(::_cTarefa,"AFA_TAREFA")+ AvKey( "01","AFA_ITEM") ))
					RecLock("AFA",.f.)
						AFA->(DbDelete())
					AFA->(MsUnLock())
				EndIf

				/***
				dbSelectArea("AFA")
				nItensAFA	:= Len(::ItensTarefa:Itens)
				For i := 1 to nItensAFA
					If !Empty(::ItensTarefa:Itens[i]:Produto)
						AFA->(DbSetOrder(1)) // AFA_FILIAL, AFA_PROJET, AFA_REVISA, AFA_TAREFA, AFA_ITEM, AFA_PRODUT
						If AFA->(DbSeek( AvKey(::_cFilial, "AFA_FILIAL")+AvKey(::ItensTarefa:Projeto, "AFA_PROJET")+ AvKey(::ItensTarefa:Revisao,"AFA_REVISA")+ AvKey(::ItensTarefa:Tarefa,"AFA_TAREFA")+ AvKey( ::ItensTarefa:Itens[i]:Item,"AFA_ITEM") ))
							RecLock("AFA",.f.)
								DbDelete()
							AFA->(MsUnLock())
						EndIf
					EndIf
				Next i
				***/
				::_cMsg+="***Exclusao da tarefa Realizada com Sucesso "+::_cCodpsp+"-"+::_cTarefa
			Else
				::_cMsg+="***A Tarefa nao foi encontrada "+::_cCodpsp+"-"+::_cTarefa
				_lRet := .f.
			EndIf
		Else
			_lRet := .f.
		EndIf
	EndIf
		
	if !_lRet
		SetSoapFault("WSEXCTAREFA",::_cMsg)
	Endif

Return(_lRet)



//Valida se Existem pedidos as Tarefas filhas da EDT
Static Function WS002PC(cProj, _cTarefa)

	Local cQuery := ""
	Local cMsgError := ""
	cQuery := " SELECT TOP 1 AFC_PROJET "
	cQuery += " FROM "+RETSQLNAME("AFC")+" NOLOCK "
	cQuery += " JOIN "+RETSQLNAME("AF9")+" ON AFC_PROJET = AF9_PROJET AND AFC_EDT = AF9_EDTPAI AND AF9010.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RETSQLNAME("SC7")+" ON AF9_PROJET = C7_PROJET AND AF9_TAREFA = C7_TAREFA AND SC7020.D_E_L_E_T_ = '' "
	cQuery += " WHERE AFC_PROJET = '"+alltrim(cProj)+"' "
	
	If Select("setpc") <> 0
		setpc->( DbCloseArea() )
	EndIf

	TCQUERY cQuery NEW ALIAS "setpc"

	dbSelectArea('setpc')
	If setpc->(!EOF())
		_lRetpc := .F.
		cMsgError := "***A Tarefa nao pode ser excluida possui pedido de compra vinculado."
		setpc->(dbSkip())
	EndIf

Return(cMsgError)