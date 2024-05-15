#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://protheus.com.br:8090/ws/NEWORC.apw?WSDL
Gerado em        07/12/16 10:55:32
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _ZUXKFJR ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSNEWORC
------------------------------------------------------------------------------- */

WSCLIENT WSNEWORC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD GETREVIEWORC
	WSMETHOD GETSTRUCTORC
	WSMETHOD SETORC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cKEY                      AS string
	WSDATA   cEMPRESA                  AS string
	WSDATA   cCODIGO                   AS string
	WSDATA   c_CMSG                    AS string
	WSDATA   oWSGETREVIEWORCRESULT     AS NEWORC_AITENSREVISA
	WSDATA   cFILIAL                   AS string
	WSDATA   cREVISA                   AS string
	WSDATA   oWSGETSTRUCTORCRESULT     AS NEWORC_AITENSORC
	WSDATA   cGERAREVISAO              AS string
	WSDATA   cUSERNAME                 AS string
	WSDATA   oWSLISTITENS              AS NEWORC_AITENSORC
	WSDATA   cSETORCRESULT             AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSAITENSORC              AS NEWORC_AITENSORC

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSNEWORC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20150908] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSNEWORC
	::oWSGETREVIEWORCRESULT := NEWORC_AITENSREVISA():New()
	::oWSGETSTRUCTORCRESULT := NEWORC_AITENSORC():New()
	::oWSLISTITENS       := NEWORC_AITENSORC():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSAITENSORC       := ::oWSLISTITENS
Return

WSMETHOD RESET WSCLIENT WSNEWORC
	::cKEY               := NIL 
	::cEMPRESA           := NIL 
	::cCODIGO            := NIL 
	::c_CMSG             := NIL 
	::oWSGETREVIEWORCRESULT := NIL 
	::cFILIAL            := NIL 
	::cREVISA            := NIL 
	::oWSGETSTRUCTORCRESULT := NIL 
	::cGERAREVISAO       := NIL 
	::cUSERNAME          := NIL 
	::oWSLISTITENS       := NIL 
	::cSETORCRESULT      := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSAITENSORC       := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSNEWORC
Local oClone := WSNEWORC():New()
	oClone:_URL          := ::_URL 
	oClone:cKEY          := ::cKEY
	oClone:cEMPRESA      := ::cEMPRESA
	oClone:cCODIGO       := ::cCODIGO
	oClone:c_CMSG        := ::c_CMSG
	oClone:oWSGETREVIEWORCRESULT :=  IIF(::oWSGETREVIEWORCRESULT = NIL , NIL ,::oWSGETREVIEWORCRESULT:Clone() )
	oClone:cFILIAL       := ::cFILIAL
	oClone:cREVISA       := ::cREVISA
	oClone:oWSGETSTRUCTORCRESULT :=  IIF(::oWSGETSTRUCTORCRESULT = NIL , NIL ,::oWSGETSTRUCTORCRESULT:Clone() )
	oClone:cGERAREVISAO  := ::cGERAREVISAO
	oClone:cUSERNAME     := ::cUSERNAME
	oClone:oWSLISTITENS  :=  IIF(::oWSLISTITENS = NIL , NIL ,::oWSLISTITENS:Clone() )
	oClone:cSETORCRESULT := ::cSETORCRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSAITENSORC  := oClone:oWSLISTITENS
Return oClone

// WSDL Method GETREVIEWORC of Service WSNEWORC

WSMETHOD GETREVIEWORC WSSEND cKEY,cEMPRESA,cCODIGO,c_CMSG WSRECEIVE oWSGETREVIEWORCRESULT WSCLIENT WSNEWORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETREVIEWORC xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("_CMSG", ::c_CMSG, c_CMSG , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETREVIEWORC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETREVIEWORC",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWORC.apw")

::Init()
::oWSGETREVIEWORCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETREVIEWORCRESPONSE:_GETREVIEWORCRESULT","AITENSREVISA",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method GETSTRUCTORC of Service WSNEWORC

