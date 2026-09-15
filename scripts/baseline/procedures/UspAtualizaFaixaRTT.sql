-- ============================================================
-- BASELINE: dbo.UspAtualizaFaixaRTT
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaFaixaRTT]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspAtualizaFaixaRTT]

AS

BEGIN

DROP TABLE IF EXISTS #tb_ml_bsc_rtt;
WITH CTE AS (
    SELECT 
        SUBSTRING(quinzena, 1, 4) AS ano,
        SUBSTRING(quinzena, 5, 2) AS mes,
        SUBSTRING(quinzena, 8, 1) AS Quinzena,
        Route_id,
        ISNULL(TRY_CAST(REPLACE(Odometro, ',', '.') AS DECIMAL(10,2)), 0) AS Odometro,
        ISNULL(TRY_CAST(REPLACE(distancetostation, ',', '.') AS DECIMAL(10,2)), 0) AS distancetostation,
        ISNULL(TRY_CAST(REPLACE(kmtotal, ',', '.') AS DECIMAL(10,2)), 0) AS kmtotal,
        DataExtracao,
		MLP,
        ROW_NUMBER() OVER (PARTITION BY Route_id ORDER BY DataExtracao DESC) AS rn
    FROM tb_stg_looker_rtt
    WHERE cast(DataExtracao as date) >= DATEADD(DAY, -5, GETDATE())
)
SELECT 
    ano, mes, Quinzena, Route_id, Odometro, distancetostation, kmtotal, MLP
INTO #tb_ml_bsc_rtt
FROM CTE
WHERE rn = 1;


--Adicionado por Saulo Barros em 30/03/2026 como forma paliativa para resolver o seguinte problema:
--as rotas coletadas da 50+ a partir do dia 27/03 estão com valor de km dobrado por algum erro no looker
--o cliente irá verificar com Meli mas enquanto isso está sendo criado essa tratativa para que não seja atualizado
delete
	#tb_ml_bsc_rtt
where
	MLP = '50 MAIS'
	and (
		(Ano = 2026 AND Mes < 3)
		OR 
		(Ano = 2026 AND Mes = 3 AND Quinzena = 1)
	)
--fim ajuste paliativo


update
	b
set
	b.Odometro = a.Odometro
	,b.DistanciaSVC = a.distancetostation
	,b.KmTotal = a.KmTotal
from
	#tb_ml_bsc_rtt a
	join tb_ml_bsc_rtt b on a.Ano = b.Ano
							and a.Mes = b.Mes
							and a.Quinzena = b.Quinzena
							and a.Route_id = b.IdRota



insert into tb_ml_bsc_rtt (
Ano
,Mes
,Quinzena
,IdRota
,Odometro
,DistanciaSVC
,KmTotal
,DataInsert 
)

select distinct
	a.Ano
	,a.Mes
	,a.Quinzena
	,a.Route_id
	,a.Odometro
	,a.distancetostation
	,a.KmTotal
	,getdate()  as DataInsert

from
	#tb_ml_bsc_rtt a
	left join tb_ml_bsc_rtt b on a.Ano = b.Ano
							and a.Mes = b.Mes
							and a.Quinzena = b.Quinzena
							and a.Route_id = b.IdRota
where
	b.IdRota is null
 

  


UPDATE a
   SET a.idkmrtt = b.idkmrtt
FROM tb_ml_rotas a
JOIN tb_ml_bsc_rtt b
     ON b.idrota = a.idrota
WHERE a.idkmrtt IS NULL
  AND a.datareferencia >= DATEADD(DAY, -20, CAST(GETDATE() AS date))

end

GO
