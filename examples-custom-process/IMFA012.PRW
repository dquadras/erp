#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"
#Define CRLF CHR(13)+CHR(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA012
Funcao para importacao os dados do movimento mensal(SRC) por centro 
de custo de acordo com a verba na Nota Fiscal de Entrada
usado na rotina de Documento de Entrada - MATA410
@aParam
@Autor      David Ferreira Quadras
@since		05/12/2011
        
/*/
//-------------------------------------------------------------------
User Function IMFA012()

	Local aArea  	:= GetArea()
	Local oDlg		:= Nil
	Local oSay1		:= Nil 
	Local oSay2		:= Nil 
	Local oSay3		:= Nil
	Local oSay4		:= Nil
	Local oSay5		:= Nil
	Local oSay6		:= Nil
	Local oConf		:= Nil 
	Local oCanc		:= Nil 
	Local oPrd		:= Nil 
	Local oVlNF		:= Nil 
	Local oTotVB	:= Nil 
	Local oAno		:= Nil 
	Local oMes		:= Nil 
	Local oTes		:= Nil
	Local cPrd	   	:= Space(15)
	Local cTes		:= Space(3)
	Local cMes  	:= StrZero(Month(Date()),2)
	Local cAno		:= StrZero(Year(Date()),4)
	Local cCdVB   	:= ""
	Local nVlNF   	:= 0
	Local lRet    	:= .F.
	Private oDescVB	:= Nil
	Private cDescVB := ""
	Private nTotVB  := 0
	//Private cFolMes:= Alltrim(SUPERGETMV("MV_FOLMES" ,.F.,""))
     
	If !cTipo$"DB"
		If Empty(cA100For) .Or. Empty(cLoja)
			Alert("Informe o Codigo do Fornecedor da Nota Fiscal")
		ElseIf Empty(cNFiscal)// .Or. Empty(cSerie)
			Alert("Informe o numero da Nota Fiscal")
		ElseIf Empty(cEspecie)
			Alert("Informe a especie da Nota Fiscal")
		Else
			DEFINE MSDIALOG oDlg TITLE "Rateio por Centro de Custo por Verba" FROM 000, 000  TO 480, 320  PIXEL STYLE DS_MODALFRAME
			@ 010, 005 SAY oSay1 	PROMPT "Produto" 																	  				   								SIZE 035, 010 	OF oDlg  PIXEL
			@ 010, 050 MSGET oPrd 		VAR cPrd  		Picture "@!"      Valid (Iif(ValPrd(cPrd),(cCdVB:=ValVB(cPrd),nTotVB:=ProcVB(cCdVB,cMes,cAno),oTotVB:Refresh()),.F.))	SIZE 060, 010 	OF oDlg  F3 "SB1" PIXEL

			@ 025, 005 SAY oSay2 	PROMPT "Mes"																														SIZE 020, 010	OF oDlg  PIXEL
			@ 025, 025 MSGET oMes		VAR cMes 		Picture "@R 99"   Valid(nTotVB:=ProcVB(cCdVB,cMes,cAno),oTotVB:Refresh())  									SIZE 020, 010 	OF oDlg  PIXEL

			@ 025, 060 SAY oSay3 	PROMPT "Ano"																		  		  			SIZE 020, 010	OF oDlg  PIXEL
			@ 025, 080 MSGET oAno		VAR cAno 		Picture "@R 9999" Valid(nTotVB:=ProcVB(cCdVB,cMes,cAno),oTotVB:Refresh()) 			SIZE 040, 010 	OF oDlg  PIXEL

			@ 040, 005 SAY oSay4 	PROMPT "TES"																		   		 			SIZE 035, 010	OF oDlg  PIXEL
			@ 040, 050 MSGET oTES	VAR cTES 			Picture "@!" Valid (ValTES(cTES))								  					SIZE 040, 010 	OF oDlg  F3 "SF4" PIXEL

			@ 060, 005 SAY oSay4 	PROMPT "Verba"																		   		 			SIZE 035, 010	OF oDlg  PIXEL
//		   @ 060, 050 MSGET oDescVB	VAR cDescVB 									When .F.   							  		 			SIZE 100, 010 	OF oDlg  PIXEL
			@ 060, 050 GET oDescVB	VAR cDescVB MEMO								When .F.   							  		 			SIZE 100, 110 	OF oDlg  PIXEL

			@ 180, 005 SAY oSay5 	PROMPT "Valor Verba"																 		  			SIZE 035, 010	OF oDlg  PIXEL
			@ 180, 050 MSGET oTotVB		VAR nTotVB	 	Picture "@E 999,999,999.99" When .F.   							 					SIZE 060, 010 	OF oDlg  PIXEL
				                                  
			@ 200, 005 SAY oSay6 	PROMPT "Valor Nota"																	 		   			SIZE 035, 010	OF oDlg  PIXEL
			@ 200, 050 MSGET oVlNF		VAR nVlNF 		Picture "@E 999,999,999.99" Valid(ValTES(cTES) .Or. nVlNF==0) 	                    SIZE 060, 010 	OF oDlg  PIXEL
				
			oDlg:lEscClose:=.F.
					
			DEFINE SBUTTON oConf 	FROM 220, 090 TYPE 01 ACTION (lRet:=.T.,oDlg:End())         	OF oDlg ENABLE
			DEFINE SBUTTON oCanc 	FROM 220, 120 TYPE 02 ACTION (oDlg:End())     		           	OF oDlg ENABLE
				
			ACTIVATE MSDIALOG oDlg CENTERED
				
			If lRet
				MsgRun("Processando Movimentacao"       ,"Aguarde...", {||CursorWait(),ProcNFE(cCDVB,cPrd,cTES,cMes,cAno,nTotVB,nVlNF) ,CursorArrow()})
			Endif
		Endif
	Else
		Alert("O Rateio por Centro de Custo não poderá ser feito por uma Nota de Beneficiamento ou de Devolução")
	Endif
	RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/  ProcVBSRC
Funcao que le e processa a informacao da movimentacao mensal
@aParam
@author		Marcos Kato
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------
Static Function ProcNFE(cCodVB,cProd,cTES,cMes,cAno,nVlrVB,nVlrNFE)
	Local aArea		:=GetARea()
	Local cQuery	:=""
	Local cArqTRB1	:=""
	Local cCF       :=""
	Local nPerc     :=1
	Local nItem     :=1
	Local nCont     :=0
	Local nVlrCalc  :=0
	Local nTotNFE   :=0
	Local nItPrd    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_ITEM" })
	Local nCodPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_COD" })
	Local nLocPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_LOCAL" })
	Local nQtdPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_QUANT" })
	Local nVlrPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_VUNIT" })
	Local nTotPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_TOTAL" })
	Local nCCPrd    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_CC" })
	Local nUMPrd    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_UM" })
	Local nCdTES    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_TES" })
	Local nCFTES    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_CF" })
	Local nIcmPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_VALICM" })
	Local nAICPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_PICM" })
	Local nDtDigit  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_DTDIGIT" })
	Local nObsX     :=0
	Local nDescPrd  :=0
	Local nDescPrj  :=0
	Local nCodPrj   :=0
	Local nY, nX
	LocaL _cPeriodo	:= cAno+cMes

	If SD1->(FieldPos("D1_OBSERVX"))>0
		nObsX     :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_OBSERVX" })
	Endif
	If SD1->(FieldPos("D1_X_DESC"))>0
		nDescPrd  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_DESC" })
	Endif
	If SD1->(FieldPos("D1_CODPSP"))>0
		nCodPrj  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_CODPSP" })
	Endif
	If SD1->(FieldPos("D1_PROJTV1"))>0
		nDescPrj  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_PROJTV1" })
	Endif
	cQuery:=" "

	/* V11
	If cFolMes<=cAno+cMes
		cQuery+=" SELECT RC_CC CC,SUM(RC_VALOR) VALOR "
		cQuery+=" FROM "+RetSqlName("SRC")+" SRC "
		cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
		cQuery+=" RV_FILIAL=RC_FILIAL "
		cQuery+=" AND RV_COD=RC_PD "
		cQuery+=" AND SRV.D_E_L_E_T_='' "
		cQuery+=" WHERE SRC.D_E_L_E_T_='' "
		cQuery+=" AND SUBSTRING(RC_DATA,1,6) = '"+cAno+cMes+"' "
		cQuery+=" AND RC_TIPO1='V' "
		cQuery+=" AND RC_PD IN ("+cCodVB+") "
		cQuery+=" GROUP BY RC_CC "
	Else
		cQuery+=" SELECT RD_CC CC,SUM(RD_VALOR) VALOR "
		cQuery+=" FROM "+RetSqlName("SRD")+" SRD "
		cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
		cQuery+=" RV_FILIAL=RD_FILIAL "
		cQuery+=" AND RV_COD=RD_PD "
		cQuery+=" AND SRV.D_E_L_E_T_='' "
		cQuery+=" WHERE SRD.D_E_L_E_T_='' "
		cQuery+=" AND RD_DATARQ = '"+cAno+cMes+"' "
		cQuery+=" AND RD_TIPO1='V' "
		cQuery+=" AND RD_PD IN ("+cCodVB+") "
		cQuery+=" GROUP BY RD_CC "
	Endif
	*/
	cQuery+="SELECT RGB_CC AS CC, SUM(RGB_VALOR) AS VALOR "+CRLF
	cQuery+="FROM "+RetSqlName("RGB")+" RGB 	"+CRLF
	cQuery+="WHERE  						"+CRLF
	cQuery+="	 RGB_PERIOD = '"+_cPeriodo+"'"+CRLF
	cQuery+="AND RGB_PD IN ("+cCodVB+") 	"+CRLF
	cQuery+="AND RGB.D_E_L_E_T_= ''  			"+CRLF
	cQuery+="GROUP BY RGB_CC "+CRLF
	
	cQuery+=" UNION  "+CRLF
	
	cQuery+="SELECT SRD.RD_CC AS CC, SUM(SRD.RD_VALOR) AS VALOR  "+CRLF
	cQuery+="FROM "+RetSqlName("SRD")+" SRD 	"+CRLF
	cQuery+="WHERE   		 				"+CRLF
	cQuery+=" 	 SRD.RD_DATARQ = '"+_cPeriodo+"' "+CRLF
	cQuery+="AND SRD.RD_PD 	  IN("+cCodVB+") 	"+CRLF	
	cQuery+="AND SRD.D_E_L_E_T_= '' 			"+CRLF
	cQuery+="GROUP BY SRD.RD_CC 			"+CRLF
	
	cArqTRB1 := GetNextAlias()
	MemoWrite("IMFA012_CC.SQL", cQuery)
	
	cQuery   := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cArqTRB1 , .F., .T.)

	DbSelectArea(cArqTRB1)
	If !(cArqTRB1)->(Eof())
		If MaFisFound()
			nPerc:=1
			nTotNFE := 0
			If nVlrNFE > 0
				nPerc:= nVlrNFE/(nVlrVB/100)
			Endif
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If SB1->(dbSeek(xFilial("SB1")+AvKey(cProd,"B1_COD")))
				cCf:=""
				DbSelectArea("SF4")
				SF4->(DbSetOrder(1))
				SF4->(DbGoTop())
				If SF4->(dbSeek(xFilial("SF4")+AvKey(cTES,"F4_CODIGO")))
					cCf:=SF4->F4_CF
				Endif
				aCols:={}
				nCont:=0
				Do While (cArqTRB1)->(!Eof())
					nCont++
					aAdd(aCols, Array(Len(aHeader) + 1 ) )
					For nY := 1 to Len(aHeader)
						If Alltrim(aHeader[nY,2])=="D1_ALI_WT"
							aCols[Len(aCols),nY] :="SD1"
						ElseIf Alltrim(aHeader[nY,2])=="D1_REC_WT"
							aCols[Len(aCols),nY] :=0
						ElseIf Alltrim(aHeader[nY,2])=="D1_GARANTI"
							aCols[Len(aCols),nY] :="N"
						ElseIf Alltrim(aHeader[nY,2])=="D1_RATEIO"
							aCols[Len(aCols),nY] :="N"
						ElseIf aHeader[nY,10] == "V"
							aCols[Len(aCols),nY] := CriaVar(aHeader[nY,2],.T.)
						Else

							If Alltrim(aHeader[nY,2]) <> "D1_CODPSP"
								aCols[Len(aCols),nY] := SD1->(FieldGet(FieldPos(aHeader[nY,2])))
							EndIf
						EndIf
					Next
					aCols[Len(aCols),Len(aHeader)+1] := .F.
					If nCont==1
						MaFisAlt("NF_DESPESA",0,)
						MaFisAlt("NF_FRETE",0,)
						MaFisAlt("NF_SEGURO",0,)
						MaFisAlt("NF_VALMERC",0,)
						MaFisAlt("NF_TOTAL",0,)
					Endif
					nItem:=Len(aCols)
					nVlrCalc:=Round((cArqTRB1)->VALOR*(nPerc/100),2)
					nTotNFE+=nVlrCalc
					If nTotNFE>	nVlrNFE
						nVlrCalc:=nVlrCalc-(nTotNFE-nVlrNFE)
					Endif
					MaFisIniLoad(nItem)
					aCols[nItem][nItPrd] :=StrZero(nItem,4)
					aCols[nItem][nCodPrd]:=cProd
					If nDescPrd>0
						aCols[nItem][nDescPrd]  :=Alltrim(SB1->B1_DESC)
					Endif
					MaFisAlt("IT_PRODUTO",aCols[nItem][nCodPrd],nItem)
					If nCodPrj>0
						aCols[nItem][nCodPrj]  :=Space(TamSx3("D1_CODPSP")[1])
					Endif
					If nDescPrj>0
						aCols[nItem][nDescPrj]  :=Space(TamSx3("D1_PROJTV1")[1])
					Endif
					aCols[nItem][nUMPrd] :=SB1->B1_UM
					aCols[nItem][nLocPrd]:=SB1->B1_LOCPAD
					aCols[nItem][nQtdPrd]:=1
					MaFisAlt("IT_QUANT",aCols[nItem][nQtdPrd],nItem)
					aCols[nItem][nVlrPrd]:=nVlrCalc
					MaFisAlt("IT_PRCUNI",aCols[nItem][nQtdPrd]*aCols[nItem][nVlrPrd],nItem)
					aCols[nItem][nTotPrd]:=aCols[nItem][nQtdPrd]*aCols[nItem][nVlrPrd]
					MaFisAlt("IT_VALMERC",aCols[nItem][nQtdPrd]*aCols[nItem][nVlrPrd],nItem)
					aCols[nItem][nCdTES] :=cTES
					MaFisLoad("IT_TES","",nItem)
					If MaAvalTes("E",aCols[nItem][nCdTes]).And.MaFisRef("IT_TES","MT100",aCols[nItem][nCdTes])
						MaFisAlt("IT_TES",aCols[nItem][nCdTes],nItem)
					Endif
					MaFisLoad("IT_CF",MaFisCFO(nItem,cCF),nItem)
					MaFisAlt("IT_BASEICM",nVlrCalc,nItem)
					MaFisAlt("IT_BASEIPI",nVlrCalc,nItem)
					aCols[nItem][nCCPrd]  :=(cArqTRB1)->CC
					aCols[nItem][nDtDigit]:=dDataBase
					If nObsX>0
						aCols[nItem][nObsX]  :=Space(TamSx3("D1_OBSERVX")[1])
					Endif
				
					MaFisEndLoad(nItem)
					(cArqTRB1)->(DbSkip())
				End
				MaFisToCols(aHeader,aCols,,"MT100")
			Endif
		Else
			Alert("Posicione na linha do produto para a inclusão do Rateio")
		Endif
	Else
		Alert("A verba "+cCodVB+" não possui movimentacao de acordo com o parametro")
	Endif

	If Select(cArqTRB1)>0
		DbSelectArea(cArqTRB1)
		(cArqTRB1)->(DbCloseArea())
	EndIf
	RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/  ValVB
