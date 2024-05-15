#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWREVIEWPROJ.apw?WSDL
Gerado em        07/12/16 10:53:27
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _JRNHZAU ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWREVIEWPROJ
------------------------------------------------------------------------------- */

WSCLIENT WSNEWREVIEWPROJ

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETREVIEWPROJ
	WSMETHOD GETSTRUCTPROJ
	WSMETHOD SETPROJ

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cPROJETO                  AS string
	WSDATA   c_CMSG                    AS string
	WSDATA   oWSGETREVIEWPROJRESULT    AS NEWREVIEWPROJ_AITENSREVISAO
	WSDATA   cFILIAL                   AS string
	WSDATA   cREVISAO                  AS string
	WSDATA   oWSGETSTRUCTPROJRESULT    AS NEWREVIEWPROJ_AITENS
	WSDATA   cGERAREVISAO              AS string
	WSDATA   cUSERNAME                 AS string
	WSDATA   oWSLISTITENS              AS NEWREVIEWPROJ_AITENS
	WSDATA   cSETPROJRESULT            AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSAITENS                 AS NEWREVIEWPROJ_AITENS

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWREVIEWPROJ
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWREVIEWPROJ
	::oWSGETREVIEWPROJRESULT := NEWREVIEWPROJ_AITENSREVISAO():New()
	::oWSGETSTRUCTPROJRESULT := NEWREVIEWPROJ_AITENS():New()
	::oWSLISTITENS       := NEWREVIEWPROJ_AITENS():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSAITENS          := ::oWSLISTITENS
Return

WSMETHOD RESET WSCLIENT WSNEWREVIEWPROJ
	::cKEY               := NIL 
	::cEMPRESA           := NIL 
	::cPROJETO           := NIL 
	::c_CMSG             := NIL 
	::oWSGETREVIEWPROJRESULT := NIL 
	::cFILIAL            := NIL 
	::cREVISAO           := NIL 
	::oWSGETSTRUCTPROJRESULT := NIL 
	::cGERAREVISAO       := NIL 
	::cUSERNAME          := NIL 
	::oWSLISTITENS       := NIL 
	::cSETPROJRESULT     := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSAITENS          := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWREVIEWPROJ
Local oClone := WSNEWREVIEWPROJ():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:cEMPRESA      := ::cEMPRESA
	oClone:cPROJETO      := ::cPROJETO
	oClone:c_CMSG        := ::c_CMSG
	oClone:oWSGETREVIEWPROJRESULT :=  IIF(::oWSGETREVIEWPROJRESULT = NIL , NIL ,::oWSGETREVIEWPROJRESULT:Clone() )
	oClone:cFILIAL       := ::cFILIAL
	oClone:cREVISAO      := ::cREVISAO
	oClone:oWSGETSTRUCTPROJRESULT :=  IIF(::oWSGETSTRUCTPROJRESULT = NIL , NIL ,::oWSGETSTRUCTPROJRESULT:Clone() )
	oClone:cGERAREVISAO  := ::cGERAREVISAO
	oClone:cUSERNAME     := ::cUSERNAME
	oClone:oWSLISTITENS  :=  IIF(::oWSLISTITENS = NIL , NIL ,::oWSLISTITENS:Clone() )
	oClone:cSETPROJRESULT := ::cSETPROJRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSAITENS     := oClone:oWSLISTITENS
Return oClone

// WSDL Method GETREVIEWPROJ of Service WSNEWREVIEWPROJ

WSMETHOD GETREVIEWPROJ WSSEND cKEY,cEMPRESA,cPROJETO,c_CMSG WSRECEIVE oWSGETREVIEWPROJRESULT WSCLIENT WSNEWREVIEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETREVIEWPROJ xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PROJETO", ::cPROJETO, cPROJETO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETREVIEWPROJ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETREVIEWPROJ",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWREVIEWPROJ.apw")

::Init()
::oWSGETREVIEWPROJRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETREVIEWPROJRESPONSE:_GETREVIEWPROJRESULT","AITENSREVISAO",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSTRUCTPROJ of Service WSNEWREVIEWPROJ

WSMETHOD GETSTRUCTPROJ WSSEND cKEY,cEMPRESA,cFILIAL,cPROJETO,cREVISAO WSRECEIVE oWSGETSTRUCTPROJRESULT WSCLIENT WSNEWREVIEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSTRUCTPROJ xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PROJETO", ::cPROJETO, cPROJETO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REVISAO", ::cREVISAO, cREVISAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</GETSTRUCTPROJ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETSTRUCTPROJ",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWREVIEWPROJ.apw")

