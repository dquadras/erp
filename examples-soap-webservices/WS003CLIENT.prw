#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWTRF.apw?WSDL
Gerado em        07/12/16 10:52:27
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TYVKDXO ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWTRF
------------------------------------------------------------------------------- */

WSCLIENT WSNEWTRF

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD WSALTTAREFA
	WSMETHOD WSEXCTAREFA
	WSMETHOD WSINCTAREFA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   c_CEMP                    AS string
	WSDATA   c_CFILIAL                 AS string
	WSDATA   c_CCODPSP                 AS string
	WSDATA   c_CREVISA                 AS string
	WSDATA   c_CTAREFA                 AS string
	WSDATA   c_CDESCRICAO              AS string
	WSDATA   n_FORCPROJ                AS float
	WSDATA   n_FVENPROJ                AS float
	WSDATA   n_FORCREEM                AS float
	WSDATA   n_FVENREEM                AS float
	WSDATA   n_FMETA                   AS float
	WSDATA   cWSALTTAREFARESULT        AS string
	WSDATA   cWSEXCTAREFARESULT        AS string
	WSDATA   c_CEDTPAI                 AS string
	WSDATA   c_CNIVEL                  AS string
	WSDATA   cWSINCTAREFARESULT        AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWTRF
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWTRF
Return

WSMETHOD RESET WSCLIENT WSNEWTRF
	::cKEY               := NIL 
	::c_CEMP             := NIL 
	::c_CFILIAL          := NIL 
	::c_CCODPSP          := NIL 
	::c_CREVISA          := NIL 
	::c_CTAREFA          := NIL 
	::c_CDESCRICAO       := NIL 
	::n_FORCPROJ         := NIL 
	::n_FVENPROJ         := NIL 
	::n_FORCREEM         := NIL 
	::n_FVENREEM         := NIL 
	::n_FMETA            := NIL 
	::cWSALTTAREFARESULT := NIL 
	::cWSEXCTAREFARESULT := NIL 
	::c_CEDTPAI          := NIL 
	::c_CNIVEL           := NIL 
	::cWSINCTAREFARESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWTRF
Local oClone := WSNEWTRF():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:c_CEMP        := ::c_CEMP
	oClone:c_CFILIAL     := ::c_CFILIAL
	oClone:c_CCODPSP     := ::c_CCODPSP
	oClone:c_CREVISA     := ::c_CREVISA
	oClone:c_CTAREFA     := ::c_CTAREFA
	oClone:c_CDESCRICAO  := ::c_CDESCRICAO
	oClone:n_FORCPROJ    := ::n_FORCPROJ
	oClone:n_FVENPROJ    := ::n_FVENPROJ
	oClone:n_FORCREEM    := ::n_FORCREEM
	oClone:n_FVENREEM    := ::n_FVENREEM
	oClone:n_FMETA       := ::n_FMETA
	oClone:cWSALTTAREFARESULT := ::cWSALTTAREFARESULT
	oClone:cWSEXCTAREFARESULT := ::cWSEXCTAREFARESULT
	oClone:c_CEDTPAI     := ::c_CEDTPAI
	oClone:c_CNIVEL      := ::c_CNIVEL
	oClone:cWSINCTAREFARESULT := ::cWSINCTAREFARESULT
Return oClone

// WSDL Method WSALTTAREFA of Service WSNEWTRF

WSMETHOD WSALTTAREFA WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CREVISA,c_CTAREFA,c_CDESCRICAO,n_FORCPROJ,n_FVENPROJ,n_FORCREEM,n_FVENREEM,n_FMETA WSRECEIVE cWSALTTAREFARESULT WSCLIENT WSNEWTRF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSALTTAREFA xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CTAREFA", ::c_CTAREFA, c_CTAREFA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCPROJ", ::n_FORCPROJ, n_FORCPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENPROJ", ::n_FVENPROJ, n_FVENPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCREEM", ::n_FORCREEM, n_FORCREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENREEM", ::n_FVENREEM, n_FVENREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FMETA", ::n_FMETA, n_FMETA , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += "</WSALTTAREFA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSALTTAREFA",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWTRF.apw")

::Init()
::cWSALTTAREFARESULT :=  WSAdvValue( oXmlRet,"_WSALTTAREFARESPONSE:_WSALTTAREFARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSEXCTAREFA of Service WSNEWTRF

WSMETHOD WSEXCTAREFA WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CREVISA,c_CTAREFA WSRECEIVE cWSEXCTAREFARESULT WSCLIENT WSNEWTRF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSEXCTAREFA xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CTAREFA", ::c_CTAREFA, c_CTAREFA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</WSEXCTAREFA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSEXCTAREFA",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWTRF.apw")

::Init()
::cWSEXCTAREFARESULT :=  WSAdvValue( oXmlRet,"_WSEXCTAREFARESPONSE:_WSEXCTAREFARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSINCTAREFA of Service WSNEWTRF

WSMETHOD WSINCTAREFA WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CTAREFA,c_CDESCRICAO,c_CREVISA,c_CEDTPAI,c_CNIVEL,n_FORCPROJ,n_FVENPROJ,n_FORCREEM,n_FVENREEM,n_FMETA WSRECEIVE cWSINCTAREFARESULT WSCLIENT WSNEWTRF
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSINCTAREFA xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CTAREFA", ::c_CTAREFA, c_CTAREFA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEDTPAI", ::c_CEDTPAI, c_CEDTPAI , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CNIVEL", ::c_CNIVEL, c_CNIVEL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCPROJ", ::n_FORCPROJ, n_FORCPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENPROJ", ::n_FVENPROJ, n_FVENPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCREEM", ::n_FORCREEM, n_FORCREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENREEM", ::n_FVENREEM, n_FVENREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FMETA", ::n_FMETA, n_FMETA , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += "</WSINCTAREFA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSINCTAREFA",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWTRF.apw")

::Init()
::cWSINCTAREFARESULT :=  WSAdvValue( oXmlRet,"_WSINCTAREFARESPONSE:_WSINCTAREFARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.