Funcao que le e processa a informacao da movimentacao mensal
@aParam
@author		Marcos Kato
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------

Static Function ValVB(cPrd)
	Local aArea   :=GetARea()
	Local cCodVB  :=""
	Local cCodVerb:=""
	Local cVerba  :=""
	Local nX      :=0

	If SB1->(FieldPos("B1_XCODVER"))>0 .And. !Empty(SB1->B1_XCODVER)
		cVerba:=""
		cDescVB:=""
		cCodVerb:=Alltrim(SB1->B1_XCODVER)
		For nX:=1 To Len(cCodVerb)
			If Substr(cCodVerb,nX,1)$"'=@#$%¨&*()-_+=[]{}<>.,;:?!/|\"
				If !Empty(cVerba)
					DbSelectArea("SRV")
					SRV->(DbSetOrder(1))
					SRV->(DbGoTop())
					If SRV->(DbSeek(xFilial("SRV")+AvKey(cVerba,"RV_COD")))
						cDescVB+=cVerba+"-"+Alltrim(SRV->RV_DESC)+CRLF
						cCodVB+="'"+cVerba+"',"
					Endif
				Endif
				cVerba:=""
			Else
				cVerba+=Substr(cCodVerb,nX,1)
			Endif
		Next
		If !Empty(cVerba)
			DbSelectArea("SRV")
			SRV->(DbSetOrder(1))
			SRV->(DbGoTop())
			If SRV->(DbSeek(xFilial("SRV")+AvKey(cVerba,"RV_COD")))
				cDescVB+=cVerba+"-"+Alltrim(SRV->RV_DESC)+CRLF
				cCodVB+="'"+cVerba+"'"
			Endif
		Endif
		oDescVB:Refresh()
	Endif
	RestARea(aArea)
