#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/************************************************************************
* PRGR020.PRW
* Build 1 09/12/2016 12:11:26
*
* Emissao de contrato determinado
*
* David Ferreira Quadras
************************************************************************/
/*
-------------------------------------------------------------------------
                H I S T O R I C O    D E    R E V I S A O
-------------------------------------------------------------------------
    DATA    | DESCRICAO                                 |  AUTOR
-------------------------------------------------------------------------
 09/12/2016 | Inicio do desenvolvimento                 | GABRIEL PORTO
-------------------------------------------------------------------------

PERGUNTAS: [ CONTRA ]
========================================================================
 Id | Descricao             			| Tipo    | Tamanho | Dec | Consulta Padrao
========================================================================
 01 | Filia?                			| char    |   02    |  0  |
 02 | C. Custo de?            			| char    |   11    |  0  |
 03 | C. Custo Ate?         			| char    |   11    |  0  |
 04 | Matricula De?                		| char    |   06    |  0  |
 05 | Matricula Ate?            		| char    |   06    |  0  |
 06 | Considera Somente Determinado?    | nume    |   01    |  0  |
========================================================================
*/

USER FUNCTION PRGR023()

   Local   cDirDoc  := GetMV('ES_DIRDOT')
   Local   cPathDot := "\Modelo\Determinado.DOT"
   Local   cDia 	:= ""
   Local   cAno		:= ""
   Local   cMes 	:= ""
   Local   cNome	:= ""
   Local   vIdade	:= ""
   Local   nDiaNasc := ""
   Local   nNaciona	:= ""
   Local   nEstCiv	:= ""
   Local   nEnderec	:= ""
   Local   nBairro	:= ""
   Local   nCep		:= ""
   Local   nMunici	:= ""
   Local   nHrsSem	:= ""
   Local   nHrsMes	:= ""
   Local   nNumCp	:= ""
   Local   nSerieCp	:= ""
   Local   nDtVige	:= ""
   Local   nDescfun	:= ""
   Local   nSalar	:= ""
   Local   nDescSal := ""
   Local   nDtFimContrato	:= ""
   Local   nSexo	:= ""
   Local   cPrint   :=  ""
   Local   vDiasContrato := ""
   Local   vDescricaoDiasContrato := ""
   Private nhandle
   
  IF File(cPathDot)                                                 
       	 
       	 If Pergunte( "PRGR023", .T. )
         
	         cQuery := " SELECT SRA.RA_NOME , "
	         cQuery += " 	   SRA.RA_NASC , "
	         cQuery += " 	   SX5.X5_DESCRI AS DescNaci, "
	         cQuery += " 	   UPPER(SX.X5_DESCRI)AS DescEsta  , "
	         cQuery += " 	   SRA.RA_ENDEREC , "
	         cQuery += " 	   SRA.RA_BAIRRO ,  "
	         cQuery += " 	   SRA.RA_CEP ,     "
	         cQuery += " 	   SRA.RA_COMPLEM,  "
	         cQuery += " 	   SRA.RA_MUNICIP , "
	         cQuery += " 	   SRA.RA_HRSEMAN,  "
	         cQuery += " 	   SRA.RA_HRSMES,   "
	         cQuery += " 	   SRA.RA_NUMCP ,  "
	         cQuery += " 	   SRA.RA_SERCP ,   "
	         cQuery += " 	   SRA.RA_ADMISSA , "
	         cQuery += " 	   SRJ.RJ_DESC,     "
	         cQuery += " 	   SRA.RA_SALARIO , "
	         cQuery += " 	   SRA.RA_DTFIMCT,  "
	         cQuery += " 	   CASE RA_SEXO     "
	         cQuery += " 			WHEN 'M' THEN 'o CONTRATADO' "
	         cQuery += " 			WHEN 'F' THEN 'a CONTRATADA' "
	         cQuery += " 	   END SEXO, "
	         cQuery += " 	   RA_ESTADO, "
	         cQuery += "      ROUND(DATEDIFF(DAY, RA_ADMISSA , RA_DTFIMCT ), -1) AS DT "
	         cQuery += " FROM "  + RetSqlName( "SRA" ) + " SRA "	
	         cQuery += " INNER JOIN " + RetSqlName( "SX5" ) + " SX5 ON SRA.RA_NACIONA = SX5.X5_CHAVE AND SX5.D_E_L_E_T_ = '' AND SX5.X5_TABELA = '34' "
	         cQuery += " INNER JOIN " + RetSqlName( "SX5" ) + " SX  ON SRA.RA_ESTCIVI = SX.X5_CHAVE AND SX.D_E_L_E_T_ = '' AND SX.X5_TABELA = '33'    "
	         cQuery += " INNER JOIN " + RetSqlName( "SRJ" ) + " SRJ ON SRA.RA_CODFUNC = SRJ.RJ_FUNCAO AND SRJ.D_E_L_E_T_ = '' "
	         cQuery += " WHERE SRA.RA_FILIAL  = '" + MV_PAR01 + "' AND "
	         cQuery += " 	  (SRA.RA_CC     >= '" + MV_PAR02 + "' AND "
	         cQuery += " 	  SRA.RA_CC      <= '" + MV_PAR03 + "' AND "
	         cQuery += " 	  SRA.RA_MAT     >= '" + MV_PAR04 + "' AND "
	         cQuery += " 	  SRA.RA_MAT     <= '" + MV_PAR05 + "') AND "
	         IF  MV_PAR06 == 1
	         		cQuery += "      SRA.RA_TPCONTR  = '2' AND "
	         END IF
	         cQuery += " 	  SRA.D_E_L_E_T_  = '' "					

	         TCQUERY cQuery NEW ALIAS 'OR1'
	         DbSelectArea( 'OR1' )
	         
	         If OR1->( Eof() )
	         	Aviso( "Atenção", "Dados não encontrados para os parâmetros informados!", { "OK" } )
	         EndIf
	         
	         
	         aDadosSM0 := GetAdvFVal("SM0", { "M0_ENDCOB", "M0_COMPCOB", "M0_BAIRCOB", "M0_CIDCOB", "M0_ESTCOB", "M0_CEPCOB", "M0_CGC" }, cEmpAnt+MV_PAR01, 1, { "-", "-", "-" })

	         WHILE !OR1->( Eof() )
	
	            nhandle := OLE_CreateLink() 	            // Faz conexao com o MS-Word
	            OLE_NewFile( nhandle, cDirDoc+cPathDot )

            	IF MV_PAR01 == "60"
					cPrint := "SEPS 702/902 - Lote B - Bloco A - 2o Andar, Asa Sul, Brasília/DF CEP:70390-025 CNPJ nº. 04.405.242/0002-05"
				ELSE
					cPrint := Alltrim(aDadosSM0[1])
					cPrint += " - " + Alltrim(aDadosSM0[2])
					cPrint += ", " + Alltrim(aDadosSM0[3])				
					cPrint += ", " + Alltrim(aDadosSM0[4])+"/"+ Alltrim(aDadosSM0[5])				
					cPrint += " CEP: "+Alltrim(Transform(Alltrim(aDadosSM0[6]), "@R 99999-999"))  
					cPrint += " CNPJ nº. "+ Alltrim(Transform(aDadosSM0[7], "@R 99.999.999/9999-99"))
				END IF
				
				//endereço empresa
				OLE_SetDocumentVar( nhandle, 'EndEmpresa',    cPrint)
				
				OLE_SetDocumentVar( nhandle, 'cNome',	   	  AllTrim( OR1->RA_NOME))
				OLE_SetDocumentVar( nhandle, 'nNasci',	      dtoc(stod( OR1->RA_NASC)) )
				OLE_SetDocumentVar( nhandle, 'vIdade',	      Left(cvaltochar( (date()-stod(OR1->RA_NASC))/ 365),2) )
				OLE_SetDocumentVar( nhandle, 'nNacionalidade',AllTrim( OR1->DescNaci ) )
				OLE_SetDocumentVar( nhandle, 'nEstCiv',       AllTrim( OR1->DescEsta ) )
				
				//vDiasContrato := stod(OR1->RA_DTFIMCT) - stod(OR1->RA_ADMISSA)
				//OLE_SetDocumentVar( nhandle, 'vDiasContrato', cvaltochar(vDiasContrato) )
				OLE_SetDocumentVar( nhandle, 'vDiasContrato', cvaltochar(OR1->DT) )
				OLE_SetDocumentVar( nhandle, 'vDescricaoDiasContrato', strTran(Extenso(OR1->DT),"REAIS","DIAS") ) 

				//endereço contratado
				cPrint := AllTrim(OR1->RA_ENDEREC)
				cPrint += " - " + Alltrim(OR1->RA_COMPLEM)
				cPrint += " - " + AllTrim(OR1->RA_BAIRRO)
				cPrint += " CEP: " + Alltrim(Transform(Alltrim(OR1->RA_CEP), "@R 99999-999"))
				cPrint += " - " + AllTrim(OR1->RA_MUNICIP)+ "/" + AllTrim(OR1->RA_ESTADO)
				
				OLE_SetDocumentVar( nhandle, 'nEnderec',    cPrint)

				OLE_SetDocumentVar( nhandle, 'nHrsSem',	    AllTrim( OR1->RA_HRSEMAN ) )
				OLE_SetDocumentVar( nhandle, 'nHrsMes',     AllTrim( OR1->RA_HRSMES)) 
				OLE_SetDocumentVar( nhandle, 'nNumCp',      AllTrim( OR1->RA_NUMCP ) )
				OLE_SetDocumentVar( nhandle, 'nSerieCpde',  AllTrim( OR1->RA_SERCP ) )
				OLE_SetDocumentVar( nhandle, 'vDtVige',     DtoC(StoD(OR1->RA_ADMISSA))) 	//montaData( getData( OR1->RA_ADMISSA) ) )
				OLE_SetDocumentVar( nhandle, 'nDtVige',     DtoC(StoD(OR1->RA_ADMISSA))) 	//montaData( getData( OR1->RA_ADMISSA) ) )				
				OLE_SetDocumentVar( nhandle, 'nDescfun',    AllTrim(OR1->RJ_DESC))
				OLE_SetDocumentVar( nhandle, 'nSalar',    	Alltrim(Transform(OR1->RA_SALARIO, "@E 9,999,999.99"))  )
				OLE_SetDocumentVar( nhandle, 'nDescSal',    Alltrim(Extenso(OR1->RA_SALARIO)) )
				OLE_SetDocumentVar( nhandle, 'nDtFimContrato', DtoC(StoD(OR1->RA_DTFIMCT)))
				OLE_SetDocumentVar( nhandle, 'nSexo',       AllTrim(OR1->SEXO))
				OLE_SetDocumentVar( nhandle, 'cDia',    	Day(Date()))
				OLE_SetDocumentVar( nhandle, 'cAno',    	Year(Date()) ) 
				//OLE_SetDocumentVar( nhandle, 'cMes',    	MesExtenso(Month(Date())) )
				
				IF MV_PAR01 == "60"
					cPrint := "Brasília" + ","
				ELSE
					cPrint := Capital(aDadosSM0[4])+ ","
				END IF
				cPrint += StrZero(Day(Date()),2) + " de " + MesExtenso(Month(Date())) + " de " + cvaltochar(Year(Date()))
				OLE_SetDocumentVar( nhandle, 'cMes',  cPrint )
				

	            // Atualizando as variaveis do documento do Word
	            OLE_UpdateFields(nhandle)
	   
	            IF MsgYesNo( "Fechar o documento?" )
	               OLE_CloseFile(nhandle)
	               OLE_CloseLink(nhandle)
	            ENDIF
	         
	         OR1->(DbSkip())
	      ENDDO
	      OR1->(DbCloseArea())
	   EndIf 
   ELSE
      Aviso( "Erro", "Arquivo modelo nao encontrado!", { "OK" } )
   ENDIF

   MS_FLUSH()
