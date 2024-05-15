#Include 'Protheus.ch'
#Include "APWEBSRV.CH"
#Include "RWMAKE.Ch"
#Include "TOPCONN.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PRGW001 - WEBSERVICE
Montagem da Estrutura do WebService
@aParam
@author	David Ferreira Quadras
@since		17/10/2014
/*/
//--------------------------------------------------------------------        

WSSERVICE NEWPROJ DESCRIPTION "Gravacao Cadastro Projeto"

	WSDATA KEY					As String 		//Chave para liberação de Acesso aos métodos de WebService.
	WSDATA _cEmpresa			As String
	WSDATA _cCodigo				As String   	OPTIONAL
	WSDATA _cFilial				As String    	OPTIONAL
	WSDATA _cProjetoInt			As String
	WSDATA _cPsp				As String     OPTIONAL
	WSDATA _cUniNeg				As String     OPTIONAL
	WSDATA _cCodVda				As String     OPTIONAL
	WSDATA _cDescricao			As String
	WSDATA _cRevisa				As String		OPTIONAL
	WSDATA _cCodSeq				As String     OPTIONAL
	WSDATA _cCodCli				As String
	WSDATA _cLojCli				As String
	WSDATA _cTipPrj				As String
	WSDATA _cDtEntr				As String
	WSDATA _cDtEntrF			As String
	WSDATA _cDtVend				As String
	WSDATA _cPercComissao		As String 		// Percentual de Comissao - 1=1%;2=2%
	WSDATA _cFase				As String
	WSDATA	_cAtendimento		As String
	WSDATA _cContato1			As String
	WSDATA _cOBS				As String
	WSDATA _cEncerraPrj			As String
	WSDATA _cNomeAgencia		As String
	WSDATA _cWsnull				As String   OPTIONAL
	WSDATA _cMsg				As String	OPTIONAL
	WSDATA Juros 				As Float 	Optional
	WSDATA Descontos 			As Float 	Optional

	WSMETHOD WSincProjeto    	DESCRIPTION "Método Gravação Cadastro de Projetos"
	WSMETHOD WSAltProjeto    	DESCRIPTION "Método de Alteração de Projetos"
	WSMETHOD WSExcluiProjeto	DESCRIPTION	"Método de Exclusão de Projetos"
	WSMETHOD setJurosDescProj	DESCRIPTION	"Método para gravar juros e Descontos do Projeto" 
	WSMETHOD setDataVendaProj	DESCRIPTION "Método para Gravar Data de Venda do PSP."	

ENDWSSERVICE

//-------------------------------------------------------------------
/*/
{Protheus.doc} WSincProjeto
Metodo Cadastro Projeto
@aParam
@author	David Ferreira
@since		18/04/2013
@uso        WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSincProjeto WSRECEIVE KEY, _cEmpresa, _cFilial, _cDescricao, _cUniNeg,_cCodVda,	_cCodSeq,_cCodCli,_cLojCli,	_cTipPrj,_cDtEntr WSSEND _cMsg WSSERVICE NEWPROJ
	
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cNome		:=""
	Local _cNReduz	:=""
	Local _cDTpPrj	:=""
	Local _cTemplate	:=""
	Local _cCdGest	:=""
	Local _cRevisa	:="0001"
	Local aGetPSP		:= {}
	Local aMsgErr		:= {}
	Local _cCodigo	:= ""
	Local _cQry 		:= ""
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::_cEmpresa), Alltrim(::_cFilial))  // Posiciona na Empresa.

	::_cMsg :=""
	If !Empty(cMsgEmp)
		::_cMsg:= "Erro:" + cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsIncProjeto]"
			_lRet:= .f.
		EndIf
	EndIf*/
	
	If _lRet

		aGetPSP 	 	:= GetPSPnew1(::_cUniNeg,::_cCodVda)
		_cCodigo  		:= aGetPSP[1]
		::_cCodSeq  	:= aGetPSP[2]

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1")+AvKey(::_cCodCli,"A1_COD")+AvKey(::_cLojCli,"A1_LOJA")))
			_cNome	:=Alltrim(SA1->A1_NOME)
			_cNReduz:=Alltrim(SA1->A1_NREDUZ)
			_cLojaCli := SA1->A1_LOJA
		Else
			::_cMsg+=" Erro: Cliente "+Alltrim(::_cCodCli)+"informado nao encontrado"
			_lRet:=.F.
		EndIf

		_cQry := " SELECT ZL_TMPPRJ,ZL_TIPPROJ  FROM "+RetSqlName("SZL")+" SZL WHERE SZL.ZL_CODIGO ='"+::_cTipPrj+"' AND SZL.D_E_L_E_T_ = '' "
		TCQUERY _cQry NEW ALIAS "TIPO"
		DbSelectArea("TIPO")
		If !TIPO->(Eof())
			_cTemplate:= TIPO->ZL_TMPPRJ
			_cDTpPrj:= Alltrim(TIPO->ZL_TIPPROJ)
		EndIf
		TIPO->(DbCloseArea())
		
	EndIf
	
	
	If _lRet
	
		Begin Transaction
	
		RecLock("AF8",.T.)
			AF8->AF8_FILIAL	:=_cFilial
			AF8->AF8_PROJET	:=Substr(_cCodigo,1,10)//Composto por Unid.Neg.+Cod.Vend+Cod.Seq.
			AF8->AF8_X_TIPO	:=Substr(::_cUniNeg,1,4)
			AF8->AF8_X_VEND	:=Substr(::_cCodVda,1,6)
			AF8->AF8_X_PCOM	:=Substr(::_cCodSeq,1,4)
			AF8->AF8_DATA		:=dDatabase
			AF8->AF8_REVISA 	:=_cRevisa
			AF8->AF8_X_DECR 	:=Substr(::_cDescricao,1,60)   //Descricao do JOB
			AF8->AF8_FASE		:="01"
			AF8->AF8_TPPRJ	:=Substr(::_cTipPrj,1,4)
			AF8->AF8_DESCRI	:=Substr(_cNReduz+" - "+_cDTpPrj+" - "+Alltrim(::_cDescricao),1,60)//Retranca Composto por Nom.Red.Cli+Descr.Tp Prj+Descr.Job
			AF8->AF8_CLIENT	:=Substr(::_cCodCli,1,6)
			AF8->AF8_LOJA 	:=Substr(::_cLojCli,1,2)
			AF8->AF8_X_DESC	:=Substr(_cNome,1,60)	//Nome Cliente
			AF8->AF8_X_DTEN	:=StoD(::_cDtEntr)//Exemplo:20130101
			AF8->AF8_DELIM 	:="."
			AF8->AF8_MASCAR 	:="2222222222"
			AF8->AF8_X_MANU 	:="N"
			AF8->AF8_NMAX 	:=999
			AF8->AF8_NMAXF3 	:=2
			AF8->AF8_CALEND 	:="001"
			AF8->AF8_TRUNCA 	:="1"
			AF8->AF8_AUTCUS 	:="1"
			AF8->AF8_PRJREV 	:="1"
			AF8->AF8_CTRUSR 	:="2"
			AF8->AF8_TPCUS 	:="1"
			AF8->AF8_PRIREA 	:="1"
			AF8->AF8_CUSOP 	:="1"
			AF8->AF8_CUSOPE 	:="1"
			AF8->AF8_REAFIX 	:="1"
			AF8->AF8_TIPOFA 	:="1"
			AF8->AF8_PAR002 	:="3"
			AF8->AF8_PAR003 	:="2"
			AF8->AF8_PAR004 	:="2"
			AF8->AF8_PAR005 	:="1"
			AF8->AF8_PAR006 	:="2"
		AF8->(MsUnlock())
		
		//Historico da Revisao
		DbSelectArea("AFE")
					
		RecLock("AFE",.T.)
			AFE->AFE_FILIAL:=xFilial("AFE")
			AFE->AFE_PROJET:=Substr(_cCodigo,1,10)
			AFE->AFE_REVISA:=_cRevisa
			AFE->AFE_DATAI :=dDatabase
			AFE->AFE_HORAI :=Time()
			AFE->AFE_USERI :=__cUserID
			AFE->AFE_MEMO  :="Inclusao WebService"
		AFE->(MsUnlock())
	
		StructTemp2(_cFilial,_cCodigo,_cTemplate,_cCdGest, Substr(_cNReduz+Space(1)+_cDTpPrj+Space(1)+Alltrim(::_cDescricao),1,60) )

	End Transaction
	
	::_cMsg := _cCodigo

	EndIf	
	

