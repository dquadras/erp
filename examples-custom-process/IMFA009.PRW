#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWADAPTEREAI.CH"
#DEFINE MAXGETDAD 999
#DEFINE CRLF chr(13)+chr(10)
#DEFINE SAY_CSS "QLineEdit{color:#333300; background-color:#F8F8FF;}"
#DEFINE GNOVA '06'

static cRetF3Un := Space(tamsx3('PA4_X_DSPR')[1])
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA009 - Geracao de Pedido de Compras.
@aParam		Nil
@uso        TV1
@Autor     David Ferreira Quadras
//--------------------------------------------------------------------
/*/
User Function IMFA009(_cPrjPai)
	Local _aArea  	:= GetArea()
	Local _cQuery 	:= ""
	Local _lMark  	:= .F.
	Local _lChk     	:= .F.
	Local _aListEDT 	:= {}
	Local _aListTar 	:= {}
	Local _aListMarc 	:= {}
	Local _oDlg		:= Nil
	Local _oOk      	:= LoadBitmap( GetResources(), "LBOK" )
	Local _oNo      	:= LoadBitmap( GetResources(), "LBNO" )
	Local _oLib      	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local _oBlq      	:= LoadBitmap( GetResources(), "BR_AZUL" )
	Local _oChk 		:= Nil
	Local _oFont		:= Nil
	Local _oBarTop	:= Nil
	Local _oBarBot	:= Nil
	Local _oLayer 	:= 	FwLayer():New()
	Local _oListEDT	:= Nil
	Local _oListTar	:= Nil
	Local _oListMarc	:= Nil
	Local _oMainWnd	:= Nil
	Local _aInfo		:= {}
	Local _aObjects 	:= {}
	Local _aPosObj 	:= {}
	Local _aSize 		:= MsAdvSize(.T.)
	Local _cLyHd01	:= 	"HEADER01"
	Local _cLy01Col1	:= "HD01_Win01"
	Local _cStyleCSS 	:= ""
	Local _cIcon 		:= ""
	Local nLargura 	:= 0
	Local nAltura     := 0
	Local cGetEDT 	:= Space(60)
	Local cGetTarefa	:= Space(60)
	Private _cMensagem:= ""
	Private _cProjeto	:= ""
	Private _cRevisao := ""
	Private _cDescPrj	:= ""
	Private _cTipoPrj	:= ""
	Private _cFase	:= ""
	Private _cGestor  := CriaVar("C7_X_GESTO")
	Private _cNomeGestor:= CriaVar("Z9_GESTOR")
	Private _cCelula    := CriaVar("PA4_X_COD")
	Private _cDescCelula:= SPACE(60)
	Private _nMegaPix	:= 1//u_L001WndRes()
	Private _nTotCust	:= 0
	Private _nTotMeta	:= 0
	
	Private _nOpcao		:= 1
	Private _oTotCust		:= Nil
	Private _oTotMeta		:= Nil
	Private _oGrpApro1	:= Nil
	Private _oGrpApro2	:= Nil
	Private _cConteudo	:=Space(200)
	
	Private _cCusto		:= ""
	Private _aListGer		:= {}
	Private aBkpEDT		:= {}
	Private aBkpTar		:= {}
	Private lMsErroAuto  := .F. // variável de controle interno da rotina automatica que informa se houve erro durante o processamento
	Private lMsHelpAuto	:= .T. // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
	Private lAutoErrNoFile:= .T. // // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
	Private aLog		  	:= {}
	
	Default _cPrjPai	  	:= "" //"080431199" // retirar
	
	DbSelectArea("SY1")
	SY1->(DbSetOrder(3))
	If !SY1->(DbSeek(xFilial("SY1")+AvKey(__cUserID,"Y1_USER")))
		ApMsgAlert("*Processo abortado. Usuário não esta cadastrado como comprador.", "Atenção")
		
	Else
		If !Empty(_cPrjPai)
			DbSelectArea("AF8")
			AF8->(DbSetOrder(1))
			AF8->(DbSeek(xFilial("AF8")+AvKey(_cPrjPai,"AF8_PROJET")))
		Endif
		
		_cProjeto	:= AF8->AF8_PROJET
		_cRevisao   := AF8->AF8_REVISA
		_cDescPrj	:= AF8->AF8_DESCRI
		_cTipoPrj	:= AF8->AF8_X_TIPO
		_cFase		:= AF8->AF8_FASE
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida Fases - 52(Pedidos de Compras) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aFase := {_cFase,"52","Pedido de Compras"}
		If u_L001vlFase(@_aFase) == "2"
			Alert("ATENÇÃO"+ CRLF+_aFase[03])
			RestArea(_aArea)
			Return .T.
		EndIf
		
		_cQuery:=""
		_cQuery+="  SELECT 			"+CRLF
		_cQuery+="   	AFC_PROJET, 	"+CRLF
		_cQuery+="    AFC_REVISA, 	"+CRLF
		_cQuery+="  	AFC_EDT, 	  	"+CRLF
		_cQuery+="  	AFC_DESCRI 	"+CRLF
		_cQuery+=" 	FROM "+RetSqlName("AFC")+" (NOLOCK) AFC "+CRLF
		_cQuery+=" 	INNER JOIN "+RetSqlName("AF8")+" (NOLOCK) AF8 "+CRLF
		_cQuery+=" 	  ON  AF8.AF8_PROJET = AFC.AFC_PROJET "+CRLF
		_cQuery+=" 	  AND AF8.AF8_REVISA = AFC.AFC_REVISA "+CRLF
		_cQuery+=" 	  AND AF8.AF8_PROJET ='"+ _cProjeto + "'"+CRLF
		_cQuery+=" 	  AND AF8.AF8_REVISA ='"+ _cRevisao + "'"+CRLF
		
		If(cEmpAnt == GNOVA)
			_cQuery+=" 	  AND ( AFC.AFC_EDTPAI ='"+_cProjeto+"' OR AFC.AFC_EDTPAI ='' )" +CRLF
		Else
			_cQuery+=" 	  AND AFC.AFC_EDTPAI ='"+ _cProjeto + "'"+CRLF
		EndIf
		
		_cQuery+=" 	  AND AF8.D_E_L_E_T_ ='' "
		_cQuery+=" 	WHERE AFC.D_E_L_E_T_ ='' "
		
		TcQuery _cQuery  NEW ALIAS "TRBEDT"
		
		_aListGer:={}
		_aListEDT:={}
		_aListTar:={}
		DbSelectArea("TRBEDT")
		If !TRBEDT->(EOF())
			Do While TRBEDT->(!EOF())
				aAdd(_aListEDT, {Alltrim(TRBEDT->AFC_EDT),Alltrim(UPPER(TRBEDT->AFC_DESCRI))})
				TRBEDT->(DbSkip())
			End
			
			_aListGer:= A009ListTar(_cProjeto,_cRevisao)
			
			If Len(_aListGer) > 0
				A009FilT(@_aListTar,_aListGer,_aListEdt[1][1])
				
				If Len(_aListTar)== 0
					
					aAdd(_aListTar, {.F.,;
						"",;
						"",;
						"",;
						"",;
						0,;
						0,;
						""})
				Endif
			Else
				aAdd(_aListTar, {.F.,;
					"",;
					"",;
					"",;
					"",;
					0,;
					0,;
					""})
			Endif
		Else
			aAdd(_aListEDT, {"",""})
			aAdd(_aListTar, {.F.,"","","","",0,0,""})
		Endif
		aAdd(_aListMarc, {"","","",0,0})
		
		If Select("TRBEDT") > 0
			DbSelectArea("TRBEDT")
			TRBEDT->(DbCloseArea())
		Endif
		
		aBkpEDT := aClone(_aListEdt)
		aBkpTar := aClone(_aListTar)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montagem da Tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aObjects := {}
		AAdd( _aObjects, { 100, 100, .t., .t. } )
		AAdd( _aObjects, { 100, 100, .t., .t. } )
		AAdd( _aObjects, { 100, 100, .t., .f. } )
		
		_aInfo 	:= { _aSize[1], _aSize[2], _aSize[3], _aSize[4], 3, 3}
		_aPosObj:= MsObjSize(_aInfo, _aObjects)
		
		//_oDlg := TDialog():New( _aSize[7], 000, _aSize[6]+30, _aSize[5]-600, OemToAnsi("PROJETO: " + ALLTRIM(_cProjeto) + " - " + ALLTRIM(_cDescPrj)+" REVISAO:"+_cRevisao) ,,,,,,,,oMainWnd,.T.)
		
		aSizeAut:= MsAdvSize(,.F.,400)
		aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
		aPosObj := MsObjSize( _aInfo, _aObjects )
		
		aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,40,105,140,200,234,275,200,225,260,285,265},;
			{10,40,105,140,200,234,63},{5,70,160,205,295},;
			{6,34,200,215},;
			{6,34,80,113,160,185},;
			{6,34,245,268,260},;
			{10,50,150,190},;
			{273,130,190},;
			{8,45,80,103,139,173,200,235,270},;
			{133,190,144,190,289,293},;
			{142,293,140},;
			{9,47,188,148,9,146} } )
		
		//DEFINE MSDIALOG _oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
		
		_oDlg := TDialog():New( aSizeAut[7], 000, aSizeAut[6], aSizeAut[5]-600, OemToAnsi("PROJETO: " + ALLTRIM(_cProjeto) + " - " + ALLTRIM(_cDescPrj)+" REVISAO:"+_cRevisao) ,,,,,,,,oMainWnd,.T.)
		
		_oLayer:Init(_oDlg, .t.)
		_oLayer:AddColumn(_cLyHd01,100, .T.)
		_oLayer:AddWindow(_cLyHd01, _cLy01Col1,"Seleção de Itens", 100, .t., .f., {|| .t.},,{||.t.} )
		
		DEFINE FONT _oFont Name "Verdana" SIZE 0,-14 BOLD
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³BOTES(BUTTONS)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		DEFINE BUTTONBAR _oBarTop size 50,150 3D TOP OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		oBtnPC := TButton():New(026,028*_nMegaPix , "  &Gerar Pedido", _oBarTop,;
			{|| A009Tela(_aListGer) },; //{|| A009Ped(_aListGer) },;
			50,34, , , .F.,.T., .F., ,.F., , ,.F.)
		
		_cIcon := " url(rpo:PEDIDO.png) "
		_cStyleCSS := "QPushButton{background-image:"+_cIcon+"; background-repeat: 1px; border: 2px solid #DCDCDC;  border-radius: 10px;  background-color: qlineargradient(x1: 12, y1: 15, x2: 0, y2: 1, stop: 9 #E8E8E8, stop: 1 #E8E8E8 );}"
		oBtnPC:SetCss(_cStyleCSS)
		
		_cIcon := " url(rpo:SDUFIND.png) "
		_cStyleCSS := "QPushButton{background-image:"+_cIcon+"; background-repeat: 1px; border: 2px solid #DCDCDC;  border-radius: 10px;  background-color: qlineargradient(x1: 12, y1: 15, x2: 0, y2: 1, stop: 9 #E8E8E8, stop: 1 #D3D3D3);}"
		
		oBtnVisualPC := TButton():New(26, 040*_nMegaPix,"  &Visualiza Pedido",_oBarTop,{|| u_L001BrwPed(_cProjeto) }, 50,34,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnVisualPC:SetCss(_cStyleCSS)
		
		_cIcon := " url(rpo:CANC0116.png) "
		_cStyleCSS := "QPushButton{background-image:"+_cIcon+"; background-repeat: 1px; border: 2px solid #DCDCDC;  border-radius: 10px;  background-color: qlineargradient(x1: 12, y1: 15, x2: 0, y2: 1, stop: 9 #E8E8E8, stop: 1 #D3D3D3);}"
		oBtnClose := TButton():New(26,052*_nMegaPix," &Fechar",_oBarTop,{|| _oDlg:End() }, 50,34,,,.F.,.T.,.F.,,.F.,,,.F. )
		oBtnClose:SetCss(_cStyleCSS)
		
		
		nLargura:= oMainWnd:nClientWidth/3.8
		nAltura	:= 050*_nMegaPix
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³EDTS DO PSP	   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		@ 020*_nMegaPix,002*_nMegaPix TO 085*_nMegaPix, nLargura+40 ;
			LABEL "EDT";
			PIXEL COLOR CLR_RED OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		_oListEdt := TWBrowse():New( 033*_nMegaPix,;
			005*_nMegaPix,;
			nLargura,;
			nAltura,;
			,;
			{"EDT", "DESCRICAO"},;
			{20 , 100},;
			_oLayer:GetWinPanel(_cLyHd01,_cLy01Col1),;
			,;
			,;
			,;
			{|| A009FilT(@_aListTar, _aListGer, _aListEdt[_oListEdt:nAt,1]), _oListTar:aArray:={}, _oListTar:aArray:=aClone(_aListTar), _oListTar:Refresh() },;
			{||},;
			,;
			,;
			,;
			CLR_LIGHTGRAY,;
			,,.F.,,.T.,,.F.,,, )
		
		_oListEdt:SetArray(_aListEdt)
		_oListEdt:bLine := {|| {_aListEdt[_oListEdt:nAt,1],_aListEdt[_oListEdt:nAt,2]}}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tarefas do PSP  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 085*_nMegaPix,002*_nMegaPix TO 160*_nMegaPix, nLargura+40;
			LABEL "Tarefas do PSP";
			PIXEL COLOR CLR_RED OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		oGetTarefa := TGet():New( 092*_nMegaPix, 005*_nMegaPix, {|u| Iif(PCount()>0, cGetTarefa := u, cGetTarefa)},;
			_oLayer:GetWinPanel(_cLyHd01,_cLy01Col1),086,009,;
			"@!",{|| a009Filtra(@cGetTarefa, 3, @_oListTar, @_aListTar),;
			If( Empty(cGetTarefa),;
			Eval({ || A009FilT(@_aListTar,_aListGer,_aListEdt[_oListEdt:nAt][1]), _oListTar:aArray :={}, _oListTar:aArray := aClone(_aListTar), _oListTar:Refresh()}), .t. ) },;
			0,;
			,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cGetTarefa",,,,)
		
		oGetTarefa:SetCSS("QLineEdit{color:#FF0000; background-color:#F5F5F5;}")
		
		
		//Botao para pesquisar.
		oBtnTarefas := TButton():New(093*_nMegaPix, 98*_nMegaPix,"",;
			_oLayer:GetWinPanel(_cLyHd01,_cLy01Col1),{|| a009Filtra(@cGetTarefa, 3, @_oListTar, @_aListTar),;
			If(Empty(cGetTarefa),;
			Eval({ || A009FilT(@_aListTar,_aListGer,_aListEdt[_oListEdt:nAt][1]),_oListTar:aArray := aClone(_aListTar),_oListTar:Refresh()}),Nil)},;
			015, 014,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		_cIcon := " url(rpo:SDUFIND.png) "
		_cStyleCSS := "QPushButton{background-image:"+_cIcon+"; background-repeat: 1px; border: 2px solid #DCDCDC;  border-radius: 10px;  background-color: qlineargradient(x1: 12, y1: 15, x2: 0, y2: 1, stop: 1 #E8E8E8, stop: 1 #D3D3D3);}"
		oBtnTarefas:SetCss(_cStyleCSS)
		
		_oListTar := TWBrowse():New( 105*_nMegaPix,;
			005*_nMegaPix,;
			nLargura,;
			050*_nMegaPix,;
			,;
			{" ", "TAREFA", "DESCRICAO","ITEM","PRODUTO","ORCADO","META","NUM ITEM"},;
			{20 , 20		,  30		 ,  10	, 40	  , 14,14,10},;
			_oLayer:GetWinPanel(_cLyHd01,_cLy01Col1),;
			,;
			,;
			,;
			,;
			{||},;
			,;
			,;
			,;
			CLR_LIGHTGRAY,;
			,,.F.,,.T.,,.F.,,, )
		
		_oListTar:SetArray(_aListTar)
		_oListTar:bLine := {|| {If(_aListTar[_oListTar:nAt,1],_oOk,_oNo),;
			_aListTar[_oListTar:nAt,2],;
			_aListTar[_oListTar:nAt,3],;
			_aListTar[_oListTar:nAt,4],;
			_aListTar[_oListTar:nAt,5],;
			alltrim(Transform(_aListTar[_oListTar:nAt,6], "@E 999,999,999.999")),;
			alltrim(Transform(_aListTar[_oListTar:nAt,7], "@E 999,999,999.999")),;
			_aListTar[_oListTar:nAt,8]}}
		
		_oListTar:bLDblClick := {||;
			A009Marca(@_aListGer,_aListTar[_oListTar:nAt][2],_aListTar[_oListTar:nAt][4]),;
			A009FilT(@_aListTar,_aListGer,_aListEdt[_oListEdt:nAt][1]),;
			_oListTar:Refresh(),;
			_oListTar:aArray := {},;
			_oListTar:aArray := aClone(_aListTar),;
			_oListTar:Refresh(),;
			A009LMarc(@_aListMarc,_aListGer),;
			_oListMarc:aArray := aClone(_aListMarc),;
			_oListMarc:Refresh()}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Tarefas que irao gerar o PC  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 162*_nMegaPix,005*_nMegaPix TO 215*_nMegaPix ,oMainWnd:nClientWidth/2.1 ;
			LABEL "Tarefas para o Pedido Compra";
			PIXEL COLOR CLR_RED OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		@ 170*_nMegaPix,005*_nMegaPix 	ListBox _oListMarc ;
			Fields HEADER "TAREFA", "DESCRICAO","PRODUTO","ORCADO","META";
			Size nLargura, nAltura Of _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1) Pixel ;
			ON dblClick(u_L001BrwPed(_cProjeto,_aListMarc[_oListMarc:nAt,1])) ;
			ColSizes {20, 20, 30, 20, 14,14,10}
		_oListMarc:SetArray(_aListMarc)
		_oListMarc:bLine := {|| {	_aListMarc[_oListMarc:nAt,1],;
			_aListMarc[_oListMarc:nAt,2],;
			_aListMarc[_oListmarc:nAt,3],;
			TRANSFORM(_aListMarc[_oListMarc:nAt,4], "@E 999,999,999.999"),;
			TRANSFORM(_aListMarc[_oListMarc:nAt,5], "@E 999,999,999.999")}}
		
		
		@ 230*_nMegaPix,005*_nMegaPix	SAY OemToAnsi("Total Custos:");
			FONT _oFont  OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1) PIXEL;
			SIZE 090*_nMegaPix,010
		
		@ 240*_nMegaPix,005*_nMegaPix	MsGet _oTotCust;
			Var _nTotCust;
			Picture "@E 999,999,999.999";
			WHEN .F.  NOBORDER ;
			Size 090*_nMegaPix,009 COLOR CLR_BLACK FONT _oFont PIXEL OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		@ 230*_nMegaPix,140*_nMegaPix	SAY OemToAnsi("Total de Meta:");
			FONT _oFont  OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1);
			PIXEL SIZE 090*_nMegaPix,010
		
		@ 240*_nMegaPix,140*_nMegaPix	MsGet _oTotMeta Var _nTotMeta Picture "@E 999,999,999.999" WHEN .F.  NOBORDER Size 090*_nMegaPix,009 COLOR CLR_BLACK FONT _oFont PIXEL OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		
		DEFINE BUTTONBAR _oBarBot size 10,10 3D BOTTOM OF _oLayer:GetWinPanel(_cLyHd01,_cLy01Col1)
		
		ACTIVATE MSDIALOG _oDlg  CENTERED
		
	EndIf
	RestArea(_aArea)
Return(.T.)

//-------------------------------------------------------------------
/*/ A009ListTar
Lista em um array todas as tarefas do projeto selecionado
@aParam
@author		Marcos kato
@since		12/11/2012
@uso        TV1 - Eventos
@Obs
/*/
//--------------------------------------------------------------------
Static Function A009ListTar(_cCodPRJ,_cRevPRJ)
	Local _aArea		:=GetArea()
	Local _aTarGER		:=()
	Local _cQryGER		:=""
	Default _cCodPRJ	:=""
	Default _cRevPRJ	:=""
	
	_cQryGER:=""
	_cQryGER+=" SELECT " +CRLF
	_cQryGER+=	"		AFC.AFC_EDT, 	"+CRLF
	_cQryGER+=	"		AFC_DESCRI ,	"+CRLF
	_cQryGER+=	"		AF9_TAREFA,	"+CRLF
	_cQryGER+=	"		AF9_DESCRI, 	"+CRLF
	_cQryGER+=	"		AFA_ITEM, 		"+CRLF
	_cQryGER+=	"		COALESCE(AFA_PRODUT,'-') AS AFA_PRODUT, 	"+CRLF
	_cQryGER+=" 		CASE WHEN COALESCE(AF9_METTOT,0) > 0 THEN COALESCE(AF9_METTOT,0) ELSE COALESCE(AF9_X_META,0) END AS AF9_METTOT, "+CRLF
	_cQryGER+=" 		COALESCE(AF9.AF9_CUSTO,0) AS AF9_CUSTO,	"+CRLF
	_cQryGER+=" 		COALESCE(AF9_X_PLAN,'') AS AF9_X_PLAN 		"+CRLF
	_cQryGER+=" FROM "+RetSqlName("AF9")+" (NOLOCK) AF9 		  	"+CRLF
	
	_cQryGER+=" INNER JOIN "+RetSqlName("AFC")+" (NOLOCK) AFC 	"+CRLF
	_cQryGER+="   ON AFC.AFC_PROJET		= AF9.AF9_PROJET  		"+CRLF
	_cQryGER+="   AND AFC.AFC_REVISA 	= AF9.AF9_REVISA 			"+CRLF
	_cQryGER+="   AND AFC.AFC_PROJET 	='"+_cCodPRJ+"' 			"+CRLF
	_cQryGER+="   AND AFC.AFC_REVISA 	='"+_cRevPRJ+"' 			"+CRLF
	_cQryGER+="   AND AFC.AFC_EDT		= AF9.AF9_EDTPAI 			"+CRLF
	_cQryGER+="   AND AFC.D_E_L_E_T_	= '' "+CRLF
	
	_cQryGER+=" LEFT JOIN "+RetSqlName("AFA")+" (NOLOCK) AFA 	"+CRLF
	_cQryGER+="   ON AFA.AFA_PROJET  	= AF9.AF9_PROJET 			"+CRLF
	_cQryGER+="   AND AFA.AFA_REVISA 	= AF9.AF9_REVISA 			"+CRLF
	_cQryGER+="   AND AFA.AFA_TAREFA 	= AF9.AF9_TAREFA 			"+CRLF
	_cQryGER+="   AND AFA.D_E_L_E_T_ 	= '' 						"+CRLF
	_cQryGER+="   AND AFA.AFA_ITEM 		= (select top 1 AFA_ITEM FROM "+RetSqlName("AFA")+" (NOLOCK) AFA2 WHERE AFA2.D_E_L_E_T_ ='' AND AFA2.AFA_PROJET = AFA.AFA_PROJET AND AFA2.AFA_REVISA = AFA.AFA_REVISA AND AFA2.AFA_TAREFA = AFA.AFA_TAREFA)
	
	_cQryGER+=" WHERE "
	_cQryGER+=" 		AF9.D_E_L_E_T_= '' "+CRLF
	_cQryGER+=" ORDER BY AFC_EDT,AF9_TAREFA, AFA.AFA_ITEM "
	
	TcQuery _cQryGER  NEW ALIAS "TRBGER"
	
	_aTarGER:={}
	DbSelectArea("TRBGER")
	If TRBGER->(!EOF())
		Do While TRBGER->(!EOF())
			_cDescPrd:=TRBGER->AFA_PRODUT
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1")+AvKey(TRBGER->AFA_PRODUT,"B1_COD")))
				_cDescPrd:=Alltrim(SB1->B1_DESC)
			Endif
			
			If ( TRBGER->AF9_CUSTO == 0 ) .And.  Alltrim(TRBGER->AF9_TAREFA) <> '2.01' //.And. Alltrim(TRBGER->AFA_PRODUT) <> "-"
				TRBGER->(DbSkip())
				Loop
			EndIf
			aAdd(_aTarGER, {.F.,;
				Alltrim(TRBGER->AFC_EDT),;
				Upper(Alltrim(TRBGER->AFC_DESCRI)),;
				Alltrim(TRBGER->AF9_TAREFA),;
				Upper(Alltrim(TRBGER->AF9_DESCRI)),;
				_cDescPrd,;
				TRBGER->AF9_CUSTO,;
				TRBGER->AF9_METTOT,;
				TRBGER->AF9_X_PLAN,;
				Alltrim(TRBGER->AFA_ITEM)})
			TRBGER->(DbSkip())
		EndDo
	Endif
	If Select("TRBGER")>0
		DbSelectArea("TRBGER")
		TRBGER->(DbCloseArea())
	Endif
	RestArea(_aArea)
Return _aTarGER
//-------------------------------------------------------------------
/*/ A009FilT
Lista em um array os dados filtrados de acordo com a EDT posicionada
@aParam
@author		Marcos kato
@since		12/11/2012
@uso        TV1 - Eventos
@Obs
/*/
//--------------------------------------------------------------------
Static Function A009FilT(_aTarFil,_aDadTar,_cCodEDT)
	Local _aArea		:=GetArea()
	Local nX			:=0
	Default _cCodEDT	:=""
	Default _aDadTar	:={}
	
	_aTarFil :={}
	_cCodEDT := AllTrim(_cCodEDT)
	
	For nX:=1 To Len(_aDadTar)
		
		If Substr(_aDadTar[nX][2],1,Len(_cCodEDT)) == _cCodEDT
			
			aAdd(_aTarFil, {;
				_aDadTar[nX][1]					,;
				Alltrim(_aDadTar[nX][4])		,;
				upper(Alltrim(_aDadTar[nX][5])),;
				Alltrim(_aDadTar[nX][10])		,;
				Alltrim(_aDadTar[nX][6])		,;
				_aDadTar[nX][7]					,;
				_aDadTar[nX][8]					,;
				Alltrim(_aDadTar[nX][9])})
		Endif
	Next
	
	If Len(_aTarFil) > 0
		_aTarFil:= aSort(_aTarFil, , , {|x,y| x[02]+x[02] < y[02]+y[02]})
	Else
		aAdd(_aTarFIL, {.F.,"", "",	"",	"",	0,	0,""})
	EndIf
	RestArea(_aArea)
Return(Nil)
//-------------------------------------------------------------------
/*/{Protheus.doc} A009Marca
Marca as tarefas que irao compor o pedido
@aParam
@author		Edson Shideki Kokado
@since		13/08/2009
@uso        TV1 - Eventos
@Obs 		Posicionado no Projeto(AF8)
/*/
//--------------------------------------------------------------------
Static Function A009Marca(_aLista,_cTarefa,_cItem)
	Local _aArea    := GetArea()
	Local _nX 		:= 0
	Default _cTarefa:= ""
	Default aBkpTar :={}
	
	_nPos := Ascan(_aLista,{ |X| Alltrim(X[4])+Alltrim(X[10]) == Alltrim(_cTarefa)+Alltrim(_cItem) })
	If _nPos>0
		_aLista[_nPos][1]:=!_aLista[_nPos][1]
	Endif
	RestArea(_aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} A009LMarc
Lista todos as tarefas marcada
@aParam
@author		Marcos Kato
@since		12/11/2012
@uso
@Obs
/*/
//--------------------------------------------------------------------
Static Function A009LMarc(_aListPC,_aLista)
	Local _aArea    := GetArea()
	Local _nX 		:= 0
	Default _aLista	:={}
	
	_nTotCust:=0
	_nTotMeta:=0
	_aListPC:={}
	For _nX := 1 To Len(_aLista)
		If _aLista[_nX][1]
			aAdd(_aListPC, {Alltrim(_aLista[_nX][4]),Alltrim(_aLista[_nX][5]),Alltrim(_aLista[_nX][6]),_aLista[_nX][7],_aLista[_nX][8]})
			_nTotCust+=_aLista[_nX][7]
			_nTotMeta+=_aLista[_nX][8]
		Endif
	Next
	_oTotCust:Refresh()
	_oTotMeta:Refresh()
	
	RestArea(_aArea)
