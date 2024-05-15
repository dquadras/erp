#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PMSXFUN.CH"
//INCLUDE "PMSICONS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"

#DEFINE DS_MODALFRAME   128
#DEFINE  CRLF CHR(13)+CHR(10)

//旼컴컴컴컴컴컴컴컴컴컴?
//?strutura da Planilha?
//읕컴컴컴컴컴컴컴컴컴컴?
#DEFINE TITULO 		";TITULO;"
#DEFINE TITULO2 	";T?ULO;"
#DEFINE SUBTITULO  ";SUB-TITULO;" 
#DEFINE SUBTITULO2 ";SUB-T?ULO;"
#DEFINE PRODUTO 	";PRODUTO;"

//旼컴컴컴컴컴컴컴컴컴커
//?olunas da Planilha.?
//읕컴컴컴컴컴컴컴컴컴켸
#DEFINE COL_RERI 	01
#DEFINE COL_CCUSTO 	02
#DEFINE COL_ESTRU	04
#DEFINE COL_LINK 	05
#DEFINE COL_DESC 	06
#DEFINE COL_V1	 	10
#DEFINE COL_V2	 	12
#DEFINE COL_META 	14

//旼컴컴컴?
//?izards?
//읕컴컴컴?
#define NOVA_ESTRUTURA 			1
#define ESTRUTURA_JA_EXISTE		2

//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA052(IMFA004)- Importacao(Upload) de Planilhas
de Orcamento.
@Data            06/11/2013
@Parametros      Nenhum
@Autor           David Ferreira Quadras
@Uso			 Grupo TV1.
@Obs			 Chamado pela Rotina - TV1PMS410.
/*/
//--------------------------------------------------------------------
User Function IMFA052()

Local aArea			:= GetArea()
Local aCampos		:={}
Local _cFaseImp 	:=""
Private cArquivo 	:=""
Private cProjAF8 	:=""
Private cRevAF8 	:=""
Private cDescAF8 	:=""
Private cUNNegAF8	:=""
Private cDUNegAF8	:=""
Private cTPNegAF8 	:=""
Private cCdCliAF8	:=""

AjustaSX1("IMFA052")
If Pergunte("IMFA052")
	cProjeto:= MV_PAR01
Else
	Alert("Importacao Cancelada")
	RestArea(aArea)	
	Return
EndIf

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
	If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjeto,"AF8_PROJET")))
	_cFaseImp := GetMV('ES_FASECAP')
	If !(Alltrim(AF8->AF8_FASE) $ _cFaseImp) // Projeto em fase de Orcamento.
		Aviso("Alterar Fase","Importacao apenas pode ser efetuado na(s) Fase(s)"+_cFaseImp+ ". Tente novamente!",{"Ok"},2)
	Else
		cProjAF8	:= AF8->AF8_PROJET
		cRevAF8		:= AF8->AF8_REVISA
		cDescAF8	:= AF8->AF8_DESCRI
		cUNNegAF8	:= Alltrim(AF8->AF8_X_TIPO)
		cTPNegAF8 	:= Alltrim(AF8->AF8_TPPRJ)
		cCdCliAF8	:= Alltrim(AF8->AF8_CLIENT+AF8->AF8_LOJA)
		cDUNegAF8	:= ""

		DbSelectArea("SZ4")
		SZ4->(DbSetOrder(1))// Z4_FILIAL, Z4_X_COD
		SZ4->(DbGoTop())
		If SZ4->(DbSeek(xFilial("SZ4")+Avkey(AF8->AF8_X_TIPO,"Z4_X_COD")))
			cDUNegAF8 := Alltrim(AF8->AF8_X_TIPO)+"-"+Alltrim(SZ4->Z4_X_DESC)
		Endif	
		
		DbSelectArea("SZL")
		SZL->(DbSetOrder(1))// ZL_FILIAL, ZL_CODIGO
		SZL->(DbGoTop())	
		If SZL->(DbSeek(xFilial("SZL")+Avkey(AF8->AF8_TPPRJ,"ZL_CODIGO")))
			cTPNegAF8	+="-"+Alltrim(SZL->ZL_TIPPROJ)	
		Endif	
	
 		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))// A1_FILIAL, A1_COD
		SA1->(DbGoTop())
		If SA1->(DbSeek(xFilial("SZL")+Avkey(cCdCliAF8,"A1_COD")))
			cCdCliAF8	+="-"+Alltrim(SA1->A1_NOME)
		Endif	

		//Arquivo de Configuracao de Colunas
		A052CfgCols(@aCampos)

		//Planilha de acordo com o Arquivo de Configuracao
		A052Browse(aCampos)
		
		If Select("XXX") > 0 
			DbSelectArea("XXX")
			XXX->(DbCloseArea())
		Endif

	Endif
Else
	Aviso("ATEN플O","PSP n? Localizado!",{"Ok"},2)
Endif	
RestArea(aArea)
Return(Nil)
//-----------------------------------------------------------------------------
/*/A052CfgCols - Monta ou Cria Arquivo que ser?utilizado para 
visualizacao do Projeto.
@Data            06/11/2013
@Parametros      aCampos - Array com as colunas a serem montadas na Browse.
@Autor           Fernando.
@Obs             Abre o arquivo de configuracoes, se nao encontrar cria o arq.
/*/
//-----------------------------------------------------------------------------
Static Function A052CfgCols(aCampos)

Local aArea		:= GetArea()
Local cArqCFG   := ""
Local cCmpCFG   := ""
Local cVerCFG   := ""
Local cPswCFG   := ""
Local cDescCFG  := ""  
Local cCmpNOT	:= "_TVTEV#_CUSTO#_METOT"
Local nArqCFG   := 0

//Prepara campos para a visualizacao em formato planilha do projeto, a partir do arquivo PROFILE\RPMSC01.PLN
aAdd(aCampos,"_CHAVE") // EDT ou Tarefa
aAdd(aCampos,"_DESCRI")

cArqCFG:=  "IMFA052"+__cUserId+".PLN"

//Criacao do Arquivo PLN
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
				cCmpCFG := Substr(cCmpCFG,AT("#",cCmpCFG)+1,Len(cCmpCFG)-AT("#",cCmpCFG))
			Else
				cCmpCFG := ""
			Endif
		End
	Endif
Else
	Aviso("Falha na Abertura.","Erro na abertura do arquivo "+cArqCFG+". Verifique a existencia do arquivo selecionado na pasta %START PATH%\profile\",{"Ok"},2)
EndIf
RestArea(aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/A004Plan - Montagem do Browse 
@Data            08/10/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Fernando
@Obs             
/*/
//--------------------------------------------------------------------
Static Function A052Browse(aCampos)
Local aArea     := 	GetArea()
Local cChave    := 	""
Local aArquivo	:= {}
Local aPlanilha := {}
Local aObjects 	:= {}
Local aPosObj 	:= {}                
Local aSize 	:= MsAdvSize(.T.)
Local cLyHd01	:= "HEADER01"
Local cLy01Col1	:= "HD01_Win01"
Local cLy01Col2	:= "HD01_Win02"
Local nX        := 	0
Local nPosHd1   := 	0
Local _lRepr	:= .F.
Local oDlgBrw
Local oBrowse       
Local oFont                      
Local oBarTop
Local oSay01
Local oSay02
Local oSay03
Local oSay05
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
aInfo 	:= {aSize[1], aSize[2], aSize[3], aSize[4], 3, 3}
aPosObj := MsObjSize( aInfo, aObjects)
oDlgBrw	:= TDialog():New( aSize[7], 000, aSize[6]+30, aSize[5], "Vis? geral do PSP",,,,,,,,oMainWnd,.T.)
oFont	:= TFont():New('Courier new',,20,,.T.,,,,.T.,.F.)

oLayer:Init(oDlgBrw, .t.)
oLayer:AddColumn(cLyHd01,100, .T.) // Cria colunas do Layer.

// Adiciona Janelas as Colunas
oLayer:addWindow(cLyHd01, cLy01Col1, 'PSP'			, 25, .t., .f., {|| .t.},,{||.t.} )
oLayer:addWindow(cLyHd01, cLy01Col2, 'Dados do PSP'	, 60, .t., .f., {|| .t.},,{||.t.} )

//Geracao dos Dados da Planilha
aPlanilha:=A004GerPlan()

//Montagem dos dados da Planilha na Estrutura
A004MontPlan(aPlanilha)

nPosHD1 := (oLayer:ALINES[1]:ACOLLUMNS[1]:NWIDTH/100)/2

//旼컴컴컴컴컴컴컴컴??
//?ados do Cabecalho?
//읕컴컴컴컴컴컴컴컴??
@ nPosHD1,nPosHD1  		Say oSay01 ;
						Prompt "PSP:";
						Size nPosHD1*4 ,nPosHD1*1.5	;
						COLOR CLR_BLUE;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
						
@ nPosHD1,nPosHD1*6 	MsGet  cProjAF8  				;
						PICTURE "@!";
				 		Size nPosHD1*6 ,nPosHD1;
				 		WHEN .F.;
				 		PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
				 		
@ nPosHD1,nPosHD1*13	Say oSay02 Prompt "Retranca:";
						Size nPosHD1*4 ,nPosHD1*1.5;
						COLOR CLR_BLUE;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*18 	MsGet  cDescAF8;
						PICTURE "@!";
						Size nPosHD1*20,nPosHD1;
						WHEN .F.;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)


@ nPosHD1,nPosHD1*40	Say oSay03;
						Prompt "Unid.Neg.:";
						Size nPosHD1*4 ,nPosHD1*1.5;
						COLOR CLR_BLUE;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1,nPosHD1*46 	MsGet  cDUNegAF8;
						PICTURE "@!";
						Size nPosHD1*20,nPosHD1;
						WHEN .F.;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)

