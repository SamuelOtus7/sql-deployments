/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akpa4u8
  Autor        : Devin
  Data         : 2026-09-25
  Descrição    : Reverte o forward 008: devolve os 18 locais de Teresopolis/RJ
                 (cliente Hawk Transportes, 66) de 'Suburbio' para 'Bairro' na
                 tb_fin_definie_cidade_distrito. Idempotente: so altera quem
                 esta como Suburbio.
  Forward ref  : scripts/forward/2026/09/008_forward_CU-86akpa4u8_regiao_suburbio.sql
  Objetos      : dbo.tb_fin_definie_cidade_distrito (UPDATE fcd_cd_regiao)
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    --==========================================================================
    -- 1. STAGING: mesmos 18 locais do forward
    --==========================================================================
    DECLARE @stage TABLE (
        base_sigla    nvarchar(100) NOT NULL,
        local_nome    varchar(50)   NOT NULL
    );

    INSERT INTO @stage (base_sigla, local_nome) VALUES
        (N'SRJ5', N'Albuquerque'),
        (N'SRJ5', N'Campanha'),
        (N'SRJ5', N'Campo Limpo'),
        (N'SRJ5', N'Granja Florestal'),
        (N'SRJ5', N'Jardim Europa'),
        (N'SRJ5', N'Jardim Salaco'),
        (N'SRJ5', N'Morro dos Pinheiros'),
        (N'SRJ5', N'Parque do Imbuí'),
        (N'SRJ7', N'Pessegueiros'),
        (N'SRJ5', N'Ponte Nova'),
        (N'SRJ5', N'Prata'),
        (N'SRJ5', N'Providência'),
        (N'SRJ5', N'Santa Rosa'),
        (N'SRJ6', N'Três Córregos'),
        (N'SRJ5', N'Vargem Grande'),
        (N'SRJ5', N'Várzea'),
        (N'SRJ5', N'Venda Nova'),
        (N'SRJ5', N'Vieira');

    --==========================================================================
    -- 2. PRE-CHECKS
    --==========================================================================
    DECLARE @cd_cliente int = 66;
    DECLARE @cd_cidade  int;
    DECLARE @rg_bairro   int;
    DECLARE @rg_suburbio int;

    SELECT @cd_cidade = cid_cd_cidade
    FROM dbo.tb_codigos_cidades
    WHERE cid_ds_cidade = N'Teresópolis'
      AND cid_cd_estado = 33;

    SELECT @rg_bairro = lst_cd_lista
    FROM dbo.tb_lista
    WHERE lst_nm_lista = 'Regiao de entrega'
      AND lst_ds_label = 'Bairro';

    SELECT @rg_suburbio = lst_cd_lista
    FROM dbo.tb_lista
    WHERE lst_nm_lista = 'Regiao de entrega'
      AND lst_ds_label = 'Suburbio';

    IF @cd_cidade IS NULL OR @rg_bairro IS NULL OR @rg_suburbio IS NULL
        THROW 50013, 'Lookup nao resolvido (cidade Teresopolis ou regiao Bairro/Suburbio).', 1;

    --==========================================================================
    -- 3. UPDATE reverso: Suburbio -> Bairro
    --==========================================================================
    UPDATE f
    SET fcd_cd_regiao = @rg_bairro
    FROM dbo.tb_fin_definie_cidade_distrito f
    WHERE f.fcd_cd_cliente  = @cd_cliente
      AND f.fcd_cd_cidade   = @cd_cidade
      AND f.fcd_cd_regiao   = @rg_suburbio
      AND EXISTS (
          SELECT 1
          FROM @stage s
          JOIN dbo.tb_bases b
              ON b.bss_ds_sigla = s.base_sigla
             AND b.bss_cod_cliente = @cd_cliente
             AND b.bss_in_excluido = 0
          JOIN dbo.tb_fin_distritos_cadastrados d
              ON d.NomeDistrito = s.local_nome
          WHERE b.bss_cd_base = f.fcd_cd_Base
            AND d.IdDistrito  = f.fcd_cd_distrito
      );

    DECLARE @revertidos int = @@ROWCOUNT;

    --==========================================================================
    -- 4. POS-CHECKS: os 18 devem voltar a Bairro
    --==========================================================================
    IF (
        SELECT COUNT(DISTINCT f.fcd_cod)
        FROM @stage s
        JOIN dbo.tb_bases b
            ON b.bss_ds_sigla = s.base_sigla
           AND b.bss_cod_cliente = @cd_cliente
           AND b.bss_in_excluido = 0
        JOIN dbo.tb_fin_distritos_cadastrados d
            ON d.NomeDistrito = s.local_nome
        JOIN dbo.tb_fin_definie_cidade_distrito f
            ON f.fcd_cd_cliente  = @cd_cliente
           AND f.fcd_cd_Base     = b.bss_cd_base
           AND f.fcd_cd_cidade   = @cd_cidade
           AND f.fcd_cd_distrito = d.IdDistrito
           AND f.fcd_cd_regiao   = @rg_bairro
    ) <> 18
        THROW 50014, 'Pos-check falhou: esperado 18 vinculos de volta como Bairro.', 1;

    PRINT 'Vinculos revertidos Suburbio -> Bairro: ' + CAST(@revertidos AS varchar);

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
