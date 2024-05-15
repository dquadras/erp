#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"
#Include "TOPCONN.CH"
#Define CRLF CHR(13)+CHR(10)
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA012
Funcao para importacao os dados do movimento mensal(SRC) por centro 
de custo de acordo com a verba na Nota Fiscal de Entrada
@aParam
@Autor           David Ferreira Quadras
@since		05/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------
User Function IMFA014()          
Local aArea  := GetArea()
Local oDlg 
Local oSay1, oSay2, oSay3, oSay4, oSay5, oSay6
Local oConf, oCanc, oPrd, oVlNF, oAno, oMes, oDescVB, oTotVB, oTes
Local cPrd	      := Space(15)  
Local cTes		  := Space(3)	
Local cDescVB     := Space(30) 
Local cMes        := Month(Date())
Local cAno		  := Year(Date())	 
Local cVBSA1      := ""                        
Local nVlNF       := 0
Local nTotVB      :=0
Local lRet    	  := .F.
     
If !cTipo$"DB"
	If Empty(cA100For) .Or. Empty(cLoja)
		Alert("Informe o Codigo do Fornecedor da Nota Fiscal")
	Else
		DbSelectArea("SA2")
		SA2->(DbSetOrder(1))
		SA2->(DbGoTop())
		If SA2->(DbSeek(xFilial("SA2")+AvKey(cA100For,"A2_COD")+AvKey(cLoja,"A2_LOJA")))
	     	If SA2->(FieldPos("A2_XCODVER"))>0 .And. !Empty(SA2->A2_XCODVER)
	     		cVBSA1:=SA2->A2_XCODVER                                               
	     		cDescVB:=cVBSA1+"-"+Posicione("SRV",1,xFilial("SRV")+cVBSA1,"RV_DESC")
				nTotVB:=ValVB(cVBSA1,cMes,cAno) 		     		

				DEFINE MSDIALOG oDlg TITLE "Rateio por Centro de Custo por Verba" FROM 000, 000  TO 280, 320  PIXEL STYLE DS_MODALFRAME
				   @ 010, 005 SAY oSay1 	PROMPT "Produto" 																	  			SIZE 035, 010 	OF oDlg  PIXEL
				   @ 010, 050 MSGET oPrd 		VAR cPrd  		Picture "@!" Valid ValPrd(cPrd)    								   			SIZE 060, 010 	OF oDlg  F3 "SB1" PIXEL

				   @ 025, 005 SAY oSay2 	PROMPT "Mes"																					SIZE 020, 010	OF oDlg  PIXEL
				   @ 025, 025 MSGET oMes		VAR cMes 		Picture "@R 99" Valid(nTotVB:=ValVB(cVBSA1,cMes,cAno),oTotVB:Refresh())  	SIZE 020, 010 	OF oDlg  PIXEL

				   @ 025, 060 SAY oSay3 	PROMPT "Ano"																		  			SIZE 020, 010	OF oDlg  PIXEL
				   @ 025, 080 MSGET oAno		VAR cAno 		Picture "@R 9999" Valid(nTotVB:=ValVB(cVBSA1,cMes,cAno),oTotVB:Refresh())	SIZE 040, 010 	OF oDlg  PIXEL

				   @ 040, 005 SAY oSay4 	PROMPT "TES"																		   			SIZE 035, 010	OF oDlg  PIXEL
				   @ 040, 050 MSGET oTES	VAR cTES 			Picture "@!" Valid ValTES(cTES)		   							  			SIZE 040, 010 	OF oDlg  F3 "SF4" PIXEL

				   @ 060, 005 SAY oSay4 	PROMPT "Verba"																		   			SIZE 035, 010	OF oDlg  PIXEL
				   @ 060, 050 MSGET oDescVB	VAR cDescVB 									When .F.   							  			SIZE 100, 010 	OF oDlg  PIXEL

				   @ 080, 005 SAY oSay5 	PROMPT "Valor Verba"																 			SIZE 035, 010	OF oDlg  PIXEL
				   @ 080, 050 MSGET oTotVB		VAR nTotVB	 	Picture "@E 999,999,999.99" When .F.   							 			SIZE 060, 010 	OF oDlg  PIXEL
				                                  
				   @ 100, 005 SAY oSay6 	PROMPT "Valor Nota"																	 			SIZE 035, 010	OF oDlg  PIXEL
				   @ 100, 050 MSGET oVlNF		VAR nVlNF 		Picture "@E 999,999,999.99"         							 			SIZE 060, 010 	OF oDlg  PIXEL
				
				oDlg:lEscClose:=.F.              
					
				DEFINE SBUTTON oConf 	FROM 120, 090 TYPE 01 ACTION (lRet:=.T.,oDlg:End())  		 	OF oDlg ENABLE
				DEFINE SBUTTON oCanc 	FROM 120, 120 TYPE 02 ACTION (oDlg:End())     		           	OF oDlg ENABLE
				
				ACTIVATE MSDIALOG oDlg CENTERED 
				
				If lRet             
				 	MsgRun("Processando Movimentacao"       ,"Aguarde...", {||CursorWait(),ProcVBSRC(cPrd,cTES,cVBSA1,nVlNF) ,CursorArrow()})
				Endif
	        Else
	        	Alert("A verba do fornecedor não encontrada")
			Endif	
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
Static Function ProcVBSRC(cProd,cTES,cCodVB,nVlrNFE)
Local aArea		:=GetARea()
Local cQuery	:=""
Local cArqTRB1	:=""  
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
Local nY
cQuery:=" "
cQuery+=" SELECT TOP 2 RV_DESC, RC_CC CC,SUM(RC_VALOR) VALOR "
cQuery+=" FROM "+RetSqlName("SRC")+" SRC "
cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
cQuery+=" RV_FILIAL='"+xFilial("SRV")+"' "
cQuery+=" AND RV_COD=RC_PD "
cQuery+=" AND SRV.D_E_L_E_T_=''
cQuery+=" WHERE SRC.D_E_L_E_T_='' "
cQuery+=" AND RC_FILIAL='"+xFilial("SRC")+"' "
cQuery+=" AND RC_TIPO1='V' "
cQuery+=" AND RC_PD ='"+cCodVB+"' "
cQuery+=" GROUP BY RV_DESC,RC_CC "

