#Include "APWEBSRV.CH"
#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"

#DEFINE enter chr(13)+chr(10)

//-------------------------------------------------------------------
/*{Protheus.doc} 
PRGW004 - WebServices para Crud de Revisões de Projetos. 
Projeto
@aParam
@author	David Ferreira Quadras
@since		12/11/2014
/*/
//--------------------------------------------------------------------        
User Function PRGW004()
	alert("PrgW004")
Return(Nil)

//-----------------------
// Estruturas de Dados
//-----------------------
WSSTRUCT aItens
	WSDATA Itens  As Array Of aListItens
ENDWSSTRUCT

WSSTRUCT aListItens
	
	/*AFC*/
	WSDATA CodProj	 	As String OPTIONAL 
	WSDATA DtVenda	 	As String OPTIONAL
	WSDATA _Edt		 	As String OPTIONAL
	WSDATA _EdtPai	 	As String OPTIONAL
	WSDATA DescEDT	 	As String OPTIONAL
	WSDATA cRevisa	 	As String OPTIONAL
	WSDATA Nivel	 	As String OPTIONAL

	WSDATA fOrcProj  	As Float  OPTIONAL
	WSDATA fVenProj	 	As Float  OPTIONAL
	WSDATA fOrcReem	 	As Float  OPTIONAL
	WSDATA fVenReem	 	As Float  OPTIONAL
	WSDATA fMeta	 	As Float  OPTIONAL

	WSDATA CentroCusto 	As String OPTIONAL
	WSDATA Produto	 	As String OPTIONAL
	WSDATA	Cargo		As String OPTIONAL
	WSDATA	Execucao	As String OPTIONAL
	WSDATA	Quantidade	As Float  OPTIONAL
	WSDATA	QtdDiarias	As Float  OPTIONAL
	WSDATA	QtdPC  	 	As Float  OPTIONAL
	WSDATA	valorPC	 	As Float  OPTIONAL
	
	WSDATA fMetaUnit   	As Float  OPTIONAL
	WSDATA fCustoUnit	As Float  OPTIONAL
	WSDATA fCustTot	 	As Float  OPTIONAL
	WSDATA fTaxa	 	As Float  OPTIONAL
	
	/*AF9*/
	WSDATA _Tarefa		As String OPTIONAL
	WSDATA DescTarefa	As String OPTIONAL
	WSDATA Familia		As String OPTIONAL
	WSDATA TipoFat		As String OPTIONAL
	WSDATA UnidadeMed	As String OPTIONAL
	WSDATA DescProduto 	As String OPTIONAL
	
ENDWSSTRUCT


//Revisoes do Projeto 
WSSTRUCT aitensRevisao
	WSDATA ItensRev  	As Array Of aListitensRevisao
ENDWSSTRUCT

WSSTRUCT aListitensRevisao
	WSDATA Revisao	As String OPTIONAL
ENDWSSTRUCT

//-------------------------------------------------------------------
/*/{Protheus.doc} WebService newRevisaoProjeto para criar nova revisao 
@author	Fernando
@since		12/11/2014
/*/
//--------------------------------------------------------------------
WSSERVICE newReviewProj DESCRIPTION "WebService para criar revisão do Projeto"
	
	//-----------------------
	// Estruturas de Dados
	//-----------------------	
	WSDATA KEY			As String // Chave para liberação de Acesso aos métodos de WebService.
	WSDATA Empresa		As String // char(2) Empresa que será criada o projeto - 02-EBCP;06-GNOVA(Não contemplado ainda); 07-EMCI.
	WSDATA Filial		As String // char(2) Filial/Unidade de negócios utilizada 05-Experience; 08-TV1 PontoCom; 10-TV1/RP; 16-Conteudo e Vídeo.
	WSDATA cMsg			As String  OPTIONAL
	WSDATA Projeto		As String //char(10)
	WSDATA Revisao		As String //char(04)
	WSDATA GeraRevisao 	As String // S=Sim; N=Não
	WSDATA _cMsg		As String //char(999)
	WSDATA UserName		As String Optional

	WSDATA ListItens	As aItens //As Array Of ListItens
	WSDATA ListItensRev	As aitensRevisao OPTIONAL
	
	WSMETHOD getReviewProj 	DESCRIPTION "Método para obter as revisões do Projeto."
	WSMETHOD getStructProj	DESCRIPTION "Método: Obter Estrutura do Projeto."
	WSMETHOD setProj		DESCRIPTION "Método: Gerar nova Revisão do Projeto."

ENDWSSERVICE

