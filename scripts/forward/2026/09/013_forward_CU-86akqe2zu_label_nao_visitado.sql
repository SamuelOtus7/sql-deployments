/*==============================================================================
  FORWARD MIGRATION SCRIPT
  ==============================================================================
  Task ClickUp : CU-86akqe2zu
  Autor        : Devin
  Data         : 2026-09-28
  Descricao    : Renomeia o rotulo 'Desconto DS' para 'Não Visitado' nas views
                 dbo.vw_pgto_espelho_motorista e dbo.vw_pgto_espelho_motorista_novo.
                 Apenas texto do CASE de desconto (flag ppr_cd_desconto_ds = 1);
                 nenhuma outra regra alterada.
  Rollback     : scripts/rollback/2026/09/013_rollback_CU-86akqe2zu_label_nao_visitado.sql
  Objetos      : dbo.vw_pgto_espelho_motorista (ALTER VIEW)
                 dbo.vw_pgto_espelho_motorista_novo (ALTER VIEW)
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
    IF NOT EXISTS (
        SELECT 1 FROM sys.objects
        WHERE object_id = OBJECT_ID('dbo.vw_pgto_espelho_motorista_novo')
          AND type = 'V'
    )
        THROW 50040, 'Pre-check falhou: view dbo.vw_pgto_espelho_motorista_novo nao existe.', 1;

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
                                            THEN '' Não Visitado: R$ ''
                                        WHEN a.ppr_cd_desconto_sd = 1
                                            THEN '' Not Visit: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Vehicle Daily Not Visited%''
                                            THEN '' Vehicle Daily Not Visited: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Pnr%''
                                            THEN '' PNR: R$ ''
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
                                            THEN '' Não Visitado: R$ ''
                                        WHEN a.ppr_cd_desconto_sd = 1
                                            THEN '' Not Visit: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Vehicle Daily Not Visited%''
                                            THEN '' Vehicle Daily Not Visited: R$ ''
                                        WHEN a.ppr_lcto_observacao LIKE ''%Pnr%''
                                            THEN '' PNR: R$ ''
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

    EXEC(N'

ALTER view  [dbo].[vw_pgto_espelho_motorista_novo] AS 
	
	select  
		ppr_cd_pgto_espelho
		,convert(varchar(10),ppr_data_referencia,103) as Data	
		,ppr_cd_rota			as Rota
		,usr_nm_usuario			as NomeMotorista
		,ppr_base_principal			as Base
		,ppr_ds_placa			as Placa
		,case when ppr_vl_total < 0 then ''Desconto'' else ''Minuta'' end as Origem

		-- /*texto para fcargo*/
		-- ,case 
		-- 	when ppr_lcto_observacao is not null then ppr_lcto_observacao
		-- 	when ppr_vl_total < 0 then ppr_lcto_observacao 
		-- 	else ''Ref.: Rota de número '' + ppr_cd_rota +  '' realizada com veículo '' + b.tipoveiculo + ''.'' end  as Descricao

		,case 
				when pgp_cd_cliente = 27
					then ppr_lcto_observacao
				else 
		CASE
			WHEN a.ppr_cd_rota IS NOT NULL
				THEN
					CASE
						WHEN a.ppr_lcto_cd_lancamento IS NULL
							THEN ''Frete '' + CASE WHEN a.ppr_ds_ciclo IS NULL THEN '''' ELSE a.ppr_ds_ciclo + '': R$ '' END + format(ISNULL(a.ppr_vl_base,0), ''N2'', ''pt-BR'') 
								-- + '' Paradas: R$ '' + cast(ISNULL(a.ppr_vl_paradas,0) as varchar(50))
								+ CASE WHEN pgp_cd_cliente = 61 THEN '' Ajudante: R$ '' 
									ELSE '' Paradas: R$ '' 
									END + format(ISNULL(a.ppr_vl_paradas,0), ''N2'', ''pt-BR'') 
								+ CASE WHEN a.ppr_vl_risco <> 0 THEN '' Risco: R$ '' + format(ISNULL(a.ppr_vl_risco,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_ajudante <> 0 THEN '' Ajudante: R$ '' + format(ISNULL(a.ppr_vl_ajudante,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_dom_fer <> 0 THEN '' Domingo Feriado: R$ '' + format(ISNULL(a.ppr_vl_dom_fer,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_lancamentos <> 0 THEN '' '' + CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '''' THEN ''Lanc. Manuais'' ELSE a.ppr_lcto_observacao END + '': R$ '' + format(ISNULL(a.ppr_vl_lancamentos,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_bonus <> 0 THEN '' Bônus: R$ '' + format(ISNULL(a.ppr_vl_bonus,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_pedagio <> 0 THEN '' Pedágio: R$ '' + format(ISNULL(a.ppr_vl_pedagio,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_recarga <> 0 THEN '' Recarga Elétrica: R$ '' + format(ISNULL(a.ppr_vl_recarga,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_desconto <> 0 THEN CASE WHEN a.ppr_lcto_observacao LIKE ''%Pnr%'' THEN '' PNR: R$ '' WHEN a.ppr_lcto_observacao LIKE ''%Vehicle Daily Not Visited%'' THEN '' Not Visited: R$ '' WHEN a.ppr_cd_desconto_ds = 1 THEN '' Não Visitado: R$ '' WHEN a.ppr_cd_desconto_sd = 1 THEN '' Not Visit: R$ '' WHEN a.ppr_lcto_observacao LIKE ''%Lost%'' THEN '' Lost: R$ '' ELSE '' Desconto: R$ '' end + format(ISNULL(a.ppr_vl_desconto,0), ''N2'', ''pt-BR'') ELSE '''' END
								+ CASE WHEN a.ppr_vl_adicional_km <> 0 then '' Adicional KM: R$ '' + format(ISNULL(a.ppr_vl_adicional_km,0), ''N2'', ''pt-BR'') ELSE '''' END
						ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '''' THEN ''Lanc. Manuais'' + case when par4.prm_cd_parametro is null then '''' else '' - '' + t.plm_nm_tipo end  ELSE a.ppr_lcto_observacao END + '': R$ '' + format(ISNULL(a.ppr_vl_lancamentos,0), ''N2'', ''pt-BR'')
					END
			ELSE 
				CASE 
					WHEN a.ppr_lcto_observacao = ''Lançamento - Aluguel''
						THEN CASE WHEN a.ppr_vl_aluguel <> 0 THEN ''Aluguel: R$ '' + format(ISNULL(a.ppr_vl_aluguel,0), ''N2'', ''pt-BR'') ELSE '''' END
					WHEN a.ppr_lcto_observacao = ''Desconto Flex Frota''
						THEN CASE WHEN a.ppr_vl_desconto_flex_rota <> 0 THEN ''Desconto Flex Frota: R$ '' + format(ISNULL(a.ppr_vl_desconto_flex_rota,0), ''N2'', ''pt-BR'') ELSE '''' END
					WHEN a.ppr_lcto_observacao = ''Desconto Cartão Flex Frota''
						THEN CASE WHEN a.ppr_vl_desconto_cartao_flex_rota <> 0 THEN ''Desconto Cartão Flex Frota: R$ '' + format(ISNULL(a.ppr_vl_desconto_cartao_flex_rota,0), ''N2'', ''pt-BR'')  ELSE '''' END
					ELSE CASE WHEN a.ppr_lcto_observacao IS NULL OR a.ppr_lcto_observacao = '''' THEN ''Avulso'' ELSE a.ppr_lcto_observacao END + '': R$ '' + format(ISNULL(a.ppr_vl_total,0), ''N2'', ''pt-BR'')
				END
