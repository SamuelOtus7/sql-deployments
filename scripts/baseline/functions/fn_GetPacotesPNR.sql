-- ============================================================
-- BASELINE: dbo.fn_GetPacotesPNR
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_GetPacotesPNR]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetPacotesPNR]
(
    @cli_cd_codigo_cliente INT,
    @DataInicial DATE,
    @DataFinal   DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT  
        ROW_NUMBER() OVER
        (
            PARTITION BY p.IdPacote, pnr.IdReclamacao
            ORDER BY p.DataHoraEntrega DESC, mot.mot_cd_matricula DESC
        ) AS ID,

        r.IdRota,
        r.IdTransportadora,
        pnr.IdReclamacao,
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
        r.UsuarioDA AS IDMotorista,

        pnrtela.motivo,
        pnrtela.erro,
        pnrtela.status_fechamento,
        pnrtela.contato_cliente,
        pnrtela.telefone,
        pnrtela.observacao

    FROM dbo.tb_clientes c WITH (NOLOCK)

    INNER JOIN dbo.tb_ml_rotas r WITH (NOLOCK)
        ON r.IdTransportadora = c.cli_id_logistics

    INNER JOIN dbo.tb_ml_pacotes p WITH (NOLOCK)
        ON  r.IdTransportadora = p.IdTransportadora
        AND r.IdRota          = p.IdRota
        AND r.DataReferencia  = p.DataReferencia

    INNER JOIN dbo.tb_ml_pnr pnr WITH (NOLOCK)
        ON  pnr.IdPacote         = p.IdPacote
        AND pnr.IdTransportadora = r.IdTransportadora

    LEFT JOIN dbo.tb_ml_traducoes tra_status WITH (NOLOCK)
        ON  pnr.Status              = tra_status.tds_vl_json
        AND tra_status.tds_nm_tabela = 'tb_ml_pnr'
        AND tra_status.tds_nm_campo  = 'Status'

    LEFT JOIN dbo.tb_ml_traducoes tra_substatus WITH (NOLOCK)
        ON  p.SubStatus                 = tra_substatus.tds_vl_json
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

    LEFT JOIN dbo.tb_ml_pnr_tela pnrtela WITH (NOLOCK)
        ON  pnrtela.idreclamacao     = pnr.IdReclamacao
        AND pnrtela.idtransportadora = pnr.IdTransportadora

    WHERE
            c.cli_cd_codigo_cliente = @cli_cd_codigo_cliente
        AND c.cli_in_ativo = 1
        AND c.cli_in_excluido = 0
        AND r.DataReferencia BETWEEN @DataInicial AND @DataFinal
        AND p.Excluido = 0
        AND r.StatusRota <> 'planned'
);
GO
