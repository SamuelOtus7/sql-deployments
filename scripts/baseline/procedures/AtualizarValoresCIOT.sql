-- ============================================================
-- BASELINE: dbo.AtualizarValoresCIOT
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[AtualizarValoresCIOT]    Script Date: 14/09/2026 12:14:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AtualizarValoresCIOT]
    @DataInicio DATE,
    @DataFim DATE
AS
BEGIN
    SET NOCOUNT ON;

    
    DECLARE @NomeMotorista NVARCHAR(255);
    DECLARE @vl_total DECIMAL(18, 2);

    DECLARE cur_motoristas CURSOR FOR
        SELECT DISTINCT e.mtn_nome_motorista
        FROM tb_pag_espelhos e
        INNER JOIN tb_pgto_periodo p ON p.pgp_cd_periodo = e.mtn_cd_pgto_periodo
        WHERE p.pgp_dt_inicio = @DataInicio
          AND p.pgp_dt_fim = @DataFim
          AND (e.mtn_cd_status = 35 or e.mtn_cd_status = 37)
		  AND e.mtn_cod_cliente = 47;

    OPEN cur_motoristas;
    FETCH NEXT FROM cur_motoristas INTO @NomeMotorista;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT TOP 1 @vl_total = e.mtn_vl_nfs
        FROM tb_pag_espelhos e
        INNER JOIN tb_pgto_periodo p ON p.pgp_cd_periodo = e.mtn_cd_pgto_periodo
        WHERE e.mtn_nome_motorista = @NomeMotorista
          AND p.pgp_dt_inicio = @DataInicio
          AND p.pgp_dt_fim = @DataFim
          AND (e.mtn_cd_status = 35 or e.mtn_cd_status = 37)
		  AND e.mtn_cod_cliente = 47
        ORDER BY e.mtn_cd_pgto_periodo DESC;

        UPDATE tb_trg_CIOT
        SET ValorFrete = @vl_total,
            ValorImpostoSestSenat = @vl_total * 0.025,
            ValorImpostoINSS = @vl_total * 0.11,
            StatusProcesso = 30
        WHERE NomeMotorista = @NomeMotorista
          AND DataHoraInicio >= @DataInicio
          AND DataHoraTermino <= @DataFim
		  AND StatusProcesso <> 51;

        FETCH NEXT FROM cur_motoristas INTO @NomeMotorista;
    END;

    CLOSE cur_motoristas;
    DEALLOCATE cur_motoristas;

END;
UPDATE p
SET p.Valor = c.ValorFrete
FROM tb_trg_CIOTParcelas p
INNER JOIN tb_trg_CIOT c ON p.IdCiot = c.IdCiot

GO
