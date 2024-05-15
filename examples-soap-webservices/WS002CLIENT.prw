#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWEDT.apw?WSDL
Gerado em        07/12/16 10:51:43
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ARMTMNL ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWEDT
------------------------------------------------------------------------------- */

WSCLIENT WSNEWEDT

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD WSALTEDT
	WSMETHOD WSEXCEDT
	WSMETHOD WSINCEDT

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   c_CEMP                    AS string
	WSDATA   c_CFILIAL                 AS string
	WSDATA   c_CCODPSP                 AS string
	WSDATA   c_CDESCRICAO              AS string
	WSDATA   c_CREVISA                 AS string
	WSDATA   c_CEDT                    AS string
	WSDATA   n_FORCPROJ                AS float
	WSDATA   n_FVENPROJ                AS float
	WSDATA   n_FORCREEM                AS float
	WSDATA   n_FVENREEM                AS float
	WSDATA   n_FMETA                   AS float
	WSDATA   cWSALTEDTRESULT           AS string
	WSDATA   cWSEXCEDTRESULT           AS string
	WSDATA   c_CEDTPAI                 AS string
	WSDATA   c_CNIVEL                  AS string
	WSDATA   cWSINCEDTRESULT           AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWEDT
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWEDT
Return

WSMETHOD RESET WSCLIENT WSNEWEDT
	::cKEY               := NIL 
	::c_CEMP             := NIL 
	::c_CFILIAL          := NIL 
	::c_CCODPSP          := NIL 
	::c_CDESCRICAO       := NIL 
	::c_CREVISA          := NIL 
	::c_CEDT             := NIL 
	::n_FORCPROJ         := NIL 
	::n_FVENPROJ         := NIL 
	::n_FORCREEM         := NIL 
	::n_FVENREEM         := NIL 
	::n_FMETA            := NIL 
	::cWSALTEDTRESULT    := NIL 
	::cWSEXCEDTRESULT    := NIL 
	::c_CEDTPAI          := NIL 
	::c_CNIVEL           := NIL 
	::cWSINCEDTRESULT    := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWEDT
Local oClone := WSNEWEDT():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:c_CEMP        := ::c_CEMP
	oClone:c_CFILIAL     := ::c_CFILIAL
	oClone:c_CCODPSP     := ::c_CCODPSP
	oClone:c_CDESCRICAO  := ::c_CDESCRICAO
	oClone:c_CREVISA     := ::c_CREVISA
	oClone:c_CEDT        := ::c_CEDT
	oClone:n_FORCPROJ    := ::n_FORCPROJ
	oClone:n_FVENPROJ    := ::n_FVENPROJ
	oClone:n_FORCREEM    := ::n_FORCREEM
	oClone:n_FVENREEM    := ::n_FVENREEM
	oClone:n_FMETA       := ::n_FMETA
	oClone:cWSALTEDTRESULT := ::cWSALTEDTRESULT
	oClone:cWSEXCEDTRESULT := ::cWSEXCEDTRESULT
	oClone:c_CEDTPAI     := ::c_CEDTPAI
	oClone:c_CNIVEL      := ::c_CNIVEL
	oClone:cWSINCEDTRESULT := ::cWSINCEDTRESULT
Return oClone

// WSDL Method WSALTEDT of Service WSNEWEDT

WSMETHOD WSALTEDT WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CDESCRICAO,c_CREVISA,c_CEDT,n_FORCPROJ,n_FVENPROJ,n_FORCREEM,n_FVENREEM,n_FMETA WSRECEIVE cWSALTEDTRESULT WSCLIENT WSNEWEDT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSALTEDT xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEDT", ::c_CEDT, c_CEDT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCPROJ", ::n_FORCPROJ, n_FORCPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENPROJ", ::n_FVENPROJ, n_FVENPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCREEM", ::n_FORCREEM, n_FORCREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENREEM", ::n_FVENREEM, n_FVENREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FMETA", ::n_FMETA, n_FMETA , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += "</WSALTEDT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSALTEDT",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWEDT.apw")

::Init()
::cWSALTEDTRESULT    :=  WSAdvValue( oXmlRet,"_WSALTEDTRESPONSE:_WSALTEDTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSEXCEDT of Service WSNEWEDT

WSMETHOD WSEXCEDT WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CREVISA,c_CEDT WSRECEIVE cWSEXCEDTRESULT WSCLIENT WSNEWEDT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSEXCEDT xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEDT", ::c_CEDT, c_CEDT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</WSEXCEDT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSEXCEDT",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWEDT.apw")

::Init()
::cWSEXCEDTRESULT    :=  WSAdvValue( oXmlRet,"_WSEXCEDTRESPONSE:_WSEXCEDTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method WSINCEDT of Service WSNEWEDT

WSMETHOD WSINCEDT WSSEND cKEY,c_CEMP,c_CFILIAL,c_CCODPSP,c_CDESCRICAO,c_CREVISA,c_CEDT,c_CEDTPAI,c_CNIVEL,n_FORCPROJ,n_FVENPROJ,n_FORCREEM,n_FVENREEM,n_FMETA WSRECEIVE cWSINCEDTRESULT WSCLIENT WSNEWEDT
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<WSINCEDT xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEMP", ::c_CEMP, c_CEMP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CFILIAL", ::c_CFILIAL, c_CFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CCODPSP", ::c_CCODPSP, c_CCODPSP , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CDESCRICAO", ::c_CDESCRICAO, c_CDESCRICAO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CREVISA", ::c_CREVISA, c_CREVISA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEDT", ::c_CEDT, c_CEDT , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CEDTPAI", ::c_CEDTPAI, c_CEDTPAI , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CNIVEL", ::c_CNIVEL, c_CNIVEL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCPROJ", ::n_FORCPROJ, n_FORCPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENPROJ", ::n_FVENPROJ, n_FVENPROJ , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FORCREEM", ::n_FORCREEM, n_FORCREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FVENREEM", ::n_FVENREEM, n_FVENREEM , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_FMETA", ::n_FMETA, n_FMETA , "float", .F. , .F., 0 , NIL, .F.) 
cSoap += "</WSINCEDT>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/WSINCEDT",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWEDT.apw")

::Init()
::cWSINCEDTRESULT    :=  WSAdvValue( oXmlRet,"_WSINCEDTRESPONSE:_WSINCEDTRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.