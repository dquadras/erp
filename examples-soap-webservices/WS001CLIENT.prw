#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWPROJ.apw?WSDL
Gerado em        07/12/16 10:50:56
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _PWVKRVR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWPROJ
------------------------------------------------------------------------------- */

WSCLIENT WSNEWPROJ

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD SETDATAVENDAPROJ
	WSMETHOD SETJUROSDESCPROJ
	WSMETHOD WSALTPROJETO
	WSMETHOD WSEXCLUIPROJETO
	WSMETHOD WSINCPROJETO

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   c_CEMPRESA                AS string
	WSDATA   c_CFILIAL                 AS string
	WSDATA   c_CCODIGO                 AS string
	WSDATA   cSETDATAVENDAPROJRESULT   AS string
	WSDATA   nJUROS                    AS float
	WSDATA   nDESCONTOS                AS float
	WSDATA   cSETJUROSDESCPROJRESULT   AS string
	WSDATA   c_CDESCRICAO              AS string
	WSDATA   c_CPROJETOINT             AS string
	WSDATA   c_CCODVDA                 AS string
	WSDATA   c_CCODCLI                 AS string
	WSDATA   c_CLOJCLI                 AS string
	WSDATA   c_CTIPPRJ                 AS string
	WSDATA   c_CFASE                   AS string
	WSDATA   c_COBS                    AS string
	WSDATA   c_CDTENTR                 AS string
	WSDATA   c_CDTENTRF                AS string
	WSDATA   c_CDTVEND                 AS string
	WSDATA   c_CCONTATO1               AS string
	WSDATA   cWSALTPROJETORESULT       AS string
	WSDATA   cWSEXCLUIPROJETORESULT    AS string
	WSDATA   c_CUNINEG                 AS string
	WSDATA   c_CCODSEQ                 AS string
	WSDATA   cWSINCPROJETORESULT       AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWPROJ
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWPROJ
Return

WSMETHOD RESET WSCLIENT WSNEWPROJ
	::cKEY               := NIL 
	::c_CEMPRESA         := NIL 
	::c_CFILIAL          := NIL 
	::c_CCODIGO          := NIL 
	::cSETDATAVENDAPROJRESULT := NIL 
	::nJUROS             := NIL 
	::nDESCONTOS         := NIL 
	::cSETJUROSDESCPROJRESULT := NIL 
	::c_CDESCRICAO       := NIL 
	::c_CPROJETOINT      := NIL 
	::c_CCODVDA          := NIL 
	::c_CCODCLI          := NIL 
	::c_CLOJCLI          := NIL 
	::c_CTIPPRJ          := NIL 
	::c_CFASE            := NIL 
	::c_COBS             := NIL 
	::c_CDTENTR          := NIL 
	::c_CDTENTRF         := NIL 
	::c_CDTVEND          := NIL 
	::c_CCONTATO1        := NIL 
	::cWSALTPROJETORESULT := NIL 
	::cWSEXCLUIPROJETORESULT := NIL 
	::c_CUNINEG          := NIL 
	::c_CCODSEQ          := NIL 
	::cWSINCPROJETORESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWPROJ
Local oClone := WSNEWPROJ():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:c_CEMPRESA    := ::c_CEMPRESA
	oClone:c_CFILIAL     := ::c_CFILIAL
	oClone:c_CCODIGO     := ::c_CCODIGO
	oClone:cSETDATAVENDAPROJRESULT := ::cSETDATAVENDAPROJRESULT
	oClone:nJUROS        := ::nJUROS
	oClone:nDESCONTOS    := ::nDESCONTOS
	oClone:cSETJUROSDESCPROJRESULT := ::cSETJUROSDESCPROJRESULT
	oClone:c_CDESCRICAO  := ::c_CDESCRICAO
	oClone:c_CPROJETOINT := ::c_CPROJETOINT
	oClone:c_CCODVDA     := ::c_CCODVDA
	oClone:c_CCODCLI     := ::c_CCODCLI
	oClone:c_CLOJCLI     := ::c_CLOJCLI
	oClone:c_CTIPPRJ     := ::c_CTIPPRJ
	oClone:c_CFASE       := ::c_CFASE
	oClone:c_COBS        := ::c_COBS
	oClone:c_CDTENTR     := ::c_CDTENTR
	oClone:c_CDTENTRF    := ::c_CDTENTRF
	oClone:c_CDTVEND     := ::c_CDTVEND
	oClone:c_CCONTATO1   := ::c_CCONTATO1
	oClone:cWSALTPROJETORESULT := ::cWSALTPROJETORESULT
	oClone:cWSEXCLUIPROJETORESULT := ::cWSEXCLUIPROJETORESULT
	oClone:c_CUNINEG     := ::c_CUNINEG
	oClone:c_CCODSEQ     := ::c_CCODSEQ
	oClone:cWSINCPROJETORESULT := ::cWSINCPROJETORESULT
Return oClone

// WSDL Method SETDATAVENDAPROJ of Service WSNEWPROJ

