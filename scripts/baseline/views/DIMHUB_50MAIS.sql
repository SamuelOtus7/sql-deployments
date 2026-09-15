-- ============================================================
-- BASELINE: dbo.DIMHUB_50MAIS
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[DIMHUB_50MAIS]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[DIMHUB_50MAIS] AS 
select * from tb_spe_station where  idtransportadora = 20230007
GO
