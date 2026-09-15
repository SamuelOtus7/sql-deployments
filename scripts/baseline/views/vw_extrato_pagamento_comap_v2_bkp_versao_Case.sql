-- ============================================================
-- BASELINE: dbo.vw_extrato_pagamento_comap_v2_bkp_versao_Case
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_extrato_pagamento_comap_v2_bkp_versao_Case]    Script Date: 14/09/2026 12:12:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_extrato_pagamento_comap_v2_bkp_versao_Case] as
SELECT 
    ppr_cd_pgto_espelho,
    mtn_cd_pgto_periodo,
    placa,
    Base,
    Motorista,
    Responsavel,
    SUM(TotalReceber) AS TotalReceber,
    SUM(TotalDiariaLiqPre) AS TotalDiariaLiqPre,
    SUM(ValorAvulso) AS ValorAvulso,
    SUM(Parada) AS Parada,
    SUM(risco) AS risco,
    SUM(ppr_vl_ajudante) AS ppr_vl_ajudante,
    SUM(ppr_vl_dom_fer) AS ppr_vl_dom_fer,
    SUM(QtdRotas) AS QtdRotas,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'Pedágio' THEN valor ELSE 0 END), 0) AS Pedagio,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'PF - Pacote Perdido' THEN valor ELSE 0 END), 0) AS PacotePerdido,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'PF - Endereço não visitado' THEN valor ELSE 0 END), 0) AS EnderecaoNaoVisitado,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'PF - PNR' THEN valor ELSE 0 END), 0) AS PNR,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'Ambulância' THEN valor ELSE 0 END), 0) AS Ambulancia,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'Backup' THEN valor ELSE 0 END), 0) AS [Backup],
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'Abastecimento' THEN valor ELSE 0 END), 0) AS Abastecimento,
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'Incentivo' THEN valor ELSE 0 END), 0) AS [Incentivo],
    ISNULL(SUM(CASE WHEN plm_nm_tipo = 'km adicional' THEN valor ELSE 0 END), 0) AS [km adicional]

FROM (
    SELECT  
        t.plm_nm_tipo,
        ppr_cd_pgto_espelho,
        ppr_ds_placa AS placa,
        mtn_cd_pgto_periodo,
        mtn_base_principal AS Base,
        mtn_nome_motorista AS Motorista,
        cadResp.usr_nm_usuario AS Responsavel,
        SUM(ppr_vl_total) AS TotalReceber, 
        SUM(CASE WHEN ppr_cd_rota IS NOT NULL THEN ppr_vl_base ELSE 0 END) AS TotalDiariaLiqPre,
        SUM(CASE WHEN ppr_lcto_cd_lancamento IS NULL AND ppr_cd_rota IS NULL THEN ppr_vl_base ELSE 0 END) AS ValorAvulso,
        SUM(ppr_vl_paradas) AS Parada,
        SUM(ppr_vl_risco) AS risco,
        SUM(ppr_vl_ajudante) AS ppr_vl_ajudante,
        SUM(ppr_vl_dom_fer) AS ppr_vl_dom_fer,
        SUM(ppr_cd_tipo_pgto) AS QtdRotas,
        SUM(
            CASE 
                WHEN ISNULL(lanc.tlm_cd_tipo, lancr.tlm_cd_tipo) = 489 
                    THEN ISNULL(ppr_vl_base, 0) * -1 
                ELSE COALESCE(lanc.tlm_vl_valor_descontos, lancr.tlm_vl_valor_descontos, 0) 
            END
        ) + SUM(COALESCE(lanc.tlm_vl_valor_adicional, lancr.tlm_vl_valor_adicional, 0)) AS valor

    FROM tb_pgto_periodo_rota AS a
    JOIN tb_pgto_periodo per ON ppr_cd_periodo = pgp_cd_periodo  
    INNER JOIN tb_pag_espelhos AS pag ON ppr_cd_pgto_espelho = pag.mtn_cd_motorista_nfs
    LEFT JOIN tb_pgto_rotas_lanc_manuais AS cod ON a.ppr_lcto_cd_lancamento = plm_cd_lancamentos
    LEFT JOIN tb_lancamentos_manuais AS lanc ON lanc.tlm_cd_lancamento_manual = cod.plm_cd_lancamento
    LEFT JOIN (
        SELECT  
            tlm_cd_rota,
            tlm_cd_tipo,
            SUM(tlm_vl_valor_adicional) AS tlm_vl_valor_adicional,
            SUM(tlm_vl_valor_descontos) * -1 AS tlm_vl_valor_descontos
        FROM vw_lancamentos_manuais_aprovados
        GROUP BY tlm_cd_rota, tlm_cd_tipo
    ) AS lancr ON lancr.tlm_cd_rota = ppr_cd_rota
    LEFT JOIN tb_tipos_lancamentos_manuais AS t ON ISNULL(lanc.tlm_cd_tipo, lancr.tlm_cd_tipo) = t.plm_cd_tipo_lancamento_manual  
    LEFT JOIN tb_usuario AS cad ON pag.mtn_cd_motorista = cad.usr_cd_usuario 
    LEFT JOIN tb_usuario AS cadResp ON cad.usr_cd_usr_responsavel_contrato = cadResp.usr_cd_usuario 

    WHERE ppr_in_excluido = 0
     -- AND ppr_cd_periodo = 2119
     -- AND ppr_cd_motorista_nfs = 863770

    GROUP BY 
        t.plm_nm_tipo,
        ppr_cd_pgto_espelho,
        ppr_ds_placa,
        mtn_cd_pgto_periodo,
        mtn_base_principal,
        mtn_nome_motorista,
        cadResp.usr_nm_usuario
) AS src
GROUP BY 
    ppr_cd_pgto_espelho,
    mtn_cd_pgto_periodo,
    placa,
    Base,
    Motorista,
    Responsavel;
GO
