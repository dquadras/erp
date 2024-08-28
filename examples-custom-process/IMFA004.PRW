#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "pmsxfun.ch"
//#include "pmsicons.ch"
#DEFINE  CRLF CHR(13)+CHR(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA004 - Importacao Planilha Excel Eventos
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           David Ferreira Quadras
@Obs
/*/
//--------------------------------------------------------------------
User Function IMFA004(cProjeto)
Local aArea			:=GetArea()
Local aCampos		:={}
Private cArquivo 	:=""
Private cProjAF8 	:=""
Private cRevAF8 	:=""
Private cDescAF8 	:=""
Private cUNNegAF8	:=""
Private cDUNegAF8	:=""
Private cTPNegAF8 	:=""
Private cCdCliAF8	:=""
Default cProjeto 	:=""

//teste

If Empty(cProjeto)
	AjustaSX1("IMFA004")
	If Pergunte("IMFA004")
		cProjeto:=MV_PAR01
	Else
		Alert("Importacao Cancelada")
		RestArea(aArea)
		Return
	Endif
Endif

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
AF8->(DbGoTop())
If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjeto,"AF8_PROJET")))
	If Alltrim(AF8->AF8_FASE)=="01"
		cProjAF8	:=AF8->AF8_PROJET
		cRevAF8		:=AF8->AF8_REVISA
		cDescAF8	:=AF8->AF8_DESCRI
		cUNNegAF8	:=Alltrim(AF8->AF8_X_TIPO)
		cTPNegAF8 	:=Alltrim(AF8->AF8_TPPRJ)
		cCdCliAF8	:=Alltrim(AF8->AF8_CLIENT+AF8->AF8_LOJA)
		cDUNegAF8	:=""
		DbSelectArea("SZ4")
		SZ4->(DbSetOrder(1))//Z4_FILIAL, Z4_X_COD
		SZ4->(DbGoTop())
		If SZ4->(DbSeek(xFilial("SZ4")+Avkey(AF8->AF8_X_TIPO,"Z4_X_COD")))
			cDUNegAF8	:=Alltrim(AF8->AF8_X_TIPO)+"-"+Alltrim(SZ4->Z4_X_DESC)
		Endif
		
		DbSelectArea("SZL")
		SZL->(DbSetOrder(1))//ZL_FILIAL, ZL_CODIGO
		SZL->(DbGoTop())
		If SZL->(DbSeek(xFilial("SZL")+Avkey(AF8->AF8_TPPRJ,"ZL_CODIGO")))
			cTPNegAF8	+="-"+Alltrim(SZL->ZL_TIPPROJ)
		Endif
		
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))//A1_FILIAL, A1_COD
		SA1->(DbGoTop())
		If SA1->(DbSeek(xFilial("SZL")+Avkey(cCdCliAF8,"A1_COD")))
			cCdCliAF8	+="-"+Alltrim(SA1->A1_NOME)
		Endif
		
		
		
		//Prepara campos para a visualizacao em formato planilha do projeto, a partir do arquivo PROFILE\RPMSC01.PLN
		aCampos := {}
		aAdd(aCampos,"_CHAVE")//EDT ou Tarefa
		aAdd(aCampos,"_DESCRI")
		//=======================================================
		//Arquivo de Configuracao
		//=======================================================
		A004Cfg(@aCampos)
		//=======================================================
		//Planilha de acordo com o Arquivo de Configuracao
		//=======================================================
		A004Plan(aCampos)
		If Select("XXX")>0
			DbSelectArea("XXX")
			XXX->(DbCloseArea())
		Endif
	Else
		Aviso("Alterar Fase","Importacao apenas pode ser efetuado na Fase 01",{"Ok"},2)
	Endif
Endif
RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/A031Open - Cria ou monta o arquivo que ser� utilizado no
gerencial
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs             Abre o arquivo de configuracoes, se nao encontrar cria o arq.
/*/
//--------------------------------------------------------------------
Static Function A004Cfg(aCampos)
Local aArea		:= GetArea()
//Local cQuery 	:= ""
//Local cArea		:= ""
Local cArqCFG   := ""
Local cCmpCFG   := ""
Local cVerCFG   := ""
Local cPswCFG   := ""
Local cDescCFG  := ""
Local cCmpNOT	:= "_TVTEV#_CUSTO#_METOT"
Local nArqCFG   := 0


