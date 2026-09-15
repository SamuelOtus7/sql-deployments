-- ============================================================
-- BASELINE: dbo.UspMLReprocessamento_detalhes_contatos
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessamento_detalhes_contatos]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[UspMLReprocessamento_detalhes_contatos]
 AS

 /*

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

-- ?? GRUPO 1: PACOTES
SELECT
    cli.cli_cd_codigo_cliente         AS dar_cd_cliente,
    1207       AS dar_cd_lista_transportadora,
    1209       AS dar_cd_lista_operacao,
    CAST(pacotes.idrota AS INT)       AS dar_cd_rota,
    1212       AS dar_cd_lista_status,
    1246       AS dar_cd_lista_acao,
    3          AS dar_nr_maximo_tentativas,
    0          AS dar_nr_execucoes,
    NULL       AS dar_dh_processamento,
    NULL       AS dar_ds_erro_message,
    GETDATE()  AS dar_dh_criacao,
    CAST(pacotes.IdPacote AS VARCHAR) AS dar_cd_pacote
FROM tb_ml_pacotes AS pacotes WITH (NOLOCK)
LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
       ON pacotes.IdPacote = detalhes.IdPacote
INNER JOIN tb_clientes AS cli WITH (NOLOCK)
       ON pacotes.IdTransportadora = cli.cli_id_logistics
WHERE pacotes.DataReferencia  = '2026-06-16'
AND pacotes.IdTransportadora IN (1025381599,652375997,1950609251)
  AND pacotes.StatusEntrega = 'not_delivered'
  AND pacotes.Excluido = 0
  AND cli.cli_in_ativo = 1
  AND (
        detalhes.telefonecontato1 IS NULL OR
        detalhes.telefonecontato1 = 'N/D'
  )
  */


  

--  select * from tb_clientes
  
--UNION

-- ?? GRUPO 2: PNR
--SELECT
--    cli.cli_cd_codigo_cliente         AS dar_cd_cliente,
--    1207       AS dar_cd_lista_transportadora,
--    1209       AS dar_cd_lista_operacao,
--    CAST(IdRota AS VARCHAR)           AS dar_cd_rota,
--    1212       AS dar_cd_lista_status,
--    1246       AS dar_cd_lista_acao,
--    3          AS dar_nr_maximo_tentativas,
--    0          AS dar_nr_execucoes,
--    NULL       AS dar_dh_processamento,
--    NULL       AS dar_ds_erro_message,
--    GETDATE()  AS dar_dh_criacao,
--    CAST(pnr.IdPacote AS VARCHAR)     AS dar_cd_pacote
--FROM tb_ml_pnr AS pnr WITH (NOLOCK)
--INNER JOIN tb_ml_pacotes pacotes WITH (NOLOCK)
--        ON pacotes.IdPacote = pnr.IdPacote
--INNER JOIN tb_clientes AS cli WITH (NOLOCK)
--        ON pacotes.IdTransportadora = cli.cli_id_logistics
--LEFT JOIN tb_ml_detalhes_pacotes AS detalhes WITH (NOLOCK)
--        ON detalhes.IdPacote = pnr.IdPacote
--WHERE pacotes.DataReferencia = '2025-09-11'
--AND pacotes.IdTransportadora IN (1025381599,652375997,1950609251)
--  AND (
--        detalhes.telefonecontato1 IS NULL OR
--        detalhes.telefonecontato1 = 'N/D'
--  )
  
--  ;
GO
