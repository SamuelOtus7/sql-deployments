-- ============================================================
-- BASELINE: dbo.vw_dash_alarmes
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_dash_alarmes]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vw_dash_alarmes] as 
WITH ClientesValidos AS (
    SELECT cli_id_logistics, cli_ds_nome, cli_cd_codigo_cliente,cli_id_shopee
    FROM tb_clientes as a WITH (NOLOCK)
    inner join tb_parametros as pr
    on cli_cd_codigo_cliente = pr.prm_cod_cliente
    and pr.prm_ds_categoria = 'Alertas'
    and pr.prm_nm_parametro = 'Habilitar Dashboard Alarmes'
    and pr.prm_ds_valor = 'true'
    AND ISNULL(pr.prm_in_ativo,1)=1
    AND ISNULL(pr.prm_in_excluido,0)=0

    WHERE cli_cd_codigo_cliente <> 7
      AND cli_in_ativo = 1
      AND cli_in_excluido = 0
      --AND cli_id_logistics > 0
)
-- =========================
-- Sem Coleta Pacote
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'ML Coleta Pct' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true' 
             AND DATEDIFF(MINUTE, MAX(r.cmr_dh_escrita), GETDATE()) > 15 
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_ml_coleta_rotas r WITH (ROWLOCK, READPAST, UPDLOCK)
    ON r.cmr_cd_transportadora = c.cli_id_logistics
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL

-- =========================
-- ML_LH Sem Coleta
-- =========================
SELECT
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'tb_ml lh_rotas' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND MAX(r.DataAtualizacao) < DATEADD(MINUTE, -15, GETDATE())
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_ml_lh_rotas r 
    ON r.idtransportadora = c.cli_id_logistics
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL

-- =========================
-- ML_LH_ROUTES Sem Coleta
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'ML LH ROTAS' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND MAX(d.dac_dh_coleta) < DATEADD(MINUTE, -15, GETDATE())
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_dra_coleta d WITH (NOLOCK) 
    ON d.dac_cd_transportadora = c.cli_id_logistics
   AND d.dac_ds_tipo_coleta = 'ML_LH_ROUTES'
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL

-- =========================
-- Amb lkr
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Amb lkr' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND MAX(a.amb_data_etl) < DATEADD(DAY, -1, GETDATE()) or MAX(a.amb_data_etl)  is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN dbo.tb_looker_ambulancias a 
    ON a.amb_cd_transportadora = c.cli_id_logistics
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Ambulancia Looker'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL

-- =========================
-- Pacotes Pendentes
-- =========================
/*
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Pct Pendentes' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND SUM(a.pacotespendentes) > 0
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_ml_rotas a WITH (NOLOCK)
    ON a.idtransportadora = c.cli_id_logistics
   AND a.datareferencia BETWEEN CAST(GETDATE()-10 AS DATE) AND CAST(GETDATE()-1 AS DATE)
   AND a.excluido = 0
   AND a.StatusRota <> 'planned'
   AND a.pacotespendentes > 0
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL
*/

-- =========================
-- PNR
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'PNR Silos' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND DATEDIFF(minute, MAX(d.dac_dh_coleta), GETDATE()) > 15 or  MAX(d.dac_dh_coleta) is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_dra_coleta d WITH (NOLOCK) 
    ON d.dac_cd_transportadora = c.cli_id_logistics
   AND d.dac_ds_tipo_coleta = 'ML_PNR'
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

union all

SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Coleta Rota ML' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND DATEDIFF(MINUTE, MAX(t.cmt_dh_escrita), GETDATE()) > 15 or  MAX(t.cmt_dh_escrita) is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_ml_coleta_totalizador t WITH (ROWLOCK, READPAST, UPDLOCK)
    ON t.cmt_cd_transportadora = c.cli_id_logistics
   AND t.cmt_dh_referencia >= '2025-03-25'
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL

-- =========================
-- Sem Coleta Flex
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Flex Frota' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND DATEDIFF(HOUR, MAX(e.iev_dh_data_hora_evento), GETDATE()) > 24 or MAX(e.iev_dh_data_hora_evento) is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_integracao_flex_eventos e
    ON e.iev_cd_codigo_cliente = c.cli_cd_codigo_cliente
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Flex Frota'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor


union all

SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Sem Rtt' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2

        WHEN prm_ds_valor = 'true'
             AND
             (
                CAST(SUM(CASE 
                            WHEN rtt.KmTotal IS NULL 
                             AND LEFT(a.OrigemSaida,1) <> 'b' 
                            THEN 1 
                            ELSE 0 
                         END) AS DECIMAL(18,4))
                /
                NULLIF(COUNT(a.IdRota), 0)
             ) >= 0.01
        THEN 1 

        ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_ml_rotas AS a
    ON a.idtransportadora = c.cli_id_logistics
   AND a.excluido = 0
   AND a.datareferencia BETWEEN CAST(GETDATE()-5 AS DATE) AND CAST(GETDATE()-2 AS DATE)
   AND a.statusrota <> 'planned'
   AND a.totalpacotes > 0

