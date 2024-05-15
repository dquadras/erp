#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMFA060   º Autor ³ David              º Data ³  01/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para fechamento do Vendas.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Controladoria                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function IMFA060


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cString := ""
	Private cQuery1 := ""
	Private cQuery2 := ""
	Private cDtatu  := ""
	Private cPrjrev := ""
	Private cZsmes  := ""
	Private cDtini  := ""
	Private cDtfec  := ""
	Private cMesfec := ""
	Private cAnofec := ""
	Private cAnoMes := ""

//cDtatu := DTOS(Date())
	cDtatu := '20160731'
	cMesfec := SUBSTR(cDtatu,5,2)
	cAnofec := SUBSTR(cDtatu,1,4)
	cAnoMes := cAnofec + cMesfec

//Definição de Data de Fechamento Inicial e Final com base na data base do Banco
	DbSelectArea("SZS")
	SZS->(DbSetOrder(1))
	SZS->(DbGoTop())

	If SZS->(DbSeek(xFilial("SZS")+AvKey("PMS","ZS_TIPO")+AvKey(cAnofec,"ZS_ANO")))
		If Alltrim(Substr(DtoS(SZS->ZS_DATA12),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA12)
			cDtini:=DtoS(SZS->ZS_DATA11)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA11),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA11)
			cDtini:=DtoS(SZS->ZS_DATA10)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA10),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA10)
			cDtini:=DtoS(SZS->ZS_DATA09)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA09),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA09)
			cDtini:=DtoS(SZS->ZS_DATA08)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA08),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA08)
			cDtini:=DtoS(SZS->ZS_DATA07)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA07),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA07)
			cDtini:=DtoS(SZS->ZS_DATA06)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA06),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA06)
			cDtini:=DtoS(SZS->ZS_DATA05)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA05),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA05)
			cDtini:=DtoS(SZS->ZS_DATA04)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA04),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA04)
			cDtini:=DtoS(SZS->ZS_DATA03)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA03),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA03)
			cDtini:=DtoS(SZS->ZS_DATA02)
		ElseIf Alltrim(Substr(DtoS(SZS->ZS_DATA02),1,6))==cAnoMes
			cDtfec:=DtoS(SZS->ZS_DATA02)
			cDtini:=DtoS(SZS->ZS_DATA01)
		ElseIF cAnoMes == '201501' .and. cDtatu <> '20150131'
			If SZS->(DbSeek(xFilial("SZS")+AvKey("PMS","ZS_TIPO")+AvKey( cValToChar( val(cAnofec)-1),"ZS_ANO") ))
				cDtfec:=DtoS(SZS->ZS_DATA12)
				cDtini:=DtoS(SZS->ZS_DATA11)
			Endif
		Else
			cDtfec:=DtoS(SZS->ZS_DATA01)
			If SZS->(DbSeek(xFilial("SZS")+AvKey("PMS","ZS_TIPO")+AvKey( cValToChar( val(cAnofec)-1),"ZS_ANO") ))
				cDtini:=DtoS(SZS->ZS_DATA12)
			Endif
		Endif
	Endif
         

	IF cDtAtu ==cDtFec
	
		cQuery1 := " SELECT AFE_PROJET PROJET,MAX(AFE_REVISA) REVISA "
		cQuery1 += " FROM "+RetSqlName("AFE")+" AFE "
		cQuery1 += " JOIN "+RetSqlName("AF8")+" ON AFE_PROJET = AF8_PROJET "
		cQuery1 += " WHERE AFE.AFE_DATAI > "+cDtini+" and AFE.AFE_DATAI <= "+cDtfec+" AND "
		cQuery1 += " AFE_DATAI >= AF8_DTVEND AND "
		cQuery1 += " AF8_DTVEND <> ''        AND "
		cQuery1 += " AFE.D_E_L_E_T_ = '' GROUP BY AFE_PROJET ORDER BY AFE_PROJET "
	
		TCQUERY cQuery1 NEW ALIAS "AFE1"
	
		dbSelectarea("AFE1")
		AFE1->(dbgotop())
	
		while AFE1->(!eof())
		
			cQuery2 := " SELECT AF8_PROJET,AF8_REVISA,AF8_DESCRI,AFC_TVPVBV,AFC_TVBRBV,AF8_DTVEND "
			cQuery2 += " FROM "+RetSqlName("AF8")+" AF8 "
			cQuery2 += " JOIN "+RetSqlName("AFC")+" AFC ON AFC_PROJET = AF8_PROJET  AND AFC_REVISA = '"+AFE1->REVISA+"' AND AFC_EDT = AFC_PROJET AND  AFC.D_E_L_E_T_ = '' "
			cQuery2 += " WHERE AF8_PROJET = '"+AFE1->PROJET+"' AND AF8.D_E_L_E_T_ = '' "
			cQuery2 += " GROUP BY AF8_PROJET,AF8_REVISA,AF8_DESCRI,AFC_TVPVBV,AFC_TVBRBV,AF8_DTVEND "
		
			TCQUERY cQuery2 NEW ALIAS "AFC1"
		
			dbSelectarea("AFC1")
			AFC1->(dbgotop())
		
			while AFC1->(!eof())
			
			
				dbSelectArea("PAL")
				dbSetOrder(1)
			
				RECLOCK("PAL",.T.)
			
				PAL->PAL_PSP 	 := AFC1->AF8_PROJET
				PAL->PAL_RETRAN  := AFC1->AF8_DESCRI
				PAL->PAL_MES     := cMesfec
				PAL->PAL_ANO     := cAnofec
				PAL->PAL_VLVEN   := AFC1->AFC_TVPVBV
				PAL->PAL_VLREEM  := AFC1->AFC_TVBRBV
				PAL->PAL_REVISA  := AFE1->REVISA
				PAL->PAL_DTVEND  := STOD(AFC1->AF8_DTVEND)
			
				PAL->(MSUNLOCK())
			
				AFC1->(dbSkip())
			enddo
		
			AFC1->(dbCloseArea())
			AFE1->(dbSkip())
		enddo
	
		AFE1->(dbCloseArea())


		PAL->(dbCloseArea())
	EndIF

	SZS->(dbCloseArea())

Return
