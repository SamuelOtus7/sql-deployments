-- ============================================================
-- BASELINE: dbo.usp_GetPacotesPNR
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_GetPacotesPNR]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE PROCEDURE [dbo].[usp_GetPacotesPNR]
(
    @cli_cd_codigo_cliente INT,
    @DataInicial DATE,
    @DataFinal   DATE
)
AS
BEGIN
    SET NOCOUNT ON;


    DECLARE @IdTransportadora INT;

    SELECT
        @IdTransportadora = c.cli_id_logistics
    FROM dbo.tb_clientes c WITH (NOLOCK)
    WHERE
        c.cli_cd_codigo_cliente = @cli_cd_codigo_cliente
        AND c.cli_in_ativo = 1
        AND c.cli_in_excluido = 0;

    /* Se não encontrar transportadora válida, não retorna nada */
    IF @IdTransportadora IS NULL
        RETURN;

    /* =========================================================
       2) Query principal
       ========================================================= */
    SELECT  
            ROW_NUMBER() OVER
            (
                PARTITION BY p.IdPacote, pnr.idReclamacao
                ORDER BY p.DataHoraEntrega DESC, mot.mot_cd_matricula DESC
            ) AS ID,

            r.IdRota,
            r.IdTransportadora,
            pnr.idReclamacao,
            p.IdPacote,
            p.EnderecoParada,
            ISNULL(tra_status.tds_ds_traducao, pnr.Status) AS Status,
            r.NomeMotorista,
            r.DataReferencia,
            p.StatusEntrega,
            ISNULL(tra_substatus.tds_ds_traducao, p.SubStatus) AS SubStatus,
            r.Ambulancia,
            p.IdRotaOrigem,
            p.IdRotaDestino,
            pnr.ServiceCenter,
            r.OrigemSaida,
            pnr.Valor,
            detalhes.NomeComprador,
            detalhes.Endereco AS EnderecoComprador,
            detalhes.TelefoneComprador,
            ISNULL(pre.Total, 0) AS ValorPreFaturaPNR,
            pnr.DataReclamacao,
            mot.mot_cd_matricula AS Matricula,
            pnr.DataFechamento,
            pnr.DataColeta,
			r.UsuarioDA as IDMotorista
		   ,pnrtela.motivo
		   ,pnrtela.erro
		   ,pnrtela.status_fechamento
		   ,pnrtela.contato_cliente
		   ,pnrtela.telefone
		   ,pnrtela.observacao

    FROM dbo.tb_ml_rotas r WITH (NOLOCK)

    INNER JOIN dbo.tb_ml_pacotes p WITH (NOLOCK)
        ON  r.IdTransportadora = p.IdTransportadora
        AND r.IdRota          = p.IdRota
        AND r.DataReferencia  = p.DataReferencia

    INNER JOIN dbo.tb_ml_pnr pnr WITH (NOLOCK)
        ON  pnr.IdPacote         = p.IdPacote
        AND pnr.IdTransportadora = r.IdTransportadora

    LEFT JOIN dbo.tb_clientes c WITH (NOLOCK)
        ON r.IdTransportadora = c.cli_id_logistics

    LEFT JOIN dbo.tb_ml_traducoes tra_status WITH (NOLOCK)
        ON  pnr.Status              = tra_status.tds_vl_json
        AND tra_status.tds_nm_tabela = 'tb_ml_pnr'
        AND tra_status.tds_nm_campo  = 'Status'

    LEFT JOIN dbo.tb_ml_traducoes tra_substatus WITH (NOLOCK)
        ON  p.SubStatus              = tra_substatus.tds_vl_json
        AND tra_substatus.tds_nm_tabela = 'tb_ml_pacotes'
        AND tra_substatus.tds_nm_campo  = 'SubStatus'

    LEFT JOIN dbo.tb_ml_detalhes_pacotes detalhes WITH (NOLOCK)
        ON  detalhes.IdPacote         = p.IdPacote
        AND detalhes.IdTransportadora = p.IdTransportadora

    LEFT JOIN dbo.tb_fin_prefatura_descontos pre WITH (NOLOCK)
        ON  pre.IdPacote = pnr.IdPacote
        AND pre.Descricao LIKE '%pnr pack%'

    LEFT JOIN dbo.tb_motorista mot WITH (NOLOCK)
        ON  mot.mot_nm_motorista = r.NomeMotorista
        AND mot.mot_cd_cliente   = c.cli_cd_codigo_cliente

	LEFT JOIN dbo.tb_ml_pnr_Tela pnrtela on pnrtela.idreclamacao = pnr.IdReclamacao and pnrtela.idtransportadora = pnr.IdTransportadora


    WHERE
            r.IdTransportadora = @IdTransportadora
        AND r.DataReferencia BETWEEN @DataInicial AND @DataFinal
        AND p.Excluido = 0
        AND c.cli_in_ativo = 1
        AND r.StatusRota <> 'planned';
END


GO
