#Include "APWEBSRV.CH"
#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"

#DEFINE enter chr(13)+chr(10)

//-------------------------------------------------------------------
/*{Protheus.doc} 
PRGW005 - WebServices para Consulta de Dados do Projeto. 
Projeto
@aParam
@author	David Ferreira Quadras
@since		17/11/2014
/*/
//--------------------------------------------------------------------        
User Function PRGW005()
	alert("Debug")
Return(Nil)

//-----------------------
// Estruturas de Dados
//-----------------------

//Projeto
WSSTRUCT aItensPSP
	WSDATA ItensPSP  As Array Of aListItensPSP
ENDWSSTRUCT
WSSTRUCT aListItensPSP
	WSDATA CodigoPSP		 As String OPTIONAL
	WSDATA DescPSP     	 As String OPTIONAL
ENDWSSTRUCT

//Projeto(4 POSICOES - PSP )
WSSTRUCT aItens2PSP
	WSDATA Itens2PSP  As Array Of aListItens2PSP
ENDWSSTRUCT
WSSTRUCT aListItens2PSP
	WSDATA CodigoPSP		 As String OPTIONAL
	WSDATA DescPSP     	 As String OPTIONAL
ENDWSSTRUCT


//Centro de Custos
WSSTRUCT aItensCC
	WSDATA ItensCC  As Array Of aListItensCC
ENDWSSTRUCT
WSSTRUCT aListItensCC
	WSDATA CodigoCC		 As String OPTIONAL
	WSDATA DescCC     	 As String OPTIONAL
ENDWSSTRUCT

//Unidade de Medida
WSSTRUCT aItensUM
	WSDATA ItensUM  As Array Of aListItensUM
ENDWSSTRUCT
WSSTRUCT aListItensUM
	WSDATA CodigoUM		 As String OPTIONAL
	WSDATA DescUM     	 As String OPTIONAL
ENDWSSTRUCT

//Produto
WSSTRUCT aItensPRD
	WSDATA ItensPRD  As Array Of aListItensPRD
ENDWSSTRUCT
WSSTRUCT aListItensPRD
	WSDATA CodigoPRD		 As String OPTIONAL
	WSDATA DescPRD     	 As String OPTIONAL
	WSDATA GrupoPRD		 As String OPTIONAL
ENDWSSTRUCT


//Cargo 
WSSTRUCT aItensCRG
	WSDATA ItensCRG  As Array Of aListItensCRG
ENDWSSTRUCT
WSSTRUCT aListItensCRG
	WSDATA CodigoCRG		 As String OPTIONAL
	WSDATA DescCRG     	 As String OPTIONAL
ENDWSSTRUCT

//Unidade de Negocio 
WSSTRUCT aItensUN
	WSDATA ItensUN  As Array Of aListItensUN
ENDWSSTRUCT
WSSTRUCT aListItensUN
	WSDATA CodigoUN		 As String OPTIONAL
	WSDATA DescUN     	 As String OPTIONAL
ENDWSSTRUCT

//Cliente
WSSTRUCT aItensCLI
	WSDATA ItensCLI  As Array Of aListItensCLI
ENDWSSTRUCT
WSSTRUCT aListItensCLI
	WSDATA CodigoCLI		 As String OPTIONAL
	WSDATA DescCLI     	 As String OPTIONAL
ENDWSSTRUCT

//Revisoes do Projeto 
WSSTRUCT aItensRev
	WSDATA ItensRev  As Array Of aListItensRev
ENDWSSTRUCT
WSSTRUCT aListItensRev
	WSDATA Revisao		 As String OPTIONAL
ENDWSSTRUCT

//Recursos do Projeto - Produto Interno
WSSTRUCT aItensRec
	WSDATA ItensRec  As Array Of aListItensRec
ENDWSSTRUCT
WSSTRUCT aListItensRec
	WSDATA CodigoRec		 As String OPTIONAL
	WSDATA DescRec     	 As String OPTIONAL
	WSDATA Valor        	 As Float OPTIONAL
ENDWSSTRUCT

