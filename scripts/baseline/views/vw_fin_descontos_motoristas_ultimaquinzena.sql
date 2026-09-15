-- ============================================================
-- BASELINE: dbo.vw_fin_descontos_motoristas_ultimaquinzena
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_fin_descontos_motoristas_ultimaquinzena]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_fin_descontos_motoristas_ultimaquinzena]
as

select
	*
from 
	vw_fin_descontos_motoristas
where
	DataReferencia >= case when DAY(getdate()) > 15 then dateadd(day,15,DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()) - 1, 0)) else DATEADD(MONTH, DATEDIFF(MONTH, 0, getdate()), 0) end
GO
