-- ============================================================
-- BASELINE: dbo.UspGeraColetaCidadesDistanteNaoEntregue
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspGeraColetaCidadesDistanteNaoEntregue]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspGeraColetaCidadesDistanteNaoEntregue] as 
--268007594
--corrige cidade distante de pacotes nao entregues. 

declare @datainicio date = cast(getdate()-1 as date)
declare @datafim date = cast(getdate()-1 as date)

drop table if exists #tb_ml_pacotes 
select *
into #tb_ml_pacotes 
from tb_ml_pacotes as a with(nolock)
where 
datareferencia between @datainicio and @datafim
and Excluido = 0 
--and IdTransportadora = 1387994348
--and idrota  = 268141644

DROP TABLE IF EXISTS #pacotes_nao_entregues;

SELECT *
INTO #pacotes_nao_entregues
FROM #tb_ml_pacotes 
WHERE 1 = 1
  AND StatusEntrega = 'not_delivered'
  AND cidadedistante is not null;

-- Limpa a ordem das cidades para correção
UPDATE a
SET cidadedistante = NULL
FROM tb_ml_pacotes AS a
INNER JOIN (
    SELECT idrota 
    FROM #pacotes_nao_entregues
    GROUP BY idrota
) AS b ON a.idrota = b.idrota;

-- Limpa a cidade distante ja cadastrada na rota
UPDATE a
SET cidadedistante = NULL
FROM tb_ml_rotas AS a
INNER JOIN (
    SELECT idrota 
    FROM #pacotes_nao_entregues
    GROUP BY idrota
) AS b ON a.idrota = b.idrota;



-- Calcula as distâncias
DROP TABLE IF EXISTS #base1;

SELECT 
    a.IdRota,
    a.idpacote,
    a.LatitudeEnderecoParada AS Latitude,
    a.LongitudeEnderecoParada AS Longitude,
    geography::Point(a.LatitudeEnderecoParada,a.LongitudeEnderecoParada,4326).STDistance(geography::Point(c.bss_dc_latitude,c.bss_dc_longitude,4326)) AS distancia,
    CASE 
			WHEN LAG(LatitudeEnderecoParada) OVER  (partition by a.idrota ORDER BY SequenciaParada) IS NOT NULL 
			 AND LAG(LongitudeEnderecoParada) OVER (partition by a.idrota ORDER BY SequenciaParada) IS NOT NULL 
			THEN geography::Point(LatitudeEnderecoParada, LongitudeEnderecoParada, 4326)
				 .STDistance(geography::Point(
					  LAG(LatitudeEnderecoParada) OVER  (partition by a.idrota ORDER BY SequenciaParada),
					 LAG(LongitudeEnderecoParada) OVER  (partition by a.idrota ORDER BY SequenciaParada),
					 4326))
			ELSE NULL
		END as DistanciaDaAnterior
		,
		CASE 
			WHEN LEAD(LatitudeEnderecoParada) OVER  (partition by a.idrota ORDER BY SequenciaParada) IS NOT NULL 
			 AND LEAD(LongitudeEnderecoParada) OVER (partition by a.idrota ORDER BY SequenciaParada) IS NOT NULL 
			THEN geography::Point(LatitudeEnderecoParada, LongitudeEnderecoParada, 4326)
				 .STDistance(geography::Point(
					 LEAD(LatitudeEnderecoParada) OVER  (partition by a.idrota ORDER BY SequenciaParada),
					 LEAD(LongitudeEnderecoParada) OVER (partition by a.idrota ORDER BY SequenciaParada),
					 4326))
			ELSE NULL
		END DistanciaDaPosterior
INTO #base1
FROM #tb_ml_pacotes AS a
INNER JOIN (
    SELECT idrota 
    FROM #pacotes_nao_entregues
    GROUP BY idrota
) AS b ON a.idrota = b.idrota
JOIN (
    SELECT 
        idrota,
        datareferencia,
        idtransportadora,
        CASE 
            WHEN servicecenter <> origemsaida THEN origemsaida 
            ELSE servicecenter 
        END AS servicecenter,
        StatusRota,
        CidadeDistante
    FROM tb_ml_rotas WITH (NOLOCK)
    WHERE excluido = 0 
      AND StatusRota <> 'planned'
) AS rota ON b.IdRota = rota.IdRota
INNER JOIN tb_bases AS c WITH (NOLOCK)
    ON rota.idtransportadora = c.bss_cd_idtransportadora
   AND rota.servicecenter = c.bss_ds_sigla
WHERE a.StatusEntrega <> 'not_delivered'
and cast(bss_dc_longitude			as decimal(14,10)) between -90 and 90
and cast(a.LatitudeEnderecoParada   as decimal(14,10)) between -90 and 90;


delete
from #base1
where (DistanciaDaAnterior	 > 500 or DistanciaDaAnterior is null)
and (DistanciaDaPosterior > 500 or DistanciaDaPosterior is null)




-- Elege as 4 mais distantes
UPDATE a
SET a.CidadeDistante = b.ordem


FROM tb_ml_pacotes AS a WITH (ROWLOCK, READPAST, UPDLOCK)
INNER JOIN (
    SELECT 
        IdRota,
        idpacote,
        Latitude,
        Longitude,
        ordem
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY distancia DESC) AS ordem
        FROM #base1
    ) AS a
    WHERE ordem <= 4
) AS b ON a.idrota = b.idrota 
      AND a.IdPacote = b.idpacote
      AND a.LongitudeEnderecoParada = b.longitude
      AND a.LatitudeEnderecoParada = b.latitude
WHERE a.excluido = 0;

-- Insere para processar as cidades a partir da latitude e longitude
INSERT INTO tb_dra_cidades_geo (
    dcg_nr_latitude,
    dcg_nr_longitude,
    dcg_cidade_distante
)

SELECT DISTINCT 
    LatitudeEnderecoParada,
    LongitudeEnderecoParada,
    MIN(cidadedistante) AS dcg_cidade_distante
FROM (
    SELECT a.*
    FROM #tb_ml_pacotes AS a  WITH (NOLOCK)
    INNER JOIN (
        SELECT idrota 
        FROM #pacotes_nao_entregues
        GROUP BY idrota
    ) AS b ON a.idrota = b.idrota
) AS pacotes
LEFT JOIN tb_dra_cidades_geo AS geo WITH (NOLOCK)
    ON pacotes.LatitudeEnderecoParada = geo.dcg_nr_latitude
   AND pacotes.LongitudeEnderecoParada = geo.dcg_nr_longitude
WHERE LatitudeEnderecoParada IS NOT NULL
  AND LongitudeEnderecoParada IS NOT NULL
  AND geo.dcg_cd_cidade_gei IS NULL
  AND pacotes.CidadeDistante >= 1
  AND geo.dcg_nr_latitude IS NULL
GROUP BY   LatitudeEnderecoParada,
    LongitudeEnderecoParada;


--atualiza a cidade na rota
UPDATE a
SET a.cidadedistante = p.cidade

FROM tb_ml_rotas AS a
inner join tb_ml_pacotes as p
on a.idrota  = p.idrota
INNER JOIN (
    SELECT idrota 
    FROM #pacotes_nao_entregues
    GROUP BY idrota
) AS pn ON p.idrota = pn.idrota
where p.cidadedistante = 1
GO