Return

//-------------------------------------------------------------------
/*/a009Tela
Tela de Pedidos de Compras.
@aParam
@author		Fonseca
@since		27/02/2014
@obs
/*/
//--------------------------------------------------------------------
Static function a009Tela(_aTarefas)
	
	Local aArea      	:= GetArea()
	Local nX		 	:= 0
	Local aCpoValid  	:= {"C7_NUMSC","C7_ITEMSC","C7_DATPRF","C7_NUMCOT","C7_APROV","C7_QTDSOL","C7_RESIDUO"}
	Local aButtons   	:= {}
	Local aObj	      	// Array com os objetos utilizados no Folder
	Local aObj2[2]	 	// Array 2 com objetos utilizados no Folder
	Local aSizeAut   	:= {}
	Local aUsButtons 	:= {}
	Local aInfo 	 	:= {}
	Local aPosObjPE  	:= {}
	Local aStruSC7   	:= {}
	Local oDescCond
	Local oDescMoed
	Local oGetMoeda
	Local oTpOp
	Local _cGrpSCR 		:= ""
	Local aCtbDia	 	:= {}
	Local cItemSCH 		:= ""
	Local nItemSCH 		:= 0
	Local aAreaAdt		:= {}
	Local aColsBKPRat	:= {}
	Local aArea2 		:= {}
	Local aAreaSE2		:= {}
	Local cGetEDT 		:= Space(60)
	Local cGetTarefa	:= Space(60)
	Local _aCmbBx1	 	:= {"Nao Aplica","Prejuízo","Cobrança Posterior"}
	Local _aCmbBx2	 	:= {"Sim","Nao"}
	Local _aCmbBx3		:= {"TV1","Cliente",""}
	Local _aCmbBx4	 	:= {"Pagamento Direto Cliente","Nota de Debito",""}
	Local _aCmbBx5	 	:= {"Sim","Nao"} //Gera Credito?
	//Local _aCmbBx5	 	:= {"0=Não se Aplica","1=Gerar","2=Utilizar"} //Gera Credito?
	Local _aCmbBx6	 	:= {"Sim","Nao"} //Utiliza Credito?
	Local _nOpca		:= 0
	Local _lRetorno		:= .t.
	Private aPosGet	 := {}
	Private aPosObj		:= {}
	Private oDlg		:= Nil
	PRIVATE aInfForn	:= {"","",CTOD(""),CTOD(""),"","",""}
	PRIVATE aValores	:= {0,0,0,0,0,0,0,0,{{'','',0,0,0}},0,0}
	PRIVATE aTitles     := {"Tipo de Pedido","Matriz de Aprovadores","Documentos Anexos" }
	PRIVATE cDescMsg	:= ""
	PRIVATE cDescFor	:= ""
	PRIVATE oFolder		:= Nil
	PRIVATE cCondPAdt   := "0" //Controle p/ cond. pgto. com aceite de Adt. 0=normal 1=Adt
	Private	aObjects := {}
	Private _cMensagem	:= ""
	Private _cDescCelula:= CriaVar("PA4_X_DSPR")
	Private _nMegaPix	:= u_L001WndRes()
	Private _nTotCust	:= 0
	Private _nTotMeta	:= 0
	Private _oTotCust	:= Nil
	Private _oTotMeta	:= Nil
	Private _aListGer	:= {}
	Private aBkpEDT		:= {}
	Private aBkpTar		:= {}
	Private _oSay01
	Private _cCodSA2 	:= Space(6)
	Private _cDescSA2 	:= Space(80)
	Private _cLojSA2	:= Space(2)
	Private _cCCusto    := Space(14)
	Private _cProdutor 	:= space(30)
	Private _cCoord		:= space(30)
	//Private _cPgto      := CriaVar("C7_COND")
	Private _dDtIni     := dDataBase
	Private _dDtFim    	:= dDataBase
	Private _dVencFor  	:= CTOD("  /  /  ")
	Private _cObsApro  	:= ""
	Private _cCboBX1 	:= "Nao Aplica"
	Private _cCboBX2 	:= "Nao"
	Private _cCboBX3 	:= ""
	Private _cCboBX4	:= ""
	Private _cCboBX5 	:= "Nao"
	Private _cCboBX6 	:= "Nao"
	Private _cMemo1    	:= ""
	Private _aHeadACB	:= {}
	Private _aColACB	:= {}
	Private _nVcrdsp 	:= 0
	Private _oGetSC7    := Nil
	Private _oDlgACB   	:= Nil
	Private _oObsApro  	:= ""
	Private _oMemo1
	Private _oSay02
	Private _oSay03
	Private _oSay04
	Private _oSay05
	Private _oSay06
	Private _oSay07
	Private _oSay08
	Private _oSay09
	Private _oSayCred
	Private _oSay11
	Private _oCboBX1
	Private _oCboBX2
	Private _oCboBX3
	Private _oCboBX4
	Private _oCboBX5
	Private _oCboBX6
	Private _oSayDescCelula := Nil
	Private oSayNomeForn	:= space(15)
	Private _cNomeForn 		:= space(15)
	Private _cDescPagto		:= space(30)
	Private _cNomeGestor:= CriaVar("Z9_GESTOR")
	Private _lEnable	:= .t.
	
	Private _nPosProd 	:= 0
	Private _nDesc    	:= 0
	Private _nDescTar  	:= 0
	Private _nCC    	:= 0
	Private _nPosUM 	:= 0
	Private _nPosQuant 	:= 0
	Private _nPosPreco 	:= 0
	Private _nPosMetTot	:= 0
	Private _nPosCusTot	:= 0
	Private _nVlrNF 	:= 0
	Private _nTarefa   	:= 0
	Private _nPosSldOrc := 0
	Private _nPosSldMet := 0
	
	
	AAdd( aObjects, { 0,    75, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )
	
	aSizeAut:= {0,0,495,272,990,580,17}
	aSizeAut:= MsAdvSize(,.F.,400)
	aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,{{10,40,105,140,200,234,275,200,225,260,285,265},;
		{10,40,105,140,200,234,63},{5,70,160,205,295},;
		{6,34,200,215},;
		{6,34,80,113,160,185},;
		{6,34,245,268,260},;
		{10,50,150,190},;
		{273,130,190},;
		{8,45,80,103,139,173,200,235,270},;
		{133,190,144,190,289,293},;
		{142,293,140},;
		{9,47,188,148,9,146} } )
	
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definicao dos MsGETS do Cabecalho do Pedido de Compras        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	n1 :=aPosObj[1][1]
	n2 :=aPosObj[1][2]
	n3 :=(aPosObj[1][3]-16) + 15
	n4 :=aPosObj[1][4]-07
	
	@ n1, n2 TO n3,n4 LABEL '' OF oDlg PIXEL
	
	oSayCelula := TSay():New(aPosObj[1][1]+10,aPosGet[1,1],{||"Centro de Custo:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 041,006)
	
	@ aPosObj[1][1]+8,aPosGet[1,2]-25 MSGET _oSayDescCelula;
		VAR 	_cDescCelula;
		F3    "PA4NEW";
		Valid( NaoVazio() .And. A009VldGet("CELULA") );
		Size 	0125,006 HASBUTTON;
		COLOR CLR_BLACK PIXEL OF oDlg
	
	
	
	_oSayDescCelula:SetCSS(SAY_CSS)
	
	
	oSayGest  := TSay():New(aPosObj[1][1]+10,aPosGet[1,3]-055,{||"Gestor.:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 041,006)
	@ aPosObj[1][1]+8,aPosGet[1,3]-033 MSGET oSayGestor;
		VAR _cNomeGestor;
		F3 "SZ9NOM";
		VALID A009VldGet("GESTOR");
		SIZE 0125,006 HASBUTTON;
		PICTURE "@!";
		WHEN    _lEnable; //.F.;
		OF oDlg PIXEL
	oSayGestor:SetCSS(SAY_CSS)
	
	oSayDe := TSay():New(aPosObj[1][1]+10,aPosGet[1,4]+015,{||"Duração De:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 041,006)
	@ aPosObj[1][1]+8,aPosGet[1,4]+050 MSGET _oSay03;
		VAR 	_dDtIni;
		Size 	046,006 HASBUTTON;
		COLOR CLR_BLACK PIXEL OF oDlg
	_oSay03:SetCSS(SAY_CSS)
	
	
	oSayAte := TSay():New(aPosObj[1][1]+10,aPosGet[1,4]+111,{||"Duração Até:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 041,006)
	
	@ aPosObj[1][1]+8, aPosGet[1,4]+146  MSGET	_oSay04;
		VAR _dDtFim;
		Size 046,006 HASBUTTON;
		COLOR CLR_BLACK PIXEL OF oDlg
	_oSay04:SetCSS(SAY_CSS)
	
	oSayForn  := TSay():New(aPosObj[1][1]+31,aPosGet[1,1],{||"Fornecedor.:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 041,006)
	@ aPosObj[1][1]+31,aPosGet[1,2]-25 MSGET oSayNomeForn;
		VAR _cDescSA2;
		F3 "SA2NOM";
		VALID A009VldGet("FOR");
		SIZE 0125,006 HASBUTTON;
		PICTURE "@!";
		WHEN    .t.; //.F.;
		OF oDlg PIXEL
	oSayNomeForn:SetCSS(SAY_CSS)
	
	oSayCredito := TSay():New(aPosObj[1][1]+31,aPosGet[1,3]-055,{||"Saldo DDI (R$)"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 035,016)
	@ aPosObj[1][1]+31,aPosGet[1,3]-019 MSGET _oSayCred;
		VAR _nVCrdsp;
		When .F.;
		Picture "@E 999,999,999.99";
		Size 112,006 HASBUTTON;
		COLOR CLR_BLACK PIXEL OF oDlg
	_oSayCred:SetCSS(SAY_CSS)
	
	oSayAcord := TSay():New(aPosObj[1][1]+31,aPosGet[1,4]+015,{||"Dt 1º Pagto.:"},oDlg,,,,,,.T.,CLR_GRAY,CLR_LIGHTGRAY, 035,016)
	@ aPosObj[1][1]+31,aPosGet[1,4]+050 MSGET _oSay11;
		VAR _dVencFor;
		Size 046,006 HASBUTTON;
		COLOR CLR_BLACK PIXEL OF oDlg
	_oSay11:SetCSS(SAY_CSS)
	
	// GetDados - Pedido de Compra
	
	a009GDadoSC7(_aTarefas)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Criacao dos Folders da Area do Rodape do PC ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosSup := aPosObj[3,1] - 030 //aPosObj[3,1]
	oFolder := TFolder():New(nPosSup,aPosObj[3,2],aTitles,{"HEADER"},oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],(aPosObj[3,3]+100)-aPosObj[3,1],)
	oFolder:BCHANGE := { | | a009ConsAprov() }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³GetDados - Pedido de Compra.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	a009GDadoACB()
	
	
	@ 006,aPosGet[3,1]+115 SAY OemToAnsi("Compra Contra?");
		OF oFolder:aDialogs[1] PIXEL ;
		SIZE 055,009
	
	@ 005,aPosGet[3,1]+170 ComboBox _oCboBX3;
		VAR _cCboBX3;
		Items _aCmbBx3;
		When A009HabCmb("CMB03")	;
		Size 072,010  OF oFolder:aDialogs[1] PIXEL
	
	
	@ 025,aPosGet[3,1]+115 SAY OemToAnsi("Tipo Pagamento?");
		OF oFolder:aDialogs[1] PIXEL ;
		SIZE 055,009
	
	@ 024,aPosGet[3,1]+170 ComboBox _oCboBX4;
		VAR _cCboBX4;
		Items _aCmbBx4;
		When A009HabCmb("CMB04");
		Size 072,010;
		PIXEL OF oFolder:aDialogs[1]
	
	@ 044,aPosGet[3,1]+115 SAY OemToAnsi("Gera DDI(Crédito)?");
		OF oFolder:aDialogs[1] PIXEL;
		SIZE 060,009
	
	@ 043,aPosGet[3,1]+170 ComboBox _oCboBX5;
		VAR _cCboBX5;
		Items _aCmbBx5;
		Size 072,010 PIXEL OF oFolder:aDialogs[1]
	
	@ 063,aPosGet[3,1]+115 SAY OemToAnsi("Utiliza DDI(Crédito)?");
		OF oFolder:aDialogs[1] PIXEL;
		SIZE 060,009
	
	@ 062,aPosGet[3,1]+170 ComboBox _oCboBX6;
		VAR _cCboBX6;
		Items _aCmbBx6;
		When GETMV("MV_RETDDI");
		Size 072,010 PIXEL OF oFolder:aDialogs[1]
	
	@ 005,aPosGet[3,1]+280 SAY OemToAnsi("Obs. Comprador:");
		OF oFolder:aDialogs[1];
		PIXEL SIZE 060,010
	
	@ 020,aPosGet[3,1]+280 GET _oObsApro;
		Var _cObsApro MEMO;
		Size 140,030;
		VALID(Iif(_nOpca == 2, .t., a009vldObs(@_cObsApro)));
		PIXEL OF oFolder:aDialogs[1]
	
	nTipoPed := 1
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{|| IIF(A009TDOK(@_cGrpSCR), (_nOpca:= 1, oDlg:End()), _nOpca:= 2 )  },{|| _nOpcA:=0, oDlg:End()},,aButtons)) CENTERED
	// ENCHOICEBAR(oDLGOrca,bOK,bCANCEL,,aButtons)
	
	If _nOpca == 1
		
		_cRet := ""
		MsgRun('Aguarde.... Gerando Pedido...',, {|| _cRet:= A009GerPC(_cGrpSCR) })
		If !Empty(_cRet)
			_cMensagem := ""
			If "ERRO" $ _cRet
				_cMensagem := "Erro na geração do Pedido de Compras...."+Chr(13)+Chr(10)+_cRet
			Else
				_cMensagem := 'Pedido de Compras Gerado com Sucesso!'+chr(13)+chr(10)+'Codigo ['+_cRet+']'
			EndIf
			ApMsgAlert(_cMensagem, 'Inclusão de PC') //(_cMensagem)
		EndIf
		
	EndIf
	
Return(Nil)



//-------------------------------------------------------------------
/*/A009TDOK
Validacao as informacoes na Confirmacao da Tela de Pedido de Compra PMS
@aParam
@author		Jose Carlos
@since		13/01/2006
@obs
/*/
//--------------------------------------------------------------------
Static Function A009TDOK(_cGrpSCR)
	Local _aArea		:= GetArea()
	Local _lRetorno		:=.T.
	Local _nLinha		:= 0
	Local _nVlrCrd		:= 0
	Local _aTarefas		:= {}
	
	_aColSC7:=_oGetSC7:aCols
	
	If Empty(_cCodSA2)
		ApMsgAlert("*Favor informar o Fornecedor.", "Atenção")
		_lRetorno := .F.
	ElseIf Empty(_dDtIni)
		ApMsgAlert("*Favor preencher a data Inicial do prazo de entrega.", "Atenção")
		_lRetorno := .F.
	ElseIf Empty(_dDtFim)
		ApMsgAlert("*Favor preencher a data Final do prazo de entrega.", "Atenção")
		_lRetorno := .F.
		
	ElseIf  _dDtIni < dDataBase
		
		ApMsgAlert( "*Data Inicial do prazo de entrega deve ser maior que a data atual do sistema.", "Atenção")
		_lRetorno := .F.
		
	ElseIf _dDtFim < _dDtIni
		
		ApMsgAlert( "*Data Final do prazo de entrega esta menor que data Inicial do prazo de entrega.", "Atenção")
		_lRetorno := .F.
		
	ElseIf 	Empty(_cCboBX3)
		ApMsgAlert("*Definir Compra Contra", "Atenção")
		_lRetorno := .F.
	ElseIf Alltrim(_cCboBX6)=="Sim"	.And. _nVCrdSP==0
		
		ApMsgAlert("*Fornecedor não possui credito", "Operacao não permitida")
		_lRetorno := .F.
		
	ElseIf Alltrim(_cCboBX5)=="Sim"	.And. Alltrim(_cCboBX6)=="Sim"
		
		ApMsgAlert("*Pedido não permite Gerar Credito e Utiliza Credito ao mesmo tempo", "Operacao não permitida")
		_lRetorno := .F.
	ElseIf Alltrim(Upper(_cCboBX3))==Alltrim(Upper("Cliente")) .And. Empty(_cCboBX4)
		MSGSTOP("*Definir Tipo de Pagamento")
		_lRetorno := .F.
		
	ElseIf Empty( dtos(_dVencFor) )
		MSGSTOP("*Favor definir data de Vencto Acordada com o Fornecedor!")
		_lRetorno := .F.
	Endif
	
	If _lRetorno
		
		For _nLinha:= 1 To Len(_aColSC7)
			
			If !_aColSC7[_nLinha][Len(_aColSC7[_nLinha])] 	// linha deletada
				
				If Empty(_aColSC7[_nLinha][_nPosProd] )
					ApMsgAlert("*Favor informar o codigo do Produto.", "Atenção")
					_lRetorno := .F.
					Exit
				Elseif ( _aColSC7[_nLinha][_nPosQuant] == 0 )
					ApMsgAlert("*Favor informar a quantidade do produto.", "Atenção")
					_lRetorno := .F.
					Exit
					
					/*Elseif Alltrim(_cCboBX5)=="Sim" .And. _aColSC7[_nLinha][_nVlrNF]>0 .And. _aColSC7[_nLinha][_nPosPreco]>=_aColSC7[_nLinha][_nVlrNF]
					Aviso("Atencao","*O Credito não poderá ser gerado porque o preco do Produto é maior ou igual ao Valor Negociado.",{"Ok"})
					_lRetorno := .F.
					Exit
					*/
					/*
				ElseIf Empty(_aColSC7[_nLinha,_nCC])
					Aviso("Atencao","*Favor preencher Centro de Custo.",{"Ok"})
					_lRetorno := .F.
					*/
					
				Elseif	Alltrim(_cCboBX6)=="Sim" .And. _aColSC7[_nLinha][_nPosPreco]>0 .And. _aColSC7[_nLinha][_nVlrNF]>=_aColSC7[_nLinha][_nPosPreco]
					
					ApMsgAlert("*O Credito não poderá ser utilizado porque o Valor negociado é maior ou igual ao preco do Produto.", "Atenção")
					_lRetorno := .F.
					Exit
					
				Elseif	Alltrim(_cCboBX5)=="Sim" .And. _aColSC7[_nLinha][_nPosPreco]>=0 .And. _aColSC7[_nLinha][_nPosPreco] > _aColSC7[_nLinha][_nVlrNF]
					
					ApMsgAlert("*O valor de Credito deve ser maior que o Preço do Produto.", "Atenção")
					_lRetorno := .F.
					Exit
					
				Elseif	Alltrim(_cCboBX6)=="Sim"
					
					If _aColSC7[_nLinha][_nPosPreco]==0 .And._aColSC7[_nLinha][_nVlrNF]>0
						_nVlrCrd+= _aColSC7[_nLinha][_nVlrNF]
					ElseIf _aColSC7[_nLinha][_nVlrNF]==0 .And. _aColSC7[_nLinha][_nPosPreco]>0
						_nVlrCrd+= _aColSC7[_nLinha][_nPosPreco]
					Else
						_nVlrCrd+= _aColSC7[_nLinha][_nPosPreco]-_aColSC7[_nLinha][_nVlrNF]
					Endif
					
				ElseIf Alltrim(_cCboBX5)== "Nao" .And. Alltrim(_cCboBX6)== "Nao"
					
					If _aColSC7[_nLinha][_nPosPreco] == 0
						ApMsgAlert( "* Campo Valor Total nao pode ser igual a 0(Zero)! Defina um valor para o Item. "+cValtoChar(_nLinha) , "Atenção")
						_lRetorno := .F.
						Exit
					EndIf
				Endif
				
				//Para meta negativa, deverah ser informado uma observacao.
				If _aColSC7[_nLinha, GdFieldPos("SLDMET", _oGetSC7:aHeader)] <= 0
					If Empty(_cObsApro)
						
						ApMsgAlert("* Favor preencher a Observação do Pedido!", "Atenção")
						_lRetorno := .F.
						Exit
					EndIf
				EndIf
				// Montagem das tarefas para validar grupo de aprovacao.
				If Empty(_aColSC7[_nLinha,_nTarefa])
					
					//aAdd(_aTarefas,{"2.01",0.00, 0.00})
					ApMsgAlert("* Favor preencher a Tarefa(Linha a ser feita o Pedido!", "Atenção")
					_lRetorno := .F.
					Exit
				Else
					aAdd(_aTarefas,{_aColSC7[_nLinha,_nTarefa], _aColSC7[_nLinha,_nPosPreco], _aColSC7[_nLinha,_nPosMetTot] })
				EndIf
			EndIf
		Next
		
		If Alltrim(_cCboBX6)=="Sim"
			If _nVlrCrd > _nVCrdSP
				
				ApMsgAlert("*O Valor do Credito utilizado não poderá ser maior que o Credito do Fornecedor.", "Atenção")
				_lRetorno := .F.
				
			Endif
		Endif
		
		If _lRetorno .And. len(_aTarefas) > 0
			
			_cGrpSCR := a009DefGrupo(_aTarefas)
			
			If Empty(_cGrpSCR)
				
				ApMsgAlert("*"+"Grupo de Aprovação não existente. Verifique com o Administrador do Sistema."+CRLF+" Célula de Negócio", "Atenção")
				_lRetorno := .F.
			EndIf
		EndIf
		
	Endif
	RestArea(_aArea)
Return _lRetorno
//-------------------------------------------------------------------
/*A009VLDCPO
Funcao que valida CC e Produto na inclusao do pedido por meio da rotina
especifico Efetivar do PMS
@aParam
@author		Imfoc
@since		24/01/2012
*/
//--------------------------------------------------------------------
User Function A009VLDCPO()
	Local _aArea:=GetArea()
	Local _lRet:=.T.
	If READVAR() == "M->C7_PRODUTO"
		
		DbSelectArea("SB1")
		SB1->(DbSetorder(1))
		If !SB1->( Dbseek(xFilial("SB1")+M->C7_PRODUTO) )
			
			ApMsgAlert("*Produto nao Cadastrado.", "Atenção")
			_lRet := .f.
		Else
			If SB1->B1_MSBLQL == "1"
				ApMsgAlert("*Produto Bloqueado para uso!", "Atenção")
				_lRet := .f.
			Else
				DbSelectArea("PA4")
				PA4->(DbSetOrder(1))//PA4_FILIAL+PA4_X_COD+PA4_X_CDPR+PA4_X_PROD+PA4_X_CC
				If PA4->(DbSeek(xFilial("PA4")+AvKey(_cTipoPrj,"PA4_X_COD")))
					Do While PA4->(!Eof()) .And. Alltrim(PA4->PA4_X_COD)==Alltrim(_cTipoPrj)
						If Alltrim(PA4->PA4_X_PROD)==Alltrim(SB1->B1_COD)
							
							ApMsgAlert("*Produto genérico não poderá ser utilizado.", "Atenção")
							_lRet := .F.
							exit
						Endif
						PA4->(DbSkip())
					End
				Endif
			Endif
			If _lRet
				_oGetSC7:ACOLS[_oGetSC7:NAT][_nDesc] :=SB1->B1_DESC
				_oGetSC7:ACOLS[_oGetSC7:NAT][_nPosUM]:=SB1->B1_UM
				_oGetSC7:Refresh()
			Endif
		Endif
	Endif
	RestArea(_aArea)
Return _lRet

//-------------------------------------------------------------------
/*A009HabCmb
Tratamento referente ao Combo da tela do pedido
@aParam
@author		Marcos Kato
@since		20/02/2012
@uso        MATA097
*/
//--------------------------------------------------------------------
Static Function A009HabCmb(_cTpCmp)
	Local _aArea := GetArea()
	Local _lRet  := .T.
	
	If _cTpCmp == "CMB04" //Tipo Pagamento
		If Alltrim(_cCboBX3)=="TV1"
			_lRet:=.F.
		Else
			_lRet:=.T.
		Endif
	Endif
	_oCboBX4:Refresh()
	RestArea(_aArea)
Return(_lRet)

//-------------------------------------------------------------------
/*/A009VldGet()
Valida os dados do fornecedor e centrod e custo
@aParam
@author		Marcos Kato
@since		20/02/2012
@uso        MATA097
/*/
//--------------------------------------------------------------------
Static Function A009VldGet(_cTipo)
	Local _aArea :=	GetArea()
	Local _lRet	 := .T.
	Local cQuery := ""
	
	_lEnable := .t.
	
	Do Case
	Case _cTipo == "CELULA"
		
		_cGestor 	 := CriaVar("Z9_CODIGO")
		_cNomeGestor := CriaVar("Z9_GESTOR")
		
		If !Empty(_cDescCelula)
			
			/*
			_cDescCelula:= PA4->PA4_X_DSPR
			_cCelula 	:= PA4->PA4_X_COD
			*/
			
			cQuery := " SELECT	PA4_X_DSPR, PA4_X_COD, PA4_CC  "
			cQuery += "	FROM "+	RetSqlName("PA4")+" (NOLOCK) PA4 "+CRLF
			cQuery += "	WHERE "
			cQuery += "			PA4.PA4_X_COD  = '"+_cTipoPrj+"' "+CRLF
			cQuery += "		AND PA4.PA4_X_DSPR = '"+_cDescCelula+"'"
			cQuery += "		AND PA4.D_E_L_E_T_ = '' "
			
			If Select("TPA4") > 0
				TPA4->(dbCloseArea())
			EndIf
			
			TcQuery cQuery New Alias "TPA4"
			
			DbSelectarea("TPA4")
			If !TPA4->(Eof())
				
				_cCelula 	:= TPA4->PA4_X_COD
				_cDescCelula:= TPA4->PA4_X_DSPR
				_cCusto 	:= TPA4->PA4_CC
				
				// Caso tenha Gestor Atrelado no Centro de Custo,
				
				If !Empty(_cCusto)
					
					DbSelectArea("CTT")
					CTT->(DbSetOrder(1))
					If CTT->(DbSeek( xFilial("CTT")+AvKey(_cCusto,"CTT_CUSTO")))
						
						If CTT->(FieldPos("CTT_GESTOR"))>0
							_cGestor := CTT->CTT_GESTOR
						Else
							_cGestor := CriaVar("Z9_CODIGO")
						EndIf
						
						If !Empty(_cGestor)
							
							DbSelecTarea("SZ9")
							SZ9->(DbSetOrder(1))
							If SZ9->(DbSeek( xFilial("SZ9")+ AvKey(_cGestor,"Z9_GESTOR")))
								
								_cGestor 	 := SZ9->Z9_CODIGO
								_cNomeGestor := SZ9->Z9_GESTOR
								
								_lEnable 	 := .f.
								
								If ALLTRIM(SZ9->Z9_MSBLQL)=="1"
									ApMsgAlert("*O Gestor "+Alltrim(_cNomeGestor)+" encontra-se bloqueado! ", "Atenção")
									_lRet := .F.
								EndIf
							Else
								
								_cGestor 	 := CriaVar("Z9_CODIGO")
								_cNomeGestor := CriaVar("Z9_GESTOR")
								
							EndIf
						Else
							_cGestor 	:= CriaVar("Z9_CODIGO")
							_cNomeGestor:= CriaVar("Z9_GESTOR")
							_lEnable 	:= .t.
						EndIf
						
					EndIf
				EndIf
				
			Else
				_cCelula 	 := CriaVar('PA4_X_COD')
				_cDescCelula := CriaVar('PA4_X_DSPR')
				_cCusto		 := CriaVar('PA4_CC')
				ALERT("*Atenção! Descrição do Centro de Custo Inválida!")
				_lRet := .f.
			EndIf
		Else
			ALERT("*Atenção! Descrição do Centro de Custo Inválida!")
			_lRet := .f.
		EndIf
		
	Case _cTipo == "FOR"
		
		
		_cCodSA2 := SA2->A2_COD
		
		If !Empty(_cCodSA2)
			
			DbSelectArea("SA2")
			SA2->(DbSetOrder(1))
			//			If SA2->(DbSeek(xFilial("SA2")+AvKey(_cDescSA2,"A2_NOME")))
			If SA2->(DbSeek(xFilial("SA2")+AvKey(_cCodSA2,"A2_COD")))
				_cCodSA2 	:= SA2->A2_COD
				_cLojSA2 	:= Alltrim(SA2->A2_LOJA)
				_cDescSA2 	:= SA2->A2_NOME
				_nVCrdsp 	:= SA2->A2_X_VLCRED
				oSayNomeForn:Refresh()
			Else
				_cCodSA2 	:= Space(6)
				_cLojSA2    := Space(2)
				_cDescSA2   := Space(Tamsx3('A2_NOME')[1])
				ALERT("*Atenção! Nome de Fornecedor Inválido!")
				_lRet := .f.
			Endif
			
			If _lRet
				If SA2->A2_MSBLQL == '1'
					ALERT("*Atenção! Este Fornecedor encontra-se BLOQUEADO!")
					_lRet:= .F.
				Else
					_lRet:= .T.
				EndIf
			EndIf
			
			
		EndIf
		
	Case _cTipo == "CTT"
		If !Empty(_cCCusto)
			DbSelecTarea("CTT")
			CTT->(DbSetOrder(1))
			If CTT->(DbSeek( xFilial("CTT") + AvKey(_cCCusto,"CTT_CUSTO")))
				If ALLTRIM(CTT->CTT_BLOQ)=="1"
					
					ApMsgAlert("*O Centro de Custo "+Alltrim(_cCCusto)+" bloqueado. "+Chr(13)+Chr(10)+"Informe outro centro de custo ou entre em contato com a Contabilidade ou com a Controladoria.", "Atenção")
					_lRet := .F.
				EndIf
			Else
				ApMsgAlert( "*O Centro de Custo informado "+Alltrim(_cCCusto)+" não cadastrado.", "Atenção")
				_lRet := .F.
			Endif
		Endif
		
	Case _cTipo == "GESTOR"
		
		If !Empty(_cNomeGestor)
			
			DbSelecTarea("SZ9")
			SZ9->(DbSetOrder(2))
			If SZ9->(DbSeek( xFilial("SZ9")+ AvKey(_cNomeGestor,"Z9_GESTOR")))
				
				_cGestor 	 := SZ9->Z9_CODIGO
				_cNomeGestor := SZ9->Z9_GESTOR
				
				If ALLTRIM(SZ9->Z9_MSBLQL)=="1"
					ApMsgAlert("*O Gestor "+Alltrim(_cNomeGestor)+" encontra-se bloqueado! ", "Atenção")
					_lRet := .F.
				EndIf
				
			Else
				ApMsgAlert( "*Gestor não Localizado!", "Atenção")
				_lRet := .F.
			Endif
		Else
			ApMsgAlert( "*Gestor não localizado! ", "Atenção")
		Endif
		
	EndCase
	RestArea(_aArea)
	
Return(_lRet)


//-------------------------------------------------------------------
/*/A009AC9ACB
Grava os dados da Tabela AC9 e ACB
@aParam
@author		Marcos Kato
@since		12/12/2011
/*/
//--------------------------------------------------------------------
Static Function A009AC9ACB(_cNumPC)
	Local _aArea	:=GetArea()
	Local _nX    	:=0
	Local _nY     	:=0
	Local _nExtArq	:=0
	Local _nPosArq	:=0
	Local _cExtArq	:=""
	Local _cNomArq	:=""
	//Local _cCodEnt	:="SC7"
	Local _cLetra 	:="A"
	Local _cCodObj	:=""
	Local _cDirDoc	:=MsDocPath()
	Default _cNumPC	:=""
	
	If !Empty(_cNumPC)
		For _nX:=1 To Len(_oDlgACB:ACOLS)
			If !_oDlgACB:ACOLS[_nX][2] .And. !Empty(_oDlgACB:ACOLS[_nX][1])
				_cCodObj:=GetSxeNum("ACB","ACB_CODOBJ")
				If _nX<>1
					_cLetra    := Soma1(_cLetra)
				Endif
				_nPosArq:=1
				_cNomArq:=Alltrim(_oDlgACB:ACOLS[_nX][1])
				_nExtArq:=0
				_cExtArq:=""
				For _nY:=1 To Len(_oDlgACB:ACOLS[_nX][1])
					_nPosArq:=1
					_nPosArq:=At("\",Substr(_cNomArq,_nPosArq,Len(_cNomArq)))
					_cNomArq:=Substr(_cNomArq,_nPosArq+1,Len(_cNomArq))
					If _nPosArq==0
						_nExtArq:=AT(".",_cNomArq)
						_cExtArq:=Substr(_cNomArq,_nExtArq,Len(_cNomArq))
						Exit
					Endif
				Next
				__CopyFile(_oDlgACB:ACOLS[_nX][1],_cDirDoc+"\"+_cNomArq)
				
				//	CpyS2T(_oDlgACB:ACOLS[_nX][1],cDirDoc+"\",.T.)
				FRename(_cDirDoc+"\"+_cNomArq,_cDirDoc+"\"+Alltrim(_cNumPC)+_cLetra+_cExtArq)
				
				DbSelectArea("ACB")
				ACB->(DbSetOrder(1))
				ACB->(DbGoTop())
				If !ACB->(DbSeek(xFilial("ACB")+AvKey(_cCodObj,"ACB_CODOBJ")))
					RecLock("ACB",.T.)
					ACB->ACB_FILIAL:=xFilial("ACB")
					ACB->ACB_CODOBJ:=_cCodObj
					ACB->ACB_DESCRI:=_cNomArq
					ACB->ACB_OBJETO:=Alltrim(_cNumPC)+_cLetra+_cExtArq
					ACB->(MsUnLock())
					
					RecLock("AC9",.T.)
					AC9->AC9_FILIAL:=xFilial("AC9")
					AC9->AC9_FILENT:=CriaVar("AC9_FILENT")
					AC9->AC9_CODOBJ:=_cCodObj
					AC9->AC9_CODENT:=_cNumPC
					AC9->AC9_ENTIDA:="SC7"
					AC9->(MsUnLock())
					ConfirmSX8()
				Endif
			Endif
		Next
	Endif
	RestArea(_aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/a009Filtra
Filtra ListBox passado por Parametro.
@aParam
@author		Fonseca
@since		06/02/2014
@obs
/*/
//--------------------------------------------------------------------
Static Function a009Filtra(cPesq, _nColuna, _oListEdt, _aListBox, aListEdt)
	Local _aArea	:= GetArea()
	Local i			:= 0
	Local aNewList 	:= {}
	Default aListEdt:= {}
	cPesq := Alltrim(cPesq)
	
	If !Empty(cPesq)
		For i:= 1 To Len(_aListBox)
			If cPesq $ Alltrim(_aListBox[i,_nColuna]) // Substr(_aListEDT[i,_nColuna],1,Len(cPesq))
				aAdd(aNewList, _aListBox[i])
			Endif
		Next i
		
		If len(aNewlist) > 0
			_aListBox	  	:= aClone(aNewlist)
			_oListEdt:aArray:= _aListBox
		EndIf
	EndIf
	
	If Len(aListEdt) > 0
		_aListBox	  	:= aClone(aListEdt)
		_oListEdt:aArray:= _aListBox
	EndIf
	
	cPesq := cPesq+Space(60-len(cPesq))
	RestArea(_aArea)
	_oListEdt:Refresh()
	
Return(.t.)

//-------------------------------------------------------------------
/*/a009DefGrupo
Define o Grupo de Aprovadores.
@aParam
@author		Fonseca
@since		06/02/2014
@obs
/*/
//--------------------------------------------------------------------
Static Function a009DefGrupo(_aTarefas)
	Local _cRetGrupo  := ""
	Local i			  := 0
	Local _cTarefaIN  := ""
	Local _lOk		  := .t.
	Default _aTarefas := {}
	
	If !Empty(_cNomeGestor) .And. len(_aTarefas) > 0
		
		aEval(_aTarefas, {|aT| _cTarefaIN+="'"+Alltrim(aT[01])+"',"})
		_cTarefaIN := substr(_cTarefaIN,1,len(_cTarefaIN)-1)
		
		cQuery := " SELECT	"
		cQuery += "			C7_CODPSP, 					"+CRLF
		cQuery += "			C7_TAREFA, 					"+CRLF
		cQuery += "			SUM(C7_TOTAL) AS TOTPEDIDO "+CRLF
		cQuery += "	FROM "+	RetSqlName("SC7")+"(NOLOCK) SC7 "+CRLF
		cQuery += "	INNER JOIN "+RetSqlName("AF9")+" (NOLOCK) AF9 "+CRLF
		cQuery += "			ON AF9.AF9_PROJET = SC7.C7_CODPSP AND AF9.AF9_TAREFA = SC7.C7_TAREFA AND AF9.D_E_L_E_T_ = '' "+CRLF
		cQuery += "	INNER JOIN "+RetSqlName("AF8")+" (NOLOCK) AF8 "
		cQuery += "			ON AF8.AF8_PROJET = AF9.AF9_PROJET AND AF9.AF9_REVISA = AF8.AF8_REVISA AND AF8.D_E_L_E_T_ = '' "+CRLF
		cQuery += "	WHERE "
		cQuery += "			SC7.C7_CODPSP = '"+_cProjeto+"' "+CRLF
		cQuery += "		AND SC7.C7_TAREFA IN("+_cTarefaIN+")"+CRLF
		cQuery += "		AND SC7.D_E_L_E_T_ = '' "+CRLF
		cQuery += "	GROUP BY SC7.C7_CODPSP, SC7.C7_TAREFA "
		
		If Select("TPED") > 0
			TPED->(dbCloseArea())
		EndIf
		
		TcQuery cQuery New Alias "TPED"
		
		DbSelectarea("TPED")
		While !TPED->(Eof())
			_nPosTarefa := aScan(_aTarefas, {|x| Alltrim(x[01]) == Alltrim(TPED->C7_TAREFA)})
			If _nPosTarefa > 0
				_nValorTarefa := (_aTarefas[_nPosTarefa,02] + TPED->TOTPEDIDO)
				_aTarefas[_nPosTarefa,02] := _nValorTarefa
			EndIf
			TPED->(DbSkip())
		EndDo
		TPED->(dbCloseArea())
		//_cRetGrupo := u_IMFA069(_cProjeto,_cRevisao,_cCelula,_cCboBX5,_aTarefas)
		//_cRetGrupo := u_IMFA069(_cProjeto,_cRevisao,_cGestor,_cCboBX5,_aTarefas)
		_cRetGrupo := u_IMFA069(_cProjeto,_cRevisao,_cGestor,_cCboBX5,_cCboBX6,_aTarefas)
	Else
		_cRetGrupo := ""
		ApMsgAlert( "Grupo de Aprovação não definido! Verificar com o Admininstrador a Matriz de Aprovação."+CRLF+"Entre em contato com o Administrador do Sistema.", "Atenção")
	EndIf
Return(_cRetGrupo)


//-------------------------------------------------------------------
/* A009MontaGD
Monta Objeto GetDados com as informacoes dos pedidos.
@aParam
@author		Marcos Kato
@since		20/02/2012
@uso        MATA097
*/
//--------------------------------------------------------------------
Static Function A009GDadoSC7(_aTarefa)
	
	Local _aArea	   	:= GetArea()
	Local _nX           := 0
	Local _nOpca		:= 0
	Local _nTotPC		:= 0
	Local _nSupACB    	:= 080		// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local _nEsqACB  	:= 175     	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local _nInfACB    	:= 050     	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local _nDirACB     	:= 300     	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	//Local _nSupSC7    := 095     	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local _nSupSC7      := aPosObj[1][3] + 30  	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local _nEsqSC7      := 008     	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local _nInfSC7      := aPosObj[1][3] + 220 //155	   	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local _nDirSC7      := aPosObj[1][4] //450     	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	Local _aCamposGD	:= {"C7_PRODUTO","B1_DESC", /*"C7_CC",*/ /*"C7_UM",*/ "C6_QTDLIB2","C7_TOTAL","C7_X_VLNF","AFA_CUSTOT","D1_TOTAL","AFA_METTOT","C6_VALOR","AFA_TAREFA","AF9_DESCRI"}
	Local _aAlterGD 	:= {"C7_PRODUTO",/*"C7_CC",*/"C6_QTDLIB2","C7_TOTAL","C7_X_VLNF"}//{""}
	Local _aColSC7		:= {}
	Local _aInfo		:= {}
	Local _aObjects 	:= {}
	Local _aPosObj 		:= {}
	Local _aSize 		:= MsAdvSize(.T.)
	Local _cLyHd01		:= "HEADER01"
	Local _cLy01Col1	:= "HD01_Win01"
	Local _cRet         :=""
	Local _cX3Titulo	:=""
	Local _cX3F3   		:=""
	Local _cX3Valid 	:=""
	Local _cX3Campo    	:=""
	Local _cX3Context  	:=""
	Local _oMainWnd     := Nil
	Local _aHeadSC7		:= {}
	Local _oDlg			:= Nil
	Local _oFont		:= Nil
	Local _oBarTop		:= Nil
	Local _cGrpSCR 		:= ""
	Local _cPicture		:= ""
	Private _cCodSA2 	:= Space(6)
	Private _cDescSA2 	:= Space(30)
	Private _cLojSA2	:= Space(2)
	Private _cCCusto    := Space(14)
	Private _cProdutor 	:= space(30)
	Private _cCoord		:= space(30)
	Private _cPgto      := CriaVar("C7_COND")
	Private _dDtIni     := dDataBase
	Private _dDtFim    	:= dDataBase
	Private _dVencFor  	:= CTOD("  /  /  ")
	Private _oGDSC7     := Nil
	
	//ÚÄÄÄÄÄÄÄ¿
	//³aHeader³
	//ÀÄÄÄÄÄÄÄÙ
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For _nX := 1 to Len(_aCamposGD)
		
		If SX3->(DbSeek(_aCamposGD[_nX]))
			
			_cX3Titulo	:= AllTrim(X3Titulo())
			_cX3F3   	:= SX3->X3_F3
			_cX3Valid 	:= ""
			_cX3Campo   := SX3->X3_CAMPO
			_cX3Context := SX3->X3_CONTEXT
			
			Do Case
			Case _aCamposGD[_nX]=="C6_VALOR"
				_cX3Titulo	:="Saldo Meta"
				_cX3Valid	:= ""
				_cX3Campo   :="SLDMET"
				_cPicture	:= GetSx3Cache("C7_X_SLMET", "X3_PICTURE")
			Case _aCamposGD[_nX]=="C6_QTDLIB2"
				_cX3Titulo	:="Quantidade"
				_cX3Valid	:=""
				_cX3Context :="R"
			Case _aCamposGD[_nX]=="AFA_CUSTOT"
				_cX3Titulo	:="Orcado"
			Case _aCamposGD[_nX]=="AFA_METTOT"
				_cX3Titulo	:="Meta"
			Case _aCamposGD[_nX]=="D1_TOTAL"
				_cX3Titulo	:="Saldo Orcado"
				_cX3Valid	:= ""
				_cX3Campo   :="SLDORC"
				_cPicture	:= GetSx3Cache(  "C7_X_SLORC"  , "X3_PICTURE" )
			Case _aCamposGD[_nX]=="C7_PRODUTO"
				_cX3Valid	:= "u_A009VCPO()"
				_cX3F3		:= "SB1LIB"//SXB Customizados - Filtra Produtos Liberados
				
				/*Case _aCamposGD[_nX]=="C7_CC"
				_cX3Valid	:= "U_A009VCPO() .AND. "+ Alltrim(SX3->X3_VALID)
				*/
			EndCase
			
			Aadd(_aHeadSC7,{;
				_cX3Titulo,;
				_cX3Campo,;
				Iif(Empty(_cPicture),SX3->X3_PICTURE, _cPicture ) ,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				_cX3Valid,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				_cX3F3,;
				_cX3Context,;
				SX3->X3_CBOX,;
				SX3->X3_RELACAO})
		EndIf
		_cPicture := ""
	Next
	
	_nPosProd 	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C7_PRODUTO"	})
	_nDesc    	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "B1_DESC"		})
	_nDescTar  	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "AF9_DESCRI"	})
	//_nCC    	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C7_CC"		})
	//_nPosUM 	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C7_UM"		})
	_nPosQuant 	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C6_QTDLIB2"	})
	_nPosPreco 	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C7_TOTAL"	})
	_nPosMetTot	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "AFA_METTOT"	})
	_nPosCusTot	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "AFA_CUSTOT"	})
	_nVlrNF 	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "C7_X_VLNF"	})
	_nTarefa   	:= aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "AFA_TAREFA"	})
	_nPosSldOrc := aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "SLDORC"		})
	_nPosSldMet := aScan(_aHeadSC7,{|x| AllTrim(x[2]) == "SLDMET"		})
	
	//ÚÄÄÄÄÄ¿
	//³ACols³
	//ÀÄÄÄÄÄÙ
	For _nX := 1 To Len(_aTarefa)
		
		If _aTarefa[_nX][1]
			
			Dbselectarea("AF9")
			AF9->(DBSETORDER(1))
			IF AF9->(DBSEEK(XFILIAL("AF9")+_cProjeto+_cRevisao+_aTarefa[_nX][4],.F.))
				_cCCusto := Space(14)
				//Centro de Custo da EDT Pai da Tarefa
				Dbselectarea("AFC")
				AFC->(DBSETORDER(1))
				IF AFC->(DBSEEK(xFilial("AFC")+AF9->AF9_PROJET+AF9->AF9_REVISA+AF9->AF9_EDTPAI))
					If AF9->AF9_TVPVC > 0 //PROJETO
						If !Empty(AF9->AF9_CCUSTO)
							_cCCusto:= AF9->AF9_CCUSTO
						ElseIf !Empty(AFC->AFC_CCUSTO)
							_cCCusto:= AFC->AFC_CCUSTO
						Else
							_cCCusto:= AF8->AF8_CCUSTO
						Endif
					Else
						If !Empty(AF9->AF9_CCRE)
							_cCCusto:= AF9->AF9_CCRE
						ElseIf !Empty(AFC->AFC_CCRE)
							_cCCusto:= AFC->AFC_CCRE
						Else
							_cCCusto:= AF8->AF8_CUSTO2
						Endif
					Endif
				Endif
			Endif
			
			_nTotPC := u_L001TotPC(_cProjeto,_aTarefa[_nX][4])
			/*
			aAdd(_aColSC7,{;
				Space(TAMSX3("C7_PRODUTO")[1])	,;//1.Cod.Produto
			Space(TAMSX3("B1_DESC")[1])		,;//2.Descr.Produto
			Space(TAMSX3("C7_CC")[1])		,;//3.Centro de Custo 			space(TAMSX3("C7_UM")[1])		,;//4.Unid.Medida
			1								,;//5.Quantidade
			0								,;//6.Total
			0								,;//7.Valor Negociado
			_aTarefa[_nX][4]				,;//8.Cod.Tarefa
			_aTarefa[_nX][5]				,;//9.Descricao Tarefa
			_aTarefa[_nX][7]				,;//10.Orcado
			_aTarefa[_nX][7]-_nTotPC		,;//11.Saldo Orcado
			_aTarefa[_nX][8]				,;//12.Meta
			_aTarefa[_nX][8]-_nTotPC		,;//13.Saldo Meta
			.F.})
			*/
			aAdd(_aColSC7,{;
				Space(TAMSX3("C7_PRODUTO")[1])	,;//1.Cod.Produto
			Space(TAMSX3("B1_DESC")[1])		,;//2.Descr.Produto				Space(TAMSX3("C7_CC")[1])		,;//3.Centro de Custo 			space(TAMSX3("C7_UM")[1])		,;//4.Unid.Medida
			1								,;//5.Quantidade
			0								,;//6.Total
			0								,;//7.Valor Negociado
			_aTarefa[_nX][7]				,;//10.Orcado
			_aTarefa[_nX][7]-_nTotPC		,;//11.Saldo Orcado
			_aTarefa[_nX][8]				,;//12.Meta
			_aTarefa[_nX][8]-_nTotPC		,;//13.Saldo Meta
			_aTarefa[_nX][4]				,;//8.Cod.Tarefa
			_aTarefa[_nX][5]				,;//9.Descricao Tarefa
			.F.})
			
		Endif
	Next
	
	//Compra nao Prevista(caso nao tenha processado nenhum item).
	If Len(_aColSC7) == 0
		_nTotPC	:= u_L001TotPC(_cProjeto,"2.01")
		
		aAdd(_aColSC7,{ Space(TAMSX3("C7_PRODUTO")[1]),;//Cod.Produto
		Space(TAMSX3("B1_DESC")[1]),;//Descr.Produto				space(TAMSX3("C7_CC")[1]),;//Unid.Medida 					space(TAMSX3("C7_UM")[1]),;//Unid.Medida
		1,;//Quantidade
		0,;//Total
		0,;//Valor Negociado
		0,;//Orcado
		0-_nTotPC,;//Saldo Orcado
		0,;//Meta
		0-_nTotPC,;//Saldo Meta
		"2.01",;//Cod.Tarefa
		"Compra nao Prevista",;//Descricao Tarefa
		.F.})
	Endif
	
	_oGetSC7:= MsNewGetDados():New(_nSupSC7,_nEsqSC7,_nInfSC7,_nDirSC7,3,/*cLinhaOk*/,/*cTudoOk*/,/*cIniCpos*/,_aAlterGD,/*nFreeze*/,Len(_aColSC7),/*cCampoOk*/,/*cSuperApagar*/,/*cApagaOk*/,oDlg, _aHeadSC7, _aColSC7)
	