--		end
		END  end as Descricao

		,ppr_ds_tipo_veiculo as veiculo	 
		--,isnull((-1*ppr_vl_lancamentos),0) + ppr_vl_total 			as Valor
		,ppr_vl_total 			as Valor
		,cli_ds_nome			as NomeTrasportadora
		,convert(varchar(10),ppr_dh_criacao,103) + '' '' + convert(varchar(8),convert(time(0),ppr_dh_criacao)) as DataGeracao
		,ppr_dh_criacao
		,cli_ds_cnpj			as CNPJTransportadora
		--,usr_matricula			as Matricula
		,e.mot_cd_matricula as Matricula
		,e.mot_cpf as CPFMotorista
		,convert(varchar(10),periodo.pgp_dt_inicio,103) as InicioPeriodo
		,convert(varchar(10),periodo.pgp_dt_fim,103) as FimPeriodo
		,CASE
			 WHEN a.ppr_cd_tipo = ''FM''
				 THEN ''First Mile''
			 WHEN a.ppr_cd_tipo = ''LM''
				 THEN ''Last Mile''
			 WHEN a.ppr_cd_tipo = ''MO''
				 THEN ''Meli One''
			WHEN a.ppr_cd_tipo = ''LH''  
				THEN ''Line Hall''  
			 ELSE ''''
		 END					AS Operacao,
		 CASE
			WHEN e.mot_pag_cd_tipo_pagamento = 1
				THEN ''Nota Fiscal''
			WHEN e.mot_pag_cd_tipo_pagamento = 2
				THEN ''CIOT''
			ELSE NULL
		END						AS Tipo_Pagamento
	
	,isnull(m.Agencia,''-'') As Agencia
	,isnull(m.Conta,''-'') As Conta
	,isnull(m.TipoConta,''-'') as Tipo_Conta
	,isnull(m.Banco,''-'') as Banco
	,isnull(m.TipoChavePix,''-'') TipoChavePix
	,isnull(m.ChavePix,''-'') ChavePix
	,isnull(m.NomeTitular,''-'') NomeTitular
	,case len (coalesce(m.CpfTitular,m.CnpjTitular,''-''))
		when 11 then format(cast(coalesce(m.CpfTitular,m.CnpjTitular,''-'') as bigint), ''000\.000\.000\-00'') --cpf
		when 14 then format(cast(coalesce(m.CpfTitular,m.CnpjTitular,''-'') as bigint), ''00\.000\.000\/0000\-00'') --cnpj
	else
		coalesce(m.CpfTitular,m.CnpjTitular,''-'')
	end CpfTitular
	,case len (coalesce(m.CpfTitular,m.CnpjTitular,''-''))
		when 11 then ''CPF Titular''
		when 14 then ''CNPJ Titular''
	else
		''CPF/CNPJ Titular''
	end LabelCpfTitular
	
	,case when par.prm_ds_valor = ''true'' then 1 else 0 end ExibirDadosBancarios

	,m.ResponsavelContrato
	
	,case len(m.CpfCnpjResponsavel)
		when 11 then format(cast(m.CpfCnpjResponsavel as bigint), ''000\.000\.000\-00'') --cpf
		when 14 then format(cast(m.CpfCnpjResponsavel as bigint), ''00\.000\.000\/0000\-00'') --cnpj
	else
		m.CpfCnpjResponsavel
	end CpfCnpjResponsavel

	,case len(m.CpfCnpjResponsavel)
		when 11 then ''CPF Responsável''
		when 14 then ''CNPJ Responsável''
	else
		''CPF/CNPJ Responsável''
	end LabelCpfCnpjResponsavel

	,case when par2.prm_ds_valor = ''true'' and m.ResponsavelContrato is not null then 1 else 0 end ExibirResponsavel

	,case when par3.prm_ds_valor is not null and par3.prm_ds_valor <> '''' then par3.prm_ds_valor else ''Total da nota a emitir:'' end LabelTotal

	--select count(*)
	from [tb_pgto_periodo_rota] a

	left join [tb_pgto_periodo] as periodo
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	inner join tb_pag_espelhos as espelho
	on 1=1
	-- and espelho.mtn_cd_motorista		= a.ppr_cd_motorista
	-- and espelho.mtn_cd_pgto_periodo = a.ppr_cd_periodo
	and espelho.mtn_cd_motorista_nfs = a.ppr_cd_pgto_espelho

	left join tb_clientes as c
	on espelho.mtn_cod_cliente =  c.cli_cd_codigo_cliente 

	--left join vw_rotas as b
	--on a.ppr_cd_rota = cast(b.idrota as varchar(10))

	left join tb_usuario as d
	on a.ppr_cd_motorista = d.usr_cd_usuario
	and d.cli_cd_codigo_cliente = c.cli_cd_codigo_cliente

	left join tb_motorista as e
	on  ppr_cd_motorista = e.mot_cd_usuario
	
	left join tb_parametros par with(nolock) on c.cli_cd_codigo_cliente = par.prm_cod_cliente and par.prm_ds_chave = ''Exibir Dados Bancários Espelho''
	left join tb_parametros par2 with(nolock) on c.cli_cd_codigo_cliente = par2.prm_cod_cliente and par2.prm_ds_chave = ''Exibir Responsável Espelho''
	left join tb_parametros par3 with(nolock) on c.cli_cd_codigo_cliente = par3.prm_cod_cliente and par3.prm_ds_chave = ''Label Total Espelho''
	left join tb_parametros par4 with(nolock) on c.cli_cd_codigo_cliente = par4.prm_cod_cliente and par4.prm_ds_chave = ''Exibir tipo lançamento espelho'' and par4.prm_ds_valor = ''true''
	
	--Inclusão para pegar dados de pagamentos dos motoristas
	left join vw_dados_motoristas m on d.usr_cd_usuario = m.CodigoUsuario and c.cli_cd_codigo_cliente = m.IdCliente

	left join tb_lancamentos_manuais as l on a.ppr_lcto_cd_lancamento = l.tlm_cd_lancamento_manual
	left join tb_tipos_lancamentos_manuais as t on l.tlm_cd_tipo = t.plm_cd_tipo_lancamento_manual

	WHERE ppr_in_excluido = 0
	and mot_cd_cliente = pgp_cd_cliente
	 --and mtn_cd_motorista_nfs = 420558

	/* ALTERAÇÃO 07/04/2025 and mot_cd_status = 1 retirado para que motoristas com status de inativo apareçam no espelho de pagamentos */

	 --and mot_cd_status = 1


	--select * from tb_motorista where mot_nm_motorista = ''Gustavo Henrique da Silva''
	--select * from tb_ml_motoristas where Nome = ''Gustavo Henrique da Silva''
	--select * from tb_usuario where usr_nm_usuario = ''Gustavo Henrique da Silva''

	--union all

	--select
	--convert(varchar(10),tlm_dh_referencia,103) as Data
	--,cast(tlm_cd_rota as varchar(50)) as IdRota
	--,tlm_cd_motorista as Motorista
	--,tlm_cd_service_center as Base
	--,null as Placa
	--,case when isnull(tlm_vl_valor_descontos,0) > 0 then ''Desconto'' else ''Credito'' end as Origem
	--,tlm_ds_observacao as observacao
	--,null as Veiculo
	--,-1 * isnull(tlm_vl_valor_descontos,0) + isnull(tlm_vl_valor_apoio,0)  ValorApoio
	--,cli_ds_nome as Transportadora
	--,null DataGeracao
	--,tlm_dh_criacao as DataCriacao
	--,cli_ds_cnpj as CNPJ
	--,usr_matricula as Matricula
	--,c.CPF
	--,CONVERT(VARCHAR(10), periodo.pgp_dt_inicio, 103) as DataInicio
	--,CONVERT(VARCHAR(10), periodo.pgp_dt_fim, 103) as DataFim
	
	--from (
	--		select a.*
	--		from [dbo].[tb_lancamentos_manuais] as a
	--		inner join [tb_aprovacao_lancamento_manual] as b
	--		on alm_cd_lancamento_manual = tlm_cd_lancamento_manual
	--		where alm_ds_status = ''Aprovado''
	--	) as a
	
	--left join tb_usuario as b
	--on a.tlm_cd_usuario_criacao = b.usr_cd_usuario
	
	--left join (
	--			select cli_cd_codigo_cliente,cli_ds_cnpj,cli_ds_nome, a.*
	--			from tb_ml_motoristas as a
	--			inner join tb_clientes as b
	--			on a.idtransportadora = b.cli_id_logistics         
	--			) as c
	--on a.tlm_cd_motorista = c.nome
	--and a.tlm_cd_cliente = c.cli_cd_codigo_cliente
	
	
	--inner join (
	
	--			select distinct ppr_cd_periodo ,pgp_dt_inicio,pgp_dt_fim,ppr_nome_motorista
	--			from tb_pgto_periodo_rota as a
	--			inner join tb_pgto_periodo as b
	--			on a.ppr_cd_periodo = b.pgp_cd_periodo
	--			where ppr_cd_pgto_espelho = @codespelho
	
	--			) as periodo
	--on periodo.ppr_nome_motorista = a.tlm_cd_motorista
	
	--where tlm_in_ativo = 1
	--and cast(tlm_dh_referencia as date) between pgp_dt_inicio and pgp_dt_fim');

    --==========================================================================
    -- 3. POS-CHECK
    --==========================================================================
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_pgto_espelho_motorista')) NOT LIKE '%Não Visitado: R$%'
        THROW 50041, 'Pos-check falhou: vw_pgto_espelho_motorista sem o label Não Visitado.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_pgto_espelho_motorista_novo')) NOT LIKE '%Não Visitado: R$%'
        THROW 50041, 'Pos-check falhou: vw_pgto_espelho_motorista_novo sem o label Não Visitado.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_pgto_espelho_motorista')) LIKE '%Desconto DS: R$%'
        THROW 50041, 'Pos-check falhou: vw_pgto_espelho_motorista ainda contem Desconto DS.', 1;
    IF OBJECT_DEFINITION(OBJECT_ID('dbo.vw_pgto_espelho_motorista_novo')) LIKE '%Desconto DS: R$%'
        THROW 50041, 'Pos-check falhou: vw_pgto_espelho_motorista_novo ainda contem Desconto DS.', 1;

    PRINT 'SUCESSO: Script executado com sucesso.';

END TRY
BEGIN CATCH
    PRINT 'ERRO: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Severidade: ' + CAST(ERROR_SEVERITY() AS VARCHAR);
    THROW;
END CATCH;
GO
