-- ============================================================
-- BASELINE: dbo.vw_rel_transferencias
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_rel_transferencias]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_rel_transferencias] as 

WITH Transferencias AS
(
    SELECT 
          a.DataReferencia     
         ,a.IdTransportadora    
         ,a.idrota      
         ,CASE 
              WHEN ambulancia.amb_id_rota IS NOT NULL THEN 'Amb' 
              ELSE NULL 
          END AS Ambulancia    
         ,CASE 
              WHEN ambulanciaDestino.amb_id_rota IS NOT NULL THEN 'Amb' 
              ELSE NULL 
          END AS ambulanciaDestino    
         ,a.idpacote      
         ,ROW_NUMBER() OVER
          (    
              PARTITION BY a.idpacote    
              ORDER BY a.DataHoraEntrega    
          ) AS OrdemRepeticaoIdPacote    
         ,RtOrigem.nomemotorista AS MotoristaOrigem      
         ,CASE 
              WHEN RtOrigem.servicecenter <> RtOrigem.origemsaida 
                OR LEFT(RtOrigem.origemsaida, 1) <> 'B'  
              THEN RtOrigem.origemsaida 
              ELSE RtOrigem.servicecenter 
          END AS BaseOrigem      
         ,RtOrigem.TipoVeiculo AS TipoVeiculoOrigem      
         ,a.DataHoraEntrega AS DataHoraEventoIncial   
         ,pctDestino.DataHoraEntrega AS DataEntrega   
         ,DATEPART(HOUR, pctDestino.DataHoraEntrega) AS HoraEntrega
         ,(DATEPART(MINUTE, pctDestino.DataHoraEntrega) / 15) * 15 AS MinutoEntrega
         ,a.IdRotaDestino      
         ,RtDestino.nomemotorista AS MotoridtaDestino      
         ,CASE 
              WHEN RtDestino.servicecenter <> RtDestino.origemsaida 
                OR LEFT(RtDestino.origemsaida, 1) <> 'B'  
              THEN RtDestino.origemsaida 
              ELSE RtDestino.servicecenter 
          END AS BaseDestino      
         ,RtDestino.TipoVeiculo AS TipoVeiculoDestino       
         ,pctDestino.StatusEntrega     
         ,pctDestino.SubStatus     
         ,se_ds_classificacao AS VisitaEndereco  
         


    FROM tb_ml_pacotes AS a WITH (NOLOCK)      
    INNER JOIN tb_ml_rotas AS RtOrigem WITH (NOLOCK)      
        ON a.idrota = RtOrigem.idrota      
       AND RtOrigem.Excluido = 0    
       AND RtOrigem.StatusRota <> 'planned'    
    INNER JOIN tb_ml_rotas AS RtDestino WITH (NOLOCK)      
        ON a.IdRotaDestino = RtDestino.idrota      
       AND RtDestino.Excluido = 0    
       AND RtDestino.StatusRota <> 'planned'    
    LEFT JOIN tb_ml_pacotes AS pctDestino WITH (NOLOCK)      
        ON a.IdRotaDestino = pctDestino.idrota       
       AND a.idpacote = pctDestino.idpacote      
    LEFT JOIN tb_looker_ambulancias AS ambulancia     
        ON ambulancia.amb_id_rota = a.idrota    
    LEFT JOIN tb_looker_ambulancias AS ambulanciaDestino     
        ON ambulanciaDestino.amb_id_rota = a.IdRotaDestino    
    LEFT JOIN tb_clientes cli WITH (NOLOCK) 
        ON pctDestino.IdTransportadora = cli.cli_id_logistics  
    LEFT JOIN tb_ml_traducoes t3 
        ON pctDestino.SubStatus = t3.tds_vl_json 
       AND t3.tds_nm_tabela = 'tb_ml_pacotes' 
       AND t3.tds_nm_campo = 'SubStatus'  
    LEFT JOIN tb_ml_status_entrega AS st 
        ON t3.tds_ds_traducao = st.se_ds_status_entrega 
       AND st.TenantID = cli.cli_cd_codigo_cliente  
    WHERE 1 = 1       
      AND a.datareferencia >= '20260601'      
      AND a.excluido = 0      
),
UltimaTentativa AS
(
    SELECT
        idpacote,
        MAX(OrdemRepeticaoIdPacote) AS MaxOrdem
    FROM Transferencias
    GROUP BY idpacote
),
PacotesComCircularidade AS
(
    SELECT DISTINCT
        t1.idpacote
        ,t1.MotoridtaDestino as MotoristaEntregaCirc
    FROM Transferencias t1
    INNER JOIN UltimaTentativa u
        ON u.idpacote = t1.idpacote
    INNER JOIN Transferencias t2
        ON t2.idpacote = u.idpacote
       AND t2.OrdemRepeticaoIdPacote = u.MaxOrdem
    WHERE t1.OrdemRepeticaoIdPacote = 1
      AND t2.OrdemRepeticaoIdPacote > 1
      AND t1.MotoristaOrigem = t2.MotoridtaDestino
)
SELECT
      t.DataReferencia
     ,t.IdTransportadora
     ,t.idrota
     ,t.Ambulancia
     ,t.ambulanciaDestino
     ,t.idpacote
     ,t.OrdemRepeticaoIdPacote

     ,CASE 
          WHEN c.idpacote IS NOT NULL THEN 1
          ELSE 0
      END AS PossuiCircularidade

     ,CASE 
          WHEN t.OrdemRepeticaoIdPacote = 1 THEN 1
          ELSE 0
      END AS StatusInicial

     ,CASE 
          WHEN t.OrdemRepeticaoIdPacote = u.MaxOrdem THEN 1
          ELSE 0
      END AS StatusFinal

     ,CASE 
          WHEN t.OrdemRepeticaoIdPacote > 1
           AND t.OrdemRepeticaoIdPacote < u.MaxOrdem THEN 1
          ELSE 0
      END AS StatusIntermediario

     ,t.MotoristaOrigem
     ,t.BaseOrigem
     ,t.TipoVeiculoOrigem
     ,t.DataHoraEventoIncial
     ,t.DataEntrega
     ,t.HoraEntrega
     ,t.MinutoEntrega
     ,t.IdRotaDestino
     ,t.MotoridtaDestino
     ,t.BaseDestino
     ,t.TipoVeiculoDestino
     ,t.StatusEntrega
     ,t.SubStatus
     ,t.VisitaEndereco
     ,t.MotoridtaDestino + N' ? ' + c.MotoristaEntregaCirc    as ParCircularidade

FROM Transferencias t
INNER JOIN UltimaTentativa u
    ON u.idpacote = t.idpacote
LEFT JOIN PacotesComCircularidade c
    ON c.idpacote = t.idpacote;
GO
