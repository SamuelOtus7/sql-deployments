-- ============================================================
-- BASELINE: dbo.UspFinanceiroPreFaturaLH
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroPreFaturaLH]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--================================================
-- Autor: Saulo Barros
-- Data de Criação: 13/05/2025
-- Descrição: Carrega a prefatura do LineHaul
--==================================================
CREATE procedure [dbo].[UspFinanceiroPreFaturaLH]  (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin

	--declare @IdTransportadora int = 1726310024
	--declare @Ano int = 2026
	--declare @Mes tinyint = 4
	--declare @Quinzena tinyint = 1

	SET NOCOUNT ON
	set dateformat dmy

	delete tb_fin_lh_prefatura where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena


	drop table if exists #prefatura
	select 
		distinct
		IdTransportadora
		,Ano
		,Mes
		,Quinzena
		,Produto
		,Pais IdRota
		,Transportadora NomeRota
		,Milha DataInicio
		,IDPreFatura DataTermino
		,Periodo Placa
		,TipoPreFatura Motorista
		,Status Quantidade
		,PrecoUnitario PrecoUnitario
		,Total
		into #prefatura 
	from 
		tb_fin_prefatura_lh_upload
	 where 
		IdTransportadora = @IdTransportadora
		and Ano = @Ano 
		and Mes = @Mes 
		and Quinzena = @Quinzena
	

	-- apaga informações não relevantes
	delete
		#prefatura
	where
		try_cast(IdRota as int) is null 
		or IdRota = ''
		or IdRota is null

		
	insert into tb_fin_lh_prefatura (IdTransportadora, Ano, Mes, Quinzena, TipoVeiculo, ServiceCenter, IdRota, NomeRota, DataInicio, DataTermino, Dia, Placa, Motorista, Quantidade, PrecoUnitario, Total)
	select 
		IdTransportadora
		,Ano
		,Mes
		,Quinzena
		,cast(ltrim(rtrim(left(Produto,charindex(' - ', Produto)))) as varchar(100)) TipoVeiculo
		,reverse(
			left(
				reverse(replace(replace(NomeRota,'_CPT_NM_OW',''),'.SOW.XPT','')),
				case when charindex('_', reverse(replace(replace(NomeRota,'_CPT_NM_OW',''),'.SOW.XPT',''))) > 0 then
					charindex('_', reverse(replace(replace(NomeRota,'_CPT_NM_OW',''),'.SOW.XPT','')))
				else
					charindex('-', reverse(replace(replace(NomeRota,'_CPT_NM_OW',''),'.SOW.XPT','')))
				end
				-1
			)
		) ServiceCenter
		,cast(IdRota as int) IdRota
		,cast(NomeRota as varchar(80)) NomeRota
		,cast(right(DataInicio,4) + '-' + SUBSTRING(DataInicio,4,2) + '-' + left(DataInicio,2) as date) DataInicio
		,cast(right(DataTermino,4) + '-' + SUBSTRING(DataTermino,4,2) + '-' + left(DataTermino,2) as date) DataTermino
		,cast(case when Produto like '%SATURDAY DAY ROUTE%' then 'Sábado' else case when Produto like '%HOLIDAY DAY ROUTE%' then 'Domingo' end end as varchar(10)) Dia
		,cast(Placa as varchar(20)) Placa
		,cast(Motorista as varchar(100)) Motorista
		,cast(Quantidade as int) Quantidade
		,TRY_CAST(PrecoUnitario as decimal(7,2)) PrecoUnitario
		,TRY_CAST(Total AS DECIMAL(7,2)) AS Total
	from 
		#prefatura

		
end
		

	
GO