//-------------------------------------------------------------------
/*/ {Protheus.doc} getStructProj - Método para Obter dados do Projeto
de acordo com a Revisão informada. 
@author	Fernando
@since		12/11/2014
/*/
//-------------------------------------------------------------------
WSMETHOD getStructProj WSRECEIVE KEY,Empresa,Filial,Projeto,Revisao WSSEND ListItens WSSERVICE newReviewProj

	Local _lRet			:= .T.
	Local _aDados		:= {}
	Local _cCdGest		:= ""
	Local cMsgEmp		:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.
	Local cNewRevisa	:= ""
	Local nItens 	   	:= 0
	Local i				:= 0
	Local j				:= 0
	Local cFlag 		:= ""
	Local cQuery 		:= ""
	Local cArqTMP 		:= GetNextAlias()
	Local aValPed 		:= {}

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	If Alltrim(::Empresa) == "07"
		::Filial := ""
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [getStructProj]"
			_lRet:= .f.
		EndIf
	EndIf*/

	conout(Replicate('-',60))
	conout('	Parâmetro de Estrutura: Revisão =  ['+::Revisao+']')

	If _lRet
		If Empty(::Revisao)
			DbSelectArea("AF8")
			AF8->(DbSetOrder(1))
			_lRet := AF8->(DbSeek( AvKey(::Filial,"AF8_FILIAL")+ AvKey(::Projeto,"AF8_PROJET") ))
				::Revisao := AF8->AF8_REVISA
			If !_lRet
				::_cMsg := "Projeto não Localizado!"
			EndIf
			conout('			Revisão [AF8] -->: '+AF8->AF8_REVISA)
			conout('	Depois de alimentado com AF8 --> Revisão =  ['+::Revisao+']')
			conout(Replicate('-',60))
			conout(alltochar(_lRet))			
		EndIf
	EndIf

	If _lRet
		
		cQuery :=" SELECT 											"+enter
		cQuery +="		AF8_X_TIPO 					AS UN, 		"+enter
		cQuery +="		AF8_PROJET 					AS PROJETO, 	"+enter
		cQuery +="		AF8.AF8_CLIENT, 								"+enter
		cQuery +="		AF8.AF8_REVISA, 								"+enter
		cQuery +="		AFC.AFC_EDT					AS EDT,		"+enter
		cQuery +="		AF8.AF8_DESCRI, 								"+enter
		cQuery +="		AFC.AFC_NIVEL					AS NIVELEDT,	"+enter
		cQuery +="		AFC.AFC_DESCRI 				AS DESCEDT, 	"+enter
		cQuery +="		AFC_EDTPAI,									"+enter
		cQuery +="		coalesce(AFC_CUSTPV,0) 		AS AFC_CUSTPV,"+enter
		cQuery +="		coalesce(AFC_CUSTRE,0) 		AS AFC_CUSTRE,"+enter
		cQuery +="		coalesce(AFC_TVPVBV,0)  		AS AFC_TVPVBV,"+enter
		cQuery +="		coalesce(AFC_TVRE,0) 		AS AFC_TVRE,  "+enter
		cQuery +="		coalesce(AFC.AFC_METTOT,0) 	AS METATOTEDT,"+enter
		cQuery +=" 	coalesce(AFC.AFC_XAREA,'')  AS CCUSTO		"+enter
		cQuery +=" FROM "+RetSqlName("AF8")+" (NOLOCK) AF8 		"+enter
		
		cQuery +=" INNER JOIN  "+RetSqlName("AFC")+ " (NOLOCK) AFC "+enter
		cQuery +="		ON 	 AF8.AF8_PROJET	= AFC.AFC_PROJET 		"+enter
		cQuery +="		AND AFC.AFC_REVISA 	= '"+::Revisao+"' 	"+enter
		cQuery +="		AND AFC.D_E_L_E_T_ 	= '' 					"+enter
		cQuery +="		AND SUBSTRING(AFC.AFC_EDTPAI,1,1) = '3' 	"
		cQuery +=" WHERE "+enter
		cQuery +=" 		AF8.D_E_L_E_T_ = '' "
		cQuery +=" 	AND AF8.AF8_PROJET = '"+::Projeto+"'"+enter
		cQuery += " ORDER BY "
		cQuery += "	AF8.AF8_PROJET, 	"
		cQuery += "	AFC.R_E_C_N_O_, 	"
		cQuery += "	AFC.AFC_NIVEL 	"		

		//AutoGrLog(cQuery)
		//conout(cQuery)
				
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		If !(cArqTMP)->(Eof())
			
			i := 1

			While !(cArqTMP)->(Eof())

				aAdd(::ListItens:Itens, WSClassNew("aListItens"))

				//AFC			
				::Filial 							:= Substr((cArqTMP)->PROJETO,1,2)
				::Projeto							:= alltrim( (cArqTMP)->PROJETO )
				::ListItens:Itens[i]:CodProj 	:= alltrim((cArqTMP)->PROJETO)
				::ListItens:Itens[i]:cRevisa	:= alltrim(::Revisao)
				::ListItens:Itens[i]:DtVenda 	:= alltrim( DToS(Posicione("AF8",1, xFilial("AF8")+(cArqTMP)->PROJETO, "AF8_DTVEND")) )
				::ListItens:Itens[i]:_Edt 		:= alltrim((cArqTMP)->EDT)
				::ListItens:Itens[i]:_EdtPai	:= alltrim((cArqTMP)->AFC_EDTPAI)
				::ListItens:Itens[i]:Nivel		:= alltrim((cArqTMP)->NIVELEDT)
				::ListItens:Itens[i]:DescEDT 	:= alltrim((cArqTMP)->DESCEDT) //(cArqTMP)->EDT //(cArqTMP)->DESCEDT

				::ListItens:Itens[i]:fOrcProj 	:= (cArqTMP)->AFC_CUSTPV
				::ListItens:Itens[i]:fOrcReem 	:= (cArqTMP)->AFC_CUSTRE
				
				::ListItens:Itens[i]:fVenProj 	:= (cArqTMP)->AFC_TVPVBV
				::ListItens:Itens[i]:fVenReem	:= (cArqTMP)->AFC_TVRE
				::ListItens:Itens[i]:fMeta		:= (cArqTMP)->METATOTEDT
				
				::ListItens:Itens[i]:CentroCusto:= alltrim((cArqTMP)->CCUSTO) //(cArqTMP)->AFC_CCUSTO
				::ListItens:Itens[i]:Execucao	:= ""
				::ListItens:Itens[i]:Cargo		:= ""
				::ListItens:Itens[i]:QtdDiarias	:= 0
				::ListItens:Itens[i]:Quantidade	:= 0
				::ListItens:Itens[i]:fCustoUnit	:= 0

				//Monta AF9 - Tarefas.
				
				cQuery := " SELECT 									"+enter
				cQuery += "		AF9.AF9_TAREFA  AS TAREFA,  	"+enter
				cQuery += "		AF9.AF9_NIVEL	  AS NIVELTAR, 	"+enter
				cQuery += " 		ISNULL(CAST(CAST( AF9.AF9_XFAMIL AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS FAMILIA,  "+enter
				cQuery += " 		ISNULL(CAST(CAST( AF9.AF9_XDESC AS VARBINARY(8000)) AS VARCHAR(8000)) ,'') AS DESCRITAR, "+enter
				cQuery += "		AF9.AF9_QUANT	 							AS QUANTTAR, 	"+enter
				cQuery += "		coalesce(AF9.AF9_QUANT,1) * (CASE WHEN AF9_X_RERI = 'RE' THEN coalesce(AF9.AF9_CUSTRE,0) WHEN AF9_X_RERI = 'PR' THEN coalesce(AF9.AF9_CUSTPV,0)	END ) CUSTOTTAR, "+enter
				cQuery += "		coalesce(AF9_CUSTPV,0) 					AS AF9_CUSTPV,"+enter
				cQuery += "		coalesce(AF9_CUSTRE,0) 					AS AF9_CUSTRE,"+enter
				cQuery += "		coalesce(AF9_TVPVBV,0) 					AS AF9_TVPVBV,"+enter
				cQuery += "		coalesce(AF9_TVRE,0) 					AS AF9_TVRE,  "+enter
				cQuery += "		coalesce(AF9.AF9_METTOT,0) 				AS METATOTTAR,"+enter
				cQuery += "		AF9.AF9_X_RERI 							AS TIPOFAT, 	"+enter				
				cQuery += "		AFA.AFA_XEXEC  							AS EXECUCAO,  "+enter
				cQuery += "		AFA.AFA_XCARGO  							AS CARGO,	  	"+enter		
				cQuery += "		AFA.AFA_PRODUT  							AS PRODUTO,   "+enter
				cQuery += "		AFA.AFA_RECURS  							AS RECURSO,	"+enter
				cQuery += "		AE8.AE8_DESCRI 							AS DESCRECURS,"+enter
				cQuery += "		SB1.B1_DESC,										 		"+enter				
				cQuery += "		AFA.AFA_UM 								AS UM,  	  	"+enter
				
				cQuery += "		coalesce(AFA.AFA_X_DIAR,0) 				AS QTDIARIAS, "+enter
				cQuery += "		coalesce(AFA.AFA_QUANT,0)				AS QUANT, 	  	"+enter
				cQuery += "		coalesce(AFA.AFA_CUSTD,0)				AS CUSTOUNIT, "+enter
				cQuery += "		coalesce(AFA.AFA_CUSTOT, 0) 			AS AFA_CUSTOT,"+enter
				cQuery += "		coalesce(AF9.AF9_METTOT,0)				AS METAUNIT,  "+enter
				cQuery += "		coalesce(AF9.AF9_X_TAXA,0)				AS TAXA  		"+enter		
				
				
				// Criar Função para Quantidade e Valor do PC.
				cQuery += " FROM "+RetSqlName("AF9")+" (NOLOCK) AF9 				  		"+enter

				cQuery += "LEFT JOIN " +RetSqlName("AFA")+" (NOLOCK) AFA 	"+enter
				cQuery += "	ON 	 AF9.AF9_PROJET	= AFA.AFA_PROJET			"+enter
				cQuery += "	AND AFA.AFA_REVISA 	= '"+alltrim(::Revisao)+"'"+enter
				cQuery += "	AND AF9.AF9_TAREFA	= AFA.AFA_TAREFA 			"+enter
				cQuery += "	AND AFA.D_E_L_E_T_	= '' 						"+enter

				cQuery += "LEFT JOIN " +RetSqlName("SB1")+" (NOLOCK) SB1	"+enter
				cQuery += "	ON 	 AFA.AFA_PRODUT	= SB1.B1_COD				"+enter
				cQuery += "	AND SB1.D_E_L_E_T_	= '' 						"+enter
		
				cQuery += "LEFT JOIN " +RetSqlName("AE8")+" (NOLOCK) AE8	"+enter
				cQuery += "	ON  AFA.AFA_FILIAL	= AE8.AE8_FILIAL			"+enter
				cQuery += "	AND AFA.AFA_RECURS	= AE8.AE8_RECURS			"+enter
				cQuery += "	AND AE8.D_E_L_E_T_	= '' 						"+enter
				cQuery += "	AND AFA.D_E_L_E_T_	= '' 						"+enter				
		
				cQuery += " WHERE "
				cQuery += "			AF9.AF9_PROJET 	= '"+Alltrim(::Projeto)+"'"+enter
				cQuery += "		AND AF9.AF9_REVISA 	= '"+alltrim(::Revisao)+"'"				
				cQuery += "		AND AF9.AF9_EDTPAI 	= '"+AllTrim((cArqTMP)->EDT)+"'"				
				cQuery += "		AND AF9.D_E_L_E_T_ 	= '' "  
				
				cQuery += " 	ORDER BY "
				cQuery += "			AF9.R_E_C_N_O_, AF9.AF9_NIVEL "

				cArqAF9 := GetNextAlias()
				
				dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqAF9,.F.,.T.)
				DbSelectArea(cArqAF9)
				
				While !(cArqAF9)->(Eof())

					aAdd(::ListItens:Itens, WSClassNew("aListItens"))
					
					i++	
					
					//AF9 - Tarefas
				
					::Filial 							:= Substr((cArqTMP)->PROJETO,1,2)
					::Projeto							:= alltrim((cArqTMP)->PROJETO)
					::ListItens:Itens[i]:CodProj 	:= alltrim((cArqTMP)->PROJETO)
					::ListItens:Itens[i]:cRevisa	:= alltrim(::Revisao)
					::ListItens:Itens[i]:_Edt 		:= ""
					::ListItens:Itens[i]:DtVenda 	:= alltrim(DToS(Posicione("AF8",1, xFilial("AF8")+(cArqTMP)->PROJETO, "AF8_DTVEND")))
					::ListItens:Itens[i]:_Tarefa 	:= alltrim((cArqAF9)->TAREFA)
					::ListItens:Itens[i]:_EdtPai	:= alltrim((cArqTMP)->EDT)
					::ListItens:Itens[i]:Nivel		:= alltrim((cArqAF9)->NIVELTAR)
					::ListItens:Itens[i]:CentroCusto:= ""
					::ListItens:Itens[i]:DescEDT 	 := ""
					::ListItens:Itens[i]:DescTarefa := AllTrim((cArqAF9)->DESCRITAR)
					::ListItens:Itens[i]:Familia 	:= AllTrim((cArqAF9)->FAMILIA)
					
					//Indica que tarefa possui Pedido de Compra.
					//::ListItens:Itens[i]:QtdPC 	:= (cArqTMP)->QTDPC
					//::ListItens:Itens[i]:ValorPC	:= (cArqTMP)->VALORPC
										
					//aValPed := getSaldoPCTar(alltrim((cArqTMP)->PROJETO), alltrim((cArqAF9)->TAREFA))
					aValPed := U_L001TotPC(AllTrim((cArqTMP)->PROJETO), AllTrim((cArqAF9)->TAREFA))
					::ListItens:Itens[i]:QtdPC 		:= 0
					::ListItens:Itens[i]:ValorPC	:= aValPed

					::ListItens:Itens[i]:fOrcProj 	:= (cArqAF9)->AF9_CUSTPV / (cArqAF9)->QTDIARIAS / (cArqAF9)->QUANT
					::ListItens:Itens[i]:fOrcReem 	:= (cArqAF9)->AF9_CUSTRE / (cArqAF9)->QTDIARIAS / (cArqAF9)->QUANT
					::ListItens:Itens[i]:fVenProj 	:= (cArqAF9)->AF9_TVPVBV
					::ListItens:Itens[i]:fVenReem	:= (cArqAF9)->AF9_TVRE
					::ListItens:Itens[i]:fMeta		:= (cArqAF9)->METATOTTAR

					::ListItens:ITens[i]:TipoFat	:= Iif( AllTrim( (cArqAF9)->EXECUCAO)=="S", "SP", (cArqAF9)->TIPOFAT)
					
					// AFA
					::ListItens:Itens[i]:Execucao	:= (cArqAF9)->EXECUCAO
					::ListItens:Itens[i]:Cargo		:= Iif( AllTrim((cArqAF9)->EXECUCAO)=="I", (cArqAF9)->CARGO, (cArqAF9)->PRODUTO)
					::ListItens:Itens[i]:Produto	:= Iif( AllTrim((cArqAF9)->EXECUCAO)=="I", (cArqAF9)->RECURSO, (cArqAF9)->PRODUTO) //
					::ListItens:Itens[i]:DescProduto:= Iif( AllTrim((cArqAF9)->EXECUCAO)=="I", (cArqAF9)->DESCRECURS, AllTrim((cArqAF9)->B1_DESC)) //
					::ListItens:Itens[i]:UnidadeMed	:= (cArqAF9)->UM
					::ListItens:Itens[i]:QtdDiarias	:= (cArqAF9)->QTDIARIAS
					::ListItens:Itens[i]:Quantidade	:= (cArqAF9)->QUANT
					::ListItens:Itens[i]:fCustoUnit	:= (cArqAF9)->CUSTOUNIT
					::ListItens:Itens[i]:fMetaUnit	:= (cArqAF9)->METAUNIT
					::ListItens:Itens[i]:fCustTot	:= (cArqAF9)->AFA_CUSTOT
					::ListItens:Itens[i]:fTaxa		:= (cArqAF9)->TAXA

					(cArqAF9)->(DbSkip())

				EndDo

				If Select(cArqAF9) <> 0
					(cArqAF9)->(DbCloseArea())
				EndIf				

				i++

				(cArqTMP)->(DbSkip())			
			
			EndDo			
		Else
			::_cMsg := "Estrutura não Localizada para o Projeto ["+::Projeto+"]!"
			_lRet 	 := .f.
		EndIf
		
		If Select(cArqTMP) <> 0
			(cArqTMP)->(DbCloseArea())
		EndIf						
			
	Else
		::_cMsg := "Estrutura não Localizada para o Projeto ["+::Projeto+"]!"
		_lRet 	 := .f.
	EndIf

	/*
	varInfo("estrutura", ::ListItens:Itens)
	*/
	If Select(cArqTMP) <> 0
		(cArqTMP)->(DbCloseArea())
	EndIf

	If !_lRet
		SetSoapFault("getStructProj", ::_cMsg)
	EndIf