//Grupo de Recursos - Area
WSSTRUCT aItensArea
	WSDATA ItensArea  As Array Of aListItensArea
ENDWSSTRUCT
WSSTRUCT aListItensArea
	WSDATA CodEquipe		 As String OPTIONAL
	WSDATA DescArea     	 As String OPTIONAL
ENDWSSTRUCT


//-------------------------------------------------------------------
/*/{Protheus.doc} WebService newRevisaoProjeto para criar nova revisao 
@author	Fernando
@since		12/11/2014
/*/
//--------------------------------------------------------------------
WSSERVICE NewRetInfo DESCRIPTION "WebService para Consultar informações do Protheus."
	
	WSDATA KEY					As String  				// Chave para liberação de Acesso aos métodos de WebService.
	WSDATA Empresa			As String		OPTIONAL	// char(2) Empresa que será criada o projeto - 02-EBCP;06-GNOVA(Não contemplado ainda); 07-EMCI.
	WSDATA Filial				As String  	OPTIONAL	// char(2) Filial/Unidade de negócios utilizada 05-Experience; 08-TV1 PontoCom; 10-TV1/RP; 16-Conteudo e Vídeo.
	WSDATA cWsnull			As String  	OPTIONAL
	WSDATA cProjeto			As String  	OPTIONAL
	WSDATA cTarefa			As String  	OPTIONAL
	WSDATA _cPesquisa			As String		OPTIONAL
	WSDATA _cUnidade			As String		OPTIONAL
	WSDATA _cMsg				As String  	OPTIONAL//char(999)
	WSDATA Produto			As String    	OPTIONAL
	WSDATA ListItensUN		As aItensUN  	OPTIONAL //ARRAY DE Unidade de Negocio
	WSDATA ExcluiPC	    	As boolean   	OPTIONAL //ARRAY DE Unidade de Negocio
	WSDATA ListItensPSP		As aItensPSP OPTIONAL //ARRAY DE PSP'S
	WSDATA ListItens2PSP	As aItens2PSP OPTIONAL //ARRAY DE PSP'S
	WSDATA ListItensCC		As aItensCC  OPTIONAL //ARRAY DE Centro Custos
	WSDATA ListItensUM		As aItensUM  OPTIONAL //ARRAY DE Unidade de Medida
	WSDATA ListItensPRD		As aItensPRD OPTIONAL //ARRAY DE Produtos
	WSDATA ListItensCRG		As aItensCRG OPTIONAL //ARRAY DE Cargos
	WSDATA ListItensCLI		As aItensCLI OPTIONAL //ARRAY DE Clientes
	WSDATA ListItensREC		As aItensRec OPTIONAL //ARRAY DE Recursos
	WSDATA ListItensRev		As aItensRev OPTIONAL //ARRAY DE Revisoes
	WSDATA ListItensEq		As aItensArea OPTIONAL //ARRAY DE Grupos de Recursos
			
	WSMETHOD getUN			DESCRIPTION "Método: Obter Unidade de Negocio."
	WSMETHOD getPsp			DESCRIPTION "Método: Obter PSP."
	WSMETHOD getListaPsp	DESCRIPTION "Método: Obter PSP."
	WSMETHOD getCC			DESCRIPTION "Método: Obter CC."
	WSMETHOD getUM			DESCRIPTION "Método: Obter Unidade de medida."
	WSMETHOD getPrd			DESCRIPTION "Método: Obter Produto."
	WSMETHOD getCRG			DESCRIPTION "Método: Obter Cargo."
	WSMETHOD getCLI			DESCRIPTION "Método: Obter Cliente."
	WSMETHOD getPED			DESCRIPTION "Método: Validar se Existe Pedido de Compra Vinculado ao Projeto/Tarefa."
	WSMETHOD getListaREC 	DESCRIPTION "Método: Retornar os Recursos."
	WSMETHOD getRevisoes 	DESCRIPTION "Método: Lista com as revisões do Projeto."
	WSMETHOD getArea     	DESCRIPTION "Método: Lista com os grupos de Recurso(Area)."
		
ENDWSSERVICE