Return(_lRet)

//-------------------------------------------------------------------
/*/StructTempl
Montagem da Estrutura baseado no template padrao
@aParam
@author		Marcos Kato
@since		06/09/2013
@uso        WEBSERVICE
/*/
//--------------------------------------------------------------------
Static Function StructTemp2(_cFilial, _cCdPrj,_cCdTpl,_cGestor, cNomeJob)
	Local _aArea	:= GetArea()
	Local _nUrv   := ""
	Local _cEDT	:= ""
	Local _cQryE  := ""
	Local _cQryC  := ""
	Local _cQryT  := ""
	Local _cQryA  := ""

	DbSelectArea("AFC")
	AFC->(DbSetOrder(1))
	
	RecLock("AFC",.T.)

	AFC->AFC_FILIAL:=  _cFilial
	AFC->AFC_PROJET:=  _cCdPrj
	AFC->AFC_REVISA:=  "0001"
	AFC->AFC_EDT   :=  _cCdPrj
	AFC->AFC_NIVEL :=  '001'
	AFC->AFC_DESCRI:=  cNomeJob
	AFC->AFC_UM	 :=  'UN'
	AFC->AFC_QUANT :=  1
	AFC->AFC_EDTPAI:=  _cCdPrj
	AFC->AFC_CALEND:=  '001'
	AFC->AFC_X_GEST:=  '020'
	AFC->(MsUnlock())

	RecLock("AFC",.T.)

	AFC->AFC_FILIAL:=  _cFilial
	AFC->AFC_PROJET:=  _cCdPrj
	AFC->AFC_REVISA:=  "0001"
	AFC->AFC_EDT   :=  '1'
	AFC->AFC_NIVEL :=  '002'
	AFC->AFC_DESCRI:=  'FATURAMENTO'
	AFC->AFC_EDTPAI:=  _cCdPrj
	AFC->AFC_CALEND:=  '001'
	AFC->AFC_X_GEST:=  '020'
	AFC->(MsUnlock())
	
	RecLock("AFC",.T.)
	AFC->AFC_FILIAL:=  _cFilial
	AFC->AFC_PROJET:=  _cCdPrj
	AFC->AFC_REVISA:=  "0001"
	AFC->AFC_EDT   :=  '2'
	AFC->AFC_NIVEL :=  '002'
	AFC->AFC_DESCRI:=  'COMPRAS NÃO PREVISTAS'
	AFC->AFC_EDTPAI:=  _cCdPrj
	AFC->AFC_CALEND:=  '001'
	AFC->AFC_X_GEST:=  '020'
	AFC->(MsUnlock())
	
	RecLock("AFC",.T.)
	AFC->AFC_FILIAL:=  _cFilial
	AFC->AFC_PROJET:=  _cCdPrj
	AFC->AFC_REVISA:=  "0001"
	AFC->AFC_EDT   :=  '3'
	AFC->AFC_NIVEL :=  '002'
	AFC->AFC_DESCRI:=  'ORÇAMENTO'
	AFC->AFC_EDTPAI:=  _cCdPrj
	AFC->AFC_CALEND:=  '001'
	AFC->AFC_X_GEST:=  '020'
	AFC->(MsUnlock())
		

	//Tarefa
	DbSelectArea("AF9")
	AF9->(DbSetOrder(1))
	
	RecLock("AF9",.T.)
	AF9->AF9_FILIAL:= _cFilial
	AF9->AF9_PROJET:=_cCdPrj
	AF9->AF9_REVISA:="0001"
	AF9->AF9_TAREFA:= '1.01'
	AF9->AF9_EDTPAI:= '1'
	AF9->AF9_NIVEL := '003'
	AF9->AF9_DESCRI:= 'FATURA DO PROJETO'
	AF9->AF9_START := dDatabase
	AF9->AF9_FINISH:= dDatabase
	AF9->AF9_CALEND:= '001'
	AF9->(MsUnlock())
	
	RecLock("AF9",.T.)
	AF9->AF9_FILIAL:=_cFilial
	AF9->AF9_PROJET:=_cCdPrj
	AF9->AF9_REVISA:="0001"
	AF9->AF9_TAREFA:= '1.02'
	AF9->AF9_EDTPAI:= '1'
	AF9->AF9_NIVEL := '003'
	AF9->AF9_DESCRI:= 'FATURA DO REEMBOLSO'
	AF9->AF9_START := dDatabase
	AF9->AF9_FINISH:= dDatabase
	AF9->AF9_CALEND:= '001'
	AF9->(MsUnlock())
	
	RecLock("AF9",.T.)
	AF9->AF9_FILIAL:=_cFilial
	AF9->AF9_PROJET:=_cCdPrj
	AF9->AF9_REVISA:="0001"
	AF9->AF9_TAREFA:= '2.01'
	AF9->AF9_EDTPAI:= '2'
	AF9->AF9_NIVEL := '003'
	AF9->AF9_DESCRI:= 'COMPRAS NÃO PREVISTAS'
	AF9->AF9_START := dDatabase
	AF9->AF9_FINISH:= dDatabase
	AF9->AF9_CALEND:= '001'
	AF9->(MsUnlock())

	AF9->(dbclosearea())
	AFC->(dbclosearea())
