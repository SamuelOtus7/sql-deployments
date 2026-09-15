-- ============================================================
-- BASELINE: dbo.UspReprocessaEspelhosErro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspReprocessaEspelhosErro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [dbo].[UspReprocessaEspelhosErro]
(
    @CodPeriodoPagamento INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.tb_pag_espelhos_erros
    WHERE pee_cd_periodo = @CodPeriodoPagamento;

END;
GO
