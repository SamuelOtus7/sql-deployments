-- ============================================================
-- BASELINE: dbo.UspFinanceiroPreFaturaFM
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroPreFaturaFM]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinanceiroPreFaturaFM]  (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin


	SET NOCOUNT ON
	set dateformat dmy

	delete tb_fin_fm_prefatura where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena

	delete tb_fin_fm_prefatura 
	where IdTransportadora in (
		select 
			cli_id_logistics
		from tb_clientes 
		where cli_cd_codigo_cliente = @IdTransportadora
	)
	and Ano = @Ano 
	and Mes = @Mes 
	and Quinzena = @Quinzena
	
	


	drop table if exists #prefatura
	select distinct
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		Produto descricao,
		Pais id_rota,
		Transportadora data_inicio,
		Milha data_termino,
		id placa,
		Periodo motorista,
		-- TipoPreFatura quantidade,
		-- StatusPrefatura preco_unitario,
		total total
        
		into #prefatura 
	from 
		tb_fin_prefatura_fm_upload
	 where 
		IdTransportadora = @IdTransportadora
	and Ano = @Ano 
	and Mes = @Mes 
	and Quinzena = @Quinzena


	delete
		#prefatura
	where
		try_cast(id_rota as int) is null or id_rota = ''


	drop table if exists #prefatura_rodada_1
	select
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		dbo.fn_fin_trata_prefatura(descricao, 1) Veiculo,
		dbo.fn_fin_trata_prefatura(descricao, 2) ContinuacaoVeiculo,
		--null ContinuacaoVeiculo,
--		dbo.fn_fin_trata_prefatura(descricao, 3) ServiceCenter,
--		dbo.fn_fin_trata_prefatura(descricao, 6) KmCiclo,
--		dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
--		dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
		Id_Rota,
		data_inicio,
		data_termino,
		--cast(right(data_inicio,4) + '-' + SUBSTRING(data_inicio,4,2) + '-' + left(data_inicio,2) as date) data_inicio,
		--cast(right(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + left(data_termino,2) as date) data_termino,
		placa,
		motorista,
		-- cast(quantidade as tinyint) quantidade,
		-- cast(preco_unitario as decimal(7,2)) preco_unitario,
		cast(case when total = '' then '0.0' else total end as decimal(9,2)) total,
        -- Parada,
        -- VLParada
		descricao

	into #prefatura_rodada_1
	from
		#prefatura
	where dbo.fn_fin_trata_prefatura(descricao, 3) not like '%Visited%'
	and descricao not like 'Vehicle Daily Not Visited%'


	drop table if exists #prefatura_rodada_2
	select
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		Veiculo,
		ContinuacaoVeiculo,
		--null ContinuacaoVeiculo,
		dbo.fn_fin_trata_prefatura(descricao, 3) ServiceCenter,
		dbo.fn_fin_trata_prefatura(descricao, 6) KmCiclo,
--		dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
--		dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
		Id_Rota,
		data_inicio,
		data_termino,
		placa,
		motorista,
		-- cast(quantidade as tinyint) quantidade,
		-- cast(preco_unitario as decimal(7,2)) preco_unitario,
		total,
        -- Parada,
        -- VLParada
		descricao

	into #prefatura_rodada_2
	from
		#prefatura_rodada_1

	drop table if exists #prefatura_final
	select
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		Veiculo,
		ContinuacaoVeiculo,
		--null ContinuacaoVeiculo,
		ServiceCenter,
		KmCiclo,
		dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
		dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
		Id_Rota,
		data_inicio,
		data_termino,
		placa,
		motorista,
		-- cast(quantidade as tinyint) quantidade,
		-- cast(preco_unitario as decimal(7,2)) preco_unitario,
		total
        -- Parada,
        -- VLParada

	into #prefatura_final
	from
		#prefatura_rodada_2


	insert into tb_fin_fm_prefatura (IdTransportadora, Ano, Mes, Quinzena, Veiculo, ContinuacaoVeiculo, ServiceCenter
    , KmCiclo, CicloPM, IntervaloFaixa, InicioIntervalo, FimIntervalo, Dia, IdRota, DataInicio, DataTermino, Placa
    , Motorista,  Total, DataAtualizacao )

	select 
		distinct
		b.IdTransportadora
		,b.Ano
		,b.Mes
		,b.Quinzena
		,b.Veiculo
		,b.ContinuacaoVeiculo
		,b.ServiceCenter
		,b.KmCiclo
		,case b.KmCiclo
				when 'KMs RANGE' then 'AM'
				when 'PART TIME D ROUTE' then 'PM'
				when 'PART TIME ROUTE' then 'PM'
				when 'HOLIDAY DAY ROUTE' then 'AM'
				when 'SATURDAY DAY ROUTE' then 'AM'
				WHEN 'AMBULANCE' then null
			end CicloPM
		,b.IntervaloFaixa
		,case when left(b.IntervaloFaixa,CHARINDEX('/', b.IntervaloFaixa)-1) = 0 then 1 else left(b.IntervaloFaixa,CHARINDEX('/', b.IntervaloFaixa)-1) end InicioIntervalo
		,right(b.IntervaloFaixa,len(b.IntervaloFaixa)-CHARINDEX('/', b.IntervaloFaixa)) FimIntervalo
		,b.Dia
		,b.Id_Rota
		,b.data_inicio
		,b.data_termino
		,b.Placa
		,b.Motorista
		-- ,Quantidade
		-- ,preco_unitario
		,b.Total + isnull(h.Total,0) Total
        -- ,Parada
        -- ,VLParada
		,GETDATE() DataAtualizacao
	from
	(
		select
			IdTransportadora,
			Ano,
			Mes,
			Quinzena,
			Veiculo,
			ContinuacaoVeiculo,
			--null ContinuacaoVeiculo,
			ServiceCenter,
			KmCiclo,
			IntervaloFaixa,
			Dia,
			Id_Rota,
			data_inicio,
			data_termino,
			placa,
			motorista,
			-- cast(quantidade as tinyint) quantidade,
			-- cast(preco_unitario as decimal(7,2)) preco_unitario,
			total
            -- Parada,
            -- VLParada

		from
			#prefatura_final
			where Veiculo is not null
			and Veiculo <> 'Helpers'
	) b
	left join (
		select
			Id_Rota
			,total
		from
			#prefatura_final
		where 
			Veiculo = 'Helpers'
	) h on b.Id_Rota = h.Id_Rota
		

end
GO
