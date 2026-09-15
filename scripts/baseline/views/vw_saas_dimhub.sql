-- ============================================================
-- BASELINE: dbo.vw_saas_dimhub
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_saas_dimhub]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_saas_dimhub]
as
select 
	IdStation
	,IdTransportadora
	,CodigoStation
	,NomeStation
	,IdCidade
	,IdCidadeReferencia
	,Cidade
	,Cep
	,Latitude
	,Longitude
	,Endereco
	,NomeContato
	,EmailContato
	,TelefoneContato
	,PropriaFrota
	,Estado
	,NomeAmigavel  
from 
	tb_spe_station with(nolock)
GO
