#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA026
	Selecao dos pedidos de compra com projeto para inclusão no Documento
	de entrada.
@aParam
@Autor      David Ferreira Quadras
@since		31/07/2012
/*/
//--------------------------------------------------------------------

User Function IMFA026()

	Local aArea  	:= GetArea()
	Local cVar    	:= Nil
	Local cQrySC7   := ""
	Local cTitulo  	:= "Pedidos de Compra PMS"
	Local cPesq  	:= Space(9)
	Local lMark    	:= .F.
	Local oOk      	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
	Local oNo      	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
	Local _oDlg     := Nil
	Local oChk     	:= Nil
	Local nX		:=0
	Local nCont     :=0
	Local nItem		:=0
	Local nItPrd    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_ITEM" })
	Local nCodPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_COD" })
	Local nDescPrd  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_DESC" })
	Local nLocPad	:=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_LOCAL" })
	Local nUnid		:=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_UM" })
	Local nQtdPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_QUANT" })
	Local nVlrPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_VUNIT" })
	Local nTotPrd   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_TOTAL" })
	Local nQtdPC    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_QTDPC" })
	Local nSldPC    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_SLDPC" })
	Local nBaixa    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_BAIXA" })
	Local nCodTES   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_TES" })
	Local nDtDigit  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_DTDIGIT" })
	Local nNumPed   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_PEDIDO" })
	Local nItPed    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_ITEMPC" })
	Local nCodPrj   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_CODPSP" })
	Local nDescPrj  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_PROJTV1" })
	Local nCodTar   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_TAREFA" })
	Local nDescTar  :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_DESCTAR" })
	Local nUsrInc   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_USERLGI" })
	Local nCrdGer   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_CRDGR" })//Credito Gerado
	Local nCrdUtl   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_CRDUT" })//Credito Utilizado
	Local nCCusto   :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_CC" })
	Local lOK       := .F.
	Local nY
	Local lMarcado	:= .f.
	Local _cField 	:= ''
	Local _cRetranca:= ''
	Private lChk    := .F.
	Private oLbx 	:= Nil
	Private aVetor  := {}

	If FindFunction("U_IMFA018")
		u_IMFA018("IMFA026","Pedidos de Compras com Projeto")
	Endif

	If Empty(cA100For) .Or. Empty(cLoja) .Or. Empty(cNFiscal) .Or. Empty(cEspecie)
		Alert("Informe os dados do cabecalho da Nota")
	ElseIf !MaFisFound()
		Alert("Posicione na linha do documento de entrada")
	Else
		cQrySC7:=""
		cQrySC7+=" SELECT "+chr(13)+chr(10)
		cQrySC7+="	C7_ITEM, 	"
		cQrySC7+="	C7_NUM, 	"
		cQrySC7+="	C7_PRODUTO, "
		cQrySC7+="	B1_DESC, 	"
		cQrySC7+="	B1_LOCPAD,  "
		cQrySC7+="	B1_UM, 	 	"
		cQrySC7+="	C7_QUANT,	"
		cQrySC7+="	C7_QUJE, 	"
		cQrySC7+="	C7_PRECO, 	"
		cQrySC7+="	C7_TOTAL, 	"
		cQrySC7+="	C7_X_VLRBX, "
		cQrySC7+="	C7_CODPSP,  "
		cQrySC7+="	C7_DESCPRO, "
		cQrySC7+="	C7_TAREFA,  "
		cQrySC7+="	C7_DESCTAR, "
		cQrySC7+="	C7_CC, 	  	"
		cQrySC7+="	C7_X_VCGER, "
		cQrySC7+="	C7_X_CRDVL, "
		cQrySC7+="	C7_VLDESC 	"+chr(13)+chr(10)
		cQrySC7+=" FROM "+RetSqlName("SC7")+" SC7 "+chr(13)+chr(10)
		cQrySC7+=" INNER JOIN "+RetSqlName("SB1")+" SB1 ON ltrim(rtrim(SB1.B1_COD)) = ltrim(rtrim(C7_PRODUTO )) "+chr(13)+chr(10)
		cQrySC7+="   										  AND SB1.D_E_L_E_T_='' "+chr(13)+chr(10)
		cQrySC7+=" WHERE "	+chr(13)+chr(10)
		cQrySC7+="  		SC7.C7_FILIAL 	= '"+xFilial("SD1")+"' "+chr(13)+chr(10)
		cQrySC7+="  	AND SC7.C7_FORNECE 	= '"+cA100For+"'"+chr(13)+chr(10)
		cQrySC7+="  	AND SC7.C7_LOJA 		= '"+cLoja+"' "+chr(13)+chr(10)
		cQrySC7+="  	AND SC7.C7_QUANT 		> 0 "+chr(13)+chr(10)
		cQrySC7+="  	AND ( (C7_TOTAL-C7_X_CRDVL) -  C7_X_VLRBX  > 0 ) "+chr(13)+chr(10)  /*Se existir saldo(usuário alterou o valor unitario na grid), traz o pedido. Na TV1, os pedidos de compras vinculados a projetos sao tratados por valor, e nao por quantidade como no modulo padrao. */
		cQrySC7+="  	AND	SC7.C7_CONAPRO 	= 'L' "+chr(13)+chr(10)
		cQrySC7+="  	AND SC7.C7_CODPSP 	<> '' 	"+chr(13)+chr(10)
		cQrySC7+="  	AND C7_X_CMCNT 		<> '' 	"+chr(13)+chr(10)
		cQrySC7+="  	AND SC7.D_E_L_E_T_ 	='' 	"+chr(13)+chr(10)
		//cQrySC7+=" AND C7_QUANT <> C7_QUJE "
		
		MemoWrite( "\logws\imfa026.log" , cQrySC7)

		cArqSC7:= GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQrySC7),cArqSC7,.F.,.T.)

		DbSelectArea(cArqSC7)
		(cArqSC7)->(DbGoTop())
		If (cArqSC7)->(!Eof())
			Do While (cArqSC7)->(!Eof())
				
				If Ascan(aCols,{ |X| Alltrim(X[nNumPed])+Alltrim(X[nItPed])==Alltrim((cArqSC7)->C7_NUM)+Alltrim((cArqSC7)->C7_ITEM)})==0
			
					_cRetranca:= Posicione("SZ4",1, xFilial("SZ4")+Substr((cArqSC7)->C7_CODPSP,1,2), "Z4_X_DESC" )
			
					aAdd( aVetor, { ;
						lMark						,;
						(cArqSC7)->C7_NUM			,;
						(cArqSC7)->C7_ITEM		,;
						(cArqSC7)->C7_PRODUTO	,;
						(cArqSC7)->B1_DESC		,;
						(cArqSC7)->C7_TOTAL		,; //(cArqSC7)->C7_PRECO -(cArqSC7)->C7_X_VLRBX,;
						(cArqSC7)->C7_TOTAL-(cArqSC7)->C7_X_VLRBX,;
						(cArqSC7)->C7_CODPSP		,;
						Alltrim(_cRetranca) + "-" + Alltrim( (cArqSC7)->C7_DESCPRO),;
						(cArqSC7)->C7_TAREFA		,;
						(cArqSC7)->C7_DESCTAR	,;
						1							,;
						(cArqSC7)->B1_UM			,;
						(cArqSC7)->B1_LOCPAD		,;
						(cArqSC7)->C7_X_VCGER	,;
						(cArqSC7)->C7_X_CRDVL	,;
						(cArqSC7)->C7_CC			,;
						(cArqSC7)->C7_VLDESC	})
				Endif
				(cArqSC7)->(DbSkip())
			End
		Endif
		If Select(cArqSC7)>0
			DbSelectArea(cArqSC7)
			(cArqSC7)->(DbCloseArea())
		Endif
	
		If Len( aVetor ) == 0
			RestArea(aArea)
			Aviso( cTitulo, "*Não existem Pedidos de Compras com projetos"+Chr(13)+Chr(10)+" vinculados a este Fornecedor ", {"Ok"} )
			Return
		Endif
	
		DEFINE MSDIALOG _oDlg TITLE cTitulo FROM 0,0 TO 280,540 PIXEL STYLE DS_MODALFRAME
		@ 010,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
			" ", "Numero", "Item", "Produto","Descr.Prod.","Valor Total", "Saldo","Projeto", "Descr.Projeto","Tarefa", "Descr.Tarefa";
			SIZE 250,095 OF _oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
			Alltrim(aVetor[oLbx:nAt,2]),;
			Alltrim(aVetor[oLbx:nAt,3]),;
			Alltrim(aVetor[oLbx:nAt,4]),;
			Alltrim(aVetor[oLbx:nAt,5]),;
			Alltrim(Transform(aVetor[oLbx:nAt,6],"@E 999,999,999.99")),;
			Alltrim(Transform(aVetor[oLbx:nAt,7],"@E 999,999,999.99")),;
			Alltrim(aVetor[oLbx:nAt,8]),;
			Alltrim(aVetor[oLbx:nAt,9]),;
			Alltrim(aVetor[oLbx:nAt,10]),;
			Alltrim(aVetor[oLbx:nAt,11])}}
		 
		@ 120,010 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,010 PIXEL OF _oDlg ;
			ON CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())
		@ 120,110 MsGet  cPesq		Picture "@!"	Size 030,008 PIXEL OF _oDlg
		@ 120,150 Button "Pesquisar" 			 	Size 050,010 PIXEL OF _oDlg ACTION(A026Pesq(cPesq))
		DEFINE SBUTTON FROM 120,203 TYPE 1 ACTION (lOk:=.T.,_oDlg:End()) ENABLE OF _oDlg
		DEFINE SBUTTON FROM 120,233 TYPE 2 ACTION _oDlg:End()            ENABLE OF _oDlg
		_oDlg:lEscClose:=.F.
		ACTIVATE MSDIALOG _oDlg CENTER
	
		If lOk
			nCont:= 0
			For nX:= 1 To Len(aVetor)
				If aVetor[nX][1]

					lMarcado := .t.
					MsgRun("Pedido "+Alltrim(aVetor[nX][2])+", Aguarde...","",{|| CursorWait(),  ,CursorArrow()})
					If !Empty(aCols[Len(aCols)][nCodPrd])
						aAdd(aCols, Array(Len(aHeader) + 1 ) )
						For nY := 1 to Len(aHeader)
							If Alltrim(aHeader[nY,2])=="D1_ALI_WT"
								aCols[Len(aCols),nY] :="SD1"
							ElseIf Alltrim(aHeader[nY,2])=="D1_REC_WT"
								aCols[Len(aCols),nY] :=0
							ElseIf Alltrim(aHeader[nY,2])=="D1_GARANTI"
								aCols[Len(aCols),nY] :="N"
							ElseIf Alltrim(aHeader[nY,2])=="D1_RATEIO"
								aCols[Len(aCols),nY] :="2"
							ElseIf Alltrim(aHeader[nY,2])=="D1_USERLGA"
								aCols[Len(aCols),nY] := Space(TamSx3("D1_USERLGA")[1])
							ElseIf Alltrim(aHeader[nY,2])=="D1_OBSERVX"
								aCols[Len(aCols),nY] := Space(TamSx3("D1_OBSERVX")[1])
							ElseIf Alltrim(aHeader[nY,2])=="D1_CC"
								aCols[Len(aCols),nY] := Space(TamSx3("D1_CC")[1])
							ElseIf Alltrim(aHeader[nY,2])=="D1_CONTA"
								aCols[Len(aCols),nY] := Space(TamSx3("D1_CONTA")[1])
							ElseIf aHeader[nY,10] == "V"
								aCols[Len(aCols),nY] := CriaVar(aHeader[nY,2],.T.)
							Else
								aCols[Len(aCols),nY] := SD1->(FieldGet(FieldPos(aHeader[nY,2])))
							EndIf
						Next
						aCols[Len(aCols),Len(aHeader)+1] := .F.
					Else
									
					Endif
					nItem:=Len(aCols)
					aCols[nItem][nItPrd] 	:=StrZero(nItem,4)
					aCols[nItem][nCodPrd]	:=aVetor[nX][4]
					aCols[nItem][nDescPrd] 	:=aVetor[nX][5]
					aCols[nItem][nQtdPrd]	:=aVetor[nX][12]
					If nQtdPC>0
						aCols[nItem][nQtdPC]:=aVetor[nX][12]
					Endif
