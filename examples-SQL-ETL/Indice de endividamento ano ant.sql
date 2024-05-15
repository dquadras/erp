DECLARE 
	nPasc  NUMBER := 0; 
	nPasnc NUMBER := 0; 
	nAtv   NUMBER := 0;
	nIdend NUMBER := 0;
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE)-1,4,0000);
BEGIN 

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nPasc FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_MOEDA = '01' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,2) = '21'  AND 
cAno = SUBSTR(CQ1_DATA,1,4);

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nPasnc FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_MOEDA = '01' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,2) = '22'  AND 
cAno = SUBSTR(CQ1_DATA,1,4);

SELECT (sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nAtv FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_MOEDA = '01' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,1) = '1'   AND 
cAno = SUBSTR(CQ1_DATA,1,4);

nIdend := ((nPasc+nPasnc)/(nAtv));
DBMS_OUTPUT.PUT_LINE('Passivo circulante = ' || TO_CHAR(nPasc)); 
DBMS_OUTPUT.PUT_LINE('Passivo nao circulante = ' || TO_CHAR(nPasnc)); 
DBMS_OUTPUT.PUT_LINE('Ativo = ' || TO_CHAR(nAtv)); 
DBMS_OUTPUT.PUT_LINE('Indice endividamento = ' || TO_CHAR(nIdend)); 

END;


