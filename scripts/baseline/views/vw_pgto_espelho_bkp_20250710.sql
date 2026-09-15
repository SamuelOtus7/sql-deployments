-- ============================================================
-- BASELINE: dbo.vw_pgto_espelho_bkp_20250710
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_espelho_bkp_20250710]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_pgto_espelho_bkp_20250710]
AS

--select * from [vw_pgto_espelho] where ppr_cd_pgto_espelho = 514274

--DECLARE @codespelho INT = 510639


SELECT	convert(varchar(10),a.ppr_data_referencia,103)									as Data	
		,a.ppr_cd_rota																	as Rota
		,d.usr_nm_usuario																as NomeMotorista
		,b.ServiceCenter																as Base
		,a.ppr_ds_placa																	as Placa
		,case 
--			when a.ppr_vl_total < 0 
			when (a.ppr_vl_total - ISNULL(a.ppr_vl_lancamentos,0) + ISNULL(ppr_vl_pedagio,0)) < 0
				then 'Desconto' 
			else 'Minuta' 
		end																				as Origem
--		,'Minuta'																		as Origem
		,
--case 
--			when a.ppr_lcto_observacao is not null 
--				then a.ppr_lcto_observacao
			--when a.ppr_vl_total < 0 
			--	then a.ppr_lcto_observacao 
