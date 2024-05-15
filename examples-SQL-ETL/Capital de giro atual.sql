

DECLARE 
	nCptgir NUMBER := 0; 
	nCtarc1 NUMBER := 0; 
	nCtarc2 NUMBER := 0; 
	nCtaest NUMBER := 0; 
	nCtapag NUMBER := 0; 
	cMes varchar(2) := LPAD(EXTRACT(MONTH FROM SYSDATE),2,00);
	cAno varchar(4) := LPAD(EXTRACT(YEAR FROM SYSDATE),4,0000);
BEGIN 

SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCtarc1 FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,5) = '11201'  AND SUBSTR(a.CQ1_DATA,5,2) <= cMes AND 
SUBSTR(a.CQ1_DATA,1,4) <= cAno;

SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCtarc2 FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.D_E_L_E_T_ <> '*'  AND (SUBSTR(a.CQ1_CONTA,1,7) >= '1120113' AND SUBSTR(a.CQ1_CONTA,1,7) <= '1120114' )  AND SUBSTR(CQ1_DATA,5,2) <= cMes AND 
SUBSTR(a.CQ1_DATA,1,4) <= cAno;

SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCtaest FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,3) = '115'  AND SUBSTR(CQ1_DATA,5,2) <= cMes AND 
SUBSTR(a.CQ1_DATA,1,4) <= cAno;
	
SELECT abs(sum(a.CQ1_DEBITO) - sum(a.CQ1_CREDIT))  INTO nCtapag FROM PROTHEUS.CQ1010 a
WHERE a.CQ1_TPSALD = '1' AND a.D_E_L_E_T_ <> '*'  AND SUBSTR(a.CQ1_CONTA,1,3) = '211'  AND SUBSTR(a.CQ1_DATA,5,2) <= cMes AND 
SUBSTR(a.CQ1_DATA,1,4) <= cAno;

nCptgir := (nCtarc1-nCtarc2)+nCtaest-nCtapag;


DBMS_OUTPUT.PUT_LINE('Capital de Giro = ' || TO_CHAR(nCptgir)); 

END;
