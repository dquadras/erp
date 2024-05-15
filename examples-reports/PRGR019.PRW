#Include "TOTVS.CH"

#define DMPAPER_A4 9  		 // A4 210 x 297 mm
#define LIMITE_POR_PAGINA 10 // Linhas por Pagina

//-------------------------------------------------------------------
/*/ PRGR001 - Relatorio Ordem de Serviço
@author		David Ferreira Quadras
@since 		12/12/2012
@uso    	Especificos - TV1.
/*/
//--------------------------------------------------------------------
User Function PRGR019(cProjDe, cProjAte)
	Local aArea    		:= GetArea()
	Local i		  		:= 0
	Local j		   		:= 0
	Local cPerg     	:= "PRGR019"
	Private aUnNeg  	:= {}
	Private nTotal  	:= 0
	Private oPrint		:= Nil
	Private cTitleReport:= "TV1 - Relatório Ordem de Serviço"
	Private oFont1 		:= TFont():New('Courier new',,-18,.T.)
	Private oFont2 		:= TFont():New('Courier new',,-11, ,.T.)
	Private oFont9 		:= TFont():New('Courier new',,-09, ,.T.)
	Private oFont8 		:= TFont():New('Courier new',,-07, ,.T.)
	Private oTrebu6N	:= TFont():New("Trebuchet MS",,6,,.T.,,,,,.F.,.F.)		
	Private cArqTrb  	:= GetNextAlias()
	Private _nTotBruto 	 := 0
	Private _nTotLiq   	 := 0
	Private _nTotComiss	 := 0
	Private _nTotLiqComis:= 0
	Private _nline		 := 0
	Private _aTotPracas  := { {"NACIONAL",0,0,0,0}, {"INTERNACIONAL", 0,0,0,0} }
	Private _aTotRede    := { {0,0,0,0} }
	Private _aTotGeral   := {0,0,0,0}
	Private aAP		     := {}
	Private nPagInicio	 := 1
	Private nPaginas	 := 1
	Private cObs		 := ""
	
	Default cProjDe := "" 
	Default cProjAte:= ""

	MakeSx1(cPerg)
	If (! Empty(cProjDe) .And. ! Empty(cProjAte))
		
		DbSelectArea("SX1")
		SX1->(DbSetOrder(1))

		If SX1->(DbSeek('PRGR019   02'))
			RecLock("SX1",.f.)		
				SX1->X1_CNT01 := Alltrim(cProjDe)
			MsUnLock()
		EndIf				
		
		If SX1->(DbSeek('PRGR019   03'))
			RecLock("SX1",.f.)		
				SX1->X1_CNT01 := Alltrim(cProjAte)
			MsUnLock()
		EndIf		
		
		Pergunte(cPerg,.t.)
		MV_PAR02 := cProjDe					
		MV_PAR03 := cProjAte
		MsgRun("Imprimindo Ordem de Serviço." ,"Aguarde...", {|| CursorWait(),R019Imp(),CursorArrow()})	
	Else
	 	Pergunte(cPerg,.t.)
		MsgRun("Imprimindo Ordem de Serviço." ,"Aguarde...", {|| CursorWait(),R019Imp(),CursorArrow()})
	EndIf
	RestArea(aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/ R001Imp - Impressão de Ordem de Serviço
//--------------------------------------------------------------------
/*/
Static Function R019Imp()
	Local cQuery  	 	:= ""
	Local aPI	  	 	:= {}
	Local i 	  	 	:= 0
	Local j		  	 	:= 0
	Local nPage   	 	:= 0
	Local _nVlrBruto 	:= 0
	Local _nVlrLiq   	:= 0
	Local _nVlrComiss	:= 0
	Local _nVlrLiqComis	:= 0
	Local cPraca		:= ""

	b := 150

	cQuery := " SELECT  "
	cQuery += " 		AF8.AF8_PROJET AS  AP,		  				 "
	//cQuery += " 		SUBSTRING(AF8.AF8_DESCRI,1,28) AS  MEIO,	 "
	cQuery += " 		SUBSTRING(AF8.AF8_X_DESC,1,32) AS NOMECLIENT,"
	cQuery += " 		AF8.AF8_X_DSPR AS PRODUTO,    				 "
	cQuery += " 		SUBSTRING(AF8.AF8_X_DSPR,1,28) AS ACAO,   	 "	
	cQuery += " 		AF8.AF8_CTCLI1 AS RESP,    					 "
	cQuery += " 		SUBSTRING(AF8.AF8_X_DECR,1,32) AS CAMPANHA,  "
	cQuery += " 		AF9.AF9_TAREFA AS 'PI', 	  				 "
	cQuery += " 		ISNULL(CONVERT(VARCHAR(8000),CONVERT(VARBINARY(8000), AF9.AF9_X_OBS)),'') AS AF9_X_OBS,  "	

	
	cQuery += " 		AF9.AF9_XPRACA AS PRACA,	"
	cQuery += " 		AF9.AF9_X_DSVC AS VEICULO, "
//	cQuery += " 		SB1.B1_DESC  AS SERVICO,   "	
//	cQuery += " 		AFA.AFA_XTIT  AS SERVICO,  "

	cQuery += " 		COALESCE(AF9.AF9_DESCRI,'') AS SERVICO, "	

	cQuery += " 		AF9.AF9_TVPVI  AS VLRBRUTO, "
	cQuery += " 		AF9.AF9_X_VLCV AS LIQUIDO,  "
	cQuery += " 		AF9.AF9_XSALPI AS COMISSAO  "
	cQuery += " FROM "+RetSqlName("AF8")+" (NOLOCK) AF8 "

	cQuery += " INNER JOIN "+RetSqlName("AF9")+ " (NOLOCK) AF9 "
	cQuery += " 	ON  AF8.AF8_PROJET = AF9.AF9_PROJET "
	cQuery += " 	AND AF8.AF8_REVISA = AF9.AF9_REVISA "
	cQuery += " 	AND AF9.D_E_L_E_T_ = ''   "

	cQuery += " INNER JOIN "+RetSqlName("AFC")+ " (NOLOCK) AFC 	"
	cQuery += " 	ON	AFC.AFC_PROJET 	= AF9.AF9_PROJET 		"
	cQuery += " 	AND AFC.AFC_EDT 	= AF9.AF9_EDTPAI		"
	cQuery += " 	AND AFC.AFC_REVISA 	= AF9.AF9_REVISA 		"
	cQuery += " 	AND AFC.D_E_L_E_T_ 	= ''	 				"

	/*	
	cQuery += " INNER JOIN "+RetSqlName("AFA")+ " (NOLOCK) AFA 	"
	cQuery += " 	ON	AF9.AF9_PROJET 	= AFA.AFA_PROJET 		"
	cQuery += " 	AND AF9.AF9_REVISA 	= AFA.AFA_REVISA 		"
	cQuery += " 	AND AF9.AF9_TAREFA 	= AFA.AFA_TAREFA 		"	
	cQuery += " 	AND AFA.D_E_L_E_T_ 	= ''	 ""

	cQuery += " INNER JOIN "+RetSqlName("SB1")+ " (NOLOCK) SB1 	"
	cQuery += " 	ON AFA.AFA_PRODUT 	= SB1.B1_COD 			"	
	cQuery += " 	AND SB1.D_E_L_E_T_ 	= ''					"
	*/

	cQuery += " WHERE  "
	cQuery += " 	AF8.AF8_PROJET BETWEEN '"+alltrim(MV_PAR02)+"' AND '"+alltrim(MV_PAR03)+"' "
	//cQuery += " 	AF8.AF8_PROJET BETWEEN '"+"AP10140290"+"' AND '"+"AP10140290"+"' "
	cQuery += " 	AND AF8.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY "
	cQuery += "		AF8.AF8_PROJET, AF9.AF9_XPRACA, AF9.AF9_TAREFA "
	
	autogrLog(cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cArqTRB,.F.,.T.)
	DbSelectArea(cArqTRB)

	If !(cArqTRB)->(Eof())
	
		oPrint := TMSPrinter():New(cTitleReport)
		oPrint:SetPortrait()
		oPrint:Setup()
		oPrint:setPaperSize(DMPAPER_A4)

		R001Cabec(@oPrint)
	
		aDadosCab:={}
		cAP := Alltrim((cArqTRB)->AP)
		
		While !(cArqTRB)->(Eof())

			aAdd(aAP,  { AllTrim((cArqTRB)->AP), Alltrim((cArqTRB)->ACAO), Alltrim((cArqTRB)->NOMECLIENT),;
			  			 AllTrim((cArqTRB)->PRODUTO), AllTrim((cArqTRB)->CAMPANHA),AllTrim((cArqTRB)->PI),;
			  			 AllTrim((cArqTRB)->PRACA), allTrim((cArqTRB)->VEICULO)})

			cAP := Alltrim((cArqTRB)->AP)
			R001Sessao1(@oPrint, cAp, aAP) // Dados do Cabecalho - Dados da AP

			aDadosCab:= {}
			aPI 	 := {}

			_nTotBruto 	:= 0.00
			_nTotLiq   	:= 0.00
			_nTotComiss	:= 0.00
			_nTotLiqComis := 0.00

			// Quebra por numero de OS
			While !(cArqTRB)->(Eof()) .And. cAP == Alltrim((cArqTRB)->AP)
		
				_nCustoTerceiro := (cArqTRB)->VLRBRUTO //+(cArqTRB)->COMISSAO
				_nVlrComiss  	:= (cArqTRB)->COMISSAO

				aAdd(aPI, {	(cArqTRB)->PI		,;
							(cArqTRB)->PRACA	,;
							(cArqTRB)->SERVICO	,;
							 _nCustoTerceiro 	,;
							 _nVlrComiss	 	,;
							 Alltrim((cArqTRB)->AP),;
							 alltrim((cArqTRB)->AF9_X_OBS)})

				(cArqTRB)->(dbSkip())
			EndDo
		
			_nline	:= 738+035+135
			_nCol   := 065
			nQuebra := 1
			nPagInicio:= 1
			nPaginas := Round(len(aPI)/10,0)
			nPaginas := Iif(nPaginas<1,1,nPaginas)
			oPrint:Say(435+035, 1635,"Página:"+cValtoChar(nPagInicio)+" de "+cvaltochar(nPaginas),oFont9,1400,CLR_BLACK)
        
			// Itens
			For i:= 1 to Len(aPI)
			
				If nQuebra <= LIMITE_POR_PAGINA
					printItens( @_nLine, aPi,i)
				Else

					R001Totaliza(@oPrint,"S", aPI, i)
					
					oPrint:EndPage()

					oPrint:StartPage()
					
					R001Cabec(@oPrint)
					
					R001Sessao1(@oPrint, aPI[i,08], aAP) // Dados do Cabecalho - Dados da AP

					_nline	:= 738+035+135
					_nCol   := 065
					
					printItens(@_nLine, aPi,i)

					_nCol   := 065
					nQuebra := 1

				EndIf
			
				_nTotBruto 	+= aPI[i,4]
				_nTotComiss	+= aPI[i,5]

				nQuebra++
			
			Next i
		
			R001Totaliza(@oPrint,"T", aPI, len(aPI))
		
			nPaginas:=1
	
			// Rodape (Assinatura).
			oPrint:Say(3055, 650, "Aprovamos e autorizamos, por nossa conta e ordem a produção dos serviço(s) acima descrito(s).",oFont9,1400,CLR_BLACK)
			oPrint:Say(3140, 650, "Data:  /  /    ",oFont9,1400,CLR_BLACK)
			oPrint:Say(3235, 650, "Aprovador: ___________________________________    ",oFont9,1400,CLR_BLACK)
		
			oPrint:EndPage()
		
			If !(cArqTRB)->(Eof())
				R001Cabec(@oPrint)

				aAdd(aAP,  { AllTrim((cArqTRB)->AP), Alltrim((cArqTRB)->ACAO), Alltrim((cArqTRB)->NOMECLIENT),  AllTrim((cArqTRB)->PRODUTO), AllTrim((cArqTRB)->CAMPANHA),;
							 AllTrim((cArqTRB)->PI), allTrim((cArqTRB)->PRACA), allTrim((cArqTRB)->VEICULO) })
				
				R001Sessao1(@oPrint, AllTrim((cArqTRB)->AP), aAP) // Dados do Cabecalho - Dados da AP.
				Loop
			EndIf
			(cArqTRB)->(dbSkip())

		EndDo

	// Visualiza a impressão
		oPrint:EndPage()
		oPrint:Preview()

	EndIf
	(cArqTRB)->(dbCloseArea())

Return(Nil)

//----------------------------------------------------
/*/ R001Cabec - Impressao de Cabecalhos.
@aParam Nil
@author	Fernando
@since 	01/10/2014
@uso    Especificos - TV1.
/*/
//----------------------------------------------------
Static Function R001Cabec(oPrint)
// Dados do Cabecalho
	oPrint:StartPage()
	//oPrint:SayBitmap( 100,140,"C:\temp\logo_ap.bmp",200,200)
	//oPrint:SayBitmap( 100,1950,"C:\temp\logo_gnova.bmp",300,250)
	oPrint:SayBitmap( 140,075,"system\logo_os.bmp",300,200)
	oPrint:SayBitmap( 100,1750,"system\logo_gnova.bmp",300,250)
	oPrint:Say( 130,380,"GNova Publicidade Ltda",oFont2,1400,CLR_BLACK )
	oPrint:Say( 175,380,"Rua João Ramalho, 1082 - Perdizes",oFont2,1400,CLR_BLACK)
	oPrint:Say( 215,380,"São Paulo - SP - CEP 05008-002",oFont2,1400,CLR_BLACK)
	oPrint:Say( 255,380,"Fone 0xx 11 3670-0640 FAX 3670-0640",oFont2,1400,CLR_BLACK)
	oPrint:Say( 295,380,"CNPJ 09.160.240/0001-28 - IE: Isento - CCM: 3.688.038-8",oFont2,1400,CLR_BLACK)
Return(Nil)

//----------------------------------------------------
/*/ R001Sessao1 - Impressao Sessao 1 (Cabecalho).
@aParam Nil
@author	Fernando
@since 	01/10/2014
@uso    Especificos - TV1.
/*/
//----------------------------------------------------
Static Function R001Sessao1(oPrint, cAp, aDadosCab)

	Local nPosAP := aScan(aDadosCab, {|ap|	alltrim(ap[1]) == alltrim(cAp)	} )

	// --- Coordenadas
	a := 335
	b := 060
	c := 3400
	d := 2150
	ee:= 0520

	oPrint:Box(a,b,c,d)

	cAP 	 := aDadosCab[nPosAp,1] // Alltrim((cArqTRB)->AP)
	cAcao 	 := aDadosCab[nPosAp,2] // Alltrim((cArqTRB)->MEIO)
	cCliente := aDadosCab[nPosAp,3] // allTrim((cArqTRB)->NOMECLIENT)
	cProduto := aDadosCab[nPosAp,4] // allTrim((cArqTRB)->PRODUTO)

	cCampanha:= aDadosCab[nPosAp,5] // AllTrim((cArqTRB)->CAMPANHA)
	cPI 	 := aDadosCab[nPosAp,6] // allTrim((cArqTRB)->PI)
	cPraca	 := aDadosCab[nPosAp,7] // allTrim((cArqTRB)->PRACA)
	cVeiculo := aDadosCab[nPosAp,8] // allTrim((cArqTRB)->VEICULO)

	oPrint:Box(a, b, 425, 480) // AP
	oPrint:Say(a+035, b+015, "OS: "+cAP,oFont9,1400,CLR_BLACK )

	oPrint:Say(a+035, 495 /*ee-25*/,"Ação: "+cAcao,oFont9,980,CLR_BLACK )

	oPrint:Box(a, 1100/*1340*/,425,1600) // Mes/ano Veiculo
	
	If ! Empty(MV_PAR01)
		cPeriodo := MesExtenso( ctod("01/"+Left(MV_PAR01,2)+"/"+Right(MV_PAR01,4)))+"/"+ Right(MV_PAR01,4)
		oPrint:Say(a+035, 1125 /*1330+020*/,"Mês/Ano :"+cPeriodo,oFont9,1400,CLR_BLACK)		
	Else
		cPeriodo := MesExtenso(dDataBase)+"/"+cvaltochar(Year(dDataBase))
		oPrint:Say(a+035, 1125 /*1330+020*/,"Mês/Ano :"+cPeriodo,oFont9,1400,CLR_BLACK)
	EndIf

	oPrint:Box(a, 1600,425,2150) // Emissao
	oPrint:Say(a+035, 1635,"Emissão:"+dtoc(dDataBase) /*+" "+substr(time(),1,5)*/ ,oFont9,1400,CLR_BLACK)

	oPrint:Box(425, b, 525, 1100 /*1040+300*/) // Cliente
	oPrint:Say(435+035, b+015, "Cliente: "+cCliente,oFont9,1400,CLR_BLACK )

	oPrint:Box(425, 1600, 525, 2150) // Produto
	oPrint:Say(435+035, 1125,"Produto: "+cProduto,oFont9,1400,CLR_BLACK)

	oPrint:Box(425, 1600,425,2150) // Pagina

	If nPaginas > 1
		If nPagInicio <=nPaginas
			nPagInicio++
		Else
			nPagInicio := 1
		EndIf
		oPrint:Say(435+035, 1635,"Página:"+cValtoChar(nPagInicio)+" de "+cvaltochar(nPaginas),oFont9,1400,CLR_BLACK)

	EndIf
	oPrint:Box(525, b, 625, 2150) // Campanha
	oPrint:Say(538+035, b+015, "Campanha: "+cCampanha,oFont9,1400,CLR_BLACK )

	oPrint:Box(625, b, 725, 2150) // Controle
	oPrint:Say(638+035, b+015, "Controle: ",oFont9,1400,CLR_BLACK )

	oPrint:Box(625, b, 725, 2150) // Responsavel
	oPrint:Say(638+035, 1040+035, "Responsável: ",oFont9,1400,CLR_BLACK )

	oPrint:Box(725, b, 3025, 265) // PI
	oPrint:Say(738+035, b+015, "OS: ",oFont9,1400,CLR_BLACK )

	oPrint:Box(825, b, 725, 2150) // marcador

	oPrint:Box(725, b, 3025, 165+300) // Praca
	oPrint:Say(738+035, 265+025, "Praça: ",oFont9,1400,CLR_BLACK)

	oPrint:Box(725, b, 3025, /*400+465*/1200) // Serviço
	oPrint:Say(738+035,480 	 /*700+035*/, "Serviço",oFont9,1400,CLR_BLACK)

	//oPrint:Box(725, 400+465, 3025, 400+300+500) // Valor Bruto
	//oPrint:Say(738+035, /*1200+035*/ 895, "Custo Terceiros",oFont9,1400,CLR_BLACK )

	//oPrint:Box(725, 400+300+500, 3025, 400+300+500+300) // Liq. + Comissão
	//oPrint:Say(738+035, 1200+035, "Comissão",oFont9,1400,CLR_BLACK )
	
	oPrint:Box(725, 400+300+500, 3025, 400+300+500+300) // Liq. + Comissão
	oPrint:Say(738+035, 1200+015, "Custo Terceiros",oFont9,1400,CLR_BLACK )	

	oPrint:Box(725, 400+300+500+300, 3025, 400+300+500+300+300) // Comissão
	oPrint:Say(738+035, 400+300+500+315, "Comissão",oFont9,1400,CLR_BLACK )

	oPrint:Box(725, 400+300+500+300+300, 3025, 2150) // Líquido
	oPrint:Say(738+035,400+300+500+300+300+035, "Valor Total",oFont9,1400,CLR_BLACK )

Return(Nil)

//---------------------------------------------
/*/ printItens - Imprime os itens
@aParam Nil
@author	Fernando
@since 	01/10/2014
@uso    Especificos - TV1.
/*/
//---------------------------------------------
static function printItens(_nLine, aPi,i)

	Local j 		:= 0
	Local nNewLine 	:= 0	
	Local nI 		:= 1
	Local nF 		:= 46
	Local _nCol 	:= 065	
	Local cDescServico := ""
	
	For j := 1 to 6 // Colunas

		//Salto na 3a e 4a coluna
		If j == 3
		ElseIf j == 4
			_nCol+= 237
		ElseIf j == 5
			_nCol := 1200+035
		ElseIf j == 6
			_nCol += 055 + 095
		EndIf

		If j == 1
			oPrint:Say(_nLine, _nCol, AllTrim(aPI[i,6])+"/"+AllTrim(aPI[i,1]), oFont8, 1400, CLR_BLACK)

		//Praca
		ElseIf j == 2
			
			If len(aPI[i,j]) > 11
				oPrint:Say(_nLine, _nCol, Substr(aPI[i,j],1,11) ,oFont8,1400,CLR_BLACK)
				_nLine+= 035
				oPrint:Say(_nLine, _nCol, Substr(aPI[i,j],12,11 ) ,oFont8,1400,CLR_BLACK)

				_nLine -= 025
			Else
				oPrint:Say(_nLine, _nCol, aPI[i,j],oFont8,1400,CLR_BLACK)
			EndIf

		//--- Quebra Descrição do Serviço.
		ElseIf j == 3
			
			nNewLine := _nLine
			
			cDescServico := alltrim(aPI[i,j])
			
			If len(cDescServico) > 44
				
				While ! Empty(cDescServico)
					
					nI := 1
					nF := 44
	
					oPrint:Say(nNewLine, _nCol, Substr(cDescServico, nI,nF) ,oFont8,1400,CLR_BLACK)
	
					nI += nF
					nF := Min(44,Len(cDescServico))	
	
					cDescServico := SubStr(cDescServico, nI,nF)
					nNewLine += 035
	
				EndDo
			Else
				nI := 1
				nF := Min(44,Len(cDescServico))
				oPrint:Say(nNewLine, _nCol, Substr(cDescServico, nI,nF) ,oFont8,1400,CLR_BLACK)				
			EndIf	

		//--- Colunas de Valores
		ElseIf j == 4 // colunas de valores
			oPrint:Say(_nLine, 1200+015, AllTrim(Transform(aPI[i,4],PesqPict("SE1","E1_VALOR"))), oFont8, 1400, CLR_BLACK)	
		ElseIf j == 5
			oPrint:Say(_nLine, 400+300+500+315, AllTrim(Transform(aPI[i,5],PesqPict("SE1","E1_VALOR"))), oFont8, 1400, CLR_BLACK)
		ElseIf j == 6
			oPrint:Say(_nLine,400+300+500+300+300+035, AllTrim(Transform(aPI[i,4]+aPI[i,5],PesqPict("SE1","E1_VALOR"))), oFont8, 1400, CLR_BLACK)		
		Else
			oPrint:Say(_nLine, _nCol, aPI[i,j], oFont8, 1400, CLR_BLACK)
		EndIf

		If j == 2 	// salto de coluna, apos impressao
			_nCol +=192
		ElseIf j == 4 	// salto de coluna, apos impressao
			_nCol+= 080
		Else
			_nCol +=215
		EndIf
	Next j

	//_nline += 135
	_nline += 075	
	
	If nNewLine > _nLine
		_nline := _nline + (nNewLine-_nline)
	EndIf	
Return(Nil)

//---------------------------------------------
/*/ R001Totaliza - Imprime Totalizadores
@aParam Nil
@author	Fernando
@since 	01/10/2014
@uso    Especificos - TV1.
/*/
//---------------------------------------------
Static Function R001Totaliza(oPrint,cTipo, aPI, i)

	Local ii := 0
	Local j := 0
	
	
	// Mensagem de Observação	
	nIniPos	:= 1
	nFimPos	:= 045
	nL		:= 3050
	
	cObs := alltrim(aPI[i,7]) //alltrim((cArqTRB)->AF9_X_OBS) 
	cObs := Substr(cObs,1, Min(len(cObs),689) )			
	cObs := AllTrim(cObs)
	
	//alert(cObs)	
	//oPrint:Say(nL,0100, SubStr(strTran(Alltrim(cObs), chr(13)+chr(10), "" ),nIniPos,nFimPos),oTrebu6N,,0)
	
	//oPrint:Say(1925,0100,cTextSA1,oArial8N,,0)
	/**/
	For  i := 1 to 13
		//oPrinter:Say(nL,085,cvaltochar(i)+") A entrega de Notas Fiscais deverá ser efetuada até o d",oTrebu7N,,0)
		oPrint:Say(nL,085, SubStr(strTran(Alltrim(cObs), chr(13)+chr(10), "" ),nIniPos,nFimPos),oTrebu6N,,0)
		nIniPos += nFimPos
		nL += 30
	Next i
	/**/
	
	// Imprime totalizador das Pracas.
	_nCol   := 065
	_nLine += 050
	For j := 1 to 7

	//Salto na 3a e 4a coluna
		If j == 3
		//_nCol+= 023
		ElseIf j == 4
			_nCol+= 237
		ElseIf j == 5
			_nCol += 240
		ElseIf j == 6
			_nCol += 055
		ElseIf j == 7
			_nCol += 095
		EndIf

		If j == 4 	// salto de coluna, apos impressao
			_nCol+= 080
		Else
			_nCol +=215
		EndIf
	Next j

	_nCol  := 065
	For j := 1 to 7

	//Salto na 3a e 4a coluna
		If j == 3
	   //	_nCol+= 023
		ElseIf j == 4
			_nCol+= 237
		ElseIf j == 5
			_nCol += 240
		ElseIf j == 6
			_nCol += 055
		ElseIf j == 7
			_nCol += 095
		EndIf

		If j == 4
			//oPrint:Say(2950, _nCol, AllTrim(Transform(_nTotBruto, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)
			oPrint:Say(2950, 1200+015, AllTrim(Transform(_nTotBruto, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)			
		ElseIf j == 5
			//oPrint:Say(2950, _nCol, AllTrim(Transform(_nTotLiqComis, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)
			oPrint:Say(2950, 400+300+500+315, AllTrim(Transform(_nTotComiss, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)			
		ElseIf j == 6
			//oPrint:Say(2950, _nCol, AllTrim(Transform(_nTotComiss, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)
			oPrint:Say(2950, 400+300+500+300+300+035, AllTrim(Transform(_nTotBruto+_nTotComiss, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)			
		//ElseIf j == 7
			//oPrint:Say(2950, _nCol, AllTrim(Transform(_nTotLiq, PesqPict("SE1","E1_VALOR"))),oFont9,1400,CLR_BLUE)
		EndIf
		
		If j == 4 	// salto de coluna, apos impressao
			_nCol+= 080
		Else
			_nCol +=215
		EndIf
	Next j

	oPrint:Line(2930,b, 2930, 2150) // 2930,400+300+500+300+300+300+350)

	If cTipo == "S"

		_aTotPracas[1,2] := 0
		_aTotPracas[1,3] := 0
		_aTotPracas[1,4] := 0
		_aTotPracas[1,5] := 0

		_aTotPracas[2,2] := 0
		_aTotPracas[2,3] := 0
		_aTotPracas[2,4] := 0
		_aTotPracas[2,5] := 0

	ElseIf cTipo == "T"
		_nTotBruto 	  := 0
		_nTotLiqComis := 0
		_nTotComiss	  := 0
		_nTotLiq   	  := 0

		_aTotPracas[1,2] := 0
		_aTotPracas[1,3] := 0
		_aTotPracas[1,4] := 0
		_aTotPracas[1,5] := 0

		_aTotPracas[2,2] := 0
		_aTotPracas[2,3] := 0
		_aTotPracas[2,4] := 0
		_aTotPracas[2,5] := 0
	EndIf

	_aTotRede[1,1] :=0
	_aTotRede[1,2] :=0
	_aTotRede[1,3] :=0
	_aTotRede[1,4] :=0

Return(Nil)

//----------------------------------------------------
/*/ makeSX1 - Criacao de Grupo de Perguntas
@aParam Nil
@author	Fernando
@since 	01/10/2014
@uso    Especificos - TV1.
/*/
//----------------------------------------------------
Static function MakeSx1(_cPerg)
	Local _aArea      := GetArea()
	Local _cHelp		:= ""
	Local _aRegs		:= {}
	Local _aHelpPor	:= {}
	Local _aHelpSpa	:= {}
	Local _aHelpEng	:= {}
	Local _lUpDate	:= .F.
	Local _cValid		:= ".t."

//³           Grupo  Ordem Pergunta Portugues  Pergunta Espanhol    Pergunta Ingles       Variavel Tipo Tamanho Decimal Presel GSC Valid        Var01      Def01       DefSPA1     DefEng1    Cnt01 Var02 Def02       DefSpa2      DefEng2      Cnt02 Var03 Def03 DefSpa3 DefEng3 Cnt03 Var04 Def04 DefSpa4 DefEng4 Cnt04 Var05 Def05 DefSpa5 DefEng5 Cnt05 XF3 GrgSxg cPyme aHelpPor aHelpEng aHelpSpa cHelp      ³
	_aHelpPor := _aHelpSpa := _aHelpEng := {"informe o Período(MMAAAA)",""}
	_cHelp:=_cPerg+"01"
	PutSX1Help("P"+_cHelp,_aHelpPor,_aHelpEng,_aHelpSpa,_lUpDate)
	Aadd(_aRegs,{_cPerg,"01","Período(MMAAAA):","Período(MMAAAA):", "Período(MMAAAA):", "MV_CH1","C",06, 0, 1, "C",_cValid,"MV_PAR01", "","","","","","","",""  ,"","","","",""   ,"","","","","","","","","","","","","","S",_aHelpPor, _aHelpEng, _aHelpSpa, _cHelp})

	_aHelpPor := _aHelpSpa := _aHelpEng := {"informe número da Ordem de Serviço",""}
	_cHelp:=_cPerg+"02"
	PutSX1Help("P"+_cHelp,_aHelpPor,_aHelpEng,_aHelpSpa,_lUpDate)
	Aadd(_aRegs,{_cPerg,"02","OS De?:","PSP De?", "PSP De?", "MV_CH2","C",TamSx3('AF8_PROJET')[1], 0, 0, "C","NaoVazio()","MV_PAR02", "","","","","","","",""  ,"","","","",""   ,"","","","","","","","","","","","","AF8","S",_aHelpPor, _aHelpEng, _aHelpSpa, _cHelp})

	_aHelpPor := _aHelpSpa := _aHelpEng := {"informe a AP",""}
	_cHelp:=_cPerg+"03"
	PutSX1Help("P"+_cHelp,_aHelpPor,_aHelpEng,_aHelpSpa,_lUpDate)
	Aadd(_aRegs,{_cPerg,"03","OS Até?:","AP Até?", "AP Até?", "MV_CH3","C",TamSx3('AF8_PROJET')[1], 0, 0, "C","NaoVazio()","MV_PAR03", "","","","","","","",""  ,"","","","",""   ,"","","","","","","","","","","","","AF8","S",_aHelpPor, _aHelpEng, _aHelpSpa, _cHelp})

	ValidPerg(_aRegs,_cPerg,.T.)
	RestArea(_aArea)
Return(Nil)