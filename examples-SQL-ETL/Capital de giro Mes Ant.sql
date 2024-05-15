

DECLARE 
	nCptgir NUMBER := 0; 
	cMes varchar(2) := LPAD(EXTRACT(MONTH FROM SYSDATE)-1,2,00);
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE),4,0000);
BEGIN 

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCptgir FROM PROTHEUS.CQ1010 a
WHERE a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,3) = '111'  AND SUBSTR(CQ1_DATA,5,2) = cMes AND 
cAno = SUBSTR(CQ1_DATA,1,4);


DBMS_OUTPUT.PUT_LINE('Capital de Giro mes ant = ' || TO_CHAR(nCptgir)); 

END;
