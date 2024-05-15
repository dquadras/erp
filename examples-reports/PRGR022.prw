// #########################################################################################
// Projeto:Relatorio de DDI
// Modulo :Sigafin
// Fonte  : PRGR022
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/03/16 | David Ferreira    | Relatório DDI1.
// ---------+-------------------+-----------------------------------------------------------


#include "rwmake.ch"
#include "PROTHEUS.ch"
#include "TOPCONN.CH"
#include "TOTVS.CH"

//Tipos de dados.
#DEFINE TEXTO 	 1
#DEFINE NUMERO 	 2
#DEFINE MOEDA 	 3
#DEFINE DATAHORA 4

//Alinhamento.
#DEFINE ESQUERDA 1
#DEFINE CENTRO	 2
#DEFINE DIREITA	 3

/*PRGR022
(long_description)
@author David Ferreira Quadras
@since 15/09/2016
@version 1.0
@example
(examples)
@see (links_or_references)
*/
USER FUNCTION PRGR022A()

	Local cCadastro :=  ""
	Local cDescricao:=  ""
	Local bProcesso :=  {}


	cCadastro :=  "Relatorio DDI"
	cDescricao:=  "Permite Extrair informações de Dados de Compras e Faturamento com DDI."
	bProcesso :=   {|oSelf| u_PRGR022b(oSelf) }

	tNewProcess():New( "PRGR022B" , cCadastro , bProcesso , cDescricao , "PRGR022",,,,,.T.,.T.  )


Return

