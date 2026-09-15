-- ============================================================
-- BASELINE: dbo.Usp_AlarmeScraperSemDadosNoDia
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeScraperSemDadosNoDia]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeScraperSemDadosNoDia]

as

--set nocount on

drop table if exists #aux 

select *
	into #aux
	from vw_status_coletas
	where tipo = 'Totalizadores'

if not exists (select * from #aux)
begin
	declare @mensagem varchar(250)
		set @mensagem = '*Alerta - ' + FORMAT(getdate(),'dd/MM/yyyy HH:mm:ss') + '*\n'
		+ 'Não foram realizadas coletas para hoje até o momento.'
	--exec Usp_SendSlackMessage @mensagem
	print ( @mensagem) ;

end


GO
