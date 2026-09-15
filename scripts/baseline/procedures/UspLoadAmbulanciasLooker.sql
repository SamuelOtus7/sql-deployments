-- ============================================================
-- BASELINE: dbo.UspLoadAmbulanciasLooker
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspLoadAmbulanciasLooker]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**********************************************************************************************
Procedure: dbo.UspLoadAmbulanciasLooker
Descrição:
    Esta procedure realiza o processo de carga da tabela 'tb_looker_ambulancias', a partir
    dos dados da stage '[stg_looker_ambulancias]'. O processo segue os passos:

    1. Leitura da stage 'stg_looker_ambulancias'.
    2. Validação e junção com a 'tb_clientes' para garantir apenas transportadoras válidas.
    3. Geração da chave de negócio 'amb_cd_ambulancias_looker'.
    4. Duplicação dos dados com base na chave de negócio, mantendo apenas o registro mais recente por chave.
    5. Realiza um INSERT na 'tb_looker_ambulancias' de todos os registros
    6. O processo é executado dentro de uma transação para garantir atomicidade.
    7. Caso ocorra algum erro, o processo é cancelado (ROLLBACK) e a exceção é lançada.
   *8. Executa a chamada de update para atualizar a VW rotas (tb_ml_rotas,tb_ml_mo_rotas,tb_ml_fm_rotas)
**********************************************************************************************/

CREATE PROCEDURE [dbo].[UspLoadAmbulanciasLooker]
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
                --TRY_CAST(amb.data AS DATE) AS amb_data,	
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
