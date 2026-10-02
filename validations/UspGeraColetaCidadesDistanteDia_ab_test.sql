/*==============================================================================
  VALIDACAO A/B — UspGeraColetaCidadesDistanteDia (+ UspGeraAtualizaCidadesDistanteDiaPacote)
  ------------------------------------------------------------------------------
  Ambiente : QAS (db_IrisysDev). NAO rodar bloco 4 (restore) em PROD.
  Uso      : executar TODOS os blocos na MESMA sessao do SSMS (tabelas #temp).
  Objetivo : provar que a versao refatorada produz resultado identico a atual.
  Fluxo    : prechecks -> snapshot ANTES -> EXEC v1 -> snapshot v1 -> restore
             -> EXEC v2 -> snapshot v2 -> diffs (esperado: 0 divergencias)
==============================================================================*/

DECLARE @di       DATE = CAST(GETDATE() - 5 AS DATE);
DECLARE @df       DATE = CAST(GETDATE()     AS DATE);
DECLARE @IdTransp INT  = NULL;   -- mesma assinatura da proc (NULL = todas)

/*==============================================================================
  0. PRE-CHECKS — rodam em qualquer estado, antes de tudo
==============================================================================*/

-- 0.1 Unicidade do join dos UPDATEs (IdRota + IdPacote). ESPERADO: 0 linhas.
SELECT IdRota, IdPacote, COUNT(*) AS qtd
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df
GROUP BY IdRota, IdPacote
HAVING COUNT(*) > 1;

-- 0.2 Coordenadas varchar invalidas no periodo (TRY_CAST = NULL).
--     Hoje essas linhas podem ABORTAR a proc no geography::Point / CAST.
SELECT COUNT(*) AS pacotes_coord_invalida
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df
  AND Excluido = 0
  AND (
       (LatitudeEnderecoParada  IS NOT NULL AND TRY_CAST(LatitudeEnderecoParada  AS DECIMAL(14,10)) IS NULL)
    OR (LongitudeEnderecoParada IS NOT NULL AND TRY_CAST(LongitudeEnderecoParada AS DECIMAL(14,10)) IS NULL)
  );

-- 0.3 Distribuicao atual de CidadeDistante nas rotas elegiveis (baseline de volume)
SELECT ISNULL(CidadeDistante, '<NULL>') AS CidadeDistante, COUNT(*) AS qtd
FROM tb_ml_rotas
WHERE DataReferencia BETWEEN @di AND @df
  AND Excluido = 0
  AND StatusRota <> 'planned'
GROUP BY CidadeDistante
ORDER BY qtd DESC;

-- 0.4 Pacotes elegiveis por status de entrega (contexto de volume)
SELECT StatusEntrega, COUNT(*) AS qtd
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df
  AND Excluido = 0
GROUP BY StatusEntrega;

/*==============================================================================
  1. SNAPSHOT "ANTES" — estado original que sera restaurado para o teste v2
==============================================================================*/

DROP TABLE IF EXISTS #pac_antes;
SELECT IdRota, IdPacote, CidadeDistante, Cidade
INTO #pac_antes
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #rot_antes;
SELECT IdRota, DataReferencia, CidadeDistante
INTO #rot_antes
FROM tb_ml_rotas
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #geo_antes;
SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade
INTO #geo_antes
FROM tb_dra_cidades_geo;

/*==============================================================================
  2. EXECUCAO V1 — versao atual em producao, com medicao
==============================================================================*/

SET STATISTICS TIME, IO ON;
EXEC dbo.UspGeraColetaCidadesDistanteDia @di, @df, @IdTransp;
SET STATISTICS TIME, IO OFF;
-- Anotar: CPU time / elapsed time total do Messages

/*==============================================================================
  3. SNAPSHOT V1 + checagens pos-execucao
==============================================================================*/

DROP TABLE IF EXISTS #pac_v1;
SELECT IdRota, IdPacote, CidadeDistante, Cidade
INTO #pac_v1
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #rot_v1;
SELECT IdRota, DataReferencia, CidadeDistante
INTO #rot_v1
FROM tb_ml_rotas
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #geo_v1;
SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade
INTO #geo_v1
FROM tb_dra_cidades_geo;

-- 3.1 Rotas elegiveis que ficaram sem CidadeDistante apos v1
--     (esperado: apenas rotas fora do escopo — ex.: cliente 7)
SELECT COUNT(*) AS rotas_elegiveis_sem_cidadedistante_v1
FROM tb_ml_rotas r
INNER JOIN tb_clientes c ON c.cli_id_logistics = r.IdTransportadora
                        AND c.cli_cd_codigo_cliente <> 7
WHERE r.DataReferencia BETWEEN @di AND @df
  AND r.Excluido = 0
  AND r.StatusRota <> 'planned'
  AND r.CidadeDistante IS NULL;

-- 3.2 Integridade do ranking: nao pode haver ordem duplicada na mesma rota
SELECT IdRota, CidadeDistante, COUNT(*) AS qtd
FROM #pac_v1
WHERE CidadeDistante >= 1
GROUP BY IdRota, CidadeDistante
HAVING COUNT(*) > 1;

-- 3.3 Inconsistencia rota x pacote: pacote ranqueado em rota sem valor
SELECT COUNT(*) AS pacotes_orfaos_v1
FROM #pac_v1 p
INNER JOIN #rot_v1 r ON r.IdRota = p.IdRota AND r.DataReferencia BETWEEN @di AND @df
WHERE p.CidadeDistante >= 1
  AND r.CidadeDistante IS NULL;

