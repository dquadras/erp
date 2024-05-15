DECLARE 
	nTotdbres NUMBER := 0;
	nTotcrres NUMBER := 0;
	nTotdbatv NUMBER := 0;
	nTotcratv NUMBER := 0;
	nSldres NUMBER := 0;
	nSldatv NUMBER := 0;
	nVldroa NUMBER := 0;
	cMes varchar(2) := LPAD(EXTRACT(MONTH FROM SYSDATE),2,00);
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE),4,0000);
BEGIN

	SELECT 
	sum(CT2_VALOR) INTO nTotdbres
	FROM 
	PROTHEUS.CT2010 
	WHERE D_E_L_E_T_ <> '*'
	AND CT2_ROTINA <> 'CTBA211'
	AND SUBSTR(CT2_DEBITO,1,1) = '3' AND SUBSTR(CT2_DATA,5,2) = cMes AND cAno = SUBSTR(CT2_DATA,1,4) AND CT2_MOEDLC = '01' AND CT2_TPSALD = '1';
	
	SELECT 
	sum(CT2_VALOR) INTO nTotcrres
	FROM 
	PROTHEUS.CT2010 
	WHERE D_E_L_E_T_ <> '*'
	AND CT2_ROTINA <> 'CTBA211'
	AND SUBSTR(CT2_CREDIT,1,1) = '3' AND SUBSTR(CT2_DATA,5,2) = cMes AND cAno = SUBSTR(CT2_DATA,1,4) AND CT2_MOEDLC = '01' AND CT2_TPSALD = '1';

	SELECT 
	sum(CT2_VALOR) INTO nTotdbatv
	FROM 
	PROTHEUS.CT2010 
	WHERE D_E_L_E_T_ <> '*'
	AND CT2_ROTINA <> 'CTBA211'
	AND SUBSTR(CT2_DEBITO,1,1) = '1' AND SUBSTR(CT2_DATA,5,2) = cMes AND cAno = SUBSTR(CT2_DATA,1,4) AND CT2_MOEDLC = '01' AND CT2_TPSALD = '1';
	
	SELECT 
	sum(CT2_VALOR) INTO nTotcratv
	FROM 
	PROTHEUS.CT2010 
	WHERE D_E_L_E_T_ <> '*'
	AND CT2_ROTINA <> 'CTBA211'
	AND SUBSTR(CT2_CREDIT,1,1) = '1' AND SUBSTR(CT2_DATA,5,2) = cMes AND cAno = SUBSTR(CT2_DATA,1,4) AND CT2_MOEDLC = '01' AND CT2_TPSALD = '1';

	nSldres := round(nTotdbres-nTotcrres,2);
	nSldatv := round(nTotdbatv-nTotcratv,2);
	
	nVldroa := round(ABS(nSldres/nSldatv),2);
	
	DBMS_OUTPUT.PUT_LINE('VALOR ROA = ' || TO_CHAR(nVldroa));
	
END;