Return(Nil)

//-------------------------------------------------------------------
/*/StructTempl
Retorna PSP
@aParam
@author	David
@since		17/10/2014
@uso       WEBSERVICE
/*/
//--------------------------------------------------------------------
Static Function GetPSPnew1(_cUniNeg,_cCodVda)

	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cNome		:=""
	Local _cNReduz	:=""
	Local _cDTpPrj	:=""
	Local _cTemplate	:=""
	Local _cCdGest	:=""
	Local cQuery      :=""
	Local _nSeq 		:="0000"
	Local cPosIni		:= AllTrim(_cUniNeg)+AllTrim(_cCodVda)
	Local aRet 		:= Array(2)

	cQuery := " SELECT MAX(AF8_PROJET) PROJETO "
	cQuery += " FROM "+RetSqlName("AF8")+ " AF8 "
	cQuery += " WHERE AF8.AF8_X_TIPO = '"+_cUniNeg+"' AND AF8.AF8_X_VEND ='"+_cCodVda+"' AND AF8.D_E_L_E_T_ = ''"
	TCQUERY cQuery NEW ALIAS "setpsp"

	dbSelectArea('setpsp')
	While !setpsp->(EOF())
		_nSeq := Soma1(SUBSTR(setpsp->PROJETO, Len(cPosIni)+1,4))
		setpsp->(dbSkip())
	Enddo
	setpsp->(dbClosearea())

	aRet[1]:= Alltrim(_cUniNeg) + Alltrim(_cCodVda) + Alltrim(_nSeq)
	aRet[2]:= Alltrim(_nSeq)

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSAltProjeto
Metodo de alteração do Projeto
@aParam
@author		David Ferreira
@since		24/10/2013
@uso        WEBSERVICE
/*/
//--------------------------------------------------------------------
WSMETHOD WSAltProjeto WSRECEIVE KEY, _cEmpresa	  ,_cFilial , _cCodigo	,_cDescricao,;
	_cProjetoInt ,_cCodVda, _cCodCli	,_cLojCli	 ,;
	_cTipPrj	  , _cFase	 , _cOBS	  	, _cDtEntr	 ,;
	_cDtEntrF	  ,	_cDtVend, _cContato1  /*, _cPercComissao, _cNomeAgencia*/ WSSEND _cMsg WSSERVICE NEWPROJ
	
