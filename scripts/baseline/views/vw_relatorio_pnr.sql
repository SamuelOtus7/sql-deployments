-- ============================================================
-- BASELINE: dbo.vw_relatorio_pnr
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_relatorio_pnr]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_relatorio_pnr]
AS
SELECT
    ROW_NUMBER() OVER (
        PARTITION BY p.IdPacote, idReclamacao
        ORDER BY p.DataHoraEntrega DESC, mot.mot_cd_matricula DESC
    ) AS ID,
    r.idRota,
    r.IdTransportadora,
    idReclamacao,
    p.idPacote,
    p.DataHoraEntrega,
    EnderecoParada,
    ISNULL(tra_status.tds_ds_traducao, pnr.Status) AS Status,
    NomeMotorista,
    r.DataReferencia,
    StatusEntrega,
    ISNULL(tra_substatus.tds_ds_traducao, p.SubStatus) AS SubStatus,
    r.Ambulancia,
    IdRotaOrigem,
    IdRotaDestino,
    pnr.ServiceCenter,
    OrigemSaida,
    pnr.Valor,
    detalhes.NomeComprador,
    detalhes.Endereco AS EnderecoComprador,
    detalhes.TelefoneComprador,
    detalhes.SituacaoDasColetas,
    CASE
        WHEN detalhes.SituacaoDasColetas = 'SEM_INFORMACAO'
            THEN 'Rota sem informação disponibilizada na API'
        WHEN detalhes.SituacaoDasColetas = 'INFORMACAO_DISPONIBILIZADA'
            THEN 'Informação disponibilizada na API'
        ELSE NULL
    END AS DescricaoSituacaoDasColetas,
    ISNULL(pre.Total, 0) AS ValorPreFaturaPNR,
    pnr.Datareclamacao,
    mot.mot_cd_matricula AS Matricula,
    pnr.DataFechamento,
    pnr.DataColeta,
    r.UsuarioDA,
    pnr.Status AS StatusPuro,
    r.DriverId as IdMotorista

FROM dbo.tb_ml_rotas r WITH (NOLOCK)
INNER JOIN dbo.tb_ml_pacotes p WITH (NOLOCK)
    ON r.idtransportadora = p.idtransportadora
   AND r.idrota = p.idrota
   AND r.datareferencia = p.datareferencia
INNER JOIN dbo.tb_ml_pnr pnr WITH (NOLOCK)
    ON pnr.IdPacote = p.IdPacote
   AND pnr.IdTransportadora = r.IdTransportadora
LEFT JOIN dbo.tb_clientes c WITH (NOLOCK)
    ON r.idtransportadora = c.cli_id_logistics
LEFT JOIN dbo.tb_ml_traducoes tra_status WITH (NOLOCK)
    ON pnr.Status = tra_status.tds_vl_json
   AND tra_status.tds_nm_tabela = 'tb_ml_pnr'
   AND tra_status.tds_nm_campo = 'Status'
LEFT JOIN dbo.tb_ml_traducoes tra_substatus WITH (NOLOCK)
    ON p.SubStatus = tra_substatus.tds_vl_json
   AND tra_substatus.tds_nm_tabela = 'tb_ml_pacotes'
   AND tra_substatus.tds_nm_campo = 'SubStatus'
LEFT JOIN dbo.tb_ml_detalhes_pacotes detalhes WITH (NOLOCK)
    ON detalhes.IdPacote = p.IdPacote
   AND detalhes.IdTransportadora = p.IdTransportadora
LEFT JOIN dbo.tb_fin_prefatura_descontos pre WITH (NOLOCK)
    ON pre.idpacote = pnr.idpacote
   AND pre.Descricao LIKE '%pnr pack%'
LEFT JOIN dbo.tb_motorista mot WITH (NOLOCK)
    ON mot.mot_nm_motorista = r.nomemotorista
   AND mot.mot_cd_cliente = c.cli_cd_codigo_cliente

INNER JOIN dbo.tb_parametros prm WITH (NOLOCK)
    ON prm.prm_cod_cliente = c.cli_cd_codigo_cliente
   AND prm.prm_nm_parametro = 'Habilitar Analise de PNR'
   AND prm.prm_ds_valor = 'true'


WHERE r.DataReferencia >= CAST(GETDATE() - 90 AS DATE)
  AND p.Excluido = 0
  AND c.cli_in_ativo = 1
  AND r.StatusRota <> 'planned'


GO
