{{ config(materialized = 'table') }}
select
	ltrim(rtrim(conta_contabil)) cont_conta_contabil,
	ct1.ct1_desc01 cont_descricao_conta_contabil,
	case
		when ct2_data = '' then '99991231'
		else ct2_data
	end cont_data_lancamento,
	coalesce(ctt.ctt_custo, 'n/a') cont_centro_custo,
	coalesce(ctt.ctt_desc01, 'n/a') cont_descricao_custo,
	empresa cont_empresa,
	ct2_filial cont_filial,
	ct2_hist cont_historico,
	ct2_xalhs cont_historico_alice,
	ct2_moedlc cont_moeda,
	ct2_doc cont_numero_documento,
	ct2_valor cont_valor,
	coalesce(ctd.ctd_item, 'n/a') financ_item_contabil,
	coalesce(ctd.ctd_desc01, 'n/a') financ_nome_fornecedor,
	coalesce(sf1.f1_dtdigit, 'n/a') financ_data_do_documento,
	coalesce(se2.e2_vencrea, 'n/a') financ_data_de_vencimento,
	coalesce(se2.e2_baixa, 'n/a') financ_data_de_pagamento,
	ct2_lp interno_codigo_lp,
	case
		when ct2_manual = 1 then 'sim'
		else 'nao'
	end interno_lancamento_manual,
	ct2_linha interno_linha,
	ct2_lote interno_lote,
	ct2_origem interno_origem,
	ct2_xprod interno_produto,
	ct2_rotina interno_rotina,
	ct2_sblote interno_sublote,
	case
		when ct2_dc = '1' then 'debito'
		else 'credito'
	end as interno_tipo_lancamento,
	usr.usr_nome interno_usuario_lancamento,
	ct2_xmens receita_mensalidade,
	ct2_xcpfpj receita_cpf_cnpj_membro,
	ct2_xrsfn receita_resp_fin,
	ct2_xtplct receita_tipo_lancamento_alice,
	id_emp + ltrim(rtrim(id_tabela :: varchar)) dados_pk,
	id_emp dados_id_emp,
	id_tabela dados_id_tabela,
	coalesce(se2.e2_num, 'n/a') financ_numtit,
	coalesce(se2.e2_tipo, 'n/a') financ_tipo,
	coalesce(se2.e2_naturez, 'n/a') financ_natureza,
	coalesce(se2.e2_fornece, 'n/a') financ_codfornecedor,
	coalesce(sa2.a2_cgc, 'n/a') financ_cpfcnpj,
	coalesce(se2.e2_emissao, 'n/a') financ_emissao,
	coalesce(se2.e2_valor, 0) financ_valortitulo,
	coalesce(se2.e2_iss, 0) financ_iss,
	coalesce(se2.e2_irrf, 0) financ_irrf,
	coalesce(se2.e2_movimen, 'n/a') financ_ultmovimen,
	coalesce(se2.e2_saldo, 0) financ_saldo,
	coalesce(se2.e2_descont, 0) financ_desconto,
	coalesce(se2.e2_multa, 0) financ_multa,
	coalesce(se2.e2_juros, 0) financ_juros,
	coalesce(se2.e2_valliq, 0) financ_valliqbaixa,
	coalesce(se2.e2_vencori, 'n/a') financ_venctorig,
	coalesce(se2.e2_inss, 0) financ_inss,
	coalesce(se2.e2_datalib, 'n/a') financ_datalib,
	coalesce(se2.e2_titpai, 'n/a') financ_titulopai,
	coalesce(se2.e2_numbor, 'n/a') financ_numbordero,
	coalesce(se2.e2_dtborde, 'n/a') financ_dtbordero,
	coalesce(se2.e2_status, 'n/a') financ_saldotit,
	coalesce(temp.ct2_tpsald, 'n/a') cont_tipo_saldo,
	ct2_xdtban cont_data_banco
