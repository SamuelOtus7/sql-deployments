-- ============================================================
-- BASELINE: dbo.fn_obter_resultado_financeiro
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_obter_resultado_financeiro]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_obter_resultado_financeiro](
    @IdTransportadora INT,
    @Mes INT,
    @Quinzena INT,
    @DataInicio DATE,
    @DataFim DATE
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        Resultado,
        COUNT(*) AS Qtde
    FROM (
        SELECT 
            a.IdRota AS Rota,
            CASE 
                WHEN TotalPrefatura = 0 THEN 'Valor zerado na Prefatura'
                WHEN ReceitaTotal = TotalPrefatura THEN 'Valores iguais'
                WHEN b.bft_cd_service_center IS NULL THEN 'Sem base frete cadastrada'
                WHEN a.ServiceCenter <> serviceCenterPrefatura THEN 'Service Center diferente'
                WHEN a.TipoVeiculo <> TipoVeiculoPreFatura THEN 'Tipo de veiculo diferente'
                WHEN a.CicloPM <> CicloPMFatura THEN 'Ciclo diferente'
                WHEN ISNULL(FaixaPreFatura, 0) <> ISNULL(FaixaKm, -1) THEN 'Faixa de KM diferente'
                ELSE 'Não mapeados'
            END AS Resultado
        FROM vw_resultado_financeiro AS a
        LEFT JOIN (
            SELECT 
                bft_cd_service_center,
                tvl_nm_tipo_veiculo,
                bft_cd_transportadora
            FROM tb_fin_base_frete_transportadora AS a
            INNER JOIN tb_dra_tipo_veiculo AS b
                ON a.bft_cd_tipo_veiculo = b.tvl_cd_tipo_veiculo
            WHERE bft_vl_frete > 0
            GROUP BY 
                bft_cd_service_center,
                tvl_nm_tipo_veiculo,
                bft_cd_transportadora
        ) AS b
            ON a.servicecenter = b.bft_cd_service_center
            AND a.tipoveiculo = b.tvl_nm_tipo_veiculo
            AND a.idtransportadora = b.bft_cd_transportadora
        WHERE a.idtransportadora = @IdTransportadora
            AND a.mes = @Mes
            AND a.quinzena = @Quinzena
            AND a.datareferencia BETWEEN @DataInicio AND @DataFim
    ) AS base  
    GROUP BY ROLLUP(Resultado)

);
GO