Local _lRet		:=.T.
Local _aDados		:={}
Local _cNome		:=""
Local _cNReduz	:=""
Local _cDTpPrj	:=""
Local _cTemplate	:=""
Local _cCdGest	:=""
Local aGetPSP		:= {}
Local cMsgEmp		:= u_TrocaEmp(Alltrim(::_cEmpresa), Alltrim(::_cFilial))  // Posiciona na Empresa.

::_cMsg:=""
If !Empty(cMsgEmp)
	::_cMsg:= cMsgEmp
	_lRet:= .f.
EndIf
/*
If _lRet
	If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
		::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsAltProjeto]"
		_lRet:= .f.
	EndIf
EndIf*/
	
If _lRet

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1")+AvKey(::_cCodCli,"A1_COD")+AvKey(::_cLojCli,"A1_LOJA")))
		_cNome	 := Alltrim(SA1->A1_NOME)
		_cNReduz:= Alltrim(SA1->A1_NREDUZ)
	Else
		::_cMsg+="***Cliente informado nao encontrado"
		_lRet:=.F.
	EndIf
EndIf

If _lRet
	DbSelectArea("AF8")
	AF8->(DbSetOrder(1))
	If AF8->(DbSeek(::_cFilial+::_cCodigo))
		If Alltrim(AF8->AF8_STATUS) == '1' // 1=ENCERRADO; BRANCO = PERMITE ALTERAÇÃO.
			::_cMsg += "***Projeto encerrado não permite alteração!"
			_lRet:=.F.
		EndIf
	Else
		::_cMsg += "***Projeto não localizado!"
		_lRet:=.F.
	EndIf