@ nPosHD1*4,nPosHD1		Say oSay04;
						Prompt "Tipo Neg.:";
						Size nPosHD1*4 ,nPosHD1*1.5;
						COLOR CLR_BLUE;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1*6	MsGet  cTPNegAF8;
						PICTURE "@!";
						Size nPosHD1*32,nPosHD1;
						WHEN .F.;
						PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)

@ nPosHD1*4,nPosHD1*40	Say oSay05 Prompt "Cliente:"						Size nPosHD1*4 ,nPosHD1*1.5	COLOR CLR_BLUE		   	PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)
@ nPosHD1*4,nPosHD1*46 	MsGet  cCdCliAF8		 		PICTURE "@!" 		Size nPosHD1*20,nPosHD1 	WHEN .F. 				PIXEL OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)


//旼컴컴??
//?otoes?
//읕컴컴??
DEFINE BUTTONBAR oBarTop;
				 size 65,25;
				 3D BOTTOM ;
				 OF oLayer:GetWinPanel(cLyHd01,cLy01Col1)

DEFINE BUTTON 	RESOURCE "FOLDER6" ;
			  	OF oBarTop ;
			  	ACTION( Eval({ || Iif( A052Wizard(), Processa({|| _lProc := .t., A052Refresh(@oBrowse)  },"Aguarde... Atualizando Estrutura do PSP..."),oBrowse:Refresh())}));  //ACTION( Eval({ || Iif( A052Wizard(), A052Refresh(@oBrowse),oBrowse:Refresh())}));
			  	TOOLTIP "" //Importar
	
DEFINE BUTTON 	RESOURCE "PMSRRFSH";
			  	OF oBarTop ACTION ( Eval({ || A052Refresh(@oBrowse),oBrowse:Refresh() }) );  // MsAguarde({ || A052Refresh(@oBrowse),oBrowse:Refresh() },"Aguarde! Atualizando Interface..."));
			  	TOOLTIP ""//"Atualizar"

If FindFunction("U_L001BRWPED") 
	DEFINE BUTTON 	RESOURCE "CAR_02_ADD_48";
					OF oBarTop ;
					ACTION( MsAguarde({ ||  u_L001BrwPed(cProjAF8) },"Aguarde! Consultando Pedido de Compras..."))  TOOLTIP "" //"Visualizar Pedido de Compras"
EndIf		

DEFINE BUTTON 	RESOURCE "cancel_ocean";
				OF oBarTop ;
				ACTION(oDlgBrw:End()) 	TOOLTIP  "" //""Sair

//旼컴컴컴컴컴컴컴컴??
//?ados da Planilha ?
//읕컴컴컴컴컴컴컴컴??
dbSelectArea("XXX")
XXX->(dbGotop())
nAlias	:= Select("XXX")

//TCBrowse(): New ( [ nRow], [ nCol], [ nWidth], [ nHeight], [ bLine], [ aHeaders], [ aColSizes], [ oWnd], [ cField], [ uValue1], [ uValue2], [ bChange], [ bLDblClick], [ bRClick], [ oFont], [ oCursor], [ nClrFore], [ nClrBack], [ cMsg], [ uParam20], [ cAlias], [ lPixel], [ bWhen], [ uParam24], [ bValid], [ lHScroll], [ lVScroll] ) 
oBrowse := TcBrowse():New( aPosObj[2][1], aPosObj[2][2] ,  aPosObj[2][3], aPosObj[2][4], , , , oLayer:GetWinPanel(cLyHd01,cLy01Col2), ,,,,/*{|| (aPlanilha:=A004AtuPlan(aPlanilha),A004MontPlan(aPlanilha),oBrowse:Refresh()) }*/,,oFont,,,,, .F.,"XXX", .T.,, .F., ,.T.,.T. )
oBrowse:AddColumn( TCColumn():New( "",{ || If(XXX->XXX_CTRNIV=="-",oMenos,If(XXX->XXX_CTRNIV=="+",oMais,If(XXX->XXX_CTRNIV=="*",oAll,If(XXX->XXX_CTRNIV=="!",oCmp,Nil) )))},,,,"RIGHT" , 6, .T., .F.,,,, .T., ))
oBrowse:AddColumn( TCColumn():New( "",{ || PmsRetRes(XXX->XXX_ALIAS,XXX->XXX_RECNO ) },,,, "LEFT", 15, .T., .F.,,,, .T., ))//BITMAP
//oBrowse:SetBlkBackColor({ || If(!Empty(XXX->XXX_CTRNIV),CLR_LIGHTGRAY,CLR_WHITE)})
oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

For nX := 1 to Len(aAuxCps)
	If aAuxCps[nX]=="_CHAVE"
		cChave:="AFC_EDT"//Pelo padrao o campo EDT e Tarefa possuir o mesmo tamanho. 
	Else
		cChave:="AFC"+aAuxCps[nX]
	Endif        
  	DbSelectArea("SX3")                                           
	SX3->(DbSetOrder(2))
	If SX3->(DbSeek(cChave))
		If cChave=="AFC_EDT"
			oBrowse:AddColumn( TCColumn():New("PSP", FieldWBlock( "XXX_CHAVE", nAlias ),Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),{ || IF(!Empty(XXX->XXX_CTRNIV),oBrowse:OFONT:BOLD:=.T.,obrowse:OFONT:BOLD:=.F.)},, Iif(SX3->X3_TIPO=="N","RIGHT","LEFT"), SX3->X3_TAMANHO+20, .F., .F.,,,, .F., ) )
		Else                
			oBrowse:AddColumn( TCColumn():New(SX3->X3_TITULO, FieldWBlock( "XXX"+Substr(cChave,4,Len(cChave)), nAlias ),Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),{ || IF(!Empty(XXX->XXX_CTRNIV),oBrowse:OFONT:BOLD:=.T.,obrowse:OFONT:BOLD:=.F.)},, Iif(SX3->X3_TIPO=="N","RIGHT","LEFT"), SX3->X3_TAMANHO+20, .F., .F.,,,, .F., ) )
  		EndIf
	EndIf
