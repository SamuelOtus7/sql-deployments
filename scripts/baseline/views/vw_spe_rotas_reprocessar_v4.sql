-- ============================================================
-- BASELINE: dbo.vw_spe_rotas_reprocessar_v4
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_spe_rotas_reprocessar_v4]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vw_spe_rotas_reprocessar_v4] 
as 

select distinct 
 a.codigorota 
,a.idtransportadora
,b.idstation

from tb_spe_pacotes_v4 as a
inner join tb_spe_rotas_v4 as b
on a.codigorota = b.codigorota
and a.IdTransportadora = b.IdTransportadora
and a.datareferencia = b.datareferencia

where a.datareferencia  = '2024-03-27'
and a.IdTransportadora = 20230010
and a.StatusEntrega = 'Assigned'
--and a.CodigoRota = 'AT20240326104VL'
and datediff(MINUTE,a.DataAtualizacao,getdate()) >= 30
GO