EndIf
	
	/*
	If _lRet
		If !(Alltrim(::_cPercComissao) $ "1/2")
			::_cMsg := "Defina o Percentual de Comissão do Vendedor!"
			_lRet := .f. 
		EndIf	
	EndIf
	*/
	
If _lRet

	RecLock("AF8",.F.)
			
			// Aba - Dados do Projeto
	If !Empty(::_cProjetoInt)
		AF8->AF8_X_PROJ := Substr(::_cProjetoInt,1,4)
	EndIf
			
			/*
			AF8->AF8_XCOMISS := _cPercComissao
			*/
			
	If !Empty(::_cCodCli)
		AF8->AF8_CLIENT	:= Substr(::_cCodCli,1,6)
		AF8->AF8_LOJA 	:= Substr(::_cLojCli,1,2)
	EndIf
			
	AF8->AF8_X_DESC := Substr(_cNome,1,60)	//Nome Cliente

	If Empty(AF8->AF8_DTVEND) // Uma vez informada a Data de Venda do PSP, não é possível alterá-la.
		AF8->AF8_DTVEND := StoD(_cDtVend)
	EndIf
			
	If !Empty(::_cDescricao)
		AF8->AF8_X_DECR 	:= Substr(::_cDescricao,1,60)   //Descricao do JOB
		AF8->AF8_DESCRI	:= Substr(_cNReduz+Space(1)+_cDTpPrj+Space(1)+Alltrim(::_cDescricao),1,60)//Retranca Composto por Nom.Red.Cli+Descr.Tp Prj+Descr.Job
	EndIf
			
	If !Empty(::_cTipPrj)
		AF8->AF8_TPPRJ	:= Substr(::_cTipPrj,1,4)
	EndIf
			
	If !Empty(::_cFase)
		AF8->AF8_FASE		:= ::_cFase
	EndIf
			
	If !Empty(::_cDtEntr)
		AF8->AF8_X_DTEN	:= StoD(::_cDtEntr) // Exemplo:20130101
	EndIf
			
	If !Empty(::_cDtEntrF)
		AF8->AF8_XDTENF	:= StoD(::_cDtEntrF) // Exemplo:20130101
	EndIf

	If !Empty(::_cContato1)
		AF8->AF8_CTCLI1  := ::_cContato1
	EndIf
			
			/*
			If !Empty(::_cNomeAgencia)
				AF8->AF8_X_NAGE  := ::_cNomeAgencia
			EndIf	
			*/
	AF8->AF8_ENCPRJ := '2'
	
			// Aba - Outros			
	AF8->AF8_X_MANU := '2'

			// Realiza a alteração do campo MEMO usando SYP			
	If !Empty(::_cOBS)
		::_cOBS:= NoAcento(AnsiToOem(AllTrim(::_cOBS)))
		_nTam1 := TamSX3("AF8_OBS")[1]
		MSMM(,_nTam1,,::_cOBS,1,,,"AF8","AF8_CODMEM")
	EndIf

	AF8->(MsUnlock())

	::_cMsg+="***Projeto Alterado com sucesso! -"+::_cCodigo
