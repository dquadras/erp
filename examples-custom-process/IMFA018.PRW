#Include "RWMAKE.Ch"
#Include "PROTHEUS.Ch"               
//-------------------------------------------------------------------
/*/{Protheus.doc} IMFA018
Grava os Historico de Acessos do Usuario
@aParam
@Autor      David Ferreira Quadras
@since		04/04/2012
@uso        
/*/
//--------------------------------------------------------------------
User Function IMFA018(cCodFun,cDscFun)
Local aArea  	:= GetArea()   
Default cCodFun := Alltrim(FullName())
Default cDscFun := "-"

If CHKFILE("PA3") 
	DbSelectArea("PA3")
	RecLock("PA3",.T.)
	PA3->PA3_FILIAL	:=xFilial("PA3")
	PA3->PA3_USER	:=__cUserId
	PA3->PA3_DATA	:=dDataBase
	PA3->PA3_HORA	:=Time()
	PA3->PA3_MODULO :=cModulo
	PA3->PA3_FUNCAO :=Upper(cCodFun)
	PA3->PA3_DESFUN :=Upper(cDscFun)
	PA3->PA3_DESAMB :=Upper(GetEnvServer())
	PA3->PA3_DESPC  :=Upper(GetComputerName())
	PA3->(MsUnlock())
Endif
RestArea(aArea)
Return(Nil)