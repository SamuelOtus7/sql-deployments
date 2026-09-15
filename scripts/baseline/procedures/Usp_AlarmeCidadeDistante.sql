-- ============================================================
-- BASELINE: dbo.Usp_AlarmeCidadeDistante
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeCidadeDistante]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_AlarmeCidadeDistante] as

DROP TABLE IF EXISTS #base;

		SELECT
		       cli_ds_nome,
		       dataReferencia,
		       COUNT(*) AS qtd
		  INTO #base
		  FROM tb_ml_rotas AS a  WITH(NOLOCK)
    INNER JOIN tb_clientes AS b  WITH(NOLOCK)
		    ON cli_id_logistics = idtransportadora 
	INNER JOIN tb_bases as c  WITH(NOLOCK)
			ON case when servicecenter <> origemsaida and left(OrigemSaida,1) in ('E','M')  then origemsaida else servicecenter end = c.bss_ds_sigla 	
		   and a.idtransportadora = c.bss_cd_idtransportadora 
		 WHERE dataReferencia  = cast(GETDATE() as date)
		   AND excluido = 0  
		   AND StatusRota not in ('planned' ,'canceled')
		   AND (TotalPacotes > 0 or PacotesTransferidos > 0)  
		   AND CidadeDistante IS NULL
		   AND cast(bss_dc_longitude as decimal(14,10)) between -90 and 90
		   AND c.bss_dc_latitude	 is not null
		   AND c.bss_dc_longitude	 is not null
		   AND b.cli_in_ativo = 1
		   AND DATEADD(HOUR, -3, DataHoraColeta) <= DATEADD(MINUTE, -15, GETDATE())
	  GROUP BY cli_ds_nome, dataReferencia
		HAVING COUNT(*) > 100
	  ORDER BY 1, dataReferencia
		
		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base;


    RAISERROR ('Faltando CidadeDistante para os seguintes clientes e datas:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
