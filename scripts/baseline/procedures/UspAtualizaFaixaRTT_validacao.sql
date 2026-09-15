-- ============================================================
-- BASELINE: dbo.UspAtualizaFaixaRTT_validacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaFaixaRTT_validacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspAtualizaFaixaRTT_validacao]

AS

BEGIN

MERGE INTO [tb_ml_bsc_rtt_validacao] AS target
	USING (
				SELECT	SUBSTRING(Quinzena,1,4)			AS Ano,
						SUBSTRING(Quinzena,5,2)			AS Mes,
						SUBSTRING(Quinzena,8,1)			AS Quinzena,
						ROUTE_ID						AS IdRota,
						ISNULL(Odometro,0)				AS Odometro,
						ISNULL(DistanceToStation,0)		AS DistanciaSVC,
						ISNULL(KMTotal,0)				AS KMTotal
				FROM tb_stg_looker_rtt
				WHERE ROUTE_ID <> 0

		 ) AS source
	ON target.IdRota = source.IdRota
		AND target.Ano = source.Ano
		AND target.Mes = source.Mes
		AND target.Quinzena = source.Quinzena

	WHEN MATCHED THEN
		UPDATE SET
			target.Odometro = source.Odometro,
			target.DistanciaSVC = source.DistanciaSVC,
			target.KMTotal = source.KMTotal
			
	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			Ano,
			Mes,
			Quinzena,
			IdRota,
			Odometro,
			DistanciaSVC,
			KMTotal
		)
		VALUES (
			source.Ano,
			source.Mes,
			source.Quinzena,
			source.IdRota,
			source.Odometro,
			source.DistanciaSVC,
			source.KMTotal
		);

END

GO
