#INCLUDE 'Protheus.ch'
//-------------------------------------------------------------------
/*/{Protheus.doc} Imfa050
Contabilizacao de baixas a pagar para PerdComp, conforme 
orientacoes 
@aParam
@Autor      David Ferreira Quadras
@since		27/06/2013
@uso        TV1 - Eventos
@Obs
/*/
//--------------------------------------------------------------------
User Function Imfa050(_cLP, _cSeq)
	Local _cRetConta := ''

	Do Case
	
	Case _cLP == "530" .And. _cSeq == "002"
		
		Do Case
		Case cEmpAnt == '02' // EBCP
			If SE2->E2_CODRET == '0561'
				/* IRRF A RECOLHER DE ASSALARIADOS*/
					//D - 2120105004
					//C - 1120501033
				_cRetConta :=  '2120105004'
			Else
				_cRetConta := IF(SA2->A2_TIPO="F".AND.EMPTY(SA2->A2_INSCR),"2120105005","2120105006")
			EndIf
		Case cEmpAnt == '06' //GNOVA
			
			_cRetConta := IF(SA2->A2_TIPO="F".AND.EMPTY(SA2->A2_INSCR),"2120105005","2120105006")
			
		EndCase
	endcase
Return(_cRetConta)