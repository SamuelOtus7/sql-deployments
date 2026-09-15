-- ============================================================
-- BASELINE: dbo.UspAtualizaDisonibilidadeMotorista
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaDisonibilidadeMotorista]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspAtualizaDisonibilidadeMotorista] AS  BEGIN
    -- Remover a tabela temporária existente, se existir
    DROP TABLE IF EXISTS #disponibilidade
	    DROP TABLE IF EXISTS #disponibilidade_alinhada;


    -- Criar a tabela temporária #disponibilidade com os dados originais
    SELECT 
        dpm_dh_data AS em_dh_data,
        dpm_cd_usuario AS em_cd_motorista,
        '-' AS em_ds_placa,
        tvl_nm_tipo_veiculo AS em_ds_tipo,
        'F' AS em_ds_frota,
        c.bss_cd_base AS em_cd_base,
        dpm_ds_periodo AS em_ds_ciclo,
        CASE 
            WHEN dpm_in_disponivel = 1 THEN 'Disponível' 
            ELSE 'Indisponível' 
        END AS em_ds_escala,
        dpm_cd_usuario_criacao AS em_cd_usuario_escala,
        GETDATE() AS em_dh_escala, 
		'Procedure' as em_origem_alteracao,
        a.dpm_cd_cliente
    INTO #disponibilidade
    FROM tb_disponibilidade_motorista AS a
    INNER JOIN tb_dra_tipo_veiculo AS b
        ON a.dpm_cd_tipoVeiculo = b.tvl_cd_tipo_veiculo
    INNER JOIN tb_bases AS c
        ON a.dpm_base = c.bss_ds_sigla
        AND a.dpm_cd_cliente = c.bss_cod_cliente
    WHERE CAST(dpm_dh_data AS DATE) >= CAST(GETDATE() - 365 AS DATE);

    -- Ordenar a tabela disponibilidade e adicionar a contagem
    WITH DisponibilidadeNumerada AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (PARTITION BY em_cd_motorista, CAST(em_dh_data AS DATE), em_cd_base ORDER BY em_dh_data ASC) AS OrdemDisponibilidade,
            COUNT(*) OVER (PARTITION BY em_cd_motorista, CAST(em_dh_data AS DATE), em_cd_base) AS TotalRegistros
        FROM #disponibilidade
    ),
    EscalaOrdenada AS (
        SELECT 
            em_cd_escala_motorista,
            em_cd_motorista,
            em_data_referencia,
            ROW_NUMBER() OVER (PARTITION BY em_cd_motorista, em_data_referencia, em_cd_base ORDER BY em_cd_escala_motorista ASC) AS OrdemEscala
        FROM tb_escala_motorista
    )
    -- Associar disponibilidade numerada com escala ordenada
    SELECT 
        e.em_cd_escala_motorista,
        d.em_dh_data,
        d.em_ds_placa,
        d.em_ds_tipo,
        d.em_ds_frota,
        d.em_cd_base,
        --d.em_ds_ciclo,
        d.em_ds_escala,
        d.em_cd_usuario_escala,
        d.em_dh_escala,
        d.dpm_cd_cliente,
		d.em_cd_motorista,
		CASE 
			WHEN d.OrdemDisponibilidade = 1 THEN 'AM' ELSE 'PM'
		END AS em_ds_ciclo
    INTO #disponibilidade_alinhada
    FROM DisponibilidadeNumerada d
    LEFT JOIN EscalaOrdenada e
        ON e.em_cd_motorista = d.em_cd_motorista
        AND e.em_data_referencia = CAST(d.em_dh_data AS DATE)
        AND e.OrdemEscala = d.OrdemDisponibilidade; -- Garantir correspondência por ordem

    -- Atualizar os registros na escala com os dados da disponibilidade
    UPDATE e
    SET 
        e.em_ds_tipo = ISNULL(d.em_ds_tipo, e.em_ds_tipo),
        e.em_cd_base = ISNULL(d.em_cd_base, e.em_cd_base),
        e.em_ds_ciclo = ISNULL(d.em_ds_ciclo, e.em_ds_ciclo),
        e.em_ds_escala = ISNULL(d.em_ds_escala, e.em_ds_escala),
        e.em_cd_usuario_escala = ISNULL(d.em_cd_usuario_escala, e.em_cd_usuario_escala),
        e.em_dh_escala = ISNULL(d.em_dh_escala, e.em_dh_escala),
        e.em_cd_cliente = ISNULL(d.dpm_cd_cliente, e.em_cd_cliente)
    FROM tb_escala_motorista e
    INNER JOIN #disponibilidade_alinhada d
        ON e.em_cd_escala_motorista = d.em_cd_escala_motorista and e.em_origem_alteracao <> 'Web'

	INSERT INTO tb_escala_motorista (em_data_referencia, em_ds_tipo, em_cd_base, em_ds_ciclo, em_ds_escala, em_cd_usuario_escala, em_dh_escala, em_cd_cliente, em_cd_motorista, em_ds_placa, em_ds_frota)
	SELECT 
		em_dh_data,
		em_ds_tipo,
		em_cd_base,
		em_ds_ciclo,
		em_ds_escala,
		em_cd_usuario_escala,
		em_dh_escala,
		dpm_cd_cliente,
		em_cd_motorista,
		em_ds_placa,
		em_ds_frota
	FROM #disponibilidade_alinhada d where em_cd_escala_motorista is null
END;
GO