cArqCFG:=  "A004EVENTO"+__cUserId+".PLN"
//===========================================
//Criacao do Arquivo PLN
//===========================================
If !File("\PROFILE\"+cArqCFG)
	nArqCfg:=FCreate("\PROFILE\"+cArqCfg)
	If nArqCfg==-1
		Aviso("Falha na Abertura.","Erro na criacao do arquivo "+cArqCFG+".",{"Ok"},2)
	Else
		FWrite(nArqCfg,"_X_PLAN#"	+CRLF)
		FWrite(nArqCfg,"101"+CRLF)
		FWrite(nArqCfg,"1"+CRLF)
		fClose(nArqCfg)
	Endif
Endif
If FT_FUse(AllTrim("\PROFILE\"+cArqCFG))<> -1
	cArqCFG	:= AllTrim("\PROFILE\"+cArqCFG)
	FT_FGOTOP()
	cCmpCFG := FT_FREADLN()
	//-------------------------------------
	FT_FSKIP()
	cVerCFG	:= FT_FREADLN()
	If AllTrim(cVerCFG) != "101" .And. AllTrim(cVerCFG) != "102"
		Aviso("Falha no Arquivo","Estrutura do arquivo incompativel. Verifique o arquivo selecionado.",{"Ok"},2 )
		cCmpCFG	:= ""
	Else
		//-------------------------------------
		// o arquivo esta codificado?
		//-------------------------------------
		If AllTrim(cVerCFG) == "102"
			FT_FSKIP()
			cPswCFG := FT_FREADLN()
			
			FT_FSKIP()
			cDescCFG:= FT_FREADLN()
			
			cCmpCFG:= Embaralha(cCmpCFG, 0)
			cDescCFG := Embaralha(cDescCFG, 0)
		Else
			FT_FSKIP()
			cDescCFG:= FT_FREADLN()
		EndIf
		
		FT_FUSE()
		
		Do While !Empty(cCmpCFG)
			If AT("#",cCmpCFG)>0
				cAux:=Substr(cCmpCFG,1,AT("#",cCmpCFG)-1)
				If !(cAux$cCmpNOT)
					aAdd(aCampos,cAux)
				Endif
				cCmpCFG:=Substr(cCmpCFG,AT("#",cCmpCFG)+1,Len(cCmpCFG)-AT("#",cCmpCFG))
			Else
				cCmpCFG:=""
			Endif
		End
	Endif
Else
	Aviso("Falha na Abertura.","Erro na abertura do arquivo "+cArqCFG+". Verifique a existencia do arquivo selecionado na pasta %START PATH%\profile\",{"Ok"},2)
EndIf
RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/A004GerPlan - Gera os dados da Estrutura
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004GerPlan()
Local aArea		:= GetArea()
Local nPos		:= 0
Local nVlrSC7	:= 0
Local nVlrSD1	:= 0
Local nVlrCor	:= 0
Local _nMeta	:= 0
Local _cQuery	:=""
Local aCopia	:= {}
Local nX
Private aStruct	:={}

aStruct	:={}
_nMeta	:=0

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjAF8,"AF8_PROJET")))
	DbSelectArea("AFC")
	AFC->(DbSetOrder(1))
	AFC->(DbGoTop())
	If AFC->(DbSeek(xFilial("AFC")+AvKey(AF8->AF8_PROJET,"AFC_PROJET")+AvKey(AF8->AF8_REVISA,"AFC_REVISA")+AvKey(AF8->AF8_PROJET,"AFC_EDT")))
		nVlrSC7:=0
		nVlrSD1:=0
		nVlrCor:=0
		_nMeta := AFC->AFC_X_META
		
		aAdd(aStruct, {"EDT","-","A",AFC->(Recno()),;
		AFC->AFC_PROJETO,AFC->AFC_PROJETO,Val(AFC->AFC_NIVEL),;
		AFC->AFC_TVPVI+AFC->AFC_TVRE,AFC->AFC_CUSTPV+AFC->AFC_CUSTRE,AFC->AFC_TVPVC,;
		_nMeta, AFC->AFC_X_COEF,nVlrSC7,;
		nVlrSD1,nVlrCor,AFC->AFC_CUSTPV,;
		AFC->AFC_TVPVI,AFC->AFC_CUSTRE,AFC->AFC_TVRE})
		
		
		_cQuery	:=""
		_cQuery	+="	SELECT AFC_PROJET,AFC_REVISA,AFC_EDT,AFC_EDTPAI,AFC_NIVEL,AFC_TVPVI,AFC_TVRE,AFC_CUSTPV,AFC_CUSTRE,AFC_TVPVC,AFC_X_META,AFC_X_META, "
		_cQuery	+="	AFC_X_COEF, R_E_C_N_O_ "
		_cQuery	+=" FROM "+RetSQlName("AFC")+" "
		_cQuery	+=" WHERE D_E_L_E_T_='' "
		_cQuery	+=" AND AFC_PROJET='"+AFC->AFC_PROJET+"' "
		_cQuery	+=" AND AFC_EDTPAI<>'"+AFC->AFC_PROJET+"' "
		_cQuery	+=" AND AFC_EDT NOT IN('1','2') "
		_cQuery	+=" AND AFC_REVISA='"+AFC->AFC_REVISA+"' "
		
		TcQuery _cQuery  NEW ALIAS "TRBPAI"
		
		DbSelectArea("TRBPAI")
		If TRBPAI->(!EOF())
			Do While TRBPAI->(!EOF())
				nVlrMet	:=TRBPAI->AFC_X_META
				nVlrSC7:=0
				nVlrSD1:=0
				nVlrCor:=0
				
				aAdd(aStruct, {"EDT","-","A",TRBPAI->R_E_C_N_O_,TRBPAI->AFC_EDT,TRBPAI->AFC_EDTPAI,Val(TRBPAI->AFC_NIVEL),;
				TRBPAI->AFC_TVPVI+TRBPAI->AFC_TVRE,TRBPAI->AFC_CUSTPV+TRBPAI->AFC_CUSTRE,TRBPAI->AFC_TVPVC,;
				_nMeta, TRBPAI->AFC_X_COEF,nVlrSC7,;
				nVlrSD1,nVlrCor,TRBPAI->AFC_CUSTPV,;
				TRBPAI->AFC_TVPVI,TRBPAI->AFC_CUSTRE,TRBPAI->AFC_TVRE})
				
				A004AddPlan(TRBPAI->AFC_PROJET,TRBPAI->AFC_REVISA,TRBPAI->AFC_EDT)
				TRBPAI->(DbSkip())
			End
		Endif
		If Select("TRBPAI")>0
			DbSelectArea("TRBPAI")
			TRBPAI->(DbCloseArea())
		Endif
	Endif
Endif
aCopia:=aClone(aStruct)
aSort(aCopia,,,{ |x,y| x[1]+StrZero(x[7],4)+x[6] >  y[1]+StrZero(y[7],4)+y[6] } )
For nX:=1 To Len(aCopia)
	If !Alltrim(aCopia[nX][5])==Alltrim(aCopia[nX][6])
		nPos:=Ascan(aStruct,{|x| Alltrim(x[5]) == Alltrim(aCopia[nX][6])})
		If nPos>0
			If 	aStruct[nPos][1]=="EDT"
				aStruct[nPos][13] 	+=aCopia[nX][13]//nVlrSC7
				aStruct[nPos][14]	+=aCopia[nX][14]//nVlrSD1
				aStruct[nPos][15]	+=aCopia[nX][15]//nVlrCor
			Endif
		Endif
		nPos:=Ascan(aCopia,{|x| Alltrim(x[5]) == Alltrim(aCopia[nX][6])})
		If nPos>0
			If 	aCopia[nPos][1]=="EDT"
				aCopia[nPos][13] 	+=aCopia[nX][13]//nVlrSC7
				aCopia[nPos][14]	+=aCopia[nX][14]//nVlrSD1
				aCopia[nPos][15]	+=aCopia[nX][15]//nVlrCor
			Endif
		Endif
	Endif
Next

RestArea(aArea)
Return aStruct
//-------------------------------------------------------------------
/*/A004AddPlan - Funcao recursiva na montagem da estrutura dio projeto.
Chamado pela funcao A004GerPlan
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004AddPlan(cProj,cRev,cEdt)
Local aArea		:= GetArea()
Local cChave	:= ""
Local cEdtPAI	:= ""
Local nNivel	:= 0
Local nVlrVda	:= 0
Local nVlrOrc	:= 0
Local nCoefOrc	:= 0
Local nVlrMet	:= 0
Local nCoefMet	:= 0
Local nVlrSC7	:= 0
Local nVlrSD1	:= 0
Local nVlrCor	:= 0
Local nCustPV	:= 0
Local nPrecPV	:= 0
Local nCustRE	:= 0
Local nPrecRE	:= 0

DbSelectArea("AFC")
AFC->(dbSetOrder(2))
If AFC->(DbSeek(xFilial("AFC")+AvKey(cProj,"AFC_PROJET")+AvKey(cRev,"AFC_REVISA")+AvKey(cEdt,"AFC_EDTPAI")))
	Do While AFC->(!Eof()) .And. Alltrim(cProj)==Alltrim(AFC->AFC_PROJET) .And. Alltrim(cRev)==Alltrim(AFC->AFC_REVISA) .And. Alltrim(cEdt)==Alltrim(AFC->AFC_EDTPAI)
		nVlrSC7:=0
		nVlrSD1:=0
		nVlrOrc:=0
		
		
		cChave  :=AFC->AFC_EDT
		cEdtPAI	:=AFC->AFC_EDTPAI
		nNivel	:=Val(AFC->AFC_NIVEL)
		nVlrVda	:=AFC->AFC_TVPVI+AFC->AFC_TVRE
		nVlrOrc	:=AFC->AFC_CUSTPV+AFC->AFC_CUSTRE
		nCoefOrc:=AFC->AFC_TVPVC
		nVlrMet	:=AFC->AFC_X_META
		nCoefMet:=AFC->AFC_X_COEF
		nCustPV :=AFC->AFC_CUSTPV
		nPrecPV :=AFC->AFC_TVPVI
		nCustRE :=AFC->AFC_CUSTRE
		nPrecRE :=AFC->AFC_TVRE
		
		aAdd(aStruct, {"EDT","-","A",AFC->(Recno()),cChave,cEdtPAI, nNivel, nVlrVda, nVlrOrc, nCoefOrc, nVlrMet, nCoefMet, nVlrSC7,nVlrSD1,nVlrCor,;
		nCustPV,nPrecPV,nCustRE,nPrecRE})
		A004AddPlan(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT)
		AFC->(DbSkip())
	End
Else
	
	DbSelectArea("AF9")
	AF9->(DbSetOrder(2))
	If AF9->(DbSeek(xFilial("AF9")+AvKey(cProj,"AF9_PROJET")+AvKey(cRev,"AF9_REVISA")+AvKey(cEdt,"AF9_EDTPAI")))
		Do While AF9->(!Eof()) .And. Alltrim(cProj)==Alltrim(AF9->AF9_PROJET) .And. Alltrim(cRev)==Alltrim(AF9->AF9_REVISA) .And. Alltrim(cEdt)==Alltrim(AF9->AF9_EDTPAI)
			nVlrSC7:=0
			nVlrSD1:=0
			nVlrOrc:=0
			
			//===============================================================================
			//Calculos
			//===============================================================================
			cChave  :=AF9->AF9_TAREFA
			cEdtPAI	:=AF9->AF9_EDTPAI
			nNivel	:=Val(AF9->AF9_NIVEL)
			nVlrVda	:=AF9->AF9_TVPVI+AF9->AF9_TVRE
			nVlrOrc	:=AF9->AF9_CUSTPV+AF9->AF9_CUSTRE
			nCoefOrc:=AF9->AF9_TVPVC
			nVlrMet	:=AF9->AF9_X_META
			nCoefMet:=AF9->AF9_X_COEF
			nCustPV :=AF9->AF9_CUSTPV
			nPrecPV :=AF9->AF9_TVPVI
			nCustRE :=AF9->AF9_CUSTRE
			nPrecRE :=AF9->AF9_TVRE
			If FindFunction("U_L001TOPC")
				nVlrSC7 :=u_L001TotPC(ALLTRIM(AF9->AF9_PROJET),ALLTRIM(AF9->AF9_TAREFA))
			Endif
			If FindFunction("U_L001TOREAL")
				nVlrSD1 :=u_L001TotReal(ALLTRIM(AF9->AF9_PROJET),ALLTRIM(AF9->AF9_TAREFA))
			Endif
			If FindFunction("U_L001VLRCOR")
				nVlrCor :=u_L001VlrCor(nVlrOrc,nVlrMet,nVlrSC7,nVlrSD1)
			Endif
			
			
			aAdd(aStruct, {"TAR","","A",AF9->(Recno()),cChave,cEdtPAI, nNivel, nVlrVda, nVlrOrc, nCoefOrc, nVlrMet, nCoefMet, nVlrSC7,nVlrSD1,nVlrCor,;
			nCustPV,nPrecPV,nCustRE,nPrecRE})
			AF9->(DbSkip())
		End
	Endif
Endif

RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/A004Plan - Montagem do Browse da Planilha
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004Plan(aCampos)
Local aArea     := 	GetArea()
Local cChave    := 	""
Local aArquivo	:= {}
Local aPlanilha := {}
Local aObjects 	:= {}
Local aPosObj 	:= {}
Local aSize 	:= MsAdvSize(.T.)
Local cLyHd01	:= 	"HEADER01"
Local cLy01Col1	:= 	"HD01_Win01"
Local cLy01Col2	:= 	"HD01_Win02"
Local nX        := 	0
Local nPosHd1   := 	0
Local _lRepr	:=.F.
Local oDlg
Local oBrowse
Local oFont
Local oBarTop
Local oSay01,oSay02,oSay03,oSay05
//Local oFont		:=  TFont():New('Courier new',,-16,.T.)
Local oLayer 	:= 	FwLayer():New()
Local oMenos	:= 	LoadBitmap( GetResources(), "SHORTCUTMINUS" )
Local oMais		:=	LoadBitmap( GetResources(), "SHORTCUTPLUS" )
Local oAll		:=	LoadBitmap( GetResources(), "PMSEXPALL" )
Local oCmp		:= 	LoadBitmap( GetResources(), "PMSEXPCMP" )
Private aHeader := {}
Private aAuxCps	:= aClone(aCampos)


AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100, 100, .t., .f. } )
aInfo 	:= { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
aPosObj := MsObjSize( aInfo, aObjects)
oDlg	:= TDialog():New( aSize[7], 000, aSize[6]+30, aSize[5], "Importacao Projeto",,,,,,,,oMainWnd,.T.)
//DEFINE FONT oFont NAME "Arial" SIZE 0, -10
oFont	 	:= TFont():New('Courier new',,20,,.T.,,,,.T.,.F.)
//oFont14b  	:= TFont():New("Arial"		 ,,14,,.T.,,,,.T.,.F.)
oLayer:Init(oDlg, .t.)

// Cria colunas do Layer.
oLayer:AddColumn(cLyHd01,100, .T.)

// Adiciona Janelas as Colunas
oLayer:addWindow(cLyHd01, cLy01Col1, 'Projeto'			, 25, .t., .f., {|| .t.},,{||.t.} )
oLayer:addWindow(cLyHd01, cLy01Col2, 'Importacao Projeto'	, 60, .t., .f., {|| .t.},,{||.t.} )

//=============================================================
//Geracao dos Dados da Planilha
//=============================================================
aPlanilha:=A004GerPlan()
//=============================================================
//Montagem dos dados da Planilha na Estrutura
//=============================================================
A004MontPlan(aPlanilha)

nPosHD1:=(oLayer:ALINES[1]:ACOLLUMNS[1]:NWIDTH/100)/2

dbSelectArea("XXX")
XXX->(dbGotop())

DEFINE BUTTONBAR oBarTop size 25,25 3D BOTTOM OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)

//Desable no botao quando unidade = PontoCom                                                                                                                  
If cUNNegAF8 <> '08'
	DEFINE BUTTON RESOURCE "ADD25" 		OF oBarTop ACTION(Iif(A004TpImp("I",cProjAF8),(A004Refresh(@oBrowse),oBrowse:Refresh()),.T.))	TOOLTIP ""//"Inclusao"
EndIf	

DEFINE BUTTON RESOURCE /*"EDIT25"*/ "EDIT0224"		OF oBarTop ACTION(Iif(A004TpImp("A",cProjAF8),(A004Refresh(@oBrowse),oBrowse:Refresh()),.T.))	TOOLTIP ""//"Alteracao"
DEFINE BUTTON RESOURCE "REFRESH25"	OF oBarTop ACTION(A004Refresh(@oBrowse),oBrowse:Refresh())					TOOLTIP ""//"Atualizar"
If FindFunction("U_L001BRWPED")
	DEFINE BUTTON RESOURCE "COMPRA25"	OF oBarTop ACTION(u_L001BrwPed(cProjAF8))									TOOLTIP "Cons.PC" //""//"Cons.PC"
Endif
DEFINE BUTTON RESOURCE "CANC0132" OF oBarTop ACTION(oDlg:End()) 												TOOLTIP  "Cancela" //""//"Cancela"

@ nPosHD1,nPosHD1  		Say oSay01 Prompt "Projeto:" 						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*6 	MsGet  cProjAF8  				PICTURE "@!" 		Size nPosHD1*6 ,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*13	Say oSay02 Prompt "Descricao:" 						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*18 	MsGet  cDescAF8  				PICTURE "@!" 		Size nPosHD1*20,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*40	Say oSay03 Prompt "Unid.Neg.:" 						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*46 	MsGet  cDUNegAF8			  	PICTURE "@!" 		Size nPosHD1*20,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1		Say oSay04 Prompt "Tipo Neg.:"						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1*6	MsGet  cTPNegAF8			  	PICTURE "@!" 		Size nPosHD1*32,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1*40	Say oSay05 Prompt "Cliente:"						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1*46 	MsGet  cCdCliAF8		 		PICTURE "@!" 		Size nPosHD1*20,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)


//========================================
//Montagem Planilha
//========================================
nAlias	:= Select("XXX")
//TCBrowse(): New ( [ nRow], [ nCol], [ nWidth], [ nHeight], [ bLine], [ aHeaders], [ aColSizes], [ oWnd], [ cField], [ uValue1], [ uValue2], [ bChange], [ bLDblClick], [ bRClick], [ oFont], [ oCursor], [ nClrFore], [ nClrBack], [ cMsg], [ uParam20], [ cAlias], [ lPixel], [ bWhen], [ uParam24], [ bValid], [ lHScroll], [ lVScroll] )
oBrowse := TcBrowse():New( aPosObj[2][1], aPosObj[2][2] ,  aPosObj[2][3], aPosObj[2][4], , , , oLayer:GetWinPanel(cLyHd01,cLy01Col2), ,,,,/*{|| (aPlanilha:=A004AtuPlan(aPlanilha),A004MontPlan(aPlanilha),oBrowse:Refresh()) }*/,,oFont,,,,, .F.,"XXX", .T.,, .F., ,.T.,.T. )
oBrowse:AddColumn( TCColumn():New( "",{ || If(XXX->XXX_CTRNIV=="-",oMenos,If(XXX->XXX_CTRNIV=="+",oMais,If(XXX->XXX_CTRNIV=="*",oAll,If(XXX->XXX_CTRNIV=="!",oCmp,Nil) )))},,,,"RIGHT" , 6, .T., .F.,,,, .T., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PmsRetRes(XXX->XXX_ALIAS,XXX->XXX_RECNO ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))//BITMAP
//oBrowse:SetBlkBackColor({ || If(!Empty(XXX->XXX_CTRNIV),CLR_LIGHTGRAY,CLR_WHITE)})
oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
For nx := 1 to Len(aAuxCps)
	If aAuxCps[nX]=="_CHAVE"
		cChave:="AFC_EDT"//Pelo padrao o campo EDT e Tarefa possuir o mesmo tamanho.
	Else
		cChave:="AFC"+aAuxCps[nX]
	Endif
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cChave))
		If cChave=="AFC_EDT"
			oBrowse:AddColumn( TCColumn():New("Codigo", FieldWBlock( "XXX_CHAVE", nAlias ),Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),{ || IF(!Empty(XXX->XXX_CTRNIV),oBrowse:OFONT:BOLD:=.T.,obrowse:OFONT:BOLD:=.F.)},, Iif(SX3->X3_TIPO=="N","RIGHT","LEFT"), SX3->X3_TAMANHO+20, .F., .F.,,,, .F., ) )
		Else
			oBrowse:AddColumn( TCColumn():New(SX3->X3_TITULO, FieldWBlock( "XXX"+Substr(cChave,4,Len(cChave)), nAlias ),Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),{ || IF(!Empty(XXX->XXX_CTRNIV),oBrowse:OFONT:BOLD:=.T.,obrowse:OFONT:BOLD:=.F.)},, Iif(SX3->X3_TIPO=="N","RIGHT","LEFT"), SX3->X3_TAMANHO+20, .F., .F.,,,, .F., ) )
		Endif
	EndIf