//-------------------------------------------------------------------
/*/ {Protheus.doc} getUn - Método para Obter dados da Unidade de Negocio
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getUN WSRECEIVE KEY,Empresa,Filial,_cMsg WSSEND ListItensUN WSSERVICE NewRetInfo

	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	//Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp := ""
	

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf

	If _lRet
		cQuery := " SELECT * FROM "+RETSQLNAME("SZ4")+" WHERE Z4_X_COD <> '06' AND Z4_X_COD <> '07' AND D_E_L_E_T_ = '' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensUN:ItensUN, WSClassNew("aListItensUN"))
	
				::ListItensUN:ItensUN[i]:CodigoUN:= (cArqTMP)->Z4_X_COD
				::ListItensUN:ItensUN[i]:DescUN	 := (cArqTMP)->Z4_X_DESC
	
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
		
			i := 1
		
			aAdd(::ListItensUN:ItensUN, WSClassNew("aListItensUN"))
	
			::ListItensUN:ItensUN[i]:CodigoUN:= ""
			::ListItensUN:ItensUN[i]:DescUN	 := ""
			::_cMsg := "Estrutura não Localizada para o Projeto ["+::Projeto+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getPSP - Método para Obter dados Filtrados de Projeto
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getPSP WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensPSP WSSERVICE NewRetInfo

	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp := ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		If Empty(::_cPesquisa)
			::_cMsg:= "Parametro de pesquisa obrigatorio!"
			_lRet:= .f.
		EndIf
	EndIf

	If _lRet
		cQuery := " SELECT AF8_PROJET,AF8_DESCRI FROM "+RETSQLNAME("AF8")+" "
		cQuery += " WHERE (AF8_PROJET LIKE '%"+_cPesquisa+"%' OR AF8_DESCRI LIKE '%"+_cPesquisa+"%')  AND AF8_FILIAL = '"+::Filial+"' AND D_E_L_E_T_ = '' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensPSP:ItensPSP, WSClassNew("aListItensPSP"))
	
				::ListItensPSP:ItensPSP[i]:CodigoPSP:= (cArqTMP)->AF8_PROJET
				::ListItensPSP:ItensPSP[i]:DescPSP	 := (cArqTMP)->AF8_DESCRI
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
			i := 1
				
			aAdd(::ListItensPSP:ItensPSP, WSClassNew("aListItensPSP"))
	
			::ListItensPSP:ItensPSP[i]:CodigoPSP:= ""
			::ListItensPSP:ItensPSP[i]:DescPSP	 := ""
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getCC - Método para Obter dados de Centro de Custos
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getCC WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensCC WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp := ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		cQuery := " SELECT CTT_CUSTO,CTT_DESC01  "
		cQuery += " FROM "+RETSQLNAME("CTT")+" CTT "
		cQuery += " WHERE 	CTT.D_E_L_E_T_ = '' "
		cQuery += "			AND CTT.CTT_DESC01 LIKE '%"+_cPesquisa+"%'  "
		cQuery += "			AND CTT.CTT_BLOQ <> '1' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensCC:ItensCC, WSClassNew("aListItensCC"))
	
				::ListItensCC:ItensCC[i]:CodigoCC:= (cArqTMP)->CTT_CUSTO
				::ListItensCC:ItensCC[i]:DescCC	  := (cArqTMP)->CTT_DESC01
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
			
			i := 1
			
			aAdd(::ListItensCC:ItensCC, WSClassNew("aListItensCC"))
			::ListItensCC:ItensCC[i]:CodigoCC:= ""
			::ListItensCC:ItensCC[i]:DescCC	  := ""
				
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getUM - Método para Obter dados de Unidade de Medida
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getUM WSRECEIVE KEY,Empresa,Filial,_cMsg WSSEND ListItensUM WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), '05')  // Posiciona na Empresa.	
	//Local cMsgEmp 	:= ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		cQuery := " SELECT AH_UNIMED,AH_DESCPO  FROM "+RETSQLNAME("SAH")+" "
		cQuery += " WHERE D_E_L_E_T_ = '' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensUM:ItensUM, WSClassNew("aListItensUM"))
	
				::ListItensUM:ItensUM[i]:CodigoUM := (cArqTMP)->AH_UNIMED
				::ListItensUM:ItensUM[i]:DescUM	   := (cArqTMP)->AH_DESCPO
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
		
			i := 1
			aAdd(::ListItensUM:ItensUM, WSClassNew("aListItensUM"))
	
			::ListItensUM:ItensUM[i]:CodigoUM := ""
			::ListItensUM:ItensUM[i]:DescUM	   := ""
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getPrd - Método para Obter dados de Produto
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getPRD WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensPRD WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp 	:= ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		
		cQuery := " SELECT 	SB1.B1_COD, SB1.B1_DESC, SB1.B1_UM "
		cQuery += " FROM "+RETSQLNAME("SB1")+" SB1 "
		cQuery += " WHERE 		SB1.D_E_L_E_T_ = '' "
		cQuery += " 		AND SB1.B1_DESC LIKE '%"+_cPesquisa+"%' "
		cQuery += "			AND SB1.B1_MSBLQL <> '1' "
		
		If !Empty(::Produto)
			cQuery += " and SB1.B1_COD = '"+::Produto+"' "
		EndIf
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensPRD:ItensPRD, WSClassNew("aListItensPRD"))
	
				::ListItensPRD:ItensPRD[i]:CodigoPRD := (cArqTMP)->B1_COD
				::ListItensPRD:ItensPRD[i]:DescPRD   := (cArqTMP)->B1_DESC
				::ListItensPRD:ItensPRD[i]:GrupoPRD  := (cArqTMP)->B1_UM
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
			
			i := 1
		
			aAdd(::ListItensPRD:ItensPRD, WSClassNew("aListItensPRD"))
	
			::ListItensPRD:ItensPRD[i]:CodigoPRD := ""
			::ListItensPRD:ItensPRD[i]:DescPRD   := ""
			::ListItensPRD:ItensPRD[i]:GrupoPRD  := ""
		
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)


//-------------------------------------------------------------------
/*/ {Protheus.doc} getCRG - Método para Obter dados de Cargo
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getCRG WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensCRG WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp := ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		cQuery := " SELECT RJ_FUNCAO,RJ_DESC FROM "+RETSQLNAME("SRJ")+" "
		cQuery += " WHERE D_E_L_E_T_ = '' AND RJ_DESC LIKE '%"+_cPesquisa+"%' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensCRG:ItensCRG, WSClassNew("aListItensCRG"))
	
				::ListItensCRG:ItensCRG[i]:CodigoCRG := (cArqTMP)->RJ_FUNCAO
				::ListItensCRG:ItensCRG[i]:DescCRG   := (cArqTMP)->RJ_DESC
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
		
			i := 1
			aAdd(::ListItensCRG:ItensCRG, WSClassNew("aListItensCRG"))
	
			::ListItensCRG:ItensCRG[i]:CodigoCRG := ""
			::ListItensCRG:ItensCRG[i]:DescCRG   := ""
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getCLI - Método para Obter dados de Cargo
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getCLI WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensCLI WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.
	//Local cMsgEmp := ""

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		cQuery := " SELECT A1_COD,A1_NOME FROM "+RETSQLNAME("SA1")+" "
		cQuery += " WHERE D_E_L_E_T_ = '' AND A1_NOME LIKE '%"+_cPesquisa+"%' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItensCLI:ItensCLI, WSClassNew("aListItensCLI"))
	
				::ListItensCLI:ItensCLI[i]:CodigoCLI := (cArqTMP)->A1_COD
				::ListItensCLI:ItensCLI[i]:DescCLI   := (cArqTMP)->A1_NOME
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
		
			i := 1
			aAdd(::ListItensCLI:ItensCLI, WSClassNew("aListItensCLI"))
	
			::ListItensCLI:ItensCLI[i]:CodigoCLI := ""
			::ListItensCLI:ItensCLI[i]:DescCLI   := ""
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)


