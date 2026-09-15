-- ============================================================
-- BASELINE: dbo.Usp_AlarmeRotasParaReprocessar
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeRotasParaReprocessar]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[Usp_AlarmeRotasParaReprocessar] as  
  
DROP TABLE IF EXISTS #base;  
SELECT  
      cli_ds_nome,   
   dhr_dt_data,  
   COUNT(*) AS qtd  
 into #base  
FROM (  
    SELECT   
        dhr_cd_cliente,  
        dhr_dt_data,  
        dhr_nr_rota  
    FROM tb_dra_historico_rotas  
    WHERE  dhr_dt_data >= getdate()-15  
    GROUP BY  
        dhr_cd_cliente,  
        dhr_dt_data,  
        dhr_nr_rota  
) AS RotasMeli  
LEFT JOIN tb_ml_rotas AS r  
    ON RotasMeli.dhr_cd_cliente = r.IdTransportadora  
    AND RotasMeli.dhr_nr_rota = r.IdRota  
join tb_clientes AS tc  
on r.IdTransportadora = tc.cli_id_logistics  
WHERE r.IdRota IS NULL  
and cli_in_ativo = 1  
Group by  
   cli_ds_nome,   
   dhr_dt_data  
  
  
    
    
IF EXISTS (SELECT 1 FROM #base)  
BEGIN  
    DECLARE @msg NVARCHAR(MAX) = '';  
  
    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dhr_dt_data, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)  
    FROM #base;  
  
  
    RAISERROR ('Faltando Rotas para reprocessar para os seguintes clientes e datas:%s%s', 16, 1, @msg);  
END  
ELSE  
BEGIN  
    PRINT 'OK';  
END;  
GO