Return(Nil)


//-------------------------------------------------------------------
/* a009GDadoACB
Monta Objeto GetDados com as informacoes dos anexos do Pedido de Compras.
@aParam
@author		Fernando
@since		20/02/2012
@uso        MATA097
*/
//--------------------------------------------------------------------
Static Function a009GDadoACB()
	
	Local _aArea	   	:= GetArea()
	Local _nX           := 0
	Local _nOpca		:= 0
	Local _nTotPC		:= 0
	Local _nSupACB    	:= 005//*_nMegaPix		// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
	Local _nEsqACB  	:= 135//175//*_nMegaPix       	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
	Local _nInfACB    	:= 050//*_nMegaPix       	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
	Local _nDirACB     	:= 300//*_nMegaPix       	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
	Local _aCpoACB 		:= {"ACB_DESCRI"}
	Local _aAltACB     	:= {}
	Private _cMemo1    	:= ""
	Private _aHeadACB	:= {}
	Private _aColACB	:= {}
	Private _nVcrdsp 	:= 0
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2)) // Campo
	For _nX := 1 to Len(_aCpoACB)
		If SX3->(DbSeek(_aCpoACB[_nX]))
			Aadd(_aHeadACB,{ AllTrim(X3Titulo()),;
				SX3->X3_CAMPO	,;
				SX3->X3_PICTURE	,;
				SX3->X3_TAMANHO	,;
				SX3->X3_DECIMAL	,;
				SX3->X3_VALID	,;
				SX3->X3_USADO	,;
				SX3->X3_TIPO	,;
				SX3->X3_F3 		,;
				SX3->X3_CONTEXT	,;
				SX3->X3_CBOX	,;
				SX3->X3_RELACAO})
		EndIf
	Next
	
	// GetDados para inclusao de anexos
	_oDlgACB:= MsNewGetDados():New(_nSupACB,_nEsqACB,_nInfACB,_nDirACB,2,,,,_aAltACB,,,,,, oFolder:aDialogs[3] ,@_aHeadACB,@_aColACB)
	
	@ _nSupACB,_nDirACB+10 Button	"Anexar"   Size 030,008  Action (A009Anexa(1)) OF oFolder:aDialogs[3] PIXEL
	@ _nSupACB+15,_nDirACB+10 Button 	"Excluir"  Size 030,008 Action (A009Anexa(2)) OF oFolder:aDialogs[3] PIXEL
	
	
