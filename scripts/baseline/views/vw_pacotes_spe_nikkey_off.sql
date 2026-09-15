-- ============================================================
-- BASELINE: dbo.vw_pacotes_spe_nikkey_off
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pacotes_spe_nikkey_off]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_pacotes_spe_nikkey_off]
as
select
	*
from
	vw_pacotes_spe
where
	IdTransportadora = 20230004
GO
