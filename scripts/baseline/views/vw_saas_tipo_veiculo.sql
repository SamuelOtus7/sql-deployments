-- ============================================================
-- BASELINE: dbo.vw_saas_tipo_veiculo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_tipo_veiculo]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vw_saas_tipo_veiculo]
as
select
	tvl_cd_tipo_veiculo CodigoTipoVeiculo
	, tvl_nm_tipo_veiculo NomeVeiculo
from
	tb_dra_tipo_veiculo v with(nolock)
	

GO