Return(Nil)

//-------------------------------------------------------------------
/*A009VLDCPO
Funcao que valida CC e Produto na inclusao do pedido por meio da rotina
especifico Efetivar do PMS
@aParam
@author		Imfoc
@since		24/01/2012
*/
//--------------------------------------------------------------------
User Function A009VCPO()
	Local _aArea:=GetArea()
	Local _lRet:=.T.
	If READVAR() == "M->C7_PRODUTO"
		
		DbSelectArea("SB1")
		SB1->(DbSetorder(1))
		If !SB1->( Dbseek(xFilial("SB1")+M->C7_PRODUTO) )
			
			ApMsgAlert("*Produto nao Cadastrado.", "Atenção")
			_lRet := .f.
			
		Else
			If SB1->B1_MSBLQL == "1"
				
				ApMsgAlert("*Produto bloqueado.", "Atenção")
				_lRet := .f.
			Else
				DbSelectArea("PA4")
				PA4->(DbSetOrder(1))//PA4_FILIAL+PA4_X_COD+PA4_X_CDPR+PA4_X_PROD+PA4_X_CC
				If PA4->(DbSeek(xFilial("PA4")+AvKey(_cTipoPrj,"PA4_X_COD")))
					Do While PA4->(!Eof()) .And. Alltrim(PA4->PA4_X_COD)==Alltrim(_cTipoPrj)
						If Alltrim(PA4->PA4_X_PROD)==Alltrim(SB1->B1_COD)
							
							ApMsgAlert("*Produto genérico não poderá ser utilizado.", "Atenção")
							_lRet := .F.
							exit
						Endif
						PA4->(DbSkip())
					End
				Endif
			Endif
			If _lRet
				_oGetSC7:ACOLS[_oGetSC7:NAT][_nDesc] :=SB1->B1_DESC
				//_oGetSC7:ACOLS[_oGetSC7:NAT][_nPosUM]:=SB1->B1_UM
				_oGetSC7:Refresh()
			Endif
		Endif
		
	ElseIf READVAR() == "M->C7_CC"
		
		If Empty(M->C7_CC)
			ApMsgAlert("*Favor preencher Centro de Custo.", "Atenção")
			_lRet := .F.
		EndIf
		
	Endif
	RestArea(_aArea)