WSMETHOD SETDATAVENDAPROJ WSSEND cKEY,c_CEMPRESA,c_CFILIAL,c_CCODIGO WSRECEIVE cSETDATAVENDAPROJRESULT WSCLIENT WSNEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETDATAVENDAPROJ xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMPRESA", ::c_CEMPRESA, c_CEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODIGO", ::c_CCODIGO, c_CCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</SETDATAVENDAPROJ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/SETDATAVENDAPROJ",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWPROJ.apw")

::Init()
::cSETDATAVENDAPROJRESULT :=  WSAdvValue( oXmlRet,"_SETDATAVENDAPROJRESPONSE:_SETDATAVENDAPROJRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETJUROSDESCPROJ of Service WSNEWPROJ

WSMETHOD SETJUROSDESCPROJ WSSEND cKEY,c_CEMPRESA,c_CFILIAL,c_CCODIGO,nJUROS,nDESCONTOS WSRECEIVE cSETJUROSDESCPROJRESULT WSCLIENT WSNEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETJUROSDESCPROJ xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMPRESA", ::c_CEMPRESA, c_CEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODIGO", ::c_CCODIGO, c_CCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("JUROS", ::nJUROS, nJUROS , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("DESCONTOS", ::nDESCONTOS, nDESCONTOS , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += "</SETJUROSDESCPROJ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/SETJUROSDESCPROJ",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWPROJ.apw")

::Init()
::cSETJUROSDESCPROJRESULT :=  WSAdvValue( oXmlRet,"_SETJUROSDESCPROJRESPONSE:_SETJUROSDESCPROJRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSALTPROJETO of Service WSNEWPROJ

WSMETHOD WSALTPROJETO WSSEND cKEY,c_CEMPRESA,c_CFILIAL,c_CCODIGO,c_CDESCRICAO,c_CPROJETOINT,c_CCODVDA,c_CCODCLI,c_CLOJCLI,c_CTIPPRJ,c_CFASE,c_COBS,c_CDTENTR,c_CDTENTRF,c_CDTVEND,c_CCONTATO1 WSRECEIVE cWSALTPROJETORESULT WSCLIENT WSNEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSALTPROJETO xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMPRESA", ::c_CEMPRESA, c_CEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODIGO", ::c_CCODIGO, c_CCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPROJETOINT", ::c_CPROJETOINT, c_CPROJETOINT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODVDA", ::c_CCODVDA, c_CCODVDA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODCLI", ::c_CCODCLI, c_CCODCLI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CLOJCLI", ::c_CLOJCLI, c_CLOJCLI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CTIPPRJ", ::c_CTIPPRJ, c_CTIPPRJ , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFASE", ::c_CFASE, c_CFASE , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_COBS", ::c_COBS, c_COBS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDTENTR", ::c_CDTENTR, c_CDTENTR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDTENTRF", ::c_CDTENTRF, c_CDTENTRF , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDTVEND", ::c_CDTVEND, c_CDTVEND , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCONTATO1", ::c_CCONTATO1, c_CCONTATO1 , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</WSALTPROJETO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSALTPROJETO",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWPROJ.apw")

::Init()
::cWSALTPROJETORESULT :=  WSAdvValue( oXmlRet,"_WSALTPROJETORESPONSE:_WSALTPROJETORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSEXCLUIPROJETO of Service WSNEWPROJ

WSMETHOD WSEXCLUIPROJETO WSSEND cKEY,c_CEMPRESA,c_CFILIAL,c_CCODIGO WSRECEIVE cWSEXCLUIPROJETORESULT WSCLIENT WSNEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSEXCLUIPROJETO xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMPRESA", ::c_CEMPRESA, c_CEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODIGO", ::c_CCODIGO, c_CCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</WSEXCLUIPROJETO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSEXCLUIPROJETO",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWPROJ.apw")

::Init()
::cWSEXCLUIPROJETORESULT :=  WSAdvValue( oXmlRet,"_WSEXCLUIPROJETORESPONSE:_WSEXCLUIPROJETORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSINCPROJETO of Service WSNEWPROJ

WSMETHOD WSINCPROJETO WSSEND cKEY,c_CEMPRESA,c_CFILIAL,c_CDESCRICAO,c_CUNINEG,c_CCODVDA,c_CCODSEQ,c_CCODCLI,c_CLOJCLI,c_CTIPPRJ,c_CDTENTR WSRECEIVE cWSINCPROJETORESULT WSCLIENT WSNEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSINCPROJETO xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMPRESA", ::c_CEMPRESA, c_CEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CUNINEG", ::c_CUNINEG, c_CUNINEG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODVDA", ::c_CCODVDA, c_CCODVDA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODSEQ", ::c_CCODSEQ, c_CCODSEQ , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODCLI", ::c_CCODCLI, c_CCODCLI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CLOJCLI", ::c_CLOJCLI, c_CLOJCLI , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CTIPPRJ", ::c_CTIPPRJ, c_CTIPPRJ , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDTENTR", ::c_CDTENTR, c_CDTENTR , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</WSINCPROJETO>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSINCPROJETO",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWPROJ.apw")

::Init()
::cWSINCPROJETORESULT :=  WSAdvValue( oXmlRet,"_WSINCPROJETORESPONSE:_WSINCPROJETORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



