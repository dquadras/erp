#INCLUDE "TOPCONN.ch"
#INCLUDE "rwmake.ch"
#include "ap5mail.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE enter chr(13)+chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³IMFA061     º Autor ³ David Ferreira   º Data ³  11/11/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exclusao de Saldos em Aberto dos pedidos de Compra.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function IMFA061(lRet)

Local cQuery 	:= ""
Local aLista 	:= {}
Local i 		:= 0
Local cHtml 	 := ""
Local cTableHtml := ""
Local lCabec	 := .f.

If ALTERA == .T. .AND. M->AF8_FASE $ GetMv('MV_ENCFASE',, '05/06') .And. __cUserID $ GETMV("MV_ENCPRJ")

	If FindFunction("U_IMFA018") 
		u_IMFA018("u_IMFA061","Mudança fase do Psp De:"+AF8->AF8_FASE+"/para:"+M->AF8_FASE)		
	EndIf	
	
	//EXCLUI OS PEDIDOS QUE ESTAO TOTALMENTE EM ABERTO EM NAO POSSUEM CREDITO
	cQuery := " SELECT * FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += " WHERE "
	cQuery += " 	  C7_ENCER 	<> 'E' "
	cQuery += " AND C7_X_NOTA 	= '' "
	cQuery += " AND C7_X_VLRBX 	= 0  "
	cQuery += " AND C7_QUJE 		= 0  "
	cQuery += " AND C7_X_VCGER	= 0  "
	cQuery += " AND C7_X_CRDVL 	= 0  "
	cQuery += " AND C7_CODPSP 	= '"+M->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_ 	= '' "
	
	TCQUERY cQuery NEW ALIAS "ESC7"
	
	dbSelectArea("ESC7")
	ESC7->(dbGotop())
	While !ESC7->(Eof())
		dbSelectArea("SC7")
		SC7->(DbSetOrder(1))
		If SC7->(dbSeek(xFilial("SC7")+ESC7->C7_NUM))
			
			While SC7->(!EOF()) .And. SC7->C7_NUM == ESC7->C7_NUM
			
				aAdd(aLista, { SC7->C7_NUM,;
								SC7->C7_CODPSP,;
								UsrFullName(SC7->C7_USER),;
								UsrRetMail(SC7->C7_USER),;
								UsrFullName( __cUserID ),;
								dDataBase,;
								"Pedido de Compra(em aberto) para Excluído, devido ao encerramento do PSP em"+ dtoc(dDataBase),;
								SubStr(AF8->AF8_DESCRI,1,40),;
								SC7->C7_USER;								
								})			
				/**/
				RECLOCK("SC7",.F.)
					SC7->(DBDELETE())
				SC7->(MSUNLOCK())
				
				DbSelectArea("SCR")
				SCR->(DbSetOrder(1))
				If SCR->(dbSeek(xFilial("SCR")+"PC"+ESC7->C7_NUM))
					
					WHILE SCR->(!EOF()) .And. SCR->CR_NUM == ESC7->C7_NUM
						RecLock("SCR",.F.)
							SCR->(DbDelete())
						SCR->(MsUnLock())
						SCR->(dbSkip())
					Enddo
				EndIf
				/**/
				
				SC7->(dbSkip())
				
			Enddo
		EndIf
		ESC7->(dbSkip())
	Enddo
	ESC7->(dbCloseArea())
	
	//ZERA O SALDO DOS PEDIDOS EM ABERTO
	cQuery := " SELECT * FROM "+RetSqlName("SC7")+" SC7 "
	cQuery += " WHERE "
	cQuery += " C7_ENCER <> 'E' "
	cQuery += " AND C7_X_NOTA <> '' "
	cQuery += " AND C7_X_VLRBX > 0 "
	cQuery += " AND C7_X_VLRBX <> C7_TOTAL "
	cQuery += " AND C7_CODPSP = '"+M->AF8_PROJET+"' "
	cQuery += " AND D_E_L_E_T_ = '' "
	
	TCQUERY cQuery NEW ALIAS "ASC7"
	dbSelectArea("ASC7")
	ASC7->(dbGotop())
	While ASC7->(!eof())
		
		dbSelectArea("SC7")
		SC7->(DBSETORDER(1))
		If dbSeek(xFilial("SC7")+ASC7->C7_NUM)
		
			aAdd(aLista, {SC7->C7_NUM,;
							SC7->C7_CODPSP,;
							UsrFullName(SC7->C7_USER),;
							UsrRetMail(SC7->C7_USER),;
							UsrFullName(__cUserID),;
							dDataBase,;
							"Pedido de Compra(em aberto) para finalizado, devido ao encerramento do PSP em"+ dtoc(dDataBase),;
							SubStr(AF8->AF8_DESCRI,1,40),;
							SC7->C7_USER;
							})
			
			RECLOCK("SC7",.F.)
				SC7->C7_QUJE    := SC7->C7_QUANT
				SC7->C7_ENCER   := 'M'
				SC7->C7_X_VLRBX := SC7->C7_TOTAL
			SC7->(MSUNLOCK())

			dbSelectArea("SCR")
			SCR->(DbSetOrder(1))
			If dbSeek(xFilial("SCR")+"PC"+ASC7->C7_NUM)
				WHILE !SCR->(EOF()) .AND. SCR->CR_NUM == ASC7->C7_NUM
					RECLOCK("SCR",.F.)
						SCR->(DBDELETE())
						SCR->(MSUNLOCK())
					SCR->(dbSkip())
				Enddo
			EndIf
		EndIf
		ASC7->(dbskip())		
	Enddo

	SCR->(DBCLOSEAREA())
	SC7->(DBCLOSEAREA())
	ASC7->(dbCloseArea())       

	_lRet := .T.
	
