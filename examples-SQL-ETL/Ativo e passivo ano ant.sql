DECLARE 
	nAtv  NUMBER := 0; 
	nPas NUMBER := 0; 
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE)-1,4,0000);
BEGIN 

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nAtv FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_MOEDA = '01' AND a.CQ1_TPSALD = '1' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,1) = '1'  AND 
cAno = SUBSTR(CQ1_DATA,1,4);

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nPas FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_MOEDA = '01' AND a.CQ1_TPSALD = '1'  AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,1) = '2'   AND 
cAno = SUBSTR(CQ1_DATA,1,4);

DBMS_OUTPUT.PUT_LINE('Ativo = ' || TO_CHAR(nAtv)); 
DBMS_OUTPUT.PUT_LINE('Passivo = ' || TO_CHAR(nPas)); 

END;
