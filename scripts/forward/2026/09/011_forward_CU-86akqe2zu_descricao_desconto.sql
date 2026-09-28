/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqe2zu
  Autor        : Devin
  Data         : 2026-09-28
  Descrição    : Corrige a coluna Descricao da view dbo.vw_pgto_espelho_motorista.
                 Quando ppr_vl_desconto <> 0 e o desconto nao veio de lancamento
                 manual (PNR / Vehicle Daily Not Visited), a view rotulava tudo
                 como 'Lost: R$'. Agora distingue o motivo real:
                   - ppr_cd_desconto_ds = 1 -> 'Desconto DS' (regra
                     DESCONTO_DS_PROPORCIONAL da UspFinAplicaRegrasFinanceiro)
                   - ppr_cd_desconto_sd = 1 -> 'Not Visit' (regra NOT_VISIT)
                   - ppr_lcto_observacao com 'Vehicle Daily Not Visited' ->
                     'Vehicle Daily Not Visited' (desconto de prefatura)
                   - ppr_lcto_observacao com 'Lost' -> 'Lost' (prefatura)
                   - demais casos -> 'Desconto' (fallback generico)
                 O CASE e replicado no GROUP BY, conforme estrutura original.
  Rollback     : scripts/rollback/2026/09/011_rollback_CU-86akqe2zu_descricao_desconto.sql
  Objetos      : dbo.vw_pgto_espelho_motorista (ALTER VIEW)
  Dependências : dbo.tb_pgto_periodo_rota, dbo.vw_lancamentos_manuais_aprovados,
                 dbo.tb_lancamentos_manuais, dbo.tb_pag_espelhos,
                 dbo.UspFinAplicaRegrasFinanceiro (flags ppr_cd_desconto_ds/sd)
  ==============================================================================*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    --==========================================================================
    -- 1. PRE-CHECK
    --==========================================================================
    IF NOT EXISTS (
        SELECT 1 FROM sys.objects
        WHERE object_id = OBJECT_ID('dbo.vw_pgto_espelho_motorista')
          AND type = 'V'
    )
        THROW 50040, 'Pre-check falhou: view dbo.vw_pgto_espelho_motorista nao existe.', 1;

    --==========================================================================
    -- 2. SCRIPT PRINCIPAL
    --==========================================================================
    EXEC(N'
ALTER view  [dbo].[vw_pgto_espelho_motorista]

as
WITH CTE_Observacoes AS (
    SELECT 
        tlm_cd_rota, 
        tlm_cd_motorista,
        CAST(tlm_dh_referencia AS DATE) AS DataLancamento,
		STRING_AGG(CAST(tlm_ds_observacao AS VARCHAR(MAX)),CHAR(13) + CHAR(10) +CHAR(13) + CHAR(10) +CHAR(13) + CHAR(10) ) AS tlm_ds_observacao_concatenada
    FROM 
		vw_lancamentos_manuais_aprovados
	where
		--Acrescentado por Saulo Barros em 21/02/2026 para que caso seja a Parceiro Spot, só exibir concatenado se o lançamento for de alguma rota
		--Observação: Incluir apenas para Parceiro Spot a principio pois preciso entender o motivo dessa CTE. Para mim só faz sentido em caso de lançamentos que estiverem atrelado a alguma rota
		--			  pois todos os lançamentos daquela rota fica no mesmo registro na tb_pgto_periodo_rota
		(tlm_cd_cliente = 56 and (tlm_cd_rota is not null and tlm_cd_rota <> '''' and tlm_cd_rota <> ''null''))
		or
		tlm_cd_cliente <> 56
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
        WHEN ppr_vl_total < 0 THEN ''Desconto'' 
        ELSE ''Minuta'' 
    END AS Origem,

    CASE 
        WHEN pgp_cd_cliente = 27 THEN ppr_lcto_observacao
        ELSE 
            CASE
                WHEN a.ppr_cd_rota IS NOT NULL THEN
                    CASE
                        WHEN a.ppr_lcto_cd_lancamento IS NULL THEN 
                              ''Frete '' 
                            + ISNULL(a.ppr_ds_ciclo + '': R$ '', '''') 
                            + CAST(ISNULL(a.ppr_vl_base, 0) AS VARCHAR(50)) 
                            + CASE 
                                WHEN pgp_cd_cliente = 61 
                                THEN '' Ajudante: R$ '' 
                                ELSE '' Paradas: R$ '' 
                              END 
                            + CAST(ISNULL(a.ppr_vl_paradas, 0) AS VARCHAR(50))
                            + CASE 
                                WHEN a.ppr_vl_risco <> 0 
                                THEN '' Risco: R$ '' + CAST(a.ppr_vl_risco AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_ajudante <> 0 
                                THEN '' Ajudante: R$ '' + CAST(a.ppr_vl_ajudante AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_dom_fer <> 0 
                                THEN '' Domingo Feriado: R$ '' + CAST(a.ppr_vl_dom_fer AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_lancamentos <> 0 
                                THEN '' '' 
                                     + ISNULL(ISNULL(lam.tlm_ds_observacao_concatenada,a.ppr_lcto_observacao), ''Lanc. Manuais'') 
                                     + '': R$ '' 
                                     + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_bonus <> 0 
                                THEN '' Bônus: R$ '' + CAST(a.ppr_vl_bonus AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_pedagio <> 0 
                                THEN '' Pedágio: R$ '' + CAST(a.ppr_vl_pedagio AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_recarga <> 0 
                                THEN '' Recarga Elétrica: R$ '' + CAST(a.ppr_vl_recarga AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_desconto <> 0 THEN 
                                    CASE 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE ''%Pnr%'' 
                                            THEN '' PNR: R$ '' 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE ''%Vehicle Daily Not Visited%'' 
                                            THEN '' '' + lam.tlm_ds_observacao_concatenada + '': R$ '' 
                                        WHEN a.ppr_cd_desconto_ds = 1
                                            THEN '' Desconto DS: R$ ''
                                        WHEN a.ppr_cd_desconto_sd = 1
                                            THEN '' Not Visit: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Vehicle Daily Not Visited%''
                                            THEN '' Vehicle Daily Not Visited: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Lost%''
                                            THEN '' Lost: R$ ''
                                        ELSE '' Desconto: R$ '' 
                                    END 
                                    + CAST(a.ppr_vl_desconto AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                        ELSE 
                            ISNULL(ISNULL(lam.tlm_ds_observacao_concatenada,a.ppr_lcto_observacao), ''Lanc. Manuais'') 
                            + '': R$ '' 
                            + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                    END
                ELSE 
                    CASE 
                        WHEN lam.tlm_ds_observacao_concatenada = ''Lançamento - Aluguel'' THEN 
                            CASE 
                                WHEN a.ppr_vl_aluguel <> 0 
                                THEN ''Aluguel: R$ '' + CAST(a.ppr_vl_aluguel AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = ''Desconto Flex Frota'' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_flex_rota <> 0 
                                THEN ''Desconto Flex Frota: R$ '' + CAST(a.ppr_vl_desconto_flex_rota AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = ''Desconto Cartão Flex Frota'' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 
                                THEN ''Desconto Cartão Flex Frota: R$ '' + CAST(a.ppr_vl_desconto_cartao_flex_rota AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        ELSE 
							ISNULL(lam.tlm_ds_observacao_concatenada, ppr_lcto_observacao) 
                            + '': R$ '' 
                            + CAST(a.ppr_vl_total AS VARCHAR(50))
                    END
            END
    END AS Descricao,

    ppr_ds_tipo_veiculo AS veiculo,   
    SUM(ppr_vl_total) AS Valor,
    cli_ds_nome AS NomeTrasportadora,
    CONVERT(VARCHAR(10), ppr_dh_criacao, 103) 
        + '' '' 
        + CONVERT(VARCHAR(8), CONVERT(TIME(0), ppr_dh_criacao)) AS DataGeracao,
    ppr_dh_criacao,
    cli_ds_cnpj AS CNPJTransportadora,
    usr_matricula AS Matricula,
    e.mot_cpf AS CPFMotorista,
    CONVERT(VARCHAR(10), periodo.pgp_dt_inicio, 103) AS InicioPeriodo,
    CONVERT(VARCHAR(10), periodo.pgp_dt_fim, 103) AS FimPeriodo,

    CASE
         WHEN a.ppr_cd_tipo = ''FM'' THEN ''Fisrt Mile''
         WHEN a.ppr_cd_tipo = ''LM'' THEN ''Last Mile''
         WHEN a.ppr_cd_tipo = ''MO'' THEN ''Meli One''
         WHEN a.ppr_cd_tipo = ''LH'' THEN ''Line Haul''  
         ELSE ''''
    END AS Operacao,

    CASE
        WHEN e.mot_pag_cd_tipo_pagamento = 1 THEN ''Nota Fiscal''
        WHEN e.mot_pag_cd_tipo_pagamento = 2 THEN ''CIOT''
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
      AND apr.alm_ds_status = ''Aprovado'' 
      AND lan.tlm_cd_rota <> ''null''
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
 GROUP BY
    ppr_cd_pgto_espelho,
    CONVERT(VARCHAR(10), ppr_data_referencia, 103),
    ppr_cd_rota,
    usr_nm_usuario,
    ppr_base_principal,
    ppr_ds_placa,
    CASE 
        WHEN ppr_vl_total < 0 THEN ''Desconto'' 
        ELSE ''Minuta'' 
    END,
    CASE 
        WHEN pgp_cd_cliente = 27 THEN ppr_lcto_observacao
        ELSE 
            CASE
                WHEN a.ppr_cd_rota IS NOT NULL THEN
                    CASE
                        WHEN a.ppr_lcto_cd_lancamento IS NULL THEN 
                              ''Frete '' 
                            + ISNULL(a.ppr_ds_ciclo + '': R$ '', '''') 
                            + CAST(ISNULL(a.ppr_vl_base, 0) AS VARCHAR(50)) 
                            + CASE 
                                WHEN pgp_cd_cliente = 61 
                                THEN '' Ajudante: R$ '' 
                                ELSE '' Paradas: R$ '' 
                              END 
                            + CAST(ISNULL(a.ppr_vl_paradas, 0) AS VARCHAR(50))
                            + CASE 
                                WHEN a.ppr_vl_risco <> 0 
                                THEN '' Risco: R$ '' + CAST(a.ppr_vl_risco AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_ajudante <> 0 
                                THEN '' Ajudante: R$ '' + CAST(a.ppr_vl_ajudante AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_dom_fer <> 0 
                                THEN '' Domingo Feriado: R$ '' + CAST(a.ppr_vl_dom_fer AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_lancamentos <> 0 
                                THEN '' '' 
                                     + ISNULL(ISNULL(lam.tlm_ds_observacao_concatenada,a.ppr_lcto_observacao), ''Lanc. Manuais'') 
                                     + '': R$ '' 
                                     + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_bonus <> 0 
                                THEN '' Bônus: R$ '' + CAST(a.ppr_vl_bonus AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_pedagio <> 0 
                                THEN '' Pedágio: R$ '' + CAST(a.ppr_vl_pedagio AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_recarga <> 0 
                                THEN '' Recarga Elétrica: R$ '' + CAST(a.ppr_vl_recarga AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                            + CASE 
                                WHEN a.ppr_vl_desconto <> 0 THEN 
                                    CASE 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE ''%Pnr%'' 
                                            THEN '' PNR: R$ '' 
                                        WHEN lam.tlm_ds_observacao_concatenada LIKE ''%Vehicle Daily Not Visited%'' 
                                            THEN '' '' + lam.tlm_ds_observacao_concatenada + '': R$ '' 
                                        WHEN a.ppr_cd_desconto_ds = 1
                                            THEN '' Desconto DS: R$ ''
                                        WHEN a.ppr_cd_desconto_sd = 1
                                            THEN '' Not Visit: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Vehicle Daily Not Visited%''
                                            THEN '' Vehicle Daily Not Visited: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Lost%''
                                            THEN '' Lost: R$ ''
                                        ELSE '' Desconto: R$ '' 
                                    END 
                                    + CAST(a.ppr_vl_desconto AS VARCHAR(50)) 
                                ELSE '''' 
                              END
                        ELSE 
                            ISNULL(ISNULL(lam.tlm_ds_observacao_concatenada,a.ppr_lcto_observacao), ''Lanc. Manuais'') 
                            + '': R$ '' 
                            + CAST(a.ppr_vl_lancamentos AS VARCHAR(50)) 
                    END
                ELSE 
                    CASE 
                        WHEN lam.tlm_ds_observacao_concatenada = ''Lançamento - Aluguel'' THEN 
                            CASE 
                                WHEN a.ppr_vl_aluguel <> 0 
                                THEN ''Aluguel: R$ '' + CAST(a.ppr_vl_aluguel AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = ''Desconto Flex Frota'' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_flex_rota <> 0 
                                THEN ''Desconto Flex Frota: R$ '' + CAST(a.ppr_vl_desconto_flex_rota AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        WHEN lam.tlm_ds_observacao_concatenada = ''Desconto Cartão Flex Frota'' THEN 
                            CASE 
                                WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 
                                THEN ''Desconto Cartão Flex Frota: R$ '' + CAST(a.ppr_vl_desconto_cartao_flex_rota AS VARCHAR(50)) 
                                ELSE '''' 
                            END
                        ELSE 
							ISNULL(lam.tlm_ds_observacao_concatenada, ppr_lcto_observacao) 
                            + '': R$ '' 
                            + CAST(a.ppr_vl_total AS VARCHAR(50))
                    END
            END
    END,

    ppr_ds_tipo_veiculo,
    cli_ds_nome,
    CONVERT(VARCHAR(10), ppr_dh_criacao, 103) 
        + '' '' 
        + CONVERT(VARCHAR(8), CONVERT(TIME(0), ppr_dh_criacao)),
    ppr_dh_criacao,
    cli_ds_cnpj,
    usr_matricula,
    e.mot_cpf,
    CONVERT(VARCHAR(10), periodo.pgp_dt_inicio, 103),
    CONVERT(VARCHAR(10), periodo.pgp_dt_fim, 103),

    CASE
         WHEN a.ppr_cd_tipo = ''FM'' THEN ''Fisrt Mile''
         WHEN a.ppr_cd_tipo = ''LM'' THEN ''Last Mile''
         WHEN a.ppr_cd_tipo = ''MO'' THEN ''Meli One''
         WHEN a.ppr_cd_tipo = ''LH'' THEN ''Line Haul''  
         ELSE ''''
    END,

    CASE
        WHEN e.mot_pag_cd_tipo_pagamento = 1 THEN ''Nota Fiscal''
        WHEN e.mot_pag_cd_tipo_pagamento = 2 THEN ''CIOT''
        ELSE NULL
    END,

    LM.ValorAdiantado
');

    --==========================================================================
    -- 3. POS-CHECK
    --==========================================================================
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_pgto_espelho_motorista')) NOT LIKE '%Desconto DS: R$%'
        THROW 50041, 'Pos-check falhou: definicao da view nao contem o novo label Desconto DS.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