--			else
			case 
				when pgp_cd_cliente = 27
					then ppr_lcto_observacao
				else 
			CASE
				WHEN a.ppr_cd_rota IS NOT NULL
					THEN
						CASE
							WHEN a.ppr_lcto_cd_lancamento IS NULL
								THEN 'Frete ' + CASE WHEN a.ppr_ds_ciclo IS NULL THEN '' ELSE a.ppr_ds_ciclo + ': R$ ' END + cast(ISNULL(a.ppr_vl_base,0) as varchar(50)) 
									-- + ' Paradas: R$ ' + cast(ISNULL(a.ppr_vl_paradas,0) as varchar(50))
									+ CASE WHEN pgp_cd_cliente = 61 THEN ' Ajudante: R$ ' 
									ELSE ' Paradas: R$ ' 
									END + cast(ISNULL(a.ppr_vl_paradas,0) as varchar(50))
									+ CASE WHEN a.ppr_vl_risco <> 0 THEN ' Risco: R$ ' + CAST(a.ppr_vl_risco AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_ajudante <> 0 THEN ' Ajudante: R$ ' + CAST(a.ppr_vl_ajudante AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_dom_fer <> 0 THEN ' Domingo Feriado: R$ ' + CAST(a.ppr_vl_dom_fer AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_lancamentos <> 0 THEN ' ' + CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_bonus <> 0 THEN ' Bônus: R$ ' + CAST(a.ppr_vl_bonus AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_pedagio <> 0 THEN ' Pedágio: R$ ' + CAST(a.ppr_vl_pedagio AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_recarga <> 0 THEN ' Recarga Elétrica: R$ ' + CAST(a.ppr_vl_recarga AS VARCHAR(50)) ELSE '' END
									+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE '%Pnr%' THEN ' PNR: R$ ' ELSE CASE WHEN a.ppr_lcto_observacao LIKE '%Vehicle Daily Not Visited%' THEN ' Not Visited: R$ ' ELSE ' Lost: R$ ' END END + CAST(a.ppr_vl_desconto AS VARCHAR(50)) ELSE '' END
							ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Lanc. Manuais' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
						END
				ELSE 
					CASE 
						WHEN a.ppr_lcto_observacao = 'Lançamento - Aluguel'
							THEN CASE WHEN a.ppr_vl_aluguel <> 0 THEN 'Aluguel: R$ ' + + CAST(a.ppr_vl_aluguel AS VARCHAR(50)) ELSE '' END
						WHEN a.ppr_lcto_observacao = 'Desconto Flex Frota'
							THEN CASE WHEN a.ppr_vl_desconto_flex_rota <> 0 THEN 'Desconto Flex Frota: R$ ' + + CAST(a.ppr_vl_desconto_flex_rota AS VARCHAR(50)) ELSE '' END
						WHEN a.ppr_lcto_observacao = 'Desconto Cartão Flex Frota'
							THEN CASE WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 THEN 'Desconto Cartão Flex Frota: R$ ' + + CAST(a.ppr_vl_desconto_cartao_flex_rota AS VARCHAR(50)) ELSE '' END
						ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '' THEN 'Avulso' ELSE a.ppr_lcto_observacao END + ': R$ ' + CAST(a.ppr_vl_total AS VARCHAR(50))
					END
--		end
		END end as Descricao
		
		,a.ppr_ds_tipo_veiculo															as veiculo	 
		,a.ppr_vl_total - ISNULL(a.ppr_vl_lancamentos,0) + ISNULL(ppr_vl_pedagio,0)		as Valor
		--,a.ppr_vl_total as Valor
		,c.cli_ds_nome																	as NomeTrasportadora
		,convert(varchar(10),a.ppr_dh_criacao,103) + ' ' 
			+ convert(varchar(8),convert(time(0),a.ppr_dh_criacao))						as DataGeracao
		,a.ppr_dh_criacao
		,c.cli_ds_cnpj																	as CNPJTransportadora
		,d.usr_matricula																as Matricula
		,mot.mot_cpf																		as CPFMotorista
		,convert(varchar(10),periodo.pgp_dt_inicio,103)									as InicioPeriodo
		,convert(varchar(10),periodo.pgp_dt_fim,103)									as FimPeriodo
		,a.ppr_nm_cidade
		,a.ppr_cd_pgto_espelho
		,CASE
			WHEN a.ppr_cd_tipo = 'FM'
				THEN 'Fisrt Mile'
			WHEN a.ppr_cd_tipo = 'LM'
				THEN 'Last Mile'
			WHEN a.ppr_cd_tipo = 'MO'
				THEN 'Meli One'
			WHEN a.ppr_cd_tipo = 'LH'
				THEN 'Line Hall'
			ELSE ''
		END																				AS Operacao,
		CASE
			WHEN MOT.mot_pag_cd_tipo_pagamento = 1
				THEN 'Nota Fiscal'
			WHEN MOT.mot_pag_cd_tipo_pagamento = 2
				THEN 'CIOT'
			ELSE NULL
		END																				AS Tipo_Pagamento

from [tb_pgto_periodo_rota] a (NOLOCK)

INNER join [tb_pgto_periodo] as periodo (NOLOCK)
on a.ppr_cd_periodo = periodo.pgp_cd_periodo
	AND periodo.pgp_in_excluido = 0

inner join tb_pag_espelhos as espelho (NOLOCK)
on 1=1
-- and espelho.mtn_cd_motorista		= a.ppr_cd_motorista
-- and espelho.mtn_cd_pgto_periodo = a.ppr_cd_periodo
and espelho.mtn_cd_motorista_nfs = a.ppr_cd_pgto_espelho

left join tb_clientes as c (NOLOCK)
on espelho.mtn_cod_cliente =  c.cli_cd_codigo_cliente 

left join (
				SELECT	*,
						ROW_NUMBER() OVER(PARTITION BY idrota ORDER BY DataHoraColeta ASC) AS IdFiltro
				FROM tb_ml_rotas (NOLOCK)
		  ) AS b
on a.ppr_cd_rota = CONVERT(VARCHAR(50),b.idrota)
and b.excluido = 0
AND b.IdFiltro = 1

left join tb_usuario as d (NOLOCK)
on a.ppr_cd_motorista = d.usr_cd_usuario
and d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente


LEFT JOIN tb_motorista AS MOT (NOLOCK) ON MOT.mot_cd_usuario = a.ppr_cd_motorista
									AND MOT.mot_cd_cliente   = c.cli_cd_codigo_cliente

WHERE ppr_lcto_cd_lancamento IS NULL
and ppr_in_excluido = 0
and usr_in_ativo = 1
--and  ppr_cd_pgto_espelho = 514274

UNION ALL

  
-- Lançamentos Manuais - EXCETO Apoio  
select distinct CONVERT(VARCHAR,a.tlm_dh_referencia,103) as Data  
  ,cast(a.tlm_cd_lancamento_manual as varchar(50)) as Rota  
  ,a.tlm_cd_motorista  
  ,a.tlm_cd_service_center AS Base  
  ,NULL AS Placa  
  ,case when isnull(a.tlm_vl_valor_descontos,0) > 0 then 'Desconto' else 'Credito' end as Origem  
  ,LTRIM(RTRIM(TIP.plm_nm_tipo)) + ': ' + CASE WHEN a.tlm_ds_observacao <> '' THEN LTRIM(RTRIM(a.tlm_ds_observacao)) + ' R$ ' ELSE LTRIM(RTRIM(a.tlm_ds_observacao)) + 'R$ ' END  
   + CONVERT(VARCHAR(50),isnull(a.tlm_vl_valor_adicional,0) + isnull(a.tlm_vl_valor_rota,0)   
   + case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(a.tlm_vl_valor_apoio,0)) else (-1 * isnull(a.tlm_vl_valor_descontos,0)) end) AS Descricao  
  ,NULL AS veiculo  
  ,isnull(a.tlm_vl_valor_adicional,0) + isnull(a.tlm_vl_valor_rota,0)   
   + case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(a.tlm_vl_valor_apoio,0)) else (-1 * isnull(a.tlm_vl_valor_descontos,0)) end AS Valor  
  ,cli_ds_nome as Transportadora  
  ,convert(varchar(10),a.tlm_dh_criacao,103) + ' '   
   + convert(varchar(8),convert(time(0),a.tlm_dh_criacao))  AS DataGeracao  
  ,a.tlm_dh_criacao as DataCriacao  
  ,cli.cli_ds_cnpj as CNPJTransportadora  
  ,usu.usr_matricula as Matricula  
  ,mot_cpf AS CPFMotorista  
  ,CONVERT(VARCHAR(10),periodo.pgp_dt_inicio, 103) as InicioPeriodo  
  ,CONVERT(VARCHAR(10),periodo.pgp_dt_fim, 103) as FimPeriodo  
  ,NULL as ppr_nm_cidade  
  ,periodo.ppr_cd_pgto_espelho  
  ,'Manual' AS Operacao,  
  CASE  
   WHEN MOT.mot_pag_cd_tipo_pagamento = 1  
    THEN 'Nota Fiscal'  
   WHEN MOT.mot_pag_cd_tipo_pagamento = 2  
    THEN 'CIOT'  
   ELSE NULL  
  END AS Tipo_Pagamento  

from [dbo].[tb_lancamentos_manuais] as a (NOLOCK)  
inner join [tb_aprovacao_lancamento_manual] as APV (NOLOCK)  
on alm_cd_lancamento_manual = tlm_cd_lancamento_manual  
   
left join tb_usuario as b (NOLOCK)  
on a.tlm_cd_usuario_criacao = b.usr_cd_usuario  
   
inner JOIN [dbo].[tb_tipos_lancamentos_manuais] AS TIP (NOLOCK) ON TIP.plm_cd_tipo_lancamento_manual = a.tlm_cd_tipo  
   
inner join tb_usuario as usu (NOLOCK)  
on usu.usr_nm_usuario = tlm_cd_motorista  
and usu.cli_cd_codigo_cliente = tlm_cd_cliente  
  
inner join tb_clientes as cli (NOLOCK)  
on usu.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente  

inner join (  
   
   select distinct ppr_cd_periodo ,pgp_dt_inicio,pgp_dt_fim,ppr_nome_motorista,ppr_cd_pgto_espelho,pgp_cd_cliente  
   from tb_pgto_periodo_rota as a (NOLOCK)  
   inner join tb_pgto_periodo as b (NOLOCK)  
   on a.ppr_cd_periodo = b.pgp_cd_periodo  
   WHERE b.pgp_in_excluido = 0  
    --and ppr_cd_pgto_espelho = 514274  
    --ppr_cd_pgto_espelho =   
   ) as periodo  
on periodo.ppr_nome_motorista = a.tlm_cd_motorista  
 AND periodo.pgp_cd_cliente = a.tlm_cd_cliente  
 AND CONVERT(DATE,tlm_dh_referencia) BETWEEN periodo.pgp_dt_inicio AND periodo.pgp_dt_fim  

LEFT JOIN tb_motorista AS MOT (NOLOCK) ON MOT.mot_cd_usuario = usu.usr_cd_usuario  
         AND MOT.mot_cd_cliente   = pgp_cd_cliente  
   
where a.tlm_in_ativo = 1  
AND APV.alm_ds_status = 'Aprovado'  
AND TIP.plm_nm_tipo <> 'Apoio'  
and usu.usr_in_ativo = 1  
--and cast(a.tlm_cd_lancamento_manual as varchar(50)) = 147106
  
UNION ALL

-- Lançamentos Manuais - Apoio  

select distinct CONVERT(VARCHAR,a.tlm_dh_referencia,103) as Data  
  ,cast(a.tlm_cd_lancamento_manual as varchar(50)) as Rota  
  ,a.tlm_cd_motorista  
  ,a.tlm_cd_service_center AS Base  
  ,NULL AS Placa  
  ,case when isnull(a.tlm_vl_valor_descontos,0) > 0 then 'Desconto' else 'Credito' end as Origem  
  ,LTRIM(RTRIM(TIP.plm_nm_tipo)) + ': ' + CASE WHEN a.tlm_ds_observacao <> '' THEN LTRIM(RTRIM(a.tlm_ds_observacao)) + ' R$ ' ELSE LTRIM(RTRIM(a.tlm_ds_observacao)) + 'R$ ' END  
   + CONVERT(VARCHAR(50),isnull(a.tlm_vl_valor_adicional,0) + isnull(a.tlm_vl_valor_rota,0)   
   + case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(a.tlm_vl_valor_apoio,0)) else (-1 * isnull(a.tlm_vl_valor_descontos,0)) end) AS Descricao  
  ,NULL AS veiculo  
  ,isnull(a.tlm_vl_valor_adicional,0) + isnull(a.tlm_vl_valor_rota,0)   
   + case when TIP.plm_nm_tipo = 'Apoio' then (-1 * isnull(a.tlm_vl_valor_apoio,0)) else (-1 * isnull(a.tlm_vl_valor_descontos,0)) end AS Valor  
  ,cli_ds_nome as Transportadora  
  ,convert(varchar(10),a.tlm_dh_criacao,103) + ' '   
   + convert(varchar(8),convert(time(0),a.tlm_dh_criacao))  AS DataGeracao  
  ,a.tlm_dh_criacao as DataCriacao  
  ,cli.cli_ds_cnpj as CNPJTransportadora  
  ,usu.usr_matricula as Matricula  
  ,mot_cpf AS CPFMotorista  
  ,CONVERT(VARCHAR(10),periodo.pgp_dt_inicio, 103) as InicioPeriodo  
  ,CONVERT(VARCHAR(10),periodo.pgp_dt_fim, 103) as FimPeriodo  
  ,NULL as ppr_nm_cidade  
  ,periodo.ppr_cd_pgto_espelho  
  ,'Manual' AS Operacao,  
  CASE  
   WHEN MOT.mot_pag_cd_tipo_pagamento = 1  
    THEN 'Nota Fiscal'  
   WHEN MOT.mot_pag_cd_tipo_pagamento = 2  
    THEN 'CIOT'  
   ELSE NULL  
  END AS Tipo_Pagamento   
  
from [dbo].[tb_lancamentos_manuais] as a (NOLOCK)  
inner join [tb_aprovacao_lancamento_manual] as APV (NOLOCK)  
on alm_cd_lancamento_manual = tlm_cd_lancamento_manual  
   
left join tb_usuario as b (NOLOCK)  
on a.tlm_cd_usuario_criacao = b.usr_cd_usuario  
   
inner JOIN [dbo].[tb_tipos_lancamentos_manuais] AS TIP (NOLOCK) ON TIP.plm_cd_tipo_lancamento_manual = a.tlm_cd_tipo  
   
inner join tb_usuario as usu (NOLOCK)  
on usu.usr_nm_usuario = tlm_cd_motorista  
and usu.cli_cd_codigo_cliente = tlm_cd_cliente  
  
inner join tb_clientes as cli (NOLOCK)  
on usu.cli_cd_codigo_cliente = cli.cli_cd_codigo_cliente  

inner join (  
   
   select distinct ppr_cd_periodo ,pgp_dt_inicio,pgp_dt_fim,ppr_nome_motorista,ppr_cd_pgto_espelho,pgp_cd_cliente  
   from tb_pgto_periodo_rota as a (NOLOCK)  
   inner join tb_pgto_periodo as b (NOLOCK)  
   on a.ppr_cd_periodo = b.pgp_cd_periodo  
   WHERE b.pgp_in_excluido = 0  
    --and ppr_cd_pgto_espelho = 514274  
    --ppr_cd_pgto_espelho =   
   ) as periodo  
on periodo.ppr_nome_motorista = a.tlm_cd_motorista  
 AND periodo.pgp_cd_cliente = a.tlm_cd_cliente  
 AND CONVERT(DATE,tlm_dh_referencia) BETWEEN periodo.pgp_dt_inicio AND periodo.pgp_dt_fim  

LEFT JOIN tb_motorista AS MOT (NOLOCK) ON MOT.mot_cd_usuario = usu.usr_cd_usuario  
         AND MOT.mot_cd_cliente   = pgp_cd_cliente  
      
where a.tlm_in_ativo = 1  
AND APV.alm_ds_status = 'Aprovado'  
AND TIP.plm_nm_tipo = 'Apoio'  
and usu.usr_in_ativo = 1
--and cast(a.tlm_cd_lancamento_manual as varchar(50)) = 147106


---- Lançamentos Manuais - Apoio
--select	CONVERT(VARCHAR,a.tlm_dh_referencia,103) as Data
--		,cast(APO.tlm_cd_rota as varchar(50)) as Rota
--		,APO.Motorista AS tlm_cd_motorista
--		,a.tlm_cd_service_center AS Base
--		,NULL AS Placa
--		,APO.Origem
--		,APO.Descricao
--		,NULL AS veiculo
GO
