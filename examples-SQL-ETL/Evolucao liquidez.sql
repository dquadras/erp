WITH ATVCIRC AS (
SELECT 
SUBSTR(a.CQ1_DATA,1,6) MESANO,
ABS(SUM(a.CQ1_DEBITO) - SUM(a.CQ1_CREDIT)) ATV_CIRC
FROM PROTHEUS.CQ1010 a WHERE CQ1_MOEDA = '01' AND CQ1_TPSALD = '1' AND a.D_E_L_E_T_  <> '*' AND a.CQ1_DATA >= '20200101' AND SUBSTR(a.CQ1_CONTA,1,2) = '11'
GROUP BY SUBSTR(a.CQ1_DATA,1,6) ORDER BY SUBSTR(a.CQ1_DATA,1,6) ),
PASCIRC AS (
SELECT 
SUBSTR(a.CQ1_DATA,1,6) MESANO,
ABS(SUM(a.CQ1_DEBITO) - SUM(a.CQ1_CREDIT)) PAS_CIRC
FROM PROTHEUS.CQ1010 a WHERE CQ1_MOEDA = '01' AND CQ1_TPSALD = '1' AND a.D_E_L_E_T_  <> '*' AND a.CQ1_DATA >= '20200101' AND SUBSTR(a.CQ1_CONTA,1,2) = '21'
GROUP BY SUBSTR(a.CQ1_DATA,1,6) ORDER BY SUBSTR(a.CQ1_DATA,1,6) )
SELECT
a.MESANO,
round(abs(a.ATV_CIRC/b.PAS_CIRC),2)*100 Liquidez_mensal
FROM ATVCIRC a
JOIN PASCIRC b ON a.MESANO = b.MESANO;
