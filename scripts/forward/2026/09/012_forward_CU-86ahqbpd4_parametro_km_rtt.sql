/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahqbpd4
  Autor        : Devin
  Data         : 2026-09-28
  Descrição    : Habilita o parâmetro 'Km RTT' (categoria 'Alertas', valor 'true')
                 para todos os clientes que recebem coleta RTT do Looker
                 (tb_stg_looker_rtt), evidência de 2026-09-28:
                 clientes 11, 27, 59, 61, 64, 66, 73.
                 Script idempotente: atualiza linhas existentes para 'true' e
                 insere o parâmetro caso o cliente não o possua.
                 Estado anterior em PROD (2026-09-28): apenas cliente 27 estava
                 com 'false'; demais já estavam 'true'.
  Rollback     : scripts/rollback/2026/09/012_rollback_CU-86ahqbpd4_parametro_km_rtt.sql
  Objetos      : dbo.tb_parametros (dados)
  Dependências : nenhuma
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_parametros'))
        THROW 50007, 'Tabela dbo.tb_parametros não encontrada.', 1;

    DECLARE @Clientes TABLE (prm_cod_cliente int PRIMARY KEY);
    INSERT INTO @Clientes (prm_cod_cliente)
    VALUES (11), (27), (59), (61), (64), (66), (73);

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    -- 2.1 Habilita 'Km RTT' = 'true' onde o parâmetro já existe
    UPDATE p
    SET p.prm_ds_valor              = 'true',
        p.prm_cd_usuario_modificacao = 7,
        p.prm_dh_modificacao         = GETDATE()
    FROM dbo.tb_parametros p
    INNER JOIN @Clientes c ON c.prm_cod_cliente = p.prm_cod_cliente
    WHERE p.prm_nm_parametro = 'Km RTT'
      AND ISNULL(p.prm_ds_valor, '') <> 'true';

    PRINT 'Parâmetro Km RTT habilitado em ' + CAST(@@ROWCOUNT AS varchar(10)) + ' cliente(s) existente(s).';

    -- 2.2 Insere o parâmetro para clientes da lista que ainda não o possuem
    --     (mesmo padrão das linhas vigentes: options Sim/Não, usuário 7)
    INSERT INTO dbo.tb_parametros (
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
        prm_cod_cliente
    )
    SELECT
        'Km RTT',
        'Km RTT',
        'Km RTT',
        'true',
        '',
        '[{"label":"Sim","value":"true"},{"label":"Não","value":"false"}]',
        'Alertas',
        'select',
        1,
        0,
        7,
        GETDATE(),
        7,
        GETDATE(),
        c.prm_cod_cliente
    FROM @Clientes c
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.tb_parametros p
        WHERE p.prm_nm_parametro = 'Km RTT'
          AND p.prm_cod_cliente  = c.prm_cod_cliente
    );

    PRINT 'Parâmetro Km RTT criado em ' + CAST(@@ROWCOUNT AS varchar(10)) + ' cliente(s).';

    --==========================================================================
    -- 3. POS-CHECKS
    --==========================================================================
    IF EXISTS (
        SELECT 1
        FROM @Clientes c
        WHERE NOT EXISTS (
            SELECT 1
            FROM dbo.tb_parametros p
            WHERE p.prm_nm_parametro = 'Km RTT'
              AND p.prm_cod_cliente  = c.prm_cod_cliente
              AND p.prm_ds_valor     = 'true'
              AND p.prm_in_ativo     = 1
              AND p.prm_in_excluido  = 0
        )
    )
        THROW 50008, 'Pós-check falhou: há cliente(s) da lista sem Km RTT habilitado.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
