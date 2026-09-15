-- ============================================================
-- BASELINE: dbo.vw_pgto_espelho_motorista_parceiro
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_pgto_espelho_motorista_parceiro]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view  [dbo].[vw_pgto_espelho_motorista_parceiro]

as

WITH CTE_Observacoes AS (
    SELECT 
        tlm_cd_rota, 
        tlm_cd_motorista,
        CAST(tlm_dh_referencia AS DATE) AS DataLancamento,
        STRING_AGG(
            CAST(tlm_ds_observacao AS VARCHAR(MAX)), 
            '  |||  Próximo : '
        ) AS tlm_ds_observacao_concatenada
    FROM vw_lancamentos_manuais_aprovados
    GROUP BY 
        tlm_cd_rota, 
        tlm_cd_motorista,
        CAST(tlm_dh_referencia AS DATE)
)

SELECT  
    ppr_cd_pgto_espelho,
    CONVERT(VARCHAR(10), ppr_data_referencia, 103) AS Data,
    ppr_cd_rota AS Rota,
    usr_nm_usuario AS NomeMotorista,
    ppr_base_principal AS Base,
    ppr_ds_placa AS Placa,
    CASE 
        WHEN ppr_vl_total < 0 THEN 'Desconto' 
        ELSE 'Minuta' 
    END AS Origem,

    CASE 
        WHEN pgp_cd_cliente = 27 THEN ppr_lcto_observacao
        ELSE 
            CASE
                WHEN a.ppr_cd_rota IS NOT NULL THEN
                    CASE
                        WHEN a.ppr_lcto_cd_lancamento IS NULL THEN 
                              'Frete ' 
                            + ISNULL(a.ppr_ds_ciclo + ': R$ ', '') 
                            + CAST(ISNULL(a.ppr_vl_base, 0) AS VARCHAR(50)) 
                            + CASE 
                                WHEN pgp_cd_cliente = 61 
                                THEN ' Ajudante: R$ ' 
                                ELSE ' Paradas: R$ ' 
                              END 
                            + CAST(ISNULL(a.ppr_vl_paradas, 0) AS VARCHAR(50))
                            + CASE 
                                WHEN a.ppr_vl_risco <> 0 
                                THEN ' Risco: R$ ' + CAST(a.ppr_vl_risco AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_ajudante <> 0 
                                THEN ' Ajudante: R$ ' + CAST(a.ppr_vl_ajudante AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_dom_fer <> 0 
                                THEN ' Domingo Feriado: R$ ' + CAST(a.ppr_vl_dom_fer AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_lancamentos <> 0 
                                THEN ' ' 
                                     + ISNULL(lam.tlm_ds_observacao_concatenada, 'Lanc. Manuais') 
                                     + ': R$ ' 
                                     + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_bonus <> 0 
                                THEN ' Bônus: R$ ' + CAST(a.ppr_vl_bonus AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_pedagio <> 0 
                                THEN ' Pedágio: R$ ' + CAST(a.ppr_vl_pedagio AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_recarga <> 0 
                                THEN ' Recarga Elétrica: R$ ' + CAST(a.ppr_vl_recarga AS VARCHAR(50)) 
                                ELSE '' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_desconto <> 0 THEN 
                                    CASE 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE '%Pnr%' 
                                            THEN ' PNR: R$ ' 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE '%Vehicle Daily Not Visited%' 
                                            THEN ' ' + lam.tlm_ds_observacao_concatenada + ': R$ ' 
                                        ELSE ' Lost: R$ ' 
                                    END 
                                    + CAST(a.ppr_vl_desconto AS VARCHAR(50)) 
                                ELSE '' 
                              END
                        ELSE 
                            ISNULL(lam.tlm_ds_observacao_concatenada, 'Lanc. Manuais') 
                            + ': R$ ' 
                            + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                    END
                ELSE 
                    CASE 
                        WHEN lam.tlm_ds_observacao_concatenada = 'Lançamento - Aluguel' THEN 
                            CASE 
                                WHEN a.ppr_vl_aluguel <> 0 
                                THEN 'Aluguel: R$ ' + CAST(a.ppr_vl_aluguel AS VARCHAR(50)) 
                                ELSE '' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = 'Desconto Flex Frota' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_flex_rota <> 0 
                                THEN 'Desconto Flex Frota: R$ ' + CAST(a.ppr_vl_desconto_flex_rota AS VARCHAR(50)) 
                                ELSE '' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = 'Desconto Cartão Flex Frota' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 
                                THEN 'Desconto Cartão Flex Frota: R$ ' + CAST(a.ppr_vl_desconto_cartao_flex_rota AS VARCHAR(50)) 
                                ELSE '' 
                            END
                        ELSE 
                            ISNULL(lam.tlm_ds_observacao_concatenada, 'Avulso') 
                            + ': R$ ' 
                            + CAST(a.ppr_vl_total AS VARCHAR(50))
                    END
            END
    END AS Descricao,

    ppr_ds_tipo_veiculo AS veiculo,   
    ppr_vl_total AS Valor,
    cli_ds_nome AS NomeTrasportadora,
    CONVERT(VARCHAR(10), ppr_dh_criacao, 103) 
        + ' ' 
        + CONVERT(VARCHAR(8), CONVERT(TIME(0), ppr_dh_criacao)) AS DataGeracao,
    ppr_dh_criacao,
    cli_ds_cnpj AS CNPJTransportadora,
    usr_matricula AS Matricula,
    e.mot_cpf AS CPFMotorista,
    CONVERT(VARCHAR(10), periodo.pgp_dt_inicio, 103) AS InicioPeriodo,
    CONVERT(VARCHAR(10), periodo.pgp_dt_fim, 103) AS FimPeriodo,

    CASE
         WHEN a.ppr_cd_tipo = 'FM' THEN 'Fisrt Mile'
         WHEN a.ppr_cd_tipo = 'LM' THEN 'Last Mile'
         WHEN a.ppr_cd_tipo = 'MO' THEN 'Meli One'
         WHEN a.ppr_cd_tipo = 'LH' THEN 'Line Haul'  
         ELSE ''
    END AS Operacao,

    CASE
        WHEN e.mot_pag_cd_tipo_pagamento = 1 THEN 'Nota Fiscal'
        WHEN e.mot_pag_cd_tipo_pagamento = 2 THEN 'CIOT'
        ELSE NULL
    END AS Tipo_Pagamento,

    LM.ValorAdiantado

FROM tb_pgto_periodo_rota a
LEFT JOIN tb_pgto_periodo periodo 
       ON a.ppr_cd_periodo = periodo.pgp_cd_periodo
INNER JOIN tb_pag_espelhos espelho 
        ON espelho.mtn_cd_motorista_nfs = a.ppr_cd_pgto_espelho
LEFT JOIN tb_clientes c 
       ON espelho.mtn_cod_cliente = c.cli_cd_codigo_cliente 
LEFT JOIN tb_usuario d 
       ON a.ppr_cd_motorista = d.usr_cd_usuario 
      AND d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente
LEFT JOIN tb_motorista e 
       ON a.ppr_cd_motorista = e.mot_cd_usuario 

LEFT JOIN ( 
    SELECT
        lan.tlm_cd_rota AS Rota,
        SUM(lan.tlm_vl_valor_descontos) AS ValorAdiantado
    FROM tb_lancamentos_manuais lan WITH (NOLOCK)
    JOIN tb_aprovacao_lancamento_manual apr WITH (NOLOCK) 
         ON apr.alm_cd_lancamento_manual = lan.tlm_cd_lancamento_manual
    WHERE lan.tlm_cd_cliente = 11 
      AND lan.tlm_cd_tipo = 233 
      AND apr.alm_ds_status = 'Aprovado' 
      AND lan.tlm_cd_rota <> 'null'
    GROUP BY lan.tlm_cd_rota
) LM 
    ON LM.Rota = a.ppr_cd_rota

LEFT JOIN CTE_Observacoes lam 
    ON (
            lam.tlm_cd_rota = a.ppr_cd_rota
         OR (lam.tlm_cd_rota IS NULL AND a.ppr_cd_rota IS NULL)
       )
   AND lam.tlm_cd_motorista = a.ppr_nome_motorista
   AND lam.DataLancamento = CAST(a.ppr_data_referencia AS DATE)

WHERE a.ppr_in_excluido = 0
  AND (e.mot_cd_cliente = periodo.pgp_cd_cliente OR periodo.pgp_cd_cliente = 7)
--  AND espelho.mtn_cd_motorista_nfs = 863367;
GO