Next
oBrowse:AddColumn( TCColumn():New("Total Venda"		, FieldWBlock("XXX_TVTEV" , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Custo Orcado"	, FieldWBlock("XXX_ORCTOT", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Meta Total"		, FieldWBlock("XXX_X_META", nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Preco Venda"		, FieldWBlock("XXX_TVPVI" , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )
oBrowse:AddColumn( TCColumn():New("Reembolso"		, FieldWBlock("XXX_TVRE"  , nAlias )		,"@E 999,999,999.99",,, "RIGHT", 34, .F., .F.,,,, .F., ) )				
oBrowse:AddColumn( TCColumn():New( "",{|| " " },,,, "LEFT", 5, .T., .F.,,,, .T., ))
oBrowse:Refresh()

ACTIVATE MSDIALOG oDlgBrw CENTERED
RestArea(aArea)

Return(Nil)

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

aStruct :={}
_nMeta	:=0

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjAF8,"AF8_PROJET")))

	DbSelectArea("AFC")
	AFC->(DbSetOrder(1))
	AFC->(DbGoTop())
	If AFC->(DbSeek(xFilial("AFC")+AvKey(AF8->AF8_PROJET,"AFC_PROJET")+AvKey(AF8->AF8_REVISA,"AFC_REVISA")+AvKey(AF8->AF8_PROJET,"AFC_EDT")))  

		nVlrSC7:= 0
		nVlrSD1:= 0
		nVlrCor:= 0		
		_nMeta := AFC->AFC_X_META
					
		_cQuery	:= ""
		_cQuery	+= "	SELECT "
		_cQuery += "		AFC_PROJET, "
		_cQuery += "		AFC_REVISA, "
		_cQuery += "		AFC_EDT, "
		_cQuery += "		AFC_EDTPAI, "
		_cQuery += "		AFC_NIVEL, "
		_cQuery += "		AFC_TVPVI, "
		_cQuery += "		AFC_TVRE, "
		_cQuery += "		AFC_CUSTPV, "
		_cQuery += "		AFC_CUSTRE, "
		_cQuery += "		AFC_TVPVC, "
		_cQuery += "		AFC_X_META, "
		_cQuery	+= "		AFC_X_COEF, "
		_cQuery += "		R_E_C_N_O_ "
		_cQuery	+=" FROM "+RetSQlName("AFC")+" (NOLOCK) AFC "
		_cQuery	+=" WHERE "
		_cQuery += "	AFC.D_E_L_E_T_ ='' "
		_cQuery	+=" AND AFC.AFC_PROJET = '"+AFC->AFC_PROJET+"'"
		_cQuery	+=" AND AFC.AFC_EDTPAI <>'"+AFC->AFC_PROJET+"'"
		_cQuery	+=" AND AFC.AFC_EDT NOT IN('1','2') "
		_cQuery	+=" AND AFC.AFC_REVISA = '"+AFC->AFC_REVISA+"'"
		_cQuery	+=" ORDER BY "
		_cQuery	+=" 		AFC.AFC_EDT"

		TcQuery _cQuery  NEW ALIAS "TRBPAI"

		DbSelectArea("TRBPAI")
		If TRBPAI->(!EOF())
			Do While TRBPAI->(!EOF())

				nVlrMet := TRBPAI->AFC_X_META
				nVlrSC7 := 0
				nVlrSD1 := 0
				nVlrCor := 0		
				
				If aScan(aStruct, {|a| a[4] == TRBPAI->R_E_C_N_O_ }) == 0
				
					aAdd(aStruct, {"EDT",;
									"-",;
									"A",;
									TRBPAI->R_E_C_N_O_	,;
									TRBPAI->AFC_EDT		,;
									TRBPAI->AFC_EDTPAI	,;
									Val(TRBPAI->AFC_NIVEL),;
									TRBPAI->AFC_TVPVI+TRBPAI->AFC_TVRE,TRBPAI->AFC_CUSTPV+TRBPAI->AFC_CUSTRE,;
									TRBPAI->AFC_TVPVC	,;
									_nMeta				,;
									TRBPAI->AFC_X_COEF	,;
									nVlrSC7,;
									nVlrSD1,;
									nVlrCor,;
									TRBPAI->AFC_CUSTPV	,;
									TRBPAI->AFC_TVPVI	,;
									TRBPAI->AFC_CUSTRE	,;
									TRBPAI->AFC_TVRE;
									})
						
					A004AddPlan(TRBPAI->AFC_PROJET,TRBPAI->AFC_REVISA,TRBPAI->AFC_EDT)				
				EndIf	
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
		If nPos > 0
			If 	aStruct[nPos][1] == "EDT" 
				aStruct[nPos][13] 	+=aCopia[nX][13]//nVlrSC7
				aStruct[nPos][14]	+=aCopia[nX][14]//nVlrSD1
				aStruct[nPos][15]	+=aCopia[nX][15]//nVlrCor
			Endif
		Endif
		nPos:= Ascan(aCopia,{|x| Alltrim(x[5]) == Alltrim(aCopia[nX][6])})
		If nPos>0 
			If 	aCopia[nPos][1] == "EDT"
				aCopia[nPos][13] 	+=aCopia[nX][13]//nVlrSC7
				aCopia[nPos][14]	+=aCopia[nX][14]//nVlrSD1
				aCopia[nPos][15]	+=aCopia[nX][15]//nVlrCor
			Endif
		Endif 
	Endif	
Next
RestArea(aArea)
Return(aStruct)
//-------------------------------------------------------------------
/*/A004AddPlan - Funcao recursiva na montagem da estrutura do projeto.
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

		aAdd(aStruct, {"EDT",;
						"-",;
						"A",;
						AFC->(Recno()),;
						cChave,;
						cEdtPAI,;
						nNivel,;
						nVlrVda,;
						nVlrOrc,;
						nCoefOrc,;
						nVlrMet,;
						nCoefMet,;
						nVlrSC7,;
						nVlrSD1,;
						nVlrCor,;
						nCustPV,;
						nPrecPV,;
						nCustRE,;
						nPrecRE})

		A004AddPlan(AFC->AFC_PROJET,AFC->AFC_REVISA,AFC->AFC_EDT)				

		AFC->(DbSkip())				
    EndDo
Else
	
	DbSelectArea("AF9")
	AF9->(DbSetOrder(2))
	If AF9->(DbSeek(xFilial("AF9")+AvKey(cProj,"AF9_PROJET")+AvKey(cRev,"AF9_REVISA")+AvKey(cEdt,"AF9_EDTPAI")))  
		Do While AF9->(!Eof()) .And. Alltrim(cProj)==Alltrim(AF9->AF9_PROJET) .And. Alltrim(cRev)==Alltrim(AF9->AF9_REVISA) .And. Alltrim(cEdt)==Alltrim(AF9->AF9_EDTPAI)
			nVlrSC7:=0
			nVlrSD1:=0
			nVlrOrc:=0

			//==========================================
			//Calculos 		
			//==========================================
			cChave  :=AF9->AF9_TAREFA
			cEdtPAI	:=AF9->AF9_EDTPAI
			nNivel	:=Val(AF9->AF9_NIVEL)
			nVlrVda	:=AF9->AF9_TVPVI+AF9->AF9_TVRE
			nVlrOrc	:=AF9->AF9_CUSTPV+AF9->AF9_CUSTRE
			nCoefOrc:=AF9->AF9_TVPVC
			nVlrMet	:=Iif(AF9->AF9_X_META==0, AF9->AF9_METTOT, AF9->AF9_X_META)
			nCoefMet:=AF9->AF9_X_COEF
			nCustPV :=AF9->AF9_CUSTPV
			nPrecPV :=AF9->AF9_TVPVI
			nCustRE :=AF9->AF9_CUSTRE
			nPrecRE :=AF9->AF9_TVRE   
			If FindFunction("U_L001TOPC") 
				nVlrSC7 := u_L001TotPC(ALLTRIM(AF9->AF9_PROJET),ALLTRIM(AF9->AF9_TAREFA))
			Endif
			If FindFunction("U_L001TOREAL")
				nVlrSD1 := u_L001TotReal(ALLTRIM(AF9->AF9_PROJET),ALLTRIM(AF9->AF9_TAREFA))
			Endif
			If FindFunction("U_L001VLRCOR")
				nVlrCor := u_L001VlrCor(nVlrOrc,nVlrMet,nVlrSC7,nVlrSD1)
			Endif	
			aAdd(aStruct, {	"TAR",;
							"",;
							"A",;
							AF9->(Recno()),;
							cChave,;
							cEdtPAI,;
							nNivel,;
							nVlrVda,;
							nVlrOrc,;
							nCoefOrc,;
							nVlrMet,;
							nCoefMet,;
							nVlrSC7,;
							nVlrSD1,;
							nVlrCor,;
							nCustPV,;
							nPrecPV,;
							nCustRE,;
							nPrecRE})
			AF9->(DbSkip())	
		EndDo
	Endif
Endif    

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/A004MontPlan - Monta Browse de Estrutura do Projeto 
@Data            06/11/2013
@Parametros      aDadGer - Array com a Estrutura do Projeto.
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Fernando.
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
						Iif(cChave=="AFC_EDT","Codigo",SX3->X3_TITULO),;
						"XXX"+Substr(SX3->X3_CAMPO,4,Len(SX3->X3_CAMPO)-1),;
						Iif(SX3->X3_TIPO=="N","@E 999,999,999.99",AllTrim(SX3->X3_PICTURE)),;
						SX3->X3_TAMANHO+20,;
						SX3->X3_DECIMAL,;
						"",;
						SX3->X3_USADO,;
						SX3->X3_TIPO,;
						"XXX",;
						SX3->X3_CONTEXT})

		aAdd(aArquivo,{;
						Iif(cChave=="AFC_EDT","XXX_CHAVE","XXX"+Substr(SX3->X3_CAMPO,4,Len(SX3->X3_CAMPO))),;
						SX3->X3_TIPO,;
						SX3->X3_TAMANHO+20,;
						SX3->X3_DECIMAL;
					  })
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
/*/A052Refresh - Refresh na tela.
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Fernando.
/*/
//--------------------------------------------------------------------
Static Function A052Refresh(oBrwAtu)
Local _aArea	:=GetArea()
Local _aPlanRefr:={}

DbSelectArea("AF8")
AF8->(DbSetOrder(1))
If AF8->(DbSeek(xFilial("AF8")+AvKey(cProjAF8,"AF8_PROJET")))
	Processa({|| _lProc := .t., u_L001PrjAT(AF8->AF8_PROJET,AF8->AF8_REVISA)  },"Aguarde... Recalculando PSP...")	
Endif
_aPlanRefr:=A004GerPlan()
A004MontPlan(_aPlanRefr)

RestArea(_aArea)
Return


//-------------------------------------------------------------------
/*/ A052Revisa - Cria, Deleta revisoes.
@Data            19/11/2013
@Parametros      Nenhum
@Retorno         Nenhum
@Autor           Fernando
/*/
//--------------------------------------------------------------------


Static Function A052Revisa(_cPrjImp,_cRevNew,_cEdtImp, _cMsgImp)

Local _cQryAFC := ""
Local _cQryAFA := ""
Local _cQryAF9 := ""

If AF8->AF8_STATUS == '2' // Projeto em Revisao
	_cMsgImp   :="Nova revis? devido a importa豫o do arquivo Excel no dia "+DtoC(dDataBase)+" as "+Time()+" pelo Usuario "+Alltrim(UsrRetName(__cUserID))+"."+Chr(13)+Chr(10)
	DbSelectArea("AFE")
	AFE->(DbSetOrder(1))
	AFE->(DbGoTop())
	If AFE->(DbSeek(xFilial("AFE")+AvKey(AF8->AF8_PROJET,"AFE_PROJET")+AvKey(AF8->AF8_REVISA,"AFE_REVISA")))
		RecLock("AFE",.F.)
		AFE->AFE_DATAF	:= MsDate()
		AFE->AFE_HORAF	:= Time()
		AFE->AFE_USERF	:= RetCodUsr()
		AFE->AFE_CODMEM := ALLTRIM(AFE->AFE_CODMEM)+Chr(13)+Chr(10)+"Iniciando"+_cMsgImp //Campo Memo Real
		AFE->(MsUnLock())
	Endif
Endif

MaPmsRevisa(AF8->(Recno()), 1, AF8->AF8_REVISA, _cRevNew) // Cria nova revisao, baseando nos historicos anteriores.

// Cria historico para nova revisao.
DbSelectArea("AFE")
AFE->(DbSetOrder(1))
AFE->(DbGoTop())
If !AFE->(DbSeek(xFilial("AFE")+AvKey(_cPrjImp,"AFE_PROJET")+AvKey(_cRevNew,"AFE_REVISA")))
	RecLock("AFE",.T.)
	AFE->AFE_FILIAL	:= xFilial("AFE")
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
	AFE->AFE_CODMEM := ALLTRIM(AFE->AFE_CODMEM)+Chr(13)+Chr(10)+"Finalizando"+_cMsgImp // Campo Memo Real
	If AFE->(FieldPos("AFE_FASE")) > 0  
		AFE->AFE_FASE := AF8->AF8_FASE
		If AFE->(FieldPos("AFE_FASEOR")) > 0
			AFE->AFE_FASEOR := AF8->AF8_FASE
		EndIf	
	EndIf
	AFE->(MsUnLock())
Endif

//Exclusao das EDT,Tarefas e Recursos da Tarefa da EDT selecionada.
_cQryAFC := " 	DELETE 	FROM  "+RetSqlName("AFC")
_cQryAFC += " 	WHERE 	AFC_PROJET ='"+_cPrjImp+"'"

////_cQryAFC += "  		AND AFC_EDT >= '"+Alltrim(_cEdtImp)+"'"
_cQryAFC += "  		AND SUBSTRING(AFC_EDT,1,2) = '"+Alltrim(_cEdtImp)+"."+"'"
_cQryAFC += "  		AND AFC_REVISA ='"+_cRevNew+"' "
_cQryAFC += "  		AND D_E_L_E_T_ =''"
If (TCSQLExec(_cQryAFC) < 0)
    Return MsgStop("Erro gerado ao atualizar estrutura do Projeto: TCSQLError() " + TCSQLError())
EndIf

_cQryAF9 := " 	DELETE 	FROM "+RetSqlName("AF9")
_cQryAF9 += " 	WHERE 	AF9_PROJET ='"+_cPrjImp+"' "
_cQryAF9 += "  		AND AF9_REVISA ='"+_cRevNew+"' "
////_cQryAF9 += "  		AND SUBSTRING(AF9_TAREFA,1,1) >= '"+Alltrim(_cEdtImp)+"'"
_cQryAF9 += "  		AND SUBSTRING(AF9_TAREFA,1,2) = '"+Alltrim(_cEdtImp)+".'"
_cQryAF9 += "  		AND D_E_L_E_T_ ='' "
If (TCSQLExec(_cQryAF9) < 0)
    Return MsgStop("Erro gerado ao atualizar estrutura do Projeto: TCSQLError() " + TCSQLError())
EndIf

_cQryAFA :=" 	DELETE 	FROM "+RetSqlName("AFA")
_cQryAFA +=" 	WHERE 	AFA_PROJET 	='"+_cPrjImp+"' "
_cQryAFA +="  		AND AFA_REVISA  ='"+_cRevNew+"' "
////_cQryAFA +="  		AND SUBSTRING(AFA_TAREFA,1,1) >= '"+Alltrim(_cEdtImp)+"'"
_cQryAFA +="  		AND SUBSTRING(AFA_TAREFA,1,2) = '"+Alltrim(_cEdtImp)+".'"
_cQryAFA +="  		AND D_E_L_E_T_	='' "
If (TCSQLExec(_cQryAFA) < 0)
    Return MsgStop("Erro gerado ao atualizar estrutura do Projeto: TCSQLError() " + TCSQLError())
EndIf
Return(Nil)


//-------------------------------------------------------------------
/*/ A052RetF3
Funcao para retornar o codigo do produto
@author
@since
/*/
//--------------------------------------------------------------------
Static Function A052RetF3(_aInfo)
Local _aArea      := GetArea()
Local _cCodPrd	  := Space(25)
Local _cCodPrd1	  := Space(25)
Local cEdit2	  := Space(25)
Local nOpc        := 0
Local nTamanho	  := TAMSX3("B1_COD")[1]
Local _oDescTar   := Nil
Local _oCodPrd	  := Nil
Local oEdit2      := Nil
Local _oDlgPrd	  := Nil


// A052RetF3({"Gestor n? encontrado no PSP:" +Alltrim(_cPrjImp), "PSP:"+Alltrim(_cPrjImp), "Informe o Gestor..:", "SZ9", "SZ9"})

DbSelectArea(_aInfo[04])
DEFINE MSDIALOG _oDlgPrd TITLE _aInfo[01] FROM 258,231 TO 414,683 PIXEL  Style DS_MODALFRAME // Cria Dialog sem o bot? de Fechar.

	@ 007,006 Say _aInfo[02];
			  Size 550,008 ;
			  PIXEL OF _oDlgPrd

	@ 020,006 Say _aInfo[03];
			  Size 46,008;
			  PIXEL OF _oDlgPrd

	@ 034,006 MsGet _oCodPrd;
			  Var _cCodPrd1;
			  F3 _aInfo[05];
			  Valid ExistCpo(_aInfo[04],alltrim(_cCodPrd1));
			  Size 068,009  PIXEL OF _oDlgPrd

	@ 034,080 MsGet _oDescTar;
			  Var _cCodPrd;
			  when .F.;
			  Size 087,009  PIXEL OF _oDlgPrd
			  			  
	@ 047,174 Button "Confirma";
			  Size 037,012;
			  PIXEL OF _oDlgPrd;
			  ACTION If(ExistCpo(_aInfo[04],_cCodPrd1),(_nOpc:=1,_oDlgPrd:End()),.F.)

	_oDlgPrd:lEscClose := .f.

ACTIVATE MSDIALOG _oDlgPrd CENTERED

RestArea(_aArea)
Return _cCodPrd



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
Return(nCampo)

//-------------------------------------------------------------------
/*/AjustaSX1 - grupo de Perguntas.
@Data            22/12/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Crias as perguntas e helps do Relatorio 
@Autor           Marcos Kato
/*/
//--------------------------------------------------------------------
Static Function AjustaSX1(_cPerg)
Local _aArea        := GetArea()
Local _cHelp		:= _cPerg+"01"
Local _aRegs		:= {}
Local _aHelpPor		:= {}
Local _aHelpSpa		:= {}
Local _aHelpEng		:= {}
Local _lUpDate		:= .F.

_aHelpPor := _aHelpSpa := _aHelpEng := {"informe o projeto a ser","importado"}

//             Grupo  |Ordem |Pergunta Portugues  |Pergunta Espanhol    |Pergunta Ingles       |Variavel |Tipo |Tamanho |Decimal |Presel |GSC |Valid        |Var01      |Def01       |DefSPA1     |DefEng1    |Cnt01 |Var02 |Def02       |DefSpa2      |DefEng2      |Cnt02 |Var03 |Def03 |DefSpa3 |DefEng3 |Cnt03 |Var04 |Def04 |DefSpa4 |DefEng4 |Cnt04 |Var05 |Def05 |DefSpa5 |DefEng5 |Cnt05 |XF3 |GrgSxg |cPyme |aHelpPor |aHelpEng |aHelpSpa |cHelp      ?
PutSX1Help("P"+_cHelp,_aHelpPor,_aHelpEng,_aHelpSpa,_lUpDate)
Aadd(_aRegs,{_cPerg,"01","Projeto:"                   ,"Projeto:"             ,"Projeto:"              ,"MV_CH1","C",12, 0, 1, "C","NaoVazio()","MV_PAR01", "","","","","","","",""  ,"","","","",""   ,"","","","","","","","","","","","","AF8","S",_aHelpPor, _aHelpEng, _aHelpSpa, _cHelp})
ValidPerg(_aRegs,_cPerg,.T.)
RestArea(_aArea)
Return(Nil)


//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA052(IMFA004)- Importacao(Upload) de Planilhas
de Orcamento.
@Data            06/11/2013
@Parametros      Nenhum
@Autor           Fernando(Imfoc).
@Uso			 Grupo TV1.
@Obs			 Chamado pela Rotina - TV1PMS410.
/*/
//--------------------------------------------------------------------
Static Function A052Wizard()

Local oWizard 	:= Nil
Local nA		:= 0
Local cPergEnt	:= "selcapo"  
Local cPergCont	:= "selcapo"  
Local cLockBy	:= "PSP_"
Local n1 		:= 015
Local n2 		:= 005
Local n3 		:= 0105
Local n4 		:= 160
Local _lProc	:= .f.

//旼컴컴컴컴컴컴컴컴컴?
//?bjetos do Wizard 1?
//읕컴컴컴컴컴컴컴컴컴?
Local oGrp2 	:= Nil
Local nRadSel	:= 1
Local aPRange	:= {}
Local aRetRange	:= {}
Local aPContab	:= {}
Local aRetContab:= {}
Local _cCodPSP 	:= ""
Private oRadio	:= Nil 

//旼컴컴컴컴컴컴컴컴컴컴?
//?izard 1: Introdu豫o ?
//읕컴컴컴컴컴컴컴컴컴컴?
DEFINE WIZARD oWizard TITLE "UpLoad - Planilha CAPO";
       HEADER 'UpLoad:';  
       MESSAGE 'Planilha modelo CAPO';
       TEXT "Esta rotina tem o objetivo"+;
       " Importar os dados informados por meio da Planilha CAPO"+CRLF+" em formato CSV(Ponto e Virgula)."+;
       	 	" Antes de iniciar este processo, certifique-se de que a Planilha: "+CRLF+CRLF+;
       	 	" 1. Esteja no formato CSV(Caracteres Separados por v?ula) Formato MS-DOS"+CRLF+CRLF+;
       	 	" 2. As configuracoes regionais do windows utilizam '.' para Decimais;"+CRLF+CRLF+;
       	 	" 3. Contenha o c?igo do PSP nas primeiras linhas;"+CRLF+CRLF+;
       	 	" 4. Contenha o c?igo ou descri豫o do Centro de Custo; "+CRLF+CRLF+;
       	 	" 5. Confira se as colunas est? preenchidas corretamente: Item(Link Excel) Custo(V1), Venda(V2) e Meta preenchidos ; "+CRLF+CRLF+;
       	 	" 6. Para encerrar o processamento da Planilha, contenham o texto 'Fim Planilha' ";
       NEXT {||.T.} ;
       FINISH {||.T.} ;
       PANEL
  
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//?izard 2: Tipos de Sele豫o: Range  ?
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?   
  CREATE PANEL oWizard;
          HEADER "Sele豫o" ;	//"Sele豫o dos Registros" 
          MESSAGE  "Selecione a Planilha" ;	//"Selecione os registros" 
          BACK {|| .T. };
          NEXT {|| .t. } ;
          FINISH {|| Iif( a052tudoOk(), _lProc:=.t. , .f.) };
          PANEL
	
	//Parambox para Diretorio do Arquivo.                           
	aAdd(aPRange,{6,;  					     // 6 - File
				  "Local da Planilha?",;		 // [2] : Descri豫o 
				  Space(150),;				 // [3] : String contendo o inicializador do campo	
				  "@!",;                     // [4] : String contendo a Picture do campo
				  "File(MV_PAR01)",;         // [5] : String contendo a valida豫o
				  ""	,;                   // [6] : String contendo a valida豫o When
				  150	,;					 // [7] : Tamanho do MsGet 
				  .t.	,;   				 // [8] : Flag .T./.F. Par?etro Obrigat?io ?
				  "Arquivos .CSV |*.CSV",;	 // [9] : Texto contendo os tipos de arquivo Ex.: "Arquivos .CSV |*.CSV"
				  "",; 						// [10]: Diret?io inicial do cGetFile
				  GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) // [11]: PARAMETROS do cGETFILE

	For nA := 1 To Len(aPRange)
		aAdd(aRetRange,aPRange[nA][3])
		&("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA] := ParamLoad(cPergEnt,aPRange,nA,aPRange[nA][3])	
	Next nA

	ParamBox(aPRange,"Par?etros",@aRetRange,,,,,,oWizard:GetPanel(02))//"Par?etros..."   

	// Opcao de UpLoad.
	oGrp2 := TGroup():New(n1:=030,n2,n3,n4,"Modo de importa豫o?",oWizard:GetPanel(02),,,.T.)
  	oRadio := TRadMenu():New(n1+015,n2+010,{'Nova Planilha?','Estrutura j?existente?'},bSetGet(nRadSel),oWizard:GetPanel(02),,,,,,,,070,060,,,,.T.) //"Range"##"Por entidade"
	oRadio:nOption := 1 	

oWizard:Activate()


//旼컴컴컴컴컴컴컴컴커
//?alva as perguntas?
//읕컴컴컴컴컴컴컴컴켸
For nA := 1 To Len(aRetRange)
	&("MV_PAR"+STRZERO(nA,2)) := aRetRange[nA]
Next nA

ParamSave(cPergEnt,aPRange,"1")

For nA := 1 To Len(aRetContab)
	&("MV_PAR"+STRZERO(nA,2)) := aRetContab[nA]
Next nA

ParamSave(cPergCont,aPContab,"1")                 

// Processa os dados.
If _lProc
	Processa({|| _lProc := A052Proc(AllTrim(MV_PAR01), nRadSel) },"Aguarde... Verificando integridade da Planilha...")
EndIf

//UnLockByName( cLockBy, .F., .F. )
Return(_lProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} a052TudoOk()
Confirmacao para importar a Planilha
@Data            20/01/2014
@Parametros      Nenhum
@Autor           Fernando(Imfoc).
@Uso			 Grupo TV1.
@Obs			 Chamado pela Rotina - TV1PMS410.
/*/
//--------------------------------------------------------------------
Static Function a052TudoOk()
Local _lRet :=.t.
If !File(MV_PAR01)
	Help("Aten豫o",1,"HELP"	,,"Selecione um local da Planilha v?ido!" ,1,0)//"N? h?registros a processar" 	
	_lRet := .f.
Else
	_lRet := ApMsgYesNo("Deseja realmente importar os dados da Planilha?", "Aten豫o")	
EndIf
Return(_lRet)

//-------------------------------------------------------------------
/*/A052Proc - Processa Planilha CSV. 
@Data            06/11/2032
@Autor           Fernando.
/*/
//--------------------------------------------------------------------
Static Function A052Proc(_cFile, nOpc)

Local _aArea	  := GetArea()
Local _nX		  := 0
Local _nPos		  := 0
Local _nlinha	  := 0
Local _aRet		  := {}
Local _aTxt 	  := {}
Local _aEDTSon	  := {}
Local _aLink	  := {}
Local _aVetor	  := {}
Local _aCmb		  := {"PSP","RETRANCA"}
Local _lOK		  := .T.
Local _lError	  := .F.
Local _cQuery	  := ""		
Local _cArqSC7	  := ""  
Local _cField	  := ""
Local _cLinha	  := ""
Local _cDescEDT	  := ""
Local _cFiltro	  := Space(100)
Local _cCmb		  := ""
Local _cVar		  := ""
Local _oDlgPln	  := Nil
Local _oDlgTXT	  := Nil
Local _oLbx		  := Nil
Local _oSay01     := Nil    
Local _oFontConf  := Nil
Local _cTitulo	  := "EDT j?existente"
Local _cCodEDT	  := A052CodEDT(nOpc)
Local _lTitulo	  := .F.
Local cAliasExcel := GetNextAlias()

If Empty(_cCodEDT)
	If nOpc == ESTRUTURA_JA_EXISTE
		Aviso("ATEN플O","PSP n? possui estrutura para importa豫o."+CRLF+"Favor selecionar a Op豫o - Nova Planilha para importa豫o!",{"OK"})
		Return(.f.)
	EndIf
EndIf

If FT_FUse(_cFile) == -1
	Help(" ",1,"NOFILEIMPOR")
	RestArea(_aArea)
	Return(.f.)
EndIf

//Leitura do Arquivo Excel e armazanagem no Array aTXT
FT_FGOTOP()
Do While !FT_FEOF()

	_cLinha:= FT_FREADLN()
	_nLinha++

	If 	TITULO    $ Upper(_cLinha).Or. TITULO2  $ Upper(_cLinha).Or.;
		SUBTITULO $ Upper(_cLinha).Or. SUBTITULO2 $ Upper(_cLinha).Or.;
		PRODUTO   $ Upper(_cLinha)

		If 	TITULO $ Upper(_cLinha) .Or. TITULO2 $ Upper(_cLinha)

			_lTitulo:= .T.

		ElseIf SUBTITULO $ Upper(_cLinha) .Or. SUBTITULO2 $ Upper(_cLinha)

			If !_lTitulo
				Aviso("Atencao","Erro na estrutura do Arquivo."+CRLF+"Na Planilha Capo, a Coluna 'TITULO' deve vir antes da coluna SUBTITULO,"+CRLF+"ajuste a Planilha e processe novamente!",{"Ok"})
				_lOK := .F.
				Exit
			Endif

		ElseIf PRODUTO $ Upper(_cLinha)
			If !_lTitulo
				Aviso("Atencao","Erro na estrutura do Arquivo."+CRLF+"Na Planilha Capo,a Coluna 'TITULO' deve vir antes da coluna PRODUTO."+CRLF+"ajuste a Planilha e processe novamente!",{"Ok"})
				_lOK := .F.
				Exit
			Endif
		Endif

		AADD(_aTxt,{})

		Do While At(";",_cLinha) > 0 // Montagem das Colunas
			aAdd(_aTxt[Len(_aTxt)], Substr(_cLinha,1,At(";",_cLinha)-1))
			_cLinha := StrTran(Substr(_cLinha,At(";",_cLinha)+1,Len(_cLinha)-At(";",_cLinha)),'"','')
			If Len(_aTxt[Len(_aTxt)]) == 17
				_aTxt[Len(_aTxt),17] := ""
			EndIF
		EndDo

		If Len(AllTrim(_cLinha)) > 0
			aAdd(_aTxt[Len(_aTxt)],StrTran(Substr(_cLinha,1,Len(_cLinha)),'"','') )
		Else
			aAdd(_aTxt[Len(_aTxt)],"")
		Endif                         

		If Len(_aTxt[Len(_aTxt)]) < 14
			Alert("Linha "+StrZero(_nLinha,3)+" da Planilha Excel com quantidade de colunas insuficientes. Processo abortado!")
			_lOK := .F.
			Exit

		ElseIf Empty(_aTxt[Len(_aTxt), COL_RERI]) .And. Upper( Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ PRODUTO
				Alert("Existem produtos na linha "+StrZero(_nLinha,3)+" sem definicao (PR/RE/RI). Processo abortado!")
				_lOK := .F.
				Exit        

		ElseIf Empty(_aTxt[Len(_aTxt), COL_LINK]) // Numero de Item(Link Excel)

			If Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ PRODUTO
				Alert("Existem produto na Linha "+StrZero(_nLinha,3)+" com numero do Item em branco. Processo abortado!")
				_lOK := .F.
				Exit        

			ElseIf Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU ])) $ TITULO .Or. Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ TITULO2 ;
			  .Or. Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ SUBTITULO .Or. Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ SUBTITULO2
				Alert("Existem Titulo ou Sub-Titulo na Linha "+StrZero(_nLinha,3)+" com numero do Item em branco. Processo abortado!")
				_lOK := .F.
				Exit        
			Endif

    	Endif

		// Adiciona Link Excel.
		If !Empty(_aTxt[Len(_aTxt), COL_LINK]) .And. Upper(Alltrim(_aTxt[Len(_aTxt), COL_ESTRU])) $ PRODUTO

			_nPos := Ascan(_aLink,{|x| Alltrim(x)== AllTrim(_aTxt[Len(_aTxt), COL_LINK]) }) 
			If _nPos > 0
				Alert("Existem linhas com mesmo numero de Link Duplicados. Verifique a linha "+StrZero(_nLinha,3)+". O Processo abortado!")
				_lOK := .F.
			Else
    			aAdd(_aLink,ALLTRIM(_aTxt[Len(_aTxt), COL_LINK]))
    		EndIf
   		EndIf

   	ElseIf "FIM DA PLANILHA" $ Upper(_cLinha) .Or. "FIM" $ Upper(_cLinha)
		Exit

	EndIf
	FT_FSKIP()
EndDo
FT_FUSE()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//?alidacao do Link da Planilha.?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

_lError :=.F.

If _lOK .And. Len(_aTxt) > 0

   	If Len(_aLink) > 0 .And. FindFunction("U_L001TotPC")
   	    
  	    /*
	   	BeginSQL Alias cAliasExcel
			SELECT
					AFC_EDT,
					AF9_EDTPAI,
					AF9_PROJET AS PSP,
					AF9_TAREFA,
					ISNULL(AFC_EDT,AF9_EDTPAI) AS EDT,
					ISNULL(AF9_X_PLAN, AFC_X_PLAN) AS LINKEXCEL
			FROM %Table:AF9% (NOLOCK) AF9 
			LEFT JOIN %Table:AFC% (NOLOCK) AFC
			  ON AF9.AF9_PROJET = AFC.AFC_PROJET
				 AND AF9.AF9_REVISA = AFC.AFC_REVISA
				 AND SUBSTRING(AF9.AF9_EDTPAI,1,1) = AFC.AFC_EDT
				 AND AFC.%NotDel%
			WHERE 
					AF9.%NotDel%
				AND AF9.AF9_PROJET = %exp:cProjAF8%
				AND AF9.AF9_REVISA = %exp:cRevAF8%
			ORDER BY  ISNULL(AF9_X_PLAN, AFC_X_PLAN)
		EndSQL

		DbSelectArea(cAliasExcel)
		If !(cAliasExcel)->(Eof())
			While !(cAliasExcel)->(Eof())

				_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim((cAliasExcel)->LINKEXCEL) })
				
				If _nPos == 0 .Or. Alltrim(_aLink[_nPos]) <> AllTrim((cAliasExcel)->LINKEXCEL)
		
					If Alltrim((cAliasExcel)->EDT) == AllTrim(_cCodEDT) .And. u_L001TotPC( (cAliasExcel)->PSP, ALLTRIM((cAliasExcel)->AF9_TAREFA)) > 0
		
						aAdd(_aTxt,{})
		
						For _nX := 1 To Len(_aTxt[1])
							If _nX == 4
								aAdd(_aTxt[Len(_aTxt)],"ERRO")
							ElseIf _nX == 6
								aAdd(_aTxt[Len(_aTxt)],AF9->AF9_TAREFA)
							ElseIf _nX == 17
								aAdd(_aTxt[Len(_aTxt)],"Considerar na Planilha o LINK "+Alltrim((cAliasExcel)->LINKEXCEL))
							ElseIf _nX == 18
								aAdd(_aTxt[Len(_aTxt)],"N? relacionado na planilha o Link da Tarefa "+Alltrim((cAliasExcel)->AF9_TAREFA)+"que possui Pedido")
							Else
								aAdd(_aTxt[Len(_aTxt)],"-")	
							Endif	
						Next	    
					Endif
				Endif					
				(cAliasExcel)->(DbSkip())
			EndDo
		EndIf
		(cAliasExcel)->(DbCloseArea())
	     */
		If nOpc == NOVA_ESTRUTURA
		
			_cArqSC7 := GetNextAlias()
			_cQuery	 :=""
			_cQuery	 +=" SELECT DISTINCT C7_NUM,C7_X_PLAN FROM "+RetSqlName("SC7")+" (NOLOCK) SC7 " 
			_cQuery	 +=" WHERE SC7.D_E_L_E_T_= '' AND C7_CODPSP='"+ Alltrim(AF8->AF8_PROJET) + "'"
			_cQuery+=" 	ORDER BY C7_NUM "
		
			dbUseArea(.T., "TOPCONN", TCGENQRY(,,_cQuery),_cArqSC7,.F.,.T.)
			DbSelectArea(_cArqSC7)
			If !(_cArqSC7)->(Eof())
				Do While !(_cArqSC7)->(Eof())
					If !Empty((_cArqSC7)->C7_X_PLAN)
						_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim((_cArqSC7)->C7_X_PLAN)})
						If _nPos == 0 // Se nao existir Link Excel
							AADD(_aTxt,{})
							For _nX:=1 To Len(_aTXT[1])
								If _nX == 4
									aAdd(_aTxt[Len(_aTxt)],"ERRO")
								ElseIf _nX== 6
							   		aAdd(_aTxt[Len(_aTxt)],"-")
								ElseIf _nX==17
									aAdd(_aTxt[Len(_aTxt)],"Numero do Pedido "+Alltrim((_cArqSC7)->C7_NUM)+ " n? possui amarracao com planilha atual")
								ElseIf _nX==18
									aAdd(_aTxt[Len(_aTxt)],"CONSIDERAR NA PLANILHA O LINK "+Alltrim((_cArqSC7)->C7_X_PLAN))
								Else
									aAdd(_aTxt[Len(_aTxt)],"-")	
								EndIf
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
								aAdd(_aTxt[Len(_aTxt)],"N? existe link associado ao pedido "+Alltrim((_cArqSC7)->C7_NUM))
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

	
		ElseIf nOpc == ESTRUTURA_JA_EXISTE

			For _nX:=1 To Len(_aTXT)
				
				If Empty(_aTXT[_nX, COL_LINK])
					_aTXT[_nX][17]:="EM BRANCO"	
					_aTXT[_nX][18]:="PREENCHER"
					_lError:=.T.
				ElseIf Empty(_aTXT[_nX, COL_DESC])					
					_aTXT[_nX][17]:="EM BRANCO"	
					_aTXT[_nX][18]:="PREENCHER"
					_lError:=.T.
				Else
	
					If Select("TRBAF9") <> 0
						TRBAF9->(DbCloseArea())
					EndIf	
				
					If Select("TRBAFC") <> 0
						TRBAFC->(DbCloseArea())
					EndIf	
	
					_cQuery	:="	SELECT "
					_cQuery	+="			AFC_X_PLAN, AFC_EDTPAI, "
					_cQuery	+="			AFC_EDT "
					_cQuery	+=" FROM "+RetSQlName("AFC")+" (NOLOCK)  AFC"
					_cQuery	+=" WHERE 	"
					_cQuery	+="		 AFC.D_E_L_E_T_= '' "
					_cQuery	+="  AND AFC_PROJET='"+AF8->AF8_PROJET+"' "
					_cQuery	+="  AND AFC_REVISA ='"+AF8->AF8_REVISA+"'"
					_cQuery	+="  AND AFC_X_PLAN ='"+Alltrim(_aTXT[_nX,5])+"'"
	
					If Select("TRBAFC") <> 0
						TRBAFC->(DbCloseArea())
					EndIf
					
					TcQuery _cQuery  NEW ALIAS "TRBAFC"
	
					DbSelectArea("TRBAFC")
					If !TRBAFC->(EOF())
				
						_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(TRBAFC->AFC_X_PLAN)})
						If _nPos > 0
							If Substr(TRBAFC->AFC_EDTPAI,1,Len(_cCodEDT)) <> Alltrim(_cCodEDT)
								_aTXT[_nX][17]:="Definir uma nova numeracao de link"
								_aTXT[_nX][18]:="Link relacionado a EDT "+ALLTRIM(TRBAFC->AFC_EDT)
								_lError:=.T.								                        
							Endif	
						Else
							If Upper(Alltrim(_aTxt[_nX, COL_ESTRU])) $ PRODUTO
								_aTXT[_nX][17]:="Definir uma nova numeracao no link do produto"
								_aTXT[_nX][18]:="Link relacionado a EDT "+ALLTRIM(TRBAFC->AFC_EDT)
								_lError:=.T.								
							Else
								_aTXT[_nX][17]:="-"
								_aTXT[_nX][18]:="-"
							Endif	  
						Endif
						TRBAFC->(DbCloseArea())
							
					Else
						If Alltrim(_aTXT[_nX][04])=="ERRO"
							_lError:=.T.						
						Else
	
							_cQuery	:="	SELECT "
							_cQuery	+="			AF9_X_PLAN, "
							_cQuery	+="			AF9_TAREFA, "
							_cQuery	+="			AF9_EDTPAI  "
							_cQuery	+=" FROM "+RetSQlName("AF9")+" (NOLOCK)  AF9"
							_cQuery	+=" WHERE 	"
							_cQuery	+="		 AF9.D_E_L_E_T_= '' "
							_cQuery	+="  AND AF9_PROJET='"+AF8->AF8_PROJET+"' "
							_cQuery	+="  AND AF9_REVISA ='"+AF8->AF8_REVISA+"'"
							_cQuery	+="  AND AF9_X_PLAN ='"+Alltrim(_aTXT[_nX,5])+"'"
							TcQuery _cQuery  NEW ALIAS "TRBAF9"
			
							DbSelectArea("TRBAF9")
							If !TRBAF9->(EOF())					
	
								_nPos:= Ascan(_aLink,{|x| Alltrim(x)== AllTrim(TRBAF9->AF9_X_PLAN)})
	
								If _nPos > 0
									If Substr(TRBAF9->AF9_EDTPAI,1,Len(_cCodEDT)) <> Alltrim(_cCodEDT)
										_aTXT[_nX][17]:="Definir uma nova numeracao no link"
										_aTXT[_nX][18]:="Link relacionado a Tarefa "+ALLTRIM(TRBAF9->AF9_TAREFA)
										_lError:=.T.								
									Endif
	
								Else
	
									If Upper(Alltrim(_aTxt[_nX][04]))=="TITULO" .Or. Upper(Alltrim(_aTxt[_nX][04]))=="T?ULO"
										_aTXT[_nX][17]:="Definir uma nova numeracao no link do titulo"
										_aTXT[_nX][18]:="Link relacionado a Tarefa "+ALLTRIM(TRBAF9->AF9_TAREFA)
										_lError:=.T.								
									Else
										_aTXT[_nX][17]:="-"
										_aTXT[_nX][18]:="-"
									Endif	
								Endif
			        		Else
								_aTXT[_nX][17]:="NAO EXISTE LINK"	        		
								_aTXT[_nX][18]:="-"							
							Endif
							TRBAF9->(DbCloseArea())
	
						Endif	
					Endif	                               
				EndiF	
	  		Next

	    Endif	
	
		//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
		//?nterface de resultado da Planilha CAPO.?
		//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
	 	_lOK:=.F.
	
		DEFINE 	FONT _oFontConf ;
				NAME "Arial";
				SIZE 0,-14 BOLD
				
		DEFINE MSDIALOG _oDlgTXT;
			   TITLE "CONFERENCIA IMPORTACAO - "+_cTitulo+" EDT FILHA "+Alltrim(_cCodEDT)+"-"+Alltrim(_cDescEDT);
			   FROM  000,000 TO 400,1200;
			   PIXEL STYLE DS_MODALFRAME
	
		@ 005,010 	LISTBOX _oLbx ;
					VAR _cVar;
					FIELDS HEADER 	"Classificao"	,;
									"Tipo"			,;
									"Descricao"		,;
									"Num.Item"		,;
									"CUSTO(V1)"		,;
									"VENDA(V2)"		,;
									"META"			,;
									"LINK"			,;
									"INCONSITENCIA"	,;
									""; 
					SIZE 580,140 OF _oDlgTXT PIXEL;                
					ColSizes { 10,;
							   10,;
							   50,;
							   10,;
							   14,;
							   14,;
							   14,;
							   80,;
							   80,;
							   1}
	
		_oLbx:SetArray(_aTXT)
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
		
		If _lError
			@ 160,010 Say _oSay01 Prompt "ATENCAO!!! INCONSITENCIA NA PLANILHA. O PROCESSO SERA ABORTADO"  	Size 300,012 FONT _oFontConf COLOR CLR_RED		PIXEL OF _oDlgTXT 
		Else
			@ 160,010 Say _oSay01 Prompt "ATENCAO!!! PLANILHA VALIDADA COM SUCESSO"  	Size 300,012 FONT _oFontConf COLOR CLR_GREEN	PIXEL OF _oDlgTXT 	
		Endif
		@ 180,010 Button "<<"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoTop())
		@ 180,050 Button "<"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoUp())
		@ 180,090 Button ">"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:GoDown())					
		@ 180,130 Button ">>"  			Size 040,012 PIXEL OF _oDlgTXT ACTION(_oLbx:nAt:=Len(_aTXT),_oLbx:Refresh())
		@ 180,190 Button "Confirma"  	Size 050,012 PIXEL OF _oDlgTXT ACTION( Iif(_lError, _lOK:=.f., _lOK:=.T.),_oDlgTXT:End())		
		@ 180,240 Button "Cancelar"  	Size 050,012 PIXEL OF _oDlgTXT ACTION(_oDlgTXT:End())
		_oDlgTXT:lEscClose:=.F.
		ACTIVATE MSDIALOG _oDlgTXT CENTERED 
	
		If _lOK	        
			If !_lError
				//Processa({|| A004Import(AF8->AF8_PROJET,AF8->AF8_REVISA,Iif(nOpc==NOVA_ESTRUTURA,"",_cCodEDT),_aTxt)},"Aguarde... Importando Planilha...")
				Processa({|| A004Import(AF8->AF8_PROJET,AF8->AF8_REVISA,Iif(nOpc==NOVA_ESTRUTURA,"3",_cCodEDT),_aTxt)},"Aguarde... Importando Planilha...")
				Aviso("Aten豫o","Importa豫o conclu?a!",{"Ok"})
			Else
				Alert("Processo Abortado por haver inconsistencia na planilha!")
				_lOk:=.F.
			EndIf
		Else
			Alert("Processo Abortado!")			
			_lOk := .F.
		EndIf

	EndIf 

