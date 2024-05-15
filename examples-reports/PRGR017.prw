// #########################################################################################
// Projeto:Relatorio de produção Diaria
// Modulo :Sigafin
// Fonte  : PRGR017
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/03/16 | David Ferreira Quadras   | Relatório para acompanhamento de produção Diaria.
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"
#include "PROTHEUS.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

//Tipos de dados.
#DEFINE TEXTO 		 1
#DEFINE NUMERO 	 	 2
#DEFINE MOEDA 	 	 3
#DEFINE DATAHORA 	 4

//Alinhamento.
#DEFINE ESQUERDA 	 1
#DEFINE CENTRO	 	 2
#DEFINE DIREITA	 	 3
#DEFINE DESLOCAMENTO 4
//------------------------------------------------------------------------------------------
user function PRGR017a()

	Local cCadastro :=  ""
	Local cDescricao:=  ""
	Local bProcesso :=  {}
	cCadastro 		:=  "Relatorio de Producao Diaria"
	cDescricao		:=  "Permite Extrair informações de Dados de projeto."
	bProcesso 		:=   {|oSelf| u_PRGR017b(oSelf) }

	tNewProcess():New( "PRGR017b" , cCadastro , bProcesso , cDescricao , "PRGR017",,,,,.T.,.T.  )

Return(Nil)