Return _lRet

//-------------------------------------------------------------------
/*/ a009vldObs
Validacao para observacao do campo
@aParam
@author		Fernando
@since		22/10/2013
@obs
/*/
//--------------------------------------------------------------------
Static Function a009vldObs(_cObsApro)
	Local lRet := .t.
	If len(_cObsApro) > 240
		ApMsgAlert("Campo observação não pode ser maior que 240 caracteres!", "Atenção")
		lRet := .f.
	EndIf
	_cObsApro := Upper(_cObsApro)
Return(lRet)

//-------------------------------------------------------------------
/*/A009Anexa

@aParam
@author		Imfoc
@since		18/09/2011
*/
//--------------------------------------------------------------------
Static Function A009Anexa(_nOpcao)
	Local _aArea		:= GetArea()
	Local _nX            := 0
	Local _nDescACB		:= aScan(_oDlgACB:aHeader,{|x| AllTrim(x[2]) == "ACB_DESCRI"})
	Local _nPosACB		:= 0
	Local _cArquivo    	:= ""
	Local _aCloneACB    :={}
	If _nOpcao == 1  //Anexa o Arquivo
		
		_cArquivo := AllTrim(cGetFile(PADR("Arquivos Diversos (*.*)",27)+"|*.*|"+;
			PADR("Arquivos Excel (*.XLS)",27)+"|*.XLS|"+;
			PADR("Arquivos CSV   (*.CSV)",27)+"|*.CSV|"+;
			PADR("Arquivos PDF   (*.PDF)",27)+"|*.PDF|"+;
			PADR("Arquivos DOC   (*.DOC)",27)+"|*.DOC|",;
			"Selecione Diretorio e Arquivo",0,,.T.,49))
		If !Empty(_cArquivo)
			_nPosACB := aScan(_oDlgACB:aCols, {|aC|	UPPER(Alltrim(aC[_nDescACB])) == UPPER(Alltrim(_cArquivo)) })
			If _nPosACB > 0
				Alert("Arquivo já anexado!")
			Else
				If Len(_oDlgACB:ACOLS)== 1 .And. Empty(_oDlgACB:ACOLS[Len(_oDlgACB:ACOLS)][_nDescACB])
					_oDlgACB:ACOLS[Len(_oDlgACB:ACOLS)][_nDescACB]:=_cArquivo
				Else
					aAdd(_oDlgACB:ACOLS,{_cArquivo,.F.})
				Endif
			EndIf
		Endif
	ElseIf _nOpcao == 2  // Excluir
		If Len(_oDlgACB:ACOLS)==1
			_oDlgACB:ACOLS:={}
			aAdd(_oDlgACB:ACOLS,{"",.F.})
		Else
			_aCloneACB:=_oDlgACB:ACOLS
			_nPosACB  :=_oDlgACB:NAT
			_oDlgACB:ACOLS:={}
			For _nX:=1 To Len(_aCloneACB)
				If _nX<>_nPosACB
					aAdd(_oDlgACB:ACOLS,{_aCloneACB[_nX][_nDescACB],.F.})
				Endif
			Next
			
			_oDlgACB:oBrowse:Refresh()
			_oDlgACB:Refresh()
			
		Endif
	Endif
	_oDlgACB:Refresh()
	RestArea(_aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/A009GerPC - Gera Pedidos de Compras atrelados ao PSP
@aParam
@author		Jose Carlos
@since		13/01/2006
@uso        Especificos Imfoc
@Obs
/*/
//--------------------------------------------------------------------
Static Function A009GerPC(_cGrpSCR)
	Local _aArea	 := GetArea()
	Local _nX		 := 0
	Local i			 := 0
	Local _cTarefa 	 := ""
	Local _cDescTar  := ""
	Local _cLink     := ""
	Local _cNumSc7   := ""
	Local _cMsgError := ""
	Local _aDadSC7	 := {}
	Local _aCabSC7	 := {}
	Local _aItSC7	 := {}
	Local _aLinSC7	 := {}
	Local _nVlrSC7	 := 0
	Local _nTotCredGr:= 0
	Local lOpc	     := .F.
	Local _nCredUt   := 0
	Local _lRet 	 := .t.
	Local _cNomeFor  := Substr( Alltrim(Posicione("SA2", 1, xFilial("SA2")+_cCodSA2, "A2_NREDUZ")), 1, tamsx3('C7_FORDESC')[1] )
	Private _nCredGr   := 0
	
	
	_aColSC7:=_oGetSC7:aCols
	If Len(_aColSC7) == 0
		_lRet 	   := .f.
		_cMsgError := "Não existem itens a serem Gerados para o Pedido de Compras!"
	EndIf
	
	If _lRet
		
		_cNumSC7:= A009GetNumSC7(AllTrim(_cCelula))
		
		// GetSxeNum("SC7","C7_NUM")
		//_cNumSC7  := GetNumSC7(.T.)
		
		_nVlrSC7 := 0
		
		_aCabSC7  := {}
		_aCabSC7  := {	{"C7_FILIAL"	  , xFilial("SC7")		,NIL},;
			{"C7_NUM"	  , _cNumSC7		,NIL},;
			{"C7_EMISSAO" , dDataBase		,NIL},;
			{"C7_FORNECE" , _cCodSA2		,NIL},;
			{"C7_LOJA"	  , _cLojSA2     	,NIL},;
			{"C7_CONTATO" , cUserName   	,NIL},;
			{"C7_COND"	  , "010"       	,NIL},;
			{"C7_FILENT"  , xFilial("SC7") 	,NIL}}
		
		For _nX :=1 To Len(_aColSC7)
			
			_nVlrPC  := _aColSC7[_nX][_nPosPreco]
			
			_nVlrSC7+=_aColSC7[_nX][_nPosPreco]
			
			//Validacao dos dados de Credito
			//==================================================================
			If Alltrim(_cCboBX5)=="Nao" .And. Alltrim(_cCboBX6)=="Sim"//(Credito Gerado==Nao e Credito Utilizado==Sim)
				
				//100% Credito Utilizado
				//========================================================
				If _aColSC7[_nX][_nPosPreco]==0 .And._aColSC7[_nX][_nVlrNF]>0
					_nCredUt := _aColSC7[_nX][_nVlrNF]
					_nVlrPC  := _aColSC7[_nX][_nVlrNF] //_aColSC7[_nX][_nPosPreco]//Valor Negociado
					
				ElseIf _aColSC7[_nX][_nVlrNF]==0 .And. _aColSC7[_nX][_nPosPreco]>0
					_nCredUt := _aColSC7[_nX][_nPosPreco]
					_nVlrPC  := _aColSC7[_nX][_nPosPreco]//Valor Negociado
					
				Else
					_nCredUt := _aColSC7[_nX][_nPosPreco]-_aColSC7[_nX][_nVlrNF]//Credito Gerado=Valor Pedido - Valor Negociado
					_nVlrPC  := _aColSC7[_nX][_nPosPreco]//Valor Negociado
				Endif
				_nCredGr := 0
				If _nCredUt < 0
					_cCboBX6 :="Nao"
					_nCredUt := 0
				EndIf
			ElseIf Alltrim(_cCboBX5)=="Sim" .And. Alltrim(_cCboBX6)=="Nao"//(Credito Gerado==Sim e Credito Utilizado==Nao?)
				
				//100% Credito Gerado
				//========================================================
				_nCredUt := 0
				If _aColSC7[_nX][_nPosPreco]==0 .And._aColSC7[_nX][_nVlrNF]>0
					
					_nCredGr := _aColSC7[_nX][_nVlrNF]
					
					_nVlrPC  	:= _aColSC7[_nX][_nVlrNF]
					_nTotCredGr += _nCredGr
					
				ElseIf _aColSC7[_nX][_nVlrNF]==0 .And. _aColSC7[_nX][_nPosPreco]>0
					_nCredGr := _aColSC7[_nX][_nPosPreco]
					_nVlrPC  := _aColSC7[_nX][_nPosPreco]//Valor Negociado
				Else
					_nCredGr := _aColSC7[_nX][_nVlrNF]-_aColSC7[_nX][_nPosPreco]
					_nVlrPC  := _aColSC7[_nX][_nPosPreco]//Valor Negociado
				Endif
				If _nCredGr < 0
					_cCboBX5 :="Nao"
					_nCredGr := 0
				EndIf
			ElseIf Alltrim(_cCboBX5)=="Nao" .And. Alltrim(_cCboBX6)=="Nao"
				
				_nCredGr := 0
				_nCredUt := 0
				_cCboBX5:="Nao"
				_cCboBX6:="Nao"
				
			EndIf
			
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(DbSeek(xFilial("SB1")+AvKey(_aColSC7[_nX][_nPosProd],"B1_COD")))
				_cTarefa :=""
				_cDescTar:=""
				If Empty(_aColSC7[_nX][_nTarefa])
					_cTarefa :="2.01"
					_cDescTar:="COMPRAS NAO PREVISTAS"
				Else
					_cTarefa :=_aColSC7[_nX][_nTarefa]
					_cDescTar:=_aColSC7[_nX][_nDescTar]
				Endif
				
				
				_cLink:=""
				DbSelectArea("AFA")
				AFA->(DbSetOrder(1))
				If AFA->(DbSeek(xFilial("AFA")+AvKey(_cProjeto,"AFA_PROJET")+AvKey(_cRevisao,"AFA_REVISA")+AvKey(_cTarefa,"AFA_TAREFA")))
					_cLink:=AFA->AFA_X_PLAN
				Endif
				
				_aLinSC7:={}
				
				aAdd(_aLinSC7,{"C7_ITEM"	, StrZero(_nX,4)	,NIL})
				aAdd(_aLinSC7,{"C7_PRODUTO"	, SB1->B1_COD		,NIL})
				aAdd(_aLinSC7,{"C7_QUANT"  	, 1					,NIL})
				aAdd(_aLinSC7,{"C7_PRECO"  	, Round(_nVlrPC,2) 	,  'Positivo() ' })
				aAdd(_aLinSC7,{"C7_TOTAL"  	, Round(_nVlrPC,2)	,NIL})
				aAdd(_aLinSC7,{"C7_TES"    	, "101"				,NIL})
				aAdd(_aLinSC7,{"C7_TIPO"	, 1					,NIL})//1-Pedido|2-Aut.Entrega
				aAdd(_aLinSC7,{"C7_DESCRI"	, SB1->B1_DESC		,NIL})
				aAdd(_aLinSC7,{"C7_UM"		, SB1->B1_UM		,NIL})
				aADD(_aLinSC7,{"C7_LOCAL"	, SB1->B1_LOCPAD	,NIL})
				aADD(_aLinSC7,{"C7_CC"		, _cCusto			, NIL})  //_aColSC7[_nX ,GdFieldPos("C7_CC", _oGetSC7:aHeader)], NIL})
				aADD(_aLinSC7,{"C7_APROV"	, _cGrpSCR			,NIL})
				aADD(_aLinSC7,{"C7_GRUPCOM"	, _cGrpSCR			,NIL})
				aADD(_aLinSC7,{"C7_USER"  	, __cUserID			,NIL})
				aADD(_aLinSC7,{"C7_CONAPRO"	, 'B'				,NIL})
				aADD(_aLinSC7,{"C7_DATPRF" 	,_dDtFim			,NIL})
				aADD(_aLinSC7,{"C7_DATAINI"	,_dDtIni			,NIL})
				aADD(_aLinSC7,{"C7_PROJET" 	, _cProjeto			,NIL})
				aADD(_aLinSC7,{"C7_CODPSP" 	, _cProjeto			,NIL})
				aADD(_aLinSC7,{"C7_DESCPRO"	, _cDescPrj			,NIL})
				aADD(_aLinSC7,{"C7_TAREFA" 	, _cTarefa			,NIL})
				aADD(_aLinSC7,{"C7_DESCTAR"	, _cDescTar			,NIL})
				aADD(_aLinSC7,{"C7_MOEDA"	, 1             	,NIL})
				
				If SC7->(FieldPos("C7_X_PLAN"))>0
					aADD(_aLinSC7,{"C7_X_PLAN"	, _cLink		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_GESTO")) > 0
					aADD(_aLinSC7,{"C7_X_GESTO"	,_cGestor		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_CMCNT")) > 0
					aADD(_aLinSC7,{"C7_X_CMCNT"	,_cCboBx3		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_TPPGT")) > 0
					aADD(_aLinSC7,{"C7_X_TPPGT"	,_cCboBx4		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_GRCRE")) > 0
					aADD(_aLinSC7,{"C7_X_GRCRE"	,_cCboBx5		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_CRESN")) > 0
					aADD(_aLinSC7,{"C7_X_CRESN"	,_cCboBx6		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_JSTOR")) > 0
					aADD(_aLinSC7,{"C7_X_JSTOR"	,_cMemo1		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_REEMB")) > 0
					aADD(_aLinSC7,{"C7_X_REEMB"	,_cMemo1		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_QUANT")) > 0
					aADD(_aLinSC7,{"C7_X_QUANT"	,_aColSC7[_nX][_nPosQuant]	,NIL})
				Endif
				/*
				If SC7->(FieldPos("C7_X_COORD")) > 0
					aADD(_aLinSC7,{"C7_X_COORD"	,_cCoord		,NIL})
				Endif
				If SC7->(FieldPos("C7_X_PROD")) > 0
					aADD(_aLinSC7,{"C7_X_PROD"	,_cProdutor		,NIL})
				Endif
				*/
				
				If !Empty(_cObsApro)
					aADD(_aLinSC7,{"C7_OBS"	 	, _cObsApro		,NIL})
					If SC7->(FieldPos("C7_X_OBDET"))>0
						aADD(_aLinSC7,{"C7_X_OBDET"	,_cObsApro	,NIL})
					Endif
				Else
					aADD(_aLinSC7,{"C7_OBS"	 	, "Automatico PMS",NIL})
					If SC7->(FieldPos("C7_X_OBDET"))>0
						aADD(_aLinSC7,{"C7_X_OBDET"	,"Automatico PMS",NIL})
					Endif
				Endif
				If SC7->(FieldPos("C7_X_VLNF"))>0
					aADD(_aLinSC7,{"C7_X_VLNF"	,Round(_aColSC7[_nX][_nVlrNf],2) ,NIL})
				Endif
				If SC7->(FieldPos("C7_X_VCGER"))>0
					aADD(_aLinSC7,{"C7_X_VCGER"	, Round(_nCredGr,2)	,NIL})
					U_A009PAV()
				Endif
				If SC7->(FieldPos("C7_X_CRDVL"))>0
					aADD(_aLinSC7,{"C7_X_CRDVL"	, Round(_nCredUt,2)	,NIL})
				Endif
				
				If SC7->(FieldPos("C7_X_VENCT"))>0
					aADD(_aLinSC7,{"C7_X_VENCT"	,_dVencFor	,NIL})
				Endif
				
				If Alltrim(_cGestor)=="020"
					aADD(_aLinSC7,{"C7_X_FLAG" 	,"P"		,NIL})//Inputado via Admin
				Endif
				
				If SC7->(FieldPos("C7_X_SLORC"))> 0 					// Saldo do Orcado na Tarefa.
					aADD(_aLinSC7,{"C7_X_SLORC" , Round(_aColSC7[_nX][_nPosSldOrc],2)	,NIL})
				Endif
				
				If SC7->(FieldPos("C7_X_SLMET"))> 0						// Saldo da Meta da Tarefa.
					aADD(_aLinSC7,{"C7_X_SLMET",Round(_aColSC7[_nX][_nPosSldMet],2)	,NIL})
				Endif
				
				If SC7->(FieldPos("C7_XTARORI"))> 0						// Tarefa que gerou Pedido de Compras.
					aADD(_aLinSC7,{"C7_XTARORI" , _cTarefa	,NIL})
				EndIf
				
				If SC7->(FieldPos("C7_XDESCTA"))> 0						// Descricao da tarefa que gerou Pedido de Compras.
					aADD(_aLinSC7,{"C7_XDESCTA"	, _cDescTar	,NIL})
				EndIf
				
				If SC7->(FieldPos("C7_XREVISA"))> 0						// Revisao atual do Projeto
					aADD(_aLinSC7,{"C7_XREVISA",_cRevisao	,NIL})
				EndIf
				
				If SC7->(FieldPos("C7_XCELULA"))> 0						// Celula do Projeto
					aADD(_aLinSC7,{"C7_XCELULA", _cCelula	,NIL})
				EndIf
				
				AADD(_aItSC7,_aLinSC7)
				
			EndIf
		Next
	EndIf
	
	If _lRet
		
		lMsErroAuto   	:= .F.
		lMsHelpAuto		:= .T. // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
		lAutoErrNoFile 	:= .T. // // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário
		
		U_A009X3()
		
		Begin Transaction
			
			MSExecAuto({|x,y,z,w,h| MatA120(x,y,z,w,h)},1,_aCabSC7,_aItSC7,3,.f.)
			If lMsErroAuto
				
				_cNumSC7:="ERRO"+Chr(13)+Chr(10)
				_cErrLog := ""
				
				//função que retorna as informações de erro ocorridos durante o processo da rotina automática
				aLog:= {}
				aLog := GetAutoGRLog()
				For _nX := 1 To Len(aLog)
					_cErrLog +=  Alltrim(aLog[_nX])+CHR(13)+CHR(10)
				Next _nX
				_cNumSC7 +="ERRO"+Chr(13)+Chr(10)+_cErrLog
				DisarmTransaction()
				
			Else
				
				//Grava dados do documentos anexados
				A009AC9ACB(_cNumSC7)
				
				DbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				If SC7->(DbSeek(xFilial("SC7")+AvKey(_cNumSC7,"C7_NUM")))
					While !SC7->(Eof()) .And. AllTrim(SC7->C7_NUM) == Alltrim(_cNumSC7)
						RecLock("SC7", .f. )
						SC7->C7_FORDESC := _cNomeFor
						MsUnLock()
						SC7->(DbSkip())
					EndDo
				EndIf
				
			EndIf
			
		End Transaction
	Else
		_cNumSC7 := "ERRO " + Iif(Empty(_cMsgError),"", Chr(13)+Chr(10)+_cMsgError) + Iif(Empty(_cErrLog),"", Chr(13)+Chr(10)+ _cErrLog)
	Endif
	RestArea(_aArea)
Return(_cNumSC7)


//-------------------------------------------------------------------
/*/A009GerPC - Gera Pedidos de Compras atrelados ao PSP
@aParam
@author		Jose Carlos
@since		13/01/2006
@uso        Especificos Imfoc
@Obs
/*/
//--------------------------------------------------------------------
Static Function a009ConsAprov()
	
	Local aArea		:= GetArea()
	Local aSavCols  := {}
	Local aSavHead  := {}
	//Local cComprador:= ""
	Local cSituaca  := ""
	Local cNumDoc   := ""
	Local cStatus   := ""
	Local cTitle    := ""
	Local cTitDoc   := ""
	Local cAddHeader:= ""
	Local cAprovador:= ""
	Local aFields 	:= {"AL_NIVEL","AL_NOME", "AL_LIBAPR"}
	Local _aHeadSCR	:= {}
	Local _aColSCR	:= {}
	Local i   		:= 0
	Local nX   		:= 0
	Local nY   		:= 0
	Local oDlg
	Local oGet
	Local oBold
	Local _aTarefas :={}
	Local cQuery 	:= ""
	Local _cGrpSCR	:= ""
	Local _nTotPC 	:= 0
	Local _cCodGrupo := ""
	Local _cNomeGrupo := ""
	Local lOk := .t.
	
	If oFolder:nOption <> 2 // 2 = Consulta Aprovadores
		Return(Nil)
	EndIf
	
	aEval(_oGetSC7:aCols, { |aPC| _nTotPC += aPC[_nPosPreco]})
	If _nTotPC == 0
		
		ApMsgAlert("Informe um valor para o Pedido de Compras", "Atenção")
		oFolder:nOption:=1
		Return(Nil)
	EndIf
	
	aEval(_oGetSC7:aCols, { |aPC| aAdd(_aTarefas,{ aPC[_nTarefa], aPC[_nPosPreco]} ) })
	_cGrpSCR := a009DefGrupo(_aTarefas)
	
	cTitle    := "Status de Aprovacao do Pedido de Compra"
	cTitDoc   := "Pedido"
	cHelpApv  := "Este pedido nao possui controle de aprovacao."
	cNumDoc   := "a Definir"
	//cComprador:= UsrRetName(__cUserID)
	cStatus   := "AGUARDANDO LIB."
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	For i:= 1 to len(aFields)
		
		SX3->(dbSetOrder(2))
		If SX3->(dbSeek( alltrim(aFields[i]) ))
			
			AADD(_aHeadSCR,{TRIM(X3Titulo()),;
				SX3->X3_CAMPO,;
				SX3->X3_PICTURE,;
				SX3->X3_TAMANHO,;
				SX3->X3_DECIMAL,;
				SX3->X3_VALID,;
				SX3->X3_USADO,;
				SX3->X3_TIPO,;
				SX3->X3_ARQUIVO,;
				SX3->X3_CONTEXT } )
		EndIf
	Next i
	
	cQuery := " SELECT	"
	cQuery += "		SAL.AL_COD,   "
	cQuery += "		SAL.AL_DESC,  "
	cQuery += "		SAL.AL_NIVEL, "
	cQuery += "		SAL.AL_APROV, SAL.AL_USER, "
	cQuery += "		SAL.AL_NOME,  "
	cQuery += "		CASE "
	cQuery += "			WHEN SAL.AL_LIBAPR = 'A' THEN 'APROVADOR' "
	cQuery += "			WHEN SAL.AL_LIBAPR = 'V' THEN 'VISTO' "
	cQuery += "		END AS AL_LIBAPR, "
	cQuery += "		SAK.AK_LIMMIN, SAK.AK_LIMMAX "
	cQuery += "	FROM "+retSqlName("SAL")+ " (NOLOCK) SAL "
	cQuery += "	INNER JOIN " +retSqlName("SAK")+ " (NOLOCK) SAK "
	cQuery += "		  ON SAL.AL_APROV = SAK.AK_COD "
	cQuery += "		  AND SAL.AL_USER = SAK.AK_USER "
	cQuery += "		  AND  SAK.AK_LIMMIN <= '"+ cvaltochar(_nTotPC) + "'"
	cQuery += "	WHERE 	SAL.D_E_L_E_T_ = '' "
	cQuery += "		AND SAL.AL_COD = '"+_cGrpSCR+"' "
	cQuery += "		ORDER BY SAL.AL_NIVEL, SAL.AL_ITEM "
	
	TcQuery cQuery  NEW ALIAS "TSCR"
	
	DbSelectArea("TSCR")
	
	If TSCR->(Eof())
		ApMsgAlert("*Gestor "+_cNomeGestor+" não possui Grupo de Aprovação.", "Atenção")
		lOk := .f.
		oFolder:nOption:=1
	Else
		While !TSCR->(Eof())
			_cCodGrupo  := alltrim(TSCR->AL_COD)
			_cNomeGrupo := alltrim(TSCR->AL_DESC)
			
			aadd(_aColSCR,Array(Len(_aHeadSCR)+1))
			nY++
			For nX := 1 to Len(_aHeadSCR)
				If ( _aHeadSCR[nX][10] != "V")
					_aColSCR[nY][nX] := TSCR->(FieldGet(FieldPos(_aHeadSCR[nX][2])))
				EndIf
			Next nX
			_aColSCR[nY][Len(_aHeadSCR)+1] := .F.
			TSCR->(dbSkip())
		EndDo
	EndIf
	TSCR->(DbCloseArea())
	
	If lOk
		
		If !Empty(_aColSCR)
			
			@ 010,aPosGet[3,1]+50 SAY OemToAnsi("Grupo de Aprovador");
				OF oFolder:aDialogs[2] PIXEL ;
				SIZE 050,009
			
			@ 020,aPosGet[3,1]+50 MsGet _oGrpApro1;
				Var _cCodGrupo;
				Picture "@!";
				When .f.;
				Size 060,009;
				PIXEL OF oFolder:aDialogs[2]
			
			_oGrpApro1:SetCSS("QLineEdit{color:#FF0000; background-color:#F5F5F5;}")
			
			@ 020,aPosGet[3,1]+110 MsGet _oGrpApro2;
				Var _cNomeGrupo;
				Picture "@!";
				When .f.;
				Size 065,009;
				PIXEL OF oFolder:aDialogs[2]
			
			_oGrpApro2:SetCSS("QLineEdit{color:#FF0000; background-color:#F5F5F5;}")
			
			
			oGet:= MsNewGetDados():New(010,205,080,515,4,,,,{},,Len(_aColSCR),,,,oFolder:aDialogs[2],@_aHeadSCR,@_aColSCR)		 //MSGetDados():New(038,003,120,250,nOpcx,,,"")
			oGet:Refresh()
		EndIf
	EndIf
	RestArea(aArea)
Return(Nil)


//-------------------------------------------------------------------
/*/ A038F301
Consulta Generica a ser chamada via F3
Tratativa para Produto(SB1), Fornecedor(SA2), Centro de Custo(CTT) e Aprovador(SAK)
@aParam
@author		Marcos Kato
@since		05/08/2013
@uso
@Obs
/*/
//--------------------------------------------------------------------
User Function A009F301(_cUN)
	Local _aArea		:=GetArea()
	Local _aOrigem		:={}
	Local _aVetor		:={}
	Local _cTitulo		:="Pesquisa: Centro de Custo"
	Local _cVar			:=""
	Local _oDlgF3, _oOpcao, _oConteudo, _oPesq, _oF3, _oConf,_oCanc
	
	_cConteudo	:=Space(200)
	
	cQuery:=""
	cQuery+="  SELECT "
	cQuery+="   	PA4_X_COD, "
	cQuery+="    	PA4_X_DSPR, "
	cQuery+="    	PA4_CC, "
	cQuery+="    	PA4.R_E_C_N_O_ AS RECPA4 "
	cQuery+=" 	FROM "+RetSqlName("PA4")+" (NOLOCK) PA4 "
	cQuery+=" 	WHERE  "
	cQuery+=" 		PA4.D_E_L_E_T_ ='' "
	cQuery+=" 	AND PA4.PA4_X_COD ='"+_cUN+"' "
	
	If Select("TRBF3")<> 0
		TRBF3->( DbCloseArea() )
	EndIf
	
	TcQuery cQuery  NEW ALIAS "TRBF3"
	cQuery := Nil
	
	DbSelectArea("TRBF3")
	TRBF3->(DbGoTop())
	If !TRBF3->(Eof())
		Do While !TRBF3->(Eof())
			aAdd(_aOrigem,{TRBF3->PA4_X_DSPR,TRBF3->PA4_CC, TRBF3->RECPA4 })
			TRBF3->(DbSkip())
		End
		_aVetor	:= aClone(_aOrigem)
		aSort( _aVetor,,, { |x,y| x[_nOpcao]< y[_nOpcao]})
	Endif
	If Len(_aOrigem)>0
		DEFINE MSDIALOG _oDlgF3 TITLE _cTitulo FROM 000, 000  TO 400, 500 PIXEL STYLE DS_MODALFRAME
		@ 010, 008 RADIO _oOpcao   		VAR _nOpcao  ITEMS "Descrição CC","Centro de Custo"	SIZE 060, 010 	OF _oDlgF3 PIXEL ON CHANGE( _cConteudo :=Space(200), aSort( _aVetor,,, { |x,y| x[_nOpcao]< y[_nOpcao]}),_oF3:aArray:=aClone(_aVetor),_oF3:Refresh())
		
		@ 010, 070 MSGET _oConteudo    ;
			VAR _cConteudo ;
			Picture "@!";
			Valid ( u_A09updF3(@_oF3, _aVetor) );
			SIZE 140, 010 	OF _oDlgF3 	PIXEL
		
		@ 025, 070 BUTTON _oPesq	;
			PROMPT "Pesquisar" 							;
			OF _oDlgF3 PIXEL ACTION ( u_A09updF3(@_oF3, _aVetor) )
		
		@ 040 ,008 LISTBOX _oF3 ;
			VAR _cVar FIELDS HEADER "Desc. CC", "Centro de Custo";
			SIZE 230,095 OF _oDlgF3 PIXEL;
			
		_oF3:bChange := {||}
		_oF3:SetArray( _aVetor )
		_oF3:bLine := {|| {_aVetor[_oF3:nAt,1],_aVetor[_oF3:nAt,2] }}
		
		TButton():New(150,010,'<<' ,_oDlgF3,{|| _oF3:GoTop()}   ,20,10,,,,.T.)
		TButton():New(150,030,'<'  ,_oDlgF3,{|| _oF3:GoUp()}    ,20,10,,,,.T.)
		TButton():New(150,050,'>'  ,_oDlgF3,{|| _oF3:GoDown()}  ,20,10,,,,.T.)
		TButton():New(150,070,'>>' ,_oDlgF3,{|| (_oF3:nAt:=Len(_aVetor),_oF3:Refresh())},20,10,,,,.T.)
		
		DEFINE SBUTTON _oConf FROM 150, 170 TYPE 01 Action ( _oF3:Refresh(), cRetF3Un:=_cConteudo:=_aVetor[_oF3:nAt][1],_oDlgF3:End()) OF _oDlgF3 ENABLE
		DEFINE SBUTTON _oCanc FROM 150, 200 TYPE 02 Action (_cConteudo:=Space(200),_oDlgF3:End()) OF _oDlgF3 ENABLE
		
		_oDlgF3:lEscClose:=.F.
		
		ACTIVATE MSDIALOG _oDlgF3 CENTERED
	Endif
	TRBF3->(DbCloseArea())
	RestArea(_aArea)
	
	//_cDescCelula := _cConteudo
Return(.t.)


//-------------------------------------------------------------------
/*/ a09FilF3
Filtro para Consulta Padrao Especifica
@aParam
@author		Fernando
@since		14/07/2014
@uso
@Obs
/*/
//--------------------------------------------------------------------
Static Function a09FilF3(_cConteudo,_aVetor)
	Local _nLinha := 0
	Local cTexto := Alltrim(_cConteudo)
	_nLinha := aScan(_aVetor, {|a| Substr( Alltrim(a[_nOpcao]), 1, len(cTexto) ) == cTexto } )
	If _nLinha == 0
		_nLinha := 1
	endIf
Return(_nLinha)
//Retorno Consulta Especifica
User Function a09RetF3()
Return(cRetF3Un)

//-------------------------------------------------------------------
/*/ A09updF3 - validacao quando se clica no botao pesquisar ou quando
o usuario pressiona Enter.
@aParam
@author		Fernando
@since		14/07/2014
@uso
@Obs
/*/
//--------------------------------------------------------------------
User Function A09updF3(_oF3, _aVetor)
	_oF3:nAt:= a09FilF3(@_cConteudo,_aVetor)
	_oF3:Refresh()
	cRetF3Un := _oF3:aArray[_oF3:nAt, 1]
	_cConteudo :=Space(200)
Return(.T.)

//-------------------------------------------------------------------
/*/ A009GetNumSC7 - Retorna numeracao do Pedido de acordo com
a unidade de negocio selecionada.
@aParam
@author		Fernando
@since		27/07/2014
/*/
//--------------------------------------------------------------------
Static Function A009GetNumSC7(_cUnidade)
	Local cRet 	   := ""
	Local _cDigUN  := ""
	Local aPrefixo := strtokarr( alltrim(GetMV("ES_DIGITPC")), ";")
	Local nPosPref := aScan(aPrefixo, {|aP| AllTrim(_cCelula) == substr( Alltrim(aP),3,2)})
	Local cQuery 	:= ""
	
	// Pega codigo do Pedido de Compras, de acordo com a unidade de negocio.
	If nPosPref > 0
		_cDigUN := Left(Alltrim(aPrefixo[nPosPref]), 1)
	EndIf
	cAliasTMP 	:= GetNextAlias()
	cQuery := " SELECT MAX(C7_NUM) AS NUMPC FROM "+RetSqlName("SC7")+" SC7 WHERE SC7.D_E_L_E_T_ = '' AND SUBSTRING(SC7.C7_NUM,1,1)= '"+_cDigUN+"'"
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliasTMP,.F.,.T.)
	If  !(cAliasTMP)->(Eof()) .And. !Empty((cAliasTMP)->NUMPC)
		cRet := (cAliasTMP)->NUMPC
		cRet := Val( SubStr(cRet, 2, len(cRet) ) ) + 1
		cRet := StrZero(cRet,5)
		//cRet := Soma1( (cAliasTMP)->NUMPC)
	Else
		cRet := "00001"
	EndIf
	cRet := _cDigUn+cRet
	If Select(cAliasTMP) <> 0
		(cAliasTMP)->(DbCloseArea())
	EndIf