from
(
		select
			'05' id_emp,
			r_e_c_n_o_ as id_tabela,
			'ALICE_PAR' as empresa,
			ct2_filial,
			ct2_data,
			ct2_lote,
			ct2_sblote,
			ct2_doc,
			ct2_linha,
			ct2_moedlc,
			ct2_dc,
			ct2_debito as conta_contabil,
			ct2_valor,
			ct2_hist,
			ct2_ccd as centro_custo,
			ct2_itemd as item_contabil,
			ct2_manual,
			ct2_origem,
			ct2_rotina,
			ct2_lp,
			ct2_xalhs,
			ct2_xtplct,
			ct2_xcpfpj,
			ct2_xmens,
			ct2_xprod,
			ct2_key,
			ct2_usergi,
			ct2_xrsfn,
			ct2_tpsald,
			ct2_xdtban
		from
			{{ source('cleaned_totvs', 'ct2050') }}
		where
			d_e_l_e_t_ = ''
			and ct2_debito <> ''
		union
		all
		select
			'05' id_emp,
			r_e_c_n_o_ as id_tabela,
			'ALICE_PAR' as empresa,
			ct2_filial,
			ct2_data,
			ct2_lote,
			ct2_sblote,
			ct2_doc,
			ct2_linha,
			ct2_moedlc,
			ct2_dc,
			ct2_credit as conta_contabil,
			ct2_valor * -1,
			ct2_hist,
			ct2_ccc as centro_custo,
			ct2_itemc as item_contabil,
			ct2_manual,
			ct2_origem,
			ct2_rotina,
			ct2_lp,
			ct2_xalhs,
			ct2_xtplct,
			ct2_xcpfpj,
			ct2_xmens,
			ct2_xprod,
			ct2_key,
			ct2_usergi,
			ct2_xrsfn,
			ct2_tpsald,
			ct2_xdtban
		from
			{{ source('cleaned_totvs', 'ct2050') }}
		where
			d_e_l_e_t_ = ''
			and ct2_credit <> ''
	) as temp
	left join {{ source('cleaned_totvs', 'ct1050') }} ct1 on temp.conta_contabil = ct1.ct1_conta
	and ct1.d_e_l_e_t_ = ''
	left join {{ source('cleaned_totvs', 'ctt010') }} ctt on temp.centro_custo = ctt.ctt_custo
	and ctt.d_e_l_e_t_ = ''
	left join {{ source('cleaned_totvs', 'ctd010') }} ctd on temp.item_contabil = ctd.ctd_item
	and ctt.d_e_l_e_t_ = ''
	left join {{ source('cleaned_totvs', 'sf1050') }} sf1 on substring(temp.ct2_key, 1, 22) = sf1.f1_filial + sf1.f1_doc + sf1.f1_serie + sf1.f1_fornece + sf1.f1_loja
	and sf1.d_e_l_e_t_ = ''
	left join {{ source('cleaned_totvs', 'se2050') }} se2 on substring(temp.ct2_key, 1, 22) = se2.e2_filial + se2.e2_num + se2.e2_prefixo + se2.e2_fornece + se2.e2_loja
	and e2_tipo = 'nf'
	and se2.d_e_l_e_t_ = ''
	left join {{ source('cleaned_totvs', 'sa2010') }} sa2 on se2.e2_fornece = sa2.a2_cod
	and se2.e2_loja = sa2.a2_loja
	left join {{ source('cleaned_totvs', 'sys_usr') }} usr on usr.usr_id = substring(ct2_usergi, 11, 1) + substring(ct2_usergi, 15, 1) + substring(ct2_usergi, 2, 1) + substring(ct2_usergi, 6, 1) + substring(ct2_usergi, 10, 1) + substring(ct2_usergi, 14, 1) + substring(ct2_usergi, 1, 1) + substring(ct2_usergi, 5, 1) + substring(ct2_usergi, 9, 1) + substring(ct2_usergi, 13, 1) + substring(ct2_usergi, 17, 1) + substring(ct2_usergi, 4, 1) + substring(ct2_usergi, 8, 1)