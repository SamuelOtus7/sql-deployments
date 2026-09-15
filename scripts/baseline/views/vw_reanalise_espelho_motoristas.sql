-- ============================================================
-- BASELINE: dbo.vw_reanalise_espelho_motoristas
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_reanalise_espelho_motoristas]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_reanalise_espelho_motoristas]
AS
SELECT
    sol.lsm_cd_log_status                    AS IdLogSolicitacao,
  esp.mtn_cod_cliente                      AS TenantId,
    sol.lsm_dt_data_log                      AS DataHoraSolicitacao,
    sol.lsm_cd_motorista_nfs                 AS IdPagamentoEspelho,
    sol.lsm_nm_remetente                     AS SolicitanteReanalise,
    sol.lsm_ds_mensagem                      AS DescricaoReanalise,
    periodo.pgp_cd_periodo                   AS IdPeriodoPagamento,
    periodo.pgp_nm_periodo                   AS PeriodoPagamento,
    ISNULL(resp.lsm_cd_log_status, 0)        AS IdLogResposta,
    resp.lsm_dt_data_log                     AS DataHoraResposta,
    ISNULL(resp.lsm_nm_remetente, '')        AS RespondidoPor,
    ISNULL(resp.lsm_ds_mensagem, '')         AS RespostaReanalise,
    ISNULL(stResp.lst_ds_valor, '')          AS StatusResposta
FROM 
    dbo.tb_pag_espelhos_logs AS sol with(nolock)
    INNER JOIN dbo.tb_lista AS stSol with(nolock) ON stSol.lst_cd_lista = sol.lsm_cd_status_atual
    INNER JOIN dbo.tb_usuario AS usrSol with(nolock) ON usrSol.usr_cd_usuario = sol.lsm_cd_usuario
    INNER JOIN dbo.tb_pag_espelhos AS esp with(nolock) ON esp.mtn_cd_motorista_nfs = sol.lsm_cd_motorista_nfs
    INNER JOIN dbo.tb_pgto_periodo AS periodo with(nolock) ON periodo.pgp_cd_periodo = esp.mtn_cd_pgto_periodo
    OUTER APPLY (
        SELECT 
            TOP (1) l2.*
        FROM 
            dbo.tb_pag_espelhos_logs l2 with(nolock)
        WHERE 
            l2.lsm_cd_motorista_nfs = sol.lsm_cd_motorista_nfs
            AND l2.lsm_dt_data_log > sol.lsm_dt_data_log
            AND l2.lsm_cd_status_anterior = sol.lsm_cd_status_atual
        ORDER BY 
            l2.lsm_dt_data_log, l2.lsm_cd_log_status
    ) AS resp
    LEFT JOIN dbo.tb_lista AS stResp with(nolock) ON stResp.lst_cd_lista = resp.lsm_cd_status_atual
WHERE 
    stSol.lst_ds_valor = 'Solicitado Reanálise'
    AND ISNULL(usrSol.usr_in_motorista, 0) = 1
    AND sol.lsm_dt_data_log >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE));

GO
