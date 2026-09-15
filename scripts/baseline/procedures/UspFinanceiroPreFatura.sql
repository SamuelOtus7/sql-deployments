-- ============================================================
-- BASELINE: dbo.UspFinanceiroPreFatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroPreFatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[UspFinanceiroPreFatura] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin
	
	SET NOCOUNT ON
	
	delete tb_fin_prefatura where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	delete tb_fin_prefatura_descontos where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	delete tb_fin_prefatura_descontos_not_visited where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	

	delete tb_fin_prefatura 
	where IdTransportadora in (
		select 
			cli_id_logistics
		from tb_clientes 
		where cli_cd_codigo_cliente = @IdTransportadora
	)
	and Ano = @Ano 
	and Mes = @Mes 
	and Quinzena = @Quinzena
	
	delete tb_fin_prefatura_descontos 
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
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		Produto descricao,
		Pais id_rota,
		Transportadora data_inicio,
		Milha data_termino,
		IDPrefatura placa,
		Periodo motorista,
		TipoPreFatura quantidade,
		StatusPrefatura preco_unitario,
		Column8 total,
        null Parada,
        null VLParada
        
		into #prefatura 
	from 
		tb_fin_prefatura_upload
	 where 
		IdTransportadora = @IdTransportadora
		and Ano = @Ano
		and Mes = @Mes
		and Quinzena = @Quinzena
	
		
	--1- Apaga registros em que não tem rota
	delete
		#prefatura
	where
		try_cast(id_rota as int) is null or id_rota = ''

	--1.1 Salva o que é desconto do motorista
	exec [dbo].[UspLoadDescontosPrefatura] @IdTransportadora, @Ano, @Mes,@Quinzena;
	--insert into tb_fin_prefatura_descontos (IdTransportadora, Ano, Mes, Quinzena, DataReferencia, IdRota, IdPacote, Descricao, Quantidade, PrecoUnitario, Total)
	--select distinct
	--	IdTransportadora,
	--	Ano,
	--	Mes,
	--	Quinzena,
	--	cast(right(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + left(data_termino,2) as date) data_termino,
	--	Id_Rota,
	--	reverse(left(reverse(descricao),CHARINDEX(' ', reverse(descricao))-1)) Pacote,
	--	left(descricao,CHARINDEX(':', descricao)-1) Penalidade,
	--	cast(quantidade as tinyint) quantidade,
	--	cast(preco_unitario as decimal(7,2)) preco_unitario,
	--	cast(total as decimal(7,2)) total
	--from
	--	#prefatura
	--where
	--	(descricao like '%pnr packages penalty%' or descricao like '%lost packages penalty%')
	--	;


	----Inserido em 21/03/2025 por Saulo Barros para salvar os descontos not visited dos motoristas
	--insert into tb_fin_prefatura_descontos_not_visited (IdTransportadora, Ano, Mes, Quinzena, DataReferencia, IdRota, Descricao, Quantidade, PrecoUnitario, Total)
	--select distinct
	--	IdTransportadora,
	--	Ano,
	--	Mes,
	--	Quinzena,
	--	cast(right(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + left(data_termino,2) as date) data_termino,
	--	Id_Rota,
	--	descricao,
	--	cast(quantidade as tinyint) quantidade,
	--	cast(preco_unitario as decimal(7,2)) preco_unitario,
	--	cast(total as decimal(7,2)) total
	--from
	--	#prefatura
	--where
	--	(descricao like '%Not Visited%')
	--	;

	
	update a
	set 
		 a.EnderecoNaoVisitado = 1

	from tb_fin_prefatura as a
	inner join (
		select *
		from #prefatura
		where descricao like 'Vehicle Daily Not Visited%'
	) as b
	on a.IdTransportadora = b.IdTransportadora
	and a.idrota = b.id_rota;



	--2- Apaga descrição com endereços visitados ou pacotes perdidos
	delete
		#prefatura
	where
		 descricao like 'Lost packages%' 
		or descricao like 'Pnr Packages Penalty%'
		--or descricao like 'Vehicle Daily Not Visited%'
		or descricao like 'Helpers%';
		

	--3- Atualiza caracateres 
	update
		#prefatura
	set
		descricao =	replace(replace(replace(replace(replace(descricao, 'UtilitÃ¡rio', 'Utilitário'), 'Ãºnica', 'única'), 'VeÃ­culo', 'Veículo'), ' â€“ ', ' – '),'MÃ©dio', 'Médio');

	-- Ajuste: Erro na execução: Internal error: An expression services limit has been reached. Please look for potentially complex expressions in your query, and try to simplify them.
	-- José Carlos
	-- Data: 26/02/2025
	DROP TABLE IF EXISTS #PreFaturaTrat1

	select
		IdTransportadora,
		Ano,
		Mes,
		Quinzena,
		dbo.fn_fin_trata_prefatura(descricao, 1) Veiculo,
		dbo.fn_fin_trata_prefatura(descricao, 2) ContinuacaoVeiculo,
		--null ContinuacaoVeiculo,
	--	dbo.fn_fin_trata_prefatura(descricao, 3) ServiceCenter,
	--	dbo.fn_fin_trata_prefatura(descricao, 6) KmCiclo,
	--	dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
	--	dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
		Id_Rota,
		cast(right(data_inicio,4) + '-' + SUBSTRING(data_inicio,4,2) + '-' + left(data_inicio,2) as date) data_inicio,
		cast(right(data_termino,4) + '-' + SUBSTRING(data_termino,4,2) + '-' + left(data_termino,2) as date) data_termino,
		placa,
		motorista,
		cast(quantidade as int) quantidade,
		cast(preco_unitario as decimal(7,2)) preco_unitario,
		cast(case when isnull(total,'') = '' then preco_unitario else total end as decimal(7,2)) total,
		Parada,
		VLParada,
		descricao
	INTO #PreFaturaTrat1
	from
		#prefatura
	where dbo.fn_fin_trata_prefatura(descricao, 3) not like '%Visited%'
	and descricao not like 'Vehicle Daily Not Visited%'

	DROP TABLE IF EXISTS #PreFaturaTrat2

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
	--	dbo.fn_fin_trata_prefatura(descricao, 4) IntervaloFaixa,
	--	dbo.fn_fin_trata_prefatura(descricao, 5) Dia,
		Id_Rota,
		data_inicio,
		data_termino,
		placa,
		motorista,
		quantidade,
		preco_unitario,
		total,
		Parada,
		VLParada,
		descricao
	INTO #PreFaturaTrat2
	FROM #PreFaturaTrat1

	DROP TABLE IF EXISTS #PreFaturaTrat

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
		quantidade,
		preco_unitario,
		total,
		Parada,
		VLParada
	INTO #PreFaturaTrat
	FROM #PreFaturaTrat2
	

	insert into tb_fin_prefatura (IdTransportadora, Ano, Mes, Quinzena, Veiculo, ContinuacaoVeiculo, ServiceCenter
    , KmCiclo, CicloPM, IntervaloFaixa, InicioIntervalo, FimIntervalo, Dia, IdRota, DataInicio, DataTermino, Placa
    , Motorista, Quantidade, PrecoUnitario, Total,Parada,VLParada, DataAtualizacao )
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
		,Quantidade
		,preco_unitario
		,Total
        ,Parada
        ,VLParada
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
			quantidade,
			preco_unitario,
			total,
            Parada,
            VLParada

		from
			#PreFaturaTrat
		where
			isnull(Veiculo,'') <> 'Not Processed'
	) base
	




	update 
		tb_fin_prefatura
	set
		IntervaloFaixa = '1/100',
		InicioIntervalo = 1
	where
		IntervaloFaixa = '0/100'
		and IdTransportadora = @IdTransportadora
		and Ano = @Ano
		and Mes = @Mes
		and Quinzena = @Quinzena


		    --4- Atualiza paradas
	update a
	set 
		 a.Parada = b.quantidade
		,a.VLParada = b.preco_unitario
	from tb_fin_prefatura as a
	inner join (
		select *
		from #prefatura
		where descricao like 'visited%' 
	) as b
	on a.IdTransportadora = b.IdTransportadora
	and a.idrota = b.id_rota;

	delete from #prefatura where descricao like 'visited%';

	
	update a
	set 
		 a.EnderecoNaoVisitado = 1

	from tb_fin_prefatura as a
	inner join (
		select *
		from #prefatura
		where descricao like 'Vehicle Daily Not Visited%'
	) as b
	on a.IdTransportadora = b.IdTransportadora
	and a.idrota = b.id_rota;

	delete from #prefatura where descricao like 'Vehicle Daily Not Visited%';
	

	--Atualiza Indicadores
	exec [UspFinanceiroAtualizaIndicadores] @IdTransportadora, @Ano, @Mes, @Quinzena, 'Prefatura'
	--atualiza financeiro
	--exec [UspAtualizaFinanceiro] @IdTransportadora, @Ano, @Mes, @Quinzena

end
GO
