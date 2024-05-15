#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWRETINFO.apw?WSDL
Gerado em        07/12/16 10:54:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _CKWZMPJ ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWRETINFO
------------------------------------------------------------------------------- */

WSCLIENT WSNEWRETINFO

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETAREA
	WSMETHOD GETCC
	WSMETHOD GETCLI
	WSMETHOD GETCRG
	WSMETHOD GETLISTAPSP
	WSMETHOD GETLISTAREC
	WSMETHOD GETPED
	WSMETHOD GETPRD
	WSMETHOD GETPSP
	WSMETHOD GETREVISOES
	WSMETHOD GETUM
	WSMETHOD GETUN

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cFILIAL                   AS string
	WSDATA   c_CPESQUISA               AS string
	WSDATA   c_CMSG                    AS string
	WSDATA   oWSGETAREARESULT          AS NEWRETINFO_AITENSAREA
	WSDATA   oWSGETCCRESULT            AS NEWRETINFO_AITENSCC
	WSDATA   oWSGETCLIRESULT           AS NEWRETINFO_AITENSCLI
	WSDATA   oWSGETCRGRESULT           AS NEWRETINFO_AITENSCRG
	WSDATA   oWSGETLISTAPSPRESULT      AS NEWRETINFO_AITENS2PSP
	WSDATA   c_CUNIDADE                AS string
	WSDATA   oWSGETLISTARECRESULT      AS NEWRETINFO_AITENSREC
	WSDATA   cCPROJETO                 AS string
	WSDATA   cCTAREFA                  AS string
	WSDATA   lGETPEDRESULT             AS boolean
	WSDATA   oWSGETPRDRESULT           AS NEWRETINFO_AITENSPRD
	WSDATA   oWSGETPSPRESULT           AS NEWRETINFO_AITENSPSP
	WSDATA   oWSGETREVISOESRESULT      AS NEWRETINFO_AITENSREV
	WSDATA   oWSGETUMRESULT            AS NEWRETINFO_AITENSUM
	WSDATA   oWSGETUNRESULT            AS NEWRETINFO_AITENSUN

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWRETINFO
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWRETINFO
	::oWSGETAREARESULT   := NEWRETINFO_AITENSAREA():New()
	::oWSGETCCRESULT     := NEWRETINFO_AITENSCC():New()
	::oWSGETCLIRESULT    := NEWRETINFO_AITENSCLI():New()
	::oWSGETCRGRESULT    := NEWRETINFO_AITENSCRG():New()
	::oWSGETLISTAPSPRESULT := NEWRETINFO_AITENS2PSP():New()
	::oWSGETLISTARECRESULT := NEWRETINFO_AITENSREC():New()
	::oWSGETPRDRESULT    := NEWRETINFO_AITENSPRD():New()
	::oWSGETPSPRESULT    := NEWRETINFO_AITENSPSP():New()
	::oWSGETREVISOESRESULT := NEWRETINFO_AITENSREV():New()
	::oWSGETUMRESULT     := NEWRETINFO_AITENSUM():New()
	::oWSGETUNRESULT     := NEWRETINFO_AITENSUN():New()
Return

WSMETHOD RESET WSCLIENT WSNEWRETINFO
	::cKEY               := NIL 
	::cEMPRESA           := NIL 
	::cFILIAL            := NIL 
	::c_CPESQUISA        := NIL 
	::c_CMSG             := NIL 
	::oWSGETAREARESULT   := NIL 
	::oWSGETCCRESULT     := NIL 
	::oWSGETCLIRESULT    := NIL 
	::oWSGETCRGRESULT    := NIL 
	::oWSGETLISTAPSPRESULT := NIL 
	::c_CUNIDADE         := NIL 
	::oWSGETLISTARECRESULT := NIL 
	::cCPROJETO          := NIL 
	::cCTAREFA           := NIL 
	::lGETPEDRESULT      := NIL 
	::oWSGETPRDRESULT    := NIL 
	::oWSGETPSPRESULT    := NIL 
	::oWSGETREVISOESRESULT := NIL 
	::oWSGETUMRESULT     := NIL 
	::oWSGETUNRESULT     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWRETINFO
Local oClone := WSNEWRETINFO():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:cEMPRESA      := ::cEMPRESA
	oClone:cFILIAL       := ::cFILIAL
	oClone:c_CPESQUISA   := ::c_CPESQUISA
	oClone:c_CMSG        := ::c_CMSG
	oClone:oWSGETAREARESULT :=  IIF(::oWSGETAREARESULT = NIL , NIL ,::oWSGETAREARESULT:Clone() )
	oClone:oWSGETCCRESULT :=  IIF(::oWSGETCCRESULT = NIL , NIL ,::oWSGETCCRESULT:Clone() )
	oClone:oWSGETCLIRESULT :=  IIF(::oWSGETCLIRESULT = NIL , NIL ,::oWSGETCLIRESULT:Clone() )
	oClone:oWSGETCRGRESULT :=  IIF(::oWSGETCRGRESULT = NIL , NIL ,::oWSGETCRGRESULT:Clone() )
	oClone:oWSGETLISTAPSPRESULT :=  IIF(::oWSGETLISTAPSPRESULT = NIL , NIL ,::oWSGETLISTAPSPRESULT:Clone() )
	oClone:c_CUNIDADE    := ::c_CUNIDADE
	oClone:oWSGETLISTARECRESULT :=  IIF(::oWSGETLISTARECRESULT = NIL , NIL ,::oWSGETLISTARECRESULT:Clone() )
	oClone:cCPROJETO     := ::cCPROJETO
	oClone:cCTAREFA      := ::cCTAREFA
	oClone:lGETPEDRESULT := ::lGETPEDRESULT
	oClone:oWSGETPRDRESULT :=  IIF(::oWSGETPRDRESULT = NIL , NIL ,::oWSGETPRDRESULT:Clone() )
	oClone:oWSGETPSPRESULT :=  IIF(::oWSGETPSPRESULT = NIL , NIL ,::oWSGETPSPRESULT:Clone() )
	oClone:oWSGETREVISOESRESULT :=  IIF(::oWSGETREVISOESRESULT = NIL , NIL ,::oWSGETREVISOESRESULT:Clone() )
	oClone:oWSGETUMRESULT :=  IIF(::oWSGETUMRESULT = NIL , NIL ,::oWSGETUMRESULT:Clone() )
	oClone:oWSGETUNRESULT :=  IIF(::oWSGETUNRESULT = NIL , NIL ,::oWSGETUNRESULT:Clone() )
Return oClone

// WSDL Method GETAREA of Service WSNEWRETINFO

WSMETHOD GETAREA WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETAREARESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETAREA xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETAREA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETAREA",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETAREARESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETAREARESPONSE:_GETAREARESULT","AITENSAREA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCC of Service WSNEWRETINFO

WSMETHOD GETCC WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETCCRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCC xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETCC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETCC",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETCCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCCRESPONSE:_GETCCRESULT","AITENSCC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCLI of Service WSNEWRETINFO

WSMETHOD GETCLI WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETCLIRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCLI xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETCLI>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETCLI",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETCLIRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCLIRESPONSE:_GETCLIRESULT","AITENSCLI",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETCRG of Service WSNEWRETINFO

WSMETHOD GETCRG WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETCRGRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETCRG xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETCRG>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETCRG",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETCRGRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETCRGRESPONSE:_GETCRGRESULT","AITENSCRG",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETLISTAPSP of Service WSNEWRETINFO

WSMETHOD GETLISTAPSP WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETLISTAPSPRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLISTAPSP xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETLISTAPSP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETLISTAPSP",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETLISTAPSPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETLISTAPSPRESPONSE:_GETLISTAPSPRESULT","AITENS2PSP",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETLISTAREC of Service WSNEWRETINFO

WSMETHOD GETLISTAREC WSSEND cKEY,cEMPRESA,cFILIAL,c_CUNIDADE,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETLISTARECRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETLISTAREC xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CUNIDADE", ::c_CUNIDADE, c_CUNIDADE , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETLISTAREC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETLISTAREC",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETLISTARECRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETLISTARECRESPONSE:_GETLISTARECRESULT","AITENSREC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPED of Service WSNEWRETINFO