//				aCols[nItem][nVlrPrd]	:=aVetor[nX][6]
					aCols[nItem][nVlrPrd]	:=aVetor[nX][7]

//				aCols[nItem][nTotPrd]	:=aVetor[nX][7]
					aCols[nItem][nTotPrd]	:=(aVetor[nX][12]*aVetor[nX][7])
					If nSldPC>0
						aCols[nItem][nSldPC]:=aVetor[nX][7]
					Endif
					aCols[nItem][nDtDigit]	:=dDataBase
					aCols[nItem][nNumPed]  	:=aVetor[nX][2]
					aCols[nItem][nItPed]    :=aVetor[nX][3]
					If nCodPrj>0
						aCols[nItem][nCodPrj]  :=aVetor[nX][8]
					Endif
					If nDescPrj>0
						aCols[nItem][nDescPrj] :=aVetor[nX][9]
					Endif
					If nCodPrj>0
						aCols[nItem][nCodTar]  :=aVetor[nX][10]
					Endif
					If nDescPrj>0
						aCols[nItem][nDescTar] :=aVetor[nX][11]
					Endif
					If nUnid>0
						aCols[nItem][nUnid]    :=aVetor[nX][13]
					Endif
					If nLocPad>0
						aCols[nItem][nLocPad]  :=aVetor[nX][14]
					Endif
					If nCrdGer>0
						aCols[nItem][nCrdGer]  :=aVetor[nX][15]
					Endif
					If nCrdUtl>0
						aCols[nItem][nCrdUtl]  :=aVetor[nX][16]
					Endif
					If nCCusto>0
						aCols[nItem][nCCusto]  :=aVetor[nX][17]
					Endif
					If nBaixa>0
						aCols[nItem][nBaixa]  :="P"
					Endif
					If nCodTES>0
						aCols[nItem][nCodTES] :="103"
					Endif
					If nUsrInc>0
						aCols[nItem][nUsrInc] := SD1->(FieldGet(FieldPos(aHeader[nUsrInc,2])))
					Endif
				
					If aVetor[nX][18] > 0 // Valor do Desconto(Gnova)
						aCols[nItem][GdFieldPos("D1_VALDESC")] := aVetor[nX][18]
					EndIf
				
					oGetDados:lNewLine		  := .T.
					oGetDados:oBrowse:nAt 	  := nItem
					oGetDados:oBrowse:Refresh()
					oGetDados:Refresh()
					oGetDados:lNewLine		  := .f.
					SysRefresh()
				
					DbSelectArea("SB1")
					SB1->(DbSetOrder(1))
					SB1->(DbSeek(xFilial("SB1")+aVetor[nX][4]))
				
					MaFisIniLoad(nItem)
					MaFisAlt("IT_PRODUTO"	,aVetor[nX][4],nItem)
					MaFisAlt("IT_QUANT"		,aVetor[nX][12],nItem)
					MaFisAlt("IT_PRCUNI"		,aVetor[nX][7],nItem)
					MaFisAlt("IT_VALMERC"	,aVetor[nX,12]*aVetor[nX,7],nItem)
				
					If aVetor[nX][18] > 0 // Valor do Desconto(Gnova)
						MaFisAlt("IT_DESCONTO"	,aVetor[nX,18],nItem)
					EndIf
				           
					MaFisLoad("IT_TES","",nItem)
					If MaAvalTes("E","103").And.MaFisRef("IT_TES","MT100","103")
						MaFisAlt("IT_TES","103",nItem)
					Endif
					MaFisEndLoad(nItem)
				Endif
			Next
		
			If lMarcado
				MaFisToCols(aHeader,aCols,,"MT100")
				For nItem := 1 to len(aCols)
					For nY := 1 to Len(aHeader)
						_cField := Alltrim(aHeader[nY,2])
						If Alltrim(aHeader[nY,10]) <> "V"
							If ExistTrigger(_cField)
								RunTrigger(2,nItem,nil,,_cField)
							EndIf
						EndIf
					Next nY
				Next nItem
			
				If ValType('oGetDados') <> 'U'
					oGetDados:oBrowse:nAt := len(aCols)
					oGetDados:oBrowse:SetFocus()
					oGetDados:oBrowse:Refresh()
					oGetDados:Refresh()
				EndIf
			EndIf
		EndIf
	EndIf

	SysRefresh()
	RestArea(aArea)
