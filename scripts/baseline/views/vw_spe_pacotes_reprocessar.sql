-- ============================================================
-- BASELINE: dbo.vw_spe_pacotes_reprocessar
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_pacotes_reprocessar]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_spe_pacotes_reprocessar]
as

select 
distinct
top 800
	p.CodigoPacote,
	p.Idtransportadora,
	p.IdStation


from	tb_spe_pacotes_para_reprocessar p
	left join db_Irisys_Json.dbo.tb_dra_coleta c on p.CodigoPacote = c.dac_ds_contexto 
							and p.IdTransportadora = c.dac_cd_transportadora
							and c.dac_ds_tipo_coleta = 'SP_PACKAGE_HISTORY'
							and c.dac_dh_escrita >= cast(getdate() as date)
where 
	c.dac_cd_coleta is null
--	and p.IdStation <> 7087

GO
