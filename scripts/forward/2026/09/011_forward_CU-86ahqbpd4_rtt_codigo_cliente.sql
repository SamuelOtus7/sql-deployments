/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahqbpd4
  Autor        : Devin
  Data         : 2026-09-28
  Descrição    : Adiciona a coluna CodigoCliente em dbo.tb_ml_bsc_rtt e altera
                 dbo.UspAtualizaFaixaRTT para propagar o CodigoCliente vindo de
                 dbo.tb_stg_looker_rtt: preenche no INSERT de rotas novas e faz
                 backfill nas linhas já existentes com match na staging.
  Rollback     : scripts/rollback/2026/09/011_rollback_CU-86ahqbpd4_rtt_codigo_cliente.sql
  Objetos      : dbo.tb_ml_bsc_rtt (coluna CodigoCliente), dbo.UspAtualizaFaixaRTT
  Dependências : dbo.tb_stg_looker_rtt (CodigoCliente), dbo.tb_ml_rotas (idkmrtt)
  ==============================================================================*/

SET NOCOUNT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECKS
    --==========================================================================
    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_rtt'))
        THROW 50001, 'Tabela dbo.tb_ml_bsc_rtt não encontrada.', 1;

    IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE object_id = OBJECT_ID('dbo.UspAtualizaFaixaRTT'))
        THROW 50002, 'Procedure dbo.UspAtualizaFaixaRTT não encontrada.', 1;

    --==========================================================================
    -- 2. Nova coluna CodigoCliente (nullable; histórico fica NULL até a proc rodar)
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_rtt') AND name = 'CodigoCliente'
    )
    BEGIN
        ALTER TABLE [dbo].[tb_ml_bsc_rtt] ADD [CodigoCliente] int NULL;
        PRINT 'Coluna CodigoCliente criada em dbo.tb_ml_bsc_rtt.';
    END
    ELSE
        PRINT 'Coluna CodigoCliente já existe em dbo.tb_ml_bsc_rtt.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO

/* ============================================================================
   ALTER PROCEDURE UspAtualizaFaixaRTT
   ----------------------------------------------------------------------------
   Única mudança em relação à versão vigente: propagação de CodigoCliente da
   tb_stg_looker_rtt (CTE -> #temp -> UPDATE de backfill -> INSERT).
   Mantidos intactos: filtro de 5 dias, dedup por Route_id (rn = 1), tratativa
   paliativa 50 MAIS e UPDATE final de tb_ml_rotas.idkmrtt.
   ============================================================================ */
CREATE OR ALTER PROCEDURE [dbo].[UspAtualizaFaixaRTT]

AS

BEGIN

DROP TABLE IF EXISTS #tb_ml_bsc_rtt;
WITH CTE AS (
    SELECT 
        SUBSTRING(quinzena, 1, 4) AS ano,
        SUBSTRING(quinzena, 5, 2) AS mes,
        SUBSTRING(quinzena, 8, 1) AS Quinzena,
        Route_id,
        CodigoCliente,
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
    ano, mes, Quinzena, Route_id, CodigoCliente, Odometro, distancetostation, kmtotal, MLP
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
	,b.CodigoCliente = a.CodigoCliente
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
,CodigoCliente
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
	,a.CodigoCliente
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

--==========================================================================
-- 3. POS-CHECKS
--==========================================================================
BEGIN TRY
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_rtt') AND name = 'CodigoCliente'
    )
        THROW 50003, 'Pós-check falhou: coluna CodigoCliente não foi criada.', 1;

    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspAtualizaFaixaRTT')) NOT LIKE '%CodigoCliente%'
        THROW 50004, 'Pós-check falhou: procedure não contém CodigoCliente.', 1;

    PRINT 'SUCESSO: tb_ml_bsc_rtt.CodigoCliente criada e UspAtualizaFaixaRTT alterada.';
END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    THROW;
END CATCH;
GO
