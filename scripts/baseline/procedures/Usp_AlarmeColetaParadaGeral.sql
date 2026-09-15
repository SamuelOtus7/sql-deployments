-- ============================================================
-- BASELINE: dbo.Usp_AlarmeColetaParadaGeral
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeColetaParadaGeral]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Usp_AlarmeColetaParadaGeral] as 

Declare @dataref date = getdate()
		 ,@QTDref int = 2000
		 ,@QTDParada int

select @QTDParada = (select count(*) from db_Irisys_Json.dbo.tb_ml_coleta_rotas where cmr_dh_referencia >= dateadd(DAY,-4,@dataref)  and cmt_dh_processamento is null)

IF @QTDParada > @QTDref
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000);

    
    SET @mensagem = '*Coleta Parada*' +  CHAR(10)
    +'Estamos com '  + CAST(@QTDParada AS VARCHAR(15)) + ' Pacotes sem processamento para inserir na tb_ml_pacotes, Necessário verificar o job DriveAnalytics - Carrega Pacotes - Instance 01' +  CHAR(10) +  CHAR(10) 

  --select @mensagem
    RAISERROR(@mensagem, 16, 1);
END;
GO