USER FUNCTION PRGR022B()

	//--< variáveis >---------------------------------------------------------------------------
	Local wnrel   := "Relatorio_DDI" // Coloque aqui o nome do arquivo usado para impressao em disco
	Local cFile   := "PRGR022_"+ strTran(alltochar(dDatabase), "/", "") +"_"+StrTran(Time(),":","")+".xml"
	Local cPath   := SuperGetMV("FS_CAMPLAN",.F.,"C:\MICROSIGA\EXCEL\")//Caminho onde vai ser gerado a planilha
	Local cStartPath  := GetSrvProfString("Startpath","")
	Local cTabID  := "Relatorio DDI - TV1"
	Local cTab 	  := "DDI"
	Local cDscLan := ""
	Local cClifor := ""
	Local oExcel  := Nil

	Local cQuery := ''
	Local cQueryc := ''
	Local cQueryv := ''
	Local aDados := {}


	cQueryc := " SELECT C7_FILIAL,C7_NUM,AF8_PROJET,AF8_DESCRI,B1_DESC,A2_NOME,D1_DOC,CONVERT(DATE,D1_EMISSAO,103) EMISSAONF,CONVERT(DATE,C7_X_VENCT,103) VENCPED,CONVERT(DATE,E2_VENCREA,103) VENCNF,CONVERT(DATE,C7_EMISSAO,103) EMISSAO,C7_TAREFA TAREFA,C7_DESCTAR DESCTAR,C7_TOTAL,C7_X_VCGER "
	cQueryc += " FROM SC7020 SC7 "
	cQueryc += " JOIN "+RetSqlName('AF8')+" AF8 ON SC7.C7_CODPSP = AF8.AF8_PROJET "
	cQueryc += " JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_COD = SC7.C7_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQueryc += " JOIN "+RetSqlName('SA2')+" SA2 ON SA2.A2_COD = SC7.C7_FORNECE AND SC7.D_E_L_E_T_ = '' AND SA2.A2_COD >='"+MV_PAR05+"' AND SA2.A2_COD <='"+MV_PAR06+"' "
	cQueryc += " JOIN "+RetSqlName('SD1')+" SD1 ON SD1.D1_PEDIDO = SC7.C7_NUM AND SD1.D1_ITEMPC = SC7.C7_ITEM AND SC7.D_E_L_E_T_ = '' AND SD1.D1_FILIAL = SC7.C7_FILIAL "
	cQueryc += " JOIN "+RetSqlName('SE2')+" SE2 ON SE2.E2_NUM = SD1.D1_DOC AND SE2.E2_FORNECE = SD1.D1_FORNECE AND SE2.E2_PREFIXO = SD1.D1_SERIE AND SE2.D_E_L_E_T_ = '' AND SD1.D1_FILIAL = SE2.E2_FILIAL  "
	cQueryc += " WHERE SC7.D_E_L_E_T_ = '' AND AF8.D_E_L_E_T_ = '' AND SC7.C7_CODPSP BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SC7.C7_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' and SC7.C7_X_VCGER > 0"
	cQueryc += " GROUP BY
	cQueryc += " C7_FILIAL, "
	cQueryc += " C7_NUM, "
	cQueryc += " AF8_PROJET, "
	cQueryc += " AF8_DESCRI, "
	cQueryc += " B1_DESC, "
	cQueryc += " A2_NOME, "
	cQueryc += " D1_DOC, "
	cQueryc += " D1_EMISSAO, "
	cQueryc += " C7_X_VENCT, "
	cQueryc += " E2_VENCREA, "
	cQueryc += " C7_EMISSAO, "
	cQueryc += " C7_TAREFA, "
	cQueryc += " C7_DESCTAR, "
	cQueryc += " C7_TOTAL, "
	cQueryc += " C7_X_VCGER "
	cQueryc += " ORDER BY "
	cQueryc += " AF8_PROJET,C7_TAREFA "

	TCQUERY cQueryc NEW ALIAS NEWSC7

	WHILE NEWSC7->(!EOF())

		//AADD(aDados,{NEWSC7->C7_FILIAL,NEWSC7->AF8_PROJET,NEWSC7->AF8_DESCRI,B1_DESC,'CREDITO',NEWSC7->A2_NOME,NEWSC7->D1_DOC,NEWSC7->EMISSAONF,NEWSC7->VENCNF,NEWSC7->VENCPED,NEWSC7->EMISSAO,NEWSC7->C7_NUM,NEWSC7->TAREFA,NEWSC7->DESCTAR,NEWSC7->C7_TOTAL,NEWSC7->C7_X_VCGER})
		AADD(aDados,{NEWSC7->C7_FILIAL,NEWSC7->AF8_PROJET,NEWSC7->AF8_DESCRI,B1_DESC,'CREDITO',NEWSC7->A2_NOME,NEWSC7->D1_DOC,NEWSC7->EMISSAONF,NEWSC7->VENCNF,NEWSC7->C7_NUM,NEWSC7->EMISSAO,NEWSC7->VENCPED,NEWSC7->TAREFA,NEWSC7->DESCTAR,NEWSC7->C7_TOTAL,NEWSC7->C7_X_VCGER,'AUTOMATICO'})

		NEWSC7->(DBSKIP())
	ENDDO

	NEWSC7->(DBCLOSEAREA())

	cQueryv := " SELECT C6_FILIAL,C6_NUM,AF8_PROJET,AF8_DESCRI,B1_DESC,A1_NOME,D2_DOC,CONVERT(DATE,D2_EMISSAO,103) EMISSAONF,CONVERT(DATE,C6_DATFAT,103) EMISSAO,'' TAREFA,'' DESCTAR,C6_VALOR "
	cQueryv += " FROM "+RetSqlName('SC6')+" SC6 "
	cQueryv += " JOIN "+RetSqlName('AF8')+" AF8 ON SC6.C6_EDTPMS = AF8.AF8_PROJET "
	cQueryv += " JOIN "+RetSqlName('SB1')+" SB1 ON SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = '' "
	cQueryv += " JOIN "+RetSqlName('SA1')+" SA1 ON SA1.A1_COD = SC6.C6_CLI AND SC6.D_E_L_E_T_ = '' AND SA1.A1_COD >='"+MV_PAR07+"' AND SA1.A1_COD <='"+MV_PAR08+"' ""
	cQueryv += " JOIN "+RetSqlName('SD2')+" SD2 ON SD2.D2_PEDIDO = SC6.C6_NUM AND SD2.D2_ITEMPV = SC6.C6_ITEM AND SC6.D_E_L_E_T_ = '' "
	cQueryv += " WHERE SC6.D_E_L_E_T_ = '' AND AF8.D_E_L_E_T_ = '' AND SC6.C6_EDTPMS BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SC6.C6_DATFAT BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SC6.C6_PROJDDI <> '' "

	TCQUERY cQueryv NEW ALIAS NEWSC6

	WHILE NEWSC6->(!EOF())

		AADD(aDados,{NEWSC6->C6_FILIAL,NEWSC6->AF8_PROJET,NEWSC6->AF8_DESCRI,B1_DESC,'DEBITO',NEWSC6->A1_NOME,NEWSC6->D2_DOC,NEWSC6->EMISSAONF,'','',NEWSC6->C6_NUM,NEWSC6->EMISSAO,NEWSC6->TAREFA,NEWSC6->DESCTAR,NEWSC6->C6_VALOR,NEWSC6->C6_VALOR,'AUTOMATICO'})

		NEWSC6->(DBSKIP())
	ENDDO

	NEWSC6->(DBCLOSEAREA())

	cQuery := " SELECT Z03_FILIAL,Z03_PROJET,AF8_DESCRI,Z03_TPLANC,Z03_CLIENT,ISNULL(A2_NOME,'') FORNECEDOR,ISNULL(A1_NOME,'') CLIENTE,Z03_FORNEC,Z03_DATA,Z03_AUTO,Z03_VALOR FROM "+RetSqlName('Z03')+" Z03"
	cQuery += " JOIN "+RetSqlName('AF8')+" AF8 ON Z03.Z03_PROJET = AF8.AF8_PROJET "
	cQuery += " LEFT JOIN "+RetSqlName('SA1')+" SA1 ON SA1.A1_COD = Z03.Z03_CLIENT AND SA1.D_E_L_E_T_ = '' AND Z03.Z03_CLIENT BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cQuery += " LEFT JOIN "+RetSqlName('SA2')+" SA2 ON SA2.A2_COD = Z03.Z03_FORNEC AND SA2.D_E_L_E_T_ = '' AND Z03.Z03_FORNEC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cQuery += " WHERE Z03_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND Z03.Z03_PROJET BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
	cQuery += " AND Z03.D_E_L_E_T_ = '' AND Z03.Z03_AUTO = '2'"

	TCQUERY cQuery NEW ALIAS NEWZ03

	WHILE NEWZ03->(!EOF())


		IF NEWZ03->Z03_TPLANC == '1'
			cDscLan := "DEBITO"
			cClifor := NEWZ03->FORNECEDOR
		ELSE
			cDscLan := "CREDITO"
			cClifor := NEWZ03->CLIENTE
		ENDIF

		AADD(aDados,{NEWZ03->Z03_FILIAL,NEWZ03->Z03_PROJET,NEWZ03->AF8_DESCRI,'',cDscLan,cClifor,'',NEWZ03->Z03_DATA,'','','','','','',NEWZ03->Z03_VALOR,0,'MANUAL'})

		NEWZ03->(DBSKIP())
	ENDDO
	NEWZ03->(DBCLOSEAREA())

	If len(aDados) == 0
		Alert("Não existem lançamentos para os parâmetros Informados.")
		Return(Nil)
	Else
		ProcRegua(Len( aDados ))
		IncProc()

		oExcel 	 := FWMSEXCEL():New()
		oExcel:AddworkSheet(cTab)

		//Tabela
		oExcel:AddTable (cTab,cTabID)

		oExcel:AddColumn(cTab,cTabID,"FILIAL"			   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"PROJETO"			   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"DESCRICAO_PROJETO"	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"PRODUTO/ SERVIÇOS PRESTADOS"	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"TIPO_LANCAMENTO"   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CLIENTE/FORNECEDOR"   	  	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"NF"   	  	 				  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"EMISSAO_NF"  	 				  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VENCIMENTO_NF"  	 			  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"PEDIDO"			   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"EMISSAO"			   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VENCIMENTO_PEDIDO"  	 		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"TAREFA"			   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"DESCRICAO_TAREFA"	   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR PEDIDO"		   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR DDI"		   	  		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"STATUS"   		   	  		  ,ESQUERDA,TEXTO)


		aLinhas := Array(17)
		For i := 1 to len(aDados)
			For j := 1 to 17
				aLinhas[j] := aDados[i,j]
			Next
			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(17)
		Next i
		oExcel:Activate()
		oExcel:GetXMLFile(cFile)

		// copia o arquivo do servidor para o remote
		CpyS2T( cStartPath+cFile, cPath , .T. )
		ShellExecute("Open","EXCEL.EXE",cPath+cFile,"C:\",1)

	ENDIF

return