WSMETHOD GETSTRUCTORC WSSEND cKEY,cEMPRESA,cFILIAL,cCODIGO,cREVISA WSRECEIVE oWSGETSTRUCTORCRESULT WSCLIENT WSNEWORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<GETSTRUCTORC xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REVISA", ::cREVISA, cREVISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</GETSTRUCTORC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/GETSTRUCTORC",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWORC.apw")

::Init()
::oWSGETSTRUCTORCRESULT:SoapRecv( WSAdvValue( oXmlRet,"_GETSTRUCTORCRESPONSE:_GETSTRUCTORCRESULT","AITENSORC",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method SETORC of Service WSNEWORC

WSMETHOD SETORC WSSEND cKEY,cEMPRESA,cFILIAL,cCODIGO,cGERAREVISAO,cREVISA,cUSERNAME,oWSLISTITENS WSRECEIVE cSETORCRESULT WSCLIENT WSNEWORC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<SETORC xmlns="http://protheus.tv1.com.br:8090/">'
cSoap += WSSoapValue("KEY", ::cKEY, cKEY , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("EMPRESA", ::cEMPRESA, cEMPRESA , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("FILIAL", ::cFILIAL, cFILIAL , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("CODIGO", ::cCODIGO, cCODIGO , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("GERAREVISAO", ::cGERAREVISAO, cGERAREVISAO , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("REVISA", ::cREVISA, cREVISA , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("USERNAME", ::cUSERNAME, cUSERNAME , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("LISTITENS", ::oWSLISTITENS, oWSLISTITENS , "AITENSORC", .T. , .F., 0 , NIL, .F.) 
cSoap += "</SETORC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://protheus.tv1.com.br:8090/SETORC",; 
	"DOCUMENT","http://protheus.tv1.com.br:8090/",,"1.031217",; 
	"http://protheus.tv1.com.br:8090/ws/NEWORC.apw")

::Init()
::cSETORCRESULT      :=  WSAdvValue( oXmlRet,"_SETORCRESPONSE:_SETORCRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure AITENSREVISA

WSSTRUCT NEWORC_AITENSREVISA
	WSDATA   oWSITENSREV               AS NEWORC_ARRAYOFALISTITENSREVISA
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_AITENSREVISA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_AITENSREVISA
Return

WSMETHOD CLONE WSCLIENT NEWORC_AITENSREVISA
	Local oClone := NEWORC_AITENSREVISA():NEW()
	oClone:oWSITENSREV          := IIF(::oWSITENSREV = NIL , NIL , ::oWSITENSREV:Clone() )
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_AITENSREVISA
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENSREV","ARRAYOFALISTITENSREVISA",NIL,"Property oWSITENSREV as s0:ARRAYOFALISTITENSREVISA on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENSREV := NEWORC_ARRAYOFALISTITENSREVISA():New()
		::oWSITENSREV:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure AITENSORC

WSSTRUCT NEWORC_AITENSORC
	WSDATA   oWSITENS                  AS NEWORC_ARRAYOFALISTITENSORC
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_AITENSORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_AITENSORC
Return

WSMETHOD CLONE WSCLIENT NEWORC_AITENSORC
	Local oClone := NEWORC_AITENSORC():NEW()
	oClone:oWSITENS             := IIF(::oWSITENS = NIL , NIL , ::oWSITENS:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWORC_AITENSORC
	Local cSoap := ""
	cSoap += WSSoapValue("ITENS", ::oWSITENS, ::oWSITENS , "ARRAYOFALISTITENSORC", .T. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_AITENSORC
	Local oNode1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNode1 :=  WSAdvValue( oResponse,"_ITENS","ARRAYOFALISTITENSORC",NIL,"Property oWSITENS as s0:ARRAYOFALISTITENSORC on SOAP Response not found.",NIL,"O",NIL,NIL) 
	If oNode1 != NIL
		::oWSITENS := NEWORC_ARRAYOFALISTITENSORC():New()
		::oWSITENS:SoapRecv(oNode1)
	EndIf
Return

// WSDL Data Structure ARRAYOFALISTITENSREVISA

WSSTRUCT NEWORC_ARRAYOFALISTITENSREVISA
	WSDATA   oWSALISTITENSREVISA       AS NEWORC_ALISTITENSREVISA OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_ARRAYOFALISTITENSREVISA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_ARRAYOFALISTITENSREVISA
	::oWSALISTITENSREVISA  := {} // Array Of  NEWORC_ALISTITENSREVISA():New()
Return

WSMETHOD CLONE WSCLIENT NEWORC_ARRAYOFALISTITENSREVISA
	Local oClone := NEWORC_ARRAYOFALISTITENSREVISA():NEW()
	oClone:oWSALISTITENSREVISA := NIL
	If ::oWSALISTITENSREVISA <> NIL 
		oClone:oWSALISTITENSREVISA := {}
		aEval( ::oWSALISTITENSREVISA , { |x| aadd( oClone:oWSALISTITENSREVISA , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_ARRAYOFALISTITENSREVISA
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSREVISA","ALISTITENSREVISA",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSREVISA , NEWORC_ALISTITENSREVISA():New() )
			::oWSALISTITENSREVISA[len(::oWSALISTITENSREVISA)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ARRAYOFALISTITENSORC

WSSTRUCT NEWORC_ARRAYOFALISTITENSORC
	WSDATA   oWSALISTITENSORC          AS NEWORC_ALISTITENSORC OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_ARRAYOFALISTITENSORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_ARRAYOFALISTITENSORC
	::oWSALISTITENSORC     := {} // Array Of  NEWORC_ALISTITENSORC():New()
Return

WSMETHOD CLONE WSCLIENT NEWORC_ARRAYOFALISTITENSORC
	Local oClone := NEWORC_ARRAYOFALISTITENSORC():NEW()
	oClone:oWSALISTITENSORC := NIL
	If ::oWSALISTITENSORC <> NIL 
		oClone:oWSALISTITENSORC := {}
		aEval( ::oWSALISTITENSORC , { |x| aadd( oClone:oWSALISTITENSORC , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWORC_ARRAYOFALISTITENSORC
	Local cSoap := ""
	aEval( ::oWSALISTITENSORC , {|x| cSoap := cSoap  +  WSSoapValue("ALISTITENSORC", x , x , "ALISTITENSORC", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_ARRAYOFALISTITENSORC
	Local nRElem1, oNodes1, nTElem1
	::Init()
	If oResponse = NIL ; Return ; Endif 
	oNodes1 :=  WSAdvValue( oResponse,"_ALISTITENSORC","ALISTITENSORC",{},NIL,.T.,"O",NIL,NIL) 
	nTElem1 := len(oNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( oNodes1[nRElem1] )
			aadd(::oWSALISTITENSORC , NEWORC_ALISTITENSORC():New() )
			::oWSALISTITENSORC[len(::oWSALISTITENSORC)]:SoapRecv(oNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure ALISTITENSREVISA

WSSTRUCT NEWORC_ALISTITENSREVISA
	WSDATA   cREVISAO                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_ALISTITENSREVISA
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_ALISTITENSREVISA
Return

WSMETHOD CLONE WSCLIENT NEWORC_ALISTITENSREVISA
	Local oClone := NEWORC_ALISTITENSREVISA():NEW()
	oClone:cREVISAO             := ::cREVISAO
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_ALISTITENSREVISA
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::cREVISAO           :=  WSAdvValue( oResponse,"_REVISAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return

// WSDL Data Structure ALISTITENSORC

WSSTRUCT NEWORC_ALISTITENSORC
	WSDATA   c_EDT                     AS string OPTIONAL
	WSDATA   c_EDTPAI                  AS string OPTIONAL
	WSDATA   c_TAREFA                  AS string OPTIONAL
	WSDATA   cCARGO                    AS string OPTIONAL
	WSDATA   cCENTROCUSTO              AS string OPTIONAL
	WSDATA   cCODPROJ                  AS string OPTIONAL
	WSDATA   cDESCEDT                  AS string OPTIONAL
	WSDATA   cDESCPRODUTO              AS string OPTIONAL
	WSDATA   cDESCTAREFA               AS string OPTIONAL
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
	WSDATA   nQUANTIDADE               AS float OPTIONAL
	WSDATA   cREVISAO                  AS string OPTIONAL
	WSDATA   cTIPOFAT                  AS string OPTIONAL
	WSDATA   cUNIDADEMED               AS string OPTIONAL
	WSDATA   nVALORPC                  AS float OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT NEWORC_ALISTITENSORC
	::Init()
Return Self

WSMETHOD INIT WSCLIENT NEWORC_ALISTITENSORC
Return

WSMETHOD CLONE WSCLIENT NEWORC_ALISTITENSORC
	Local oClone := NEWORC_ALISTITENSORC():NEW()
	oClone:c_EDT                := ::c_EDT
	oClone:c_EDTPAI             := ::c_EDTPAI
	oClone:c_TAREFA             := ::c_TAREFA
	oClone:cCARGO               := ::cCARGO
	oClone:cCENTROCUSTO         := ::cCENTROCUSTO
	oClone:cCODPROJ             := ::cCODPROJ
	oClone:cDESCEDT             := ::cDESCEDT
	oClone:cDESCPRODUTO         := ::cDESCPRODUTO
	oClone:cDESCTAREFA          := ::cDESCTAREFA
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
	oClone:nQUANTIDADE          := ::nQUANTIDADE
	oClone:cREVISAO             := ::cREVISAO
	oClone:cTIPOFAT             := ::cTIPOFAT
	oClone:cUNIDADEMED          := ::cUNIDADEMED
	oClone:nVALORPC             := ::nVALORPC
Return oClone

WSMETHOD SOAPSEND WSCLIENT NEWORC_ALISTITENSORC
	Local cSoap := ""
	cSoap += WSSoapValue("_EDT", ::c_EDT, ::c_EDT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("_EDTPAI", ::c_EDTPAI, ::c_EDTPAI , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("_TAREFA", ::c_TAREFA, ::c_TAREFA , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CARGO", ::cCARGO, ::cCARGO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CENTROCUSTO", ::cCENTROCUSTO, ::cCENTROCUSTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CODPROJ", ::cCODPROJ, ::cCODPROJ , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCEDT", ::cDESCEDT, ::cDESCEDT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCPRODUTO", ::cDESCPRODUTO, ::cDESCPRODUTO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("DESCTAREFA", ::cDESCTAREFA, ::cDESCTAREFA , "string", .F. , .F., 0 , NIL, .F.) 
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
	cSoap += WSSoapValue("QUANTIDADE", ::nQUANTIDADE, ::nQUANTIDADE , "float", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("REVISAO", ::cREVISAO, ::cREVISAO , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("TIPOFAT", ::cTIPOFAT, ::cTIPOFAT , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("UNIDADEMED", ::cUNIDADEMED, ::cUNIDADEMED , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("VALORPC", ::nVALORPC, ::nVALORPC , "float", .F. , .F., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT NEWORC_ALISTITENSORC
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::c_EDT              :=  WSAdvValue( oResponse,"__EDT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::c_EDTPAI           :=  WSAdvValue( oResponse,"__EDTPAI","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::c_TAREFA           :=  WSAdvValue( oResponse,"__TAREFA","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCARGO             :=  WSAdvValue( oResponse,"_CARGO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCENTROCUSTO       :=  WSAdvValue( oResponse,"_CENTROCUSTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cCODPROJ           :=  WSAdvValue( oResponse,"_CODPROJ","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCEDT           :=  WSAdvValue( oResponse,"_DESCEDT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCPRODUTO       :=  WSAdvValue( oResponse,"_DESCPRODUTO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cDESCTAREFA        :=  WSAdvValue( oResponse,"_DESCTAREFA","string",NIL,NIL,NIL,"S",NIL,NIL) 
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
	::nQUANTIDADE        :=  WSAdvValue( oResponse,"_QUANTIDADE","float",NIL,NIL,NIL,"N",NIL,NIL) 
	::cREVISAO           :=  WSAdvValue( oResponse,"_REVISAO","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cTIPOFAT           :=  WSAdvValue( oResponse,"_TIPOFAT","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::cUNIDADEMED        :=  WSAdvValue( oResponse,"_UNIDADEMED","string",NIL,NIL,NIL,"S",NIL,NIL) 
	::nVALORPC           :=  WSAdvValue( oResponse,"_VALORPC","float",NIL,NIL,NIL,"N",NIL,NIL) 
Return