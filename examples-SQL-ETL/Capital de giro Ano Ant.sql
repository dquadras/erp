

DECLARE 
	nCptgir NUMBER := 0; 
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE)-1,4,0000);
BEGIN 

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCptgir FROM PROTHEUS.CQ1010 a
WHERE a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,3) = '111'   AND 
cAno = SUBSTR(CQ1_DATA,1,4);


DBMS_OUTPUT.PUT_LINE('Capital de Giro ano ant = ' || TO_CHAR(nCptgir)); 

END;
