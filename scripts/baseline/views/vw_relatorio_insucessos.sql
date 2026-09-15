-- ============================================================
-- BASELINE: dbo.vw_relatorio_insucessos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_relatorio_insucessos]    Script Date: 14/09/2026 12:12:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   VIEW [dbo].[vw_relatorio_insucessos] AS
WITH PacotesAlvo AS (
    SELECT
         p.IdTransportadora
        ,p.IdPacote
    FROM dbo.tb_ml_pacotes p WITH(NOLOCK)
    WHERE p.DataReferencia = CONVERT(date, '2025-07-01') 
      --AND p.IdTransportadora = 643493085
      AND p.Excluido = 0
      AND p.StatusEntrega = 'not_delivered'
    GROUP BY p.IdTransportadora, p.IdPacote
),
TentativasBase AS (
    SELECT
         p.IdTransportadora
        ,p.DataReferencia
        ,p.DataHoraEntrega AS DataEvento
        ,p.StatusEntrega
        ,p.SubStatus
        ,p.IdPacote
        ,p.IdRota
        ,p.TipoEndereco
        ,p.Cidade AS CidadeEntrega
        ,p.ForaAreaEntrega
    FROM dbo.tb_ml_pacotes p WITH(NOLOCK)
    INNER JOIN PacotesAlvo a
        ON a.IdTransportadora = p.IdTransportadora
       AND a.IdPacote = p.IdPacote
    WHERE p.Excluido = 0
),
TentativasOrdenadas AS (
    SELECT
         tb.*
        ,ROW_NUMBER() OVER (
            PARTITION BY tb.IdTransportadora, tb.IdPacote
            ORDER BY tb.DataEvento, tb.DataReferencia
         ) AS OrdemTentativa
    FROM TentativasBase tb
),
TentativasComPrimeiraTransferencia AS (
    SELECT
         t.*
        ,MIN(CASE
                WHEN t.StatusEntrega = 'not_delivered'
                 AND t.SubStatus = 'transferred'
                THEN t.OrdemTentativa
             END) OVER (
                PARTITION BY t.IdTransportadora, t.IdPacote
             ) AS OrdemTentativaTransferencia
    FROM TentativasOrdenadas t
),
TentativasComResumoBase AS (
    SELECT
         t.*
        ,MAX(CASE WHEN t.StatusEntrega = 'delivered' THEN 1 ELSE 0 END) OVER (
            PARTITION BY t.IdTransportadora, t.IdPacote
         ) AS PacoteRecuperado
        ,CASE WHEN t.OrdemTentativaTransferencia IS NULL THEN 0 ELSE 1 END AS TeveTransferencia
        ,MAX(CASE
                WHEN t.OrdemTentativa = t.OrdemTentativaTransferencia
                THEN t.IdRota
             END) OVER (
                PARTITION BY t.IdTransportadora, t.IdPacote
             ) AS IdRotaTransferencia
    FROM TentativasComPrimeiraTransferencia t
),
Tentativas AS (
    SELECT
         t.*
        ,MAX(CASE
                WHEN t.OrdemTentativaTransferencia IS NOT NULL
                 AND t.StatusEntrega = 'delivered'
                 AND t.OrdemTentativa > t.OrdemTentativaTransferencia
                 AND t.IdRota <> t.IdRotaTransferencia
                THEN 1 ELSE 0
             END) OVER (
                PARTITION BY t.IdTransportadora, t.IdPacote
             ) AS TransferredRecuperado
    FROM TentativasComResumoBase t
),
ReversaoPacote AS (
    SELECT
         h.IdTransportadora
        ,h.IdPacote
        ,MAX(CAST(h.Revertido AS int)) AS Revertido
        ,case when MAX(CAST(h.Revertido AS int)) = 1 then 'Sim' else 'Não' end as Desc_revertido
		,MAX(CAST(h.RevertidoOutraRota AS int)) AS RevertidoOutraRota
    FROM dbo.tb_ml_hist_insucesso h WITH(NOLOCK)
    INNER JOIN PacotesAlvo a
        ON a.IdTransportadora = h.IdTransportadora
       AND a.IdPacote = h.IdPacote
    GROUP BY h.IdTransportadora, h.IdPacote
),
EnderecoVisitadoPacote AS (
    SELECT
         tb.IdTransportadora
        ,tb.IdPacote
        ,tb.IdRota
        ,tb.DataEvento
        ,MAX(CASE WHEN st.se_ds_classificacao = 'Visitado' THEN 1 ELSE 0 END) AS EnderecoVisitado
    FROM TentativasBase tb
    LEFT JOIN dbo.tb_ml_traducoes t3
        ON tb.SubStatus = t3.tds_vl_json
       AND t3.tds_nm_tabela = 'tb_ml_pacotes'
       AND t3.tds_nm_campo = 'SubStatus'
    LEFT JOIN dbo.tb_clientes cli WITH(NOLOCK)
        ON tb.IdTransportadora = cli.cli_id_logistics
    LEFT JOIN dbo.tb_ml_status_entrega st WITH(NOLOCK)
        ON t3.tds_ds_traducao = st.se_ds_status_entrega
       AND st.TenantID = cli.cli_cd_codigo_cliente
    GROUP BY tb.IdTransportadora, tb.IdPacote, tb.IdRota, tb.DataEvento,tb.ForaAreaEntrega
),
AmbulanciaRota AS (
    SELECT amb_id_rota
    FROM dbo.tb_looker_ambulancias WITH(NOLOCK)
    GROUP BY amb_id_rota
)
SELECT
     t.IdTransportadora
    ,t.DataReferencia
    ,t.DataEvento
    ,ISNULL(trad_status.tds_ds_traducao, t.StatusEntrega) AS StatusEntrega
    ,ISNULL(trad_substatus.tds_ds_traducao, t.SubStatus) AS SubStatus
    ,t.IdPacote
    ,t.IdRota
    ,t.TipoEndereco
    ,t.CidadeEntrega
    ,t.OrdemTentativa
    ,t.ForaAreaEntrega
    ,ISNULL(evp.EnderecoVisitado, 0) AS EnderecoVisitado
    ,r.ServiceCenter AS Base
    ,r.NomeMotorista
    ,r.TipoVeiculo
    ,ISNULL(rp.Revertido, 0) AS Revertido
	,ISNULL(rp.Desc_revertido, 'Não') AS Desc_revertido
    ,ISNULL(rp.RevertidoOutraRota, 0) AS RevertidoOutraRota
    ,t.PacoteRecuperado
    ,t.TeveTransferencia
    ,t.TransferredRecuperado
    ,CASE WHEN amb.amb_id_rota IS NOT NULL THEN 1 ELSE 0 END AS EhAmbulancia
    ,comprador.NomeComprador
    ,comprador.TelefoneComprador
    ,comprador.NomeContato1
    ,comprador.TelefoneContato1
    ,comprador.EmailContato1
    ,comprador.NomeContato2
