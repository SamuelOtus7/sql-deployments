-- ============================================================
-- BASELINE: dbo.UspReprocessaRotasErro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspReprocessaRotasErro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  
 PROCEDURE [dbo].[UspReprocessaRotasErro]
(
    @CodPeriodoPagamento INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.tb_pgto_periodo_rota_erro
    WHERE pre_cd_periodo = @CodPeriodoPagamento;

END;
GO