Return cCodVB
//-------------------------------------------------------------------
/*/  ValVB
Funcao que le e processa a informacao da movimentacao mensal
@aParam
@author		Marcos Kato
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------

Static Function ProcVB(cCodVB,cMes,cAno)
	Local aArea   :=GetArea()
	Local cQuery  :=""
	Local cArqTRB1:=""
	Local nTotal  :=0
	Local _cPeriodo := cAno+cMes
	
	/* V11
	cQuery:=" "
	If cFolMes<=cAno+cMes
		cQuery+=" SELECT SUM(RC_VALOR) VALOR "
		cQuery+=" FROM "+RetSqlName("SRC")+" SRC "
		cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
//	cQuery+=" RV_FILIAL='"+xFilial("SRV")+"' "
		cQuery+=" RV_FILIAL=RC_FILIAL "
		cQuery+=" AND RV_COD=RC_PD "
		cQuery+=" AND SRV.D_E_L_E_T_=''
		cQuery+=" WHERE SRC.D_E_L_E_T_='' "
//	cQuery+=" AND RC_FILIAL='"+xFilial("SRC")+"' "
		cQuery+=" AND SUBSTRING(RC_DATA,1,6) = '"+cAno+cMes+"' "
		cQuery+=" AND RC_TIPO1='V' "
		cQuery+=" AND RC_PD IN ("+cCodVB+") "
	Else
		cQuery+=" SELECT SUM(RD_VALOR) VALOR "
		cQuery+=" FROM "+RetSqlName("SRD")+" SRD "
		cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
//	cQuery+=" RV_FILIAL='"+xFilial("SRV")+"' "
		cQuery+=" RV_FILIAL=RD_FILIAL "
		cQuery+=" AND RV_COD=RD_PD "
		cQuery+=" AND SRV.D_E_L_E_T_=''
		cQuery+=" WHERE SRD.D_E_L_E_T_=''
//	cQuery+=" AND RD_FILIAL='"+xFilial("SRD")+"' "
		cQuery+=" AND RD_DATARQ = '"+cAno+cMes+"' "
		cQuery+=" AND RD_TIPO1='V' "
		cQuery+=" AND RD_PD IN ("+cCodVB+") "
	Endif
	*/
	
	cQuery+="SELECT RGB_PERIOD AS PERIODO, SUM(RGB_VALOR) AS VALOR "+CRLF
	cQuery+="FROM "+RetSqlName("RGB")+" RGB 	"+CRLF
	cQuery+="INNER JOIN "+RetSqlName("SRV")+" SRV "+CRLF
	cQuery+="	ON RV_FILIAL = RGB_FILIAL AND RV_COD = RGB_PD AND SRV.D_E_L_E_T_ =''"+CRLF	
	cQuery+="WHERE  						"+CRLF
	cQuery+="	 RGB_PERIOD = '"+_cPeriodo+"'"+CRLF
	cQuery+="AND RGB_PD IN ("+cCodVB+") 	"+CRLF
	cQuery+="AND RGB.D_E_L_E_T_= ''  			"+CRLF
	cQuery+="GROUP BY RGB_PERIOD 			"+CRLF
	
	cQuery+=" UNION  "+CRLF
	
	cQuery+="SELECT SRD.RD_DATARQ AS PERIODO, SUM(SRD.RD_VALOR) AS VALOR  "+CRLF
	cQuery+="FROM "+RetSqlName("SRD")+" SRD 	"+CRLF
	cQuery+="INNER JOIN "+RetSqlName("SRV")+" SRV "+CRLF
	cQuery+="	ON RV_FILIAL = RD_FILIAL AND RV_COD = RD_PD AND SRV.D_E_L_E_T_ =''"+CRLF	
	cQuery+="WHERE   		 				"+CRLF
	cQuery+=" 	RD_DATARQ = '"+_cPeriodo+"' "+CRLF
	cQuery+="AND RD_PD 	  IN("+cCodVB+") 	"+CRLF	
	cQuery+="AND SRD.D_E_L_E_T_= '' 			"+CRLF
	cQuery+="GROUP BY RD_DATARQ 			"+CRLF	
	
	
	cArqTRB1 := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cArqTRB1 , .F., .T.)

	DbSelectArea(cArqTRB1)
	(cArqTRB1)->(DbGoTop())
	If (cArqTRB1)->(!Eof())
		nTotal:=0
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		Do While (cArqTRB1)->(!Eof())
			nTotal+=(cArqTRB1)->VALOR
			(cArqTRB1)->(DbSkip())
		End
	Endif
	If Select(cArqTRB1)>0
		DbSelectArea(cArqTRB1)
		(cArqTRB1)->(DbCloseArea())
	Endif
	RestArea(aArea)
