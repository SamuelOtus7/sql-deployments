-- ============================================================
-- BASELINE: dbo.Usp_AlarmeColetaRotasReprocessamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeColetaRotasReprocessamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
    
CREATE procedure [dbo].[Usp_AlarmeColetaRotasReprocessamento] as    
    
DROP TABLE IF EXISTS #base;    
    
  SELECT     
    dhr_cd_cliente,    
    MAX(dhr_dh_coleta) AS UltimaColeta,    
    cli_ds_nome       
   INTO #base    
    FROM     
        tb_dra_historico_rotas a with(nolock)    
     join tb_clientes b   with(nolock)    
     on a.dhr_cd_cliente = b.cli_id_logistics    
     and cli_in_ativo = 1    
    where cli_ds_nome not in ('Flashlog')    
    GROUP BY     
        dhr_cd_cliente,    
     cli_ds_nome    
    HAVING     
        MAX(dhr_dh_coleta) <= DATEADD(day, -1, GETDATE())    
      
      
      
IF EXISTS (SELECT 1 FROM #base)    
BEGIN    
    DECLARE @msg NVARCHAR(MAX) = '';    
    
    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), UltimaColeta, 23) +CHAR(10)    
    FROM #base;    
    
    
    RAISERROR ('Verificar com time de desenvolvimento. Última rota coletada na tabela tb_dra_historico_rotas para os clientes foram em: %s%s', 16, 1, @msg);    
END    
ELSE    
BEGIN    
    PRINT 'OK';    
END;    
  
  
GO
