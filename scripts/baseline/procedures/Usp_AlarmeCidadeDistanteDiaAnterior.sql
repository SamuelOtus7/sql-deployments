-- ============================================================
-- BASELINE: dbo.Usp_AlarmeCidadeDistanteDiaAnterior
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeCidadeDistanteDiaAnterior]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Usp_AlarmeCidadeDistanteDiaAnterior] as

DROP TABLE IF EXISTS #base;

		SELECT
		       cli_ds_nome,
		       a.dataReferencia,
		       COUNT(a.idrota) AS qtd
		  INTO #base
		  FROM tb_ml_rotas AS a  WITH(NOLOCK)
    INNER JOIN tb_clientes AS b  WITH(NOLOCK)
		    ON cli_id_logistics = idtransportadora 
	INNER JOIN tb_bases as c  WITH(NOLOCK)
			ON case when servicecenter <> origemsaida and left(OrigemSaida,1) in ('E','M')  then origemsaida else servicecenter end = c.bss_ds_sigla 	
		   and a.idtransportadora = c.bss_cd_idtransportadora 
	INNER JOIN tb_ml_pacotes d with(nolock)
			on a.idrota = d.idrota
			and d.StatusEntrega not in( 'not_delivered','pending')
		 WHERE a.dataReferencia BETWEEN GETDATE()-7 AND GETDATE()-1
		   AND a.excluido = 0  
		   AND a.StatusRota not in ('planned' ,'canceled')
		   AND (a.TotalPacotes > 0 or a.PacotesTransferidos > 0)  
		   AND a.CidadeDistante IS NULL
		   AND cast(bss_dc_longitude as decimal(14,10)) between -90 and 90
		   AND c.bss_dc_latitude	 is not null
		   AND c.bss_dc_longitude	 is not null
		   AND b.cli_in_ativo = 1
		   AND DATEADD(HOUR, -3, a.DataHoraColeta) <= DATEADD(MINUTE, -15, GETDATE())
	  GROUP BY b.cli_ds_nome, a.dataReferencia
		--HAVING COUNT(*) > 20
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
