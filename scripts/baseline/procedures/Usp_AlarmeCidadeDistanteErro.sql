-- ============================================================
-- BASELINE: dbo.Usp_AlarmeCidadeDistanteErro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[Usp_AlarmeCidadeDistanteErro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[Usp_AlarmeCidadeDistanteErro] as  
  
DROP TABLE IF EXISTS #base;  
  
select   
    cli_ds_nome  
    ,dataReferencia  
    , count(*) qtd  
  INTO #base    
from tb_ml_rotas as a  
  
inner join tb_clientes as b  
on cli_id_logistics = idtransportadora  
  
INNER JOIN tb_bases as c  WITH(NOLOCK)  
   ON a.ServiceCenter = c.bss_ds_sigla    
     and a.idtransportadora = c.bss_cd_idtransportadora   
  
where dataReferencia between cast(getdate()-7 as date) and cast(getdate() as date)  
and cidadedistante = 'ERROR'  
and cli_ds_nome <> 'Otus7'  
and excluido = 0  
AND a.StatusRota <> 'planned'    
  
group by cli_ds_nome, dataReferencia  
having count(*) > 0  
order by 1,dataReferencia  
  
    
IF EXISTS (SELECT 1 FROM #base)  
BEGIN  
    DECLARE @msg NVARCHAR(MAX) = '';  
  
    SELECT @msg = COALESCE(@msg + CHAR(10), '') + 'Cliente: ' + cli_ds_nome + ', Data: ' + CONVERT(NVARCHAR(10), dataReferencia, 23) + ', Quantidade: ' + CONVERT(VARCHAR(3), qtd ) + CHAR(10)  
    FROM #base;  
  
  
    RAISERROR ('CidadeDistante processou com erro. Acionar time de dados para verificar UspGeraColetaCidadesDistanteDia: %s%s', 16, 1, @msg);  
END  
ELSE  
BEGIN  
    PRINT 'OK';  
END;  
GO
