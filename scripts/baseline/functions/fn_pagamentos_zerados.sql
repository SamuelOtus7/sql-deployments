-- ============================================================
-- BASELINE: dbo.fn_pagamentos_zerados
-- Tipo: UserDefinedFunction
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  UserDefinedFunction [dbo].[fn_pagamentos_zerados]    Script Date: 14/09/2026 12:12:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_pagamentos_zerados]
(
    @IdPeriodo INT = NULL,
    @Rota VARCHAR(50) = NULL
)
RETURNS @Resultado TABLE
(
    CodigoEspelho INT,
    DataReferencia DATE,
    ppr_cd_periodo int,
    Contrato VARCHAR(200),
    Motorista VARCHAR(200),
    Base VARCHAR(50),
    TipoVeiculo VARCHAR(100),
    Cidade VARCHAR(100),
    IdRota VARCHAR(100),
    Status VARCHAR(200),
    DataAtualizacaoControlePowerBI DATETIME
)
AS
BEGIN

    DECLARE @IdCliente INT;
    DECLARE @UtilizaContrato INT;
    --declare @IdPeriodo INT = 3357,
    --@Rota VARCHAR(50) = '403561915'



    INSERT INTO @Resultado
    SELECT 
        r.ppr_cd_pgto_espelho,
        r.ppr_data_referencia,
        r.ppr_cd_periodo,
        CASE 
            WHEN @UtilizaContrato = 0 
                THEN 'Cadastro Padrao'
            ELSE ISNULL(c.ttc_nm_tipo, 'Sem contrato atribuido')
        END AS Contrato,
        r.ppr_nome_motorista,
        r.ppr_base_principal,
        r.ppr_ds_tipo_veiculo,
        r.ppr_nm_cidade,
        r.ppr_cd_rota,
        CASE  
            WHEN r.ppr_vl_base > 0 
                THEN 'Cadastro OK'
            WHEN r.ppr_cd_desconto_ds = 1 or (b.pgp_cd_cliente = 45 and r.ppr_vl_success_delivery < 0.5)          
                THEN 'Desconto de sucessos na entrega'
            WHEN isnull(frete.bfm_perc_minimo_endereco_nao_visitado,frete_cidade.bfm_perc_minimo_endereco_nao_visitado) is not null 
                    and r.ppr_per_endereco_nao_visitado < COALESCE(
                                                                    freteParadas.bfm_perc_minimo_endereco_nao_visitado,
                                                                    frete.bfm_perc_minimo_endereco_nao_visitado,
                                                                    frete_cidadeParadas.bfm_perc_minimo_endereco_nao_visitado,
                                                                    frete_cidade.bfm_perc_minimo_endereco_nao_visitado
                                                                )
                THEN 'Percentual de endereço não visitado abaixo do limite'
            WHEN isnull(par.prm_ds_valor,1) = 1 AND c.ttc_nm_tipo IS NULL
                THEN 'Sem contrato atribuido'
            WHEN isnull(par.prm_ds_valor,1) = 1 
                 AND b.pgp_cd_tipo_contratos <> m.mot_ctn_cd_tipo_contrato
                THEN 'Contrato diferente do periodo'
            WHEN r.ppr_total_km IS NULL OR r.ppr_total_km = 0
                THEN 'Código 1 - Acionar o suporte'
            WHEN frete_cidade.bfm_nm_cidade IS NOT NULL AND r.ppr_nm_cidade <> frete_cidade.bfm_nm_cidade
                THEN 'Cidade com nomeclaturas diferentes'
            WHEN r.ppr_qt_pacotes_entregues = 0
                THEN 'Sem pacotes entregues'
             WHEN lanc.plm_nm_tipo = 'Ambulância Reprovada'
                THEN 'Ambulância Reprovada'


            WHEN COALESCE(
                            freteParadas.bfm_vl_inicio_faixa,
                            frete.bfm_vl_inicio_faixa,
                            frete_cidadeParadas.bfm_vl_inicio_faixa,
                            frete_cidade.bfm_vl_inicio_faixa
                        ) is null

                THEN 'Sem base cadastrada'

            WHEN b.pgp_cd_cliente = 45 and r.ppr_in_ambulancia = 1 and ppr_ds_tipo_veiculo like '%SDD%'
                THEN 'Veiculos SDD / Ambulancia'

            WHEN edit.edit_zerar_pagamento = 1
                THEN 'Zerado Manualmente'

            WHEN COALESCE(freteParadas.bfm_vl_frete,frete.bfm_vl_frete,frete_cidadeParadas.bfm_vl_frete,frete_cidade.bfm_vl_frete) = 0 
                    or COALESCE(freteParadas.bfm_vl_frete_pm,frete.bfm_vl_frete_pm,frete_cidadeParadas.bfm_vl_frete_pm,frete_cidade.bfm_vl_frete_pm) = 0 
                    or COALESCE(freteParadas.bfm_vl_domfer_am,frete.bfm_vl_domfer_am,frete_cidadeParadas.bfm_vl_domfer_am,frete_cidade.bfm_vl_domfer_am) = 0 
                    or COALESCE(freteParadas.bfm_vl_domfer_pm,frete.bfm_vl_domfer_pm,frete_cidadeParadas.bfm_vl_domfer_pm,frete_cidade.bfm_vl_domfer_pm) = 0 
                THEN 'Base Frete Zerada'

            WHEN r.ppr_motivo_rota_zerada is not null
                THEN r.ppr_motivo_rota_zerada


            ELSE 'Motivo nao mapeado'
        END AS Status,
        CAST(
            CASE 
                WHEN b.pgp_dt_inicio >= DATEADD(DAY,-60,CAST(GETDATE() AS DATE))
                    THEN CAST(GETDATE() AS DATE)
                ELSE b.pgp_dt_inicio
            END AS DATETIME
        ) AS DataAtualizacaoControlePowerBI

    FROM tb_pgto_periodo_rota r
    LEFT JOIN tb_motorista m
        ON r.ppr_cd_motorista = m.mot_cd_usuario
    LEFT JOIN tb_tipo_contrato c
        ON c.ttc_cd_tipo_contrato = m.mot_ctn_cd_tipo_contrato
    LEFT JOIN tb_dra_tipo_veiculo veic
        ON veic.tvl_nm_tipo_veiculo = r.ppr_ds_tipo_veiculo
    LEFT JOIN tb_pgto_periodo b
        ON b.pgp_cd_periodo = r.ppr_cd_periodo

    left join tb_parametros as par 
        on b.pgp_cd_cliente = par.prm_cod_cliente
        and prm_ds_categoria = 'Financeiro - Pagamentos'
        and prm_nm_parametro = 'Utiliza contrato'

    LEFT JOIN tb_fin_base_frete_motorista frete
        ON frete.bfm_cd_transportadora = b.pgp_cd_cliente
       AND frete.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND frete.bfm_cd_service_center = r.ppr_base_principal
       AND (
            (isnull(par.prm_ds_valor,1) = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(frete.bmf_cd_tipo_contrato,-1))
            OR isnull(par.prm_ds_valor,1) = 0
       )
       AND ISNULL(r.ppr_total_km,0) BETWEEN frete.bfm_vl_inicio_faixa AND frete.bfm_vl_fim_faixa
       AND frete.bfm_nm_cidade IS NULL
       AND r.ppr_data_referencia BETWEEN frete.bfm_data_inicio_vigencia 
           AND ISNULL(frete.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))
       AND frete.bfm_cd_criterio_faixa2 is null
       AND frete.bfm_ds_placa IS NULL

    LEFT JOIN tb_fin_base_frete_motorista frete_cidade
        ON frete_cidade.bfm_cd_transportadora = b.pgp_cd_cliente
       AND frete_cidade.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND frete_cidade.bfm_cd_service_center = r.ppr_base_principal
       AND frete_cidade.bfm_nm_cidade = r.ppr_nm_cidade
       AND (
            (isnull(par.prm_ds_valor,1) = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(frete_cidade.bmf_cd_tipo_contrato,-1))
            OR 
            isnull(par.prm_ds_valor,1) = 0
       )
       AND ISNULL(r.ppr_total_km,0) BETWEEN frete_cidade.bfm_vl_inicio_faixa AND frete_cidade.bfm_vl_fim_faixa
       AND r.ppr_data_referencia BETWEEN frete_cidade.bfm_data_inicio_vigencia 
           AND ISNULL(frete_cidade.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))
       AND frete_cidade.bfm_cd_criterio_faixa2 is null
       AND frete_cidade.bfm_ds_placa IS NULL

    LEFT JOIN vw_fin_base_frete_motorista freteParadas
        ON freteParadas.bfm_cd_transportadora = b.pgp_cd_cliente
       AND freteParadas.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND freteParadas.bfm_cd_service_center = r.ppr_base_principal
       AND (
            (isnull(par.prm_ds_valor,1) = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(freteParadas.bmf_cd_tipo_contrato,-1))
            OR 
            isnull(par.prm_ds_valor,1) = 0
       )
       AND r.ppr_total_km > (freteParadas.bfm_vl_inicio_faixa - 1)
       AND r.ppr_total_km <= freteParadas.bfm_vl_fim_faixa
       AND freteParadas.bfm_nm_cidade IS NULL
       AND r.ppr_data_referencia BETWEEN freteParadas.bfm_data_inicio_vigencia
           AND ISNULL(freteParadas.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))
       AND freteParadas.CriterioFaixa2 = 'Paradas'
       AND r.ppr_qt_paradas > (freteParadas.bfm_vl_inicio_faixa2 - 1)
       AND r.ppr_qt_paradas <= freteParadas.bfm_vl_fim_faixa2
       AND freteParadas.bfm_ds_placa IS NULL

    LEFT JOIN vw_fin_base_frete_motorista frete_cidadeParadas
        ON frete_cidadeParadas.bfm_cd_transportadora = b.pgp_cd_cliente
       AND frete_cidadeParadas.bfm_cd_tipo_veiculo = veic.tvl_cd_tipo_veiculo
       AND frete_cidadeParadas.bfm_cd_service_center = r.ppr_base_principal
       AND (
            (isnull(par.prm_ds_valor,1) = 1 
             AND ISNULL(c.ttc_cd_tipo_contrato,-1) = ISNULL(frete_cidadeParadas.bmf_cd_tipo_contrato,-1))
            OR 
            isnull(par.prm_ds_valor,1) = 0
       )
       AND r.ppr_total_km > (frete_cidadeParadas.bfm_vl_inicio_faixa - 1)
       AND r.ppr_total_km <= frete_cidadeParadas.bfm_vl_fim_faixa
       AND frete_cidadeParadas.bfm_nm_cidade = r.ppr_nm_cidade
       AND r.ppr_data_referencia BETWEEN frete_cidadeParadas.bfm_data_inicio_vigencia
           AND ISNULL(frete_cidadeParadas.bfm_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))
       AND frete_cidadeParadas.CriterioFaixa2 = 'Paradas'
       AND r.ppr_qt_paradas > (frete_cidadeParadas.bfm_vl_inicio_faixa2 - 1)
       AND r.ppr_qt_paradas <= frete_cidadeParadas.bfm_vl_fim_faixa2
       AND frete_cidadeParadas.bfm_ds_placa IS NULL

    left join vw_lancamentos_manuais as lanc
        on lanc.tlm_cd_rota = r.ppr_cd_rota
        and cast(tlm_dh_referencia as date) between pgp_dt_inicio and pgp_dt_fim
        and pgp_cd_cliente = 27
        and plm_nm_tipo = 'Ambulância Reprovada'

    left join tb_pgto_periodo_rota_edit as edit
        on r.ppr_cd_periodo = edit.edit_cd_periodo
        and r.ppr_cd_rota = edit.edit_rota

    WHERE r.ppr_vl_base = 0
      AND r.ppr_cd_periodo >= 370
      AND (@IdPeriodo IS NULL OR r.ppr_cd_periodo = @IdPeriodo)
      AND (@Rota IS NULL OR r.ppr_cd_rota = @Rota);


    RETURN;
END;


GO