Else
	SetSoapFault("WSAltProjeto",::_cMsg)
EndIf
Return(_lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} WSExcluiProjeto
Metodo de exclusão do Projeto
@aParam
@author		David Ferreira
@since		24/10/2013
@uso        WEBSERVICE
/*/
//--------------------------------------------------------------------

WSMETHOD WSExcluiProjeto WSRECEIVE KEY, _cEmpresa,_cFilial, _cCodigo WSSEND _cMsg WSSERVICE NEWPROJ
	
	Local _lRet		:= .T.
	Local _aDados		:= {}
	Local _cNome		:= ""
	Local _cNReduz	:= ""
	Local nSqlError	:= 0
	Local _cDTpPrj	:= ""
	Local _cTemplate	:= ""
	Local _cCdGest	:= ""
	Local aGetPSP		:= {}
	Local cQuery		:= ""
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::_cEmpresa), Alltrim(::_cFilial))  // Posiciona na Empresa.
	
	::_cMsg:=""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim( GetMV('ES_KEYWS') )
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [WsIncProjeto]"
			_lRet:= .f.
		EndIf
	EndIf*/
	
	If _lRet
		// Pedido de Compra
		cQuery := "SELECT '1' FROM SC7"+Alltrim(::_cEmpresa)+"0 SC7 WHERE SC7.C7_CODPSP = '"+AllTrim(_cCodigo)+"' AND SC7.D_E_L_E_T_ = '' "
		TCQUERY cQuery NEW ALIAS "TSC7"
	EndIf

	If _lRet
		DbSelectArea("TSC7")
		If !TSC7->(Eof())
			::_cMsg:="Projeto não pode ser excluído, pois existem pedidos de Compras vinculados!"
			_lRet := .f.
		EndIf
		TSC7->(DbCloseArea())
	EndIf

	// Nota Fiscal de Entrada
	If _lRet
		cQuery := "SELECT '1' FROM SD1"+Alltrim(::_cEmpresa)+"0 SD1 WHERE SD1.D1_CODPSP = '"+AllTrim(_cCodigo)+"' AND SD1.D_E_L_E_T_ = '' "
		TCQUERY cQuery NEW ALIAS "TSD1"
		
		DbSelectArea("TSD1")
		If !TSD1->(Eof())
			::_cMsg:="Projeto não pode ser excluído, pois existe(m) Documento(s) de entrada vinculados!"
			_lRet := .f.
		EndIf
		TSD1->(DbCloseArea())
	EndIf
	
	// Previsão de Faturamento	
	If _lRet
		cQuery := "SELECT '1' FROM PAS"+Alltrim(::_cEmpresa)+"0 PAS WHERE PAS.PAS_PROJET ='"+AllTrim(_cCodigo)+"' AND PAS.D_E_L_E_T_ = '' "
		TCQUERY cQuery NEW ALIAS "TPAS"
		
		DbSelectArea("TPAS")
		If !TPAS->(Eof())
			::_cMsg:="Projeto não pode ser excluído, pois existe Faturamento atrelado ao mesmo."
			_lRet := .f.
		EndIf
		TPAS->(DbCloseArea())
	EndIf

	If _lRet
		::_cMsg := ""
		DbSelectArea("AF8")
		AF8->(DbSetOrder(1))
		If !AF8->(DbSeek(::_cFilial+::_cCodigo))
			::_cMsg += "***Projeto não localizado!"
			_lRet:=.F.
		Else
			RecLock("AF8",.F.)
			AF8->(dbdelete())
			AF8->(MsUnlock())
			::_cMsg :="***Projeto ["+::_cCodigo+"] excluído com sucesso!"
			_lRet := .t.
		EndIf
	EndIf
	
	If _lRet

		// Revisões
		_cQuery := " SELECT AFE.R_E_C_N_O_ AS RECAFE FROM "+RetSqlName("AFE")+" AFE WHERE AFE.AFE_PROJET ='"+Alltrim(::_cCodigo)+"' AND AFE.D_E_L_E_T_ = '' "
		TCQUERY _cQuery NEW ALIAS "TAFE"

		DbSelectArea("TAFE")
		If !TAFE->(Eof())
			While !TAFE->( Eof())
				DbSelectArea("AFE")
				AFE->( DbGoTo(TAFE->RECAFE) )
				AFE->( RecLock("AFE", .F. ) )
				AFE->( DbDelete() )
				AFE->( MsUnLock() )
				TAFE->( DbSkip() )
			EndDo
			::_cMsg:="Revisões Excluídas com Sucesso. Projeto["+AllTrim(::_cCodigo)+"]"
			_lRet := .t.
		EndIf
		TAFE->(DbCloseArea())
		
		// Estrutura do Projeto.			
		_cQuery := "SELECT AFC.R_E_C_N_O_ AS RECAFC FROM "+RetsqlName("AFC")+" AFC WHERE AFC.AFC_PROJET ='"+Alltrim(::_cCodigo)+"' AND AFC.D_E_L_E_T_ = '' "
		TCQUERY _cQuery NEW ALIAS "TAFC"
			
		DbSelectArea("TAFC")
		If !TAFC->(Eof())
			While !TAFC->( Eof())
				DbSelectArea("AFC")
				AFC->( DbGoTo(TAFC->RECAFC) )
	
				AFC->( RecLock("AFC", .F. ) )
				AFC->( DbDelete() )
				AFC->( MsUnLock() )
	
				TAFC->( DbSkip() )
			EndDo
			::_cMsg:="Estruturas Excluídas com Sucesso. Projeto["+AllTrim(::_cCodigo)+"] (AFC)"
			_lRet := .t.
		EndIf
		TAFC->(DbCloseArea())

		// AF9 - Tarefas.
		_cQuery := "SELECT AF9.R_E_C_N_O_ AS RECAF9 FROM "+RetSqlName("AF9")+" AF9 WHERE AF9.AF9_PROJET ='"+::_cCodigo+"' AND AF9.D_E_L_E_T_ = '' "
		TCQUERY _cQuery NEW ALIAS "TAF9"
			
		DbSelectArea("TAF9")
		If !TAF9->(Eof())
			While !TAF9->( Eof())
				DbSelectArea("AF9")
				AF9->( DbGoTo(TAF9->RECAF9) )
			
				AF9->( RecLock("AF9", .F. ) )
				AF9->( DbDelete() )
				AF9->( MsUnLock() )
				
				TAF9->( DbSkip() )
				
			EndDo
			::_cMsg:="Tarefas Excluídas com Sucesso. Projeto["+AllTrim(::_cCodigo)+"] (AF9)"
			_lRet := .t.

		EndIf
		TAF9->(DbCloseArea())

		// AFA - Itens de Tarefas.
		_cQuery := "SELECT AFA.R_E_C_N_O_ AS RECAFA FROM "+RetSqlName("AFA")+" AFA WHERE AFA_PROJET ='"+::_cCodigo+"' AND D_E_L_E_T_ = '' "
		TCQUERY _cQuery NEW ALIAS "TAFA"
		DbSelectArea("TAFA")
		If !TAFA->(Eof())
			While !TAFA->( Eof())
				
				DbSelectArea("AFA")
				AFA->( DbGoTo(TAFA->RECAFA) )
				
				AFA->( RecLock("AFA", .F. ) )
				AFA->( DbDelete() )
				AFA->( MsUnLock() )
				
				TAFA->( DbSkip() )
			EndDo
			::_cMsg:="Itens das Tarefas excluídos com Sucesso. Projeto["+AllTrim(::_cCodigo)+"] (AFA)"
			_lRet := .t.
		EndIf
		TAFA->(DbCloseArea())
	
	EndIf
	
	If !_lRet
		SetSoapFault("WSExcluiProjeto",::_cMsg)
	EndIf