Else
	
	_lRet := .F.
	Alert("Usuario nao possui permissao para Encerrar o Projeto!")
	
EndIf

cHtml := ""

/** Dispara emails **/

If len(aLista) > 0

	aSort( aLista,,, { |x,y| x[9]+x[1]+x[2] < y[9]+y[1]+y[2]})
		
	cComprador := aLista[1,3]
	htmlCab(@cHtml, cComprador)	

	For i := 1 to Len(aLista)
		
		If cComprador == aLista[i,3]
			
			htmlItens(@cHtml, i, aLista)
		
		  	cComprador := aLista[i,3]
		  	_cTo := AllTrim(aLista[i,4])
		
		Else
			
			HtmlRodape(@cHtml)			
			aAnexo := {}
			_cMailError := ""
			_cCC := AllTrim(UsrRetMail("000000"))
			_cSubject := "Aviso - Encerramento de Pedidos de Compras por Finalização de PSP"
			
			AutoGrLog("Envio de Email")
			AutoGrLog(cHtml)
			

			_cMailError := Imf061Mail(_cTo,_cCC,_cSubject,cHtml,aAnexo)

			If !Empty(_cMailError)
				AutoGrLog("Erro:IMFA061/Muda fase PSP: Erro ao gerar Email"+ _cMailError)
			EndIf
			
			cHtml := ""
			cComprador := aLista[i,3]	
			htmlCab(@cHtml, cComprador)	
			htmlItens(@cHtml, i, aLista)			

	  	EndIf

	Next i
	
	If i > len(aLista) .And. len(aLista) > 0
		
		//htmlItens(@cHtml, len(aLista), aLista)
		HtmlRodape(@cHtml)			
		aAnexo := {}
		_cMailError := ""
		_cTo := AllTrim(aLista[len(aLista),4])
		_cCC := AllTrim(UsrRetMail("000000"))
		_cSubject := "Aviso - Encerramento de Pedidos de Compras por Finalização de PSP"
			
		AutoGrLog("Envio de Email")
		AutoGrLog(cHtml)
		
		_cMailError := Imf061Mail(_cTo,_cCC,_cSubject,cHtml,aAnexo)
		If !Empty(_cMailError)
			AutoGrLog("Erro:IMFA061/Muda fase PSP: Erro ao gerar Email"+ _cMailError)
		EndIf
		__CopyFile(NomeAutoLog(), 'imfa061_encerrapsp'+dtos(dDataBase)+__cUserID+".html")
	EndIf
	