Next
oBrowse:AddColumn( TCColumn():New("Total Venda"		, FieldWBlock("XXX_TVTEV" , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Custo Orcado"	, FieldWBlock("XXX_ORCTOT", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Meta Total"		, FieldWBlock("XXX_X_META", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Preco Venda"		, FieldWBlock("XXX_TVPVI" , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Reembolso"		, FieldWBlock("XXX_TVRE"  , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
//oBrowse:AddColumn( TCColumn():New("Tot.Pedido"		, FieldWBlock("XXX_PEDTOT", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
//oBrowse:AddColumn( TCColumn():New("Tot.Realizado"	, FieldWBlock("XXX_REATOT", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", 5, .T., .F.,,,, .T., ))
oBrowse:Refresh()


ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/A004AtuPlan - Tratamento no Browse dos dados a ser apresentados
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
/*
Static Function A004AtuPlan(aDadGer)
Local aArea			:= GetArea()
Local nX 			:= 0
Local nY 			:= 0

If Select("XXX")>0
For nX := 1 to Len(aDadGer)
If Alltrim(aDadGer[nX][5])==Alltrim(XXX->XXX_CHAVE)
If XXX->XXX_CTRNIV=="+"
aDadGer[nX][2]:="-"
ElseIf XXX->XXX_CTRNIV=="-"
aDadGer[nX][2]:="+"
Endif
nX++
For nY:=nX To Len(aDadGer)
If aDadGer[nY][7]>XXX->XXX_NIVTRE
If XXX->XXX_CTRNIV=="+"
aDadGer[nY][3]:="A"

ElseIf XXX->XXX_CTRNIV=="-"
aDadGer[nY][3]:="I"
Endif
Else
Exit
Endif
Next
Endif
Next
Endif
RestArea(aArea)
Return aDadGer
*/

//-------------------------------------------------------------------
/*/A004MontPlan - Montagem dos Dados do  Browse da Planilha
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------

Static Function A004MontPlan(aDadGer)
Local aArea			:= GetArea()
Local cChave		:= ""
Local nX 			:= 0
Local nY 			:= 0
Default aDadGer		:= {}


//=============================================================
//Montagem da Estrutura
//=============================================================
aArquivo:={}
For nX := 1 to Len(aAuxCps)
	If aAuxCps[nX]=="_CHAVE"
		cChave:="AFC_EDT"//Pelo padrao o campo EDT e Tarefa possuir o mesmo tamanho.
	Else
		cChave:="AFC"+aAuxCps[nX]
	Endif
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cChave))
		aAdd(aHeader,{;
		Iif(cChave=="AFC_EDT","Codigo",SX3->X3_TITULO),"XXX"+Substr(SX3->X3_CAMPO,4,Len(SX3->X3_CAMPO)-1),	Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),;
		SX3->X3_TAMANHO+20,SX3->X3_DECIMAL,"",	SX3->X3_USADO,SX3->X3_TIPO,"XXX",SX3->X3_CONTEXT})
		aAdd(aArquivo,{Iif(cChave=="AFC_EDT","XXX_CHAVE","XXX"+Substr(SX3->X3_CAMPO,4,Len(SX3->X3_CAMPO))),SX3->X3_TIPO,SX3->X3_TAMANHO+20,SX3->X3_DECIMAL})
	EndIf
Next
aAdd(aArquivo,{"XXX_TVTEV"		,"N",14,2})//Preco Venda
aAdd(aArquivo,{"XXX_ORCTOT"		,"N",14,2})//Preco Venda
aAdd(aArquivo,{"XXX_X_META"		,"N",14,2})//Meta Total
aAdd(aArquivo,{"XXX_TVPVI"		,"N",14,2})//Preco Venda
aAdd(aArquivo,{"XXX_TVRE"		,"N",14,2})//Preco Reembolso
//aAdd(aArquivo,{"XXX_PEDTOT"		,"N",14,2})//Total Pedido
//aAdd(aArquivo,{"XXX_REATOT"		,"N",14,2})//TotalRealizado
aAdd(aArquivo,{"XXX_CTRNIV"		,"C",1,0})
aAdd(aArquivo,{"XXX_ALIAS"		,"C",3,0})
aAdd(aArquivo,{"XXX_NIVTRE"		,"N",3,0})
aAdd(aArquivo,{"XXX_RECNO"		,"N",14,0})
aAdd(aArquivo,{"XXX_REGPAI"		,"C",12,0})
aAdd(aArquivo,{"XXX_FLAG"		,"C",1,0})

cArquivo:=CriaTrab(aArquivo,.T.)

If Select("XXX")>0
	XXX->(DbCloseArea())
Endif

USE &cArquivo ALIAS "XXX" NEW
//dbUseArea(.T.,,cArquivo,"XXX",.T.,.F.)



For nX:=1 To len(aDadGer)
	//=============================================================
	//Montagem dos dados da Estrutura
	//=============================================================
	If aDadGer[nX][3]=="A"
		If aDadGer[nX][1] == "EDT"
			AFC->(DbGoto(aDadGer[nX][4]))
			RecLock("XXX",.T.)
			For nY := 1 to Len(aAuxCps)
				If aAuxCps[nY]=="_CHAVE"
					cChave:="AFC_EDT"
				Else
					cChave:="AFC"+aAuxCps[nY]
				Endif
				If Substr(cChave,1,1)!="|"
					If AFC->(FieldPos(cChave)) >0
						FieldPut(FieldPos("XXX"+aAuxCps[nY]),AFC->(FieldGet(FieldPos(cChave))))
					EndIf
				Endif
			Next
			XXX->XXX_CTRNIV	:=aDadGer[nX][2]
			XXX->XXX_FLAG	:=aDadGer[nX][3]
			XXX->XXX_RECNO	:=aDadGer[nX][4]
			XXX->XXX_REGPAI	:=aDadGer[nX][6]
			XXX->XXX_NIVTRE	:=aDadGer[nX][7]
			XXX->XXX_ORCTOT	:=aDadGer[nX][9]
			XXX->XXX_TVTEV  :=aDadGer[nX][17]+aDadGer[nX][19]
			XXX->XXX_TVPVI  :=aDadGer[nX][17]
			XXX->XXX_TVRE   :=aDadGer[nX][19]
			XXX->XXX_X_META	:=aDadGer[nX][11]
			//			XXX->XXX_PEDTOT	:=aDadGer[nX][13]
			//			XXX->XXX_REATOT	:=aDadGer[nX][14]
			XXX->XXX_ALIAS 	:="AFC"
			XXX->(MsUnlock())
		ElseIf aDadGer[nX][1] == "TAR"
			AF9->(DbGoto(aDadGer[nX][4]))
			RecLock("XXX",.T.)
			For nY := 1 to Len(aAuxCps)
				If aAuxCps[nY]=="_CHAVE"
					cChave:="AF9_TAREFA
				Else
					cChave:="AF9"+aAuxCps[nY]
				Endif
				If Substr(cChave,1,1)!="|"
					If AF9->(FieldPos(cChave)) >0
						FieldPut(FieldPos("XXX"+aAuxCps[nY]),AF9->(FieldGet(FieldPos(cChave))))
					EndIf
				Endif
			Next
			XXX->XXX_CTRNIV	:=aDadGer[nX][2]
			XXX->XXX_FLAG	:=aDadGer[nX][3]
			XXX->XXX_RECNO	:=aDadGer[nX][4]
			XXX->XXX_REGPAI	:=aDadGer[nX][6]
			XXX->XXX_NIVTRE	:=aDadGer[nX][7]
			XXX->XXX_ORCTOT	:=aDadGer[nX][9]
			XXX->XXX_TVTEV  :=aDadGer[nX][17]+aDadGer[nX][19]
			XXX->XXX_TVPVI  :=aDadGer[nX][17]
			XXX->XXX_TVRE   :=aDadGer[nX][19]
			XXX->XXX_X_META	:=aDadGer[nX][11]
			//			XXX->XXX_PEDTOT	:=aDadGer[nX][13]
			//			XXX->XXX_REATOT	:=aDadGer[nX][14]
			XXX->XXX_ALIAS	:= "AF9"
			XXX->(MsUnlock())
		Endif
	Endif
Next
XXX->(DbGoTop())
RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/A004TpImp - Importacao Planilha CSV de acordo com o Tipo
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004TpImp(_cTipo,_cCodPrj)
Local _aArea	:=GetArea()
Local _nX		:=0
Local _nPos		:=0
Local _nlinha	:=0
Local _aRet		:={}
Local _aTxt 	:={}
Local _aEDTSon	:={}
Local _aLink	:={}
Local _aVetor	:={}
Local _aCmb		:={"PSP","RETRANCA"}
Local _lOK		:=.F.
Local _lAbort	:=.F.
Local _lCons	:=.F.
Local _lTitulo	:=.F.
Local _cQuery	:=""
Local _cArqSC7	:=""

Local _cLinha	:=""
Local _cCodEDT	:=""
Local _cDescEDT	:=""
Local _cFiltro	:=Space(100)
Local _cCmb		:=""
Local _cVar		:=""
Local _oDlgPln
Local _oDlgTXT
Local _oLbx
Local _oSay01
Local _oFontConf

PRIVATE _nUnid := 0

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
If AF8->(DbSeek(xFilial("AF8")+AvKey(_cCodPrj,"AF8_PROJET")))
	If Alltrim(_cTipo)=="I"
		_cQuery	:=""
		_cQuery	+="	SELECT MAX(AFC_EDT) SEQMAX "
		_cQuery	+=" FROM "+RetSQlName("AFC")+" "
		_cQuery	+=" WHERE D_E_L_E_T_='' "
		_cQuery	+=" AND AFC_PROJET='"+AF8->AF8_PROJET+"' "
		_cQuery	+=" AND AFC_EDTPAI='"+AF8->AF8_PROJET+"' "
		//_cQuery	+=" AND AFC_EDT NOT IN('1','2') "
		_cQuery	+=" AND AFC_REVISA='"+AF8->AF8_REVISA+"' "
		
		TcQuery _cQuery  NEW ALIAS "TRBAFC"
		
		DbSelectArea("TRBAFC")
		If TRBAFC->(!EOF())
			_cCodEDT:=Soma1(Alltrim(TRBAFC->SEQMAX))
			If Empty(_cCodEDT)
				_cCodEDT:="3"
			ElseIf _cCodEDT=="10"
				_cCodEDT:="A"
			Endif
			_lOk:=.T.
		Else
			_cCodEDT:="3"
			_cDescEDT:="A SER IMPORTADO"
		Endif
		If Select("TRBAFC")>0
			DbSelectArea("TRBAFC")
			TRBAFC->(DbCloseArea())
		Endif
	ElseIf Alltrim(_cTipo)== "A"
		
		_cQuery	:=""
		_cQuery	+="	SELECT AFC_EDT,AFC_DESCRI "
		_cQuery	+=" FROM "+RetSQlName("AFC")+" "
		_cQuery	+=" WHERE D_E_L_E_T_='' "
		_cQuery	+=" AND AFC_PROJET='"+AF8->AF8_PROJET+"' "
		_cQuery	+=" AND AFC_EDTPAI='"+AF8->AF8_PROJET+"' "
		_cQuery	+=" AND AFC_EDT NOT IN('1','2') "
		_cQuery	+=" AND AFC_REVISA='"+AF8->AF8_REVISA+"' "
		
		TcQuery _cQuery  NEW ALIAS "TRBAFC"
		
		_aEDTSon:={}
		DbSelectArea("TRBAFC")
		If TRBAFC->(!EOF())
			Do While TRBAFC->(!EOF())
				aAdd(_aEDTSon,{TRBAFC->AFC_EDT,UPPER(TRBAFC->AFC_DESCRI)})
				TRBAFC->(DbSkip())
			End
		Endif
		If Select("TRBAFC")>0
			DbSelectArea("TRBAFC")
			TRBAFC->(DbCloseArea())
		Endif
		If Len(_aEDTSon)>0
			_lOk:=.F.
			_aVetor:=aClone(_aEDTSon)
			DEFINE MSDIALOG _oDlgPln TITLE "EDT Secundaria do Projeto "+AF8->AF8_PROJET FROM  000,000 TO 400,600 PIXEL STYLE DS_MODALFRAME
			@ 005,005 TO 030,300 LABEL "" 																							PIXEL OF _oDlgPln
			@ 015,010 Say	_oSay1 		Prompt "Filtrar"															Size 030,008 	PIXEL OF _oDlgPln
			@ 015,035 ComboBox _cCmb Items _aCmb  																	Size 060,008 	PIXEL OF _oDlgPln
			@ 015,100 MsGet _cFiltro   	Picture "@!"																Size 060,008 	PIXEL OF _oDlgPln
			@ 015,170 Button "Filtrar" 	Size 050,012 PIXEL OF _oDlgPln ACTION(A004Filt(@_oLbx,@_aVetor,_aEDTSon,_cCmb,_cFiltro))
			@ 040,010 LISTBOX _oLbx VAR _cVar FIELDS HEADER ;
			"PSP","Retranca";
			SIZE 280,120 OF _oDlgPln PIXEL
			_oLbx:SetArray( _aVetor )
			_oLbx:bLine := {|| {	_aVetor[_oLbx:nAt,1],;//Projeto
			_aVetor[_oLbx:nAt,2]}}
			@ 180,010 Button "<<"  			Size 040,012 PIXEL OF _oDlgPln ACTION(_oLbx:GoTop())
			@ 180,050 Button "<"  			Size 040,012 PIXEL OF _oDlgPln ACTION(_oLbx:GoUp())
			@ 180,090 Button ">"  			Size 040,012 PIXEL OF _oDlgPln ACTION(_oLbx:GoDown())
			@ 180,130 Button ">>"  			Size 040,012 PIXEL OF _oDlgPln ACTION(_oLbx:nAt:=Len(_aVetor),_oLbx:Refresh())
			@ 180,190 Button "Confirma"  	Size 050,012 PIXEL OF _oDlgPln ACTION(_lOK:=.T.,_cCodEDT:=Alltrim(_aVetor[_oLbx:nAt,1]),_cDescEDT:=Alltrim(_aVetor[_oLbx:nAt,2]),_oDlgPln:End())
			@ 180,240 Button "Cancelar"  	Size 050,012 PIXEL OF _oDlgPln ACTION(_oDlgPln:End())
			_oDlgPln:lEscClose:=.F.
			ACTIVATE MSDIALOG _oDlgPln CENTERED
		Else
			Aviso("Importacao EDT","O projeto n�o possui EDT Filhas para a importacao",{"OK"})
		Endif
		
	Endif
	If _lOk .And. ParamBox({	{6,"Arquivo",SPACE(50),"","FILE(mv_par01)","", 70 ,.T.,"Arquivo .CSV |*.CSV"}},;
		"Atualizar Projeto",@_aRet,,)
		If Aviso("Importacao de projetos","Atencao! Certifique-se de que o arquivo foi gerado com novo formato CSV (MS-DOS)  e que as configuracoes regionais do windows utilizam '.' para decimais. Deseja Continuar ?",;
			{"Sim", "Nao"}) == 1
			If (FT_FUse(AllTrim(_aRet[1])))== -1
				Help(" ",1,"NOFILEIMPOR")
				RestArea(_aArea)
				Return
			EndIf
			_nlinha	:=0
			_lAbort	:=.F.
			_lTitulo:=.F.
			_aLink	:={}
			//===============================================================================================================================================
			//Processo da Leitura do Arquivo Excel e armazanagem no Array aTXT
			//===============================================================================================================================================
			FT_FGOTOP()
			Do While !FT_FEOF()
				_cLinha := FT_FREADLN()
				
				If "PCOM"$UPPER(_CLINHA)
					_nUnid := 08
				Else
					_nUnid := 05
				Endif
				
				_nLinha++
				
				If (_nLinha==1 .And. _nUnid <> 08 .And. _nUnid <> 05 ) //Primeira linha deve conter o descritivo da unidade de negocio da EVENTOS ou PCOM
					Alert("Nao esta sendo lida a Planilha correta preparada para o Departamento de Eventos. Processo abortado!")
					_lAbort:=.T.
					Exit
				ElseIf 	"FIM DA PLANILHA"$UPPER(_CLINHA)//Primeira linha deve conter o descritivo da unidade de negocio da EVENTOS
					Exit
				ElseIF 	";TITULO;"$UPPER(_CLINHA) .Or. ";T�TULO;"$UPPER(_CLINHA) .Or. ";SUB-TITULO;"$UPPER(_CLINHA) .Or. ";SUB-T�TULO;"$UPPER(_CLINHA) .Or. ";PRODUTO;"$UPPER(_CLINHA)
					If 	";TITULO;"$UPPER(_CLINHA) .Or. ";T�TULO;"$UPPER(_CLINHA)
						_lTitulo:=.T.
					ElseIf ";SUB-TITULO;"$UPPER(_CLINHA) .Or. ";SUB-T�TULO;"$UPPER(_CLINHA)
						If !_lTitulo
							Aviso("Atencao","O TITULO deve vir antes do SUBTITULO",{"Ok"})                                                                          �
							Exit
						Endif
					ElseIf ";PRODUTO;"$UPPER(_CLINHA)
						If !_lTitulo
							Aviso("Atencao","O TITULO deve vir antes do PRODUTO",{"Ok"})
							Exit
						Endif
					Endif
					AADD(_aTxt,{})
					Do While At(";",_cLinha)>0
						aAdd(_aTxt[Len(_aTxt)],Substr(_cLinha,1,At(";",_cLinha)-1))
						_cLinha := StrTran(Substr(_cLinha,At(";",_cLinha)+1,Len(_cLinha)-At(";",_cLinha)),'"','')
						
					End
					If Len(AllTrim(_cLinha)) > 0
						aAdd(_aTxt[Len(_aTxt)],StrTran(Substr(_cLinha,1,Len(_cLinha)),'"','') )
					Else
						aAdd(_aTxt[Len(_aTxt)],"")
					Endif
					If Len(_aTxt[Len(_aTxt)])<18
						Alert("Linha "+StrZero(_nLinha,3)+" da Planilha Excel com quantidade de colunas insuficiente. Processo abortado!")
						_lAbort:=.T.
						Exit
					ElseIf Empty(_aTxt[Len(_aTxt)][01]) .And. Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "PRODUTO"
						Alert("Existem produto na linha "+StrZero(_nLinha,3)+" sem definicao (PR/RE/RI). Processo abortado!")
						_lAbort:=.T.
						Exit
					ElseIf Empty(_aTxt[Len(_aTxt)][05])
						If Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "PRODUTO"
							Alert("Existem produto na Linha "+StrZero(_nLinha,3)+" com numero do Item em branco. Processo abortado!")
							_lAbort:=.T.
							Exit
						ElseIf Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "TITULO" .Or. Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "T�TULO" ;
							.Or. Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "SUB-TITULO" .Or. Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "SUB-T�TULO"
							Alert("Existem Titulo ou Sub-Titulo na Linha "+StrZero(_nLinha,3)+" com numero do Item em branco. Processo abortado!")
							_lAbort:=.T.
							
							Exit
						Endif
					Endif
					If !Empty(_aTxt[Len(_aTxt)][05]) .And. Upper(Alltrim(_aTxt[Len(_aTxt)][04])) == "PRODUTO"
						_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(_aTxt[Len(_aTxt)][05]) })
						If _nPos>0
							Alert("Existem Produto com a mesma numeracao de Link. Verifique a linha "+StrZero(_nLinha,3)+". Processo abortado!")
							_lAbort:=.T.
						Else
							aAdd(_aLink,ALLTRIM(_aTxt[Len(_aTxt)][05]))
						Endif
					Endif
				Endif
				FT_FSKIP()
			End
			FT_FUSE()
			
			
			//================================================================================================
			//Processo de Importacao da EDT Filha no Projeto
			//================================================================================================
			_lCons:=.F.
			If !_lAbort .And. Len(_aTxt)>0
				If Len(_aLink)>0 .And. FindFunction("U_L001TotPC")
					DbSelectArea("AF9")
					AF9->(DbSetOrder(1))
					AF9->(DbGoTop())
					If AF9->(DbSeek(xFilial("AF9")+AvKey(AF8->AF8_PROJET,"AF9_PROJET")+AvKey(AF8->AF8_REVISA,"AF9_REVISA")))
						Do While AF9->(!Eof()) .And. Alltrim(AF8->AF8_PROJET)==Alltrim(AF9->AF9_PROJET) .And. Alltrim(AF8->AF8_REVISA)==Alltrim(AF9->AF9_REVISA)
							_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(AF9->AF9_X_PLAN) })
							If _nPos==0 .Or. !Alltrim(_aLink[_nPos])==ALLTRIM(AF9->AF9_X_PLAN)
								If SUBSTR(AF9->AF9_TAREFA,1,1)==ALLTRIM(_cCodEDT) .And. u_L001TotPC(ALLTRIM(AF9->AF9_PROJET),ALLTRIM(AF9->AF9_TAREFA))>0
									AADD(_aTxt,{})
									For _nX:=1 To Len(_aTXT[1])
										If _nX==4
											aAdd(_aTxt[Len(_aTxt)],"ERRO")
										ElseIf _nX==6
											aAdd(_aTxt[Len(_aTxt)],AF9->AF9_TAREFA)
										ElseIf _nX==17
											aAdd(_aTxt[Len(_aTxt)],"CONSIDERAR NA PLANILHA O LINK "+Alltrim(AF9->AF9_X_PLAN))
										ElseIf _nX==18
											aAdd(_aTxt[Len(_aTxt)],"N�o relacionado na planilha o Link da Tarefa "+ALLTRIM(AF9->AF9_TAREFA)+"que possui Pedido")
										Else
											aAdd(_aTxt[Len(_aTxt)],"-")
										Endif
									Next
								Endif
							Endif
							AF9->(DbSkip())
						End
					Endif
				Endif
				
				_cArqSC7:=GetNextAlias()
				
				_cQuery:=""
				_cQuery+=" SELECT DISTINCT C7_NUM,C7_X_PLAN "
				_cQuery+=" 	FROM "+RetSqlName("SC7")+" SC7 (NOLOCK) "
				_cQuery+=" 	WHERE SC7.D_E_L_E_T_=''
				_cQuery+=" 	AND C7_CODPSP='"+ Alltrim(AF8->AF8_PROJET) + "' "
				
				If Alltrim(_cTipo)=="A"
					_cQuery+=" 	AND SUBSTRING(C7_TAREFA,1,1)='"+_cCodEDT+ "' "
				Endif
				_cQuery+=" 	ORDER BY C7_NUM "
				
				dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),_cArqSC7,.F.,.T.)
				
				
				DbSelectArea(_cArqSC7)
				If (_cArqSC7)->(!EOF())
					Do While (_cArqSC7)->(!EOF())
						If !Empty((_cArqSC7)->C7_X_PLAN)
							_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim((_cArqSC7)->C7_X_PLAN)})
							If _nPos==0
								AADD(_aTxt,{})
								For _nX:=1 To Len(_aTXT[1])
									If _nX==4
										aAdd(_aTxt[Len(_aTxt)],"ERRO")
									ElseIf _nX==6
										aAdd(_aTxt[Len(_aTxt)],"-")
									ElseIf _nX==17
										aAdd(_aTxt[Len(_aTxt)],"Numero do Pedido "+Alltrim((_cArqSC7)->C7_NUM)+ " n�o possui amarracao com planilha atual")
									ElseIf _nX==18
										aAdd(_aTxt[Len(_aTxt)],"CONSIDERAR NA PLANILHA O LINK "+Alltrim((_cArqSC7)->C7_X_PLAN))
									Else
										aAdd(_aTxt[Len(_aTxt)],"-")
									Endif
								Next
							Endif
						Else
							AADD(_aTxt,{})
							For _nX:=1 To Len(_aTXT[1])
								If _nX==4
									aAdd(_aTxt[Len(_aTxt)],"ERRO")
								ElseIf _nX==6
									aAdd(_aTxt[Len(_aTxt)],"-")
								ElseIf _nX==17
									aAdd(_aTxt[Len(_aTxt)],"N�o existe link associado ao pedido "+Alltrim((_cArqSC7)->C7_NUM))
								ElseIf _nX==18
									aAdd(_aTxt[Len(_aTxt)],"LINK DO PEDIDO VAZIO. NECESSARIO EXCLUIR OU LINKAR O PEDIDO")
								Else
									aAdd(_aTxt[Len(_aTxt)],"-")
								Endif
							Next
						Endif
						(_cArqSC7)->(DbSkip())
					End
				Endif
				If Select(_cArqSC7)>0
					DbSelectArea(_cArqSC7)
					(_cArqSC7)->(DbCloseArea())
				Endif
				
				If Alltrim(_cTipo)=="A"
					For _nX:=1 To Len(_aTXT)
						If Empty(_aTXT[_nX][05])
							_aTXT[_nX][17]:="EM BRANCO"
							_aTXT[_nX][18]:="PREENCHER"
							_lCons:=.T.
						ElseIf Empty(_aTXT[_nX][06])
							_aTXT[_nX][17]:="EM BRANCO"
							_aTXT[_nX][18]:="PREENCHER"
							_lCons:=.T.
						Else
							DbSelectArea("AFC")
							AFC->(DbOrderNickName("AFCLINKEXC")) // Projeto + Revisao + LinkExcel
							AFC->(DbGoTop())
							If AFC->(DbSeek(xFilial("AFC")+AvKey(AF8->AF8_PROJET,"AFC_PROJET")+AvKey(AF8->AF8_REVISA,"AFC_REVISA")+AvKey(Alltrim(_aTXT[_nX,5]),"AFC_X_PLAN")))
								_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(AFC->AFC_X_PLAN)})
								If _nPos>0
									If Substr(AFC->AFC_EDTPAI,1,Len(_cCodEDT))<>Alltrim(_cCodEDT)
										_aTXT[_nX][17]:="Definir uma nova numeracao no link"
										_aTXT[_nX][18]:="Link relacionado a EDT "+ALLTRIM(AFC->AFC_EDT)
										_lCons:=.T.
									Endif
								Else
									If Upper(Alltrim(_aTxt[_nX][04]))=="PRODUTO"
										_aTXT[_nX][17]:="Definir uma nova numeracao no link do produto"
										_aTXT[_nX][18]:="Link relacionado a EDT "+ALLTRIM(AFC->AFC_EDT)
										_lCons:=.T.
									Else
										_aTXT[_nX][17]:="-"
										_aTXT[_nX][18]:="-"
									Endif
								Endif
							Else
								If Alltrim(_aTXT[_nX][04])=="ERRO"
									_lCons:=.T.
								Else
									DbSelectArea("AF9")
									AF9->(DbOrderNickName("AF9LINKEXC")) // Projeto + Revisao + LinkExcel
									AF9->(DbGoTop())
									If AF9->(DbSeek(xFilial("AF9")+AvKey(AF8->AF8_PROJET,"AF9_PROJET")+AvKey(AF8->AF8_REVISA,"AF9_REVISA")+AvKey(Alltrim(_aTXT[_nX,5]),"AF9_X_PLAN")))
										_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(AF9->AF9_X_PLAN)})
										If _nPos>0
											If Substr(AF9->AF9_EDTPAI,1,Len(_cCodEDT))<>Alltrim(_cCodEDT)
												_aTXT[_nX][17]:="Definir uma nova numeracao no link"
												_aTXT[_nX][18]:="Link relacionado a Tarefa "+ALLTRIM(AF9->AF9_TAREFA)
												_lCons:=.T.
											Endif
										Else
											If Upper(Alltrim(_aTxt[_nX][04]))=="TITULO" .Or. Upper(Alltrim(_aTxt[_nX][04]))=="T�TULO"
												_aTXT[_nX][17]:="Definir uma nova numeracao no link do titulo"
												_aTXT[_nX][18]:="Link relacionado a Tarefa "+ALLTRIM(AF9->AF9_TAREFA)
												_lCons:=.T.
											Else
												_aTXT[_nX][17]:="-"
												_aTXT[_nX][18]:="-"
											Endif
										Endif
									Else
										_aTXT[_nX][17]:="NAO EXISTE LINK"
										_aTXT[_nX][18]:="-"
									Endif
								Endif
							Endif
						EndiF
					Next
				Endif
				_lOK:=.F.
				DEFINE FONT _oFontConf NAME "Arial" SIZE 0,-14 BOLD
				DEFINE MSDIALOG _oDlgTXT TITLE "CONFERENCIA IMPORTACAO - "+Iif(_cTipo=="I","INCLUSAO ","ALTERACAO ")+" EDT FILHA "+Alltrim(_cCodEDT)+"-"+Alltrim(_cDescEDT) FROM  000,000 TO 400,1200 PIXEL STYLE DS_MODALFRAME
				@ 005,010 LISTBOX _oLbx VAR _cVar FIELDS HEADER ;
				"Classificao","Tipo","Descricao","Num.Item","CUSTO(V1)","VENDA(V2)","META","LINK","INCONSITENCIA","";
				SIZE 580,140 OF _oDlgTXT PIXEL;
				ColSizes {10, 10,50, 10, 14,14,14,30,30,1}
				_oLbx:SetArray( _aTXT )
				_oLbx:bLine := {|| {_aTXT[_oLbx:nAt,4],;
				_aTXT[_oLbx:nAt,1],;
				_aTXT[_oLbx:nAt,6],;
				Alltrim(_aTXT[_oLbx:nAt,5]),;
				_aTXT[_oLbx:nAt,10],;
				_aTXT[_oLbx:nAt,12],;
				_aTXT[_oLbx:nAt,14],;
				_aTXT[_oLbx:nAt,17],;
				_aTXT[_oLbx:nAt,18]	,;
				""}}
				
				If _lCons
					@ 160,010 Say _oSay01 Prompt "ATENCAO!!! INCONSITENCIA NA PLANILHA. O PROCESSO SERA ABORTADO"  	Size 300,012 FONT _oFontConf COLOR CLR_RED		PIXEL OF _oDlgTXT
				Else
					@ 160,010 Say _oSay01 Prompt "ATENCAO!!! PLANILHA VALIDADA COM SUCESSO"  	Size 300,012 FONT _oFontConf COLOR CLR_GREEN	PIXEL OF _oDlgTXT
				Endif
				@ 180,010 Button "<<"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoTop())
				@ 180,050 Button "<"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoUp())
				@ 180,090 Button ">"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoDown())
				@ 180,130 Button ">>"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:nAt:=Len(_aTXT),_oLbx:Refresh())
				@ 180,190 Button "Confirma"  	Size 050,012 PIXEL OF _oDlgTXT ACTION(_lOK:=.T.,_oDlgTXT:End())
				@ 180,240 Button "Cancelar"  	Size 050,012 PIXEL OF _oDlgTXT ACTION(_oDlgTXT:End())
				_oDlgTXT:lEscClose:=.F.
				ACTIVATE MSDIALOG _oDlgTXT CENTERED
				
				If _lOK
					If !_lCons
						Processa({|| A004Import(AF8->AF8_PROJET,AF8->AF8_REVISA,Iif(_cTipo=="I","",_cCodEDT),_aTxt)},"Importando CSV Eventos. Aguarde...")
						//Fernando	Processa({||A004Import(AF8->AF8_PROJET,AF8->AF8_REVISA,_cCodEDT,_aTxt)},"Importando CSV Eventos. Aguarde...")
						Alert("Processo Finalizado")
					Else
						Alert("Processo Abortado por haver inconsistencia na planilha ")
						_lOk:=.F.
					Endif
				Else
					Alert("Processo Abortado")
					_lOk:=.F.
				Endif
			Endif
		Endif
	Else
		_lOk:=.F.
	Endif
Endif
RestArea(_aArea)
Return _lOK
//-------------------------------------------------------------------
/*/A004Filt - Filtra os dados de acordo com a opcao escolhida na
selecao da EDT
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004Filt(_oFilt,_aVetList,_aVetEDT,_cCombo,_cChave)
Local _aArea	:=GetArea()
Local _nX		:=0
Local _nPosVet	:=1
Local _aFiltChv	:={}
Default _cChave :=""
Default _cCombo :=""
Default _aVetEDT:={}

If Len(_aVetEDT)>0
	_aFiltChv	:={}
	If _cCombo=="PSP"
		_nPosVet:=1
	Else
		_nPosVet:=2
	Endif
	If !Empty(_cChave)
		For _nX:=1 To Len(_aVetEDT)
			If Alltrim(_cChave)$Alltrim(_aVetEDT[_nX][_nPosVet])
				aAdd(_aFiltChv,{_aVetEDT[_nX][1],_aVetEDT[_nX][2]})
			Endif
		Next
	Else
		_aFiltChv	:=aClone(_aVetEDT)
	Endif
Endif
If Len(_aFiltChv)==0
	Aviso("Importacao EDT","Palavra Chave nao encontrada")
	_aFiltChv	:=aClone(_aVetEDT)
Endif
_aVetList:={}
_aVetList:=aClone(_aFiltChv)
_oFilt:aArray:={}
_oFilt:aArray:=aClone(_aVetList)
_oFilt:Refresh()
RestArea(_aArea)
Return
//-------------------------------------------------------------------
/*/A004Import - importa os dados da planilha para uma EDT Filha
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004Refresh(oBrwAtu)
Local _aArea	:=GetArea()
Local _aPlanRefr:={}

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjAF8,"AF8_PROJET")))
	MsgRun('Aguarde.... Recalculando Projeto...',, {|| u_L001PrjAT(AF8->AF8_PROJET,AF8->AF8_REVISA)})
	//	MsgRun('Aguarde.... Recalculando Projeto...',, {|| u_ReprocEDT(AF8->AF8_PROJET,AF8->AF8_REVISA)})
Endif
_aPlanRefr:=A004GerPlan()
A004MontPlan(_aPlanRefr)

RestArea(_aArea)
Return
//-------------------------------------------------------------------
/*/A004Import - importa os dados da planilha para uma EDT Filha
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function A004Import(_cPrjImp,_cRevImp,_cEdtImp,_aImport)
Local _aArea:=GetArea()
Local _nX		:=0
Local _nTotCus 	:=0
Local _nTotVda 	:=0
Local _nTotMet 	:=0
Local _cRevNew	:=""
Local _cEdtNiv3	:="00"
Local _cEdtNiv4	:="00"
Local _cTarNiv 	:="00"
Local _cNivel  	:="003"
Local _cLink	:=""
Local _cProduto	:=""
Local _cCCstVda	:=""
Local _cCCstRee	:=""
Local _cMsgImp	:=""
Local _cEDTPai	:=""
Local _cTarefa	:=""
Local _lTitulo 	:=.F.
Local _lSubTit 	:=.F.
Local _lCont	:=.F.
Local _lExcAFC	:=.F.
Default _cPrjImp:=""
Default _cRevImp:=""
Default _cEdtImp:=""
Default _aImport:={}

If Len(_aImport) >0
	Begin Transaction
	_cRevNew := Soma1(_cRevImp)
	If Empty(_cEdtImp)
		_cEdtNiv3:="0"
	Else
		_cEdtNiv3:="00"
	Endif
	DbSelectArea("AF8")
	AF8->(DbSetOrder(1))
	If AF8->(DbSeek(xFilial("AF8")+AvKey(_cPrjImp,"AF8_PROJET")))
		//===============================================================================================================================================
		//Se estiver revisao em aberto Finaliza e Abre uma Nova Revisao, caso contrario efetua somente a abertura. Gravacao do Historico
		//===============================================================================================================================================
		IF AF8->AF8_STATUS == '2'//Projeto em Revisao
			_cMsgImp   :="Revisao por causa da importa��o do arquivo Excel no dia "+DtoC(dDataBase)+" as "+Time()+" pelo Usuario "+Alltrim(UsrRetName(__cUserID))+"."+Chr(13)+Chr(10)
			DbSelectArea("AFE")
			AFE->(DbSetOrder(1))
			AFE->(DbGoTop())
			If AFE->(DbSeek(xFilial("AFE")+AvKey(AF8->AF8_PROJET,"AFE_PROJET")+AvKey(AF8->AF8_REVISA,"AFE_REVISA")))
				RecLock("AFE",.F.)
				AFE->AFE_DATAF	:= MsDate()
				AFE->AFE_HORAF	:= Time()
				AFE->AFE_USERF	:= RetCodUsr()
				AFE->AFE_CODMEM :=ALLTRIM(AFE->AFE_CODMEM)+Chr(13)+Chr(10)+"Iniciando"+_cMsgImp                  //Campo Memo Real
				AFE->(MsUnLock())
			Endif
		EndIf
		MsgRun('Aguarde.... Gerando nova revisao...',, {|| MaPmsRevisa(AF8->(Recno()),1,AF8->AF8_REVISA,_cRevNew)})
		
		DbSelectArea("AFE")
		AFE->(DbSetOrder(1))
		AFE->(DbGoTop())
		If !AFE->(DbSeek(xFilial("AFE")+AvKey(_cPrjImp,"AFE_PROJET")+AvKey(_cRevNew,"AFE_REVISA")))
			RecLock("AFE",.T.)
			AFE->AFE_PROJET	:= _cPrjImp
			AFE->AFE_DATAI	:= MsDate()
			AFE->AFE_HORAI	:= Time()
			AFE->AFE_USERI	:= RetCodUsr()
			AFE->AFE_REVISA	:= _cRevNew
			AFE->AFE_USERI	:= RetCodUsr()
			AFE->AFE_TIPO   := "1"
			AFE->AFE_DATAF	:= MsDate()
			AFE->AFE_HORAF	:= Time()
			AFE->AFE_USERF	:= RetCodUsr()
			AFE->AFE_CODMEM :=ALLTRIM(AFE->AFE_CODMEM)+Chr(13)+Chr(10)+"Finalizando"+_cMsgImp                  //Campo Memo Real
			If AFE->(FieldPos("AFE_FASE")) > 0 .And. AFE->(FieldPos("AFE_FASEOR")) > 0
				AFE->AFE_FASE   := AF8->AF8_FASE
				AFE->AFE_FASEOR := AF8->AF8_FASE
			EndIf
			AFE->(MsUnLock())
		Endif
		
		A004Excl(_cPrjImp,_cRevNew,_cEdtImp)
		
		// Processa dados obtidos da Planilha.
		For _nX := 1 to Len(_aImport)
			
			PmsIncProc(.T.)
			
			_cLink	:= Alltrim(_aImport[_nX][05])
			
			If Upper(alltrim(_aImport[_nX][04])) == "TITULO" .Or. Upper(alltrim(_aImport[_nX][04]))=="T�TULO" // EDT
				
				DbSelectArea("AFC")
				AFC->(DbSetOrder(1)) // Projeto + Revisao + EDT
				AFC->(DbGoTop())
				If !AFC->(DbSeek(xFilial("AFC")+AvKey(_cPrjImp,"AFC_PROJET")+AvKey(_cRevNew,"AFC_REVISA")+AvKey(_cEdtImp,"AFC_EDT"))) .And. !Empty(_cEDTImp)
					RecLock("AFC",.T.)
					AFC->AFC_PROJET := _cPrjImp
					AFC->AFC_REVISA := _cRevNew
					AFC->AFC_EDT    := _cEDTImp
					AFC->AFC_NIVEL  := "002"
					AFC->AFC_EDTPAI := _cPrjImp
					AFC->AFC_DESCRI := Iif(Empty(Alltrim(_aImport[_nX][6])),"NAO INFORMADO",Alltrim(_aImport[_nX][6]))
					AFC->AFC_START  := dDataBase
					AFC->AFC_FINISH := dDataBase
					AFC->AFC_X_PLAN	:= ""
					AFC->AFC_CALEND := "001"
					AFC->AFC_X_GEST := IIF(EMPTY(AF8->AF8_X_GEST),"019",AF8->AF8_X_GEST)
					AFC->(MsUnlock())
				Endif
				
				_cEdtNiv3	:=Soma1(_cEdtNiv3)
				_cEdtNiv4	:="00"
				_cTarNiv 	:="00"
				_cNivel  	:=Iif(Empty(_cEDTImp),"002","003")
				_lTitulo	:=.T.
				_lSubTit 	:=.F.
				
				RecLock("AFC",.T.)
				AFC->AFC_PROJET := _cPrjImp
				AFC->AFC_REVISA := _cRevNew
				If !Empty(_cEdtImp)
					AFC->AFC_EDT    := _cEdtImp+"."+_cEDTNiv3
					AFC->AFC_EDTPAI := _cEdtImp
				Else
					AFC->AFC_EDT    := _cEDTNiv3
					AFC->AFC_EDTPAI := _cPrjImp
				Endif
				AFC->AFC_NIVEL  := _cNivel
				AFC->AFC_DESCRI := Alltrim(_aImport[_nX][6])
				AFC->AFC_X_PLAN	:= _cLink
				AFC->AFC_START 	:= dDataBase
				AFC->AFC_FINISH	:= dDataBase
				AFC->AFC_CALEND := "001"
				AFC->AFC_X_GEST := IIF(EMPTY(AF8->AF8_X_GEST),"019",AF8->AF8_X_GEST)
				AFC->(MsUnlock())
				
			ElseIf Upper(alltrim(_aImport[_nX][04])) == "SUB-TITULO" .Or. Upper(alltrim(_aImport[_nX][04]))=="SUB-T�TULO"
				_cEdtNiv4	:=Soma1(_cEdtNiv4)
				_cTarNiv 	:="00"
				_cNivel  	:=Iif(Empty(_cEDTImp),"003","004")
				_lTitulo 	:=.F.
				_lSubTit 	:=.T.
				
				RecLock("AFC",.T.)
				AFC->AFC_PROJET := _cPrjImp
				AFC->AFC_REVISA := _cRevNew
				If !Empty(_cEdtImp)
					AFC->AFC_EDT    := _cEdtImp+"."+_cEdtNiv3+"."+_cEdtNiv4
					AFC->AFC_EDTPAI := _cEdtImp+"."+_cEdtNiv3
				Else
					AFC->AFC_EDT    := _cEdtNiv3+"."+_cEdtNiv4
					AFC->AFC_EDTPAI := _cEdtNiv3
				Endif
				AFC->AFC_NIVEL  := _cNivel
				AFC->AFC_DESCRI := Alltrim(_aImport[_nX][6])
				AFC->AFC_X_PLAN	:= _cLink
				AFC->AFC_START 	:= dDataBase
				AFC->AFC_FINISH	:= dDataBase
				AFC->AFC_CALEND := "001"
				AFC->AFC_X_GEST := IIF(EMPTY(AF8->AF8_X_GEST),"019",AF8->AF8_X_GEST)
				AFC->(MsUnlock())
				
			ElseIf Upper(alltrim(_aImport[_nX][04])) $ "PRODUTO"
				_cTarNiv:=Soma1(_cTarNiv)
				If _lTitulo
					If !Empty(_cEdTImp)
						_cEDTPai:=_cEdtImp+"."+_cEdtNiv3
						_cTarefa:=_cEdtImp+"."+_cEdtNiv3+"."+_cTarNiv
					Else
						_cEDTPai:=_cEdtNiv3
						_cTarefa:=_cEdtNiv3+"."+_cTarNiv
					Endif
				Else
					If !Empty(_cEdTImp)
						_cEDTPai:=_cEdtImp+"."+_cEdtNiv3+"."+_cEdtNiv4
						_cTarefa:=_cEdtImp+"."+_cEdtNiv3+"."+_cEdtNiv4+"."+_cTarNiv
					Else
						_cEDTPai:=_cEdtNiv3+"."+_cEdtNiv4
						_cTarefa:=_cEdtNiv3+"."+_cEdtNiv4+"."+_cTarNiv
					Endif
				Endif
				
				If Upper(Alltrim(_aImport[_nX][2])) == Upper("T�cnica")
					_aImport[_nX][2] := "TECNICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Log�stica")
					_aImport[_nX][2] := "LOGISTICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Gr�fica")
					_aImport[_nX][2] := "GRAFICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Excutiva")
					_aImport[_nX][2] := "EXECUTIVA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("	SEV. PR�PRIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SEV. PROPRIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SERV. PR�PRIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SERV. PROPRIOS")
					_aImport[_nX][2] := "SERVICOS PROPRIOS"
				Endif
				
				IF _nUnid == 05
					DbSelectArea("PA4")
					PA4->(DbSetOrder(1))//PA4_FILIAL+PA4_X_COD+PA4_X_CDPR+PA4_X_PROD+PA4_X_CC
					PA4->(DbGoTop())
					If PA4->(DbSeek(xFilial("PA4")+AvKey("05","PA4_X_COD")))
						Do While PA4->(!Eof()) .And. Alltrim(PA4->PA4_X_COD)==Alltrim("05")
							If Empty(_aImport[_nX][2]) .And. Upper(Alltrim(PA4->PA4_X_DSPR))=="PADRAO"
								_cProduto	:= PA4->PA4_X_PROD
								_cCCstVda	:= PA4->PA4_X_CCVD
								_cCCstRee	:= PA4->PA4_X_CCRE
							ElseIf Upper(Alltrim(PA4->PA4_X_DSPR))==Upper(Alltrim(_aImport[_nX][2]))
								_cProduto:= PA4->PA4_X_PROD
								_cCCstVda	:= PA4->PA4_X_CCVD
								_cCCstRee	:= PA4->PA4_X_CCRE
							Endif
							PA4->(DbSkip())
						End
					Endif
				ELSE         
					_cProduto := "0000000014"
					_cCCstVda := _aImport[_nX][2]
					_cCCstRee := _aImport[_nX][2]
				ENDIF
				
				If Empty(_cProduto)
					_cProduto := A004RetPrd()
				Endif
				
				DbSelectArea("AF9")
				AF9->(DbSetOrder(1))
				AF9->(DbGoTop())
				If AF9->(DbSeek(xFilial("AF9")+AvKey(_cPrjImp,"AF9_PROJET")+AvKey(_cRevNew,"AF9_REVISA")+AvKey(_cTarefa,"AF9_TAREFA")))
					RecLock("AF9",.F.)
					AF9->AF9_EDTPAI	:= _cEdtPai
					AF9->AF9_NIVEL 	:= Soma1(_cNivel)
					AF9->AF9_CCUSTO :=_cCCstVda
					AF9->AF9_CCRE	:=_cCCstRee
					AF9->AF9_QUANT 	:= 1
					AF9->AF9_START 	:= dDataBase
					AF9->AF9_FINISH	:= dDataBase
					AF9->AF9_TPMEDI	:= "4"
					AF9->AF9_CALEND	:= "001"
					AF9->AF9_PRIORI	:= 500
					AF9->AF9_X_TXMU	:= 0
					AF9->AF9_X_RERI	:= upper(Alltrim(_aImport[_nX][1]))
					AF9->AF9_X_VISU	:= _aImport[_nX][3]
					AF9->AF9_DESCRI	:= _aImport[_nX][6]
					AF9->AF9_X_OBS 	:= _aImport[_nX][6]
					AF9->AF9_CUSTO 	:= A004Troca(_aImport[_nX][10])//Custo do Projeto
					AF9->AF9_TVTEV 	:= A004Troca(_aImport[_nX][12])//Tt.Venda BV (PV c/BV+Reemb. c/BV)
					AF9->AF9_PEDTOT	:= u_L001TotPC(ALLTRIM(_cPrjImp),ALLTRIM(_cTarefa))
					AF9->AF9_REATOT	:= u_L001TotReal(ALLTRIM(_cPrjImp),ALLTRIM(_cTarefa))
					If !(upper(Alltrim(_aImport[_nX][1])) $ "RE/RI")
						AF9->AF9_CUSTPV   := A004Troca(_aImport[_nX][10])
						AF9->AF9_TVPVI    := A004Troca(_aImport[_nX][12])								//Preco venda
						AF9->AF9_TVPVBV   := A004Troca(_aImport[_nX][12])								//PV c/BV
						AF9->AF9_TVPVC    := A004Troca(_aImport[_nX][12])/A004Troca(_aImport[_nX][10])
						AF9->AF9_CUSTRE   := 0
						AF9->AF9_TVRE     := 0
						AF9->AF9_TVBRBV   := 0
						AF9->AF9_TVRECO   := 0
					Else
						AF9->AF9_CUSTPV   := 0
						AF9->AF9_TVPVI    := 0
						AF9->AF9_TVPVBV   := 0
						AF9->AF9_TVPVC    := 0
						AF9->AF9_CUSTRE   := A004Troca(_aImport[_nX][10])
						AF9->AF9_TVRE     := A004Troca(_aImport[_nX][12])
						AF9->AF9_TVBRBV   := A004Troca(_aImport[_nX][12])
						AF9->AF9_TVRECO   := A004Troca(_aImport[_nX][12])/A004Troca(_aImport[_nX][10])
					Endif
					AF9->AF9_X_META :=A004Troca(_aImport[_nX][14])
					AF9->AF9_X_PLAN:= _cLink
					AF9->(MsUnLock())
					
				Else
					RecLock("AF9",.T.)
					AF9->AF9_PROJET := _cPrjImp
					AF9->AF9_REVISA := _cRevNew
					AF9->AF9_EDTPAI	:= _cEdtPai
					AF9->AF9_TAREFA	:= _cTarefa
					AF9->AF9_NIVEL 	:= Soma1(_cNivel)
					AF9->AF9_CCUSTO :=_cCCstVda
					AF9->AF9_CCRE	:=_cCCstRee
					AF9->AF9_QUANT 	:= 1
					AF9->AF9_START 	:= dDataBase
					AF9->AF9_FINISH	:= dDataBase
					AF9->AF9_TPMEDI	:= "4"
					AF9->AF9_CALEND	:= "001"
					AF9->AF9_PRIORI	:= 500
					AF9->AF9_X_TXMU	:= 0
					AF9->AF9_X_RERI	:= upper(Alltrim(_aImport[_nX][1]))
					AF9->AF9_X_VISU	:= _aImport[_nX][3]
					AF9->AF9_DESCRI	:= _aImport[_nX][6]
					AF9->AF9_X_OBS 	:= _aImport[_nX][6]
					AF9->AF9_CUSTO 	:= A004Troca(_aImport[_nX][10])//Custo do Projeto
					AF9->AF9_TVTEV 	:= A004Troca(_aImport[_nX][12])//Tt.Venda BV (PV c/BV+Reemb. c/BV)
					AF9->AF9_PEDTOT	:= u_L001TotPC(ALLTRIM(_cPrjImp),ALLTRIM(_cTarefa))
					AF9->AF9_REATOT	:= u_L001TotReal(ALLTRIM(_cPrjImp),ALLTRIM(_cTarefa))
					If !(upper(Alltrim(_aImport[_nX][1])) $ "RE/RI")
						AF9->AF9_CUSTPV   := A004Troca(_aImport[_nX][10])
						AF9->AF9_TVPVI    := A004Troca(_aImport[_nX][12])								//Preco venda
						AF9->AF9_TVPVBV   := A004Troca(_aImport[_nX][12])								//PV c/BV
						AF9->AF9_TVPVC    := A004Troca(_aImport[_nX][12])/A004Troca(_aImport[_nX][10])
						AF9->AF9_CUSTRE   := 0
						AF9->AF9_TVRE     := 0
						AF9->AF9_TVBRBV   := 0
						AF9->AF9_TVRECO   := 0
					Else
						AF9->AF9_CUSTPV   := 0
						AF9->AF9_TVPVI    := 0
						AF9->AF9_TVPVBV   := 0
						AF9->AF9_TVPVC    := 0
						AF9->AF9_CUSTRE   := A004Troca(_aImport[_nX][10])
						AF9->AF9_TVRE     := A004Troca(_aImport[_nX][12])
						AF9->AF9_TVBRBV   := A004Troca(_aImport[_nX][12])
						AF9->AF9_TVRECO   := A004Troca(_aImport[_nX][12])/A004Troca(_aImport[_nX][10])
						
					Endif
					AF9->AF9_X_META :=A004Troca(_aImport[_nX][14])
					AF9->AF9_X_PLAN:= _cLink
					AF9->(MsUnLock())
				Endif
				DbSelectArea("AFA")
				AFA->(DbSetOrder(1))
				AFA->(DbGoTop())
				If AFA->(DbSeek(xFilial("AFA")+AvKey(_cPrjImp,"AFA_PROJET")+AvKey(_cRevNew,"AFA_REVISA")+AvKey(_cTarefa,"AFA_TAREFA")))
					RecLock("AFA",.F.)
					AFA->AFA_PRODUT:= _cProduto
					AFA->AFA_QUANT := 1
					AFA->AFA_METQTD:= 1
					AFA->AFA_METUNI:= 1
					AFA->AFA_METTOT:= A004Troca(_aImport[_nX][14])
					AFA->AFA_CUSTD := A004Troca(_aImport[_nX][10])
					AFA->AFA_CUSTOT:= A004Troca(_aImport[_nX][10])
					AFA->AFA_X_PLAN:= _cLink
					AFA->(MsUnlock())
				Else
					RecLock("AFA",.T.)
					AFA->AFA_FILIAL:= xFilial("AFA")
					AFA->AFA_ITEM  := "01"
					AFA->AFA_PROJET:= _cPrjImp
					AFA->AFA_REVISA:= _cRevNew
					AFA->AFA_TAREFA:= _cTarefa
					AFA->AFA_PRODUT:= _cProduto
					AFA->AFA_QUANT := 1
					AFA->AFA_METQTD:= 1
					AFA->AFA_METUNI:= 1
					AFA->AFA_METTOT:= A004Troca(_aImport[_nX][14])
					AFA->AFA_CUSTD := A004Troca(_aImport[_nX][10])
					AFA->AFA_CUSTOT:= A004Troca(_aImport[_nX][10])
					AFA->AFA_X_PLAN:= _cLink
					AFA->(MsUnlock())
				EndIf
				MsgRun("Aguarde!!! Processando ajustes das tarefas ","Manutencao",{|| A004AtuBS(_cPrjImp,_cRevNew,_cLink,_cTarefa,_aImport[_nX][6])})
			Endif
		Next
	Endif
	End Transaction
Endif
RestArea(_aArea)
Return

//-------------------------------------------------------------------
/*/ A004Excl
Exclusao das EDT,Tarefas e Recursos da Tarefa da EDT selecionada
@aParam
@aRetorno
@author
@since
@obs
@uso
/*/
//--------------------------------------------------------------------

Static Function A004Excl(_cPrj,_cRev,_cEDT)
Local _aArea    :=GetArea()
Local _cQryAFC	:=""
Local _cQryAF9	:=""
Local _cQryAFA	:=""

_cQryAFC:="DELETE "+RetSqlName("AFC")+" "
_cQryAFC+="WHERE AFC_PROJET='"+_cPrj+"' "
_cQryAFC+=" AND AFC_REVISA='"+_cRev+"' "
If !Empty(_cEDT)
	_cQryAFC+=" AND AFC_NIVEL NOT IN ('001','002') "
	_cQryAFC+=" AND SUBSTRING(AFC_EDT,1,1)='"+ALLTRIM(_cEdt)+"' "
Else
	_cQryAFC+=" AND AFC_NIVEL NOT IN('001') "
	_cQryAFC+=" AND ( AFC_NIVEL NOT IN('002') AFC_EDT NOT IN('1', '2') ) "
Endif
_cQryAFC+=" AND D_E_L_E_T_=''
TcSqlExec(_cQryAFC)

_cQryAF9:="DELETE "+RetSqlName("AF9")+" "
_cQryAF9+="WHERE AF9_PROJET='"+_cPrj+"' "
_cQryAF9+="AND AF9_REVISA='"+_cRev+"' "
If !Empty(_cEDT)
	_cQryAF9+="AND SUBSTRING(AF9_TAREFA,1,1)='"+ALLTRIM(_cEdt)+"' "
Endif

_cQryAF9+="   AND AF9_TAREFA NOT IN('1.01','1.02','2.01') "
_cQryAF9+="	AND D_E_L_E_T_=''

TcSqlExec(_cQryAF9)

_cQryAFA:="DELETE "+RetSqlName("AFA")+" "
_cQryAFA+="WHERE AFA_PROJET='"+_cPrj+"' "
_cQryAFA+="AND AFA_REVISA='"+_cRev+"' "
If !Empty(_cEDT)
	_cQryAFA+="AND SUBSTRING(AFA_TAREFA,1,1)='"+ALLTRIM(_cEdt)+"' "
EndIf
_cQryAFA+="   AND AFA_TAREFA NOT IN('1.01','1.02','2.01') "
_cQryAFA+="AND D_E_L_E_T_=''
TcSqlExec(_cQryAFA)
RestArea(_aArea)
Return
//-------------------------------------------------------------------
/*/ A004RetPrd
Funcao para retornar o codigo do produto
@aParam
@aRetorno
@author
@uso
/*/
//--------------------------------------------------------------------
Static Function A004RetPrd(_cDescTar)
Local _aArea     :=GetArea()
Local _cCodPrd	 := Space(25)
Local cEdit2	 := Space(25)
Local nOpc       := 0
Local nTamanho:= TAMSX3("B1_COD")[1]
Local _oDescTar, _oCodPrd
Local oEdit2
Local _oDlgPrd
Default _cDescTar	:=""

DbSelectArea("SB1")

DEFINE MSDIALOG _oDlgPrd TITLE "Codigo do Produto nao Cadastrado." 		FROM 258,231 TO 414,683 PIXEL
@ 007,006 Say "Descricao da Tarefa" 													Size 050,008  PIXEL OF _oDlgPrd
@ 020,006 MsGet _oDescTar Var _cDescTar 	when .F.									Size 207,009  PIXEL OF _oDlgPrd
@ 034,006 Say "Codigo do Produto" 								  						Size 046,008  PIXEL OF _oDlgPrd
@ 049,006 MsGet _oCodPrd  Var _cCodPrd F3 "SB1LIB" Valid ExistCpo("SB1",_cCodPrd)	 	Size 068,009  PIXEL OF _oDlgPrd
@ 047,174 Button "Confirma" Size 037,012 PIXEL OF _oDlgPrd ACTION If(ExistCpo("SB1",_cCodPrd),(_nOpc:=1,_oDlgPrd:End()),.F.)
ACTIVATE MSDIALOG _oDlgPrd CENTERED
RestArea(_aArea)
Return _cCodPrd
//-------------------------------------------------------------------
/*/ A004AtuBs
Funcao para efetuar a atualizacao da Tarefa na base de dados
@aParam
@aRetorno
@author		Marcos Kato
@since
@obs		A atualizacao n�o trata por revisao. Considera apenas
Projeto e Tarefa
@uso        UpLoad de Planilha Capo(generico para grupo TV1).
/*/
//--------------------------------------------------------------------
Static Function A004AtuBS(_cAtuPrj,_cAtuRev,_cAtuLink,_cAtuTar,_cAtuDesc)
Local _aArea  		:=GetArea()
Local _cMsgOBS		:=""
Default _cAtuPrj	:=""
Default _cAtuRev	:=""
Default _cAtuLink	:=""
Default _cAtuTar	:=""
Default _cAtuDesc	:=""

//=====================================
//Pedido de Compra
//=====================================
_cMsgOBS:=""
DbSelectArea("SC7")
SC7->(DbOrderNickName("SC7LINKEXC")) // Projeto + LinkExc
SC7->(DbGoTop())
If SC7->(Dbseek(xFilial("SC7")+AvKey(_cAtuPrj,"C7_CODPSP")+AvKey(_cAtuLink,"C7_X_PLAN")))
	Do While SC7->(!Eof()) .And. Alltrim(_cAtuPrj)==Alltrim(SC7->C7_CODPSP) .And.  Alltrim(_cAtuLink)==Alltrim(SC7->C7_X_PLAN)
		_cMsgOBS:="Ajuste importacao da Tarefa "+Alltrim(SC7->C7_TAREFA)+" para "+Alltrim(_cAtuTar)
		//=============================================================================================================
		//Projeto x Pedido de Compras
		//=============================================================================================================
		DbSelectArea("AJ7")
		AJ7->(DbSetOrder(2))//AJ7_FILIAL+AJ7_NUMPC+AJ7_ITEMPC+AJ7_PROJET+AJ7_REVISA+AJ7_TAREFA
		AJ7->(DbGoTop())
		If AJ7->(Dbseek(xFilial("AJ7")+AvKey(SC7->C7_NUM,"AJ7_NUMPC")+AvKey(SC7->C7_ITEM,"AJ7_ITEMPC")+AvKey(SC7->C7_CODPSP,"AJ7_PROJET")))
			Do While AJ7->(!Eof()) .And. Alltrim(SC7->C7_NUM)==Alltrim(AJ7->AJ7_NUMPC) .And. Alltrim(SC7->C7_ITEM)==Alltrim(AJ7->AJ7_ITEMPC) ;
				.And. Alltrim(SC7->C7_CODPSP)==Alltrim(AJ7->AJ7_PROJET)
				If Alltrim(AJ7->AJ7_TAREFA)==Alltrim(SC7->C7_TAREFA)
					RecLock("AJ7",.F.)
					AJ7->AJ7_TAREFA:=_cAtuTar
					AJ7->(MsUnLock())
				Endif
				AJ7->(DbSkip())
			End
		Endif
		
		//=====================================================================================================================
		//Documento Entrada
		//=====================================================================================================================
		DbSelectArea("SD1")
		SD1->(DbOrderNickName("SD1_01"))//D1_FILIAL, D1_CODPSP, D1_TAREFA
		SD1->(DbGoTop())
		If SD1->(Dbseek(xFilial("SD1")+AvKey(SC7->C7_CODPSP,"D1_CODPSP")+AvKey(SC7->C7_TAREFA,"D1_TAREFA")))
			Do While SD1->(!Eof()) .And. Alltrim(SD1->D1_CODPSP)==Alltrim(SC7->C7_CODPSP) .And. Alltrim(SD1->D1_TAREFA)==Alltrim(SC7->C7_TAREFA)
				//=============================================================================================================
				//Projeto x Nota Fiscal Entrada
				//=============================================================================================================
				DbSelectArea("AFN")
				AFN->(DbSetOrder(2))//AFN_FILIAL+AFN_DOC+AFN_SERIE+AFN_FORNEC+AFN_LOJA+AFN_ITEM+AFN_PROJET+AFN_REVISA+AFN_TAREFA
				AFN->(DbGoTop())
				If AFN->(Dbseek(xFilial("AFN")+AvKey(SD1->D1_DOC,"AFN_DOC")+AvKey(SD1->D1_SERIE,"AFN_SERIE")+;
					AvKey(SD1->D1_FORNECE,"AFN_FORNEC")+AvKey(SD1->D1_LOJA,"AFN_LOJA")+;
					AvKey(SD1->D1_ITEM,"AFN_ITEM")+AvKey(SC7->C7_CODPSP,"AFN_PROJET")))
					Do While AFN->(!Eof()) .And. Alltrim(SD1->D1_DOC)==Alltrim(AFN->AFN_DOC) .And. Alltrim(SD1->D1_SERIE)==Alltrim(AFN->AFN_SERIE) ;
						.And. Alltrim(SD1->D1_FORNECE)==Alltrim(AFN->AFN_FORNEC) .And. Alltrim(SD1->D1_LOJA)==Alltrim(AFN->AFN_LOJA) ;
						.And. Alltrim(SD1->D1_ITEM)==Alltrim(AFN->AFN_ITEM) .And. Alltrim(SD1->D1_CODPSP)==Alltrim(AFN->AFN_PROJET)
						Reclock("AFN",.F.)
						If Alltrim(SD1->D1_TAREFA)==Alltrim(SC7->C7_TAREFA)
							AFN->AFN_TAREFA:=_cAtuTar
						Endif
						AFN->(MsUnlock())
						AFN->(DbSkip())
					End
				Endif
				//-------------------------------------------------------------------------------------------------------------
				RecLock("SD1",.F.)
				SD1->D1_TAREFA :=_cAtuTar
				SD1->D1_DESCTAR:=_cAtuDesc
				SD1->(MsUnLock())
				SD1->(DbSkip())
			End
		Endif
		RecLock("SC7",.F.)
		SC7->C7_TAREFA 	:=_cAtuTar
		SC7->C7_DESCTAR	:=_cAtuDesc
		SC7->C7_OBS		:=_cMsgOBS
		SC7->(MsUnLock())
		SC7->(DbSkip())
	End
Endif
RestArea(_aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} A004Troca
Funcao para retornar os valores da forma correta
@aParam
@aRetorno
@author
@since
@obs		somente podera ser usado com valores
@uso        GENERICO
/*/
//--------------------------------------------------------------------
Static Function A004Troca(cCampo)
Local aArea  := GetArea()
Local nCampo := 0

cCampo := StrTran(cCampo,".","")
cCampo := StrTran(cCampo,",",".")
nCampo := Val(cCampo)
RestArea(aArea)
Return nCampo

//-------------------------------------------------------------------
/*/
AjustaSX1
@Data            22/12/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Crias as perguntas e helps do Relatorio
@Tipo            SubRotina
@Autor           Marcos Kato
@Obs
/*/
//--------------------------------------------------------------------
Static Function AjustaSX1(_cPerg)
Local _aArea        := GetArea()
Local _cHelp		:= ""
Local _aRegs		:= {}
Local _aHelpPor		:= {}
Local _aHelpSpa		:= {}
Local _aHelpEng		:= {}
Local _lUpDate		:= .F.


/*/
����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
�           Grupo  Ordem Pergunta Portugues  Pergunta Espanhol    Pergunta Ingles       Variavel Tipo Tamanho Decimal Presel GSC Valid        Var01      Def01       DefSPA1     DefEng1    Cnt01 Var02 Def02       DefSpa2      DefEng2      Cnt02 Var03 Def03 DefSpa3 DefEng3 Cnt03 Var04 Def04 DefSpa4 DefEng4 Cnt04 Var05 Def05 DefSpa5 DefEng5 Cnt05 XF3 GrgSxg cPyme aHelpPor aHelpEng aHelpSpa cHelp      �
������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
/*/
_aHelpPor := _aHelpSpa := _aHelpEng := {"informe o projeto a ser",;
"importado"}
_cHelp:=_cPerg+"01"
PutSX1Help("P"+_cHelp,_aHelpPor,_aHelpEng,_aHelpSpa,_lUpDate)
Aadd(_aRegs,{_cPerg,"01","Projeto:"                   ,"Projeto:"             ,"Projeto:"              ,"MV_CH1","C",12, 0, 1, "C","NaoVazio()","MV_PAR01", "","","","","","","",""  ,"","","","",""   ,"","","","","","","","","","","","","AF8","S",_aHelpPor, _aHelpEng, _aHelpSpa, _cHelp})

ValidPerg(_aRegs,_cPerg,.T.)
RestArea(_aArea)
Return
