/*==============================================================================
  ROLLBACK MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86ahqbpd4
  Autor        : Devin
  Data         : 2026-09-28
  Descrição    : Reverte o forward 011: restaura dbo.UspAtualizaFaixaRTT para a
                 versão vigente em produção (sem CodigoCliente) e remove a
                 coluna CodigoCliente de dbo.tb_ml_bsc_rtt.
                 ATENÇÃO: dados de CodigoCliente gravados entre deploy e
                 rollback são perdidos com o DROP COLUMN.
  Forward ref  : scripts/forward/2026/09/011_forward_CU-86ahqbpd4_rtt_codigo_cliente.sql
  Objetos      : dbo.UspAtualizaFaixaRTT, dbo.tb_ml_bsc_rtt (coluna CodigoCliente)
  ==============================================================================*/

SET NOCOUNT ON;

/* ============================================================================
   ALTER PROCEDURE UspAtualizaFaixaRTT (versão anterior ao forward 011)
   ----------------------------------------------------------------------------
   Restaura a definição vigente em produção (evidência 2026-09-28:
   OBJECT_DEFINITION idêntico ao baseline scripts/baseline/procedures/
   UspAtualizaFaixaRTT.sql), sem propagação de CodigoCliente.
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

BEGIN TRY
    --==========================================================================
    -- Remove a coluna CodigoCliente (se existir)
    --==========================================================================
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_rtt') AND name = 'CodigoCliente'
    )
    BEGIN
        ALTER TABLE [dbo].[tb_ml_bsc_rtt] DROP COLUMN [CodigoCliente];
        PRINT 'Coluna CodigoCliente removida de dbo.tb_ml_bsc_rtt.';
    END
    ELSE
        PRINT 'Coluna CodigoCliente não existe em dbo.tb_ml_bsc_rtt.';

    --==========================================================================
    -- POS-CHECK
    --==========================================================================
    IF EXISTS (
        SELECT 1 FROM sys.columns
        WHERE object_id = OBJECT_ID('dbo.tb_ml_bsc_rtt') AND name = 'CodigoCliente'
    )
        THROW 50005, 'Pós-check falhou: coluna CodigoCliente não foi removida.', 1;

    IF OBJECT_DEFINITION(OBJECT_ID('dbo.UspAtualizaFaixaRTT')) LIKE '%CodigoCliente%'
        THROW 50006, 'Pós-check falhou: procedure ainda contém CodigoCliente.', 1;

    PRINT 'SUCESSO: Rollback executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);

    THROW;
END CATCH;
GO
