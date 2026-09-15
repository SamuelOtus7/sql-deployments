-- ============================================================
-- BASELINE: dbo.UspFinanceiroEnviaParaAprovacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroEnviaParaAprovacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
    Projeto: KM Aprovacao Motorista
    Objeto:  dbo.UspFinanceiroEnviaParaAprovacao
    Ordem:   02
    Tipo:    ALTER com regras de KM via vw_pbi_auditoria_km_rotas, tb_ml_rotas e StatusRota <> 'planned'
    Dependencia: vw_pbi_auditoria_km_rotas (KmColetadoFin, FlagUsoDevidoFin, KmRtt, ParamKm1Label)
*/

CREATE   PROCEDURE [dbo].[UspFinanceiroEnviaParaAprovacao] 
(
    @IdTransportadora INT,
    @Ano INT,
    @Mes TINYINT,
    @Quinzena TINYINT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @data_inicial DATE = CAST(CAST(@Ano AS VARCHAR(4)) + '-' + CAST(@Mes AS VARCHAR(2)) + '-' + CASE WHEN @Quinzena = 1 THEN '01' ELSE '16' END AS DATE);
    DECLARE @data_final DATE = CASE 
                                    WHEN @Quinzena = 1 THEN DATEADD(DAY, 14, @data_inicial) 
                                    ELSE EOMONTH(@data_inicial) 
                                END;

    -- Materializa KM do periodo uma vez (evita join com view PBI dentro do INSERT)
    DROP TABLE IF EXISTS #KmAuditoria;

    SELECT
        aud.IdRota,
        aud.DataReferencia,
        aud.ParamKm1Label,
        aud.FlagUsoDevidoFin,
        aud.KmRtt,
        aud.KmColetadoFin,
        CAST(
            CASE
                WHEN aud.ParamKm1Label = 'KM do app Irisys' AND aud.FlagUsoDevidoFin = 0
                    THEN CAST(0 AS decimal(18,9))
                WHEN aud.ParamKm1Label = 'Faixa km da prefatura'
                    THEN ISNULL(CAST(aud.KmRtt AS decimal(18,9)), 0)
                ELSE ISNULL(CAST(aud.KmColetadoFin AS decimal(18,9)), 0)
            END
        AS decimal(18,9)) AS KmAprovacao
    INTO #KmAuditoria
    FROM dbo.vw_pbi_auditoria_km_rotas AS aud WITH (NOLOCK)
    WHERE aud.IdTransportadora = @IdTransportadora
      AND aud.DataReferencia BETWEEN @data_inicial AND @data_final;

    CREATE NONCLUSTERED INDEX IX_KmAuditoria
        ON #KmAuditoria (IdRota, DataReferencia);

    -- Exclui registros de aprovação existentes (exceto reprovados)
    DELETE fam
    FROM tb_fat_aprovacao_motorista fam
    JOIN tb_clientes cli WITH (NOLOCK) ON cli.cli_cd_codigo_cliente = fam.fam_cd_cliente
    WHERE cli.cli_id_logistics = @IdTransportadora
        AND cli.cli_cd_codigo_cliente <> 7
        AND fam.fam_dt_data BETWEEN @data_inicial AND @data_final
        AND fam.fam_ds_status NOT IN ('Reprovado');

    -- Insere novos registros de aprovação
    INSERT INTO tb_fat_aprovacao_motorista 
    (
        fam_cd_cliente, fam_dt_data, fam_ds_rota, fam_cd_usuario_motorista, fam_ds_entregas,
        fam_ds_km, fam_ds_valor, fam_ds_sucesso, fam_ds_insucesso, fam_ds_url_maps, fam_ds_status, 
        fam_cd_usuario_criacao, fam_dh_criacao, fam_cd_usuario_modificacao, fam_dh_modificacao, 
        fam_dh_aprovacao, fam_cd_usuario_aprovacao, fam_in_excluido, fam_ds_km_excedente
    )
    
    SELECT DISTINCT 
        cli.cli_cd_codigo_cliente,
        fin.Data,
        fin.IdRota,
        r.UsuarioDA usr_cd_usuario,
        r.TotalPacotes,
        ISNULL(aud.KmAprovacao, 0) AS fam_ds_km,
        0 AS CUSTO_TOTAL,
        r.PacotesEntregues,
        r.PacotesNaoEntregue,
        ISNULL(r.LinkMapa, '') AS LinkMapa,
        'Aprovado' ,
        4039,
        GETDATE(),
        4039,
        GETDATE(),
        NULL,
        NULL,
        0,
        CASE 
            WHEN cli.cli_cd_codigo_cliente = 45 AND ISNULL(aud.KmAprovacao, 0) > 100 THEN ISNULL(aud.KmAprovacao, 0) - 100 
            ELSE 0 
        END AS KmExcedente

    FROM tb_fin_pagamento_motorista fin WITH (NOLOCK)
    JOIN tb_clientes cli WITH (NOLOCK) ON fin.IdTransportadora = cli.cli_cd_codigo_cliente
    JOIN dbo.tb_ml_rotas r WITH (NOLOCK) 
        ON fin.IdRota = r.IdRota 
        AND fin.Data = r.DataReferencia 
        AND @IdTransportadora = r.IdTransportadora
        AND ISNULL(r.Excluido, 0) = 0
        AND r.StatusRota <> 'planned'
    LEFT JOIN #KmAuditoria aud 
        ON fin.IdRota = aud.IdRota 
        AND fin.Data = aud.DataReferencia
    LEFT JOIN tb_fat_aprovacao_motorista apr WITH (NOLOCK) 
        ON fin.IdRota = apr.fam_ds_rota 
        AND fin.Data = apr.fam_dt_data 
        AND cli.cli_cd_codigo_cliente = apr.fam_cd_cliente
    WHERE fin.IdTransportadora IN (
            SELECT cli_cd_codigo_cliente 
            FROM tb_clientes WITH (NOLOCK) 
            WHERE cli_id_logistics = @IdTransportadora AND cli_cd_codigo_cliente <> 7
        )
        AND fin.Data BETWEEN @data_inicial AND @data_final
        and r.UsuarioDA is not null;
END

 
INSERT INTO tb_fat_aprovacao_motorista 
    (
        fam_cd_cliente, fam_dt_data, fam_ds_rota, fam_cd_usuario_motorista, fam_ds_entregas,
        fam_ds_km, fam_ds_valor, fam_ds_sucesso, fam_ds_insucesso, fam_ds_url_maps, fam_ds_status, 
        fam_cd_usuario_criacao, fam_dh_criacao, fam_cd_usuario_modificacao, fam_dh_modificacao, 
        fam_dh_aprovacao, fam_cd_usuario_aprovacao, fam_in_excluido, fam_ds_km_excedente
    )

select 
        cli.cli_cd_codigo_cliente,
        r.DataReferencia Data,
        null as IdRota,
        UsuarioIrisys as usr_cd_usuario,
        r.TotalPacotes,
        isnull(r.DistanciaTotal,0) KmColetado,
        0 AS CUSTO_TOTAL,
        isnull(r.PacotesEntregues,0) PacotesEntregues,
        isnull(r.PacotesNaoEntregue,0) PacotesNaoEntregue ,
        ISNULL(r.LinkMapa, '') AS LinkMapa,
        'Aprovado' ,
        4039,
        GETDATE(),
        4039,
        GETDATE(),
        NULL,
        NULL,
        0,
        CASE 
            WHEN cli.cli_cd_codigo_cliente = 45 AND r.KmColetado > 100 THEN r.KmColetado - 100 
            ELSE 0 
        END AS KmExcedente

from tb_spe_rotas_v5 as r
inner join tb_clientes as cli
on r.IdTransportadora = cli.cli_id_shopee

where r.DataReferencia BETWEEN @data_inicial AND @data_final
and UsuarioIrisys is not null
and r.TotalPacotes is not null 
and r.excluido = 0

--select top 10 * 
--from tb_fin_pagamento_motorista
--where IdTransportadora = 20230022

--select * from tb_fin_pagamento_motorista
--where IdTransportadora = 20230022
GO
