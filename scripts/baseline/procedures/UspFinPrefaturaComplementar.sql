-- ============================================================
-- BASELINE: dbo.UspFinPrefaturaComplementar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinPrefaturaComplementar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Processa o que ja estiver em dbo.tb_stg_fin_prefatura_complementar e
-- insere (transformado) direto em tb_fin_prefatura_complementar (tabela
-- final; nao existe mais tabela intermediaria de upload).
-- O carregamento da staging (BULK INSERT/insert do arquivo) e feito por
-- outro processo; esta procedure so cuida da transformacao/carga final.
--
-- Duplicidade: para cada chave natural (transportadora + ano + mes +
-- quinzena + rota + provider + conceito_billing) presente na staging,
-- remove o que ja existia na tb_fin_prefatura_complementar para aquela
-- chave e insere novamente (DELETE + INSERT, sem controle de lote/
-- fingerprint). O DELETE eh feito pela chave natural completa, nao pelo
-- periodo inteiro, para nao apagar chaves que nao estao sendo recarregadas.
-- Sem BEGIN TRAN, conforme solicitado.
--
-- Dedup da staging: o microservico externo pode inserir o mesmo registro
-- (mesma chave natural: transportadora + ano + mes + quinzena + rota +
-- provider + conceito_billing) varias vezes, com stg_dt_carga diferente.
-- Antes do INSERT, mantemos apenas a linha mais recente de cada chave
-- (maior stg_dt_carga; desempate por stg_ds_arquivo), evitando duplicidade
-- na tb_fin_prefatura_complementar.
--
-- Exemplo de uso:
-- EXEC dbo.UspFinPrefaturaComplementar
--      @IdTransportadora = 1024706007;

CREATE PROCEDURE [dbo].[UspFinPrefaturaComplementar]
(
    @IdTransportadora INT
)
AS
BEGIN
    SET NOCOUNT ON;

    IF @IdTransportadora IS NULL
    BEGIN
        THROW 50001, 'Parametro @IdTransportadora e obrigatorio.', 1;
    END;

    DELETE t
    FROM dbo.tb_fin_prefatura_complementar AS t
    WHERE t.pfc_cd_transportadora = @IdTransportadora
      AND EXISTS (
          SELECT 1
          FROM dbo.tb_stg_fin_prefatura_complementar AS s
          WHERE TRY_CONVERT(INT, SUBSTRING(s.periodo, 1, 4)) = t.pfc_nu_ano
            AND TRY_CONVERT(INT, SUBSTRING(s.periodo, 5, 2)) = t.pfc_nu_mes
            AND TRY_CONVERT(INT, RIGHT(s.periodo, 1))        = t.pfc_nu_quinzena
            AND s.entity_id         = t.pfc_cd_rota
            AND TRY_CONVERT(BIGINT, s.provider_id) = t.pfc_cd_provider
            AND s.conceito_billing  = t.pfc_ds_conceito_billing
      );

    INSERT INTO dbo.tb_fin_prefatura_complementar
    (
        pfc_cd_transportadora,
        pfc_nu_ano,
        pfc_nu_mes,
        pfc_nu_quinzena,
        pfc_ds_periodo,
        pfc_cd_rota,
        pfc_cd_provider,
        pfc_ds_conceito_billing,
        pfc_vl_servico,
        pfc_ds_tipo_entidade,
        pfc_ds_status_final,
        pfc_ds_motivo_aprovacao,
        pfc_ds_nome_transportadora,
        pfc_ds_placa_base,
        pfc_dt_rota,
        pfc_ds_faixa_km,
        pfc_ds_nova_faixa_km,
        pfc_qt_paradas_atualizada,
        pfc_qt_paradas_anterior,
        pfc_ds_service_center,
        pfc_ds_tipo_veiculo,
        pfc_dt_processamento
    )
    SELECT
        @IdTransportadora                                                          AS pfc_cd_transportadora,
        TRY_CONVERT(INT, SUBSTRING(s.periodo, 1, 4))                               AS pfc_nu_ano,
        TRY_CONVERT(INT, SUBSTRING(s.periodo, 5, 2))                               AS pfc_nu_mes,
        TRY_CONVERT(INT, RIGHT(s.periodo, 1))                                      AS pfc_nu_quinzena,
        s.periodo                                                                  AS pfc_ds_periodo,
        s.entity_id                                                                AS pfc_cd_rota,
        TRY_CONVERT(BIGINT, s.provider_id)                                         AS pfc_cd_provider,
        s.conceito_billing                                                         AS pfc_ds_conceito_billing,
        TRY_CONVERT(DECIMAL(18, 2), REPLACE(s.total_a_pagar, ',', '.'))            AS pfc_vl_servico,
        s.entity_type                                                              AS pfc_ds_tipo_entidade,
        s.final_desicao                                                           AS pfc_ds_status_final,
        s.motivo_aprovacao                                                         AS pfc_ds_motivo_aprovacao,
        s.mlp_name                                                                 AS pfc_ds_nome_transportadora,
        s.placa                                                                    AS pfc_ds_placa_base,
        s.data_rota                                                                AS pfc_dt_rota,
        s.billing_km_range                                                         AS pfc_ds_faixa_km,
        s.new_km_range                                                             AS pfc_ds_nova_faixa_km,
        TRY_CONVERT(INT, s.c_qty_stops)                                            AS pfc_qt_paradas_atualizada,
        TRY_CONVERT(INT, s.b_qty_stops)                                            AS pfc_qt_paradas_anterior,
        s.svc                                                                      AS pfc_ds_service_center,
        s.veiculo                                                                  AS pfc_ds_tipo_veiculo,
        GETDATE()                                                                  AS pfc_dt_processamento
    FROM (
        SELECT
            s.*,
            ROW_NUMBER() OVER (
                PARTITION BY
                    s.periodo,
                    s.entity_id,
                    s.provider_id,
                    s.conceito_billing
                ORDER BY
                    s.stg_dt_carga   DESC,
                    s.stg_ds_arquivo DESC
            ) AS rn_dedup
        FROM dbo.tb_stg_fin_prefatura_complementar AS s
    ) AS s
    WHERE s.rn_dedup = 1;

    SELECT @@ROWCOUNT AS qtd_registros_inseridos;
END;
GO
