/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-02
  Descrição    : Habilita o parametro 'Habilitar PNR BSC' = 1 em tb_parametros
                 para todos os clientes elegiveis do fluxo PNR — aqueles com
                 dados recentes na staging dbo.tb_looker_pnr (ultimos 30 dias)
                 e mapeados em tb_clientes — que ainda nao possuem o parametro
                 ativo. Sem ele, USPTrataStagingPNRBSC filtra a carga e
                 tb_pnr_bsc so recebia o cliente 61 (Rodoprime).

                 Clientes impactados nesta execucao (elegiveis sem o parametro):
                 11 (50 Mais), 27 (Flight Cargo), 59 (MSR Transportes),
                 64 (OnTime Log), 66 (Hawk Transportes), 69 (ADO), 73 (Pantera).
                 Cliente 61 (Rodoprime) ja estava habilitado.

                 O INSERT e idempotente (NOT EXISTS) e replica os demais campos
                 da linha modelo do cliente 61 (prm_cd_parametro = 7563).
  Rollback     : scripts/rollback/2026/10/024_rollback_CU-86akqxyka_pnr_bsc_todos_clientes.sql
  Objetos      : dbo.tb_parametros (INSERT)
  Dependências : dbo.tb_looker_pnr, dbo.tb_clientes, dbo.tb_parametros
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_parametros'))
        THROW 50050, 'Tabela dbo.tb_parametros nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_looker_pnr'))
        THROW 50051, 'Tabela dbo.tb_looker_pnr nao encontrada.', 1;
    IF NOT EXISTS (
        SELECT 1 FROM dbo.tb_parametros
        WHERE prm_nm_parametro = N'Habilitar PNR BSC'
          AND prm_ds_categoria = N'Financeiro - Pagamentos'
          AND prm_ds_valor = N'1'
          AND prm_cod_cliente = 61
    )
        THROW 50052, 'Linha modelo do parametro (cliente 61) nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. INSERT — parametro para clientes elegiveis que ainda nao possuem
--==========================================================================
INSERT INTO dbo.tb_parametros
(
    prm_nm_parametro,
    prm_ds_parametro,
    prm_ds_chave,
    prm_ds_valor,
    prm_ds_placeholder,
    prm_ds_options,
    prm_ds_categoria,
    prm_ds_tipo,
    prm_in_ativo,
    prm_in_excluido,
    prm_cd_usuario_criacao,
    prm_dh_criacao,
    prm_cd_usuario_modificacao,
    prm_dh_modificacao,
    prm_cod_cliente,
    prm_cod_operacao
)
SELECT
    N'Habilitar PNR BSC',
    N'Automatiza lancamentos manuais de PNR faturado via BSC',
    N'Habilitar PNR BSC',
    N'1',
    NULL,
    N'[{"label":"Ativo","value":"1"},{"label":"Inativo","value":"0"}]',
    N'Financeiro - Pagamentos',
    N'select',
    1,
    0,
    7,
    GETDATE(),
    7,
    GETDATE(),
    s.CodigoCliente,
    NULL
FROM
(
    SELECT DISTINCT s.CodigoCliente
    FROM dbo.tb_looker_pnr AS s WITH (NOLOCK)
    WHERE s.DataExtracao >= DATEADD(DAY, -30, GETDATE())
) AS s
INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
    ON c.cli_cd_codigo_cliente = s.CodigoCliente
WHERE c.cli_id_logistics IS NOT NULL
  AND NOT EXISTS
  (
      SELECT 1
      FROM dbo.tb_parametros AS p
      WHERE p.prm_nm_parametro = N'Habilitar PNR BSC'
        AND p.prm_ds_categoria = N'Financeiro - Pagamentos'
        AND p.prm_cod_cliente = s.CodigoCliente
        AND p.prm_ds_valor = N'1'
        AND p.prm_in_ativo = 1
        AND ISNULL(p.prm_in_excluido, 0) = 0
  );
GO

--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    DECLARE @elegiveis INT, @habilitados INT;

    SELECT @elegiveis = COUNT(DISTINCT s.CodigoCliente)
    FROM dbo.tb_looker_pnr AS s WITH (NOLOCK)
    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
        ON c.cli_cd_codigo_cliente = s.CodigoCliente
    WHERE s.DataExtracao >= DATEADD(DAY, -30, GETDATE())
      AND c.cli_id_logistics IS NOT NULL;

    SELECT @habilitados = COUNT(DISTINCT s.CodigoCliente)
    FROM dbo.tb_looker_pnr AS s WITH (NOLOCK)
    INNER JOIN dbo.tb_clientes AS c WITH (NOLOCK)
        ON c.cli_cd_codigo_cliente = s.CodigoCliente
    INNER JOIN dbo.tb_parametros AS p WITH (NOLOCK)
        ON p.prm_cod_cliente = s.CodigoCliente
       AND p.prm_nm_parametro = N'Habilitar PNR BSC'
       AND p.prm_ds_categoria = N'Financeiro - Pagamentos'
       AND p.prm_ds_valor = N'1'
       AND p.prm_in_ativo = 1
       AND ISNULL(p.prm_in_excluido, 0) = 0
    WHERE s.DataExtracao >= DATEADD(DAY, -30, GETDATE())
      AND c.cli_id_logistics IS NOT NULL;

    IF @habilitados < @elegiveis
        THROW 50053, 'Clientes elegiveis sem parametro habilitado.', 1;

    PRINT 'SUCESSO: Script executado com sucesso. Elegiveis habilitados: '
        + CAST(@habilitados AS varchar(10)) + '/' + CAST(@elegiveis AS varchar(10));
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