Return(_lRet)

//---------------------------------------------------------------------
/*/ {Protheus.doc} setProj - Método para gerar nova revisão do Projeto 
@author	Fernando
@since		12/11/2014
/*/
//--------------------------------------------------------------------
WSMETHOD setProj WSRECEIVE KEY,Empresa,Filial,Projeto,GeraRevisao, Revisao, UserName, ListItens /*DataVenda,*/  WSSEND _cMsg WSSERVICE newReviewProj

	Local _lRet	 		:= .T.
	Local _aDados	 	:= {}
	Local _cCdGest 		:= ""
	Local cMsgEmp	 	:= u_TrocaEmp(Alltrim(::Empresa), Alltrim(::Filial))  // Posiciona na Empresa.
	Local cNewRevisa 	:= "0000"
	Local cRevAnterior	:= ""
	Local nItens 	:= 0
	Local i		 	:= 1
	Local j		 	:= 0
	Local cRet		:= ""
	Local cFlag 	:=""
	Local cQuery	:= ""
	Local cNovo 	:= ::GeraRevisao
	Local nItens	:= Len(::ListItens:Itens)

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf
	
	If Alltrim(::Empresa) == "07"
		::Filial := ""
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [setProj]"
			_lRet:= .f.
		EndIf
	EndIf*/
	
	If _lRet
	
		DbSelectArea("AF8")
		AF8->(DbSetOrder(1))
		If AF8->(DbSeek( AvKey(::Filial,"AF8_FILIAL")+ AvKey(::Projeto,"AF8_PROJET")))
			cNewRevisa   := AF8->AF8_REVISA
			cRevAnterior := AF8->AF8_REVISA

			If AllTrim(::GeraRevisao) == "S"
				cNewRevisa := StrZero(Val(cNewRevisa)+1,4)			
	
			ElseIf Alltrim(::GeraRevisao) == "N"
				
					_lRet := excDadosProj(AllTrim(::Filial), AvKey(::Projeto,"AF8_PROJET"), cNewRevisa, @cRet) //Deleta estrutura do Projeto.
					If _lRet 
						RecLock("AF8",.F.)

							AF8->AF8_REVISA := cNewRevisa

							If Empty(AF8->AF8_DTVEND) // Grava data de Venda
								AF8->AF8_DTVEND := date()
							EndIf
							
						AF8->(MsUnLock())
					Else
						AutoGrLog("[setProj] Erro ao gerar a rotina" + cRet)
						::_cMsg += cRet						
					EndIf				
			EndIf
		Else
			
			::_cMsg += "[setProj] Projeto não localizado!"+::Projeto
			AutoGrLog(::_cMsg)
		EndIf

	EndIf

	If _lRet

		If AllTrim(::GeraRevisao) == "S"
			
			setReview(AllTrim(::Filial), AvKey(::Projeto,"AF8_PROJET"), cRevAnterior, cNewRevisa)
			
			RecLock("AF8",.F.)
			
				AF8->AF8_REVISA := cNewRevisa
			
				If Empty(AF8->AF8_DTVEND) // Grava data de Venda
					AF8->AF8_DTVEND := date()
				EndIf
			
			AF8->(MsUnLock())
		EndIf	

		::_cMsg := "Projeto: "+::Projeto+CRLF+"Revisão: "+cNewRevisa+CRLF

		For i := 1 to nItens

			cFlag := ::ListItens:Itens[i]:Nivel
			Do Case
				
			Case cFlag == "003" .Or. cFlag == "004"
						
				If Empty(::ListItens:Itens[i]:_Edt) .Or. Empty(::ListItens:Itens[i]:_EdtPai)
					_lRet := .F.
					::_cMsg := "[setProj] Para salvar uma Edt(SubProjeto) é necessário informar Edt e EdtPai"+cNewRevisa+CRLF
					Exit
				EndIf
				RecLock("AFC", .T. )
				AFC->AFC_FILIAL  := ::Filial
				AFC->AFC_PROJET  := ::Projeto
				AFC->AFC_REVISA  := cNewRevisa
				AFC->AFC_DESCRI  := ::ListItens:Itens[i]:DescEDT
				AFC->AFC_EDT     := ::ListItens:Itens[i]:_Edt
				AFC->AFC_EDTPAI  := ::ListItens:Itens[i]:_EdtPai
				AFC->AFC_NIVEL   := ::ListItens:Itens[i]:Nivel
				AFC->AFC_XAREA	:= ::ListItens:Itens[i]:CentroCusto
				AFC->AFC_CALEND  := "001"
				AFC->AFC_FATURA  := "1"				
				AFC->AFC_TVPVI   := ::ListItens:Itens[i]:fVenProj
				AFC->AFC_TVPVBV  := ::ListItens:Itens[i]:fVenProj
				AFC->AFC_CUSTRE  := ::ListItens:Itens[i]:fOrcReem
				AFC->AFC_TVRE    := ::ListItens:Itens[i]:fVenReem
				AFC->AFC_TVBRBV  := ::ListItens:Itens[i]:fVenReem
				AFC->AFC_CUSTO   := ::ListItens:Itens[i]:fOrcProj + ::ListItens:Itens[i]:fOrcReem
				AFC->AFC_CUSTPV  := ::ListItens:Itens[i]:fVenProj + ::ListItens:Itens[i]:fVenReem
				If ::ListItens:Itens[i]:fVenProj > 0 .AND. ::ListItens:Itens[i]:fOrcProj > 0
					AFC->AFC_TVPVC := ::ListItens:Itens[i]:fVenProj / ::ListItens:Itens[i]:fOrcProj
				EndIf
				If ::ListItens:Itens[i]:fVenReem > 0 .AND. ::ListItens:Itens[i]:fOrcReem > 0
					AFC->AFC_TVRECO  := ::ListItens:Itens[i]:fVenReem / ::ListItens:Itens[i]:fOrcReem
				EndIf
				AFC->AFC_TVTEV	:= ::ListItens:Itens[i]:fVenProj + ::ListItens:Itens[i]:fVenReem
				AFC->AFC_X_META  := ::ListItens:Itens[i]:fMeta
				AFC->AFC_METUNI  := ::ListItens:Itens[i]:fMeta
				AFC->AFC_METTOT  := ::ListItens:Itens[i]:fMeta
					
				AFC->(MsUnlock())

			Case  cFlag == "005" .Or. val(cFlag) > 5
	
				If Empty(::Projeto)
					_lRet := .f.
					::_cMsg := "[setProj] Para salvar uma tarefa é necessário informar o Projeto!"+cNewRevisa+CRLF
					Exit
				EndIf
	
				If Empty(::ListItens:Itens[i]:_Tarefa)
					_lRet := .f.
					::_cMsg := "[setProj] Para salvar uma tarefa é necessário informar Edt e EdtPai!"+cNewRevisa+CRLF
					Exit
				EndIf
	
				If Empty(::ListItens:Itens[i]:_EdtPai)
					_lRet := .f.
					::_cMsg := "[setProj] Para salvar uma tarefa é necessário informar EdtPai(SubProjeto)!"+cNewRevisa+CRLF
					Exit
				EndIf
			
				DbSelectArea("AF9")
				RecLock("AF9", .T.)
					
					AF9->AF9_FILIAL  	:= ::Filial
					AF9->AF9_PROJET  	:= ::Projeto
					AF9->AF9_REVISA  	:= cNewRevisa
					AF9->AF9_TAREFA	:= ::ListItens:Itens[i]:_Tarefa
					AF9->AF9_DESCRI  	:= SUBSTR(::ListItens:Itens[i]:DescTarefa,1,90)
					AF9->AF9_XDESC  	:= ::ListItens:Itens[i]:DescTarefa
					AF9->AF9_XFAMIL	:= ::ListItens:Itens[i]:Familia
					AF9->AF9_X_TAXA   := ::ListItens:Itens[i]:fTaxa				 
					AF9->AF9_EDTPAI  	:= ::ListItens:Itens[i]:_EdtPai
					AF9->AF9_NIVEL   	:= ::ListItens:Itens[i]:Nivel
										
					AF9->AF9_START		:= dDataBase
					AF9->AF9_FINISH		:= dDataBase
								
					AF9->AF9_CUSTPV  	:= ::ListItens:Itens[i]:Quantidade * ::ListItens:Itens[i]:fOrcProj * ::ListItens:Itens[i]:QtdDiarias
					AF9->AF9_TVPVI   	:= ::ListItens:Itens[i]:fVenProj
					AF9->AF9_TVPVBV  	:= ::ListItens:Itens[i]:fVenProj
					AF9->AF9_CUSTRE  	:= ::ListItens:Itens[i]:fOrcReem * ::ListItens:Itens[i]:QtdDiarias * ::ListItens:Itens[i]:Quantidade
					AF9->AF9_TVRE    	:= ::ListItens:Itens[i]:fVenReem
					AF9->AF9_TVBRBV  	:= ::ListItens:Itens[i]:fVenReem
					AF9->AF9_CUSTO 	:= ::ListItens:Itens[i]:Quantidade * ::ListItens:Itens[i]:fCustoUnit * ::ListItens:Itens[i]:QtdDiarias
					AF9->AF9_CALEND  	:= "001"
					AF9->AF9_TVTEV	:= ::ListItens:Itens[i]:fVenProj + ::ListItens:Itens[i]:fVenReem
	
					If ::ListItens:Itens[i]:fVenProj > 0 .AND. ::ListItens:Itens[i]:fOrcProj > 0
						AF9->AF9_TVPVC   := ::ListItens:Itens[i]:fVenProj / ::ListItens:Itens[i]:fOrcProj
					EndIf
										
					If ::ListItens:Itens[i]:fVenReem > 0 .AND. ::ListItens:Itens[i]:fOrcReem > 0
						AF9->AF9_TVRECO:= ::ListItens:Itens[i]:fVenReem / ::ListItens:Itens[i]:fOrcReem
					EndIf
					AF9->AF9_X_META  	:= ::ListItens:Itens[i]:fMeta
					AF9->AF9_METUNI  	:= ::ListItens:Itens[i]:fMeta
					AF9->AF9_METTOT  	:= ::ListItens:Itens[i]:fMeta
					AF9->AF9_X_RERI := ::ListItens:Itens[i]:TipoFat
							
				AF9->(MsUnlock())
					
				dbSelectArea("AFA")
				RecLock("AFA",.T.)

					AFA->AFA_FILIAL	:= ::Filial
					AFA->AFA_PROJET	:= ::Projeto
					AFA->AFA_REVISA	:= cNewRevisa
					AFA->AFA_TAREFA	:= ::ListItens:Itens[i]:_Tarefa
					AFA->AFA_ITEM	:= StrZero(i,2)
					AFA->AFA_FIX   	:= "2"
					If AllTrim(::ListItens:Itens[i]:Execucao) == "I"
						AFA->AFA_RECURS := ::ListItens:Itens[i]:Produto
						AFA->AFA_PRODUT := '0000001255'
					Else
						AFA->AFA_PRODUT	:= ::ListItens:Itens[i]:Produto
					EndIf
					AFA->AFA_QUANT 	:= ::ListItens:Itens[i]:Quantidade
					AFA->AFA_MOEDA 	:= 1
					AFA->AFA_PLNPOR	:= "1"
					AFA->AFA_START 	:= dDataBase
					AFA->AFA_FINISH	:= dDataBase
					AFA->AFA_ACUMUL	:= "4"
					AFA->AFA_CUSTD 	:= ::ListItens:Itens[i]:fCustoUnit //::ListItens:Itens[i]:fOrcProj + ::ListItens:Itens[i]:fOrcReem
					AFA->AFA_CUSTOT	:= ::ListItens:Itens[i]:Quantidade * ::ListItens:Itens[i]:fCustoUnit * ::ListItens:Itens[i]:QtdDiarias  //(::ListItens:Itens[i]:fOrcProj + ::ListItens:Itens[i]:fOrcReem)
					AFA->AFA_METUNI 	:= ::ListItens:Itens[i]:fMeta / ::ListItens:Itens[i]:Quantidade
					AFA->AFA_METQTD	:= ::ListItens:Itens[i]:Quantidade
					AFA->AFA_METTOT	:= ::ListItens:Itens[i]:fMeta
					AFA->AFA_DATPRF	:= dDatabase
					AFA->AFA_XEXEC  	:= ::ListItens:Itens[i]:Execucao
					AFA->AFA_XCARGO 	:= ::ListItens:Itens[i]:Cargo
					AFA->AFA_X_DIAR 	:= ::ListItens:Itens[i]:QtdDiarias
					AFA->AFA_QUANT  	:= ::ListItens:Itens[i]:Quantidade
					AFA->AFA_UM 		:= ::ListItens:Itens[i]:UnidadeMed
				AFA->(MsUnLock())
			EndCase
		Next i

		If _lRet .And. AllTrim(::GeraRevisao) == "S"

			// Cria historico para nova revisao.
			DbSelectArea("AFE")
			AFE->(DbSetOrder(1))
			RecLock("AFE",.T.)
				AFE->AFE_FILIAL	:= ::Filial
				AFE->AFE_PROJET	:= ::Projeto
				AFE->AFE_DATAI	:= MsDate()
				AFE->AFE_HORAI	:= Time()
				AFE->AFE_USERI	:= u_g01InfoUser(::UserName) //'000000'
				AFE->AFE_REVISA	:= cNewRevisa
				AFE->AFE_USERI	:= u_g01InfoUser(::UserName) //'000000'
				AFE->AFE_TIPO   	:= "1"
				AFE->AFE_DATAF	:= MsDate()
				AFE->AFE_HORAF	:= Time()
				AFE->AFE_USERF	:= u_g01InfoUser(::UserName) //'000000'
				AFE->AFE_CODMEM   := "Revisão gerada via app Web"
				If AFE->(FieldPos("AFE_FASE")) > 0
					AFE->AFE_FASE := '01'
					If AFE->(FieldPos("AFE_FASEOR")) > 0
						AFE->AFE_FASEOR := '01'
					EndIf
				EndIf
			AFE->(MsUnLock())
			::_cMsg+= "*** Revisão Gerada com Sucesso! Empresa/Filial: ["+::Empresa+"/"+::Filial+"]"
		EndIf

		If _lRet	// Atualiza as Edt's PAI.
				
			cQuery := " UPDATE " + RetSqlName("AFC")
			cQuery += " SET  "
			cQuery += "  		AFC_CUSTPV = AF9.AF9_CUSTPV,"
			cQuery += "  		AFC_CUSTO  = AF9.AF9_CUSTO,	"			
			cQuery += "  		AFC_TVPVI  = AF9.AF9_TVPVI, "
			cQuery += "  		AFC_TVPVBV = AF9.AF9_TVPVBV,"
			cQuery += "  		AFC_CUSTRE = AF9.AF9_CUSTRE,"
			cQuery += "  		AFC_TVRE   = AF9.AF9_TVRE, 	"
			cQuery += "  		AFC_TVBRBV = AF9.AF9_TVBRBV,"
			cQuery += "  		AFC_METTOT = AF9.AF9_METTOT,"
			cQuery += "  		AFC_X_META = AF9.AF9_METTOT,"
			cQuery += "  		AFC_TVTEV  = AF9.AF9_TVTEV	"
		
			
			cQuery += "  		FROM " +RetSqlName("AFC")+" AFC "
			cQuery += "  		INNER JOIN "
			cQuery += "  		( "
			cQuery += "  		SELECT "
			cQuery += "  			AF9.AF9_PROJET, "
			cQuery += "  			AF9.AF9_REVISA, "
			cQuery += "  			AF9.AF9_EDTPAI, "
			cQuery += "  			SUM(AF9.AF9_CUSTPV) 	AS AF9_CUSTPV,	"
			cQuery += "  			SUM(AF9.AF9_CUSTO)	AS AF9_CUSTO, 	"			
			cQuery += "  			SUM(AF9.AF9_TVPVI)	AS AF9_TVPVI, 	"
			cQuery += "  			SUM(AF9.AF9_TVPVBV) 	AS AF9_TVPVBV,	"
			cQuery += "  			SUM(AF9.AF9_CUSTRE)	AS AF9_CUSTRE,	"
			cQuery += "  			SUM(AF9.AF9_TVRE)		AS AF9_TVRE, 		"
			cQuery += "  			SUM(AF9.AF9_TVBRBV) 	AS AF9_TVBRBV,	"
			cQuery += "  			SUM(AF9.AF9_METTOT) 	AS AF9_METTOT, 	"
			cQuery += "			sum(AF9.AF9_TVTEV)	AS AF9_TVTEV		"
			cQuery += "  		FROM "+RetSqlName("AF9")+" (NOLOCK) AF9 	"
			cQuery += " 		WHERE AF9.D_E_L_E_T_ = '' "
			cQuery += "  		GROUP BY AF9.AF9_PROJET, AF9.AF9_EDTPAI, AF9.AF9_REVISA "
			cQuery += "  		) AF9 "
			cQuery += "  		ON "
			cQuery += "  			AFC.AFC_PROJET 	= AF9.AF9_PROJET "
			cQuery += "  		AND AFC.AFC_EDT 	 	= AF9.AF9_EDTPAI "
			cQuery += "  		AND AFC.AFC_REVISA 	= AF9.AF9_REVISA "
			cQuery += " WHERE AFC.AFC_PROJET 		= '"+AllTrim(::Projeto)+"'"
			cQuery += "  	AND AFC.AFC_REVISA 		= '"+AllTrim(cNewRevisa)+"' "
			cQuery += "  	AND AFC.D_E_L_E_T_ 		= '' "
			_lRet := (TcSqlExec(cQuery) == 0 )
			If !_lRet
				::_cMsg := "Erro ao Atualizar o Totalizador (EDT) "+enter+ tcSqlError()
			EndIf
			
			If _lRet
				For i := 1 to 3
					cQuery := " UPDATE "+RetSqlName("AFC")
					cQuery += " SET  "
					cQuery += " 	AFC_CUSTPV	= AFC1.AFC_CUSTPV,	"
					cQuery += " 	AFC_CUSTO	= AFC1.AFC_CUSTO,		"					
					cQuery += " 	AFC_TVPVI	= AFC1.AFC_TVPVI,		"
					cQuery += " 	AFC_TVPVBV	= AFC1.AFC_TVPVBV,	"
					cQuery += " 	AFC_CUSTRE	= AFC1.AFC_CUSTRE,	"
					cQuery += " 	AFC_TVRE	= AFC1.AFC_TVRE,	"
					cQuery += " 	AFC_TVBRBV	= AFC1.AFC_TVBRBV,	"
					cQuery += " 	AFC_METTOT	= AFC1.AFC_METTOT,	"
					cQuery += " 	AFC_X_META	= AFC1.AFC_METTOT,	"
					
					cQuery += " 	AFC_TVTEV	= AFC1.AFC_TVTEV		"
					
					cQuery += " FROM "+RetSqlName("AFC")+" AFC	"
					cQuery += " INNER JOIN 			"
					cQuery += " ( 					"
					cQuery += " SELECT  				"
					cQuery += " 		A.AFC_PROJET,	"
					cQuery += " 		A.AFC_EDTPAI,	"
					cQuery += " 		A.AFC_REVISA,	"
					cQuery += " 		sum(A.AFC_CUSTO) 	AS AFC_CUSTO,		"					
					cQuery += " 		sum(A.AFC_CUSTPV)	AS AFC_CUSTPV,	"
					cQuery += " 		sum(A.AFC_TVPVI) 	AS AFC_TVPVI, 	"
					cQuery += " 		sum(A.AFC_TVPVBV)	AS AFC_TVPVBV, 	"
					cQuery += " 		sum(A.AFC_CUSTRE)	AS AFC_CUSTRE,	"
					cQuery += " 		sum(A.AFC_TVRE) 	AS AFC_TVRE,		"
					cQuery += " 		sum(A.AFC_TVBRBV)	AS AFC_TVBRBV,	"
					cQuery += " 		sum(A.AFC_METTOT)	AS AFC_METTOT,	"
					cQuery += "		sum(A.AFC_TVTEV)	AS AFC_TVTEV		"
					cQuery += " 	FROM "+RetSqlName("AFC")+" (NOLOCK) A	"
					cQuery += " 	WHERE   A.D_E_L_E_T_ = ''	"
					cQuery += " 	GROUP BY "
					cQuery += " 		A.AFC_PROJET,	"
					cQuery += " 		A.AFC_EDTPAI,	"
					cQuery += " 		A.AFC_REVISA	"
					cQuery += " )AFC1		"
					cQuery += " ON AFC.AFC_PROJET 	= AFC1.AFC_PROJET 	"
					cQuery += " AND AFC1.AFC_EDTPAI	= AFC.AFC_EDT	"
					cQuery += " AND AFC.AFC_REVISA 	= AFC1.AFC_REVISA	"
					cQuery += " WHERE AFC.D_E_L_E_T_= '' 				"
					cQuery += " AND AFC.AFC_PROJET 	= '"+AllTrim(::Projeto)+"'"
					cQuery += " AND AFC.AFC_REVISA 	= '"+AllTrim(cNewRevisa)+"'"
				
					If i == 1
						cQuery += " AND AFC.AFC_NIVEL =('003')"
					ElseIf i == 2
						cQuery += " AND AFC.AFC_NIVEL =('002')"
					Else
						cQuery += " AND AFC.AFC_NIVEL =('001')"
					EndIf
					
					_lRet := (TcSqlExec(cQuery) == 0 )
					If !_lRet
						::_cMsg := "Erro ao Atualizar o Totalizador (EDT)"+enter+ tcSqlError()
					EndIf
				Next i
			EndIf
		EndIf
	EndIf

	If !_lRet
		SetSoapFault("setProj", ::_cMsg)
	EndIf
