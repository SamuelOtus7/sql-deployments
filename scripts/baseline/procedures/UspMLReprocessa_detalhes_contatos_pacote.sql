-- ============================================================
-- BASELINE: dbo.UspMLReprocessa_detalhes_contatos_pacote
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessa_detalhes_contatos_pacote]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create procedure [dbo].[UspMLReprocessa_detalhes_contatos_pacote]
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
    CAST(pacotes.idrota AS INT) AS dar_cd_rota,
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
WHERE pacotes.DataReferencia >= '2025-09-01'
  AND pacotes.IdTransportadora IN (1025381599)
  AND pacotes.StatusEntrega = 'not_delivered'
  AND pacotes.Excluido = 0
  AND cli.cli_in_ativo = 1
  AND (
        detalhes.telefonecontato1 IS NULL OR
        detalhes.telefonecontato1 = 'N/D'
  )
  AND NOT EXISTS (
        SELECT 1
        FROM tb_dra_reprocessamento repro WITH (NOLOCK)
        WHERE repro.dar_cd_pacote = CAST(pacotes.IdPacote AS VARCHAR)
          AND (
              repro.dar_dh_processamento IS NULL
              OR DATEDIFF(MINUTE, repro.dar_dh_processamento, GETDATE()) < 60
          )
  );
GO
