// #########################################################################################
// Projeto:Relatorio de produção Diaria
// Modulo :Sigafin    
// Fonte  : PRGR018
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 30/03/16 | David Ferreira Quadras    | Relatório para Extrair dados de Funcionario PJ.
// ---------+-------------------+-----------------------------------------------------------

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

//------------------------------------------------------------------------------------------
user function PRGR018a()
	//--< variáveis >---------------------------------------------------------------------------
	Local cCadastro :=  ""
	Local cDescricao:=  ""
	Local bProcesso :=  {}


	cCadastro :=  "Relatorio Folha PJ"
	cDescricao:=  "Permite Extrair informações de Dados de Funcionarios PJ."
	bProcesso :=   {|oSelf| u_PRGR018b(oSelf) }

	tNewProcess():New( "PRGR018b" , cCadastro , bProcesso , cDescricao , "PRGR018",,,,,.T.,.T.  )

return

user function PRGR018b(oSelf)

	//--< variáveis >---------------------------------------------------------------------------
	Local wnrel   := "Relatorio_RH" // Coloque aqui o nome do arquivo usado para impressao em disco
	Local cFile   := "PRGR018_"+ strTran(alltochar(dDatabase), "/", "") +"_"+StrTran(Time(),":","")+".xml"
	Local cPath   := SuperGetMV("FS_CAMPLAN",.F.,"C:\MICROSIGA\EXCEL\")//Caminho onde vai ser gerado a planilha
	Local cStartPath  := GetSrvProfString("Startpath","")
	Local cTabID  := "Relatorio RH - TV1"
	Local cTab 	  := "RH"
	Local oExcel  := Nil
	Local cQuery := ""
	Local aDados := {}
	Local cDpari := ""
	Local cDparf := ""
	Local cMov := SuperGetMV("MV_FOLMES")
	Local cVbnf := ""
	Local nVal01 := 0
	Local nVal02 := 0
	Local nVal03 := 0
	Local nVal04 := 0
	Local nVal05 := 0
	Local nVal06 := 0
	
	//Cria Diretorio para Salvar o Arquivo caso não exista
	If !ExistDir(cPath)
		If Makedir(cPath)<>0
			Makedir("C:\MICROSIGA")
			If !ExistDir(cPath)
				Makedir(cPath)
			EndIf
		EndIf
	EndIf
	
	
	cDpari := MV_PAR03+MV_PAR01
	cDparf := MV_PAR03+MV_PAR02
	
	//IF cDpar == cMov
		//lCorr := .T.
		//cTab := "C"
	//else
	lCorr := .F.
	cTab := "D"
	//Endif
	
	//Verbas utilizadas para composição do Valor NF repassadas pelo Depto de RH.
	cVbnf := "'990','001','490','470','290','995'"
	
	//Query para buscar os dados de Funcionarios PJ.
	cQuery := " SELECT "
	cQuery += " RA_FILIAL, "
	cQuery += " ISNULL(RD_DATARQ,'') DTCAL, "
	cQuery += " RA_MAT, "
	cQuery += " RA_NOME, "
	cQuery += " RA_NOMEMPR, "
	cQuery += " RA_CNAE, "
	cQuery += " RA_TELEFON, "
	cQuery += " RA_TELEFO2, "
	cQuery += " RA_NUMCELU, "
	cQuery += " RA_EMAIL, "
	cQuery += " RA_EMAIL2, "
	cQuery += " RA_SERVICO, "
	cQuery += " RA_BAIRRPJ, "
	cQuery += " RA_MUNICPJ, "
	cQuery += " RA_CICANT, "
	cQuery += " RA_ADMISSA, "
	cQuery += " RA_DEMISSA, "
	cQuery += " RA_CC, "
	cQuery += " RA_SIMPLES, "
	cQuery += " RD_DATARQ  "
	cQuery += " FROM "+ RetSqlName('SRA') +" SRA "
	cQuery += " LEFT JOIN "+ RetSqlName('SR'+cTab) +" MOV ON MOV.R"+cTab+"_FILIAL = SRA.RA_FILIAL AND MOV.R"+cTab+"_MAT = SRA.RA_MAT AND "
	cQuery += " MOV.R"+cTab+"_PD IN ("+cVbnf+") AND MOV.D_E_L_E_T_ = ''  "
	IF !lCorr
		cQuery += " AND MOV.R"+cTab+"_DATARQ BETWEEN "+cDpari+" AND "+cDparf+" "
	Endif
	cQuery += " WHERE SRA.D_E_L_E_T_ = '' "
	cQuery += " GROUP BY "
	cQuery += " RA_FILIAL, "
	cQuery += " RD_DATARQ, "
	cQuery += " RA_MAT, "
	cQuery += " RA_NOME, "
	cQuery += " RA_NOMEMPR, "
	cQuery += " RA_CNAE, "
	cQuery += " RA_TELEFON, "
	cQuery += " RA_TELEFO2, "
	cQuery += " RA_NUMCELU, "
	cQuery += " RA_EMAIL, "
	cQuery += " RA_EMAIL2, "
	cQuery += " RA_SERVICO, "
	cQuery += " RA_BAIRRPJ, "
	cQuery += " RA_MUNICPJ, "
	cQuery += " RA_CICANT, "
	cQuery += " RA_ADMISSA, "
	cQuery += " RA_DEMISSA, "
	cQuery += " RA_CC, "
	cQuery += " RA_SIMPLES "
	cQuery += " ORDER BY "
	cQuery += " RA_FILIAL, "
	cQuery += " RA_MAT, "
	cQuery += " RD_DATARQ "
	
	TCQUERY cQuery NEW ALIAS 'TSRA'

	dbSelectArea('TSRA')
		
	TSRA->(dbgotop())


	WHILE TSRA->(!eof())
	
		nVal01 := 0
		nVal02 := 0
		nVal03 := 0
		nVal04 := 0
		nVal05 := 0
		nVal06 := 0
		
		IF !EMPTY(TSRA->RD_DATARQ)
		
		//Contrato
			cQuery := " SELECT SUM(ISNULL(VAL1.R"+cTab+"_VALOR,0)) VLR FROM "+ RetSqlName('SR'+cTab) +" VAL1 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '990'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD1'
		
			IF TRD1->(!EOF())
		
				nVal01 := TRD1->VLR
		
			ENDIF
		
			TRD1->(DBCLOSEAREA())
		
		//Adiantamento
			cQuery := " SELECT SUM(ISNULL(VAL2.R"+cTab+"_VALOR,0)) VLR  FROM "+ RetSqlName('SR'+cTab) +" VAL2 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '001'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD2'
		
			IF TRD2->(!EOF())
		
				nVal02 := TRD2->VLR
		
			ENDIF
		
			TRD2->(DBCLOSEAREA())
		
		//Parc. Bonus
			cQuery := " SELECT SUM(ISNULL(VAL3.R"+cTab+"_VALOR,0)) VLR FROM "+ RetSqlName('SR'+cTab) +" VAL3 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '290'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD3'
		
			IF TRD3->(!EOF())
		
				nVal03 := TRD3->VLR
		
			ENDIF
		
			TRD3->(DBCLOSEAREA())
		
		//Adiant. Bonus Mensal
			cQuery := " SELECT SUM(ISNULL(VAL4.R"+cTab+"_VALOR,0)) VLR  FROM "+ RetSqlName('SR'+cTab) +" VAL4 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '470'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD4'
		
			IF TRD4->(!EOF())
		
				nVal04 := TRD4->VLR
		
			ENDIF
		
			TRD4->(DBCLOSEAREA())
		
		//Adiant. Rescisão
			cQuery := " SELECT SUM(ISNULL(VAL5.R"+cTab+"_VALOR,0)) VLR FROM "+ RetSqlName('SR'+cTab) +" VAL5 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '490'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD5'
		
			IF TRD5->(!EOF())
		
				nVal05 := TRD5->VLR
		
			ENDIF
		
			TRD5->(DBCLOSEAREA())
		
		//LIQUIDO BONUS 8.33
			cQuery := " SELECT SUM(ISNULL(VAL6.R"+cTab+"_VALOR,0)) VLR FROM "+ RetSqlName('SR'+cTab) +" VAL6 "
			cQuery += " WHERE RD_MAT ="+TSRA->RA_MAT+" AND RD_DATARQ = "+TSRA->RD_DATARQ+" AND D_E_L_E_T_ = '' AND RD_PD = '995'  "
		
			TCQUERY cQuery NEW ALIAS 'TRD6'
		
			IF TRD6->(!EOF())
		
				nVal06 := TRD6->VLR
		
			ENDIF
		
			TRD6->(DBCLOSEAREA())
		
		ENDIF
	
		AADD(aDados,{TSRA->RA_FILIAL,SUBSTR(TSRA->DTCAL,5,2) +"/"+ SUBSTR(TSRA->DTCAL,1,4),TSRA->RA_MAT,TSRA->RA_NOME,TSRA->RA_NOMEMPR,TSRA->RA_CNAE,TSRA->RA_TELEFON,TSRA->RA_TELEFO2,TSRA->RA_NUMCELU,TSRA->RA_EMAIL,TSRA->RA_EMAIL2,TSRA->RA_SERVICO,TSRA->RA_BAIRRPJ,TSRA->RA_MUNICPJ,TSRA->RA_CICANT,TSRA->RA_ADMISSA,TSRA->RA_DEMISSA,TSRA->RA_CC,TSRA->RA_SIMPLES,nVal01,nVal02,nVal03,nVal04,nVal05,nVal06})
		
	
		TSRA->(dbSkip())
	
	Enddo
	
	
	TSRA->(dbCloseArea())
	
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
		oExcel:AddColumn(cTab,cTabID,"FILIAL"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"DATA"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"MATRICULA"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"NOME"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"EMPRESA"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CNAE"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"TELEFONE_1"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"TELEFONE_2"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CELULAR"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"EMAIL"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"EMAIL_2"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"SERVICO"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"BAIRRO"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"MUNICIPIO"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CNPJ"			   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"ADMISSAO"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"DEMISSAO"		   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CENTRO_CUSTO"	  	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"OPT_SIMPLES"	   	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"CONTRATO"			  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"ADIANTAMENTO"		  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"PARC.BONUS"			  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"ADIANT.BONUS MENSAL" ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"ADIANT.RESCISAO"	  ,ESQUERDA,TEXTO)
		oExcel:AddColumn(cTab,cTabID,"LIQUIDO BONUS 8.33"  ,ESQUERDA,TEXTO)


 
		aLinhas := Array(25)
		For i := 1 to len(aDados)
			For j := 1 to 25
				aLinhas[j] := aDados[i,j]
			Next
			oExcel:AddRow(cTab, cTabID,aLinhas)
			aLinhas := Array(25)
		Next i
		oExcel:Activate()
		oExcel:GetXMLFile(cFile)
		
		//oExcel:Activate()
		//oExcel:GetXMLFile(cFile)
	
	// copia o arquivo do servidor para o remote
		CpyS2T( cStartPath+cFile, cPath , .T. )
		ShellExecute("Open","EXCEL.EXE",cPath+cFile,"C:\",1)
	
	
	Endif

return
//--< fim de arquivo >----------------------------------------------------------------------
