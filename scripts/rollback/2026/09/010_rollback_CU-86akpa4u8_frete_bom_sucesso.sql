/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Reverte o forward 010: devolve bfm_nm_cidade 'Bom Sucesso' ->
                 'Bonsucesso' na tb_fin_base_frete_motorista para a Hawk
                 (bfm_cd_transportadora = 66, bfm_cd_codigo_cliente = 1261).
                 Idempotente.
  Forward ref  : scripts/forward/2026/09/010_forward_CU-86akpa4u8_frete_bom_sucesso.sql
  Objetos      : dbo.tb_fin_base_frete_motorista (UPDATE bfm_nm_cidade)
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    DECLARE @transportadora int = 66;
    DECLARE @codigo_cliente int = 1261;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_base_frete_motorista
        WHERE bfm_cd_transportadora = @transportadora
          AND bfm_cd_codigo_cliente = @codigo_cliente
          AND bfm_nm_cidade = N'Bom Sucesso'
    )
        THROW 50033, 'Pre-check falhou: nenhuma linha de frete com cidade Bom Sucesso para a Hawk.', 1;

    --==========================================================================
    -- 2. UPDATE reverso
    --==========================================================================
    UPDATE b
    SET bfm_nm_cidade = N'Bonsucesso'
    FROM dbo.tb_fin_base_frete_motorista b
    WHERE b.bfm_cd_transportadora = @transportadora
      AND b.bfm_cd_codigo_cliente = @codigo_cliente
      AND b.bfm_nm_cidade = N'Bom Sucesso';

    DECLARE @revertidos int = @@ROWCOUNT;

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM dbo.tb_fin_base_frete_motorista
        WHERE bfm_cd_transportadora = @transportadora
          AND bfm_cd_codigo_cliente = @codigo_cliente
          AND bfm_nm_cidade = N'Bom Sucesso'
    )
        THROW 50034, 'Pos-check falhou: ainda ha frete com cidade Bom Sucesso para a Hawk.', 1;

    PRINT 'Linhas de frete revertidas Bom Sucesso -> Bonsucesso: ' + CAST(@revertidos AS varchar);

    COMMIT TRAN;
    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
