-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_vetor_diaatual_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_vetor_diaatual_off]    Script Date: 14/09/2026 12:12:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE view [dbo].[vw_pacotes_spe_vetor_diaatual_off]
as
select
	*
from
	vw_pacotes_spe_vetor
where
	DataReferencia = cast(getdate() as date)
	and 1 = 0

GO
