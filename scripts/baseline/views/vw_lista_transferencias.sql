-- ============================================================
-- BASELINE: dbo.vw_lista_transferencias
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_lista_transferencias]    Script Date: 14/09/2026 12:12:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_lista_transferencias] as 


select   

DataHoraEntrega	
,DataReferencia	
,IdTransportadora	
,IdRota	
,idpacote	
,SubStatus	
,StatusEntrega	
,TempoEntrega

from tb_lista_transferencias
GO
