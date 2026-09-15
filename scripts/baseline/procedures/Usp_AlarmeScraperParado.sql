-- ============================================================
-- BASELINE: dbo.Usp_AlarmeScraperParado
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeScraperParado]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeScraperParado]

as

set nocount on

if datepart(minute,getdate()) <> 0
begin
	
	declare @Tolerancia int = 10 * 60
	drop table if exists #aux 

	select *
	into #aux
	from vw_status_coletas
	where tipo = 'Totalizadores'

	if exists (select * from #aux where tipo = 'Totalizadores' and SegundosDesdeAUltimaColeta > @Tolerancia)
	begin
		declare @svcs varchar(1000)
		declare @mensagem varchar(2000)
		Select @svcs = SUBSTRING( 
		( 
			 SELECT '\n' + ServiceCenter AS 'data()'
				 FROM #aux 
				 where SegundosDesdeAUltimaColeta > @Tolerancia
				 and tipo = 'Totalizadores'
				 FOR XML PATH('') 
			 
		), 2 , 9999)

		set @mensagem = '*Alerta - ' + FORMAT(getdate(),'dd/MM/yyyy HH:mm:ss') + '*\n'
			+ 'Os Service Centers abaixo estão a mais de ' + cast(round(@Tolerancia / 60,0) as varchar(15)) + ' minutos sem enviar registros para o banco de dados:\'
			+ @svcs

		--exec Usp_SendSlackMessage @mensagem
		select @mensagem

end

end

GO
