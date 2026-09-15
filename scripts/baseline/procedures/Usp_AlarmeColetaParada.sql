-- ============================================================
-- BASELINE: dbo.Usp_AlarmeColetaParada
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeColetaParada]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeColetaParada]
as

set nocount on

if datepart(hour,getdate()) between 8 and 19 
begin
	
	declare @tolerancia_minutos int = 15
	
	drop table if exists #aux
	create table #aux (Transportadora varchar(30) not null, UltimaEscrita datetime null, Tipo varchar(100) not null)

    --parado enquanto não tivermos a informação de rotas e packages do shopee
	-- insert into #aux
	-- select 
	-- 	Transportadora, 
	-- 	isnull(UltimaEscritaPackages,'1900-12-31'), 
	-- 	'Routes Shopee' Tipo
	-- from 
	-- 	vw_monitoramento_shopee_v4
	-- where
	-- 	DATEDIFF(minute,isnull(UltimaEscritaPackages,'1900-12-31'),getdate()) >= @tolerancia_minutos

    --parado enquanto não tivermos a informação de rotas e packages do shopee
	-- insert into #aux
	-- select 
	-- 	Transportadora, 
	-- 	isnull(UltimaEscritaPackages,'1900-12-31'),
	-- 	'Packages Shopee' Tipo
	-- from 
	-- 	vw_monitoramento_shopee_v4
	-- where
	-- 	DATEDIFF(minute,isnull(UltimaEscritaPackages,'1900-12-31'),getdate()) >= @tolerancia_minutos

	--insert into #aux
	--select 
	--	Transportadora, 
	--	isnull(UltimaEscritaTotalizador,'1900-12-31'), 
	--	'Totalizador Shopee V3' Tipo
	--from 
	--	vw_monitoramento_shopee
	--where
	--	DATEDIFF(minute,isnull(UltimaEscritaTotalizador,'1900-12-31'),getdate()) >= @tolerancia_minutos

	--insert into #aux
	--select 
	--	Transportadora, 
	--	isnull(UltimaEscritaRotas,'1900-12-31'),
	--	'Rotas Shopee V3' Tipo
	--from 
	--	vw_monitoramento_shopee
	--where
	--	DATEDIFF(minute,isnull(UltimaEscritaRotas,'1900-12-31'),getdate()) >= @tolerancia_minutos

	insert into #aux
	select 
		Transportadora, 
		isnull(UltimaEscritaTotalizador,'1900-12-31'),
		'Totalizador Mercado Livre' Tipo
	from 
		vw_monitoramento_mercadolivre
	where
		DATEDIFF(minute,isnull(UltimaEscritaTotalizador,'1900-12-31'),getdate()) >= @tolerancia_minutos


	insert into #aux
	select 
		Transportadora, 
		isnull(UltimaEscritaRotas,'1900-12-31'),
		'Rotas Mercado Livre' Tipo
	from 
		vw_monitoramento_mercadolivre
	where
		DATEDIFF(minute,isnull(UltimaEscritaRotas,'1900-12-31'),getdate()) >= @tolerancia_minutos

		
	if exists (select * from #aux)
	begin
		
		declare @coleta varchar(1000)
		declare @mensagem varchar(2000)
		Select @coleta = SUBSTRING( 
		( 
			 SELECT '\n' + Transportadora + ': ' + FORMAT(UltimaEscrita,'dd/MM/yyyy HH:mm:ss') + ' Tipo: ' + Tipo AS 'data()'
				 FROM #aux 
				 FOR XML PATH('') 
			 
		), 2 , 9999)

		set @mensagem = '*[Coleta Parada]*\n'
			+ 'As Transportadoras abaixo estão a mais de ' + cast(@tolerancia_minutos as varchar(15)) + ' minutos sem atualizar:\'
			+ @coleta

		exec Usp_SendSlackMessage @mensagem
		--print @mensagem

end

end

GO
