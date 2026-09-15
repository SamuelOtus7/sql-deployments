-- ============================================================
-- BASELINE: dbo.UspMLLoadVeiculos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLLoadVeiculos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspMLLoadVeiculos](
	@JSON VARCHAR(max),
	@Transportadora varchar(20),
	@DataColeta datetime
)
as
begin
	
	SET NOCOUNT ON
	

	drop table if exists #veiculos
	CREATE TABLE #veiculos (
		[IdVeiculo] [int] NOT NULL,
		[IdTransportadora] int not null,
		[Placa] varchar(7) not NULL,
		[IdTipo] int not NULL,
		[Tipo] [varchar](60) not NULL,
		[Capacidade] decimal(5,2) null,
		[Tracao] bit not NULL,
		[QuantidadePlacaUtilizacao] tinyint NOT NULL,
		[UltimaAtualizacao] [datetime] NULL,
		DataColeta [datetime] not NULL
	)

	insert into #veiculos
	select 
		id IdVeiculo
		,@Transportadora IdTransportadora
		,Placa
		,IdTipo
		,replace(replace(replace(replace(replace(Tipo, 'UtilitÃ¡rio', 'Utilitário'), 'Ãºnica', 'única'), 'VeÃ­culo', 'Veículo'), ' â€“ ', ' – '),'MÃ©dio', 'Médio') Tipo
		,cast(Capacidade as decimal(5,2)) Capacidade
		,case when Tracao = 'true' then 1 else 0 end Tracao
		,QuantidadePlacaUtilizacao
		,getdate()
		,@DataColeta
	from
		OPENJSON(@JSON)
	WITH
		(
			id int '$.id'
			,Placa varchar(7) '$.name'
			,IdTipo int '$.typeId'
			,Tipo varchar(60) '$.type'
			,Capacidade varchar(10) '$.capacity'
			,Tracao varchar(20) '$.isTraction'
			,QuantidadePlacaUtilizacao tinyint '$.quantityPlates'
		)

		
		
	merge tb_ml_veiculos as v
	using #veiculos as i
		ON v.IdVeiculo = i.IdVeiculo and v.IdTransportadora = i.IdTransportadora
	when matched then
	update set
		v.Placa = i.Placa
		,v.IdTipo = i.IdTipo
		,v.Tipo = i.Tipo
		,v.Capacidade = i.Capacidade
		,v.Tracao = i.Tracao
		,v.QuantidadePlacaUtilizacao = i.QuantidadePlacaUtilizacao
		,v.UltimaAtualizacao = i.UltimaAtualizacao
		,v.DataColeta = i.DataColeta
	when not matched by target then 
	insert (
			IdVeiculo
			,IdTransportadora
			,Placa
			,IdTipo
			,Tipo
			,Capacidade
			,Tracao
			,QuantidadePlacaUtilizacao
			,UltimaAtualizacao
			,DataColeta
	) values (
			IdVeiculo
			,IdTransportadora
			,Placa
			,IdTipo
			,Tipo
			,Capacidade
			,Tracao
			,QuantidadePlacaUtilizacao
			,UltimaAtualizacao
			,DataColeta
	);



end
GO
