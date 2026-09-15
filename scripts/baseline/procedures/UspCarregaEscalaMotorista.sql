-- ============================================================
-- BASELINE: dbo.UspCarregaEscalaMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCarregaEscalaMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE  [dbo].[UspCarregaEscalaMotorista] AS BEGIN
select top 1 * from tb_escala_motorista
/*
    DROP TABLE IF EXISTS #tabela;

    -- Variável que define o número de dias para gerar registros (3 dias no caso)
    DECLARE @qtddia INT = 7;

    WITH DateGenerator AS (
        SELECT 0 AS DayIncrement
        UNION ALL
        SELECT DayIncrement + 1
        FROM DateGenerator
        WHERE DayIncrement + 1 < @qtddia
    ),
    RowDuplicator AS (
        -- Duplica os registros para criar dois por dia
        SELECT 1 AS RowDuplicator
        UNION ALL
        SELECT 2 AS RowDuplicator
    )
    -- Criação dos registros fictícios
    SELECT  
        DATEADD(DAY, dg.DayIncrement, CAST(GETDATE() AS DATE)) AS em_data_referencia, -- Gera datas a partir de hoje
        usr_cd_usuario AS em_cd_motorista,
        '-' AS em_ds_placa,                --
        '-' AS em_ds_tipo,                 --
        'F' AS em_ds_frota,                --
        '37' AS em_cd_base,                --
        '-' AS em_ds_ciclo,                --
        'Indisponível' AS em_ds_escala,    --
        usr_cd_usuario AS em_cd_usuario_escala,
        GETDATE() AS em_dh_escala,         -- 
        cli_cd_codigo_cliente AS em_cd_cliente,
		'Procedure' as em_origem_alteracao,
        rd.RowDuplicator AS Duplicador     -- 
    INTO #tabela
    -- Dados baseados na tabela de usuários
    FROM tb_usuario 
    CROSS JOIN DateGenerator dg 
    CROSS JOIN RowDuplicator rd -- Duplica os registros gerados para cada usuário/dia
    WHERE usr_in_ativo = 1 
      AND cli_cd_codigo_cliente <> 7 
    OPTION (MAXRECURSION 0); 

    -- Identificar os registros existentes na tabela final (tb_escala_motorista)
    WITH RegistrosExistentes AS (
        SELECT 
            em_data_referencia,
            em_cd_motorista,  
            COUNT(*) AS TotalExistente -- 
        FROM tb_escala_motorista
        GROUP BY em_data_referencia, em_cd_motorista 
    )
    -- Selecionar apenas os registros que precisam ser criados
    SELECT 
        t.* -- 
    FROM #tabela t
    LEFT JOIN RegistrosExistentes re
        ON t.em_data_referencia = re.em_data_referencia
        AND t.em_cd_motorista = re.em_cd_motorista -- 
    WHERE ISNULL(re.TotalExistente, 0) < 2 -- Apenas motoristas com menos de 2 registros por dia

    -- Inserir os registros faltantes na tabela final (tb_escala_motorista)
    INSERT INTO tb_escala_motorista (
        em_data_referencia, --
        em_cd_motorista,    --
        em_ds_placa,        --
        em_ds_tipo,         --
        em_ds_frota,        --
        em_cd_base,         --
        em_ds_ciclo,        --
        em_ds_escala,       --
        em_cd_usuario_escala, 
        em_dh_escala,       --
        em_cd_cliente, --
		em_origem_alteracao --
    )
    SELECT 
        em_data_referencia,
        em_cd_motorista,
        em_ds_placa,
        em_ds_tipo,
        em_ds_frota,
        em_cd_base,
        em_ds_ciclo,
        em_ds_escala,
        em_cd_usuario_escala,
        em_dh_escala,
        em_cd_cliente,
		em_origem_alteracao
    FROM #tabela
    WHERE NOT EXISTS ( -- Garante que não sejam inseridos registros duplicados
        SELECT 1
        FROM tb_escala_motorista te
        WHERE te.em_data_referencia = #tabela.em_data_referencia
          AND te.em_cd_motorista = #tabela.em_cd_motorista
    );
	*/
END;
GO
