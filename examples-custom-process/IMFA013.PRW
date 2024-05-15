#INCLUDE "APWEBSRV.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA013
Funcao para tratamento do pedido de compra via Solicitacao/Alteracao de Produto X Fornecedor sem voltar a alçada.
@aParam
@Autor     David Ferreira Quadras
@since		12/12/2011
@uso        MATA120
/*/
//--------------------------------------------------------------------
User Function IMFA013()
Local oDlg, oSay1, oSay2, oCond, oConf, oCanc, oCodFor, oLojFor
Local aArea  		:=GetArea()
Local cQuery    	:=""
Local cQryTRB		:=""
Local cArqTRB		:=""
Local cTpCmp    	:="V"
Local nX        	:= 0
Local nY        	:= 0
Local aFieldSC7    	:={"C7_ITEM","C7_PRODUTO"}
Local aHdSC7    	:={}
Local aColSC7   	:={}
Local aLista    	:={}
Local aAltField 	:={"C7_PRODUTO"}
Local lRet   		:=.t.
Private cCNPJNew	:=""
Private cNumPC  	:=""
Private cCodFor		:=""
Private cLojFor		:=""
Private cGrupo  	:=""
Private nVlrSC7 	:= 0
Private nMoedaSC7 	:= 0
Private nTXSC7    	:= 0
Private dDtSC7    	:= Ctod("//")
Private cProjeto  	:=""
Private cDescPrj  	:=""
Private cTarefa   	:=""
Private cDescTar  	:=""
Private lGrupo  	:=""
Private lAltFor   	:=.F.	//Usuario Altera Fornecedor
Private lAltPrd 	:=.F.	//Usuario Altera Produto
Private cCNPJOld  	:=""
Private S           :=.T.	//Variavel Obrigatorio devido a Consulta do Produto. Se não for informado ira gerar um Errro Log qinformando que a variavel nao existe
Private oGetSC7		:= Nil
Private lReprApr  :=.F.


If FindFunction("U_IMFA018")
	u_IMFA018("IMFA013","Alteracao Pedido para Produto e Fornecedor")
Endif

lAltFor:=Alltrim(Upper(UsrRetName(__cUserID)))$Alltrim(Upper(SuperGetMV("FS_ALFORPC",.T.,"")))
lAltPrd:=Alltrim(Upper(UsrRetName(__cUserID)))$Alltrim(Upper(SuperGetMV("FS_ALPRDPC",.T.,"")))

DbSelectArea("SX3")
SX3->(DbSetOrder(2))
For nX := 1 To Len(aFieldSC7)
	If SX3->(DbSeek(aFieldSC7[nX]))
		cTpCmp:="V"
		If lAltPrd
			cTpCmp:="A"
		Endif
		aAdd(aHdSC7,{ ;
		AllTrim(X3Titulo()),;
		SX3->X3_CAMPO	,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		""	,;
		SX3->X3_USADO	,;
		SX3->X3_TIPO	,;
		SX3->X3_F3 		,;
		SX3->X3_VISUAL,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX	,;
		SX3->X3_RELACAO	,;
		SX3->X3_INIBRW	,;
		SX3->X3_BROWSE	,;
		cTpCmp})
	Endif
Next
If Alltrim(SC7->C7_X_FLAG)=="3"
	Alert("Alteracao nao permitida para pedido de solicitacao de verba")
Else
	cNumPC   := SC7->C7_NUM
	cCNPJOld := Alltrim(Posicione("SA2",1,xFilial("SA2")+AvKey(SC7->C7_FORNECE,"A2_COD")+AvKey(SC7->C7_LOJA,"A2_LOJA"),"A2_CGC"))
	
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))//FILIAL+PEDIDO
	SC7->(DbGoTop())
	If SC7->(DbSeek(xFilial("SC7")+AvKey(cNumPC,"C7_NUM")))
		nX			:=0
		aColSC7		:={}
		cCodFor  	:=SC7->C7_FORNECE
		cLojFor  	:=SC7->C7_LOJA
		nMoedaSC7	:=SC7->C7_MOEDA
		nTXSC7   	:=SC7->C7_TXMOEDA
		dDtSC7   	:=SC7->C7_EMISSAO
		cGrupo   	:=SC7->C7_APROV
		cProjeto 	:=SC7->C7_PROJET
		cDescPrj 	:=SC7->C7_DESCPRO
		cTarefa  	:=SC7->C7_TAREFA
		cDescTar 	:=SC7->C7_DESCTAR
		If (SC7->C7_QUJE==0 .And. SC7->C7_QTDACLA==0) .Or. (SC7->C7_CONAPRO=="B" .And. SC7->C7_QUJE<SC7->C7_QUANT)
			Do While SC7->(!Eof()) .And. Alltrim(SC7->C7_NUM)==Alltrim(cNumPC)
				cQuery := " SELECT D1_PEDIDO "
				cQuery += " FROM " + RetSqlName("SD1") + " SD1 "
				cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' "
				cQuery += " AND D1_PEDIDO  = '"+cNumPC+"' "
				cQuery += " AND D1_FILIAL = '"+xFilial("SD1")+"' "
				If Select("TEMP") > 0
					TEMP->(dbCloseArea())
				EndIf
				TcQuery cQuery New Alias "TEMP"
				DbSelectArea("TEMP")
				If 	!TEMP->(Eof())
					lRet := .f.
					Exit
				Else
					nVlrSC7 += SC7->C7_TOTAL
					aAdd(aColSC7, Array(Len(aHdSC7)+1))
					aColSC7[Len(aColSC7)][1]:=SC7->C7_ITEM
					aColSC7[Len(aColSC7)][2]:=SC7->C7_PRODUTO
					aColSC7[Len(aColSC7),Len(aHdSC7)+1] := .F.
				EndIf
				SC7->(DbSkip())
			End
			If Select("TEMP") > 0
				TEMP->(dbCloseArea())
			EndIf
			
			If lRet
				//DEFINE MSDIALOG  oDlg 	TITLE "Alteracao Pedido" 				FROM 000, 000  TO 250, 400  PIXEL STYLE DS_MODALFRAME
				
				DEFINE MSDIALOG  oDlg 	 	TITLE "Alteracao Pedido" 				FROM 000, 000  TO 290, 600  PIXEL STYLE DS_MODALFRAME
				
				nRight := 0285
				nDepth := 0030
				@ 003, 005 To nDepth, nRight LABEL "De:" OF oDlg Pixel
				
				//=========================================================================================================================================
				//Apenas pessoas autorizadas poderao alterar pedido e mesmo assim apenas se pertencer entre a matriz e as filiais da matriz
				//=========================================================================================================================================
				_cCodForDe:= cCodFor
				_cCodLoja := cLojFor
				@ 014, 007 SAY   oSay1 	 	PROMPT "Fornecedor"  COLOR CLR_GREEN																	  					SIZE 035, 010 	OF oDlg  PIXEL
				@ 012, 035 MSGET oCodFor 	VAR _cCodForDe		 PICTURE "@!" WHEN .F.	SIZE 060, 010 	OF oDlg  PIXEL
				
				@ 014, 095 SAY oSay2 		PROMPT "Loja"		COLOR CLR_GREEN																						SIZE 020, 010	OF oDlg  PIXEL
				@ 012, 110 MSGET oLojFor	VAR _cCodLoja 		PICTURE "@!" WHEN .F.   SIZE 020, 010 	OF oDlg  PIXEL
				
				@ 012, 0135 MSGET oLojFor	VAR Posicione("SA2",1,xFilial("SA2")+_cCodForDe+_cCodLoja,"A2_NOME") PICTURE "@!" WHEN .F. 				SIZE 0140, 010 	OF oDlg  PIXEL
				
				
				nRight := 0285
				nDepth := 0058
				@ 031, 005 To nDepth, nRight LABEL "Para:" OF oDlg Pixel
				
				@ 040, 005 SAY   oSay1 	 	PROMPT "Fornecedor" 																	  					SIZE 035, 010 	OF oDlg  PIXEL
				@ 040, 035 MSGET oCodFor 	VAR cCodFor 			 				PICTURE "@!" VALID ValFor(cCodFor,cLojFor)	F3 "FOR"				SIZE 060, 010 	OF oDlg  PIXEL
				
				@ 040, 095 SAY oSay2 		PROMPT "Loja"																								SIZE 020, 010	OF oDlg  PIXEL
				@ 040, 110 MSGET oLojFor	VAR cLojFor				 				PICTURE "@!" Valid ValFor(cCodFor,cLojFor)                  		SIZE 020, 010 	OF oDlg  PIXEL
				
				@ 040, 0135 MSGET oLojFor	VAR Posicione("SA2",1,xFilial("SA2")+cCodFor,"A2_NOME") PICTURE "@!" WHEN .F. 								SIZE 0140, 010 	OF oDlg  PIXEL
				
				
				//=========================================================================================================================================
				//Apenas pessoas autorizadas poderao alterar produto
				//=========================================================================================================================================
				oGetSC7:= MsNewGetDados():New(065,005,125,285,Iif(Len(aColSC7)>0 .And. lAltPrd,GD_UPDATE,0),,,,aAltField,,Len(aColSC7),,,,oDlg,aHdSC7,aColSC7)
				oDlg:lEscClose:=.F.
				DEFINE SBUTTON oConf 	FROM 130, 140 TYPE 01 ACTION (lRet:=ValFor(cCodFor,cLojFor),oDlg:End())  OF oDlg ENABLE
				DEFINE SBUTTON oCanc 	FROM 130, 170 TYPE 02 ACTION (oDlg:End(), lRet := .f.)     		         OF oDlg ENABLE
				ACTIVATE MSDIALOG oDlg CENTERED
				If lRet
					processa({ || A013AltSC7() }, "Aguarde... Alterando dados no Pedido de Compras!" )
				Endif
			Else
				Alert("Pedido não poderá ser alterado por ter gerado Nota Fiscal de Entrada!")
			Endif
			If Select("TEMP") > 0
				DbSelectArea("TEMP")
				TEMP->(dbCloseArea())
			EndIf
		Else
			Alert("A alteracao do fornecedor somente podera para pedido pendente ou bloqueado")
		Endif
	Endif
Endif
RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/ {Protheus.doc} A013AltSC7
Processa alteracoes de Pedido de Compras.
@aParam
@author		Marcos Kato
@since		12/12/2011
@uso        MATA120
/*/
//--------------------------------------------------------------------
Static Function A013AltSC7()
Local aArea		:=GetArea()
Local cNomFor   	:=Alltrim(Posicione("SA2",1,XFILIAL("SA2")+cCodFor,"A2_NOME"))
Local cObs  		:= ""
Local cTrocaSA2	:= ""
Local cTrocaSB1	:= ""
Local cCodProc	:= ""
Local cHtmlMod 	:= ""
Local cAssunto	:= ""
Local cMensagem 	:= ""
Local cMsgWF   	:=""
Local cEmail		:= ""
Local nX			:= 0
Local oProcess
Local oHtml