user function PRGR017b(oSelf)



	//--< variáveis >---------------------------------------------------------------------------
	Local wnrel   	:= "Relatorio_Producao" // Coloque aqui o nome do arquivo usado para impressao em disco
	Local cFile   	:= "PRGR017_"+ strTran(alltochar(dDatabase), "/", "") +"_"+StrTran(Time(),":","")+".xml"
	Local cPath   	:= SuperGetMV("FS_CAMPLAN",.F.,"C:\MICROSIGA\EXCEL\")//Caminho onde vai ser gerado a planilha
	Local cStartPath:= GetSrvProfString("Startpath","")
	Local DataAtu   := DTOS(DDATABASE)
	//Local cTabID  	:= "Relatorio de Producao - TV1  " + substr(DataAtu,7,2)+"/"+substr(DataAtu,5,2)+"/"+substr(DataAtu,1,4) + "."
	Local cTabID  	:= "Relatorio de Producao - TV1  "+ strTran(alltochar(dDatabase), "/", "") +"_"+StrTran(Time(),":","")+ "."
	Local cTab 	  	:= "Producao"
	Local oExcel  	:= Nil
	Local aDadosc 	:= {}
	Local aDadosi 	:= {}
	Local aDadosa 	:= {}
	Local aDadosp   := {}
	Local cQuery 	:= ""
	Local cDRefini 	:= "01"
	Local dDini 	:= FirstDate(CTOD(cDRefini+"/"+MV_PAR01+"/"+MV_PAR02))
	Local dDfim 	:= CTOD(cValtochar(Last_Day(CTOD("01/"+MV_PAR01+"/"+MV_PAR02)))+"/"+MV_PAR01+"/"+MV_PAR02)
	Local nTotday 	:= DateDiffDay(dDini,dDfim)+1
	Local _nDiasMes := nTotday
	Local dAtu 		:= ""
	Local nPedc 	:= 0
	Local nAcped 	:= 0
	Local nSldpc 	:= 0
	Local nTotpc 	:= 0
	Local nNfe 		:= 0
	Local nSldnfe 	:= 0
	Local nTotnfe 	:= 0
	Local nAcnfe 	:= 0
	Local nNfs 		:= 0
	Local nSldnfs 	:= 0
	Local nTotnfs 	:= 0
	Local nAcnfs 	:= 0
	Local cRevant 	:= ""
	Local cRevpos 	:= ""
	Local cRevatu 	:= ""
	Local nVendia 	:= 0
	Local nVen 		:= 0
	Local nSldven 	:= 0
	Local nTotven 	:= 0
	Local nAcven 	:= 0
	Local nAcvdia 	:= 0
	Local nMeta 	:= 0
	Local nSldmet 	:= 0
	Local nTotmet	:= 0
	Local nAcmet 	:= 0
	Local nVlsp 	:= 0
	Local cCust 	:= ""
	Local dAtu
	Local cRevdia := ""
	Local i
	Local j

	/*
	MV_PAR01 := '12'
	MV_PAR02 := '2016'
	MV_PAR03 := '05'
	MV_PAR04 := '05'

	dDini 	:= FirstDate(CTOD(cDRefini+"/"+MV_PAR01+"/"+MV_PAR02))
	dDfim 	:= CTOD(cValtochar(Last_Day(CTOD("01/"+MV_PAR01+"/"+MV_PAR02)))+"/"+MV_PAR01+"/"+MV_PAR02)
	nTotday 	:= DateDiffDay(dDini,dDfim)+1
	_nDiasMes := nTotday
	*/

	//Cria Diretorio para Salvar o Arquivo caso não exista
	If !ExistDir(cPath)
		If Makedir(cPath)<>0
			Makedir("C:\MICROSIGA")
			If !ExistDir(cPath)
				Makedir(cPath)
			EndIf
		EndIf
	EndIf

	//Projetos que geraram Venda no Periodo
	cQuery := "SELECT AFE_PROJET FROM "+Retsqlname('AFE')+" AFE WHERE AFE.D_E_L_E_T_ = '' AND AFE.AFE_DATAI BETWEEN "+Dtos(dDini)+" AND "+Dtos(dDfim)+" AND "
	cQuery += " AFE.AFE_FILIAL >= '"+MV_PAR03+"' AND AFE.AFE_FILIAL <= '"+MV_PAR04+"' "
	//cQuery += " AND AFE.AFE_PROJET = '05E0000480' "
	cQuery += " GROUP BY AFE_PROJET "

	TCQUERY cQuery NEW ALIAS 'TAFE'

	dbSelectArea('TAFE')

	WHILE TAFE->(!Eof())

		IF ASCAN(aDadosp,{|aP| ALLTRIM(aP) == ALLTRIM(TAFE->AFE_PROJET) }) == 0
			aAdd(aDadosp,TAFE->AFE_PROJET)
		ENDIF

		TAFE->(DBSKIP())
	ENDDO

	TAFE->(DBCLOSEAREA())

	//Projetos que tiveram pedidos de Compra Aprovados no periodo
	cQuery :=  " SELECT C7_CODPSP FROM "+Retsqlname('SC7')+" SC7 "
	cQuery +=  " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SC7.C7_CC AND CTT.D_E_L_E_T_ = '' AND CTT.CTT_XTPCC = '1' "
	cQuery +=  " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_X_DTLIB BETWEEN "+Dtos(dDini)+" AND "+Dtos(dDfim)+" AND"
	cQuery +=  " UPPER(C7_X_CMCNT) <> 'CLIENTE' AND SC7.C7_CONAPRO = 'L' AND C7_CODPSP <> '' AND "
	cQuery += " SC7.C7_FILIAL >= '"+MV_PAR03+"' AND SC7.C7_FILIAL <= '"+MV_PAR04+"'"
	//cQuery += " AND SC7.C7_CODPSP = '05E0000480' "
	cQuery += " GROUP BY C7_CODPSP "

	TCQUERY cQuery NEW ALIAS 'TSC7'

	dbSelectArea('TSC7')

	WHILE TSC7->(!Eof())

		IF ASCAN(aDadosp,{|aP| ALLTRIM(aP) == ALLTRIM(TSC7->C7_CODPSP) }) == 0
			aAdd(aDadosp,TSC7->C7_CODPSP)
		ENDIF

		TSC7->(DBSKIP())
	ENDDO

	TSC7->(DBCLOSEAREA())

	//Projetos que tiveram Notas Fiscais de Entrada no periodo
	cQuery :=  " SELECT D1_CODPSP FROM "+Retsqlname('SD1')+" SD1 "
	cQuery +=  " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SD1.D1_CC AND CTT.D_E_L_E_T_ = '' AND CTT.CTT_XTPCC = '1' "
	cQuery +=  " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_DTDIGIT BETWEEN "+Dtos(dDini)+" AND "+Dtos(dDfim)+" AND "
	cQuery +=  " D1_TES <> '109' AND D1_CODPSP <> ''  AND "
	cQuery += "  SD1.D1_FILIAL >= '"+MV_PAR03+"' AND SD1.D1_FILIAL <= '"+MV_PAR04+"' "
	//cQuery += " AND SD1.D1_CODPSP = '05E0000480' "
	cQuery += " GROUP BY D1_CODPSP "

	TCQUERY cQuery NEW ALIAS 'TSD1'

	dbSelectArea('TSD1')

	WHILE TSD1->(!Eof())

		IF ASCAN(aDadosp,{|aP| ALLTRIM(aP) == ALLTRIM(TSD1->D1_CODPSP) }) == 0
			aAdd(aDadosp,TSD1->D1_CODPSP)
		ENDIF

		TSD1->(DBSKIP())
	ENDDO

	TSD1->(DBCLOSEAREA())

	//Projetos que tiveram Notas Fiscais de Saida no periodo
	cQuery := " SELECT D2_EDTPMS FROM "+Retsqlname('SD2')+" SD2 WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_EMISSAO BETWEEN "+Dtos(dDini)+" AND "+Dtos(dDfim)+" AND D2_EDTPMS <> '' "
	cQuery += " AND SD2.D2_FILIAL >= '"+MV_PAR03+"' AND SD2.D2_FILIAL <= '"+MV_PAR04+"' "
	//cQuery += " AND SD2.D2_EDTPMS = '05E0000480' "
	cQuery += " GROUP BY D2_EDTPMS "

	TCQUERY cQuery NEW ALIAS 'TSD2'

	dbSelectArea('TSD2')

	WHILE TSD2->(!Eof())

		IF ASCAN(aDadosp,{|aP| ALLTRIM(aP) == ALLTRIM(TSD2->D2_EDTPMS) }) == 0
			aAdd(aDadosp,TSD2->D2_EDTPMS)
		ENDIF

		TSD2->(DBSKIP())
	ENDDO

	TSD2->(DBCLOSEAREA())

	ASORT(aDadosp)

	If LEN(aDadosp) > 0

		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTab)

		//Tabela
		oExcel:AddTable (cTab,cTabID)

		//Colunas
		oExcel:AddColumn(cTab,cTabID,"Projeto"			,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"Desc.Projeto"		,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"Tipo. Lancamento"	,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"Saldo.Anterior"	,ESQUERDA,TEXTO)

		// Array com os dias do mês/período selecionado.
		For I := 1 to nTotday
			aAdd(aDadosa,{MV_PAR02+MV_PAR01+STRZERO(I,2)})
		Next I

		// Imprime array para Excel.

		For I:= 1 To Len(aDadosa)
			oExcel:AddColumn(cTab,cTabID,aDadosa[I][1],ESQUERDA,TEXTO)
		Next I
		oExcel:AddColumn(cTab,cTabID,"Saldo.Atual"	  ,ESQUERDA,TEXTO)


	EndIf



	FOR Y := 1 TO LEN(aDadosp)

		cQuery := " SELECT "
		cQuery += " AF8.AF8_PROJET PROJETO, "
		cQuery += " AF8.AF8_REVISA REVATU, "
		cQuery += " AF8.AF8_DESCRI DESC_PROJ "
		cQuery += " FROM "+Retsqlname('AF8')+" AF8 "
		cQuery += " WHERE AF8.D_E_L_E_T_ = '' AND "
		cQuery += " AF8.AF8_PROJET = '"+Alltrim(aDadosp[Y])+"' AND "
		//cQuery += " AF8.AF8_PROJET = '05E0000480' AND"
		cQuery += " AF8.AF8_FILIAL >= '"+MV_PAR03+"' AND AF8.AF8_FILIAL <= '"+MV_PAR04+"' "

		TCQUERY cQuery NEW ALIAS 'PRJ'


		While PRJ->(!Eof())

			nAcped := 0
			nAcnfe := 0
			nAcnfs := 0
			nAcven := 0
			nAcvdia := 0

			//Traz o Saldo Anterior dos pedidos de compras
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) TPED FROM "+Retsqlname('SC7')+" SC7 "
			cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SC7.C7_CC "
			cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_CODPSP = '"+PRJ->PROJETO+"' AND SUBSTRING(C7_X_DTLIB,1,6) < "+MV_PAR02+MV_PAR01+""
			cQuery += " AND CTT.CTT_XTPCC = '1' AND UPPER(C7_X_CMCNT) <> 'CLIENTE' AND C7_CONAPRO = 'L' "

			TCQUERY cQuery NEW ALIAS 'TSC7A'

			dbSelectArea('TSC7A')

			IF TSC7A->(!eof())

				nSldpc := TSC7A->TPED
				nAcped := nSldpc

			EndIf
			TSC7A->(dbCloseArea())

			//Traz o Saldo Total dos pedidos de Compra Até a Data base selecionada
			cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) TPED FROM "+Retsqlname('SC7')+" SC7 "
			cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SC7.C7_CC "
			cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_CODPSP = '"+PRJ->PROJETO+"' AND SUBSTRING(C7_X_DTLIB,1,6) <= "+MV_PAR02+MV_PAR01+""
			cQuery += " AND CTT.CTT_XTPCC = '1'  AND UPPER(C7_X_CMCNT) <> 'CLIENTE' AND C7_CONAPRO = 'L' "

			TCQUERY cQuery NEW ALIAS 'TSC7B'

			dbSelectArea('TSC7B')

			IF TSC7B->(!eof())

				nTotpc := TSC7B->TPED

			EndIf
			TSC7B->(dbCloseArea())

			//Traz o Saldo Anterior das Notas de Entrada
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) TNFE FROM "+Retsqlname('SD1')+" SD1 "
			cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SD1.D1_CC "
			cQuery += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_CODPSP = '"+PRJ->PROJETO+"' AND SUBSTRING(D1_DTDIGIT,1,6) < "+MV_PAR02+MV_PAR01+""
			cQuery += " AND CTT.CTT_XTPCC = '1' AND D1_TES <> '109' "

			TCQUERY cQuery NEW ALIAS 'TSD1A'

			dbSelectArea('TSD1A')

			IF TSD1A->(!eof())

				nSldnfe := TSD1A->TNFE
				nAcnfe := nSldnfe

			EndIf
			TSD1A->(dbCloseArea())

			//Traz o Saldo Total das Notas de Entrada Até a Data base selecionada
			cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) TNFE FROM "+Retsqlname('SD1')+" SD1 "
			cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SD1.D1_CC "
			cQuery += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_CODPSP = '"+PRJ->PROJETO+"' AND SUBSTRING(D1_DTDIGIT,1,6) <= "+MV_PAR02+MV_PAR01+""
			cQuery += " AND CTT.CTT_XTPCC = '1' AND D1_TES <> '109' "

			TCQUERY cQuery NEW ALIAS 'TSD1B'

			dbSelectArea('TSD1B')

			IF TSD1B->(!eof())

				nTotnfe := TSD1B->TNFE

			EndIf
			TSD1B->(dbCloseArea())

			//Traz o Saldo Anterior das Notas de Saida
			cQuery := " SELECT ISNULL(SUM(D2_TOTAL),0) TNFS FROM "+Retsqlname('SD2')+" SD2 "
			cQuery += " WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_EDTPMS = '"+PRJ->PROJETO+"' AND SUBSTRING(D2_EMISSAO,1,6) < "+MV_PAR02+MV_PAR01+""

			TCQUERY cQuery NEW ALIAS 'TSD2A'

			dbSelectArea('TSD2A')

			IF TSD2A->(!eof())

				nSldnfs := TSD2A->TNFS
				nAcnfs := nSldnfs

			EndIf
			TSD2A->(dbCloseArea())

			//Traz o Saldo Total das Notas de Saida Até a Data base selecionada
			cQuery := " SELECT ISNULL(SUM(D2_TOTAL),0) TNFS FROM "+Retsqlname('SD2')+" SD2 "
			cQuery += " WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_EDTPMS = '"+PRJ->PROJETO+"' AND SUBSTRING(D2_EMISSAO,1,6) <= "+MV_PAR02+MV_PAR01+""

			TCQUERY cQuery NEW ALIAS 'TSD2B'

			dbSelectArea('TSD2B')

			IF TSD2B->(!eof())

				nTotnfs := TSD2B->TNFS

			EndIf
			TSD2B->(dbCloseArea())

			//Traz a ultima revisão do projeto para ser utilizada para trazer o Valor de venda
			cQuery := " SELECT MAX(AFE_REVISA) REVISAO FROM "+Retsqlname('AFE')+" AFE "
			cQuery += " WHERE AFE.D_E_L_E_T_ = '' AND AFE.AFE_PROJET = '"+PRJ->PROJETO+"' AND SUBSTRING(AFE_DATAI,1,6) < "+MV_PAR02+MV_PAR01+""

			TCQUERY cQuery NEW ALIAS 'TAFEA'

			dbSelectArea('TAFEA')

			IF TAFEA->(!eof())

				cRevant := TAFEA->REVISAO

			EndIf
			TAFEA->(dbCloseArea())

			//Traz a ultima revisão do projeto para ser utilizada para trazer o Valor de venda
			cQuery := " SELECT MAX(AFE_REVISA) REVISAO FROM "+Retsqlname('AFE')+" AFE "
			cQuery += " WHERE AFE.D_E_L_E_T_ = '' AND AFE.AFE_PROJET = '"+PRJ->PROJETO+"' AND SUBSTRING(AFE_DATAI,1,6) = '"+MV_PAR02+MV_PAR01+"'"

			TCQUERY cQuery NEW ALIAS 'TAFEP'

			dbSelectArea('TAFEP')

			IF TAFEP->(!eof())

				cRevpos := TAFEP->REVISAO

			EndIf
			TAFEP->(dbCloseArea())


			IF !EMPTY(cRevant)

				//Traz a ultima revisão do projeto para ser utilizada para trazer o Saldo Anterior do Valor de venda
				cQuery := " SELECT ISNULL(AFC_TVPVBV,0) VLVEND FROM "+Retsqlname('AFC')+" AFC "
				cQuery += " WHERE AFC.D_E_L_E_T_ = '' AND AFC.AFC_PROJET = '"+PRJ->PROJETO+"' AND AFC.AFC_REVISA = "+cRevant+" AND AFC.AFC_EDT = '"+PRJ->PROJETO+"' "

				TCQUERY cQuery NEW ALIAS 'TAFCA'

				dbSelectArea('TAFCA')

				IF TAFCA->(!eof())

					nSldven := TAFCA->VLVEND
					nAcven := nSldven
					nAcvdia := nSldven
				EndIf
				TAFCA->(dbCloseArea())

				//Traz o Valor de SP da ultima revisao para trazer o saldo de Valor de Venda
				cQuery := " SELECT ISNULL(SUM(AF9_TVPVBV),0) VLSP FROM "+Retsqlname('AF9')+" AF9 "
				cQuery += " WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_REVISA = "+cRevant+" AND AF9.AF9_X_RERI = 'SP'  "

				TCQUERY cQuery NEW ALIAS 'TAFCA'

				dbSelectArea('TAFCA')

				IF TAFCA->(!eof())

					nSldven := nSldven - TAFCA->VLSP
					nAcven := nSldven
					nAcvdia := nSldven
				EndIf
				TAFCA->(dbCloseArea())



			ELSE
				nSldven := 0
			ENDIF

			//Traz a ultima revisão do mes que esta sendo avaliada do projeto para ser utilizada para trazer o Valor de venda
			cQuery := " SELECT MAX(AFE_REVISA) REVISAO FROM "+Retsqlname('AFE')+" AFE "
			cQuery += " WHERE AFE.D_E_L_E_T_ = '' AND AFE.AFE_PROJET = '"+PRJ->PROJETO+"' AND SUBSTRING(AFE_DATAI,1,6) = "+MV_PAR02+MV_PAR01+""

			TCQUERY cQuery NEW ALIAS 'TAFEA'

			dbSelectArea('TAFEA')

			IF TAFEA->(!eof())

				cRevatu := TAFEA->REVISAO

			EndIf
			TAFEA->(dbCloseArea())

			If !EMPTY(cRevatu)
				//Traz a ultima revisão do projeto para ser utilizada para trazer o Saldo do Valor de venda
				cQuery := " SELECT ISNULL(AFC_TVPVBV,0) VLVEND FROM "+Retsqlname('AFC')+" AFC "
				cQuery += " WHERE AFC.D_E_L_E_T_ = '' AND AFC.AFC_PROJET = '"+PRJ->PROJETO+"' AND AFC.AFC_REVISA = "+cRevatu+" AND AFC.AFC_EDT = '"+PRJ->PROJETO+"' "

				TCQUERY cQuery NEW ALIAS 'TAFCA'

				dbSelectArea('TAFCA')

				IF TAFCA->(!eof())

					nTotven := TAFCA->VLVEND

				EndIf
				TAFCA->(dbCloseArea())
			Else
				nTotven := 0
			EndIf

			If !EMPTY(cRevatu)
				//Traz a ultima revisão do projeto para ser utilizada para trazer o Saldo do Valor de SP
				cQuery := " SELECT ISNULL(SUM(AF9_TVPVBV),0) VLSP FROM "+Retsqlname('AF9')+" AF9 "
				cQuery += " WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_REVISA = "+cRevatu+" AND AF9.AF9_X_RERI = 'SP' "

				TCQUERY cQuery NEW ALIAS 'AF9T'

				dbSelectArea('AF9T')

				IF AF9T->(!eof())

					nVlsp := AF9T->VLSP
					nTotven := nTotven - nVlsp

				EndIf
				AF9T->(dbCloseArea())
			Else
				nTotven := nSldven
			EndIf

			nTotday := nTotday + DESLOCAMENTO
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			For I := 1 to _nDiasMes

				dAtu = STRZERO(I,2)
				nTotmet := 0

				//Traz o valor de meta
				//cQuery := " SELECT ISNULL(SUM(AFA.AFA_METTOT),0) META FROM "+Retsqlname('AFA')+" AFA "
				//cQuery += " WHERE AFA.D_E_L_E_T_ = '' AND AFA.AFA_PROJET = '"+PRJ->PROJETO+"' AND AFA.AFA_REVISA = "+PRJ->REVATU+" "
				cQuery := " SELECT "
				cQuery += " AF9.AF9_X_RERI IDENT, "
				cQuery += " SUM(AF9_TVPVBV) VENDA, "
				cQuery += " SUM(AF9_TVBRBV) REEMBOLSO, "
				cQuery += " ISNULL(SUM(AF9.AF9_X_META),0) META "
				cQuery += " FROM "+Retsqlname('AF9')+" AF9  "
				cQuery += " WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_REVISA = '"+cRevpos+"' "
				cQuery += " GROUP BY "
				cQuery += " AF9.AF9_X_RERI "


				TCQUERY cQuery NEW ALIAS 'TAFA'

				dbSelectArea('TAFA')


				WHILE TAFA->(!eof())

					IF ALLTRIM(TAFA->IDENT) == 'PR'
						nTotmet += TAFA->META
					ELSEIF ALLTRIM(TAFA->IDENT) == '' .AND. TAFA->VENDA > 0
						nTotmet += TAFA->META
					ElSE
						nTotmet += 0
					ENDIF

					TAFA->(DBSKIP())
				ENDDO

				TAFA->(dbCloseArea())

				IF nTotmet == 0
					cQuery := " SELECT "
					cQuery += " AF9.AF9_X_RERI IDENT, "
					cQuery += " SUM(AF9_TVPVBV) VENDA, "
					cQuery += " ISNULL(SUM(AF9.AF9_X_META),0) META "
					cQuery += " FROM "+Retsqlname('AF9')+" AF9  "
					cQuery += " WHERE AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_REVISA = '"+cRevant+"' "
					cQuery += " GROUP BY "
					cQuery += " AF9.AF9_X_RERI "

					TCQUERY cQuery NEW ALIAS 'TAFA'

					dbSelectArea('TAFA')

					WHILE TAFA->(!eof())

						IF ALLTRIM(TAFA->IDENT) == 'PR'
							nTotmet += TAFA->META
						ELSEIF ALLTRIM(TAFA->IDENT) == '' .AND. TAFA->VENDA > 0
							nTotmet += TAFA->META
						ElSE
							nTotmet += 0
						ENDIF
						TAFA->(DBSKIP())
					ENDDO

					TAFA->(dbCloseArea())

				ENDIF




				//aAdd(aDadosi,{PRJ->PROJETO,nTotmet,MV_PAR02+MV_PAR01+dAtu,"Custo.Meta",nTotmet,nTotmet,PRJ->DESC_PROJ})

				aLinhas[1]:= PRJ->PROJETO
				aLinhas[2]:= PRJ->DESC_PROJ
				aLinhas[3]:= "Custo.Meta"
				aLinhas[4]:= nTotmet

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] := nTotMet
				//aLinhas[nTotday+1]:= nTotMet
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotMet

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			//Popular os Lançamentos Diarios
			//For I := 1 to nTotday
			For I := 1 To _nDiasMes

				dAtu = STRZERO(I,2)

				//Pedido de compra
				cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) TPED FROM "+Retsqlname('SC7')+" SC7 "
				cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SC7.C7_CC "
				cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_CODPSP = '"+PRJ->PROJETO+"' AND C7_X_DTLIB = "+MV_PAR02+MV_PAR01+dAtu+""
				cQuery += " AND CTT.CTT_XTPCC = '1' AND UPPER(C7_X_CMCNT) <> 'CLIENTE' AND C7_CONAPRO = 'L' "

				TCQUERY cQuery NEW ALIAS 'TSC7'

				dbSelectArea('TSC7')

				If TSC7->(!eof())

					nPedc := TSC7->TPED

					AADD(aDadosi,{PRJ->PROJETO,nPedc,MV_PAR02+MV_PAR01+dAtu,"Pedidos.Compra",nSldpc,nTotpc,PRJ->DESC_PROJ})

				Else
					nPedc := 0

					AADD(aDadosi,{PRJ->PROJETO,nPedc , MV_PAR02+MV_PAR01+dAtu,"Pedidos.Compra",nSldpc,nTotpc,PRJ->DESC_PROJ})

				EndIf
				TSC7->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Pedidos.Compra"	//4
				aLinhas[4]:= nSldpc				//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nPedc	//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotpc	//6
			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			//Popular os Lançamentos  Acumulados Pedido de Compra
			//For I := 1 to nTotday
			For I :=  1 to _nDiasMes

				dAtu = STRZERO(I,2)

				//Pedido de compra
				cQuery := " SELECT ISNULL(SUM(C7_TOTAL),0) TPED FROM "+Retsqlname('SC7')+" SC7 "
				cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SC7.C7_CC "
				cQuery += " WHERE SC7.D_E_L_E_T_ = '' AND SC7.C7_CODPSP = '"+PRJ->PROJETO+"' AND C7_X_DTLIB = "+MV_PAR02+MV_PAR01+dAtu+""
				cQuery += " AND CTT.CTT_XTPCC = '1' AND UPPER(C7_X_CMCNT) <> 'CLIENTE' AND C7_CONAPRO = 'L' "

				TCQUERY cQuery NEW ALIAS 'TSC7'

				dbSelectArea('TSC7')

				IF TSC7->(!eof())

					nPedc := TSC7->TPED
					nAcped += nPedc

					AADD(aDadosi,{PRJ->PROJETO,nAcped,MV_PAR02+MV_PAR01+dAtu,"Acum Ped.Compra",nSldpc,nTotpc,PRJ->DESC_PROJ})

				Else
					nPedc := 0
					nAcped += nPedc

					AADD(aDadosi,{PRJ->PROJETO,nAcped  ,MV_PAR02+MV_PAR01+dAtu,"Acum Ped.Compra",nSldpc,nTotpc,PRJ->DESC_PROJ})

				EndIf
				TSC7->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Acum Ped.Compra"	//4
				aLinhas[4]:= nSldpc				//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nAcped	//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotpc	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			//For I := 1 to nTotday
			//Nota Fiscal Entrada Diario
			For I := 1 To _nDiasMes

				dAtu = STRZERO(I,2)

				//Nota Fiscal de Entrada
				cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) TNFE FROM "+Retsqlname('SD1')+" SD1 "
				cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SD1.D1_CC "
				cQuery += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_CODPSP = '"+PRJ->PROJETO+"' AND D1_DTDIGIT = "+MV_PAR02+MV_PAR01+dAtu+""
				cQuery += " AND CTT.CTT_XTPCC = '1' AND D1_TES <> '109' "

				TCQUERY cQuery NEW ALIAS 'TSD1'

				dbSelectArea('TSD1')

				IF TSD1->(!eof())

					nNfe := TSD1->TNFE

					AADD(aDadosi,{PRJ->PROJETO,nNfe,MV_PAR02+MV_PAR01+dAtu,"Custo.Variavel",nSldnfe,nTotnfe,PRJ->DESC_PROJ})

				Else
					nNfe := 0
					AADD(aDadosi,{PRJ->PROJETO,0, MV_PAR02+MV_PAR01+dAtu,"Custo.Variavel",nSldnfe,nTotnfe,PRJ->DESC_PROJ})

				EndIf
				TSD1->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Custo.Variavel"	//4
				aLinhas[4]:= nSldnfe			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nNfe		//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotnfe	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			//Nota Fiscal Entrada Acumulado
			//For I := 1 to nTotday
			For I := 1 to _nDiasMes

				dAtu = STRZERO(I,2)

				//Nota Fiscal de Entrada
				cQuery := " SELECT ISNULL(SUM(D1_TOTAL),0) TNFE FROM "+Retsqlname('SD1')+" SD1 "
				cQuery += " JOIN "+Retsqlname('CTT')+" CTT ON CTT.CTT_CUSTO = SD1.D1_CC "
				cQuery += " WHERE SD1.D_E_L_E_T_ = '' AND SD1.D1_CODPSP = '"+PRJ->PROJETO+"' AND D1_DTDIGIT = "+MV_PAR02+MV_PAR01+dAtu+""
				cQuery += " AND CTT.CTT_XTPCC = '1' AND D1_TES <> '109' "

				TCQUERY cQuery NEW ALIAS 'TSD1'

				dbSelectArea('TSD1')

				IF TSD1->(!eof())

					nNfe 	:= TSD1->TNFE
					nAcnfe 	+= nNfe

					AADD(aDadosi,{PRJ->PROJETO,nAcnfe,MV_PAR02+MV_PAR01+dAtu,"Acum.Custo.Variavel",nSldnfe,nTotnfe,PRJ->DESC_PROJ})

				Else
					nNfe := 0
					nAcnfe 	+= nNfe

					AADD(aDadosi,{PRJ->PROJETO,nAcnfe , MV_PAR02+MV_PAR01+dAtu,"Acum.Custo.Variavel",nSldnfe,nTotnfe,PRJ->DESC_PROJ})
				EndIf
				TSD1->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Acum.Custo.Variavel" //4
				aLinhas[4]:= nSldnfe			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nAcnfe		//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotnfe	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			//Nota Fiscal de Saída Diário
			//For I := 1 to nTotday
			For I := 1 to _nDiasMes

				dAtu = STRZERO(I,2)

				//Nota Fiscal de Saída
				cQuery := " SELECT ISNULL(SUM(D2_TOTAL),0) TNFS FROM "+Retsqlname('SD2')+" SD2 "
				cQuery += " WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_EDTPMS = '"+PRJ->PROJETO+"' AND D2_EMISSAO = "+MV_PAR02+MV_PAR01+dAtu+""

				TCQUERY cQuery NEW ALIAS 'TSD2'

				dbSelectArea('TSD2')

				IF TSD2->(!eof())

					nNfs := TSD2->TNFS

					AADD(aDadosi,{PRJ->PROJETO,nNfs,MV_PAR02+MV_PAR01+dAtu,"Faturado",nSldnfs,nTotnfs,PRJ->DESC_PROJ})

				Else
					nNfs := 0
					AADD(aDadosi,{PRJ->PROJETO,0, MV_PAR02+MV_PAR01+dAtu,"Faturado",nSldnfs,nTotnfs,PRJ->DESC_PROJ})

				EndIf
				TSD2->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Faturado" 		//4
				aLinhas[4]:= nSldnfs			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nNfs		//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotnfs	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			For I := 1 to _nDiasMes
				//Nota Fiscal de Saída Acumulado
				//For I := 1 to nTotday

				dAtu = STRZERO(I,2)

				//Nota Fiscal de Saída
				cQuery := " SELECT ISNULL(SUM(D2_TOTAL),0) TNFS FROM "+Retsqlname('SD2')+" SD2 "
				cQuery += " WHERE SD2.D_E_L_E_T_ = '' AND SD2.D2_EDTPMS = '"+PRJ->PROJETO+"' AND D2_EMISSAO = "+MV_PAR02+MV_PAR01+dAtu+""

				TCQUERY cQuery NEW ALIAS 'TSD2'

				dbSelectArea('TSD2')

				IF TSD2->(!eof())

					nNfs := TSD2->TNFS
					nAcnfs += nNfs

					AADD(aDadosi,{PRJ->PROJETO,nAcnfs,MV_PAR02+MV_PAR01+dAtu,"Acum.Faturado",nSldnfs,nTotnfs,PRJ->DESC_PROJ})
				Else
					nNfs := 0
					nAcnfs += nNfs

					AADD(aDadosi,{PRJ->PROJETO,nAcnfs, MV_PAR02+MV_PAR01+dAtu,"Acum.Faturado",nSldnfs,nTotnfs,PRJ->DESC_PROJ})

				EndIf
				TSD2->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Acum.Faturado"	//4
				aLinhas[4]:= nSldnfs			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nAcnfs		//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotnfs	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			For I := 1 to _nDiasMes
				//Venda Diario
				//For I := 1 to nTotday

				dAtu = STRZERO(I,2)

				//Ultima revisão do dia
				cQuery := " SELECT MAX(AFE.AFE_REVISA) REVISA FROM "+Retsqlname('AFE')+" AFE "
				cQuery += " WHERE  AFE.AFE_PROJET = '"+PRJ->PROJETO+"' AND D_E_L_E_T_ = '' AND AFE.AFE_DATAI = "+MV_PAR02+MV_PAR01+dAtu+" "

				TCQUERY cQuery NEW ALIAS 'TAFE'

				dbSelectArea('TAFE')

				IF TAFE->(!eof())
					cRevdia := TAFE->REVISA
				EndIf
				TAFE->(dbCloseArea())


				//Valor de SP
				cQuery := " SELECT ISNULL(SUM(AF9_TVPVBV),0) TVSP FROM "+Retsqlname('AF9')+" AF9 "
				//cQuery += " JOIN "+Retsqlname('AFE')+" AFE ON AF9.AF9_PROJET = AFE.AFE_PROJET AND AF9.AF9_REVISA = AFE.AFE_REVISA "
				cQuery += " WHERE AF9.AF9_REVISA = '"+cRevdia+"' AND AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_X_RERI = 'SP'  "

				TCQUERY cQuery NEW ALIAS 'TAF9'

				dbSelectArea('TAF9')

				IF TAF9->(!eof())
					nVlsp := TAF9->TVSP
				EndIf
				TAF9->(dbCloseArea())

				//Valor de Venda
				cQuery := " SELECT ISNULL(AFC_TVPVBV,0) TVEN FROM "+Retsqlname('AFC')+" AFC "
				//cQuery += " JOIN "+Retsqlname('AFE')+" AFE ON AFC.AFC_PROJET = AFE.AFE_PROJET AND AFC.AFC_REVISA = AFE.AFE_REVISA "
				cQuery += " WHERE AFC.AFC_REVISA = '"+cRevdia+"' AND AFC.D_E_L_E_T_ = '' AND AFC.AFC_PROJET = '"+PRJ->PROJETO+"' AND AFC.AFC_EDT = '"+PRJ->PROJETO+"'  "

				TCQUERY cQuery NEW ALIAS 'TAFC'

				dbSelectArea('TAFC')

				IF TAFC->(!eof())

					nVen := 0

					nVen := TAFC->TVEN - nVlsp - nAcvdia

					nAcvdia := nAcvdia + nVen

					AADD(aDadosi,{PRJ->PROJETO,nVen,MV_PAR02+MV_PAR01+dAtu,"Vendido",nSldven,nTotven,PRJ->DESC_PROJ})

				Else
					nVen := 0
					AADD(aDadosi,{PRJ->PROJETO,0, MV_PAR02+MV_PAR01+dAtu,"Vendido",nSldven,nTotven,PRJ->DESC_PROJ})

				EndIf
				TAFC->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Vendido"			//4
				aLinhas[4]:= nSldven			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nVen		//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotven	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			For I := 1 to _nDiasMes
				//Venda Acumulado
				//For I := 1 to nTotday

				dAtu = STRZERO(I,2)

				//Ultima revisão do dia
				cQuery := " SELECT MAX(AFE.AFE_REVISA) REVISA FROM "+Retsqlname('AFE')+" AFE "
				cQuery += " WHERE  AFE.AFE_PROJET = '"+PRJ->PROJETO+"' AND D_E_L_E_T_ = '' AND AFE.AFE_DATAI = "+MV_PAR02+MV_PAR01+dAtu+" "

				TCQUERY cQuery NEW ALIAS 'TAFE'

				dbSelectArea('TAFE')

				IF TAFE->(!eof())
					cRevdia := TAFE->REVISA
				EndIf
				TAFE->(dbCloseArea())

				//Valor de SP
				cQuery := " SELECT ISNULL(SUM(AF9_TVPVBV),0) TVSP FROM "+Retsqlname('AF9')+" AF9 "
				//cQuery += " JOIN "+Retsqlname('AFE')+" AFE ON AF9.AF9_PROJET = AFE.AFE_PROJET AND AF9.AF9_REVISA = AFE.AFE_REVISA "
				cQuery += " WHERE AF9.AF9_REVISA = '"+cRevdia+"' AND AF9.D_E_L_E_T_ = '' AND AF9.AF9_PROJET = '"+PRJ->PROJETO+"' AND AF9.AF9_X_RERI = 'SP'  "

				TCQUERY cQuery NEW ALIAS 'TAF9'

				dbSelectArea('TAF9')

				IF TAF9->(!eof())

					nVlsp := TVSP

				EndIf
				TAF9->(dbCloseArea())

				IF dAtu == '01'
					nVendia := nSldven
				EndIf

				//Valor de Venda
				cQuery := " SELECT TOP 1(ISNULL(AFC_TVPVBV,0)) TVEN FROM "+Retsqlname('AFC')+" AFC "
				//cQuery += " JOIN "+Retsqlname('AFE')+" AFE ON AFC.AFC_PROJET = AFE.AFE_PROJET AND AFC.AFC_REVISA = AFE.AFE_REVISA "
				cQuery += " WHERE AFC.AFC_REVISA = '"+cRevdia+"' AND AFC.D_E_L_E_T_ = '' AND AFC.AFC_PROJET = '"+PRJ->PROJETO+"' AND AFC.AFC_EDT = '"+PRJ->PROJETO+"'  "

				TCQUERY cQuery NEW ALIAS 'TAFC'

				dbSelectArea('TAFC')

				IF TAFC->(!eof())

					nVen := TAFC->TVEN - nVlsp - nVendia

					nVendia := TAFC->TVEN - nVlsp

					nAcven += nVen
					AADD(aDadosi,{PRJ->PROJETO,nAcven,MV_PAR02+MV_PAR01+dAtu,"Acum.Vendido",nSldven,nTotven,PRJ->DESC_PROJ})

				Else
					AADD(aDadosi,{PRJ->PROJETO,nAcven, MV_PAR02+MV_PAR01+dAtu,"Acum.Vendido",nSldven,nTotven,PRJ->DESC_PROJ})
				EndIf
				TAFC->(dbCloseArea())

				aLinhas[1]:= PRJ->PROJETO	 	//1
				aLinhas[2]:= PRJ->DESC_PROJ		//7
				aLinhas[3]:= "Acum.Vendido"		//4
				aLinhas[4]:= nSldven			//5

				nColuna := val( Right(MV_PAR02+MV_PAR01+dAtu,2) )
				aLinhas[nColuna+DESLOCAMENTO] 		:= nAcven	//2
				aLinhas[_nDiasMes+ DESLOCAMENTO + 1]:= nTotven	//6

			Next I

			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(_nDiasMes+ DESLOCAMENTO + 1)

			PRJ->(dbSkip())

		Enddo

		PRJ->(dbCloseArea())

	NEXT Y

	//Ativa Excel e imprime os itens.
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)

	// Copia o arquivo do servidor para o remote
	CpyS2T( cStartPath+cFile, cPath , .T. )
	ShellExecute("Open","EXCEL.EXE",cPath+cFile,"C:\",1)
	//EndIf
Return(Nil)

//--< fim de arquivo >----------------------------------------------------------------------