EndIf

RestArea(_aArea)
Return(_lOK)

//-------------------------------------------------------------------
/*/a052CodEDT - Retorna o Codigo da EDT.
selecao da EDT
@Data            14/11/2012
@Parametros      Nenhum
@Retorno         Nenhum
@Processo        Nenhum
@Tipo            Rotina
@Autor           Fernando.
@Obs             
/*/
//--------------------------------------------------------------------
Static function a052CodEDT(nOpc,_cTitulo)
Local _cCodEDT 	:= ""
Local _cQuery  	:= ""
Local _aEDTSon 	:= {}
Local _aVetor 	:= {}
Local _oDlgPln  := Nil
Local _oSay1    := Nil
Local _cFiltro  := ""
Local _cCmb 	:= ""
Local _aCmb  	:= {}
Local _oLbx 	:= Nil

Do Case
	Case nOpc == NOVA_ESTRUTURA
		_cCodEDT:= "3" // Inicializa o Codigo da EDT, sempre com 3
		_cTitulo:= "Nova Estrutura"

	Case nOpc == ESTRUTURA_JA_EXISTE

		_cQuery	+="	SELECT "
		_cQuery	+="			AFC_EDT, "
		_cQuery	+="			AFC_DESCRI "
		_cQuery	+=" FROM "+RetSQlName("AFC")+" (NOLOCK)  AFC"
		_cQuery	+=" WHERE 	"
		_cQuery	+="		 D_E_L_E_T_= '' "
		_cQuery	+="  AND AFC_PROJET='"+AF8->AF8_PROJET+"' "
		_cQuery	+="  AND AFC_EDTPAI='"+AF8->AF8_PROJET+"' "
		_cQuery	+="  AND AFC_EDT NOT IN('1','2') "
		_cQuery	+="  AND AFC_REVISA ='"+AF8->AF8_REVISA+"'"

		If Select("TRBAFC") <> 0
			TRBAFC->(DbCloseArea())
		EndIf

		TcQuery _cQuery  NEW ALIAS "TRBAFC"

		DbSelectArea("TRBAFC")
		If !TRBAFC->(EOF())
			Do While !TRBAFC->(EOF())
				aAdd(_aEDTSon,{TRBAFC->AFC_EDT,UPPER(TRBAFC->AFC_DESCRI)})
				TRBAFC->(DbSkip())			
			EndDo
		EndIf
		If Select("TRBAFC")>0
			DbSelectArea("TRBAFC")
			TRBAFC->(DbCloseArea())
		Endif

		If Len(_aEDTSon) > 0

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
			_cCodEDT:= "3" // Inicializa o Codigo da EDT, sempre com 3
			_cTitulo:= "Nova Estrutura"
		EndIf