WSMETHOD GETPED WSSEND cKEY,cEMPRESA,cFILIAL,cCPROJETO,cCTAREFA,c_CMSG WSRECEIVE lGETPEDRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPED xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CPROJETO", ::cCPROJETO, cCPROJETO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CTAREFA", ::cCTAREFA, cCTAREFA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETPED>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETPED",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::lGETPEDRESULT      :=  WSAdvValue( oXmlRet,"_GETPEDRESPONSE:_GETPEDRESULT:TEXT","boolean",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPRD of Service WSNEWRETINFO

WSMETHOD GETPRD WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETPRDRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPRD xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETPRD>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETPRD",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETPRDRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPRDRESPONSE:_GETPRDRESULT","AITENSPRD",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETPSP of Service WSNEWRETINFO

WSMETHOD GETPSP WSSEND cKEY,cEMPRESA,cFILIAL,c_CPESQUISA,c_CMSG WSRECEIVE oWSGETPSPRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETPSP xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CPESQUISA", ::c_CPESQUISA, c_CPESQUISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETPSP>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETPSP",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETPSPRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETPSPRESPONSE:_GETPSPRESULT","AITENSPSP",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETREVISOES of Service WSNEWRETINFO

WSMETHOD GETREVISOES WSSEND cKEY,cEMPRESA,cCPROJETO,c_CMSG WSRECEIVE oWSGETREVISOESRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETREVISOES xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CPROJETO", ::cCPROJETO, cCPROJETO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETREVISOES>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETREVISOES",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETREVISOESRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETREVISOESRESPONSE:_GETREVISOESRESULT","AITENSREV",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETUM of Service WSNEWRETINFO

WSMETHOD GETUM WSSEND cKEY,cEMPRESA,cFILIAL,c_CMSG WSRECEIVE oWSGETUMRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETUM xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETUM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETUM",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETUMRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETUMRESPONSE:_GETUMRESULT","AITENSUM",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETUN of Service WSNEWRETINFO

WSMETHOD GETUN WSSEND cKEY,cEMPRESA,cFILIAL,c_CMSG WSRECEIVE oWSGETUNRESULT WSCLIENT WSNEWRETINFO
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETUN xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETUN>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETUN",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWRETINFO.apw")

::Init()
::oWSGETUNRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETUNRESPONSE:_GETUNRESULT","AITENSUN",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AITENSAREA