LEFT JOIN tb_ml_bsc_rtt rtt WITH (NOLOCK)
   ON a.idrota = rtt.idrota

LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Km RTT'

GROUP BY 
    c.cli_id_logistics, 
    c.cli_ds_nome, 
    prm_ds_valor

UNION ALL

-- =========================
-- Sem Cidade
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Cidade Meli' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND SUM(CASE WHEN a.CidadeDistante IS NULL THEN 1 ELSE 0 END)  > 0 and sum(case when datediff(minute,dateadd(hour,-3,DataHoraColeta) ,getdate()) > 30 then 1 else 0 end) >= 1
             and SUM(CASE WHEN a.CidadeDistante IS NULL THEN 1 ELSE 0 END) / cast(nullif(count(*),0) as decimal(10,2)) > 0.02
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_ml_rotas a WITH (NOLOCK)
    ON a.idtransportadora = c.cli_id_logistics
   AND a.excluido = 0
   AND a.datareferencia BETWEEN CAST(GETDATE()-5 AS DATE) AND CAST(GETDATE() AS DATE)
   AND a.statusrota <> 'planned'
   AND a.totalpacotes > 0
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'


GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL


SELECT  
    c.cli_id_shopee AS id_transportadora,
    c.cli_ds_nome,
    'Cidade SPE' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND SUM(CASE WHEN a.CidadeDistante IS NULL THEN 1 ELSE 0 END)  > 0 and sum(case when datediff(minute,dateadd(hour,-3,DataHoraColeta) ,getdate()) > 30 then 1 else 0 end) >= 1
             and SUM(CASE WHEN a.CidadeDistante IS NULL THEN 1 ELSE 0 END) / cast(nullif(count(*),0) as decimal(10,2)) > 0.02
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN tb_spe_rotas_v5 a WITH (NOLOCK)
    ON a.idtransportadora = c.cli_id_shopee
   AND a.excluido = 0
   AND a.datareferencia BETWEEN CAST(GETDATE()-5 AS DATE) AND CAST(GETDATE() AS DATE)
   AND a.totalpacotes > 0
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas SPE'
GROUP BY c.cli_id_shopee, c.cli_ds_nome, prm_ds_valor


UNION ALL

-- =========================
-- Coleta Motorista
-- =========================
SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'Integ Mot' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND DATEADD(HOUR,-3,MAX(d.dac_dh_coleta)) < DATEADD(HOUR,-20,GETDATE()) or MAX(d.dac_dh_coleta) is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_dra_coleta d WITH (NOLOCK)
    ON d.dac_cd_transportadora = c.cli_id_logistics
   AND d.dac_ds_tipo_coleta = 'DRIVER_ML'
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor


union all



SELECT  
    c.cli_id_logistics AS id_transportadora,
    c.cli_ds_nome,
    'ml pacotes' AS TipoAlarme,
    CASE
        WHEN prm_ds_valor = 'false' THEN 2
        WHEN prm_ds_valor = 'true'
             AND MAX(r.cmt_dh_processamento)  < DATEADD(MINUTE, -15, GETDATE()) or MAX(r.cmt_dh_processamento) is null
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos c
LEFT JOIN db_Irisys_Json.dbo.tb_ml_coleta_rotas r WITH (NOLOCK)
    ON r.cmr_cd_transportadora = c.cli_id_logistics
   AND r.cmr_dh_referencia = CAST(GETDATE() AS DATE)
   AND r.cmr_in_processado = 1
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Alertas'
   AND parm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Rotas Meli'
GROUP BY c.cli_id_logistics, c.cli_ds_nome, prm_ds_valor

UNION ALL



SELECT 
    cli.cli_id_logistics AS id_transportadora,
    cli.cli_ds_nome,
    'Dados Comp.' AS TipoAlarme,
    CASE
        WHEN parm.prm_ds_valor = 'false' THEN 2
        WHEN parm.prm_ds_valor = 'true'
             AND EXISTS (
                 SELECT 1
                 FROM tb_ml_pacotes p WITH (NOLOCK)
                 LEFT JOIN tb_ml_detalhes_pacotes d WITH (NOLOCK)
                        ON d.IdPacote = p.IdPacote
                 WHERE p.IdTransportadora = cli.cli_id_logistics
                   AND p.StatusEntrega = 'not_delivered'
                   AND p.Excluido = 0
                   AND p.substatus <> 'transferred'
                   -- últimos 60 min pela COLETA (não pelo dia)
                   AND d.datahoracoleta >= DATEADD(MINUTE, -120, GETDATE())
                   -- regra de “dados do comprador”
                   AND d.NomeComprador IS NULL
                   AND d.TelefoneComprador IS NULL
             )
        THEN 1 ELSE 0
    END AS Valor
FROM ClientesValidos cli WITH (NOLOCK)
LEFT JOIN tb_parametros parm
    ON parm.prm_ds_categoria = 'Monitoramento Meli'
   AND parm.prm_cod_cliente = cli.cli_cd_codigo_cliente
   AND parm.prm_nm_parametro = 'Habilitar Analise de PNR'


GROUP BY cli.cli_id_logistics, cli.cli_ds_nome, parm.prm_ds_valor



GO