FROM Tentativas t
JOIN dbo.tb_ml_rotas r WITH(NOLOCK)
    ON r.IdRota = t.IdRota
   AND r.IdTransportadora = t.IdTransportadora
   AND r.Excluido = 0
   AND r.StatusRota <> 'planned'
LEFT JOIN ReversaoPacote rp
    ON rp.IdTransportadora = t.IdTransportadora
   AND rp.IdPacote = t.IdPacote
LEFT JOIN dbo.tb_ml_detalhes_pacotes comprador WITH(NOLOCK)
    ON comprador.IdTransportadora = t.IdTransportadora
   AND comprador.IdPacote = t.IdPacote
LEFT JOIN EnderecoVisitadoPacote evp
    ON evp.IdTransportadora = t.IdTransportadora
   AND evp.IdPacote = t.IdPacote
   AND evp.IdRota = t.IdRota
   AND evp.DataEvento = t.DataEvento
LEFT JOIN AmbulanciaRota amb
    ON amb.amb_id_rota = t.IdRota
LEFT JOIN dbo.tb_ml_traducoes trad_status WITH(NOLOCK)
    ON t.StatusEntrega = trad_status.tds_vl_json
   AND trad_status.tds_nm_tabela = 'tb_ml_pacotes'
   AND trad_status.tds_nm_campo = 'StatusEntrega'
LEFT JOIN dbo.tb_ml_traducoes trad_substatus WITH(NOLOCK)
    ON t.SubStatus = trad_substatus.tds_vl_json
   AND trad_substatus.tds_nm_tabela = 'tb_ml_pacotes'
   AND trad_substatus.tds_nm_campo = 'SubStatus';

GO
