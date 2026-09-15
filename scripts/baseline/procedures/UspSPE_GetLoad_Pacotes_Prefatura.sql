-- ============================================================
-- BASELINE: dbo.UspSPE_GetLoad_Pacotes_Prefatura
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPE_GetLoad_Pacotes_Prefatura]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspSPE_GetLoad_Pacotes_Prefatura]
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#PacotesFonte') IS NOT NULL
        DROP TABLE #PacotesFonte;

    SELECT
        x.IdTransportadora,
        x.Tipo_do_Serviço,
        x.Operação,
        x.SOC,
        x.Hub,
        x.Rota,
        x.Período_Ano_Mês_Quinzena,
        x.Tracking_Number_Numero_Etiqueta_Ordem_Shopee,
        x.Tracking_Number_Enviado_por_API_pela_Transportadora,
        x.Data_da_Prestação_do_Serviço,
        x.Nome_Tomador_do_Serviço,
        x.CNPJ_Tomador,
        x.Nome_Transportadora_3PL,
        x.CNPJ_Emitente_3PL,
        x.CEP_Origem,
        x.Cidade_Origem,
        x.UF_Origem,
        x.CEP_Entrega,
        x.Cidade_Entrega,
        x.UF_Entrega,
        x.Dados_do_Seller,
        x.Data_da_Entrega,
        x.Quantidade_Volume,
        x.Peso_Real,
        x.Peso_Cubado,
        x.Peso_Calculado_Cobrado,
        x.KM_Rodado,
        x.Tipo_do_Veículo,
        x.Fator_Agrupador_p_Cobrança_por_Veiculo,
        x.Placa,
        x.Valor_Nota_Fiscal_Mercadoria,
        x.Tarifa_Aplicada,
        x.Frete_Tarifa_Base_Peso_KM_Veículo,
        x.Frete_Calculado,
        x.ADV,
        x.GRIS,
        x.Aliquota_ICMS_ISS,
        x.Base_Calc_ICMS_ISS,
        x.Valor_ICMS_ISS,
        x.ICMS_Subst,
        x.Outros_Valores,
        x.Descontos,
        x.Valor_Final_a_Receber,
        x.Data_Emissão_Cte_NF,
        x.Fatura,
        x.Numero_Cte,
        x.Numero_NF,
        x.Serie_Cte_Nf,
        x.Chave_de_Acesso_Cte,
        x.Motivo_Rejeição_CTE,
        x.Prefeitura_NFSe,
        x.Comentários,
        x.De_acordo_Sim_Não,
        x.Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo,
        x.Valor_Negociado_Caso_para_valor_incorreto,
        x.Observações,
        x.UF_Tomador,
        x.Resultado,
        x.PackageUID,
        x.IdentityId,

        /* ===== novos campos ===== */
        CASE
            WHEN x.Comentários LIKE '%Valor ajudante:%'
            THEN TRY_CAST(
                LTRIM(RTRIM(
                    SUBSTRING(
                        x.Comentários,
                        CHARINDEX('Valor ajudante:', x.Comentários) + LEN('Valor ajudante:'),
                        50
                    )
                )) AS NUMERIC(18,8)
            )
            ELSE 0
        END AS ValorAjudante,

        CASE
            WHEN x.Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo LIKE '%Valor incentivo:%'
            THEN TRY_CAST(
                LTRIM(RTRIM(
                    SUBSTRING(
                        x.Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo,
                        CHARINDEX(
                            'Valor incentivo:',
                            x.Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo
                        ) + LEN('Valor incentivo:'),
                        50
                    )
                )) AS NUMERIC(18,8)
            )
            ELSE 0
        END AS ValorIncentivo,

        CASE
            WHEN x.Comentários LIKE '%Flag Risco: 1%' THEN 1
            ELSE 0
        END AS FlagRisco

    INTO #PacotesFonte
    FROM
    (
        SELECT 20230007 AS IdTransportadora, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_50mais t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230008, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_fcargo t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230021, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_optimize t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230019, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_parceiro t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        --UNION ALL
        --SELECT 20230019, t.*
        --FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_parceiro_lh t
        --WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230019, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_parceiro_lm t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230016, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_vite t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))

        UNION ALL
        SELECT 20230025, t.[Tipo_do_Serviço], t.[Operação], [SOC], [Hub], [Rota], [Período_Ano_Mês_Quinzena], [Tracking_Number_Numero_Etiqueta_Ordem_Shopee], [Tracking_Number_Enviado_por_API_pela_Transportadora], [Data_da_Prestação_do_Serviço], [Nome_Tomador_do_Serviço], [CNPJ_Tomador], [Nome_Transportadora_3PL], [CNPJ_Emitente_3PL], [CEP_Origem], [Cidade_Origem], [UF_Origem], [CEP_Entrega], [Cidade_Entrega], [UF_Entrega], [Dados_do_Seller], [Data_da_Entrega], [Quantidade_Volume], [Peso_Real], [Peso_Cubado], [Peso_Calculado_Cobrado], [KM_Rodado], [Tipo_do_Veículo], [Fator_Agrupador_p_Cobrança_por_Veiculo], [Placa], [Valor_Nota_Fiscal_Mercadoria], [Tarifa_Aplicada], [Frete_Tarifa_Base_Peso_KM_Veículo], [Frete_Calculado], [ADV], [GRIS], [Aliquota_ICMS_ISS], [Base_Calc_ICMS_ISS], [Valor_ICMS_ISS], [ICMS_Subst], [Outros_Valores], [Descontos], [Valor_Final_a_Receber], [Data_Emissão_Cte_NF], [Fatura], [Numero_Cte], [Numero_NF], [Serie_Cte_Nf], [Chave_de_Acesso_Cte], [Motivo_Rejeição_CTE], [Prefeitura_NFSe], [Comentários], [De_acordo_Sim_Não], [Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo], [Valor_Negociado_Caso_para_valor_incorreto], [Observações], [UF_Tomador], [Resultado], [PackageUID], [IdentityId]
        FROM [10.1.1.21,1483].[IrisysFiscal].[dbo].tb_carga_prefatura_hawk t
        WHERE CAST(t.Data_da_Prestação_do_Serviço AS DATE) >= DATEADD(DAY, -10, CAST(GETDATE() AS DATE))
    ) x;

   MERGE dbo.tb_spe_pacotes_prefatura AS T
