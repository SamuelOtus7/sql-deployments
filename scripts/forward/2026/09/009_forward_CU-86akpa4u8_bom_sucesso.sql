/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Reaponta o vinculo de Teresopolis/RJ (cliente Hawk Transportes,
                 66) do distrito 'Bonsucesso' para 'Bom Sucesso', que ja existe
                 em tb_fin_distritos_cadastrados. Corrige a grafia do local
                 cadastrado pelo script 007 sem criar nome duplicado nem alterar
                 o nome global 'Bonsucesso' (compartilhado entre clientes).
                 'Bonsucesso' fica sem referencia apos o reapontamento.
  Rollback     : scripts/rollback/2026/09/009_rollback_CU-86akpa4u8_bom_sucesso.sql
  Objetos      : dbo.tb_fin_definie_cidade_distrito (UPDATE fcd_cd_distrito)
  Dependências : dbo.tb_fin_distritos_cadastrados, dbo.tb_codigos_cidades,
                 dbo.tb_bases, dbo.vw_fin_definie_cidade_distrito,
                 dbo.UspGeraAtualizaCidadesDistanteDiaPacote
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. PRE-CHECKS: resolver cliente/cidade/base e os dois distritos
    --==========================================================================
    DECLARE @cd_cliente int = 66;   -- Hawk Transportes
    DECLARE @cd_cidade  int;
    DECLARE @cd_base    int;
    DECLARE @dist_origem  int;
    DECLARE @dist_destino int;

    SELECT @cd_cidade = cid_cd_cidade
    FROM dbo.tb_codigos_cidades
    WHERE cid_ds_cidade = N'Teresópolis'
      AND cid_cd_estado = 33; -- IBGE RJ

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

    IF @cd_cidade IS NULL OR @cd_base IS NULL OR @dist_destino IS NULL
        THROW 50020, 'Lookup nao resolvido (cidade, base SRJ5 ou distrito Bom Sucesso).', 1;

    IF @dist_origem IS NULL
        THROW 50021, 'Distrito origem Bonsucesso nao encontrado.', 1;

    --==========================================================================
    -- 2. UPDATE: reaponta o vinculo para o distrito correto (idempotente)
    --==========================================================================
    UPDATE f
    SET fcd_cd_distrito = @dist_destino
    FROM dbo.tb_fin_definie_cidade_distrito f
    WHERE f.fcd_cd_cliente  = @cd_cliente
      AND f.fcd_cd_cidade   = @cd_cidade
      AND f.fcd_cd_Base     = @cd_base
      AND f.fcd_cd_distrito = @dist_origem;

    DECLARE @atualizados int = @@ROWCOUNT;

    --==========================================================================
    -- 3. POS-CHECKS: vinculo aponta para Bom Sucesso; nao resta apontando p/ origem
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.tb_fin_definie_cidade_distrito f
        WHERE f.fcd_cd_cliente  = @cd_cliente
          AND f.fcd_cd_cidade   = @cd_cidade
          AND f.fcd_cd_Base     = @cd_base
          AND f.fcd_cd_distrito = @dist_destino
    )
        THROW 50022, 'Pos-check falhou: vinculo nao aponta para Bom Sucesso.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.tb_fin_definie_cidade_distrito f
        WHERE f.fcd_cd_cliente  = @cd_cliente
          AND f.fcd_cd_cidade   = @cd_cidade
          AND f.fcd_cd_Base     = @cd_base
          AND f.fcd_cd_distrito = @dist_origem
    )
        THROW 50023, 'Pos-check falhou: ainda ha vinculo apontando para Bonsucesso.', 1;

    PRINT 'Vinculos reapontados Bonsucesso -> Bom Sucesso: ' + CAST(@atualizados AS varchar);

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