Return(_lRet)

User Function PMRGW001()
	Alert("debug")
Return



//-------------------------------------------------------------------
/*/ {Protheus.doc} SetJurosDescProj
Grava Juros e Descontos para o Projeto
@author Fernando
@since	 08/04/2015
/*/
//--------------------------------------------------------------------
WSMETHOD setJurosDescProj WSRECEIVE KEY,_cEmpresa, _cFilial,_cCodigo, Juros, Descontos WSSEND _cMsg WSSERVICE NEWPROJ

	Local cMsgEmp :=	u_TrocaEmp(Alltrim(::_cEmpresa), Alltrim(::_cFilial))  // Posiciona na Empresa.
	Local _lRet := .t.

	::_cMsg := ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet	:= .f.
	EndIf
	
	If _lRet

		dbSelectarea("AF8")
		AF8->(DbSetOrder(1))
		If AF8->(DbSeek(::_cFilial+::_cCodigo))
				RecLock("AF8",.F.)
					If ::Juros > 0
						AF8->AF8_XJUROS := ::Juros
					EndIf
					
					If ::Descontos > 0
						AF8->AF8_XDESC := ::Descontos					
					EndIf	
				AF8->(MsUnLock())
		Else
			_lRet := .f.
			::_cMsg := "Projeto"+::_cCodigo+" não Localizado!"
			SetSoapFault("SetJurosDescProj",::_cMsg)
		EndIf
	EndIf
		
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} setDataVendaProj
Atualiza data de Venda do Projeto
@author Fernando
@since	 01/04/2015
/*/
//--------------------------------------------------------------------
WSMETHOD setDataVendaProj WSRECEIVE KEY, _cEmpresa, _cFilial, _cCodigo WSSEND _cMsg WSSERVICE NEWPROJ

	Local cMsgEmp :=	u_TrocaEmp(Alltrim(::_cEmpresa), Alltrim(::_cFilial))  // Posiciona na Empresa.
	Local _lRet := .t.

	::_cMsg := ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet	:= .f.
	EndIf
	
	If _lRet
		dbSelectarea("AF8")
		AF8->(DbSetOrder(1))
		If AF8->(DbSeek(AvKey(::_cFilial, "AF8_FILIAL")+AvKey(::_cCodigo, "AF8_PROJET")))
			If Empty(AF8->AF8_DTVEND)
				RecLock("AF8",.F.)
					AF8->AF8_DTVEND := date()
				AF8->(MsUnLock())
				::_cMsg := "Data Venda gravada com sucesso!"
			Else
				_lRet := .f.
				::_cMsg := "Data de Venda já informada para o Projeto"+::_cCodigo+"!"
				SetSoapFault("setDataVendaProj",::_cMsg)				
			EndIf
		Else
			_lRet := .f.
			::_cMsg := "Projeto"+::_cCodigo+" não Localizado!"
			SetSoapFault("setDataVendaPSP",::_cMsg)
		EndIf
	EndIf
		
Return(_lRet)