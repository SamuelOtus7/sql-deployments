-- ============================================================
-- BASELINE: dbo.UspAtualizaDriverId
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaDriverId]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Saulo Barros
-- Create date: 23/03/2026
-- Description:	Atualiza DriverId das rotas que não coletou essa informação
-- =============================================
CREATE PROCEDURE [dbo].[UspAtualizaDriverId] (
	@DataInicio date = null
	,@DataFim date = null
	,@IdTransportadora int = null
	,@IdRota int = null
)
AS
BEGIN
	
	SET NOCOUNT ON;

	set @DataInicio = case when @DataInicio is null then dateadd(day,-15,cast(getdate() as date)) else @DataInicio end
	set @DataFim = case when @DataFim is null then cast(getdate() as date) else @DataFim end
    
	update
		r
	set
		r.DriverId = h.dhr_nr_motorista
	from
		tb_dra_historico_rotas h
		join tb_ml_rotas r on h.dhr_nr_rota = r.idrota and h.dhr_cd_cliente = r.idtransportadora
	where
		r.DriverId is null
		and r.Excluido = 0
		and dhr_dt_data between @DataInicio and @DataFim
		and (r.IdTransportadora = @IdTransportadora or @IdTransportadora is null)
		and (r.IdRota = @IdRota or @IdRota is null)

END
GO
