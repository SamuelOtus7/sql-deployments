-- ============================================================
-- BASELINE: dbo.Usp_RotasComPacotesPendentes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_RotasComPacotesPendentes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[Usp_RotasComPacotesPendentes] as

DROP TABLE IF EXISTS #base;



Select 
idtransportadora,
cli_ds_nome,
datareferencia,
COUNT(*) as qtd
into #base
from tb_ml_rotas nolock
 INNER JOIN tb_clientes AS b  WITH(NOLOCK)
 ON cli_id_logistics = idtransportadora 
where datareferencia between cast(getdate()-10 as date) and cast(getdate()-1 as date)
and excluido = 0
and StatusRota <> 'planned'
and pacotespendentes > 0  
group by idtransportadora, datareferencia,cli_ds_nome


		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base;


    RAISERROR ('Rotas com pacotes pendentes para os seguintes clientes e datas, Verificar com o time de Dados:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;


GO
