-- ============================================================
-- BASELINE: dbo.Usp_AlarmeMapasHistoricoLogistics
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeMapasHistoricoLogistics]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[Usp_AlarmeMapasHistoricoLogistics] as

DROP TABLE IF EXISTS #base;

select 
	datareferencia
	,cli_ds_nome
	,count(distinct idrota)  qtd
		  INTO #base
	
from vw_coletar_km_rotas_trajeto 
INNER JOIN tb_clientes AS b  WITH(NOLOCK)
ON cli_id_logistics = idtransportadora 

where cli_cd_codigo_cliente  <> 7
group by datareferencia,cli_ds_nome

HAVING COUNT(distinct idrota) > 10;
		
		
IF EXISTS (SELECT 1 FROM #base)
BEGIN
    DECLARE @msg NVARCHAR(MAX) = '';

    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)
    FROM #base
	order by datareferencia;


    RAISERROR ('Servico que gera os mapas Google do relatorio Historico Logistics nao esta processando a fila vw_coletar_km_rotas_trajeto. Acionar time de Desenvolvimento:%s%s', 16, 1, @msg);
END
ELSE
BEGIN
    PRINT 'OK';
END;
GO
