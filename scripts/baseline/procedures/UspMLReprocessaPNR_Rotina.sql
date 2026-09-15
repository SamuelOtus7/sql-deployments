-- ============================================================
-- BASELINE: dbo.UspMLReprocessaPNR_Rotina
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessaPNR_Rotina]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspMLReprocessaPNR_Rotina]
 as


 INSERT INTO dbo.tb_dra_reprocessamento (
    dar_cd_cliente,
    dar_cd_lista_transportadora,
    dar_cd_lista_operacao,
    dar_cd_rota,
    dar_cd_lista_status,
    dar_cd_lista_acao,
    dar_nr_maximo_tentativas,
    dar_nr_execucoes,
    dar_dh_processamento,
    dar_ds_erro_message,
    dar_dh_criacao,
    dar_cd_pacote
)
SELECT
    64         AS dar_cd_cliente,
    1207       AS dar_cd_lista_transportadora,
    1209       AS dar_cd_lista_operacao,
    pac.idrota  AS dar_cd_rota,
    1212       AS dar_cd_lista_status,
    1246       AS dar_cd_lista_acao,
    3          AS dar_nr_maximo_tentativas,
    0          AS dar_nr_execucoes,
    NULL       AS dar_dh_processamento,
    NULL       AS dar_ds_erro_message,
    GETDATE()  AS dar_dh_criacao,
    CAST(pnr.IdPacote AS VARCHAR) AS dar_cd_pacote



FROM tb_ml_pnr AS pnr WITH (NOLOCK)

LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
ON detalhes.IdPacote = pnr.IdPacote

inner join tb_ml_pacotes pac on pac.IdPacote = pnr.IdPacote

WHERE detalhes.TelefoneContato1 IS NULL
and cast(pac.DataReferencia as date) >='2025-09-01'
  AND pnr.IdTransportadora IN (652375997)
  and pnr.Status not in  ('CLOSED_NOT_BILLED','TO_BILL')
 AND NOT EXISTS (
        SELECT 1
        FROM tb_dra_reprocessamento repro WITH (NOLOCK)
        WHERE repro.dar_cd_pacote = CAST(pnr.IdPacote AS VARCHAR)
          AND (
              repro.dar_dh_processamento IS NULL
              OR DATEDIFF(MINUTE, repro.dar_dh_processamento, GETDATE()) < 60
          ))
		  
AND NOT EXISTS (
        SELECT 1
        FROM tb_dra_reprocessamento rep WITH (NOLOCK)
        WHERE rep.dar_cd_pacote = CAST(pac.IdPacote AS VARCHAR)
          AND (
                 rep.dar_dh_processamento IS NULL
              OR rep.dar_dh_processamento > DATEADD(HOUR, -2, GETDATE())
          )
)


GO
