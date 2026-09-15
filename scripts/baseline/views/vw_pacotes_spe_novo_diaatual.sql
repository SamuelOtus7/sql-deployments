-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_novo_diaatual
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_novo_diaatual]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_pacotes_spe_novo_diaatual]
as
select
	*
from
	vw_pacotes_spe_novo
where
	DataReferencia = cast(getdate() as date)

GO
