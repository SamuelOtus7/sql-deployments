-- ============================================================
-- BASELINE: dbo.fn_faturamento_otus7_detalhe_2
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_faturamento_otus7_detalhe_2]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create FUNCTION [dbo].[fn_faturamento_otus7_detalhe_2]
(
    @Competencia    DATE,
    @Transportadora VARCHAR(150)
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        base.NomeMotorista,
        @Competencia AS Competencia,
        @Transportadora AS Cliente,
        COUNT(DISTINCT base.Data) AS Data,
        base.MarketPlace,
        MIN(base.Data) AS PrimeiraData,
        MAX(base.Data) AS UltimaData,
        DATEDIFF(
            DAY,
            MIN(base.Data),
            MAX(base.Data)
        ) + 1 AS Dias,
        CAST(1 AS DECIMAL(10,2)) AS Licencas,
        MIN(base.Base) AS Base
    FROM
    (
        /* ==========================================================
           MERCADO LIVRE — LAST MILE
           Mesmas regras da fn_faturamento_otus7
           ========================================================== */
        SELECT
            r.NomeMotorista,
            r.DataReferencia AS Data,
            CAST('Mercado Livre' AS VARCHAR(30)) AS MarketPlace,
            CAST(MAX(r.ServiceCenter) AS VARCHAR(200)) AS Base
        FROM tb_ml_rotas r WITH (NOLOCK)
        INNER JOIN tb_dra_transportadora t WITH (NOLOCK)
            ON r.IdTransportadora = t.tpr_cd_transportadora
        INNER JOIN
        (
            SELECT DISTINCT
                p.IdRota,
                p.IdTransportadora
            FROM tb_ml_pacotes p WITH (NOLOCK)
            WHERE
                p.Excluido = 0
                AND p.DataReferencia BETWEEN
                    @Competencia AND EOMONTH(@Competencia)
        ) p
            ON r.IdRota = p.IdRota
            AND r.IdTransportadora = p.IdTransportadora
        WHERE
            r.Excluido = 0
            AND r.DataReferencia BETWEEN
                @Competencia AND EOMONTH(@Competencia)
            AND r.NomeMotorista <> '-'
            AND r.NomeMotorista <> ''
            AND r.IdTransportadora <> 1726310024
            AND t.tpr_nome_transportadora = @Transportadora
            AND
            (
                r.StatusRota <> 'planned'

                OR
                (
                    r.SubStatusRota IN
                    (
                        'on_way_destination_facility',
                        'not_destination_facility'
                    )
                    AND t.tpr_nome_transportadora IN
                    (
                        'Attitude',
                        'Maxx log',
                        'Rodoprime',
                        'Decargo Express',
                        'ADO Transportadora'
                    )
                )

                OR
                (
                    r.SubStatusRota = 'not_destination_facility'
                    AND t.tpr_nome_transportadora = 'Transmana'
                )
            )
        GROUP BY
            r.NomeMotorista,
            r.DataReferencia

        UNION ALL

        /* ==========================================================
           MERCADO LIVRE — LINE HAUL
           ========================================================== */
        SELECT
            r.NomeMotorista,
            r.DataReferencia AS Data,
            CAST('Mercado Livre' AS VARCHAR(30)) AS MarketPlace,
            CAST(NULL AS VARCHAR(200)) AS Base
        FROM tb_ml_lh_rotas r WITH (NOLOCK)
        INNER JOIN tb_dra_transportadora t WITH (NOLOCK)
            ON r.IdTransportadora = t.tpr_cd_transportadora
        WHERE
            r.Excluido = 0
            AND r.DataReferencia BETWEEN
                @Competencia AND EOMONTH(@Competencia)
            AND r.NomeMotorista <> '-'
            AND r.NomeMotorista <> ''
            AND r.UsuarioDA IS NOT NULL
            AND r.IdTransportadora <> 1726310024
            AND t.tpr_nome_transportadora = @Transportadora
        GROUP BY
            r.NomeMotorista,
            r.DataReferencia

        UNION ALL

        /* ==========================================================
           MERCADO LIVRE — FIRST MILE
           ========================================================== */
        SELECT
            r.NomeMotorista,
            r.DataReferencia AS Data,
            CAST('Mercado Livre' AS VARCHAR(30)) AS MarketPlace,
            CAST(NULL AS VARCHAR(200)) AS Base
        FROM tb_ml_fm_rotas r WITH (NOLOCK)
        INNER JOIN tb_dra_transportadora t WITH (NOLOCK)
            ON r.IdTransportadora = t.tpr_cd_transportadora
        WHERE
            r.Excluido = 0
            AND r.DataReferencia BETWEEN
                @Competencia AND EOMONTH(@Competencia)
            AND r.NomeMotorista <> '-'
            AND r.NomeMotorista <> ''
            AND r.UsuarioDA IS NOT NULL
            AND r.IdTransportadora <> 1726310024
            AND t.tpr_nome_transportadora = @Transportadora
        GROUP BY
            r.NomeMotorista,
            r.DataReferencia

        UNION ALL

        /* ==========================================================
           SHOPEE — V5, FIRST MILE E LINE HAUL
           Mesmas regras da fn_faturamento_otus7
           ========================================================== */
        SELECT
            ISNULL(m.NomeMotorista, r.Motorista) AS NomeMotorista,
            r.DataReferencia AS Data,
            CAST('Shopee' AS VARCHAR(30)) AS MarketPlace,
            CAST(MAX(st.NomeStation) AS VARCHAR(200)) AS Base
        FROM tb_spe_rotas_v5 r WITH (NOLOCK)
        INNER JOIN tb_clientes c WITH (NOLOCK)
            ON r.IdTransportadora = c.cli_id_shopee
            AND c.cli_id_shopee > 0
        LEFT JOIN
        (
            SELECT DISTINCT
                p.CodigoRota,
                p.IdTransportadora,
                p.DataReferencia
            FROM tb_spe_pacotes_v5 p WITH (NOLOCK)
            WHERE
                p.Excluido = 0
                AND p.DataReferencia BETWEEN
                    @Competencia AND EOMONTH(@Competencia)
                AND p.StatusEntrega = 'delivered'
        ) p
            ON r.CodigoRota = p.CodigoRota
            AND r.IdTransportadora = p.IdTransportadora
            AND r.DataReferencia = p.DataReferencia
        LEFT JOIN
        (
            SELECT DISTINCT
                p.CodigoRota,
                p.IdTransportadora
            FROM tb_spe_pacotes_FM p WITH (NOLOCK)
            WHERE
                p.Excluido = 0
        ) f
            ON r.CodigoRota = CAST(f.CodigoRota AS VARCHAR(20))
            AND r.IdTransportadora = f.IdTransportadora
        LEFT JOIN
        (
            SELECT DISTINCT
                p.CodigoRota,
                p.IdTransportadora
            FROM tb_spe_pacotes_lh p WITH (NOLOCK)
        ) l
            ON r.CodigoRota = l.CodigoRota
            AND r.IdTransportadora = l.IdTransportadora
        LEFT JOIN tb_spe_motoristas m WITH (NOLOCK)
            ON r.IdMotorista = m.IdMotorista
        LEFT JOIN tb_spe_station st WITH (NOLOCK)
            ON r.IdStation = st.IdStation
        WHERE
            r.Excluido = 0
            AND r.DataReferencia BETWEEN
                @Competencia AND EOMONTH(@Competencia)
            AND ISNULL(m.NomeMotorista, r.Motorista) <> '-'
            AND ISNULL(m.NomeMotorista, r.Motorista) <> ''
            AND r.IdTransportadora <> 20230007
            AND c.cli_ds_nome = @Transportadora
            AND
            (
                p.CodigoRota IS NOT NULL
                OR f.CodigoRota IS NOT NULL
                OR l.CodigoRota IS NOT NULL
            )
        GROUP BY
            ISNULL(m.NomeMotorista, r.Motorista),
            r.DataReferencia
    ) base
    GROUP BY
        base.NomeMotorista,
        base.MarketPlace
);
GO