-- 3.4 Linhas novas inseridas na tabela geo por v1
SELECT COUNT(*) AS geo_inseridas_v1
FROM #geo_v1 g
WHERE NOT EXISTS (
    SELECT 1 FROM #geo_antes a
    WHERE a.dcg_nr_latitude       = g.dcg_nr_latitude
      AND a.dcg_nr_longitude      = g.dcg_nr_longitude
      AND a.dcg_cidade_distante   = g.dcg_cidade_distante
);

/*==============================================================================
  4. RESTORE — devolve o estado "ANTES" para a v2 processar o mesmo input.
     SOMENTE QAS. Nunca executar este bloco em PROD.
==============================================================================*/

UPDATE p
SET    p.CidadeDistante = a.CidadeDistante,
       p.Cidade         = a.Cidade
FROM   tb_ml_pacotes p
INNER JOIN #pac_antes a
       ON a.IdRota = p.IdRota AND a.IdPacote = p.IdPacote
WHERE  p.DataReferencia BETWEEN @di AND @df;

UPDATE r
SET    r.CidadeDistante = a.CidadeDistante
FROM   tb_ml_rotas r
INNER JOIN #rot_antes a
       ON a.IdRota = r.IdRota AND a.DataReferencia = r.DataReferencia;

DELETE g
FROM   tb_dra_cidades_geo g
WHERE  NOT EXISTS (
    SELECT 1 FROM #geo_antes a
    WHERE a.dcg_nr_latitude     = g.dcg_nr_latitude
      AND a.dcg_nr_longitude    = g.dcg_nr_longitude
      AND a.dcg_cidade_distante = g.dcg_cidade_distante
)
AND g.dcg_dh_inclusao >= DATEADD(MINUTE, -60, GETDATE()); -- so o que esta execucao inseriu

/*==============================================================================
  5. EXECUCAO V2 — versao refatorada (apos aplicar o forward em QAS)
==============================================================================*/

SET STATISTICS TIME, IO ON;
EXEC dbo.UspGeraColetaCidadesDistanteDia @di, @df, @IdTransp;
SET STATISTICS TIME, IO OFF;
-- Comparar elapsed/cpu com a execucao V1

DROP TABLE IF EXISTS #pac_v2;
SELECT IdRota, IdPacote, CidadeDistante, Cidade
INTO #pac_v2
FROM tb_ml_pacotes
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #rot_v2;
SELECT IdRota, DataReferencia, CidadeDistante
INTO #rot_v2
FROM tb_ml_rotas
WHERE DataReferencia BETWEEN @di AND @df;

DROP TABLE IF EXISTS #geo_v2;
SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade
INTO #geo_v2
FROM tb_dra_cidades_geo;

/*==============================================================================
  6. DIFFS V1 x V2 — ESPERADO: 0 linhas em todos os blocos abaixo
==============================================================================*/

-- 6.1 Pacotes: divergencias em CidadeDistante / Cidade
SELECT 'pac_v1_sobrando' AS lado, * FROM (
    SELECT IdRota, IdPacote, CidadeDistante, Cidade FROM #pac_v1
    EXCEPT
    SELECT IdRota, IdPacote, CidadeDistante, Cidade FROM #pac_v2
) d
UNION ALL
SELECT 'pac_v2_sobrando', * FROM (
    SELECT IdRota, IdPacote, CidadeDistante, Cidade FROM #pac_v2
    EXCEPT
    SELECT IdRota, IdPacote, CidadeDistante, Cidade FROM #pac_v1
) d;

-- 6.2 Rotas: divergencias em CidadeDistante
SELECT 'rot_v1_sobrando' AS lado, * FROM (
    SELECT IdRota, DataReferencia, CidadeDistante FROM #rot_v1
    EXCEPT
    SELECT IdRota, DataReferencia, CidadeDistante FROM #rot_v2
) d
UNION ALL
SELECT 'rot_v2_sobrando', * FROM (
    SELECT IdRota, DataReferencia, CidadeDistante FROM #rot_v2
    EXCEPT
    SELECT IdRota, DataReferencia, CidadeDistante FROM #rot_v1
) d;

-- 6.3 Geo: divergencias na tabela de coordenadas
SELECT 'geo_v1_sobrando' AS lado, * FROM (
    SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade FROM #geo_v1
    EXCEPT
    SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade FROM #geo_v2
) d
UNION ALL
SELECT 'geo_v2_sobrando', * FROM (
    SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade FROM #geo_v2
    EXCEPT
    SELECT dcg_nr_latitude, dcg_nr_longitude, dcg_cidade_distante, dcg_ds_cidade FROM #geo_v1
) d;

-- 6.4 Resumo executivo
SELECT
    (SELECT COUNT(*) FROM #pac_v1) AS pacotes_v1,
    (SELECT COUNT(*) FROM #pac_v2) AS pacotes_v2,
    (SELECT COUNT(*) FROM #pac_v1 WHERE CidadeDistante >= 1) AS ranqueados_v1,
    (SELECT COUNT(*) FROM #pac_v2 WHERE CidadeDistante >= 1) AS ranqueados_v2,
    (SELECT COUNT(*) FROM #rot_v1 WHERE CidadeDistante IS NOT NULL) AS rotas_preenchidas_v1,
    (SELECT COUNT(*) FROM #rot_v2 WHERE CidadeDistante IS NOT NULL) AS rotas_preenchidas_v2;
