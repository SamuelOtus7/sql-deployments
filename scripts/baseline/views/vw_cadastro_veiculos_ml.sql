-- ============================================================
-- BASELINE: dbo.vw_cadastro_veiculos_ml
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_cadastro_veiculos_ml]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_cadastro_veiculos_ml] as


SELECT 
    cadastro.vei_ds_placa AS Placa,
    cadastro.vei_ds_base AS Base,
    cadastro.vei_ds_tipo AS TipoTransportadora,
    COALESCE(Resultado.TipoVeiculo, ResultadoSPE.TipoVeiculo) AS TipoLogistics,
    COALESCE(Resultado.Rotas, 0) + COALESCE(ResultadoSPE.Rotas, 0) AS Rotas,
    COALESCE(Resultado.UltimaData, ResultadoSPE.UltimaData) AS UltimaData,
    COALESCE(Resultado.UltimoMotorista, ResultadoSPE.UltimoMotorista) AS UltimoMotorista,
    COALESCE(Resultado.UltimoServiceCenter, ResultadoSPE.UltimoServiceCenter) AS UltimoServiceCenter,
    cadastro.vei_cd_cliente AS TenantId
FROM tb_veiculos AS cadastro
left join tb_clientes cli 
on cadastro.vei_cd_cliente = cli.cli_cd_codigo_cliente
LEFT JOIN (
    SELECT 
        a.Placa,
        COUNT(DISTINCT IdRota) AS Rotas,
        MAX(DataReferencia) AS UltimaData,
        MAX(NomeMotorista) AS UltimoMotorista,
        MAX(TipoVeiculo) AS TipoVeiculo,
        MAX(a.ServiceCenter) AS UltimoServiceCenter,
		MAX(A.idtransportadora) AS Idtransportadora
    FROM vw_rotas a
    WHERE a.DataReferencia >= '2025-01-01'
    GROUP BY a.Placa
) AS Resultado
    ON cadastro.vei_ds_placa = Resultado.Placa
	and cli.cli_id_logistics = resultado.Idtransportadora
LEFT JOIN (
    SELECT 
        a.Placa,
        COUNT(DISTINCT CodigoRota) AS Rotas,
        MAX(DataReferencia) AS UltimaData,
        MAX(Motorista) AS UltimoMotorista,
        MAX(TipoVeiculo) AS TipoVeiculo,
        MAX(a.NomeHub) AS UltimoServiceCenter,
		MAX(A.idtransportadora) AS Idtransportadora
    FROM vw_rotas_spe_v4 a
    WHERE a.DataReferencia >= '2025-01-01'
    GROUP BY a.Placa
) AS ResultadoSPE
    ON cadastro.vei_ds_placa = ResultadoSPE.Placa
	and cli.cli_id_shopee = ResultadoSPE.Idtransportadora
WHERE 
    cadastro.vei_in_ativo = 1
    AND (
        COALESCE(Resultado.TipoVeiculo, '') <> '' 
        OR COALESCE(ResultadoSPE.TipoVeiculo, '') <> ''
    )


GO
