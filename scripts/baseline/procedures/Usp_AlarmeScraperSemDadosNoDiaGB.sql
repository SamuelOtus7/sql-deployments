-- ============================================================
-- BASELINE: dbo.Usp_AlarmeScraperSemDadosNoDiaGB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeScraperSemDadosNoDiaGB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeScraperSemDadosNoDiaGB]

as

set nocount on

drop table if exists #aux 

select *
	into #aux
	from vw_status_coletas
	where tipo = 'Totalizadores'

if not exists (select * from #aux)
begin
	declare @mensagem varchar(250)
		set @mensagem = '*Alerta - ' + FORMAT(getdate(),'dd/MM/yyyy HH:mm:ss') + CHAR(10) + CHAR(10) 
		+ 'Não foram realizadas coletas para hoje até o momento.'
	-- print ( @mensagem) ;
	RAISERROR(@mensagem, 16, 1);
end



GO