//-------------------------------------------------------------------
/*/ {Protheus.doc} getPED - Método para Verificar a existencia de Pedidos de Compra
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getPED WSRECEIVE KEY,Empresa,Filial,cProjeto,cTarefa,_cMsg WSSEND ExcluiPC WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.	
	//Local cMsgEmp := ""
	
	::ExcluiPC := .F.

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		cQuery := " SELECT COUNT(*) PED FROM  "+RETSQLNAME("SC7")+" "
		cQuery += " WHERE C7_CODPSP = '"+::cProjeto+"' AND C7_TAREFA = '"+::cTarefa+"' AND D_E_L_E_T_ = '' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			
			_cMsg := ''
			While !(cArqTMP)->(Eof())
				If (cArqTMP)->PED > 0
					::ExcluiPC := .T.
				EndIf
				(cArqTMP)->(dbskip())
			EndDo
		Else
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)


//-------------------------------------------------------------------------------
/*/ {Protheus.doc} getRevisoes - Método para Obter Revisoes de um Projeto
@author	Fernando
@since		09/12/2014
/*/
//-------------------------------------------------------------------------------
WSMETHOD getRevisoes WSRECEIVE KEY, Empresa, cProjeto, _cMsg WSSEND ListItensRev WSSERVICE NewRetInfo

	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf

	If _lRet

		cQuery := " SELECT AFE.AFE_REVISA FROM "+RETSQLNAME("AFE")+" AFE WHERE AFE.AFE_PROJET ='"+::cProjeto+"' AND AFE.D_E_L_E_T_ = '' ORDER BY AFE.AFE_REVISA DESC "
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			While !(cArqTMP)->(Eof())
				aAdd(::ListItensRev:ItensRev, WSClassNew("aListItensRev"))
				::ListItensRev:ItensRev[i]:Revisao:= (cArqTMP)->AFE_REVISA
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
			i := 1
			aAdd(::ListItensRev:ItensRev, WSClassNew("aListItensRev"))
			::ListItensRev:ItensRev[i]:Revisao:= ""
			::_cMsg := "Estrutura não Localizada para o Projeto ["+::cProjeto+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("getRevisoes", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getListaPSP - Método para Obter dados Filtrados de Projeto
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getListaPSP WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItens2PSP WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.
	
	//conout("GetListaPSP")

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	If _lRet
		If Empty(::_cPesquisa)
			::_cMsg:= "Parametro de pesquisa obrigatorio!"
			_lRet:= .f.
		EndIf
	EndIf

	If _lRet
		cQuery := " SELECT AF8_PROJET,AF8_DESCRI FROM " + RETSQLNAME("AF8") + " "
		cQuery += " WHERE (AF8_PROJET LIKE '" + _cPesquisa + "%' OR AF8_DESCRI LIKE UPPER('" + _cPesquisa + "%')) AND D_E_L_E_T_ = '' "

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())

			i := 1
			_cMsg := ''
			While !(cArqTMP)->(Eof())

				aAdd(::ListItens2PSP:Itens2PSP, WSClassNew("aListItensPSP"))
	
				::ListItens2PSP:Itens2PSP[i]:CodigoPSP:= (cArqTMP)->AF8_PROJET
				::ListItens2PSP:Itens2PSP[i]:DescPSP	 := (cArqTMP)->AF8_DESCRI
	
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		Else
			i := 1
				
			aAdd(::ListItens2PSP:Itens2PSP, WSClassNew("aListItensPSP"))
	
			::ListItens2PSP:Itens2PSP[i]:CodigoPSP	:= ""
			::ListItens2PSP:Itens2PSP[i]:DescPSP	:= ""
		
			::_cMsg := "Estrutura não Localizada para a Filial ["+::Filial+"]!"
			_lRet := .f.
		EndIf
	
	EndIf
		
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf
	
Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getListaREC - Método para Obter dados Filtrados de Projeto
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getListaREC WSRECEIVE KEY,Empresa,Filial,_cUnidade,_cPesquisa,_cMsg WSSEND ListItensRec WSSERVICE NewRetInfo
	Local _lRet		:=.T.
	Local _aDados		:={}
	Local _cCdGest	:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.
	

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf

	i := 1
	If _lRet
		cQuery := " SELECT AE8_RECURS,AE8_DESCRI,AE8_VALOR FROM "+RETSQLNAME("AE8")+" "
		cQuery += " WHERE D_E_L_E_T_ = '' "
		cQuery += "		AND AE8_FILIAL= '"+::_cUnidade+"' "
		cQuery += "		AND AE8_DESCRI LIKE '%"+_cPesquisa+"%'  "
		cQuery += " 	AND  AE8_ATIVO <> '2' " // 2=Inativo.

		MEMOWRITE("NEWRETINFO", cQuery)
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		_lRet := (cArqTMP)->(!Eof())
		If !_lRet
			::_cMsg := "Não Existem registros para os parametros informados!"

			aAdd(::ListItensRec:ItensRec, WSClassNew("aListItensRec"))
			::ListItensRec:ItensRec[i]:CodigoRec := ''
			::ListItensRec:ItensRec[i]:DescRec	  := ''
			::ListItensRec:ItensRec[i]:Valor  	  := 0			
			
		Else
			_cMsg := ''
			While (cArqTMP)->(!Eof())

				aAdd(::ListItensRec:ItensRec, WSClassNew("aListItensRec"))
				::ListItensRec:ItensRec[i]:CodigoRec := (cArqTMP)->AE8_RECURS
				::ListItensRec:ItensRec[i]:DescRec	  := (cArqTMP)->AE8_DESCRI
				::ListItensRec:ItensRec[i]:Valor  	  := (cArqTMP)->AE8_VALOR
		
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		EndIf
		
		If Select(cArqTMP) <> 0
			(cArqTMP)->(DbCloseArea())
		EndIf

	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo", ::_cMsg)
	EndIf

Return(_lRet)

//-------------------------------------------------------------------
/*/ {Protheus.doc} getArea - Método para Obter dados Filtrados de Projeto
@author	David
@since		17/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getArea WSRECEIVE KEY,Empresa,Filial,_cPesquisa,_cMsg WSSEND ListItensEq WSSERVICE NewRetInfo
	Local _lRet			:=.T.
	Local _aDados		:={}
	Local _cCdGest		:=""
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i				:= 0
	Local j				:= 0
	Local cFlag 		:=""
	Local cQuery 		:= ""
	Local cArqTMP 		:= GetNextAlias()
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::_cPesquisa))  // Posiciona na Empresa.
	
	If Alltrim(::Empresa) == "07"
		::_cPesquisa := ""
	EndIf

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [NewRetInfo]"
			_lRet:= .f.
		EndIf
	EndIf
	
	i := 1
	If _lRet
		cQuery := " SELECT AED_EQUIP,AED_DESCRI FROM "+RETSQLNAME("AED")+" "
		cQuery += " WHERE D_E_L_E_T_ = '' AND AED_FILIAL = '"+Alltrim(::_cPesquisa)+"' "
		
		MemoWrite("Prgw005.sql", cQuery)

		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		
		 
		If (cArqTMP)->(Eof())
		
			_lRet := .f.
			
			::_cMsg := "Não Existem registros para os parametros informados!"
			
			aAdd(::ListItensEq:ItensArea, WSClassNew("aListItensArea"))
			::ListItensEq:ItensArea[i]:CodEquipe := ''
			::ListItensEq:ItensArea[i]:DescArea  := ''

		Else
			::_cMsg := ''
		
			While (cArqTMP)->(!Eof())

				_cMsg := ''
		
				aAdd(::ListItensEq:ItensArea, WSClassNew("aListItensArea"))
		
				::ListItensEq:ItensArea[i]:CodEquipe := (cArqTMP)->AED_EQUIP
				::ListItensEq:ItensArea[i]:DescArea  := (cArqTMP)->AED_DESCRI
		
				(cArqTMP)->(DbSkip())
				i++
			EndDo
		
		EndIf		
		
		If Select(cArqTMP) <> 0
			(cArqTMP)->(DbCloseArea())
		EndIf

	EndIf

	If !_lRet
		SetSoapFault("NewRetInfo:getArea()", ::_cMsg)
	EndIf


Return(_lRet)