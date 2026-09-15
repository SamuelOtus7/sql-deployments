-- ============================================================
-- BASELINE: dbo.vw_spe_vld_rotas_pacotes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_vld_rotas_pacotes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_spe_vld_rotas_pacotes] as 

WITH cte_prefatura AS
(
    SELECT
        56 AS TenantId,
        20230019 AS IdTransportadora,
        'Parceiro' AS Cliente,
        'LH' AS Operacao,
        '2026-05-Q1' AS Quinzena,
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee AS Pacote
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_parceiro_lh

    UNION ALL

    SELECT
        52,
        20230013,
        'DJM',
        'LM',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_djm

    UNION ALL

    SELECT
        66,
        20230025,
        'Hawk',
        'LM',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_hawk

    UNION ALL

    SELECT
        66,
        20230025,
        'Hawk',
        'LM XPT',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_hawk_xpt

    UNION ALL

    SELECT
        62,
        20230021,
        'Optimize',
        'LM',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_optimize

    UNION ALL

    SELECT
        62,
        20230021,
        'Optimize',
        'LM XPT',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_optimize_xpt

    UNION ALL

    SELECT
        32,
        20230010,
        'Única',
        'LM',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_unica

    UNION ALL

    SELECT
        65,
        20230023,
        'JMT Log',
        'LM XPT',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_jmt

    UNION ALL

    SELECT
        65,
        20230023,
        'JMT HLEXPRESS',
        'LM XPT',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_jmt_hl

    UNION ALL

    SELECT
        65,
        20230023,
        'JMT Transmarale',
        'LM XPT',
        '2026-05-Q2',
        Rota,
        Tracking_Number_Numero_Etiqueta_Ordem_Shopee
    FROM [10.1.1.21,1483].IrisysFiscal.dbo.tb_carga_prefatura_jmt_tra

    UNION ALL

    SELECT
        70,
        20230027,
        'Versan',
        'LM',
        '2026-05-Q1',
        Rota,
        TrackingNumber
    FROM STG_VERSAN_LAST_MILE_HUB
)
 
, Resultado as
(
	select
		p.TenantId
		,p.IdTransportadora
		,p.Cliente
		,p.Operacao
		,p.Quinzena

		,count(distinct p.Rota) as QtdeRotasPrefatura
		,count(distinct r.CodigoRota) - sum(case when NomeHub = 'Informação não enviada pela Shopee' then 1 else 0 end) as RotasColetadas
		,sum(case when NomeHub = 'Informação não enviada pela Shopee' then 1 else 0 end) as RotasPacote
		,count(distinct p.Rota) - count(distinct r.CodigoRota) as RotasNaoIdentificadas
	from
		cte_prefatura p
		left join tb_spe_rotas_v5 r with(nolock) 
			on p.IdTransportadora = r.IdTransportadora
			and p.Rota = r.CodigoRota
			and r.Excluido = 0

		left join tb_spe_pacotes_v5 p2 with(nolock) 
			on r.IdTransportadora = p2.IdTransportadora
			and r.CodigoRota = p2.CodigoRota
			and p.Pacote = p2.CodigoPacote
			and p2.Excluido = 0

		left join tb_spe_pacotes_lh p3 with(nolock) 
			on r.IdTransportadora = p3.IdTransportadora
			and r.CodigoRota = p3.CodigoRota
			and p.Pacote = p3.CodigoPacote
	group by
		p.TenantId
		,p.IdTransportadora
		,p.Cliente
		,p.Operacao
		,p.Quinzena
)

select
	r.TenantId
	,r.IdTransportadora
	,r.Cliente
	,r.Operacao
	,replace(replace(R.Quinzena,'Q2','16'),'Q1','01') AS Quinzena
	,v.Ordem
	,v.Indicador
	,v.Quantidade
from
	Resultado r
	cross apply
	(
		values
			(1, 'QtdeRotasPrefatura', r.QtdeRotasPrefatura)
			,(2, 'RotasColetadas', r.RotasColetadas)
			,(3, 'RotasPacote', r.RotasPacote)
			,(4, 'RotasNaoIdentificadas', r.RotasNaoIdentificadas)
	) v(Ordem, Indicador, Quantidade)
--order by
--	r.QtdeRotasPrefatura desc
--	,r.Cliente
--	,r.Operacao
--	,v.Ordem;
 
GO
