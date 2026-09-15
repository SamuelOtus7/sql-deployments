-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_novo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_novo]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_pacotes_spe_novo]
as
select
	rotas.Id IdRotaInterno,
	rotas.CodigoRota,
	pacotes.IdTransportadora,
	pacotes.CodigoPacote,
	pacotes.DataReferencia,
	t1.tds_ds_traducao StatusEntrega,
	t2.tds_ds_traducao SubStatus,
	pacotes.DataHoraEntrega,
	pacotes.DataAtualizacao,
	case when pacotes.URLImagem is not null then 'https://spx.shopee.com.br' + pacotes.URLImagem end URLImagem
from
	tb_spe_pacotes_novo pacotes with(nolock)
	left join tb_ml_traducoes t1 with(nolock) on pacotes.StatusEntrega = t1.tds_vl_json and t1.tds_nm_tabela = 'tb_spe_pacotes' and t1.tds_nm_campo = 'StatusEntrega'
	left join tb_ml_traducoes t2 with(nolock) on pacotes.SubStatus = t2.tds_vl_json and t2.tds_nm_tabela = 'tb_spe_pacotes' and t2.tds_nm_campo = 'SubStatus'
	join tb_spe_rotas_novo rotas with(nolock) on pacotes.IdTransportadora = rotas.IdTransportadora 
											and pacotes.CodigoRota = rotas.CodigoRota
											and pacotes.DataReferencia = rotas.DataReferencia
GO
