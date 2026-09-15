-- ============================================================
-- BASELINE: dbo.vw_monitoramento_shopee
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_shopee]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vw_monitoramento_shopee]
as

select
	t.tpr_nome_transportadora Transportadora,
	isnull(c.QtdeColeta, 0) QtdeColetaTotalizador,
	isnull(c.QtdeProcessado, 0) QtdeColetaTotalizadorProcessado,
	isnull(c.QtdeProcessadoComErro, 0) QtdeColetaTotalizadorProcessadoComErro,
	c.UltimaEscrita UltimaEscritaTotalizador,
	isnull(c2.QtdeColeta, 0) QtdeColetaRotas,
	isnull(c2.QtdeProcessado, 0) QtdeColetaRotasProcessado,
	isnull(c2.QtdeProcessadoComErro, 0) QtdeColetaRotasProcessadoComErro,
	c2.UltimaEscrita UltimaEscritaRotas,
	isnull(r.QtdeRotas, 0) QtdeRotasGeradas,
	isnull(p.QtdePacotes, 0) QtdePacotesGerados
from
	tb_dra_transportadora t with(nolock)
	left join (
		select
			dac_cd_transportadora IdTransportadora,
			count(1) QtdeColeta,
			sum(cast(dac_in_processado as int)) QtdeProcessado,
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,
			max(dac_dh_escrita) UltimaEscrita
		from
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)
		where
			dac_ds_tipo_coleta = 'SP2_ROUTES'
			and dac_dh_referencia = cast(getdate() as date)
		group by
			dac_cd_transportadora
	) c on t.tpr_cd_transportadora = c.IdTransportadora
	left join (
		select
			dac_cd_transportadora IdTransportadora,
			count(1) QtdeColeta,
			sum(cast(dac_in_processado as int)) QtdeProcessado,
			sum(case when dac_in_processado = 1 and dac_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,
			max(dac_dh_escrita) UltimaEscrita
		from
			db_Irisys_Json.dbo.tb_dra_coleta with(nolock)
		where
			dac_ds_tipo_coleta = 'SP2_ROUTES_DETAILS'
			and dac_dh_referencia = cast(getdate() as date)
		group by
			dac_cd_transportadora
	) c2 on t.tpr_cd_transportadora = c2.IdTransportadora
	left join (
		select
			IdTransportadora,
			count(1) QtdeRotas
		from
			tb_spe_rotas_novo with(nolock)
		where
			DataReferencia = cast(getdate() as date)
			and Excluido = 0
		group by
			IdTransportadora
	) r on t.tpr_cd_transportadora = r.IdTransportadora
	left join (
		select
			IdTransportadora,
			count(1) QtdePacotes
		from
			tb_spe_pacotes_novo with(nolock)
		where
			DataReferencia = cast(getdate() as date)
			--and Excluido = 0
		group by
			IdTransportadora
	) p on t.tpr_cd_transportadora = p.IdTransportadora
where
	t.tpr_cd_marketplace = 2
	and t.tpr_cd_transportadora = 20230006
	
GO
