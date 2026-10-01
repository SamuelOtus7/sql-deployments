/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqxyka
  Autor        : Devin
  Data         : 2026-10-01
  Descrição    : Restaura a versão anterior de dbo.UspLoadAmbulanciasLooker
                 (fonte: dbo.stg_looker_ambulancias, com colunas ID_MOTORISTA,
                 STATUS, PAGAMENTO, MOTIVO). Esta é a definição vigente em PROD
                 antes do forward 020 (modify_date do objeto: 2026-07-06).
  Forward ref  : scripts/forward/2026/10/020_forward_CU-86akqxyka_load_ambulancias_tb_stg.sql
  Objetos      : dbo.UspLoadAmbulanciasLooker (CREATE OR ALTER PROCEDURE)
  ==============================================================================
  ATENÇÃO: linhas inseridas no destino pelo forward NÃO são removidas aqui —
  o MERGE é idempotente por amb_id_rota; se necessário, avaliar DELETE pontual
  das linhas com amb_id_motorista = -1 inseridas após o deploy.
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspLoadAmbulanciasLooker'))
        THROW 50013, 'Procedure dbo.UspLoadAmbulanciasLooker nao encontrada.', 1;
END TRY
BEGIN CATCH
    PRINT 'ERRO (pre-check): ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO

--==========================================================================
-- 2. SCRIPT DE ROLLBACK — restaura definição anterior (fonte stg_looker_ambulancias)
--==========================================================================
CREATE OR ALTER PROCEDURE [dbo].[UspLoadAmbulanciasLooker]
AS
BEGIN
    SET NOCOUNT off;

    BEGIN TRY
        BEGIN TRANSACTION;

        WITH cte_ambulancias_looker AS (
            SELECT DISTINCT *
            FROM [stg_looker_ambulancias] AS amb WITH (NOLOCK)
        ),
        cte_dados_tratados AS (
            SELECT 
                amb.id_rota,
                 PARSE(amb.data AS date USING 'pt-BR') AS amb_data,
                amb.codigocliente AS amb_cd_cliente,
                cli.cli_id_logistics AS amb_cd_transportadora,
                cli.cli_ds_nome AS amb_nome_transportadora,
                amb.id_rota AS amb_id_rota,
                amb.id_motorista AS amb_id_motorista,
                amb.svc AS amb_svc,
                Isnull(amb.status,'-') AS amb_status,
                amb.pagamento AS amb_pagamento,
                amb.timestamp AS amb_data_etl,
                amb.MOTIVO
            FROM cte_ambulancias_looker AS amb
            LEFT JOIN dbo.tb_clientes AS cli WITH (NOLOCK)
                ON amb.codigocliente = cli.cli_cd_codigo_cliente
            WHERE cli.cli_id_logistics IS NOT NULL 
            and  PARSE(amb.data AS date USING 'pt-BR') >= dateadd(d,-15,getdate())
            and amb.id_motorista is not null
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

		-- Passo 8: Atualiza os campos de ambulância nas rotas
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
          AND sm.definition LIKE '%stg_looker_ambulancias%'
          AND sm.definition NOT LIKE '%tb_stg_looker_ambulancias%'
    )
        THROW 50014, 'Procedure nao foi restaurada para a staging antiga.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
