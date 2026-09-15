-- ============================================================
-- BASELINE: dbo.UspSpeProcessamentoKmRotas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSpeProcessamentoKmRotas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSpeProcessamentoKmRotas]
as 

declare @datainicio date = cast(getdate()-1 as date)
declare @datafim date = cast(getdate() as date)

insert into tb_spe_processamento_km_rotas (idrota) 
select
	distinct codigorota
from tb_spe_rotas_v5 as a

left join tb_spe_processamento_km_rotas as b
on a.codigorota = b.idrota

where 1=1
--and  IdTransportadora in (20230009,20230016)
and DataReferencia between @datainicio and @datafim
and excluido = 0
and KmApp is null
and b.idrota is null


GO
