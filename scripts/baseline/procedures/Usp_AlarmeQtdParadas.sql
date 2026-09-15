-- ============================================================
-- BASELINE: dbo.Usp_AlarmeQtdParadas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeQtdParadas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_AlarmeQtdParadas] as

DROP TABLE IF EXISTS #base;

select
IdTransportadora
,cli_ds_nome
,DataReferencia
,COUNT(*) as qtd
into #base
from tb_ml_rotas with(nolock)
 INNER JOIN tb_clientes AS b  WITH(NOLOCK)
 ON cli_id_logistics = idtransportadora 
where StatusRota = 'Close'
and quantidadeParadas = 0
and totalpacotes > 0
and excluido = 0
and DataReferencia between cast(GETDATE()-10 as date) and cast(GETDATE()-1 as date)
group by IdTransportadora,DataReferencia,cli_ds_nome
		
		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base;


    RAISERROR ('Quantidade de Paradas zeradas para os seguintes clientes e datas, Verificar com o time de Dados:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;


GO