cArqTRB1 := GetNextAlias()
cQuery   := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cArqTRB1 , .F., .T.)

DbSelectArea(cArqTRB1)
(cArqTRB1)->(DbGoTop())
If (cArqTRB1)->(!Eof())
	DbSelectArea("SB1") 
	SB1->(DbSetOrder(1))
	SB1->(DbGoTop())       			
	If SB1->(dbSeek(xFilial("SB1")+AvKey(cProd,"B1_COD")))
		aCols:={}
		DbSelectArea("SF4") 
		SF4->(DbSetOrder(1))
		SF4->(DbGoTop())       			
		If SF4->(dbSeek(xFilial("SF4")+AvKey(cTES,"F4_CODIGO")))
			cCf:=SF4->F4_CF
	 	Endif
		Do While (cArqTRB1)->(!Eof())		
			aAdd(aCols, Array(Len(aHeader) + 1 ) )
			For nY := 1 to Len(aHeader)
				If aHeader[nY,10] == "V"
					aCols[Len(aCols),nY] := CriaVar(aHeader[nY,2],.T.)
				Else                                            
					aCols[Len(aCols),nY] := SD1->(FieldGet(FieldPos(aHeader[nY,2])))
				EndIf
			Next
			aCols[Len(aCols),Len(aHeader)+1] := .F.           
			
			aCols[Len(aCols)][nItPrd] :=StrZero(Len(aCols),4)
			aCols[Len(aCols)][nCodPrd]:=cProd
			aCols[Len(aCols)][nUMPrd] :=SB1->B1_UM
			aCols[Len(aCols)][nLocPrd]:=SB1->B1_LOCPAD
			aCols[Len(aCols)][nQtdPrd]:=1
			aCols[Len(aCols)][nVlrPrd]:=(cArqTRB1)->VALOR
			aCols[Len(aCols)][nTotPrd]:=(cArqTRB1)->VALOR
			aCols[Len(aCols)][nCCPrd] :=(cArqTRB1)->CC      
			aCols[Len(aCols)][nCdTES] :=cTES
			aCols[Len(aCols)][nCFTES] :=cCF
			(cArqTRB1)->(DbSkip())
		End	     
		n:=1   
	Endif	
Endif
If Select(cArqTRB1)>0
	DbSelectArea(cArqTRB1)
	(cArqTRB1)->(DbCloseArea())
Endif
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

Static Function ValVB(cCodVb,cMes,cAno) 
Local cQuery  :=""
Local cArqTRB1:=""
Local nTotal  :=0
cQuery:=" "
If cMes==Month(Date()) .And. cAno==Year(Date())

	cQuery+=" SELECT SUM(RC_VALOR) VALOR " 
	cQuery+=" FROM "+RetSqlName("SRC")+" SRC "
	cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
	cQuery+=" RV_FILIAL='"+xFilial("SRV")+"' "
	cQuery+=" AND RV_COD=RC_PD "
	cQuery+=" AND SRV.D_E_L_E_T_=''
	cQuery+=" WHERE SRC.D_E_L_E_T_='' "
	cQuery+=" AND RC_FILIAL='"+xFilial("SRC")+"' "
	cQuery+=" AND RC_TIPO1='V' "
	cQuery+=" AND RC_PD ='"+cCodVB+"' "
	cQuery+=" GROUP BY RC_CC "

Else
	cQuery+=" SELECT SUM(RC_VALOR) VALOR "
	cQuery+=" FROM "+RetSqlName("SRC")+" SRC "
	cQuery+=" INNER JOIN "+RetSqlName("SRV")+" SRV ON "
	cQuery+=" RV_FILIAL='"+xFilial("SRV")+"' "
	cQuery+=" AND RV_COD=RC_PD "
	cQuery+=" AND SRV.D_E_L_E_T_=''
	cQuery+=" WHERE SRC.D_E_L_E_T_='' "
	cQuery+=" AND RC_FILIAL='"+xFilial("SRC")+"' "
	cQuery+=" AND RC_TIPO1='V' "
	cQuery+=" AND RC_PD ='"+cCodVB+"' "
	cQuery+=" GROUP BY RC_CC "

Endif	
cArqTRB1 := GetNextAlias()
cQuery   := ChangeQuery(cQuery)
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
Else
	Alert("A verba "+cCodVB+" não possui movimentacao de acordo com o parametro")	
Endif	
If Select(cArqTRB1)>0
	DbSelectArea(cArqTRB1)
	(cArqTRB1)->(DbCloseArea())
Endif
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
			Alert("Produto informado não encontrado. Informe um produto valido")	
			lRet:=.F.
		Endif
	Endif	        
Else
	Alert("Tipo de Entrada não informado")	
	lRet:=.F.
Endif

RestArea(aArea)
Return lRet