::Init()
::oWSGETSTRUCTPROJRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSTRUCTPROJRESPONSE:_GETSTRUCTPROJRESULT","AITENS",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETPROJ of Service WSNEWREVIEWPROJ

WSMETHOD SETPROJ WSSEND cKEY,cEMPRESA,cFILIAL,cPROJETO,cGERAREVISAO,cREVISAO,cUSERNAME,oWSLISTITENS WSRECEIVE cSETPROJRESULT WSCLIENT WSNEWREVIEWPROJ
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETPROJ xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("PROJETO", ::cPROJETO, cPROJETO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("GERAREVISAO", ::cGERAREVISAO, cGERAREVISAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REVISAO", ::cREVISAO, cREVISAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("USERNAME", ::cUSERNAME, cUSERNAME , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LISTITENS", ::oWSLISTITENS, oWSLISTITENS , "AITENS", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETPROJ>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/SETPROJ",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWREVIEWPROJ.apw")

::Init()
::cSETPROJRESULT     :=  WSAdvValue( oXmlRet,"_SETPROJRESPONSE:_SETPROJRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AITENSREVISAO

WSSTRUCT NEWREVIEWPROJ_AITENSREVISAO
	WSDATA   oWSITENSREV               AS NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_AITENSREVISAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_AITENSREVISAO
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_AITENSREVISAO
	Local oClone := NEWREVIEWPROJ_AITENSREVISAO():NEW()
	oClone:oWSITENSREV          := IIF(::oWSITENSREV = NIL , NIL , ::oWSITENSREV:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_AITENSREVISAO
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSREV","ARRAYOFALISTITENSREVISAO",NIL,"Property oWSITENSREV as s0:ARRAYOFALISTITENSREVISAO on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSREV := NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO():New()
		::oWSITENSREV:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENS

WSSTRUCT NEWREVIEWPROJ_AITENS
	WSDATA   oWSITENS                  AS NEWREVIEWPROJ_ARRAYOFALISTITENS
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_AITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_AITENS
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_AITENS
	Local oClone := NEWREVIEWPROJ_AITENS():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWREVIEWPROJ_AITENS
	Local cSoap := ""
	cSoap += WSSoapValue("ITENS", ::oWSITENS, ::oWSITENS , "ARRAYOFALISTITENS", .T. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_AITENS
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFALISTITENS",NIL,"Property oWSITENS as s0:ARRAYOFALISTITENS on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := NEWREVIEWPROJ_ARRAYOFALISTITENS():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFALISTITENSREVISAO

WSSTRUCT NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	WSDATA   oWSALISTITENSREVISAO      AS NEWREVIEWPROJ_ALISTITENSREVISAO OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	::oWSALISTITENSREVISAO := {} // Array Of  NEWREVIEWPROJ_ALISTITENSREVISAO():New()
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	Local oClone := NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO():NEW()
	oClone:oWSALISTITENSREVISAO := NIL
	If ::oWSALISTITENSREVISAO <> NIL 
		oClone:oWSALISTITENSREVISAO := {}
		aEval( ::oWSALISTITENSREVISAO , { |x| aadd( oClone:oWSALISTITENSREVISAO , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENSREVISAO
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSREVISAO","ALISTITENSREVISAO",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSREVISAO , NEWREVIEWPROJ_ALISTITENSREVISAO():New() )
			::oWSALISTITENSREVISAO[len(::oWSALISTITENSREVISAO)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENS

WSSTRUCT NEWREVIEWPROJ_ARRAYOFALISTITENS
	WSDATA   oWSALISTITENS             AS NEWREVIEWPROJ_ALISTITENS OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENS
	::oWSALISTITENS        := {} // Array Of  NEWREVIEWPROJ_ALISTITENS():New()
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENS
	Local oClone := NEWREVIEWPROJ_ARRAYOFALISTITENS():NEW()
	oClone:oWSALISTITENS := NIL
	If ::oWSALISTITENS <> NIL 
		oClone:oWSALISTITENS := {}
		aEval( ::oWSALISTITENS , { |x| aadd( oClone:oWSALISTITENS , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENS
	Local cSoap := ""
	aEval( ::oWSALISTITENS , {|x| cSoap := cSoap  +  WSSoapValue("ALISTITENS", x , x , "ALISTITENS", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_ARRAYOFALISTITENS
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENS","ALISTITENS",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENS , NEWREVIEWPROJ_ALISTITENS():New() )
			::oWSALISTITENS[len(::oWSALISTITENS)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALISTITENSREVISAO

WSSTRUCT NEWREVIEWPROJ_ALISTITENSREVISAO
	WSDATA   cREVISAO                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_ALISTITENSREVISAO
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_ALISTITENSREVISAO
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_ALISTITENSREVISAO
	Local oClone := NEWREVIEWPROJ_ALISTITENSREVISAO():NEW()
	oClone:cREVISAO             := ::cREVISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_ALISTITENSREVISAO
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cREVISAO           :=  WSAdvValue( oResponse,"_REVISAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENS

WSSTRUCT NEWREVIEWPROJ_ALISTITENS
	WSDATA   c_EDT                     AS string OPTIONAL
	WSDATA   c_EDTPAI                  AS string OPTIONAL
	WSDATA   c_TAREFA                  AS string OPTIONAL
	WSDATA   cCARGO                    AS string OPTIONAL
	WSDATA   cCENTROCUSTO              AS string OPTIONAL
	WSDATA   cCODPROJ                  AS string OPTIONAL
	WSDATA   cCREVISA                  AS string OPTIONAL
	WSDATA   cDESCEDT                  AS string OPTIONAL
	WSDATA   cDESCPRODUTO              AS string OPTIONAL
	WSDATA   cDESCTAREFA               AS string OPTIONAL
	WSDATA   cDTVENDA                  AS string OPTIONAL
	WSDATA   cEXECUCAO                 AS string OPTIONAL
	WSDATA   cFAMILIA                  AS string OPTIONAL
	WSDATA   nFCUSTOUNIT               AS float OPTIONAL
	WSDATA   nFCUSTTOT                 AS float OPTIONAL
	WSDATA   nFMETA                    AS float OPTIONAL
	WSDATA   nFMETAUNIT                AS float OPTIONAL
	WSDATA   nFORCPROJ                 AS float OPTIONAL
	WSDATA   nFORCREEM                 AS float OPTIONAL
	WSDATA   nFTAXA                    AS float OPTIONAL
	WSDATA   nFVENPROJ                 AS float OPTIONAL
	WSDATA   nFVENREEM                 AS float OPTIONAL
	WSDATA   cNIVEL                    AS string OPTIONAL
	WSDATA   cPRODUTO                  AS string OPTIONAL
	WSDATA   nQTDDIARIAS               AS float OPTIONAL
	WSDATA   nQTDPC                    AS float OPTIONAL
	WSDATA   nQUANTIDADE               AS float OPTIONAL
	WSDATA   cTIPOFAT                  AS string OPTIONAL
	WSDATA   cUNIDADEMED               AS string OPTIONAL
	WSDATA   nVALORPC                  AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWREVIEWPROJ_ALISTITENS
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWREVIEWPROJ_ALISTITENS
Return

WSMETHOD CLONE WSCLIENT NEWREVIEWPROJ_ALISTITENS
	Local oClone := NEWREVIEWPROJ_ALISTITENS():NEW()
	oClone:c_EDT                := ::c_EDT
	oClone:c_EDTPAI             := ::c_EDTPAI
	oClone:c_TAREFA             := ::c_TAREFA
	oClone:cCARGO               := ::cCARGO
	oClone:cCENTROCUSTO         := ::cCENTROCUSTO
	oClone:cCODPROJ             := ::cCODPROJ
	oClone:cCREVISA             := ::cCREVISA
	oClone:cDESCEDT             := ::cDESCEDT
	oClone:cDESCPRODUTO         := ::cDESCPRODUTO
	oClone:cDESCTAREFA          := ::cDESCTAREFA
	oClone:cDTVENDA             := ::cDTVENDA
	oClone:cEXECUCAO            := ::cEXECUCAO
	oClone:cFAMILIA             := ::cFAMILIA
	oClone:nFCUSTOUNIT          := ::nFCUSTOUNIT
	oClone:nFCUSTTOT            := ::nFCUSTTOT
	oClone:nFMETA               := ::nFMETA
	oClone:nFMETAUNIT           := ::nFMETAUNIT
	oClone:nFORCPROJ            := ::nFORCPROJ
	oClone:nFORCREEM            := ::nFORCREEM
	oClone:nFTAXA               := ::nFTAXA
	oClone:nFVENPROJ            := ::nFVENPROJ
	oClone:nFVENREEM            := ::nFVENREEM
	oClone:cNIVEL               := ::cNIVEL
	oClone:cPRODUTO             := ::cPRODUTO
	oClone:nQTDDIARIAS          := ::nQTDDIARIAS
	oClone:nQTDPC               := ::nQTDPC
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cTIPOFAT             := ::cTIPOFAT
	oClone:cUNIDADEMED          := ::cUNIDADEMED
	oClone:nVALORPC             := ::nVALORPC
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWREVIEWPROJ_ALISTITENS
	Local cSoap := ""
	cSoap += WSSoapValue("_EDT", ::c_EDT, ::c_EDT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("_EDTPAI", ::c_EDTPAI, ::c_EDTPAI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("_TAREFA", ::c_TAREFA, ::c_TAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CARGO", ::cCARGO, ::cCARGO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CENTROCUSTO", ::cCENTROCUSTO, ::cCENTROCUSTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODPROJ", ::cCODPROJ, ::cCODPROJ , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CREVISA", ::cCREVISA, ::cCREVISA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCEDT", ::cDESCEDT, ::cDESCEDT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCPRODUTO", ::cDESCPRODUTO, ::cDESCPRODUTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCTAREFA", ::cDESCTAREFA, ::cDESCTAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DTVENDA", ::cDTVENDA, ::cDTVENDA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("EXECUCAO", ::cEXECUCAO, ::cEXECUCAO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FAMILIA", ::cFAMILIA, ::cFAMILIA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FCUSTOUNIT", ::nFCUSTOUNIT, ::nFCUSTOUNIT , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FCUSTTOT", ::nFCUSTTOT, ::nFCUSTTOT , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FMETA", ::nFMETA, ::nFMETA , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FMETAUNIT", ::nFMETAUNIT, ::nFMETAUNIT , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FORCPROJ", ::nFORCPROJ, ::nFORCPROJ , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FORCREEM", ::nFORCREEM, ::nFORCREEM , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FTAXA", ::nFTAXA, ::nFTAXA , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FVENPROJ", ::nFVENPROJ, ::nFVENPROJ , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("FVENREEM", ::nFVENREEM, ::nFVENREEM , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NIVEL", ::cNIVEL, ::cNIVEL , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("PRODUTO", ::cPRODUTO, ::cPRODUTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QTDDIARIAS", ::nQTDDIARIAS, ::nQTDDIARIAS , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QTDPC", ::nQTDPC, ::nQTDPC , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("QUANTIDADE", ::nQUANTIDADE, ::nQUANTIDADE , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TIPOFAT", ::cTIPOFAT, ::cTIPOFAT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UNIDADEMED", ::cUNIDADEMED, ::cUNIDADEMED , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VALORPC", ::nVALORPC, ::nVALORPC , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWREVIEWPROJ_ALISTITENS
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::c_EDT              :=  WSAdvValue( oResponse,"__EDT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::c_EDTPAI           :=  WSAdvValue( oResponse,"__EDTPAI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::c_TAREFA           :=  WSAdvValue( oResponse,"__TAREFA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCARGO             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCENTROCUSTO       :=  WSAdvValue( oResponse,"_CENTROCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODPROJ           :=  WSAdvValue( oResponse,"_CODPROJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCREVISA           :=  WSAdvValue( oResponse,"_CREVISA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCEDT           :=  WSAdvValue( oResponse,"_DESCEDT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCPRODUTO       :=  WSAdvValue( oResponse,"_DESCPRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCTAREFA        :=  WSAdvValue( oResponse,"_DESCTAREFA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDTVENDA           :=  WSAdvValue( oResponse,"_DTVENDA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cEXECUCAO          :=  WSAdvValue( oResponse,"_EXECUCAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cFAMILIA           :=  WSAdvValue( oResponse,"_FAMILIA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nFCUSTOUNIT        :=  WSAdvValue( oResponse,"_FCUSTOUNIT","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFCUSTTOT          :=  WSAdvValue( oResponse,"_FCUSTTOT","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFMETA             :=  WSAdvValue( oResponse,"_FMETA","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFMETAUNIT         :=  WSAdvValue( oResponse,"_FMETAUNIT","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFORCPROJ          :=  WSAdvValue( oResponse,"_FORCPROJ","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFORCREEM          :=  WSAdvValue( oResponse,"_FORCREEM","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFTAXA             :=  WSAdvValue( oResponse,"_FTAXA","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFVENPROJ          :=  WSAdvValue( oResponse,"_FVENPROJ","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nFVENREEM          :=  WSAdvValue( oResponse,"_FVENREEM","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cNIVEL             :=  WSAdvValue( oResponse,"_NIVEL","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cPRODUTO           :=  WSAdvValue( oResponse,"_PRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nQTDDIARIAS        :=  WSAdvValue( oResponse,"_QTDDIARIAS","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nQTDPC             :=  WSAdvValue( oResponse,"_QTDPC","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cTIPOFAT           :=  WSAdvValue( oResponse,"_TIPOFAT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUNIDADEMED        :=  WSAdvValue( oResponse,"_UNIDADEMED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nVALORPC           :=  WSAdvValue( oResponse,"_VALORPC","float",NIL,NIL,NIL,"N",NIL,NIL) 
Return