WSSTRUCT NEWRETINFO_AITENSAREA
	WSDATA   oWSITENSAREA              AS NEWRETINFO_ARRAYOFALISTITENSAREA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSAREA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSAREA
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSAREA
	Local oClone := NEWRETINFO_AITENSAREA():NEW()
	oClone:oWSITENSAREA         := IIF(::oWSITENSAREA = NIL , NIL , ::oWSITENSAREA:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSAREA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSAREA","ARRAYOFALISTITENSAREA",NIL,"Property oWSITENSAREA as s0:ARRAYOFALISTITENSAREA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSAREA := NEWRETINFO_ARRAYOFALISTITENSAREA():New()
		::oWSITENSAREA:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSCC

WSSTRUCT NEWRETINFO_AITENSCC
	WSDATA   oWSITENSCC                AS NEWRETINFO_ARRAYOFALISTITENSCC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSCC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSCC
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSCC
	Local oClone := NEWRETINFO_AITENSCC():NEW()
	oClone:oWSITENSCC           := IIF(::oWSITENSCC = NIL , NIL , ::oWSITENSCC:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSCC
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSCC","ARRAYOFALISTITENSCC",NIL,"Property oWSITENSCC as s0:ARRAYOFALISTITENSCC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSCC := NEWRETINFO_ARRAYOFALISTITENSCC():New()
		::oWSITENSCC:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSCLI

WSSTRUCT NEWRETINFO_AITENSCLI
	WSDATA   oWSITENSCLI               AS NEWRETINFO_ARRAYOFALISTITENSCLI
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSCLI
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSCLI
	Local oClone := NEWRETINFO_AITENSCLI():NEW()
	oClone:oWSITENSCLI          := IIF(::oWSITENSCLI = NIL , NIL , ::oWSITENSCLI:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSCLI
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSCLI","ARRAYOFALISTITENSCLI",NIL,"Property oWSITENSCLI as s0:ARRAYOFALISTITENSCLI on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSCLI := NEWRETINFO_ARRAYOFALISTITENSCLI():New()
		::oWSITENSCLI:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSCRG

WSSTRUCT NEWRETINFO_AITENSCRG
	WSDATA   oWSITENSCRG               AS NEWRETINFO_ARRAYOFALISTITENSCRG
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSCRG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSCRG
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSCRG
	Local oClone := NEWRETINFO_AITENSCRG():NEW()
	oClone:oWSITENSCRG          := IIF(::oWSITENSCRG = NIL , NIL , ::oWSITENSCRG:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSCRG
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSCRG","ARRAYOFALISTITENSCRG",NIL,"Property oWSITENSCRG as s0:ARRAYOFALISTITENSCRG on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSCRG := NEWRETINFO_ARRAYOFALISTITENSCRG():New()
		::oWSITENSCRG:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENS2PSP

WSSTRUCT NEWRETINFO_AITENS2PSP
	WSDATA   oWSITENS2PSP              AS NEWRETINFO_ARRAYOFALISTITENS2PSP
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENS2PSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENS2PSP
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENS2PSP
	Local oClone := NEWRETINFO_AITENS2PSP():NEW()
	oClone:oWSITENS2PSP         := IIF(::oWSITENS2PSP = NIL , NIL , ::oWSITENS2PSP:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENS2PSP
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS2PSP","ARRAYOFALISTITENS2PSP",NIL,"Property oWSITENS2PSP as s0:ARRAYOFALISTITENS2PSP on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS2PSP := NEWRETINFO_ARRAYOFALISTITENS2PSP():New()
		::oWSITENS2PSP:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSREC

WSSTRUCT NEWRETINFO_AITENSREC
	WSDATA   oWSITENSREC               AS NEWRETINFO_ARRAYOFALISTITENSREC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSREC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSREC
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSREC
	Local oClone := NEWRETINFO_AITENSREC():NEW()
	oClone:oWSITENSREC          := IIF(::oWSITENSREC = NIL , NIL , ::oWSITENSREC:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSREC
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSREC","ARRAYOFALISTITENSREC",NIL,"Property oWSITENSREC as s0:ARRAYOFALISTITENSREC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSREC := NEWRETINFO_ARRAYOFALISTITENSREC():New()
		::oWSITENSREC:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSPRD

WSSTRUCT NEWRETINFO_AITENSPRD
	WSDATA   oWSITENSPRD               AS NEWRETINFO_ARRAYOFALISTITENSPRD
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSPRD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSPRD
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSPRD
	Local oClone := NEWRETINFO_AITENSPRD():NEW()
	oClone:oWSITENSPRD          := IIF(::oWSITENSPRD = NIL , NIL , ::oWSITENSPRD:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSPRD
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSPRD","ARRAYOFALISTITENSPRD",NIL,"Property oWSITENSPRD as s0:ARRAYOFALISTITENSPRD on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSPRD := NEWRETINFO_ARRAYOFALISTITENSPRD():New()
		::oWSITENSPRD:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSPSP

WSSTRUCT NEWRETINFO_AITENSPSP
	WSDATA   oWSITENSPSP               AS NEWRETINFO_ARRAYOFALISTITENSPSP
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSPSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSPSP
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSPSP
	Local oClone := NEWRETINFO_AITENSPSP():NEW()
	oClone:oWSITENSPSP          := IIF(::oWSITENSPSP = NIL , NIL , ::oWSITENSPSP:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSPSP
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSPSP","ARRAYOFALISTITENSPSP",NIL,"Property oWSITENSPSP as s0:ARRAYOFALISTITENSPSP on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSPSP := NEWRETINFO_ARRAYOFALISTITENSPSP():New()
		::oWSITENSPSP:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSREV

WSSTRUCT NEWRETINFO_AITENSREV
	WSDATA   oWSITENSREV               AS NEWRETINFO_ARRAYOFALISTITENSREV
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSREV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSREV
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSREV
	Local oClone := NEWRETINFO_AITENSREV():NEW()
	oClone:oWSITENSREV          := IIF(::oWSITENSREV = NIL , NIL , ::oWSITENSREV:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSREV
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSREV","ARRAYOFALISTITENSREV",NIL,"Property oWSITENSREV as s0:ARRAYOFALISTITENSREV on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSREV := NEWRETINFO_ARRAYOFALISTITENSREV():New()
		::oWSITENSREV:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSUM

WSSTRUCT NEWRETINFO_AITENSUM
	WSDATA   oWSITENSUM                AS NEWRETINFO_ARRAYOFALISTITENSUM
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSUM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSUM
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSUM
	Local oClone := NEWRETINFO_AITENSUM():NEW()
	oClone:oWSITENSUM           := IIF(::oWSITENSUM = NIL , NIL , ::oWSITENSUM:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSUM
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSUM","ARRAYOFALISTITENSUM",NIL,"Property oWSITENSUM as s0:ARRAYOFALISTITENSUM on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSUM := NEWRETINFO_ARRAYOFALISTITENSUM():New()
		::oWSITENSUM:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSUN

WSSTRUCT NEWRETINFO_AITENSUN
	WSDATA   oWSITENSUN                AS NEWRETINFO_ARRAYOFALISTITENSUN
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_AITENSUN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_AITENSUN
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_AITENSUN
	Local oClone := NEWRETINFO_AITENSUN():NEW()
	oClone:oWSITENSUN           := IIF(::oWSITENSUN = NIL , NIL , ::oWSITENSUN:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_AITENSUN
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSUN","ARRAYOFALISTITENSUN",NIL,"Property oWSITENSUN as s0:ARRAYOFALISTITENSUN on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSUN := NEWRETINFO_ARRAYOFALISTITENSUN():New()
		::oWSITENSUN:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFALISTITENSAREA

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSAREA
	WSDATA   oWSALISTITENSAREA         AS NEWRETINFO_ALISTITENSAREA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSAREA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSAREA
	::oWSALISTITENSAREA    := {} // Array Of  NEWRETINFO_ALISTITENSAREA():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSAREA
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSAREA():NEW()
	oClone:oWSALISTITENSAREA := NIL
	If ::oWSALISTITENSAREA <> NIL 
		oClone:oWSALISTITENSAREA := {}
		aEval( ::oWSALISTITENSAREA , { |x| aadd( oClone:oWSALISTITENSAREA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSAREA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSAREA","ALISTITENSAREA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSAREA , NEWRETINFO_ALISTITENSAREA():New() )
			::oWSALISTITENSAREA[len(::oWSALISTITENSAREA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSCC

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSCC
	WSDATA   oWSALISTITENSCC           AS NEWRETINFO_ALISTITENSCC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCC
	::oWSALISTITENSCC      := {} // Array Of  NEWRETINFO_ALISTITENSCC():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCC
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSCC():NEW()
	oClone:oWSALISTITENSCC := NIL
	If ::oWSALISTITENSCC <> NIL 
		oClone:oWSALISTITENSCC := {}
		aEval( ::oWSALISTITENSCC , { |x| aadd( oClone:oWSALISTITENSCC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSCC","ALISTITENSCC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSCC , NEWRETINFO_ALISTITENSCC():New() )
			::oWSALISTITENSCC[len(::oWSALISTITENSCC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSCLI

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSCLI
	WSDATA   oWSALISTITENSCLI          AS NEWRETINFO_ALISTITENSCLI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCLI
	::oWSALISTITENSCLI     := {} // Array Of  NEWRETINFO_ALISTITENSCLI():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCLI
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSCLI():NEW()
	oClone:oWSALISTITENSCLI := NIL
	If ::oWSALISTITENSCLI <> NIL 
		oClone:oWSALISTITENSCLI := {}
		aEval( ::oWSALISTITENSCLI , { |x| aadd( oClone:oWSALISTITENSCLI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCLI
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSCLI","ALISTITENSCLI",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSCLI , NEWRETINFO_ALISTITENSCLI():New() )
			::oWSALISTITENSCLI[len(::oWSALISTITENSCLI)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSCRG

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSCRG
	WSDATA   oWSALISTITENSCRG          AS NEWRETINFO_ALISTITENSCRG OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCRG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCRG
	::oWSALISTITENSCRG     := {} // Array Of  NEWRETINFO_ALISTITENSCRG():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCRG
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSCRG():NEW()
	oClone:oWSALISTITENSCRG := NIL
	If ::oWSALISTITENSCRG <> NIL 
		oClone:oWSALISTITENSCRG := {}
		aEval( ::oWSALISTITENSCRG , { |x| aadd( oClone:oWSALISTITENSCRG , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSCRG
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSCRG","ALISTITENSCRG",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSCRG , NEWRETINFO_ALISTITENSCRG():New() )
			::oWSALISTITENSCRG[len(::oWSALISTITENSCRG)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENS2PSP

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENS2PSP
	WSDATA   oWSALISTITENS2PSP         AS NEWRETINFO_ALISTITENS2PSP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENS2PSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENS2PSP
	::oWSALISTITENS2PSP    := {} // Array Of  NEWRETINFO_ALISTITENS2PSP():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENS2PSP
	Local oClone := NEWRETINFO_ARRAYOFALISTITENS2PSP():NEW()
	oClone:oWSALISTITENS2PSP := NIL
	If ::oWSALISTITENS2PSP <> NIL 
		oClone:oWSALISTITENS2PSP := {}
		aEval( ::oWSALISTITENS2PSP , { |x| aadd( oClone:oWSALISTITENS2PSP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENS2PSP
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENS2PSP","ALISTITENS2PSP",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENS2PSP , NEWRETINFO_ALISTITENS2PSP():New() )
			::oWSALISTITENS2PSP[len(::oWSALISTITENS2PSP)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSREC

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSREC
	WSDATA   oWSALISTITENSREC          AS NEWRETINFO_ALISTITENSREC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREC
	::oWSALISTITENSREC     := {} // Array Of  NEWRETINFO_ALISTITENSREC():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREC
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSREC():NEW()
	oClone:oWSALISTITENSREC := NIL
	If ::oWSALISTITENSREC <> NIL 
		oClone:oWSALISTITENSREC := {}
		aEval( ::oWSALISTITENSREC , { |x| aadd( oClone:oWSALISTITENSREC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSREC","ALISTITENSREC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSREC , NEWRETINFO_ALISTITENSREC():New() )
			::oWSALISTITENSREC[len(::oWSALISTITENSREC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSPRD

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSPRD
	WSDATA   oWSALISTITENSPRD          AS NEWRETINFO_ALISTITENSPRD OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPRD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPRD
	::oWSALISTITENSPRD     := {} // Array Of  NEWRETINFO_ALISTITENSPRD():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPRD
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSPRD():NEW()
	oClone:oWSALISTITENSPRD := NIL
	If ::oWSALISTITENSPRD <> NIL 
		oClone:oWSALISTITENSPRD := {}
		aEval( ::oWSALISTITENSPRD , { |x| aadd( oClone:oWSALISTITENSPRD , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPRD
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSPRD","ALISTITENSPRD",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSPRD , NEWRETINFO_ALISTITENSPRD():New() )
			::oWSALISTITENSPRD[len(::oWSALISTITENSPRD)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSPSP

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSPSP
	WSDATA   oWSALISTITENSPSP          AS NEWRETINFO_ALISTITENSPSP OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPSP
	::oWSALISTITENSPSP     := {} // Array Of  NEWRETINFO_ALISTITENSPSP():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPSP
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSPSP():NEW()
	oClone:oWSALISTITENSPSP := NIL
	If ::oWSALISTITENSPSP <> NIL 
		oClone:oWSALISTITENSPSP := {}
		aEval( ::oWSALISTITENSPSP , { |x| aadd( oClone:oWSALISTITENSPSP , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSPSP
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSPSP","ALISTITENSPSP",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSPSP , NEWRETINFO_ALISTITENSPSP():New() )
			::oWSALISTITENSPSP[len(::oWSALISTITENSPSP)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSREV

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSREV
	WSDATA   oWSALISTITENSREV          AS NEWRETINFO_ALISTITENSREV OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREV
	::oWSALISTITENSREV     := {} // Array Of  NEWRETINFO_ALISTITENSREV():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREV
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSREV():NEW()
	oClone:oWSALISTITENSREV := NIL
	If ::oWSALISTITENSREV <> NIL 
		oClone:oWSALISTITENSREV := {}
		aEval( ::oWSALISTITENSREV , { |x| aadd( oClone:oWSALISTITENSREV , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSREV
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSREV","ALISTITENSREV",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSREV , NEWRETINFO_ALISTITENSREV():New() )
			::oWSALISTITENSREV[len(::oWSALISTITENSREV)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSUM

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSUM
	WSDATA   oWSALISTITENSUM           AS NEWRETINFO_ALISTITENSUM OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUM
	::oWSALISTITENSUM      := {} // Array Of  NEWRETINFO_ALISTITENSUM():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUM
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSUM():NEW()
	oClone:oWSALISTITENSUM := NIL
	If ::oWSALISTITENSUM <> NIL 
		oClone:oWSALISTITENSUM := {}
		aEval( ::oWSALISTITENSUM , { |x| aadd( oClone:oWSALISTITENSUM , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUM
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSUM","ALISTITENSUM",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSUM , NEWRETINFO_ALISTITENSUM():New() )
			::oWSALISTITENSUM[len(::oWSALISTITENSUM)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSUN

WSSTRUCT NEWRETINFO_ARRAYOFALISTITENSUN
	WSDATA   oWSALISTITENSUN           AS NEWRETINFO_ALISTITENSUN OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUN
	::oWSALISTITENSUN      := {} // Array Of  NEWRETINFO_ALISTITENSUN():New()
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUN
	Local oClone := NEWRETINFO_ARRAYOFALISTITENSUN():NEW()
	oClone:oWSALISTITENSUN := NIL
	If ::oWSALISTITENSUN <> NIL 
		oClone:oWSALISTITENSUN := {}
		aEval( ::oWSALISTITENSUN , { |x| aadd( oClone:oWSALISTITENSUN , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ARRAYOFALISTITENSUN
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSUN","ALISTITENSUN",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSUN , NEWRETINFO_ALISTITENSUN():New() )
			::oWSALISTITENSUN[len(::oWSALISTITENSUN)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALISTITENSAREA

WSSTRUCT NEWRETINFO_ALISTITENSAREA
	WSDATA   cCODEQUIPE                AS string OPTIONAL
	WSDATA   cDESCAREA                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSAREA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSAREA
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSAREA
	Local oClone := NEWRETINFO_ALISTITENSAREA():NEW()
	oClone:cCODEQUIPE           := ::cCODEQUIPE
	oClone:cDESCAREA            := ::cDESCAREA
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSAREA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODEQUIPE         :=  WSAdvValue( oResponse,"_CODEQUIPE","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCAREA          :=  WSAdvValue( oResponse,"_DESCAREA","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSCC

WSSTRUCT NEWRETINFO_ALISTITENSCC
	WSDATA   cCODIGOCC                 AS string OPTIONAL
	WSDATA   cDESCCC                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSCC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSCC
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSCC
	Local oClone := NEWRETINFO_ALISTITENSCC():NEW()
	oClone:cCODIGOCC            := ::cCODIGOCC
	oClone:cDESCCC              := ::cDESCCC
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSCC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOCC          :=  WSAdvValue( oResponse,"_CODIGOCC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCCC            :=  WSAdvValue( oResponse,"_DESCCC","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSCLI

WSSTRUCT NEWRETINFO_ALISTITENSCLI
	WSDATA   cCODIGOCLI                AS string OPTIONAL
	WSDATA   cDESCCLI                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSCLI
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSCLI
	Local oClone := NEWRETINFO_ALISTITENSCLI():NEW()
	oClone:cCODIGOCLI           := ::cCODIGOCLI
	oClone:cDESCCLI             := ::cDESCCLI
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSCLI
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOCLI         :=  WSAdvValue( oResponse,"_CODIGOCLI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCCLI           :=  WSAdvValue( oResponse,"_DESCCLI","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSCRG

WSSTRUCT NEWRETINFO_ALISTITENSCRG
	WSDATA   cCODIGOCRG                AS string OPTIONAL
	WSDATA   cDESCCRG                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSCRG
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSCRG
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSCRG
	Local oClone := NEWRETINFO_ALISTITENSCRG():NEW()
	oClone:cCODIGOCRG           := ::cCODIGOCRG
	oClone:cDESCCRG             := ::cDESCCRG
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSCRG
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOCRG         :=  WSAdvValue( oResponse,"_CODIGOCRG","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCCRG           :=  WSAdvValue( oResponse,"_DESCCRG","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENS2PSP

WSSTRUCT NEWRETINFO_ALISTITENS2PSP
	WSDATA   cCODIGOPSP                AS string OPTIONAL
	WSDATA   cDESCPSP                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENS2PSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENS2PSP
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENS2PSP
	Local oClone := NEWRETINFO_ALISTITENS2PSP():NEW()
	oClone:cCODIGOPSP           := ::cCODIGOPSP
	oClone:cDESCPSP             := ::cDESCPSP
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENS2PSP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOPSP         :=  WSAdvValue( oResponse,"_CODIGOPSP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCPSP           :=  WSAdvValue( oResponse,"_DESCPSP","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSREC

WSSTRUCT NEWRETINFO_ALISTITENSREC
	WSDATA   cCODIGOREC                AS string OPTIONAL
	WSDATA   cDESCREC                  AS string OPTIONAL
	WSDATA   nVALOR                    AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSREC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSREC
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSREC
	Local oClone := NEWRETINFO_ALISTITENSREC():NEW()
	oClone:cCODIGOREC           := ::cCODIGOREC
	oClone:cDESCREC             := ::cDESCREC
	oClone:nVALOR               := ::nVALOR
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSREC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOREC         :=  WSAdvValue( oResponse,"_CODIGOREC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCREC           :=  WSAdvValue( oResponse,"_DESCREC","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nVALOR             :=  WSAdvValue( oResponse,"_VALOR","float",NIL,NIL,NIL,"N",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSPRD

WSSTRUCT NEWRETINFO_ALISTITENSPRD
	WSDATA   cCODIGOPRD                AS string OPTIONAL
	WSDATA   cDESCPRD                  AS string OPTIONAL
	WSDATA   cGRUPOPRD                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSPRD
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSPRD
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSPRD
	Local oClone := NEWRETINFO_ALISTITENSPRD():NEW()
	oClone:cCODIGOPRD           := ::cCODIGOPRD
	oClone:cDESCPRD             := ::cDESCPRD
	oClone:cGRUPOPRD            := ::cGRUPOPRD
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSPRD
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOPRD         :=  WSAdvValue( oResponse,"_CODIGOPRD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCPRD           :=  WSAdvValue( oResponse,"_DESCPRD","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cGRUPOPRD          :=  WSAdvValue( oResponse,"_GRUPOPRD","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSPSP

WSSTRUCT NEWRETINFO_ALISTITENSPSP
	WSDATA   cCODIGOPSP                AS string OPTIONAL
	WSDATA   cDESCPSP                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSPSP
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSPSP
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSPSP
	Local oClone := NEWRETINFO_ALISTITENSPSP():NEW()
	oClone:cCODIGOPSP           := ::cCODIGOPSP
	oClone:cDESCPSP             := ::cDESCPSP
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSPSP
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOPSP         :=  WSAdvValue( oResponse,"_CODIGOPSP","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCPSP           :=  WSAdvValue( oResponse,"_DESCPSP","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSREV

WSSTRUCT NEWRETINFO_ALISTITENSREV
	WSDATA   cREVISAO                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSREV
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSREV
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSREV
	Local oClone := NEWRETINFO_ALISTITENSREV():NEW()
	oClone:cREVISAO             := ::cREVISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSREV
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cREVISAO           :=  WSAdvValue( oResponse,"_REVISAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSUM

WSSTRUCT NEWRETINFO_ALISTITENSUM
	WSDATA   cCODIGOUM                 AS string OPTIONAL
	WSDATA   cDESCUM                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSUM
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSUM
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSUM
	Local oClone := NEWRETINFO_ALISTITENSUM():NEW()
	oClone:cCODIGOUM            := ::cCODIGOUM
	oClone:cDESCUM              := ::cDESCUM
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSUM
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOUM          :=  WSAdvValue( oResponse,"_CODIGOUM","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCUM            :=  WSAdvValue( oResponse,"_DESCUM","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSUN

WSSTRUCT NEWRETINFO_ALISTITENSUN
	WSDATA   cCODIGOUN                 AS string OPTIONAL
	WSDATA   cDESCUN                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWRETINFO_ALISTITENSUN
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWRETINFO_ALISTITENSUN
Return

WSMETHOD CLONE WSCLIENT NEWRETINFO_ALISTITENSUN
	Local oClone := NEWRETINFO_ALISTITENSUN():NEW()
	oClone:cCODIGOUN            := ::cCODIGOUN
	oClone:cDESCUN              := ::cDESCUN
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWRETINFO_ALISTITENSUN
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cCODIGOUN          :=  WSAdvValue( oResponse,"_CODIGOUN","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCUN            :=  WSAdvValue( oResponse,"_DESCUN","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return