//Ajuste no pedido de compra
cNotif:=""
DbSelectArea("SC7")
SC7->(DbSetOrder(1))//FILIAL+PEDIDO
SC7->(DbGoTop())
For nX := 1 To Len(oGetSC7:ACOLS)
	If SC7->(DbSeek(xFilial("SC7")+AvKey(cNumPC,"C7_NUM")+AvKey(oGetSC7:ACOLS[nX][1],"C7_ITEM")))
		If Alltrim(cCodFor+cLojFor)<>Alltrim(SC7->C7_FORNECE+SC7->C7_LOJA) .Or. Alltrim(SC7->C7_PRODUTO)<>Alltrim(oGetSC7:ACOLS[nX][2])
			cObs:=""
			If Alltrim(cCodFor+cLojFor)<>Alltrim(SC7->C7_FORNECE+SC7->C7_LOJA)
				cObs+= "Fornecedor"
				
				If Empty(AllTrim(SC7->C7_APROV)) //Pedido sem alçada de aprovação
				
					lReprApr := .F.
					
					cMensagem := "O fornecedor foi alterado com sucesso!" + chr(13) + chr(10)
					
					cTrocaSA2 := "<tr><td  align=left>O fornecedor foi alterado com sucesso!</td></tr>"
				
				Else
				
					If lAltFor
						If Substr(cCNPJNew,1,8) <> Substr(cCNPJOld,1,8)
							
							lReprApr := .T.
							
							//Aceita alteração de Fornecedor do Mesmo Grupo
							//ValGrupo()
							
							cMensagem := "O fornecedor foi alterado com sucesso!" + chr(13) + chr(10)
							cMensagem += "Dentro de alguns instantes o Workflow será reenviado para os aprovadores deste pedido."
							
							cTrocaSA2 := "<tr><td  align=left>O fornecedor foi alterado com sucesso!</td></tr>"
							cTrocaSA2 += "<tr><td  align=left>O Workflow ser"+u_L001Acento("á")+" reenviado para os aprovadores deste pedido.</td></tr>"
						Else
							lReprApr := .F.
							
							//Aceita alteração de Fornecedor do Mesmo Grupo
							//ValGrupo()
							
							cMensagem += "Pedido de compra alterado com sucesso!" + chr(13) + chr(10)
							cMensagem := "O novo fornecedor pertence à mesma MATRIZ/FILIAL que o anterior."		
												
							cTrocaSA2 := "<tr><td  align=left>Pedido de compra alterado com sucesso!</td></tr>"
							cTrocaSA2 += "<tr><td  align=left>O novo fornecedor pertence a mesma MATRIZ/FILIAL que o anterior.</td></tr>"
						Endif
					Else
						
						lReprApr := .T.
						
						//Aceita alteração de Fornecedor do Mesmo Grupo
						//ValGrupo()
						
						cMensagem := "O fornecedor foi alterado com sucesso!"+chr(13)+chr(10)
						cMensagem += "Dentro de alguns instantes o Workflow será reenviado para os aprovadores deste pedido."
						
						cTrocaSA2 := "<tr><td  align=left>O fornecedor foi alterado com sucesso!</td></tr>"
						cTrocaSA2 += "<tr><td  align=left>Dentro de alguns instantes o Workflow ser" + u_L001Acento("á") + " reenviado para os aprovadores deste pedido.</td></tr>"
					Endif
					
				EndIf
				
				cTrocaSA2+="<br>"
				cTrocaSA2+= "<tr><td  align=left>Fornecedor Anterior: CNPJ "+Transform(cCNPJOld,"@R 99.999.999/9999-99")+" Razao Social-"+Alltrim(Posicione("SA2",1,XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"))+"</td></tr>"
				cTrocaSA2+= "<tr><td  align=left>Fornecedor Atual...: CNPJ "+Transform(cCNPJNew,"@R 99.999.999/9999-99")+" Razao Social-"+Alltrim(Posicione("SA2",1,XFILIAL("SA2")+cCodFor+cLojFor,"A2_NOME"))+"</td></tr>"
			Endif
			
			If Alltrim(SC7->C7_PRODUTO)<>Alltrim(oGetSC7:ACOLS[nX][2])
				If !Empty(cObs)
					cObs+= " e "
				Endif
				cObs+= "Produto"
				cTrocaSB1+="<tr><td  align=left>Produto "+Alltrim(SC7->C7_PRODUTO)+"-"+Alltrim(Posicione("SB1",1,XFILIAL("SB1")+SC7->C7_PRODUTO,"B1_DESC"))+" alterado para "+Alltrim(oGetSC7:ACOLS[nX][2])+"-"+Alltrim(Posicione("SB1",1,XFILIAL("SB1")+oGetSC7:ACOLS[nX][2],"B1_DESC"))+"</td></tr>"
			Endif
			cObs+=" alterado pelo usuario "+ cUserName //UsrFullName(__cUserId)
			RecLock("SC7",.F.)
			SC7->C7_FORNECE 	:=cCodFor
			SC7->C7_LOJA    	:=cLojFor
			SC7->C7_FORDESC	:=cNomFor
			SC7->C7_PRODUTO	:=oGetSC7:ACOLS[nX][2]
			SC7->C7_DESCRI	:=Posicione("SB1",1,XFILIAL("SB1")+oGetSC7:ACOLS[nX][2],"B1_DESC")
			//SC7->C7_OBS   	:=cObs
			SC7->C7_X_WF   	:=""
			
			If lReprApr
				SC7->C7_CONAPROV := "B"
				If SC7->(FieldPos("C7_XMSGLOG")) > 0
					SC7->C7_XMSGLOG := cObs + CHR(13)+CHR(10)+cMensagem				 
				EndIf
			EndIf
			SC7->(MsUnLock())
		EndIf
	EndIf
Next
If !Empty(cTrocaSA2) .Or. !Empty(cTrocaSB1)
	cCodProc	:= "NOTIF"
	cHtmlMod 	:= "\WORKFLOW\HTML\NOTIF.htm"
	cAssunto	:= "Notificacao de alteracao do pedido de compra "+cNumPC
	cMsgWF:="<tr>"
	cMsgWF+="<td  align=left>Prezados Aprovadores,</td>"
	cMsgWF+="</tr>"
	cMsgWF+="<tr>"
	cMsgWF+="<td  align=left>Em "+DtoC(dDataBase)+", o pedido "+cNumPC+" foi alterado por: "+ cUserName /*UsrFullName(__cUserId)*/ +" </td>"
	cMsgWF+="</tr>"
	cMsgWF+="<tr>"
	cMsgWF+="<td  align=left>Segue abaixo a modifica"+u_L001Acento("ç")+u_L001Acento("ã")+"o efetuada:</td>"
	cMsgWF+="</tr>"
	If !Empty(cTrocaSA2)
		cMsgWF+="<br>"
		cMsgWF+=cTrocaSA2
	Endif
	If !Empty(cTrocaSB1)
		cMsgWF+="<br>"
		cMsgWF+=cTrocaSB1
	Endif
	
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	SCR->(DbGoTop())
	If SCR->(DbSeek(xFilial("SCR")+AvKey("PC","CR_TIPO")+AvKey(cNumPC,"CR_NUM")))
		cEmail:=""
		Do While SCR->(!Eof()) .And. cNumPC==Alltrim(SCR->CR_NUM)
			cEmail+=Alltrim(UsrRetMail(SCR->CR_USER))+";"
			SCR->(DbSkip())
		End
		cEmail+=Substr(cEmail,1,Len(cEmail)-1)
		oProcess:= TWFProcess():New(cCodProc, cAssunto)
		oProcess:NewTask(cAssunto, cHtmlMod)
		oProcess:cSubject:= cAssunto
		oProcess:cTo:= cEmail

		oProcess:cCC := "microsiga@grupotv1.com.br" // Adiciona cópia		
		
		oHtml:=oProcess:oHtml
		oHtml:ValByName( "msg"		,cMsgWF)
		oProcess:Start()
		oProcess:Finish()
	Endif
Endif
If !Empty(cMensagem)
	Aviso("ATENÇÃO", cMensagem , {"OK"} )
EndIf
//=====================================
//Reprocessa Aprovacao
//=====================================
If lReprApr
	//=================================
	//Reprocessa a alcada
	//=================================
	If !Empty(cGrupo)
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))//FILIAL+TIPO+PEDIDO
		SCR->(DbGoTop())
		If SCR->(DbSeek(xFilial("SCR")+AvKey("PC","CR_TIPO")+AvKey(cNumPC,"CR_NUM")))
			MaAlcDoc({cNumPC,"PC",nVlrSC7,,,cGrupo,,nMoedaSC7,nTXSC7,dDtSC7},dDataBase,3)
		Endif
		MaAlcDoc({cNumPC,"PC",nVlrSC7,,,cGrupo,,nMoedaSC7,nTXSC7,dDtSC7},dDataBase,1)
		
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))//FILIAL+TIPO+PEDIDO
		SCR->(DbGoTop())
		If SCR->(DbSeek(xFilial("SCR")+AvKey("PC","CR_TIPO")+AvKey(cNumPC,"CR_NUM")))
			Do While SCR->(!Eof()) .And. Alltrim(SCR->CR_NUM)==Alltrim(cNumPC)
				RecLock("SCR",.F.)
				SCR->CR_PROJETO:=cProjeto
				SCR->CR_DESCPRO:=cDescPrj
				
				If Alltrim(SCR->CR_STATUS)=="02"
					SCR->CR_WF		:= "1"			// Status 1 - envio para aprovador // 0 - Nao enviado para aprovador pelo Pedido
				Endif
				SCR->(MsUnLock())
				SCR->(DbSkip())
			End
		Endif
	Endif
