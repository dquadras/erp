#include "rwmake.ch"
#include "PROTHEUS.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

//Tipos de dados.
#DEFINE TEXTO 	 1
#DEFINE NUMERO 	 2
#DEFINE MOEDA 	 3
#DEFINE DATAHORA 4

//Alinhamento.
#DEFINE ESQUERDA 1
#DEFINE CENTRO	 2
#DEFINE DIREITA	 3

/*/{Protheus.doc} PRGR019
Relatorio de Comissionamento 
@author David Ferreira Quadras
@since 11/07/2016
@version 1.0
/*/


user Function PRGR020a() 


	//--< variáveis >---------------------------------------------------------------------------
	Local cCadastro :=  ""
	Local cDescricao:=  ""
	Local bProcesso :=  {}


	cCadastro :=  "Relatorio de Comissionamento"
	cDescricao:=  "Permite Extrair informações de Dados de projeto."
	bProcesso :=   {|oSelf| u_PRGR020b(oSelf) }

	tNewProcess():New( "PRGR020b" , cCadastro , bProcesso , cDescricao , "PRGR020",,,,,.T.,.T.  )


Return 


user function PRGR020b()

	//--< variáveis >---------------------------------------------------------------------------
	Local wnrel   := "Relatorio_Comissionamento" // Coloque aqui o nome do arquivo usado para impressao em disco
	Local cFile   := "PRGR019_"+ strTran(alltochar(dDatabase), "/", "") +"_"+StrTran(Time(),":","")+".xml"
	Local cPath   := SuperGetMV("FS_CAMPLAN",.F.,"C:\MICROSIGA\EXCEL\")//Caminho onde vai ser gerado a planilha
	Local cStartPath  := GetSrvProfString("Startpath","")
	Local cTabID  := "Relatorio de Comissao - TV1"
	Local cTab 	  := "projeto"
	Local oExcel  := Nil
	Local cQuery := ""
	Local aDados := {}
	Local cNfant := ""
	Local cPspant := ""




	If !ExistDir(cPath)
		If Makedir(cPath)<>0
			Makedir("C:\MICROSIGA")
			If !ExistDir(cPath)
				Makedir(cPath)
			EndIf
		EndIf
	EndIf

	cQuery := " SELECT "
	cQuery += " SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) AS EMISSAO, "
	cQuery += " Z4_X_DESC UNIDADE, "
	cQuery += " AF8_PROJET PSP, "
	cQuery += " AF8_DESCRI RETRANCA, "
	cQuery += " A1_NOME RAZAO_SOCIAL, "
	cQuery += " SUM(D2_TOTAL) BRUTO, "
	cQuery += " AFC_CUSTPV VALOR_ORCADO, "
	cQuery += " AFC_TVPVBV VENDA, "
	cQuery += " '' MARGEM_VENDA, "
	cQuery += " AF8_X_NOMV VENDEDOR, "
	cQuery += " ISNULL(SUM(SE5.E5_VALOR),0) RECEBIDO, "
	cQuery += " SUBSTRING(E5_DATA,7,2)+'/'+SUBSTRING(E5_DATA,5,2)+'/'+SUBSTRING(E5_DATA,1,4) AS DATA_RECEBIMENTO, "
	cQuery += " SD2.D2_DOC RPS, "
	cQuery += " SD2.D2_ITEM ITEM, "
	cQuery += " SE1.E1_NFELETR NFE "
	cQuery += " FROM  "
	cQuery += " "+RetSqlname('SD2')+" SD2 "
	cQuery += " JOIN "+RetSqlname('AF8')+" AF8 ON AF8_PROJET = SD2.D2_EDTPMS AND AF8.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RetSqlname('AFC')+" AFC ON AF8_PROJET = AFC_PROJET AND AF8_REVISA = AFC_REVISA and AFC_EDT = AFC_PROJET AND AFC.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RetSqlname('SZ4')+" SZ4 ON AF8_X_TIPO = Z4_X_COD AND SZ4.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RetSqlname('SA1')+" SA1 ON AF8_CLIENT = A1_COD AND SA1.D_E_L_E_T_ = '' "
	cQuery += " JOIN "+RetSqlname('SE1')+" SE1 ON SE1.E1_FILIAL = SD2.D2_FILIAL AND SE1.E1_NUM = SD2.D2_DOC AND SE1.E1_PREFIXO = SD2.D2_SERIE AND SD2.D2_CLIENTE = SE1.E1_CLIENTE AND SE1.D_E_L_E_T_ = '' "
	cQuery += " LEFT JOIN "+RetSqlname('SE5')+" SE5 ON SE1.E1_FILIAL = SE5.E5_FILIAL AND SE5.E5_NUMERO = SE1.E1_NUM AND  SE5.E5_PREFIXO = SE1.E1_PREFIXO AND SE5.E5_CLIENTE = SE1.E1_CLIENTE AND SE5.D_E_L_E_T_ = '' "
	cQuery += " WHERE  "
	cQuery += " (E5_DATA BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' or D2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' ) AND SD2.D_E_L_E_T_= ''	 AND "
	cQuery += " SD2.D_E_L_E_T_ = '' AND "
	cQuery += " SE1.E1_TIPO = 'NF' "
	cQuery += " GROUP BY "
	cQuery += " D2_EMISSAO, "
	cQuery += " E1_BAIXA, "
	cQuery += " Z4_X_DESC, "
	cQuery += " AF8_PROJET, "
	cQuery += " AF8_DESCRI, "
	cQuery += " A1_NOME, "
	cQuery += " AFC_CUSTPV, " 
	cQuery += " AFC_TVPVBV, "
	cQuery += " AF8_X_NOMV, "
	cQuery += " SE1.E1_VALOR, "
	cQuery += " SE1.E1_SALDO, "
	cQuery += " SE5.E5_DATA, "
	cQuery += " SD2.D2_DOC, "
	cQuery += " SD2.D2_ITEM, "
	cQuery += " SE1.E1_NFELETR "
	cQuery += " ORDER BY "
	cQuery += " Z4_X_DESC,SD2.D2_DOC,AF8_PROJET,SD2.D2_EMISSAO,SE5.E5_DATA "

	TCQUERY cQuery NEW ALIAS 'CMS'

	dbSelectArea('CMS')

	CMS->(dbgotop())
	aNf := {}
	WHILE CMS->(!eof())

		//IF alltrim(CMS->NF) <> alltrim(cNfant)
		nPosNF := aScan(aNF,{ |a| alltrim(a[1]) == alltrim(CMS->RPS) .And. alltrim(a[2]) == alltrim(CMS->PSP) }) 
		IF  nPosNF == 0

			AADD(aDados,{CMS->EMISSAO,CMS->UNIDADE,CMS->PSP,CMS->RETRANCA,CMS->RAZAO_SOCIAL,CMS->BRUTO,CMS->VALOR_ORCADO,CMS->VENDA,CMS->MARGEM_VENDA,CMS->VENDEDOR,CMS->RECEBIDO,CMS->DATA_RECEBIMENTO,CMS->RPS,CMS->ITEM,CMS->NFE})
			
			aAdd(aNF, {alltrim(CMS->RPS), alltrim(CMS->PSP)})

		ELSE 

			AADD(aDados,{CMS->EMISSAO,CMS->UNIDADE,CMS->PSP,CMS->RETRANCA,CMS->RAZAO_SOCIAL,0,0,0,'',CMS->VENDEDOR,CMS->RECEBIDO,CMS->DATA_RECEBIMENTO,CMS->RPS,CMS->ITEM,CMS->NFE})

		ENDIF

		//cNfant := CMS->NF
		//cPspant := CMS->PSP

		CMS->(DBSKIP())


	ENDDO
	
	CMS->(DBCLOSEAREA())

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

		//Colunas
		oExcel:AddColumn(cTab,cTabID,"EMISSAO"			   	  ,ESQUERDA,DATAHORA)
		oExcel:AddColumn(cTab,cTabID,"UNIDADE"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"PROJETO"		   	      ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"DESCRICAO_PROJETO"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"RAZAO_SOCIAL"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR_NF"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR_ORCADO"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR_VENDA"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"MARGEM_VENDA"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VENDEDOR"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"VALOR_RECEBIDO"			   	  ,ESQUERDA,DATAHORA)
		oExcel:AddColumn(cTab,cTabID,"DATA_RECEBIMENTO"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"RPS"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"ITEM"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"NFE"			   	  ,ESQUERDA,TEXTO)


		aLinhas := Array(15)

		For i := 1 to len(aDados)
			For j := 1 to 15
				aLinhas[j] := aDados[i,j]
			Next
			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(15)
		Next i
		oExcel:Activate()
		oExcel:GetXMLFile(cFile)

		//oExcel:Activate()
		//oExcel:GetXMLFile(cFile)

		// copia o arquivo do servidor para o remote
		CpyS2T( cStartPath+cFile, cPath , .T. )
		ShellExecute("Open","EXCEL.EXE",cPath+cFile,"C:\",1)



	ENDIF


return