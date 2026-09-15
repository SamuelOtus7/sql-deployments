-- ============================================================
-- BASELINE: dbo.vw_monitoramento_mercadolivre
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_mercadolivre]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vw_monitoramento_mercadolivre]
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
	join tb_clientes cli with(nolock) on t.tpr_cd_transportadora = cli.cli_id_logistics
	left join (
		select
			cmt_cd_transportadora IdTransportadora,
			count(1) QtdeColeta,
			sum(cast(cmt_in_processado as int)) QtdeProcessado,
			sum(case when cmt_in_processado = 1 and cmt_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,
			max(cmt_dh_escrita) UltimaEscrita
		from
			db_Irisys_Json.dbo.tb_ml_coleta_totalizador with(nolock)
		where
			cmt_dh_referencia = cast(getdate() as date)
		group by
			cmt_cd_transportadora
	) c on t.tpr_cd_transportadora = c.IdTransportadora
	left join (
		select
			cmr_cd_transportadora IdTransportadora,
			count(1) QtdeColeta,
			sum(cast(cmr_in_processado as int)) QtdeProcessado,
			sum(case when cmr_in_processado = 1 and cmt_in_erro = 1 then 1 else 0 end) QtdeProcessadoComErro,
			max(cmr_dh_escrita) UltimaEscrita
		from
			db_Irisys_Json.dbo.tb_ml_coleta_rotas with(nolock)
		where
			cmr_dh_referencia = cast(getdate() as date)
		group by
			cmr_cd_transportadora
	) c2 on t.tpr_cd_transportadora = c2.IdTransportadora
	left join (
		select
			IdTransportadora,
			count(1) QtdeRotas
		from
			tb_ml_rotas with(nolock)
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
			tb_ml_pacotes with(nolock)
		where
			DataReferencia = cast(getdate() as date)
			and Excluido = 0
		group by
			IdTransportadora
	) p on t.tpr_cd_transportadora = p.IdTransportadora
where
	t.tpr_cd_marketplace = 1
	and cli.cli_in_ativo = 1
	and cli.cli_dt_ini_ml <= getdate()
	
GO
