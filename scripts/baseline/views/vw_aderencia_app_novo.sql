-- ============================================================
-- BASELINE: dbo.vw_aderencia_app_novo
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_aderencia_app_novo]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_aderencia_app_novo] as   
select distinct    
DataReferencia   
,NomeMotorista   
,ServiceCenter   
,Base   
,KmColetado   
,LinkMapa   
,TenantId   
,Apontamentos   
,StatusApontamento   
,PossuiUsuario   
,dateadd(hour,-3,UltimoAcesso)  as UltimoAcesso 
,convert(varchar(103),UltimaRota ) as UltimaRota
,ListaFiltro
from tb_aderencia_app_novo nolock

GO
