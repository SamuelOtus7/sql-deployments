/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Reverte o forward 009: devolve o vinculo de Teresopolis/RJ
                 (cliente Hawk Transportes, 66) do distrito 'Bom Sucesso' para
                 'Bonsucesso'. Idempotente: so altera quem aponta para o
                 distrito destino.
  Forward ref  : scripts/forward/2026/09/009_forward_CU-86akpa4u8_bom_sucesso.sql
  Objetos      : dbo.tb_fin_definie_cidade_distrito (UPDATE fcd_cd_distrito)
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    DECLARE @cd_cliente int = 66;
    DECLARE @cd_cidade  int;
    DECLARE @cd_base    int;
    DECLARE @dist_origem  int;
    DECLARE @dist_destino int;

    SELECT @cd_cidade = cid_cd_cidade
    FROM dbo.tb_codigos_cidades
    WHERE cid_ds_cidade = N'Teresópolis'
      AND cid_cd_estado = 33;

    SELECT @cd_base = bss_cd_base
    FROM dbo.tb_bases
    WHERE bss_ds_sigla = N'SRJ5'
      AND bss_cod_cliente = @cd_cliente
      AND bss_in_excluido = 0;

    SELECT @dist_origem = IdDistrito
    FROM dbo.tb_fin_distritos_cadastrados
    WHERE NomeDistrito = N'Bonsucesso';

    SELECT @dist_destino = IdDistrito
    FROM dbo.tb_fin_distritos_cadastrados
    WHERE NomeDistrito = N'Bom Sucesso';

    IF @cd_cidade IS NULL OR @cd_base IS NULL OR @dist_origem IS NULL OR @dist_destino IS NULL
        THROW 50024, 'Lookup nao resolvido (cidade, base ou distritos).', 1;

    --==========================================================================
    -- 2. UPDATE reverso: Bom Sucesso -> Bonsucesso
    --==========================================================================
    UPDATE f
    SET fcd_cd_distrito = @dist_origem
    FROM dbo.tb_fin_definie_cidade_distrito f
    WHERE f.fcd_cd_cliente  = @cd_cliente
      AND f.fcd_cd_cidade   = @cd_cidade
      AND f.fcd_cd_Base     = @cd_base
      AND f.fcd_cd_distrito = @dist_destino;

    DECLARE @revertidos int = @@ROWCOUNT;

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_definie_cidade_distrito f
        WHERE f.fcd_cd_cliente  = @cd_cliente
          AND f.fcd_cd_cidade   = @cd_cidade
          AND f.fcd_cd_Base     = @cd_base
          AND f.fcd_cd_distrito = @dist_origem
    )
        THROW 50025, 'Pos-check falhou: vinculo nao voltou para Bonsucesso.', 1;

    PRINT 'Vinculos revertidos Bom Sucesso -> Bonsucesso: ' + CAST(@revertidos AS varchar);

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