Endif


RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/ValFor
Funcao para validacao do fornecedor
@aParam
@author		Marcos Kato
@since		12/12/2011
@uso        MATA410
/*/
//-------------------------------------------------------------------
Static Function ValFor(cCodigo,cLoja)
Local aArea  	:= GetArea()
Local lRet      :=.T.
If Empty(cCodigo) .Or. Empty(cLoja)
	Alert("Informe Fornecedor")
	lRet      :=.F.
Else
	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	If !SA2->(DbSeek(xFilial("SA2")+AvKey(cCodigo,"A2_COD")+AvKey(cLoja,"A2_LOJA")))
		Alert("Fornecedor nao cadastrado.Informe um novo codigo")
		lRet      :=.F.
		//Else
		//If !lAltFor .And. Substr(SA2->A2_CGC,1,8)<>Substr(cCNPJOld,1,8)
		//		Alert("A alteracao do codigo do Fornecedor no pedido poderá ser apenas entre a matriz e as filiais")
		//		lRet      :=.F.
	ElseIf SA2->A2_MSBLQL=="1"
		Alert("Fornecedor bloqueado.Informe um novo codigo")
		lRet      :=.F.
	Else
		cCNPJNew:=SA2->A2_CGC
	Endif
Endif
RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/ValGrupo
Funcao para validacao do grupo do fornecedor
@aParam
@author	David Ferreira
@since		12/12/2011
@uso      MATA410
/*/
//-------------------------------------------------------------------
/*
Static Function ValGrupo()

Local cQry1 := ""
Local cQry2 := ""
Local cGAnt := ""
Local cGNew := ""


cQry1 := " SELECT A2_X_GRUPO FROM SA2010 WHERE A2_COD = '"+SC7->C7_FORNECE+"' AND D_E_L_E_T_ = '' "

TCQUERY cQry1 NEW ALIAS "GRP1"


dbSelectArea("GRP1")

WHILE GRP1->(!EOF())
	
	cGAnt := GRP1->A2_X_GRUPO
	
	GRP1->(dbskip())
ENDDO

GRP1->(dbCloseArea())

cQry2 := " SELECT A2_X_GRUPO FROM SA2010 WHERE A2_COD = '"+cCodFor+"' AND D_E_L_E_T_ = '' "

TCQUERY cQry2 NEW ALIAS "GRP2"

dbSelectArea("GRP2")

WHILE GRP2->(!EOF())
	
	cGNew := GRP2->A2_X_GRUPO
	
	GRP2->(dbskip())
ENDDO

GRP2->(dbCloseArea())                                       

IF cGAnt == cGNew
	lReprApr := .F.
Else
	lReprApr := .T.
ENDIF


Return(lReprApr)
*/