Return(_lRet)

//-------------------------------------------------------------------
/*/setReview
Montagem da Estrutura baseado na revisão anterior do Projeto
@aParam
@author	Fernando
@since		17/11/2014
@uso       Precificação TV1.
/*/
//--------------------------------------------------------------------
Static Function setReview(_cFilial, _cProj, _cRev, cNewRevisa)
	Local _aArea	:= GetArea()
	Local _nUrv   := ""
	Local _cEDT	:= ""
	Local _cQuery := ""
	Local _lRet 	:= .t.

	DbSelectArea("AFC")
	AFC->(DbSetOrder(1))

	_cQuery := " SELECT AFC.* FROM " +RetSqlName("AFC")+" (NOLOCK) AFC 	"+enter
	_cQuery += " WHERE " + enter
	_cQuery += "  	AFC.AFC_FILIAL = '" + _cFilial 	+ "' AND "
	_cQuery += "  	AFC.D_E_L_E_T_ = '' AND "
	_cQuery += "  	AFC.AFC_PROJET = '" + _cProj 	+ "' AND "
	_cQuery += "  	AFC.AFC_REVISA = '" + _cRev 	+ "' AND "
	_cQuery += "  	AFC.AFC_NIVEL  < '003' "
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),"TAFC",.F.,.T.)
	
	DbSelectArea("TAFC")
	_lRet 	:= !TAFC->(Eof())
	While !TAFC->(Eof())

		RecLock("AFC",.T.)
		AFC->AFC_FILIAL  := TAFC->AFC_FILIAL
		AFC->AFC_PROJET  := TAFC->AFC_PROJET
		AFC->AFC_DESCRI  := TAFC->AFC_DESCRI
		AFC->AFC_REVISA  := cNewRevisa
		AFC->AFC_FATURA  := "1"
		AFC->AFC_EDT     := TAFC->AFC_EDT
		AFC->AFC_EDTPAI  := TAFC->AFC_EDTPAI
		AFC->AFC_NIVEL   := TAFC->AFC_NIVEL
		AFC->AFC_CUSTPV  := 0//TAFC->AFC_CUSTPV
		AFC->AFC_TVPVI   := 0//TAFC->AFC_TVPVI
		AFC->AFC_TVPVBV  := 0//TAFC->AFC_TVPVBV
		AFC->AFC_CUSTRE  := 0//TAFC->AFC_CUSTRE
		AFC->AFC_TVRE    := 0//TAFC->AFC_TVRE
		AFC->AFC_TVBRBV  := 0//TAFC->AFC_TVBRBV
		AFC->AFC_CUSTO   := 0//TAFC->AFC_CUSTO
		AFC->AFC_CUSTPV  := 0//TAFC->AFC_CUSTPV
		AFC->AFC_CALEND  := "001"
		AFC->AFC_TVPVC 	 := 0//TAFC->AFC_TVPVC
		AFC->AFC_TVRECO  := 0//TAFC->AFC_TVRECO
		AFC->AFC_X_META  := 0//TAFC->AFC_X_META
		AFC->AFC_METUNI  := 0//TAFC->AFC_METUNI
		AFC->AFC_METTOT  := 0//TAFC->AFC_METTOT

		AFC->(MsUnlock())

		TAFC->(DbSkip())
	EndDo
	TAFC->(DbCloseArea())

	If _lRet

		DbSelectArea("AF9")
		AF9->(DbSetOrder(1))
	
		_cQuery := " SELECT AF9.* "+enter
		_cQuery += " FROM "+RetSqlName("AF9")+" (NOLOCK) AF9 	 "+enter
		_cQuery += " WHERE "+enter
		_cQuery += " 		AF9.AF9_FILIAL ='"+alltrim(_cFilial)+"'"+enter
		_cQuery += " AND AF9.D_E_L_E_T_ = '' "+enter
		_cQuery += " AND AF9.AF9_PROJET = '"+alltrim(_cProj)+"' "+enter
		_cQuery += " AND AF9.AF9_REVISA ='"+alltrim(_cRev)+"' 	"+enter
		_cQuery += " AND SUBSTRING(AF9.AF9_EDTPAI,1,1) < '3' 	"+enter
		_cQuery += " ORDER BY AF9.AF9_EDTPAI, AF9.AF9_TAREFA 	"+enter
		
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),"TAF9",.F.,.T.)
		DbSelectArea("TAF9")
		While !TAF9->(Eof())
		
			DbSelectArea("AF9")
			RecLock("AF9",.T.)
			AF9->AF9_FILIAL  	:= TAF9->AF9_FILIAL
			AF9->AF9_PROJET  	:= TAF9->AF9_PROJET
			AF9->AF9_REVISA  	:= cNewRevisa
			AF9->AF9_TAREFA		:= TAF9->AF9_TAREFA
			AF9->AF9_DESCRI  	:= TAF9->AF9_DESCRI
			AF9->AF9_EDTPAI  	:= TAF9->AF9_EDTPAI
			AF9->AF9_NIVEL   	:= TAF9->AF9_NIVEL
			AF9->AF9_START		:= dDataBase
			AF9->AF9_FINISH		:= dDataBase
			AF9->AF9_CUSTPV  	:= TAF9->AF9_CUSTPV
			AF9->AF9_TVPVI   	:= TAF9->AF9_TVPVI
			AF9->AF9_TVPVBV  	:= TAF9->AF9_TVPVBV
			AF9->AF9_CUSTRE  	:= TAF9->AF9_CUSTRE
			AF9->AF9_TVRE    	:= TAF9->AF9_TVRE
			AF9->AF9_TVBRBV  	:= TAF9->AF9_TVBRBV
			AF9->AF9_CUSTO   	:= TAF9->AF9_CUSTO
			AF9->AF9_CALEND  	:= "001"
			AF9->AF9_TVPVC   	:= TAF9->AF9_TVPVC
			AF9->AF9_TVRECO		:= TAF9->AF9_TVRECO
			AF9->AF9_X_META  	:= TAF9->AF9_X_META
			AF9->AF9_METUNI  	:= TAF9->AF9_METUNI
			AF9->AF9_METTOT  	:= TAF9->AF9_METTOT
			AF9->AF9_X_RERI 	:= TAF9->AF9_X_RERI
			AF9->(MsUnlock())
			
			DbSelectArea("AFA")
			AFA->(DbSetOrder(1))
			_cQuery := " SELECT AFA.* " + enter
			_cQuery += " FROM " + RetSqlName("AFA") + " (NOLOCK) AFA  " + enter
			_cQuery += " WHERE 	AFA.AFA_FILIAL = '"  + allTrim(TAF9->AF9_FILIAL) + "'" + enter
			_cQuery += "   AND 	AFA.AFA_PROJET = '"  + allTrim(TAF9->AF9_PROJET) + "'" + enter
			_cQuery += "   AND 	AFA.AFA_REVISA = '"  + allTrim(_cRev) + "' 	" + enter
			_cQuery += "   AND 	AFA.AFA_TAREFA = '"  + TAF9->AF9_TAREFA+"'"
			_cQuery += "   AND 	AFA.D_E_L_E_T_ = ''" + enter
			dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),"TAFA",.F.,.T.)
			
			DbSelectArea("TAFA")
			While !TAFA->(Eof())

				dbSelectArea("AFA")
				RecLock("AFA",.T.)
				AFA->AFA_FILIAL:= TAFA->AFA_FILIAL
				AFA->AFA_PROJET:= TAFA->AFA_PROJET
				AFA->AFA_TAREFA:= TAFA->AFA_TAREFA
				AFA->AFA_REVISA:= cNewRevisa
				AFA->AFA_FIX   := "2"
				AFA->AFA_PRODUT:= TAFA->AFA_PRODUT //'0000001255' // ::Produto
				AFA->AFA_RECURS:= TAFA->AFA_RECURS
				AFA->AFA_QUANT := 1
				AFA->AFA_CUSTD := TAFA->AFA_CUSTD
				AFA->AFA_CUSTOT:= TAFA->AFA_CUSTOT
				AFA->AFA_METUNI:= TAFA->AFA_METUNI
				AFA->AFA_METQTD:= TAFA->AFA_METQTD
				AFA->AFA_METTOT:= TAFA->AFA_METQTD * TAFA->AFA_METUNI
					
				AFA->AFA_XEXEC 	:= TAFA->AFA_XEXEC
				AFA->AFA_XCARGO := TAFA->AFA_XCARGO
				AFA->AFA_X_DIAR := TAFA->AFA_X_DIAR
				AFA->AFA_QUANT	:= TAFA->AFA_QUANT
				AFA->AFA_CUSTD	:= TAFA->AFA_CUSTD
					
				AFA->AFA_DATPRF:= dDatabase
				AFA->AFA_MOEDA := 1
				AFA->AFA_PLNPOR:= "1"
				AFA->AFA_START := dDataBase
				AFA->AFA_FINISH:= dDataBase
				AFA->AFA_ACUMUL:= "4"
				AFA->(MsUnLock())
				TAFA->(DbSkip())
			EndDo
			TAFA->(DbCloseArea())
			
			TAF9->(DbSkip())

		EndDo

		TAF9->(DbCloseArea())
	EndIf
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} excDadosProj
Metodo de exclusão de Estrutura do Projeto
@aParam
@author		David Ferreira
@since		24/10/2013
@uso        WEBSERVICE
/*/
//--------------------------------------------------------------------
Static Function excDadosProj(_Fil, _Codigo, _Revisao, _cMgs)
	Local _lRet 	:= .t.
	Local _cQuery 	:= ""
	Local cArqTMP	:= ""

	_cMsg:=""

	autoGrLog("ExcDadosProj - Exclusão de Estrutura do Projeto")

	If _lRet

		cArqTMP := getnextAlias()
		_cQuery := " SELECT AFC.R_E_C_N_O_ AFCREC FROM "+RetsqlName("AFC") + " AFC "
		_cQuery += " WHERE 	AFC_FILIAL = '" + AllTrim(_Fil)     + "'"
		_cQuery += "   AND 	AFC_PROJET = '" + AllTrim(_Codigo)  + "'"
		_cQuery += "   AND 	AFC_REVISA = '" + AllTrim(_Revisao) + "'"
		_cQuery += "   AND 	AFC.D_E_L_E_T_   = '' 	"
		_cQuery += "   AND 	AFC_NIVEL 	   >= '003' "
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		While !(cArqTMP)->(Eof())
			_lRet := .t.
			DbSelectArea("AFC")
			AFC->(DbGoto((cArqTMP)->AFCREC))
			RecLock("AFC",.f.)
			AFC->(DbDelete())
			AFC->( MsUnLock() )
			(cArqTMP)->(dbSkip())
		EndDo
		(cArqTMP)->(DbCloseArea())

	EndIf

	If _lRet

		cArqTMP := getnextAlias()
		_cQuery := " SELECT AF9.R_E_C_N_O_ AF9REC FROM "+RetsqlName("AF9") + " AF9 "
		_cQuery += " WHERE 	AF9_FILIAL 	   	= '" + AllTrim(_Fil)	+ "'"
		_cQuery += "   AND 	AF9.AF9_PROJET	= '" + AllTrim(_Codigo) + "'"
		_cQuery += "   AND 	AF9_REVISA 	   	= '" + AllTrim(_Revisao)+ "'"
		_cQuery += "   AND 	AF9.D_E_L_E_T_ 	= ''  "
		_cQuery += "   AND 	AF9_TAREFA 		> '3' "
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		While !(cArqTMP)->(Eof())
			_lRet := .t.
			DbSelectArea("AF9")
			AF9->(DbGoto((cArqTMP)->AF9REC))
			RecLock("AF9",.f.)
			AF9->(DbDelete())
			AF9->( MsUnLock() )
			(cArqTMP)->(dbSkip())
		EndDo
		(cArqTMP)->(DbCloseArea())

	EndIf

	If _lRet
		cArqTMP := getnextAlias()
		_cQuery := " SELECT AFA.R_E_C_N_O_ AFAREC FROM "+RetsqlName("AFA") + " AFA "
		_cQuery += " WHERE	AFA_FILIAL = '" + AllTrim(_Fil)	   + "'"
		_cQuery += "   AND	AFA_PROJET = '" + AllTrim(_Codigo) + "'"
		_cQuery += "   AND	AFA_REVISA = '" + AllTrim(_Revisao)+ "'"
		_cQuery += "   AND	AFA.D_E_L_E_T_ 	= '' "
		_cQuery += "   AND	AFA_TAREFA 		> '3' "
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),cArqTMP,.F.,.T.)
		DbSelectArea(cArqTMP)
		While !(cArqTMP)->(Eof())
			_lRet := .t.
			DbSelectArea("AFA")
			AFA->(DbGoto((cArqTMP)->AFAREC))
			RecLock("AFA",.f.)
			AFA->(DbDelete())
			AFA->( MsUnLock() )
			(cArqTMP)->(dbSkip())
		EndDo
		(cArqTMP)->(DbCloseArea())
	EndIf

/*
_cQuery := " DELETE "+RetsqlName("AF9")
_cQuery += " WHERE	AF9_FILIAL = '"+AllTrim(cFil)+"'"
_cQuery += " 		AND	AF9_PROJET ='"+Alltrim(cProj)+"' "
_cQuery += " 		AND	AF9_REVISA ='"+Alltrim(cRevisao)+"' "
_cQuery += " 		AND	AF9_TAREFA >'3'"
_lRet := TcSQlExec(_cQuery) == 0


_cQuery := " DELETE "+RetsqlName("AFC")
_cQuery += " WHERE	AFC_FILIAL = '"+AllTrim(cFil)+"'"
_cQuery += " 		AND	AFC_PROJET ='"+Alltrim(cProj)+"' "
_cQuery += " 		AND	AFC_REVISA ='"+Alltrim(cRevisao)+"' "
_cQuery += " 		AND	AFC_EDT >'3'"

_lRet := TcSQlExec(_cQuery) == 0

_cQuery := " DELETE "+RetsqlName("AFA")
_cQuery += " WHERE	AFA_FILIAL = '"+AllTrim(cFil)+"'"
_cQuery += " 		AND	AFA_PROJET ='"+Alltrim(cProj)+"' "
_cQuery += " 		AND	AFA_REVISA ='"+Alltrim(cRevisao)+"' "
_cQuery += " 		AND	AFA_TAREFA >'3'"
_lRet := TcSQlExec(_cQuery) == 0
*/

