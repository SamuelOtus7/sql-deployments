-- ============================================================
-- BASELINE: dbo.UspFinanceiroPreFaturaMO
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroPreFaturaMO]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--1662443209,2025,03,01
CREATE procedure [dbo].[UspFinanceiroPreFaturaMO] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin
	
	SET NOCOUNT ON
	



	delete tb_fin_mo_prefatura where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena

	delete tb_fin_mo_prefatura 
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
		tb_fin_prefatura_mo_upload
	 where 
		IdTransportadora = @IdTransportadora
		and Ano = @Ano
		and Mes = @Mes
		and Quinzena = @Quinzena;



	delete
		#prefatura
	where
		try_cast(id_rota as int) is null or id_rota = '';    


		drop table if exists #teste_rodada_1
		select
			IdTransportadora,
			Ano,
			Mes,
			Quinzena,
			dbo.fn_fin_trata_prefatura(descricao, 1) Veiculo,
			dbo.fn_fin_trata_prefatura(descricao, 2) ContinuacaoVeiculo,
			--null ContinuacaoVeiculo,
--			dbo.fn_fin_trata_prefatura(descricao, 3) ServiceCenter,
--			dbo.fn_fin_trata_prefatura(descricao, 6) KmCiclo,
--			dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
--			dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
			Id_Rota,
			cast(right(data_inicio,4) + '-' + SUBSTRING(data_inicio,4,2) + '-' + left(data_inicio,2) as date) data_inicio,
			cast(right(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + left(data_termino,2) as date) data_termino,
			placa,
			motorista,
			-- cast(quantidade as tinyint) quantidade,
			-- cast(preco_unitario as decimal(7,2)) preco_unitario,
			cast(total as decimal(7,2)) total,
            -- Parada,
            -- VLParada
			descricao

			into #teste_rodada_1

		from
			#prefatura
		where dbo.fn_fin_trata_prefatura(descricao, 3) not like '%Visited%'
		and descricao not like 'Vehicle Daily Not Visited%'
		and descricao not like '%Penalty%'

		drop table if exists #teste_rodada_2
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
--			dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
--			dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
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

			into #teste_rodada_2

		from
			#teste_rodada_1


		drop table if exists #teste
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

			into #teste

		from
			#teste_rodada_2

drop table if exists #teste2
select distinct
		IdTransportadora
		,Ano
		,Mes
		,Quinzena
		,Veiculo
		,ContinuacaoVeiculo
		,ServiceCenter
		,KmCiclo
		,case KmCiclo
				when 'KMs RANGE' then 'AM'
				when 'PART TIME D ROUTE' then 'PM'
				when 'PART TIME ROUTE' then 'PM'
				when 'HOLIDAY DAY ROUTE' then 'AM'
				when 'SATURDAY DAY ROUTE' then 'AM'
				WHEN 'AMBULANCE' then null
			end CicloPM
		,IntervaloFaixa
		,case when left(IntervaloFaixa,CHARINDEX('/', IntervaloFaixa)-1) = 0 then 1 else left(IntervaloFaixa,CHARINDEX('/', IntervaloFaixa)-1) end InicioIntervalo
		,right(IntervaloFaixa,len(IntervaloFaixa)-CHARINDEX('/', IntervaloFaixa)) FimIntervalo
		,Dia
		,Id_Rota
		,data_inicio
		,data_termino
		,Placa
		,Motorista
		-- ,Quantidade
		-- ,preco_unitario
		,Total
        -- ,Parada
        -- ,VLParada
		,GETDATE() DataAtualizacao
		into #teste2
	from #teste

	insert into tb_fin_mo_prefatura (IdTransportadora, Ano, Mes, Quinzena, Veiculo, ContinuacaoVeiculo, ServiceCenter
    , KmCiclo, CicloPM, IntervaloFaixa, InicioIntervalo, FimIntervalo, Dia, IdRota, DataInicio, DataTermino, Placa
    , Motorista,  Total, DataAtualizacao )


	select * from #teste2

        end
GO
