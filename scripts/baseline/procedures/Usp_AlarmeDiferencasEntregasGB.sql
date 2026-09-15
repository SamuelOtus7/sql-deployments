-- ============================================================
-- BASELINE: dbo.Usp_AlarmeDiferencasEntregasGB
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeDiferencasEntregasGB]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Usp_AlarmeDiferencasEntregasGB]

as

--set nocount on

drop table if exists #aux 

select *
into #aux
from vw_DiferencasPacotes
where abs(cast(Delta as float) / cast(QtdePacotes as float)) > 0.2

if exists (select * from #aux)
begin
	declare @rotas varchar(1000)
	declare @mensagem varchar(2000)
	Select @rotas = SUBSTRING( 
	( 
		 SELECT CHAR(10) + cast(idrota as varchar(10)) AS 'data()'
			 FROM #aux 
			 FOR XML PATH('') 
			 
	), 2 , 9999)

	--set @rotas = right(@rotas,len(@rotas) - 2)
	
	set @mensagem = '*[Diferença pacotes]*' + CHAR(10)
		+ 'As rotas abaixo estão com diferenças entre os valores do totalizador com os valores das rotas: ' + CHAR(10) + CHAR(10)
		+ @rotas

	RAISERROR(@mensagem, 16, 1);

end

GO
