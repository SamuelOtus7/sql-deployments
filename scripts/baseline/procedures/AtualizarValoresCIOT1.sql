-- ============================================================
-- BASELINE: dbo.AtualizarValoresCIOT1
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[AtualizarValoresCIOT1]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AtualizarValoresCIOT1]
AS
BEGIN
    SET NOCOUNT ON;

    -- Variável para armazenar o valor total do pagamento
    DECLARE @vl_total DECIMAL(18, 2);

    -- Pega o valor total (mtn_vl_nfs) do motorista no período
    SELECT TOP 1 @vl_total = e.mtn_vl_nfs
    FROM tb_pag_espelhos e
    INNER JOIN tb_pgto_periodo p ON p.pgp_cd_periodo = e.mtn_cd_pgto_periodo
    WHERE e.mtn_nome_motorista LIKE 'BRUNNO DE OLIVEIRA QUIULO'
      AND p.pgp_dt_inicio >= '2025-03-01'
      AND p.pgp_dt_fim <= '2025-03-15'
	  AND e.mtn_cd_status = 35 
    ORDER BY mtn_cd_pgto_periodo DESC;
	select  @vl_total

    UPDATE tb_trg_CIOT
    SET ValorFrete = @vl_total,
        ValorImpostoSestSenat = @vl_total * 0.025,
        ValorImpostoINSS = @vl_total * 0.11,
        StatusProcesso = 30
    WHERE NomeMotorista = 'BRUNNO DE OLIVEIRA QUIULO'
      AND DataHoraInicio >= '2025-03-01'
      AND DataHoraTermino <= '2025-03-15';
END;
GO