Return(cRet)

//-------------------------------------------------------------------
/*/ MudaX3() - Altera o Conteudo do Valid
@aParam
@author		Fernando
@since		27/07/2014
/*/
//--------------------------------------------------------------------
USER FUNCTION A009X3()
	
	Local nArea:=Select()
	
	cFamCCIO:=Space(05)
	cIOJOA :=Space(10)
	
	// Abre arquivo de parametros da empresa consolidadora
	IF cEmpAnt == '02'
		Use SX3020 Alias X3000 NEW
	Elseif cEmpAnt == '07'
		Use SX3070 Alias X3000 NEW
	Else
		Use &("SX3"+alltrim(cEmpAnt)+"0") Alias X3000 NEW
	EndIf
	
	X3000->(DbGoTop())
	Locate For X3_CAMPO = "C7_PRECO" && Localiza parâmetro na SX6
	If Found() .AND. X3000->(RLock())
		X3000->X3_VALID:="Positivo().and.A120Preco(M->C7_PRECO)"
		X3000->(DbCommit())
		X3000->(DbUnLock())
	EndIf
	
	If Select("X3000") > 0
		X3000->(DbCloseArea())
	EndIf
	Sele (nArea)
Return()

//-------------------------------------------------------------------
/*/
@aParam
@author	David
@since		03/09/2015
/*/
//--------------------------------------------------------------------
USER FUNCTION A009PAV()
	
	dbSelectarea("PAV")
	dbsetorder(1)
	
	IF PAV->(dbseek(xFilial("PAV")+AvKey(_cProjeto, "PAV_PROJET")+ AvKey(_cCodSA2, "PAV_CODFOR")  ))
		RECLOCK("PAV",.F.)
		PAV->PAV_SALDO := PAV->PAV_SALDO + _nCredGr
		PAV->(MSUNLOCK())
	ELSE
		RECLOCK("PAV",.T.)
		PAV->PAV_FILIAL := xFilial("PAV")
		PAV->PAV_PROJET := _cProjeto
		PAV->PAV_DESCPR := _cDescPrj
		PAV->PAV_CODFOR := _cCodSA2
		PAV->PAV_SALDO  := _nCredGr
		PAV->(MSUNLOCK())
	ENDIF
	
	
Return()