EndCase
Return(_cCodEDT)

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
Local _lNewAFC 	:=.F.
Local _lTitulo 	:=.F.
Local _lSubTit 	:=.F.
Local _lCont	:=.F.
Local _lExcAFC	:=.F.
Default _cPrjImp:=""
Default _cRevImp:=""
Default _cEdtImp:=""
Default _aImport:={}

If Len(_aImport) >0
	//Begin Transaction
	_cRevNew := Soma1(_cRevImp)
	If Empty(_cEdtImp)
		_cEdtNiv3:="0"
	Else
		_cEdtNiv3:="00"
	Endif
	DbSelectArea("AF8")
	AF8->(DbSetOrder(1))
	If AF8->(DbSeek(xFilial("AF8")+AvKey(_cPrjImp,"AF8_PROJET")))
	
		Processa({|| _lProc := .t., A052Revisa(_cPrjImp,_cRevNew,_cEdtImp, _cMsgImp, AF8->AF8_REVISA)  },"Aguarde... Criando Revisao...")

	  Begin Transaction

		// Processa dados obtidos da Planilha.
		For _nX := 1 to Len(_aImport)
			
			PmsIncProc(.T.)
			
			_cLink	:= Alltrim(_aImport[_nX][05])
			
			If Upper(alltrim(_aImport[_nX][04])) == "TITULO" .Or. Upper(alltrim(_aImport[_nX][04]))=="T?ULO" // EDT
				
				DbSelectArea("AFC")
				AFC->(DbSetOrder(1)) // Projeto + Revisao + EDT
				AFC->(DbGoTop())
				If !AFC->(DbSeek(xFilial("AFC")+AvKey(_cPrjImp,"AFC_PROJET")+AvKey(_cRevNew,"AFC_REVISA")+AvKey(_cEdtImp,"AFC_EDT"))) .And. !Empty(_cEDTImp)
					RecLock("AFC",.T.)
					AFC->AFC_FILIAL := xFilial("AFC")
					AFC->AFC_PROJET := _cPrjImp
					AFC->AFC_REVISA := _cRevNew
					AFC->AFC_EDT    := _cEDTImp
					AFC->AFC_NIVEL  := "002"
					//AFC->AFC_EDTPAI := 

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
				
				nRecAFC := 0
				If !Empty(_cEDTImp)				
					_lNewAFC:=!A052AFCVld(_cPrjImp,_cRevNew,_cEdtImp+"."+_cEDTNiv3, @nRecAFC)
				Else
					// Inclus? de EDT	
					_lNewAFC:=!A052AFCVld(_cPrjImp,_cRevNew,_cEDTNiv3, @nRecAFC)
				Endif
				
				If nRecAFC > 0
					DbSelectArea("AFC")
					AFC->(DbGoTo(nRecAFC))
				EndIf
				
				RecLock("AFC",_lNewAFC)
				If _lNewAFC
					AFC->AFC_FILIAL := xFilial("AFC")				
				EndIf	
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
				
			ElseIf Upper(alltrim(_aImport[_nX][04])) == "SUB-TITULO" .Or. Upper(alltrim(_aImport[_nX][04]))=="SUB-T?ULO"
				_cEdtNiv4	:=Soma1(_cEdtNiv4)
				_cTarNiv 	:="00"
				_cNivel  	:=Iif(Empty(_cEDTImp),"003","004")
				_lTitulo 	:=.F.
				_lSubTit 	:=.T.


				_lNewAFC:=.T.
				If !Empty(_cEDTImp)				
					_lNewAFC:=!A052AFCVld(_cPrjImp,_cRevNew,_cEdtImp+"."+_cEdtNiv3+"."+_cEdtNiv4)
				Else                                                                
					_lNewAFC:=!A052AFCVld(_cPrjImp,_cRevNew,_cEdtNiv3+"."+_cEdtNiv4)
				Endif
				
				RecLock("AFC",_lNewAFC)
				If _lNewAFC
					AFC->AFC_FILIAL := xFilial("AFC")
				Endif	
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
				
				If Upper(Alltrim(_aImport[_nX][2])) == Upper("T?nica")
					_aImport[_nX][2] := "TECNICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Log?tica")
					_aImport[_nX][2] := "LOGISTICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Gr?ica")
					_aImport[_nX][2] := "GRAFICA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("Excutiva")
					_aImport[_nX][2] := "EXECUTIVA"
				ElseIf Upper(Alltrim(_aImport[_nX][2])) == Upper("	SEV. PR?RIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SEV. PROPRIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SERV. PR?RIOS") .OR.  Upper(Alltrim(_aImport[_nX][2])) == Upper("	SERV. PROPRIOS")
					_aImport[_nX][2] := "SERVICOS PROPRIOS"
				Endif


				If cUNNegAF8 == "05"
					_cProduto	:= "0000000005"
				Else
					_cProduto := "0000000014"
					_cCCstVda := _aImport[_nX][2]
					_cCCstRee := _aImport[_nX][2]
				EndIf

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
					AF9->AF9_X_META := A004Troca(_aImport[_nX][14])
					AF9->AF9_METTOT := A004Troca(_aImport[_nX][14])
					AF9->AF9_X_PLAN:= _cLink
					AF9->(MsUnLock())
					
				Else
					RecLock("AF9",.T.)
					AF9->AF9_FILIAL := xFilial("AF9")
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
					AF9->AF9_METTOT :=A004Troca(_aImport[_nX][14])
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

			Endif
		Next

		Processa({|| _lProc := .t., A052updLink()} , "Aguarde... "+CHR(13)+CHR(10)+"Redefinindo Item Excel x Tarefas e Pedidos de Compras  ")	
		End Transaction
	Endif
	//End Transaction
