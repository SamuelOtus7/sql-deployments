-- ============================================================
-- BASELINE: dbo.UspMLCorrigeRotasExcluidasV3
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLCorrigeRotasExcluidasV3]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLCorrigeRotasExcluidasV3]

as 
begin

	
	declare @DataReferencia date = dateadd(day,-2,cast(getdate() as date))

	drop table if exists #rotas
	select
		IdRota
		,IdTransportadora
		into #rotas
	from
		tb_ml_rotas with(nolock)
	where
		DataReferencia >= @DataReferencia
	
		
	-- altera as rotas e pacotes que tiveram 5 tentativas de reprocessamento histótica com 404 para excluído
	drop table if exists #rotas_404
	select 
		distinct
		cast(substring(dec_ds_contexto,charindex('routes/',dec_ds_contexto,1) + 7,10 ) as int) as IdRota
		,cast(dec_cd_transportadora as int) IdTransportadora
		into #rotas_404
	from 
		tb_dra_erros_coleta a with(nolock)
		join #rotas r on cast(substring(a.dec_ds_contexto,charindex('routes/',a.dec_ds_contexto,1) + 7,10 ) as int) = r.IdRota
	where 
		dec_ds_tipo_coleta = 'ML_SC_ROUTE_HISTORY'
		and dec_ds_erro = 'Error: Request failed with status code 404'
		and dec_nr_tentativas =  5
		and (cast(dec_dt_referencia as date) >= @DataReferencia or cast(dec_dh_escrita as date) >= @DataReferencia)
		
	
	update
		rotas
	set
		rotas.Excluido = 1
	from
		tb_ml_rotas rotas
		join #rotas_404 Status404 on rotas.IdRota = Status404.IdRota and rotas.IdTransportadora = Status404.IdTransportadora
	where 
		rotas.PacotesEntregues = 0

	update
		pacotes
	set
		pacotes.Excluido = 1
	from
		tb_ml_pacotes pacotes
		join #rotas_404 Status404 on pacotes.IdRota = Status404.IdRota and pacotes.IdTransportadora = Status404.IdTransportadora

		
		--Marcando como excluído rotas que não tiveram pacotes  -- Matheus 25/07/25 -- task id 86aa1ctuq 
	UPDATE 
		rotas
	SET 
		rotas.excluido = 1
	FROM 
		tb_ml_rotas rotas
		left join tb_dra_historico_rotas hist on rotas.IdRota = hist.dhr_nr_rota
											and rotas.IdTransportadora = hist.dhr_cd_cliente
	WHERE 
		rotas.excluido = 0
		AND (rotas.PacotesEntregues = 0 and rotas.PacotesTransferidos = 0)
		AND rotas.IdTransportadora <> 678279205  -- Incluído por solicitação da transportadora
		AND rotas.StatusRota <> 'planned'
		AND rotas.datareferencia >= CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)
		and rotas.datareferencia < cast(getdate() as date)
		and hist.dhr_cd_historico_rota is null


		
	--Marcando como excluído rotas que não tiveram pacotes independente do status  
	UPDATE 
		rotas
	SET 
		rotas.excluido = 1
	FROM 
		tb_ml_rotas rotas
		left join tb_dra_historico_rotas hist on rotas.IdRota = hist.dhr_nr_rota
											and rotas.IdTransportadora = hist.dhr_cd_cliente
	WHERE 
		rotas.excluido = 0
		AND (rotas.PacotesEntregues = 0 and rotas.PacotesTransferidos = 0)
		--AND rotas.StatusRota <> 'planned'
		AND rotas.IdTransportadora <> 678279205  -- Incluído por solicitação da transportadora
		AND rotas.datareferencia >= CAST(DATEADD(DAY, -3, GETDATE()) AS DATE)
		and rotas.datareferencia <= CAST(DATEADD(DAY, -2, GETDATE()) AS DATE)
		and hist.dhr_cd_historico_rota is null
end


GO
