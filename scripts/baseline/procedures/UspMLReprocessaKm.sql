-- ============================================================
-- BASELINE: dbo.UspMLReprocessaKm
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessaKm]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 11/03/2026
-- Description:	Reprocessa km de rotas que foram enviadas para tabela tb_ml_processamento_km_rotas
--				porém os kms estão zerados.
-- =============================================
CREATE procedure [dbo].[UspMLReprocessaKm]
as
begin

	SET NOCOUNT ON;

	--Atualiza código do IdKmProcessado caso não exista mais
	update
		r
	set
		r.IdKmProcessado = km.Id
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_processamento_km_rotas km with(nolock) on r.IdRota = km.IdRota
		left join tb_ml_processamento_km_rotas km2 with(nolock) on r.IdKmProcessado = km2.id
	where
		r.Excluido = 0 
		and r.StatusRota <> 'planned'
		and r.DataReferencia >= dateadd(day,-5,cast(getdate() as date))
		and r.IdKmProcessado is not null
		and km2.id is null


	drop table if exists #rotas_reprocessar_km
	select
		p.IdRota
		into #rotas_reprocessar_km
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_processamento_km_rotas p with(nolock) on r.IdRota = p.Idrota
	where
		r.excluido = 0  
		and StatusRota = 'close'  
  		and DataReferencia >= dateadd(day,-5,cast(getdate() as date))
		and r.PacotesEntregues > 0
		and p.pontosAppRotasTotalKm = 0 
		and p.pontosRotasPacotesKm = 0
		and p.processamento = 1

		
	update
		k
	set
		k.processamento = 0
	from
		tb_ml_processamento_km_rotas k
		join #rotas_reprocessar_km r on k.IdRota = r.Idrota


	--reprocessa também rotas que tiveram apontamento do app porém conta com km vazio
	update
		p
	set
		processamento = 0
	from
		tb_ml_rotas r with(nolock)
		join tb_ml_processamento_km_rotas p with(nolock) on r.IdRota = p.IdRota
	where
		r.Excluido = 0
		and r.StatusRota <> 'planned' 
		and isnull(r.SubStatusRota,'') <> 'cancelled' 
		and r.DataReferencia >= dateadd(day,-5,cast(getdate() as date))
		and r.UsouAPP = 'Sim'
		and r.KmColetadoApp = 0
		and p.pontosAppRotasTotalkm = 0

end
GO