Return nTotal
//-------------------------------------------------------------------
/*/  ValSB1
Funcao que efetua as validacoes minimas necessarias das informacoes 
passadas
@aParam
@author		Marcos Kato
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------

Static Function ValPrd(cPrdSB1)
	Local aArea:=GetARea()
	Local lRet :=.T.

	If !Empty(cPrdSB1)
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbGoTop())
		If !SB1->(DbSeek(xFilial("SB1")+AvKey(cPrdSB1,"B1_COD")))
			Alert("Produto informado não encontrado. Informe um produto valido")
			lRet:=.F.
		ElseIf SB1->(FieldPos("B1_XCODVER"))>0 .And. Empty(SB1->B1_XCODVER)
			Alert("Produto não possui verba informado. Informe um produto valido")
			lRet:=.F.
		Endif
	Else
		Alert("Produto não informado")
		lRet:=.F.
	Endif

	RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/  ValTES
Funcao que efetua as validacoes minimas necessarias das informacoes 
passadas
@aParam
@author		Marcos Kato
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------

Static Function ValTES(cTESSF4)
	Local aArea:=GetARea()
	Local lRet :=.T.

	If !Empty(cTESSF4)
		If !Substr(cTesSF4,1,1)$"01234"
			Alert("Tes Invalido")
		Else
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			SF4->(DbGoTop())
			If !SF4->(DbSeek(xFilial("SF4")+AvKey(cTESSF4,"F4_CODIGO")))
				Alert("Tipo de Entrada informado não encontrado. Informe um produto valido")
				lRet:=.F.
			Endif
		Endif
	Else
		Alert("Tipo de Entrada não informado")
		lRet:=.F.
	Endif
	RestArea(aArea)
Return lRet