Return(_lRet)

//-------------------------------------------------------------------------------
/*/ {Protheus.doc} getRevisoes - Método para Obter Revisoes de um Projeto
@author	Fernando
@since		09/12/2014
/*/
//-------------------------------------------------------------------------------
WSMETHOD getReviewProj WSRECEIVE KEY, Empresa, Projeto, _cMsg WSSEND ListItensRev WSSERVICE newReviewProj

	Local _lRet		:=.T.
	Local _aDados	:={}
	Local _cCdGest	:=""
	Local cNewRevisa:= ""
	Local nItens 	:= 0
	Local i			:= 0
	Local j			:= 0
	Local cFlag 	:=""
	Local cQuery 	:= ""
	Local cArqTMP 	:= GetNextAlias()
	Local cMsgEmp	:= u_TrocaEmp(Alltrim(::Empresa), "01")  // Posiciona na Empresa.

	::_cMsg:= ""
	If !Empty(cMsgEmp)
		::_cMsg:= cMsgEmp
		_lRet:= .f.
	EndIf

	/*If _lRet
		If Alltrim(::KEY) <> AllTrim(GetMV('ES_KEYWS'))
			::_cMsg:= "Erro de Autenticação. A Chave informada não é válida para acesso ao método [newReviewProj]"
			_lRet:= .f.
		EndIf
	EndIf*/

	If _lRet

		cQuery := " SELECT AFE.AFE_REVISA FROM "+RETSQLNAME("AFE")+" AFE WHERE AFE.AFE_PROJET ='"+::Projeto+"' AND AFE.D_E_L_E_T_ = '' ORDER BY AFE.AFE_REVISA DESC "
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
		SetSoapFault("getReviewProj", ::_cMsg)
	EndIf
	
