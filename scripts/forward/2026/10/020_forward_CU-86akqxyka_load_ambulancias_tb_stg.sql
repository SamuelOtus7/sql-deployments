/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Altera dbo.UspLoadAmbulanciasLooker para ler da nova staging
                 dbo.tb_stg_looker_ambulancias (a antiga stg_looker_ambulancias
                 foi substituída). A nova fonte tem schema diferente:

                 Mapeamentos (nova staging -> tb_looker_ambulancias):
                 - DATA           -> amb_data (PARSE 'pt-BR', mantido filtro D-15)
                 - ID_ROTA        -> amb_id_rota / chave do MERGE
                 - SVC            -> amb_svc
                 - CodigoCliente  -> amb_codigocliente + join tb_clientes
                                     (cli_id_logistics / cli_ds_nome)
                 - timestamp      -> amb_data_etl
                 - rotas_pagas    -> amb_pagamento ('Sim'/'Não', mesma convenção
                                     dos valores já gravados no destino)

                 Sem equivalente na nova staging (colunas removidas da fonte):
                 - ID_MOTORISTA   -> amb_id_motorista = -1 (sentinela; coluna
                                     NOT NULL no destino)
                 - STATUS         -> amb_status = '-' (mesmo padrão do ISNULL
                                     anterior)
                 - MOTIVO         -> amb_motivo = NULL (coluna nullable)

                 Colunas novas sem destino (ignoradas): MLP, REGIONAL, VEICULO,
                 planejada_no_dia, rotas_nao_pagas, filename.

                 Filtros mantidos: cli_id_logistics IS NOT NULL e DATA >= D-15.
                 Removido: filtro "id_motorista IS NOT NULL" (coluna não existe
                 mais na fonte).
  Rollback     : scripts/rollback/2026/10/020_rollback_CU-86akqxyka_load_ambulancias_tb_stg.sql
  Objetos      : dbo.UspLoadAmbulanciasLooker (CREATE OR ALTER PROCEDURE)
  Dependências : dbo.tb_stg_looker_ambulancias (fonte), dbo.tb_clientes,
                 dbo.tb_looker_ambulancias (destino), dbo.UspUpdateAmbulanciasLooker
                 (executada ao final para propagar p/ tb_ml_rotas/tb_ml_mo_rotas/
                 tb_ml_fm_rotas)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_stg_looker_ambulancias'))
        THROW 50010, 'Tabela dbo.tb_stg_looker_ambulancias nao encontrada.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_looker_ambulancias'))
        THROW 50011, 'Tabela dbo.tb_looker_ambulancias nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. SCRIPT PRINCIPAL
--==========================================================================
CREATE OR ALTER PROCEDURE [dbo].[UspLoadAmbulanciasLooker]
AS
BEGIN
    SET NOCOUNT off;

    BEGIN TRY
        BEGIN TRANSACTION;

        WITH cte_ambulancias_looker AS (
            SELECT DISTINCT *
            FROM [dbo].[tb_stg_looker_ambulancias] AS amb WITH (NOLOCK)
        ),
        cte_dados_tratados AS (
            SELECT
                amb.ID_ROTA AS id_rota,
                PARSE(amb.[DATA] AS date USING 'pt-BR') AS amb_data,
                amb.CodigoCliente AS amb_cd_cliente,
                cli.cli_id_logistics AS amb_cd_transportadora,
                cli.cli_ds_nome AS amb_nome_transportadora,
                amb.ID_ROTA AS amb_id_rota,
                CAST(-1 AS bigint) AS amb_id_motorista,
                amb.SVC AS amb_svc,
                '-' AS amb_status,
                CASE WHEN amb.rotas_pagas = 1 THEN 'Sim' ELSE N'Não' END AS amb_pagamento,
                amb.[timestamp] AS amb_data_etl,
                CAST(NULL AS varchar(max)) AS MOTIVO
            FROM cte_ambulancias_looker AS amb
            LEFT JOIN dbo.tb_clientes AS cli WITH (NOLOCK)
                ON amb.CodigoCliente = cli.cli_cd_codigo_cliente
            WHERE cli.cli_id_logistics IS NOT NULL
              AND PARSE(amb.[DATA] AS date USING 'pt-BR') >= dateadd(d,-15,getdate())
        ),
        cte_dados_distintos AS (
            SELECT *
            FROM (
                SELECT *,
                    ROW_NUMBER() OVER (PARTITION BY id_rota ORDER BY amb_data_etl DESC) AS rn
                FROM cte_dados_tratados
            ) AS t
            WHERE t.rn = 1
        )

        -- MERGE: fonte deduplicada por id_rota (rn=1); escopo controlado pelo
        -- ON target.amb_id_rota = source.amb_id_rota (sem risco de chave duplicada).
        MERGE dbo.tb_looker_ambulancias AS target
        USING (
            SELECT
                d.amb_data,
                d.amb_cd_transportadora,
                d.amb_nome_transportadora,
                d.amb_id_rota,
                d.amb_id_motorista,
                d.amb_svc,
                d.amb_status,
                d.amb_pagamento,
                d.amb_cd_cliente,
                d.amb_data_etl,
                d.MOTIVO
            FROM cte_dados_distintos AS d
        ) AS source
        ON target.amb_id_rota = source.amb_id_rota
        WHEN MATCHED THEN
            UPDATE SET
                -- Escopo controlado: equivale a WHERE target.amb_id_rota = source.amb_id_rota
                target.amb_status = source.amb_status,
                target.amb_pagamento = source.amb_pagamento,
                target.amb_data_etl = source.amb_data_etl
        WHEN NOT MATCHED THEN
            INSERT (
                amb_data,
                amb_cd_transportadora,
                amb_nome_transportadora,
                amb_id_rota,
                amb_id_motorista,
                amb_svc,
                amb_status,
                amb_pagamento,
                amb_codigocliente,
                amb_data_etl,
                amb_motivo
            )
            VALUES (
                source.amb_data,
                source.amb_cd_transportadora,
                source.amb_nome_transportadora,
                source.amb_id_rota,
                source.amb_id_motorista,
                source.amb_svc,
                source.amb_status,
                source.amb_pagamento,
                source.amb_cd_cliente,
                source.amb_data_etl,
                source.motivo
            );

        COMMIT TRANSACTION;

        -- Atualiza os campos de ambulância nas rotas
        EXEC dbo.UspUpdateAmbulanciasLooker;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErroMensagem NVARCHAR(4000);
        DECLARE @ErroSeverity INT;
        DECLARE @ErroState INT;

        SELECT
            @ErroMensagem = ERROR_MESSAGE(),
            @ErroSeverity = ERROR_SEVERITY(),
            @ErroState = ERROR_STATE();

        RAISERROR (@ErroMensagem, @ErroSeverity, @ErroState);
    END CATCH
END
GO

--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM sys.sql_modules sm
        WHERE sm.object_id = OBJECT_ID('dbo.UspLoadAmbulanciasLooker')
          AND sm.definition LIKE '%tb_stg_looker_ambulancias%'
    )
        THROW 50012, 'Procedure nao foi alterada para a nova staging.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
