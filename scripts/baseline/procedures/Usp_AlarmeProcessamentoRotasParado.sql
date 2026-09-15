-- ============================================================
-- BASELINE: dbo.Usp_AlarmeProcessamentoRotasParado
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeProcessamentoRotasParado]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Usp_AlarmeProcessamentoRotasParado] as 

Declare @dataref date = getdate()
		 ,@QTDref int = 1000
		 ,@QTDParada int

select @QTDParada = (select count(*) from db_Irisys_Json.dbo.tb_ml_coleta_totalizador where cmt_dh_referencia >= dateadd(DAY,-4,@dataref)  and cmt_dh_processamento is null)

IF @QTDParada > @QTDref
BEGIN
    DECLARE @coleta VARCHAR(1000);
    DECLARE @mensagem VARCHAR(2000);

    
    SET @mensagem = '*Processamento de rotas parado*' +  CHAR(10)
    +'Estamos com '  + CAST(@QTDParada AS VARCHAR(15)) + ' Rotas sem processamento para inserir na tb_ml_rotas, Necessário verificar o job DriveAnalytics - Carrega Rotas' +  CHAR(10) +  CHAR(10) 

  --select @mensagem
    RAISERROR(@mensagem, 16, 1);
END;
GO
