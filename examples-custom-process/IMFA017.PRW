#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"               
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA017
Grava os dados da pessoa que efetuou a inclusao, alteracao ou exclusao 
da Nota de Entrada
@aParam
@Autor      David Ferreira Quadras
@since		29/03/2012
@uso        MATA120
/*/
//--------------------------------------------------------------------
User Function IMFA017(nOpc)
Local aArea  	:= GetArea()       
Local cLink     :="" 
Default nOpc    :=0 
//=======================================================
//Variaveis Private da Funcao Principal MATA103
//-------------------------------------------------------
//-cSerie
//-cNFiscal
//-cA100For
//-cLoja
//-cTipo
//=======================================================
DbSelectArea("SD1")
SD1->(DbSetOrder(1))//D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
SD1->(DbGoTop())
If SD1->(DbSeek(xFilial("SD1")+AvKey(cNFiscal,"D1_DOC")+AvKey(cSerie,"D1_SERIE")+AvKey(cA100For,"D1_FORNECE")+AvKey(cLoja,"D1_LOJA")))
	Do While SD1->(!Eof()) .And. Alltrim(cNFiscal)==Alltrim(SD1->D1_DOC) .And. Alltrim(cSerie)==Alltrim(SD1->D1_SERIE) ;
	.And. Alltrim(cA100For)==Alltrim(SD1->D1_FORNECE) .And. Alltrim(cLoja)==Alltrim(SD1->D1_LOJA)
		cLink:=""
		DbSelectArea("AF8")
		AF8->(DbSetOrder(1))
		AF8->(DbGoTop())
		If AF8->(DbSeek(xFilial("AF8")+AvKey(SD1->D1_CODPSP,"AF8_PROJET")))
			DbSelectArea("AF9")
			AF9->(DbSetOrder(1))
			AF9->(DbGoTop())
			If AF9->(DbSeek(xFilial("AF9")+AvKey(AF8->AF8_PROJET,"AF9_PROJET")+AvKey(AF8->AF8_REVISA,"AF9_REVISA")+AvKey(SD1->D1_TAREFA,"AF9_TAREFA")))
				cLink:=AF9->AF9_X_PLAN
            Endif
		Endif
		If SD1->(FieldPos("D1_X_INCLU"))>0 .And. nOpc==3//Inclusao   
			RecLock("SD1",.F.)
			SD1->D1_X_INCLU:=__cUserID
			SD1->D1_X_PLAN :=cLink
		    SD1->(MsUnlock())
		ElseIf SD1->(FieldPos("D1_X_ALTER"))>0 .And. nOpc==4//Alteracao
			RecLock("SD1",.F.)                                                               
			SD1->D1_X_ALTER:=__cUserID		
			SD1->D1_X_PLAN :=cLink			
		    SD1->(MsUnlock())
		ElseIf SD1->(FieldPos("D1_X_EXCLU"))>0 .And. nOpc==5//Exclusao
			RecLock("SD1",.F.)
			SD1->D1_X_EXCLU:=__cUserID		
		    SD1->(MsUnlock())
		Endif
		SD1->(DbSkip())
	End
Endif	
RestArea(aArea)
Return