RETURN

/************************************************************************
* Funcao para transformar a data da base de dados na forma tradicional.
* De 20050520 para 20/05/2005 (básico)
*
* @param   sdata    data no formato do banco de dados (AAAAMMDD)
* @return  cdata    data no formato frances (DD/MM/AAAA)
************************************************************************/
STATIC FUNCTION getData( sdata )
   IF Empty( sdata )
      RETURN "  /  /"
   ENDIF
RETURN CtoD( substr( sdata, 7, 2 ) + "/" + substr( sdata, 5, 2 ) + "/" + substr( sdata, 0, 4 ) )

/************************************************************************
* Funcao montar a data de emissao do contrato
************************************************************************/
STATIC FUNCTION montaData( ddata )
   LOCAL creturn := ""

   creturn += StrZero( Day( ddata ), 2 ) + " de "
   creturn += getMes( Month( ddata ) ) + " de "
   creturn += StrZero( Year( ddata ), 4 )
RETURN creturn

/************************************************************************
* Funcao para transformar retornar o mês por extenso.
************************************************************************/
STATIC FUNCTION getMes( imes )
   LOCAL creturn := ""

   IF imes == 1
      creturn := "Janeiro"
   ELSEIF imes == 2
      creturn := "Fevereiro"
   ELSEIF imes == 3
      creturn := "Março"
   ELSEIF imes == 4
      creturn := "Abril"
   ELSEIF imes == 5
      creturn := "Maio"
   ELSEIF imes == 6
      creturn := "Junho"
   ELSEIF imes == 7
      creturn := "Julho"
   ELSEIF imes == 8
      creturn := "Agosto"
   ELSEIF imes == 9
      creturn := "Setembro"
   ELSEIF imes == 10
      creturn := "Outubro"
   ELSEIF imes == 11
      creturn := "Novembro"
   ELSEIF imes == 12
      creturn := "Dezembro"
   ENDIF
RETURN creturn
