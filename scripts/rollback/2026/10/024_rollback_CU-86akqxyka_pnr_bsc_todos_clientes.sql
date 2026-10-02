/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-02
  Descrição    : Remove de tb_parametros as linhas 'Habilitar PNR BSC' criadas
                 pelo forward 024 para os clientes elegiveis (11, 27, 59, 64,
                 66, 69, 73). O cliente 61 (Rodoprime) tinha o parametro antes
                 do deploy e e preservado — o DELETE e restrito aos clientes
                 que o script habilitou.
                 Efeito: USPTrataStagingPNRBSC volta a carregar tb_pnr_bsc
                 apenas para o cliente 61.
  Forward ref  : scripts/forward/2026/10/024_forward_CU-86akqxyka_pnr_bsc_todos_clientes.sql
  Objetos      : dbo.tb_parametros (DELETE escopado)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_parametros'))
        THROW 50054, 'Tabela dbo.tb_parametros nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. DELETE — remove apenas os clientes habilitados pelo forward (61 preservado)
--==========================================================================
DELETE FROM dbo.tb_parametros
WHERE prm_nm_parametro = N'Habilitar PNR BSC'
  AND prm_ds_categoria = N'Financeiro - Pagamentos'
  AND prm_cod_cliente IN (11, 27, 59, 64, 66, 69, 73);
GO

--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    DECLARE @habilitados INT;

    SELECT @habilitados = COUNT(DISTINCT prm_cod_cliente)
    FROM dbo.tb_parametros
    WHERE prm_nm_parametro = N'Habilitar PNR BSC'
      AND prm_ds_valor = N'1'
      AND prm_in_ativo = 1
      AND ISNULL(prm_in_excluido, 0) = 0;

    IF @habilitados <> 1
        THROW 50055, 'Rollback incompleto: clientes alem do 61 ainda habilitados.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso. Clientes habilitados: ' + CAST(@habilitados AS varchar(10));
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