Endif
RestArea(_aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} A052UpdLink 
Atualiza tarefas dos Pedidos de Compras, Documentos de Entrada e
Link Excel.

@Data            06/11/2013
@Parametros      Nenhum
@Autor           Fernando.
@Uso			 Grupo TV1.
@Obs
/*/
//--------------------------------------------------------------------
Static Function A052updLink(aTarefas)

Local i 		:= 0
Local lRet 		:= .t.
Local _cPSP		:= alltrim(cProjAF8)
Local cQuery 	:= ""
Local _cMotivo	:= ''        
//Local aPedidos	:= {}
//Local cAliasTop := GetNextAlias()   
//Local _cRevisAnt:= aTarefas[1,4]
Default aTarefas:= {}

// Atualiza Pedidos de Compras que n? possuem vinculo com as tarefas da Revisao atual do Projeto.
cQuery := "	UPDATE " +RetSqlName("SC7")
cQuery += "	SET C7_XTARORI  = C7_TAREFA "
cQuery += "		,C7_XDESCTA = C7_DESCTAR "
cQuery += "		,C7_TAREFA  = '2.01' "
cQuery += "		,C7_DESCTAR = '*Compras n? Previstas' "
cQuery += "		,C7_X_OBDET = ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024), C7_X_OBDET)),'') + char(9)+ 'Link Excel:'+LTRIM(RTRIM(C7_X_PLAN))+'n? encontrado para a revis? atual: "+soma1(cRevAF8)+"'"
cQuery += " FROM "+RetSqlname("SC7")+ " (nolock) SC7 "

cQuery +="  INNER JOIN ("
cQuery +="				  SELECT AF9.AF9_PROJET, AF9.AF9_X_PLAN FROM "+RetSqlName("AF9") + " AF9  INNER JOIN "+RetSqlName("AF8")+ " AF8 ON "   
cQuery += " 			  AF8.AF8_PROJET = AF9.AF9_PROJET AND AF9.AF9_REVISA = AF8.AF8_REVISA AND AF8.D_E_L_E_T_ = '' "
cQuery += "            	  WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_TAREFA <> '2.01'  "
cQuery += "            )  AF9 "
cQuery += "	  ON SC7.C7_CODPSP = AF9.AF9_PROJET AND AF9.AF9_X_PLAN <> SC7.C7_X_PLAN   "

cQuery += "	WHERE  "
cQuery += "	  	  SC7.C7_CODPSP =  '"+_cPSP+"'"
//cQuery += "	  AND SC7.C7_TAREFA <> '2.01' "
cQuery += "	  AND SC7.C7_X_PLAN <> '' "
cQuery += "	  AND SC7.D_E_L_E_T_ = '' "

If (TCSQLExec(cQuery) < 0)
    MsgStop("Erro gerado ao atualizar Link Excel(SC7): TCSQLError() " + TCSQLError())
    Return(.F.)
EndIf

// Atualiza Pedidos de Compras que n? possuem vinculo com as tarefas da Revisao atual do Projeto.
cQuery := "	UPDATE " +RetSqlName("SC7")
cQuery += "	SET  "
cQuery += "		C7_TAREFA  = AF9_TAREFA "
cQuery += "		,C7_DESCTAR = AF9_DESCRI "
cQuery += " FROM "+RetSqlname("SC7")+ " (nolock) SC7 "

cQuery +="  INNER JOIN ("
cQuery +="				  SELECT AF9.AF9_PROJET, AF9.AF9_TAREFA, AF9_DESCRI, AF9.AF9_X_PLAN FROM "+RetSqlName("AF9") + " AF9  INNER JOIN "+RetSqlName("AF8")+ " AF8 ON "   
cQuery += " 			  AF8.AF8_PROJET = AF9.AF9_PROJET AND AF9.AF9_REVISA = AF8.AF8_REVISA AND AF8.D_E_L_E_T_ = '' "
cQuery += "            	  WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_TAREFA <> '2.01'  "
cQuery += "            )  AF9 "
cQuery += "	  ON SC7.C7_CODPSP = AF9.AF9_PROJET AND AF9.AF9_X_PLAN = SC7.C7_X_PLAN   "

cQuery += "	WHERE  "
cQuery += "	  	  SC7.C7_CODPSP =  '"+_cPSP+"'"
cQuery += "	  AND SC7.C7_X_PLAN <> '' "
cQuery += "	  AND SC7.D_E_L_E_T_ = '' "

If (TCSQLExec(cQuery) < 0)
    MsgStop("Erro gerado ao atualizar Link Excel(SC7): TCSQLError() " + TCSQLError())
    Return(.F.)
EndIf

// Atualiza Tarefas do Documento de Entrada

cQuery := "	UPDATE " +RetSqlName("SD1")
cQuery += "	SET  D1_TAREFA  = C7_TAREFA "
cQuery += "		,D1_DESCTAR = C7_DESCTAR "
cQuery += " FROM "+RetSqlname("SD1")+" (nolock) SD1 "

cQuery += " INNER JOIN "+RetSqlname("SC7")+" (nolock) SC7 "
cQuery += "   ON  SD1.D1_PEDIDO = SC7.C7_NUM   "
cQuery += "   AND SD1.D1_ITEMPC = SC7.C7_ITEM  "
//cQuery += "	  AND SD1.D1_X_PLAN = SC7.C7_X_PLAN"
cQuery += "   AND SC7.D_E_L_E_T_ = '' "

cQuery += "	WHERE SD1.D_E_L_E_T_ = '' "
cQuery += "	  AND SD1.D1_CODPSP =  '"+_cPSP+"'"
cQuery += "	  AND SD1.D1_TAREFA <> '2.01' "

If (TCSQLExec(cQuery) < 0)
	MsgStop("Erro gerado ao atualizar Link Excel(SD1): TCSQLError() " + TCSQLError())
    Return(.F.)
EndIf
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} A052UpdLink 
Verifica se existe o registro na base de dados de acordo com a chave
passada. Retorna Verdadeiro se Existir ou Falso caso nao exista no 
sistema
@Data            06/11/2013
@Parametros      Nenhum
@Autor           Fernando.
@Uso			 Grupo TV1.
@Obs
/*/
//--------------------------------------------------------------------
Static Function A052AFCVld(_cCodPrj,_cCodRev,_cCodEDT, nRecAFC)
	Local _aArea	 := GetArea()
	Local _lRet		 := .F.
	//Local cQuery1 	 := ""
	Default _cCodPrj := ""
	Default _cCodRev := ""
	Default _cCodEDT := ""
	Default nRecAFC  := 0
	/*
	cQuery1	:= "SELECT 1"
	cQuery1	+=" FROM "+RetSQlName("AFC")+" (NOLOCK) AFC "
	cQuery1	+=" WHERE "
	cQuery1	+=" 	AFC.AFC_FILIAL 	= '"+xFilial("AFC")+"'"	
	cQuery1	+=" AND AFC.AFC_PROJET 	= '"+_cCodPrj+"'"
	cQuery1	+=" AND AFC.AFC_EDT 	= '"+_cCodEDT+"'"	
	cQuery1	+=" AND AFC.AFC_REVISA 	= '"+_cCodRev+"'"
	cQuery1 +=" AND AFC.D_E_L_E_T_ 	= '' "	

	MemoWrite( "\logws\imfa052_A052AFCVld_"+"_"+StrTran(Time(),":","")+".log" , cQuery1)
	TcQuery cQuery1  NEW ALIAS "TAFC1"
	cQuery1:= ""
	
	DbSelectArea("TAFC1")
	If !TAFC1->(Eof())
		_lRet :=.T.
	EndIf
	TAFC1->(DbCloseArea())
	*/
	DbSelectArea("AFC")
	AFC->(DbSetOrder(1)) // Projeto + Revisao + EDT
	AFC->(DbGoTop())
	If AFC->(DbSeek(xFilial("AFC")+AvKey(_cCodPrj,"AFC_PROJET")+AvKey(_cCodRev,"AFC_REVISA")+AvKey(_cCodEDT,"AFC_EDT"))) 
		_lRet:=.T.
		nRecAFC := AFC->(Recno())
	EndIf
	RestArea(_aArea)

Return _lRet