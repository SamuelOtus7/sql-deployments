-- ============================================================
-- BASELINE: dbo.vw_usuario_hist
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_usuario_hist]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vw_usuario_hist]
as
select dateadd(hour,-3,ValidFrom) as Inicio,
	   dateadd(hour,-3,ValidTo) as Fim,
	   *
from tb_usuario_hist

GO