Return(_lRet)


//-------------------------------------------------------------------------------
/*/ {Protheus.doc} getSaldoPCTar - Obtém saldo do valor de Pedido de Compras 
					 por tarefa
@author	Fernando
@since		30/06/2015
/*/
//-------------------------------------------------------------------------------
Static Function getSaldoPCTar(cProj, cTar)
Local _nValorPC 	:= 0
Local _nQuant		:= 0
Local cQuery 		:= ""
Local cArqTMP		:= GetNextAlias()
cQuery := " SELECT  ISNULL(COUNT(*),0) AS QTDPC, ISNULL(SUM(C7_TOTAL),0) AS VALORPC "
cQuery += " FROM "+RetSqlName("SC7")+" SC7 "
cQuery += " WHERE "
cQuery += "			SC7.C7_CODPSP ='"+cProj+"'"
cQuery += "		AND SC7.C7_TAREFA ='"+cTar+"'"
cQuery += " 		AND SC7.D_E_L_E_T_ ='' "
dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTMP,.F.,.T.)
DbSelectArea(cArqTMP)
If !(cArqTMP)->(Eof())
	_nQuant  := (cArqTMP)->QTDPC
	_nValorPC:= (cArqTMP)->VALORPC
EndIf
(cArqTMP)->(DbCloseArea())
Return({_nQuant, _nValorPC})