EndIf
/**/
Return(_lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
HtmlCab
Cabecalho do Html
@author    TOTVS | Developer Studio - Fernando
/*/
//------------------------------------------------------------------------------------------
Static function HtmlCab(cHtml, cComprador)

	cHtml := '<html>'
	cHtml := '<body></body>	

	cHtml += ' <br> '	

	cHtml += ' <table frame="box"  > '
  	cHtml += ' 	<tr > '
	cHtml += ' 		<td>	 '
	cHtml += ' 			Prezado(a) '+cComprador+',<BR><BR> '
	cHtml += ' 			Devido a finaliza&ccedil;&atilde;o dos PSPs(Jobs) abaixo, o(s) seguinte(s) Pedidos de Compras foram encerrados:'
	cHtml += ' 			 '
	cHtml += ' 		</td> '
  	cHtml += ' 	</tr> '
	cHtml += ' </table>	'


	cHtml += ' <table border="0" > '
	cHtml += '  <tr > '	
	cHtml += '  	<th  bgColor="FFD447" align="center" >N&uacute;mero Pedido</th> ' 
	cHtml += '  	<th  bgColor="FFD447" align="left" >PSP</th> '
	cHtml += '  	<th  bgColor="FFD447" align="left" >Finalizado Por:</th> '		
	cHtml += '  	<th  bgColor="FFD447" align="left" >Data</th>		'
	cHtml += '  	<th  bgColor="FFD447" align="left" >Retranca</th> '
	cHtml += '  	<th  bgColor="FFD447" align="left">Detalhes</th> ' 
	cHtml += '  </tr> '
	//cHtml += '</table>'

Return(Nil)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
HtmlItens
Cabecalho do Html
@author    TOTVS | Developer Studio - Fernando
/*/
//------------------------------------------------------------------------------------------
Static function HtmlItens(cHtml, nLinha,aLista)

	If mod(nLinha,2) == 0
		//cHtml +='<tr style="background-color:lightgray;"> '
		cHtml +='<tr bgColor="#d3d3d3"> '
	Else
		cHtml +='<tr bgColor="#F9F9F9">'
	EndIf
	
	cHtml += '		<td  align="left">'+aLista[nLinha,01]+'</td>'  //Numero PC
	cHtml += '		<td  align="left">'+aLista[nLinha,02]+'</td>'  //Numero PSP 
	cHtml += '		<td  align="left">'+aLista[nLinha,05]+'</td>'  //Fase Finalizada Por: 
	cHtml += '		<td  align="left">'+dtoc(aLista[nLinha,06])+'</td>'  //Data
	cHtml += '		<td  align="left">'+aLista[nLinha,08]+'</td>'  //Retranca	
	cHtml += '		<td  align="left">'+aLista[nLinha,07]+'.</td>' //Detalhes
	cHtml += '	</tr> '

Return(Nil)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
HtmlRodape
Rodapé do Html
@author    TOTVS | Developer Studio - Fernando
/*/
//------------------------------------------------------------------------------------------
Static Function HtmlRodape(cHtml)

	cHtml += ' </table> '
	cHtml += ' <h4>* Em caso de d&uacute;vidas, contate o respons&aacute;vel pelo encerramento do PSP.</h4> '
	cHtml += ' </html> '
Return(Nil)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} 
Imf061Mail
Rodapé do Html
Envio de Emails.
@author    TOTVS | Developer Studio - Fernando
/*/
//------------------------------------------------------------------------------------------
Static Function Imf061Mail(_cTo,_cCC,_cSubject,_cHtml,aAnexo)

Local nY		:= 0
Local  _lFalha  := .f.          
Local _cFilial  := xFilial("SA1")
Local lDetalhe  := .F.
Local lOk	  	:= .F.
Local _cPara    := SPACE(250)
Local cCC       := ""                      //:= GetMV("MV_WFSMTP")
Local cSubject  := _cSubject
Local cEnvia    := ""

Private cPassword := GETMV("MV_RELPSW")     
Private cAccount  := GETMV("MV_RELACNT",, "msiga")   // msiga 
Private cServer   := GETMV("MV_RELSERV",,"172.30.0.25")  


If FindFunction("U_IMFA018") 
	u_IMFA018("Imf061Mail","")		
Endif	


// Envio do Email
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
If lOk
    	SEND MAIL FROM "msiga@tv1.com.br"  TO _cTo SUBJECT cSubject BODY _cHtml Result lOk  
    	If !lOk
    		GET MAIL ERROR cError
    		Aviso("ATENCAO", "Nao foi enviado o Email - Para :"+_cTo +chr(13)+chr(10)+" Mensagem: "+cError,{"&Ok"})
    		_lFalha:=.T.
   	    EndIf
Else
	GET MAIL ERROR cError
  	Aviso("ATENCAO", "Falha na conexao com o servidor de Email - "+cError,{"&Ok"})
EndIf

DISCONNECT SMTP SERVER

Return(Nil)