Return(Nil)

//-------------------------------------------------------------------
/*/A026Pesq
Pesquisa o pedido da tela executada via botao referente aos pedidos 
de compra do projeto 
Entrada
@aParam
@author		Marcos Kato
@since		08/08/2012
@uso        MATA103
@Obs        
/*/
//--------------------------------------------------------------------
Static Function A026Pesq(cNumPC)
	Local aArea	:=GetArea()
	Local nPos 	:= 0

	nPos := Ascan(aVetor,{ |X| Alltrim(X[2])== Alltrim(cNumPC)})
	If nPos > 0
		oLbx:nAt:=nPos
	Else
		oLbx:nAt:=1
	Endif
	oLbx:Refresh()
	RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/IMFA026When
Habilitar ou Desabilitar para Edicao o Campo Valor Unitario no Documento
Entrada
@aParam
@author		Marcos Kato
@since		08/08/2012
@uso        MATA103
@Obs        Funcao executada no When do Campo D1_VUNIT
/*/
//--------------------------------------------------------------------

User Function IMFA026When()
	Local aArea :=GetArea()
	Local nBaixa    :=aScan(aHeader, {|x| AllTrim(Upper(x[2])) == "D1_X_BAIXA" })
	Local lRet	:=.T.

	If Alltrim(aCols[n][nBaixa])  == "P"
		lRet:=.F.
	Endif
	RestArea(aArea)
Return lRet