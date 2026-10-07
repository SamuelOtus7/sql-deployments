/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Padroniza bfm_nm_cidade 'Bonsucesso' -> 'Bom Sucesso' na
                 tb_fin_base_frete_motorista para a Hawk Transportes
                 (bfm_cd_transportadora = 66, bfm_cd_codigo_cliente = 1261).
                 Apos o script 009, o cadastro usa 'Bom Sucesso'; sem esta
                 correcao o join por nome cidade x distrito nao casava.
                 Afeta as 3 linhas de frete (veiculos 14/17/18) da base SRJ5.
  Rollback     : scripts/rollback/2026/09/010_rollback_CU-86akpa4u8_frete_bom_sucesso.sql
  Objetos      : dbo.tb_fin_base_frete_motorista (UPDATE bfm_nm_cidade)
  Dependências : dbo.vw_fin_definie_cidade_distrito,
                 dbo.UspGeraAtualizaCidadesDistanteDiaPacote
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    DECLARE @transportadora int = 66;   -- Hawk Transportes
    DECLARE @codigo_cliente int = 1261; -- Hawk na base de frete

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_base_frete_motorista
        WHERE bfm_cd_transportadora = @transportadora
          AND bfm_cd_codigo_cliente = @codigo_cliente
          AND bfm_nm_cidade = N'Bonsucesso'
    )
        THROW 50030, 'Pre-check falhou: nenhuma linha de frete com cidade Bonsucesso para a Hawk.', 1;

    --==========================================================================
    -- 2. UPDATE: padroniza o nome da cidade (idempotente)
    --==========================================================================
    UPDATE b
    SET bfm_nm_cidade = N'Bom Sucesso'
    FROM dbo.tb_fin_base_frete_motorista b
    WHERE b.bfm_cd_transportadora = @transportadora
      AND b.bfm_cd_codigo_cliente = @codigo_cliente
      AND b.bfm_nm_cidade = N'Bonsucesso';

    DECLARE @atualizados int = @@ROWCOUNT;

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM dbo.tb_fin_base_frete_motorista
        WHERE bfm_cd_transportadora = @transportadora
          AND bfm_nm_cidade = N'Bonsucesso'
    )
        THROW 50031, 'Pos-check falhou: ainda ha frete com cidade Bonsucesso para a Hawk.', 1;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_base_frete_motorista
        WHERE bfm_cd_transportadora = @transportadora
          AND bfm_cd_codigo_cliente = @codigo_cliente
          AND bfm_nm_cidade = N'Bom Sucesso'
    )
        THROW 50032, 'Pos-check falhou: nenhuma linha de frete com cidade Bom Sucesso.', 1;

    PRINT 'Linhas de frete corrigidas Bonsucesso -> Bom Sucesso: ' + CAST(@atualizados AS varchar);

    COMMIT TRAN;
    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
