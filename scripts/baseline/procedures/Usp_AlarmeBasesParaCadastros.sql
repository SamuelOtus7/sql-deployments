-- ============================================================
-- BASELINE: dbo.Usp_AlarmeBasesParaCadastros
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeBasesParaCadastros]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_AlarmeBasesParaCadastros] as

DROP TABLE IF EXISTS #base;

		SELECT
		       cli_ds_nome,
		       Servicecenter
		--       COUNT(*) AS qtd
		 INTO #base
		  FROM tb_ml_rotas AS a  WITH(NOLOCK)
    INNER JOIN tb_clientes AS b  WITH(NOLOCK)
		    ON cli_id_logistics = idtransportadora 
	LEFT JOIN tb_bases as c  WITH(NOLOCK)
			ON a.ServiceCenter = c.bss_ds_sigla 	
		   and a.idtransportadora = c.bss_cd_idtransportadora 
		 WHERE dataReferencia BETWEEN GETDATE()-50 AND GETDATE()
		   AND excluido = 0  
		   AND StatusRota not in ('planned' ,'canceled')
		   AND (TotalPacotes > 0 or PacotesTransferidos > 0)  
		   AND CidadeDistante IS NULL
		   AND b.cli_in_ativo = 1
		   AND bss_ds_sigla IS NULL
	  GROUP BY  cli_ds_nome,
		       Servicecenter
		--HAVING COUNT(*) > 20
	  ORDER BY 1
		
		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Base: ' + CONVERT(NVARCHAR(10), ServiceCenter, 23) + CHAR(10)
    FROM #base;


    RAISERROR ('Faltando Cadastro das bases abaixo para os seguintes clientes :%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
