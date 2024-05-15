DECLARE
	nSldatv NUMBER := 0;
	nSldpsv NUMBER := 0;
	nLqdcra NUMBER := 0;
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE)-1,4,0000);
BEGIN
SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT)) INTO nSldatv FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.CQ1_MOEDA = '01' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,2) = '11' AND
cAno = SUBSTR(CQ1_DATA,1,4) ;


SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT)) INTO nSldpsv FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.CQ1_MOEDA = '01' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,2) = '21' AND 
SUBSTR(CQ1_DATA,1,4) <= cAno;


nLqdcra := round(nSldatv / nSldpsv,2);
DBMS_OUTPUT.PUT_LINE('Saldo ativo circulante = ' || TO_CHAR(nSldatv));
DBMS_OUTPUT.PUT_LINE('Saldo passivo circulante = ' || TO_CHAR(nSldpsv));
DBMS_OUTPUT.PUT_LINE('Liquidez corrente Ano Ant = ' || TO_CHAR(nLqdcra));
END;
