-- ============================================================
-- BASELINE: dbo.Usp_AlarmeAcaoGPS
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeAcaoGPS]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Usp_AlarmeAcaoGPS] 
as

Declare @dataref date = getdate() 
 
IF Isnull((select count(*) qtd  
from [dbo].[tb_acao_gps] as a
where cast(agp_dh_data_hora as date)   = @dataref
group by cast(agp_dh_data_hora as date)),0) = 0

BEGIN
    DECLARE @mensagem VARCHAR(2000);
	
 
    SET @mensagem =  'Não está entrando dados na tabela tb_acao_gps, verificar tb_azure_acaoGPS na procedure [UspAtualizaAcaoGPS]. Se não tiver dados, acionar o time e dev para verificar a function.' +  CHAR(10) +  CHAR(10) 
       
 --select @mensagem
  RAISERROR(@mensagem, 16, 1);
END


GO