USING #PacotesFonte AS S
    ON  T.IdTransportadora = S.IdTransportadora
    AND T.Rota             = S.Rota
    AND T.Tracking_Number_Numero_Etiqueta_Ordem_Shopee
        = S.Tracking_Number_Numero_Etiqueta_Ordem_Shopee

WHEN MATCHED THEN
    UPDATE SET
        T.ValorAjudante  = S.ValorAjudante,
        T.ValorIncentivo = S.ValorIncentivo,
        T.FlagRisco      = S.FlagRisco

    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            IdTransportadora,
            Tipo_do_Servico,
            Operacao,
            SOC,
            Hub,
            Rota,
            Periodo_Ano_Mes_Quinzena,
            Tracking_Number_Numero_Etiqueta_Ordem_Shopee,
            Tracking_Number_Enviado_por_API_pela_Transportadora,
            Data_da_Prestacao_do_Servico,
            Nome_Tomador_do_Servico,
            CNPJ_Tomador,
            Nome_Transportadora_3PL,
            CNPJ_Emitente_3PL,
            CEP_Origem,
            Cidade_Origem,
            UF_Origem,
            CEP_Entrega,
            Cidade_Entrega,
            UF_Entrega,
            Dados_do_Seller,
            Data_da_Entrega,
            Quantidade_Volume,
            Peso_Real,
            Peso_Cubado,
            Peso_Calculado_Cobrado,
            KM_Rodado,
            Tipo_do_Veiculo,
            Fator_Agrupador_p_Cobranca_por_Veiculo,
            Placa,
            Valor_Nota_Fiscal_Mercadoria,
            Tarifa_Aplicada,
            Frete_Tarifa_Base_Peso_KM_Veiculo,
            Frete_Calculado,
            ADV,
            GRIS,
            Aliquota_ICMS_ISS,
            Base_Calc_ICMS_ISS,
            Valor_ICMS_ISS,
            ICMS_Subst,
            Outros_Valores,
            Descontos,
            Valor_Final_a_Receber,
            Data_Emissao_Cte_NF,
            Fatura,
            Numero_Cte,
            Numero_NF,
            Serie_Cte_Nf,
            Chave_de_Acesso_Cte,
            Motivo_Rejeicao_CTE,
            Prefeitura_NFSe,
            Comentarios,
            De_acordo_Sim_Nao,
            Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo,
            Valor_Negociado_Caso_para_valor_incorreto,
            Observacoes,
            UF_Tomador,
            Resultado,
            PackageUID,
            IdentityId,
            ValorAjudante,
            ValorIncentivo,
            FlagRisco
        )
        VALUES
        (
            S.IdTransportadora,
            S.Tipo_do_Serviço,
            S.Operação,
            S.SOC,
            S.Hub,
            S.Rota,
            S.Período_Ano_Mês_Quinzena,
            S.Tracking_Number_Numero_Etiqueta_Ordem_Shopee,
            S.Tracking_Number_Enviado_por_API_pela_Transportadora,
            S.Data_da_Prestação_do_Serviço,
            S.Nome_Tomador_do_Serviço,
            S.CNPJ_Tomador,
            S.Nome_Transportadora_3PL,
            S.CNPJ_Emitente_3PL,
            S.CEP_Origem,
            S.Cidade_Origem,
            S.UF_Origem,
            S.CEP_Entrega,
            S.Cidade_Entrega,
            S.UF_Entrega,
            S.Dados_do_Seller,
            S.Data_da_Entrega,
            S.Quantidade_Volume,
            S.Peso_Real,
            S.Peso_Cubado,
            S.Peso_Calculado_Cobrado,
            S.KM_Rodado,
            S.Tipo_do_Veículo,
            S.Fator_Agrupador_p_Cobrança_por_Veiculo,
            S.Placa,
            S.Valor_Nota_Fiscal_Mercadoria,
            S.Tarifa_Aplicada,
            S.Frete_Tarifa_Base_Peso_KM_Veículo,
            S.Frete_Calculado,
            S.ADV,
            S.GRIS,
            S.Aliquota_ICMS_ISS,
            S.Base_Calc_ICMS_ISS,
            S.Valor_ICMS_ISS,
            S.ICMS_Subst,
            S.Outros_Valores,
            S.Descontos,
            S.Valor_Final_a_Receber,
            S.Data_Emissão_Cte_NF,
            S.Fatura,
            S.Numero_Cte,
            S.Numero_NF,
            S.Serie_Cte_Nf,
            S.Chave_de_Acesso_Cte,
            S.Motivo_Rejeição_CTE,
            S.Prefeitura_NFSe,
            S.Comentários,
            S.De_acordo_Sim_Não,
            S.Motivo_Valor_incorreto_numero_de_ordens_incorreta_no_protocolo,
            S.Valor_Negociado_Caso_para_valor_incorreto,
            S.Observações,
            S.UF_Tomador,
            S.Resultado,
            S.PackageUID,
            S.IdentityId,
            S.ValorAjudante,
            S.ValorIncentivo,
            S.FlagRisco
        );

END;
GO
