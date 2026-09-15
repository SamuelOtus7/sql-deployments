-- ============================================================
-- BASELINE: dbo.UpsGeraPagamentoAdicional
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UpsGeraPagamentoAdicional]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[UpsGeraPagamentoAdicional] (    
    @CodPeriodoPagamento INT,    
    @idrota VARCHAR(50) NULL,    
    @cd_usr INT    
)    
AS    
BEGIN   

    /*    
        Em clientes que utilizam a prefatura como parâmetro, precisa ter um parâmetro de contingência.    
        Sempre que for calculado os valores, precisa ter uma sinalização se é da prefatura ou contingência.    
    
        Tem uma regra de adicional que define se ambulância será paga na primeira faixa (bfa_cd_ambulancia_primeira_faixa).    
            Este campo deveria ser um parâmetro global?    
            Cada base pode ou não ter este campo?    
            Esta regra deveria estar na etapa de adicional?    
    
        Regra de desconto flex:    
            Flag na tabela de adicional:    
                Sim, Valor fixo ? sempre que tiver um abastecimento será descontado o valor de desconto flex.    
                Sem, valor de abastecimento ? sempre que tiver um abastecimento será descontado o valor do abastecimento que vem da API.    
                Não ? não tem desconto flex.    
            Obs: descobrir quais são os códigos das flags.    
    
        Flag de desconto por cartão:    
            Sim ou não, valor fixo que será descontado.    
            Obs: descobrir quais são os códigos das flags.    
    */    
        
    

    
    DECLARE    
        @IdTransportadora INT,    
        --@CodPeriodoPagamento INT = 2423,    
        --@idrota VARCHAR(50) = NULL,    
        --@cd_usr INT = 7, -- se receber valor NULL precisa    
        @data_inicial DATE,    
        @data_final DATE,    
        @clienteid INT,    
        @usuarioIrisys INT,    
        @Motorista VARCHAR(250),    
        @IdCliTransportadora INT,    
        @tipocontrato INT = NULL,    
        @agora DATETIME = GETDATE();    
    
    ----- Parâmetros de filtros    
    SET @data_inicial = (    
        SELECT pgp_dt_inicio    
        FROM [dbo].[tb_pgto_periodo] WITH (NOLOCK)    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @data_final = (    
        SELECT pgp_dt_fim    
        FROM [dbo].[tb_pgto_periodo] WITH (NOLOCK)    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    IF @idrota IS NOT NULL    
    BEGIN    
        SET @Motorista = (    
            SELECT DISTINCT NomeMotorista    
            FROM tb_ml_rotas (NOLOCK)    
            WHERE idrota = @idrota    
        );    
    END;    
    
    SET @IdTransportadora = (    
        SELECT cli_id_logistics    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @tipocontrato = (    
        SELECT pgp_cd_tipo_contratos    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    SET @IdCliTransportadora = (    
        SELECT lst_cd_lista    
        FROM tb_lista (NOLOCK)    
        WHERE lst_nm_lista = 'Clientes transportadoras'    
          AND lst_ds_label = 'Mercado Livre'    
          AND lst_cd_cliente IN (    
                SELECT pgp_cd_cliente    
                FROM [tb_pgto_periodo] AS a (NOLOCK)    
                LEFT JOIN tb_clientes AS b (NOLOCK)    
                    ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
                WHERE pgp_cd_periodo = @CodPeriodoPagamento    
          )    
    );    
    
    SET @clienteid = (    
        SELECT pgp_cd_cliente    
        FROM [tb_pgto_periodo] AS a (NOLOCK)    
        LEFT JOIN tb_clientes AS b (NOLOCK)    
            ON a.pgp_cd_cliente = cli_cd_codigo_cliente    
        WHERE pgp_cd_periodo = @CodPeriodoPagamento    
    );    
    
    DECLARE @Operacao INT = (    
        SELECT lst_cd_lista    
        FROM tb_lista WITH (NOLOCK)    
        WHERE lst_nm_lista = 'Operações Marketplace'    
          AND lst_ds_valor = 'LM'    
          AND lst_cd_cliente = @clienteid    
    );    
    
    ----- Parâmetros para cálculos    
    DECLARE @Kmselecionado1 VARCHAR(150) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'    
          AND prm_nm_parametro = 'Km a ser utilizado.'    
          AND prm_cod_cliente = 37    
    );    
    
    DECLARE @Kmselecionado2 VARCHAR(150) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem'    
          AND prm_nm_parametro = 'Km a ser utilizado 2'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @MenorValorKm VARCHAR(5) = (    
        SELECT prm_ds_valor    
        FROM tb_parametros    
        WHERE prm_nm_parametro = 'Considerar menor valor entre KM'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @Veiculo VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Veiculo'    
          AND prm_cod_cliente = @clienteid    
          and prm_ds_categoria = 'Financeiro - Pagamentos'    
    );    
    
    -- Utiliza ponto ou parada    
    DECLARE @PontoOuParada VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Pontou ou Parada'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Este parâmetro é a origem da parada    
    DECLARE @OrigemParada VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        -- O nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Paradas"    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadeParadas'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Origem ponto    
    DECLARE @OrigemPonto VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        -- O nome desta lista precisa mudar para "Parâmetros do financeiro - Origem Pontos"    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - QuantidadePontos'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    DECLARE @DivisaoEspelho VARCHAR(50) = (    
        SELECT prm_ds_valor    
        FROM tb_parametros    
        WHERE prm_nm_parametro = 'Divisão  de espelho'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    -- Descontos de ponto ou parada    
    DECLARE @DescontaPontoPara VARCHAR(50) = (    
        SELECT lst_ds_valor    
        FROM tb_lista l (NOLOCK)    
        INNER JOIN tb_parametros AS p    
            ON prm_ds_valor = CAST(l.lst_cd_lista AS VARCHAR(150))    
        WHERE l.lst_nm_lista = 'Parâmetros do financeiro - Desconta Pacote'    
          AND prm_cod_cliente = @clienteid    
    );    
    
    declare @UtilizaContrato int = (    
     select prm_ds_valor     
     from tb_parametros     
     where prm_ds_categoria = 'Financeiro - Pagamentos'    
     and prm_nm_parametro = 'Utiliza contrato'    
     and prm_cod_cliente = @clienteid    
 )    
    
    
    
    
    
    DROP TABLE IF EXISTS #tb_pgto_periodo_rota;    
    SELECT a.*    
    INTO #tb_pgto_periodo_rota    
    FROM tb_pgto_periodo_rota as a  
    inner join tb_pag_espelhos as b  
    on a.ppr_cd_motorista_nfs = mtn_cd_motorista_nfs  
    WHERE ppr_cd_periodo = @CodPeriodoPagamento    
      and mtn_cd_status IN (34,228,38)
      AND (ppr_cd_rota  = @idrota OR @idrota IS NULL)
      and ppr_nm_pgto = 'Rota Mercado Livre'
      and ppr_in_excluido = 0
      ;    
    


    --- REGRA PARA PARAMETRIZAR
    update  a
    set     ppr_in_area_risco = 
            case 
                when ppr_base_principal = 'SRJ13' and isnull(ppr_cd_desconto_sd,0) = 0 then 1
                when ppr_base_principal = 'SRJ1' then 1
                --when ppr_base_principal = 'SRJ6' then 1
                when ppr_base_principal = 'SRJ2' then 1
                else 0
            end
    from    #tb_pgto_periodo_rota as a
    where   @clienteid = 66





    DROP TABLE IF EXISTS #tb_parametro_paradas_km;    
    SELECT    
        bfp_cd_adcional_parada,    
        bfa_cd_adicional_motorista,    
        bfa_fx_ini,    
        bfa_fx_fim,    
        bfa_fx_fim - ISNULL(LAG(bfa_fx_fim) OVER (PARTITION BY bfa_cd_adicional_motorista ORDER BY bfp_cd_adcional_parada), 0) AS bfa_fx_multiplicador,    
        bfa_fx_valor,    
        bfa_fx_ini_2,    
        bfa_fx_fim_2,    
        bfa_dia_util,    
        bfa_tipo_valor,
        tipo_fx_1
    INTO #tb_parametro_paradas_km    
    FROM tb_fin_base_frete_adicional_motorista_parada;    
    
    
    
    DROP TABLE IF EXISTS #tb_pgto_periodo_rota_calc;    
    
       WITH adicionais AS (    
        SELECT    
            a.ppr_cd_periodo,    
            a.ppr_cd_rota,  
            a.ppr_cd_pagamento_rota, 
            a.ppr_in_zerar_rota,
            COALESCE(adcplaca.bfa_cd_base_frete_adicional_motorista, adplaca.bfa_cd_base_frete_adicional_motorista,adc.bfa_cd_base_frete_adicional_motorista, ad.bfa_cd_base_frete_adicional_motorista) AS bfa_cd_base_frete_adicional_motorista,    
            NULLIF(a.ppr_qt_pacotes_entregues, 0) / CAST(NULLIF(a.ppr_qt_pacotes, 0) AS DECIMAL(9,2)) AS ppr_vl_success_delivery,    
            COALESCE(adcplaca.bfa_tipo_adicional_risco, adplaca.bfa_tipo_adicional_risco, adc.bfa_tipo_adicional_risco, ad.bfa_tipo_adicional_risco) AS tipo_risco,    
            COALESCE(adcplaca.bfa_vl_adicional_risco, adplaca.bfa_vl_adicional_risco, adc.bfa_vl_adicional_risco, ad.bfa_vl_adicional_risco) AS vl_risco,    
            COALESCE(adcplaca.bfa_tipo_adicional_ajudante, adplaca.bfa_tipo_adicional_ajudante, adc.bfa_tipo_adicional_ajudante, ad.bfa_tipo_adicional_ajudante) AS tipo_ajudante,    
            COALESCE(adcplaca.bfa_vl_adicional_ajudante, adplaca.bfa_vl_adicional_ajudante, adc.bfa_vl_adicional_ajudante, ad.bfa_vl_adicional_ajudante) AS vl_ajudante,    
            COALESCE(adcplaca.bfa_tipo_adicional_domingo, adplaca.bfa_tipo_adicional_domingo, adc.bfa_tipo_adicional_domingo, ad.bfa_tipo_adicional_domingo) AS tipo_domingo,    
            COALESCE(adcplaca.bfa_vl_adicional_domingo, adplaca.bfa_vl_adicional_domingo, adc.bfa_vl_adicional_domingo, ad.bfa_vl_adicional_domingo) AS vl_domingo,    
            COALESCE(adcplaca.bfa_vl_adicional_recarga, adplaca.bfa_vl_adicional_recarga, adc.bfa_vl_adicional_recarga, ad.bfa_vl_adicional_recarga) AS vl_recarga,   
            COALESCE(adcplaca.bfa_tipo_adicional_feriado, adplaca.bfa_tipo_adicional_feriado, adc.bfa_tipo_adicional_feriado, ad.bfa_tipo_adicional_feriado) AS tipo_feriado,    
            COALESCE(adcplaca.bfa_vl_adicional_feriado, adplaca.bfa_vl_adicional_feriado, adc.bfa_vl_adicional_feriado, ad.bfa_vl_adicional_feriado) AS vl_feriado,    
            COALESCE(adcplaca.bfa_tipo_adicional_ciclo_pm, adplaca.bfa_tipo_adicional_ciclo_pm, adc.bfa_tipo_adicional_ciclo_pm, ad.bfa_tipo_adicional_ciclo_pm) AS tipo_desc_ciclo_pm,    
            COALESCE(adcplaca.bfa_vl_adicional_ciclo_pm, adplaca.bfa_vl_adicional_ciclo_pm, adc.bfa_vl_adicional_ciclo_pm, ad.bfa_vl_adicional_ciclo_pm) AS vl_desc_ciclo_pm,    
            COALESCE(adcplaca.bfa_perc_ds, adplaca.bfa_perc_ds, adc.bfa_perc_ds, ad.bfa_perc_ds) AS perc_ds,    
            COALESCE(adcplaca.bfa_tipo_bonus_ds, adplaca.bfa_tipo_bonus_ds, adc.bfa_tipo_bonus_ds, ad.bfa_tipo_bonus_ds) AS bfa_tipo_bonus_ds,    
            COALESCE(adcplaca.bfa_vl_bonus_ds, adplaca.bfa_vl_bonus_ds, adc.bfa_vl_bonus_ds, ad.bfa_vl_bonus_ds) AS vl_bonus_ds,    
            COALESCE(adcplaca.bfa_tipo_adicional_faixa, adplaca.bfa_tipo_adicional_faixa, adc.bfa_tipo_adicional_faixa, ad.bfa_tipo_adicional_faixa) AS bfa_tipo_adicional_faixa,    
            COALESCE(adcplaca.bfa_tipo_adicional_rota, adplaca.bfa_tipo_adicional_rota, adc.bfa_tipo_adicional_rota, ad.bfa_tipo_adicional_rota) AS bfa_tipo_adicional_rota,    
            COALESCE(adcplaca.bfa_vl_adicional_rota, adplaca.bfa_vl_adicional_rota, adc.bfa_vl_adicional_rota, ad.bfa_vl_adicional_rota) AS bfa_vl_adicional_rota,    
            COALESCE(adcplaca.bfa_calcula_por_parada, adplaca.bfa_calcula_por_parada, adc.bfa_calcula_por_parada, ad.bfa_calcula_por_parada) AS bfa_calcula_por_parada,    
            COALESCE(adcplaca.bfa_vl_adicional, adplaca.bfa_vl_adicional, adc.bfa_vl_adicional, ad.bfa_vl_adicional) AS bfa_vl_adicional,    
            COALESCE(adcplaca.bfa_tipo_adicional_ajudante_dom, adplaca.bfa_tipo_adicional_ajudante_dom, adc.bfa_tipo_adicional_ajudante_dom, ad.bfa_tipo_adicional_ajudante_dom) AS bfa_tipo_adicional_ajudante_dom,    
            COALESCE(adcplaca.bfa_vl_adicional_ajudante_dom, adplaca.bfa_vl_adicional_ajudante_dom, adc.bfa_vl_adicional_ajudante_dom, ad.bfa_vl_adicional_ajudante_dom) AS bfa_vl_adicional_ajudante_dom,    
            COALESCE(adcplaca.bfa_tipo_adicional, adplaca.bfa_tipo_adicional, adc.bfa_tipo_adicional, ad.bfa_tipo_adicional) AS bfa_tipo_adicional,    
            COALESCE(adcplaca.bfa_qtd_pacote_ambulancia, adplaca.bfa_qtd_pacote_ambulancia, adc.bfa_qtd_pacote_ambulancia, ad.bfa_qtd_pacote_ambulancia) AS regra_ambulancia, 
            COALESCE(adcplaca.bfa_zera_adicional_ambulancia, adplaca.bfa_zera_adicional_ambulancia, adc.bfa_zera_adicional_ambulancia, ad.bfa_zera_adicional_ambulancia) AS zera_adicional_ambulancia    
 

    
    
       FROM #tb_pgto_periodo_rota a    
            INNER JOIN tb_pag_espelhos b    
                ON b.mtn_cd_motorista_nfs = a.ppr_cd_motorista_nfs    
            LEFT JOIN tb_dra_tipo_veiculo tv    
                ON a.ppr_ds_tipo_veiculo = tv.tvl_nm_tipo_veiculo    
            
            LEFT JOIN tb_fin_base_frete_adicional_motorista ad    
                ON b.mtn_cod_cliente = ad.bfa_cd_transportadora    
                   AND a.ppr_base_principal = ad.bfa_cd_service_center    
                   AND tv.tvl_cd_tipo_veiculo = ad.bfa_cd_tipo_veiculo    
                   AND ad.bfa_nm_cidade IS NULL    
                   and (    
                          (@UtilizaContrato = 1 and ISNULL(b.mtn_cd_tipo_contrato, -1) = ISNULL(ad.bfa_cd_tipo_contrato, -1))    
                          or    
                          @UtilizaContrato = 0    
                        )    
            
                   AND a.ppr_data_referencia BETWEEN ad.bfa_data_inicio_vigencia AND ISNULL(ad.bfa_data_fim_vigencia, CONVERT(DATE, DATEADD(YEAR, 1, GETDATE()))) 
                   and ad.bfa_ds_placa is null
            
            LEFT JOIN tb_fin_base_frete_adicional_motorista adc    
                ON b.mtn_cod_cliente = adc.bfa_cd_transportadora    
                   AND a.ppr_base_principal = adc.bfa_cd_service_center    
                   AND tv.tvl_cd_tipo_veiculo = adc.bfa_cd_tipo_veiculo    
                   AND a.ppr_nm_cidade = adc.bfa_nm_cidade    
                   --AND ISNULL(b.mtn_cd_tipo_contrato, -1) = ISNULL(adc.bfa_cd_tipo_contrato, -1)    
                    and (    
                          (@UtilizaContrato = 1 and ISNULL(b.mtn_cd_tipo_contrato, -1) = ISNULL(adc.bfa_cd_tipo_contrato, -1))    
                          or    
                          @UtilizaContrato = 0    
                        ) 
                   AND a.ppr_data_referencia BETWEEN adc.bfa_data_inicio_vigencia AND ISNULL(adc.bfa_data_fim_vigencia, CONVERT(DATE, DATEADD(YEAR, 1, GETDATE())))  
                   and adc.bfa_ds_placa is null


			left join tb_fin_base_frete_adicional_motorista adcplaca on b.mtn_cod_cliente = adcplaca.bfa_cd_transportadora
					and a.ppr_base_principal = adcplaca.bfa_cd_service_center
					and tv.tvl_cd_tipo_veiculo = adcplaca.bfa_cd_tipo_veiculo
					and a.ppr_ds_placa = adcplaca.bfa_ds_placa
					and a.ppr_nm_cidade = adcplaca.bfa_nm_cidade
					and (
							(@UtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(adcplaca.bfa_cd_tipo_contrato, -1))
							or @UtilizaContrato = 0
						)
					and a.ppr_data_referencia between adcplaca.bfa_data_inicio_vigencia and isnull(adcplaca.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
					and adcplaca.bfa_cd_operacao = @Operacao
					and adcplaca.bfa_cd_codigo_cliente = @IdCliTransportadora
				
			left join tb_fin_base_frete_adicional_motorista adplaca on b.mtn_cod_cliente = adplaca.bfa_cd_transportadora
					and a.ppr_base_principal = adplaca.bfa_cd_service_center
					and tv.tvl_cd_tipo_veiculo = adplaca.bfa_cd_tipo_veiculo
					and a.ppr_ds_placa = adplaca.bfa_ds_placa
					and adplaca.bfa_nm_cidade is null
					and (
							(@UtilizaContrato = 1 and isnull(b.mtn_cd_tipo_contrato, -1) = isnull(adplaca.bfa_cd_tipo_contrato, -1))
							or @UtilizaContrato = 0
						)
					and a.ppr_data_referencia between adplaca.bfa_data_inicio_vigencia and isnull(adplaca.bfa_data_fim_vigencia, convert(date, dateadd(year, 1, getdate())))
					and adplaca.bfa_cd_operacao = @Operacao
					and adplaca.bfa_cd_codigo_cliente = @IdCliTransportadora
    
    )    
    
        
    SELECT    
        a.ppr_cd_pagamento_rota,    
        a.ppr_cd_periodo,    
        a.ppr_cd_rota,    
        a.ppr_cd_faixa_km,    
        a.ppr_ds_placa,    
        a.ppr_ds_tipo_veiculo,    
        a.ppr_ds_ciclo,    
        a.ppr_qt_faixa,    
        a.ppr_qt_paradas,    
        a.ppr_qt_pontos,    
        a.ppr_in_area_risco,   -- precisa trazer o dado da fixa de rota    
        a.ppr_in_ajudante,     -- precisa trazer o dado da fixa de rota    
        a.ppr_in_dom,          -- precisa trazer o dado da fixa de rota    
        a.ppr_in_fer,          -- precisa criar esta coluna na tabela tb_pgto_periodo_rota em produção    
        a.ppr_in_ambulancia,   -- precisa criar esta coluna na tabela tb_pgto_periodo_rota em produção    
        a.ppr_vl_base,    
        bfa_cd_base_frete_adicional_motorista,    
        a.ppr_base_principal,    
        a.ppr_total_km,    
        a.ppr_qt_pacotes_entregues,    
        regra_ambulancia,    
        zera_adicional_ambulancia,
        a.ppr_cd_desconto_sd,  
        a.ppr_in_zerar_rota,
        CASE WHEN a.ppr_in_dom = 1 or a.ppr_in_fer = 1 then 0 else 1 end ppr_dia_util, --Validação para saber se a rota é dia util ou domingo e feriado    
        case when bfa_tipo_adicional = 1 then bfa_vl_adicional * a.ppr_qt_paradas else bfa_vl_adicional end bfa_vl_adicional, --Corrigido para pegar os valores que pagam por parada    
        cast(0.00 as decimal(7,2)) AS ppr_vl_paradas,    
        cast(0.00 as decimal(7,2)) AS ppr_vl_faixa,    
        CASE     
            WHEN ad.tipo_risco = 1 and a.ppr_in_area_risco = 1 THEN (ad.vl_risco / 100) * a.ppr_vl_base    
            WHEN ad.tipo_risco = 2 and a.ppr_in_area_risco = 1 THEN ad.vl_risco    
            ELSE 0     
        END AS ppr_vl_risco,    
            
        CASE WHEN a.ppr_in_dom = 1 then    
        CASE     
                WHEN isnull(ad.bfa_tipo_adicional_ajudante_dom,ad.tipo_ajudante) = 1 /*AND a.ppr_in_ajudante = 1*/ THEN (isnull(ad.bfa_vl_adicional_ajudante_dom,ad.vl_ajudante) / 100) * a.ppr_vl_base    
                WHEN isnull(ad.bfa_tipo_adicional_ajudante_dom,ad.tipo_ajudante) = 2 /*AND a.ppr_in_ajudante = 1*/ THEN isnull(ad.bfa_vl_adicional_ajudante_dom,ad.vl_ajudante)
            ELSE 0     
        END     
            
        ELSE    
            CASE     
                WHEN ad.tipo_ajudante = 1 /*AND a.ppr_in_ajudante = 1*/ THEN (ad.vl_ajudante / 100) * a.ppr_vl_base    
                WHEN ad.tipo_ajudante = 2 /*AND a.ppr_in_ajudante = 1*/ THEN ad.vl_ajudante    
            ELSE 0     
        END     
        END AS ppr_vl_ajudante,    
        CASE    
            WHEN ad.tipo_domingo = 1 AND a.ppr_in_dom = 1 THEN (ad.vl_domingo / 100) * a.ppr_vl_base    
            WHEN ad.tipo_domingo = 2 AND a.ppr_in_dom = 1 THEN ad.vl_domingo    
            ELSE 0     
        END AS ppr_vl_dom,      
        CASE     
            WHEN ad.tipo_feriado = 1 AND a.ppr_in_fer = 1 THEN (ad.vl_feriado / 100) * a.ppr_vl_base    
            WHEN ad.tipo_feriado = 2 AND a.ppr_in_fer = 1 THEN ad.vl_feriado    
            ELSE 0     
        END AS ppr_vl_fer,    
        a.ppr_vl_insucessos, -- verificar regra de negócio para cada cliente    
        ad.ppr_vl_success_delivery,    
        CASE     
            WHEN ad.bfa_tipo_bonus_ds = 1 AND ad.ppr_vl_success_delivery >= ad.perc_ds AND ad.perc_ds > 0 THEN (ad.vl_bonus_ds / 100) * a.ppr_vl_base    
            WHEN ad.bfa_tipo_bonus_ds = 2 AND ad.ppr_vl_success_delivery >= ad.perc_ds AND ad.perc_ds > 0 THEN ad.vl_bonus_ds
            WHEN ad.bfa_tipo_bonus_ds = 3 AND ad.ppr_vl_success_delivery >= ad.perc_ds AND ad.perc_ds > 0 THEN ad.vl_bonus_ds * a.ppr_qt_pacotes_entregues   
            ELSE 0    
        END AS ppr_vl_bonus_ds,    
        NULL AS ppr_vl_bonus,    
        CASE     
            WHEN ad.tipo_desc_ciclo_pm = 1 AND a.ppr_ds_ciclo = 'PM' THEN (ad.vl_desc_ciclo_pm / 100) * a.ppr_vl_base    
            WHEN ad.tipo_desc_ciclo_pm = 2 AND a.ppr_ds_ciclo = 'PM' THEN ad.vl_desc_ciclo_pm    
            ELSE 0     
        END AS ppr_vl_pm, -- valor que precisa ser descontado do ppr_vl_base    
        pedagios.atp_dc_valor AS ppr_vl_pedagio,    
        NULL AS ppr_vl_aluguel,    
        NULL AS ppr_vl_desconto,    
        ad.vl_recarga AS ppr_vl_recarga,    
        cast(0 as decimal(10,2)) AS ppr_vl_pontos,  
        cast(0.00 as decimal(7,2)) as ppr_vl_pacotes,   
        NULL AS ppr_vl_desconto_flex_rota,          -- desconto de 10 reais do cartão flex na base de adicional (verificar anotação sobre flex)    
        NULL AS ppr_vl_desconto_cartao_flex_rota,   -- desconto total dos valores de cartão flex    
        NULL AS ppr_vl_adicional_km,    
        ad.bfa_tipo_adicional_faixa,    
        case    
            when ad.bfa_tipo_adicional_rota = 1 then ad.bfa_vl_adicional_rota    
            --when ad.bfa_tipo_adicional_rota = 2 then ad.bfa_vl_adicional_rota * a.ppr_qt_pacotes_entregues    
        else 0 end ppr_vl_rota,    
        isnull(ad.bfa_calcula_por_parada,1) bfa_calcula_por_parada,    
        case when isnull(ad.bfa_calcula_por_parada,1) = 1 then a.ppr_qt_paradas else a.ppr_qt_pontos end ppr_ponto_parada,
        cast(0 as decimal(10,2)) ppr_vl_ponto_parada
    
    INTO #tb_pgto_periodo_rota_calc    
    
    FROM    #tb_pgto_periodo_rota a    
    JOIN    adicionais ad    
            ON a.ppr_cd_periodo = ad.ppr_cd_periodo    
            AND a.ppr_cd_rota = ad.ppr_cd_rota    
            and a.ppr_cd_pagamento_rota = ad.ppr_cd_pagamento_rota    
    left    join (    
                    SELECT  atp_ds_rota    
         ,   atp_cd_codigo_cliente    
                        ,   sum(atp_dc_valor) as atp_dc_valor    
                    FROM    [tb_atm_pedagios] (NOLOCK)    
                    where   atp_in_excluido = 0    
             and atp_cd_codigo_status = 1    
        group   by  atp_ds_rota    
                            ,   atp_cd_codigo_cliente    
    ) pedagios    
            on cast(a.ppr_cd_rota as varchar(50)) = pedagios.atp_ds_rota    
   and pedagios.atp_cd_codigo_cliente = @clienteid    
            ;    
    
    
-- Documentação da coluna bfa_tipo_adicional_faixa    
--select *    
--from tb_lista    
--where lst_nm_lista = 'Tipos de calculos para pagamento de adicionais por faixa de ponto ou paradas.'    
      
    
    
    -- Calcula adicional de paradas calculado por qtd / faixa    
    UPDATE  a    
    SET     a.ppr_vl_ponto_parada = ISNULL(b.ppr_vl_paradas, 0)    
    FROM    #tb_pgto_periodo_rota_calc AS a    
    INNER JOIN (    
            SELECT    
                a.bfa_cd_base_frete_adicional_motorista,    
                a.ppr_cd_rota,    
                SUM(    
                    CASE     
                        WHEN ppr_ponto_parada >= bfa_fx_ini     
                            THEN ((case when ppr_ponto_parada < bfa_fx_fim then ppr_ponto_parada else bfa_fx_fim end) - case when bfa_fx_ini = 0 then bfa_fx_ini else bfa_fx_ini - 1 end) * bfa_fx_valor
                            --THEN ((case when ppr_ponto_parada < bfa_fx_fim then ppr_ponto_parada else bfa_fx_fim end) - bfa_fx_ini + 1) * bfa_fx_valor    
                        ELSE 0    
                    END    
                ) AS ppr_vl_paradas    
        FROM #tb_pgto_periodo_rota_calc AS a    
        INNER JOIN (    
            SELECT    
                bfp_cd_adcional_parada,    
                bfa_cd_adicional_motorista,    
                bfa_fx_ini,    
                bfa_fx_fim,    
                bfa_fx_valor,    
                bfa_tipo_valor,    
           bfa_dia_util    
            FROM #tb_parametro_paradas_km    
            --Apartando o tipo de calculo do adicional    
            where 
                bfa_tipo_valor = 3  
                and isnull(tipo_fx_1,1331) in (1331,1332) --considera apenas parada ou ponto
        ) AS adcParadaCalc    
            ON adcParadaCalc.bfa_cd_adicional_motorista = a.bfa_cd_base_frete_adicional_motorista    
                and (a.ppr_dia_util = adcParadaCalc.bfa_dia_util or adcParadaCalc.bfa_dia_util is null) -- Validação da regra ser paga apenas dia util ou domingo e feriado (Ser for nulo pagar todos os dias)    
        GROUP BY     
            bfa_cd_base_frete_adicional_motorista,     
            a.ppr_cd_rota    
    ) AS b    
        ON a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_base_frete_adicional_motorista    
        AND a.ppr_cd_rota = b.ppr_cd_rota    
    

      -- Calcula adicional de pontos calculado por qtd / faixa    
    UPDATE  a    
    SET     a.ppr_vl_pacotes = ISNULL(b.ppr_vl_pacotes, 0)    
    FROM    #tb_pgto_periodo_rota_calc AS a    
    INNER JOIN (    
            SELECT    
                a.bfa_cd_base_frete_adicional_motorista,    
                a.ppr_cd_rota,    
                SUM(    
                    CASE     
                        WHEN ppr_qt_pacotes_entregues >= bfa_fx_ini     
                            THEN ((case when ppr_qt_pacotes_entregues < bfa_fx_fim then ppr_qt_pacotes_entregues else bfa_fx_fim end) - case when bfa_fx_ini = 0 then bfa_fx_ini else bfa_fx_ini - 1 end) * bfa_fx_valor
                            --THEN ((case when ppr_qt_pacotes_entregues < bfa_fx_fim then ppr_qt_pacotes_entregues else bfa_fx_fim end) - bfa_fx_ini + 1) * bfa_fx_valor    
                        ELSE 0    
                    END    
                ) AS ppr_vl_pacotes    
        FROM #tb_pgto_periodo_rota_calc AS a    
        INNER JOIN (    
            SELECT    
                bfp_cd_adcional_parada,    
                bfa_cd_adicional_motorista,    
                bfa_fx_ini,    
                bfa_fx_fim,    
                bfa_fx_valor,    
                bfa_tipo_valor,    
           bfa_dia_util    
            FROM #tb_parametro_paradas_km    
            --Apartando o tipo de calculo do adicional    
            where 
                bfa_tipo_valor = 3  
                and tipo_fx_1 = 1333 --considera apenas pacotes
        ) AS adcPacotesCalc    
            ON adcPacotesCalc.bfa_cd_adicional_motorista = a.bfa_cd_base_frete_adicional_motorista    
                and (a.ppr_dia_util = adcPacotesCalc.bfa_dia_util or adcPacotesCalc.bfa_dia_util is null) -- Validação da regra ser paga apenas dia util ou domingo e feriado (Ser for nulo pagar todos os dias)    
        GROUP BY     
            bfa_cd_base_frete_adicional_motorista,     
            a.ppr_cd_rota    
    ) AS b    
        ON a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_base_frete_adicional_motorista    
        AND a.ppr_cd_rota = b.ppr_cd_rota    

    
    --Novo Calculo de frete     
    --faixa_fixa de ponto ou parada e faixa km    
    --esta etapa e para calcular     
    DROP TABLE IF EXISTS #vl_paradas;    
    select  *    
            ,    
            --valor fixo    
            case when bfa_tipo_valor = 2    
            then    
                case when ppr_ponto_parada >= bfa_fx_ini and ppr_ponto_parada <= bfa_fx_fim and (ppr_total_km >= bfa_fx_ini_2 and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)    
                    then bfa_fx_valor    
                else 0 end     
            --Calcula por pacote    
            when bfa_tipo_valor = 1    
            then    
                case when ppr_ponto_parada >= bfa_fx_ini and ppr_ponto_parada <= bfa_fx_fim and (ppr_total_km >= bfa_fx_ini_2 and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)    
                    then bfa_fx_valor * ppr_ponto_parada    
                else 0 end     
            end as ppr_vl_ponto_parada_novo    
    into    #vl_paradas         
    from    #tb_pgto_periodo_rota_calc as a    
    left    join #tb_parametro_paradas_km as b on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista    
            and (a.ppr_dia_util = b.bfa_dia_util or b.bfa_dia_util is null) -- Validação da regra ser paga apenas dia util ou domingo e feriado (Ser for nulo pagar todos os dias)    
      
    where   ppr_vl_base > 0    
            and     b.bfa_tipo_valor in (1,2)  
            and isnull(b.tipo_fx_1,1331) in (1331,1332) --considera apenas parada ou ponto
    
    
    
    --Calcula valor de pacote 
    drop table if exists #vl_pacotes
	select
		*
		,case
			when bfa_tipo_valor = 2 then
				case
					when ppr_qt_pacotes_entregues >= bfa_fx_ini and ppr_qt_pacotes_entregues <= bfa_fx_fim
						and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)
						then bfa_fx_valor
					else 0
				end
			when bfa_tipo_valor = 1 then
				case
					when ppr_qt_pacotes_entregues >= bfa_fx_ini and ppr_qt_pacotes_entregues <= bfa_fx_fim
						and ((ppr_total_km > bfa_fx_ini_2 -1) and ppr_total_km <= bfa_fx_fim_2 or bfa_fx_ini_2 is null)
						then bfa_fx_valor * ppr_qt_pacotes_entregues
					else 0
				end
		end as ppr_vl_pacote_novo
	    into #vl_pacotes
	from
		#tb_pgto_periodo_rota_calc as a
		left join #tb_parametro_paradas_km as b
			on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista
			and (a.ppr_dia_util = b.bfa_dia_util or b.bfa_dia_util is null)
	where
		ppr_vl_base > 0
		and b.bfa_tipo_valor in (1, 2)
		and b.tipo_fx_1 = 1333



    --Deletar casos que não entraram na regra    
    delete  #vl_paradas    
    where   ppr_vl_ponto_parada_novo = 0    
 
    delete  #vl_pacotes    
    where   ppr_vl_pacote_novo = 0    
    

    --atualiza o valor adicional    
    --UPDATE  a    
    --SET     a.ppr_vl_paradas = ISNULL(b.ppr_vl_paradas_novo, 0) + ISNULL(a.ppr_vl_paradas, 0)    
    --from    #tb_pgto_periodo_rota_calc as a    
    --inner   join #vl_paradas as b on a.ppr_cd_rota = b.ppr_cd_rota    
    UPDATE a
    SET a.ppr_vl_paradas = 
                            CASE 
                                WHEN a.bfa_calcula_por_parada = 1 
                                    THEN ISNULL(b.soma_paradas, 0) + ISNULL(a.ppr_vl_ponto_parada, 0)
                                ELSE 0
                            END
    ,   a.ppr_vl_pontos = 
                            CASE 
                                WHEN a.bfa_calcula_por_parada = 0 
                                    THEN ISNULL(b.soma_paradas, 0) + ISNULL(a.ppr_vl_ponto_parada, 0)
                                ELSE 0
                            END
    
    FROM    #tb_pgto_periodo_rota_calc AS a
	LEFT    JOIN (
			    SELECT ppr_cd_rota, SUM(ppr_vl_ponto_parada_novo) as soma_paradas
			    FROM #vl_paradas
			    GROUP BY ppr_cd_rota
		) AS b ON a.ppr_cd_rota = b.ppr_cd_rota
    
    
    -- Atualiza valor pacote
	update
		a
	set
		a.ppr_vl_pacotes = isnull(a.ppr_vl_pacotes,0) + isnull(b.soma_pacotes, 0)
	from
		#tb_pgto_periodo_rota_calc as a
		LEFT JOIN (
				SELECT ppr_cd_rota, SUM(ppr_vl_pacote_novo) as soma_pacotes
				FROM #vl_pacotes
				GROUP BY ppr_cd_rota
			) AS b ON a.ppr_cd_rota = b.ppr_cd_rota
    

    update #tb_pgto_periodo_rota_calc    
    set ppr_vl_paradas = isnull(ppr_vl_paradas,0) + case when bfa_calcula_por_parada = 1 then ppr_vl_rota + isnull(bfa_vl_adicional,0) else 0 end --Valor por faixa / valor adcional rota / valor adicional fixo
    ,   ppr_vl_pontos  = isnull(ppr_vl_pontos,0)  + case when bfa_calcula_por_parada = 0 then ppr_vl_rota + isnull(bfa_vl_adicional,0) else 0 end   
    ,ppr_vl_pacotes = isnull(ppr_vl_pacotes,0)
    


    DROP TABLE IF EXISTS #tb_pgto_periodo_rota_calc_tratado;    
    select  distinct *    
    into    #tb_pgto_periodo_rota_calc_tratado    
    from    #tb_pgto_periodo_rota_calc as a    
    
    
    
    --- Zerar valor adicional caso a rota for ambulancia    
    update  a    
    set     ppr_vl_paradas = 0  
        ,   ppr_vl_pontos  = 0
    from    #tb_pgto_periodo_rota_calc_tratado as a    
    where   ppr_in_ambulancia = 1    
            and regra_ambulancia is not null --Campo para considerar apenas bases com a regra de ambulancia aplicada    
    
    
    --- Zerar valor adicional para veiculos de Frota Fixa    
    update  a    
    set     ppr_vl_paradas = 0    
        ,   ppr_vl_pontos = 0
    from    #tb_pgto_periodo_rota_calc_tratado as a    
    inner   join tb_veiculos as b on a.ppr_ds_placa = b.vei_ds_placa     
            and b.vei_in_ativo = 1    
            and b.vei_valor_fixo is not null    
            and b.vei_cd_cliente in (68,66) --apenas Decargo    
    

    --- Zerar valor adicional para rotas de SAMEDAY    
    update  a    
    set     ppr_vl_paradas = 0   
        ,   ppr_vl_pontos = 0
    from    #tb_pgto_periodo_rota_calc_tratado as a    
    where   ppr_cd_desconto_sd = 1    
    
    
    
    -- Regra para zerar o adicional caso a rota for ambulancia e tiver definido para tb zerar os adicionais
    update  a
    set     ppr_vl_paradas      = 0
        ,   ppr_vl_pontos       = 0
        ,   ppr_vl_risco        = 0
        ,   ppr_vl_adicional_km = 0
        ,   ppr_vl_ajudante     = 0
        ,   ppr_vl_dom          = 0
        ,   ppr_vl_fer          = 0
        ,   ppr_vl_recarga      = 0
        ,   ppr_vl_bonus_ds     = 0
        ,   ppr_vl_pedagio      = 0
        ,   ppr_vl_pm           = 0
    from    #tb_pgto_periodo_rota_calc_tratado as a    
    where   ppr_in_ambulancia = 1    
            and zera_adicional_ambulancia = 1 


      --- Sera adicional se tiver editado a rota para ser zerada
    update  a
    set     ppr_vl_paradas      = 0
        ,   ppr_vl_pontos       = 0
        ,   ppr_vl_risco        = 0
        ,   ppr_vl_adicional_km = 0
        ,   ppr_vl_ajudante     = 0
        ,   ppr_vl_dom          = 0
        ,   ppr_vl_fer          = 0
        ,   ppr_vl_recarga      = 0
        ,   ppr_vl_bonus_ds     = 0
        ,   ppr_vl_pedagio      = 0
        ,   ppr_vl_pm           = 0
    from    #tb_pgto_periodo_rota_calc_tratado as a    
    where   ppr_in_zerar_rota = 1
    
    MERGE INTO tb_pgto_periodo_rota AS target    
    USING #tb_pgto_periodo_rota_calc_tratado AS source    
        ON target.ppr_cd_rota = source.ppr_cd_rota    
        AND target.ppr_cd_periodo = source.ppr_cd_periodo    
        and target.ppr_cd_pagamento_rota = source.ppr_cd_pagamento_rota    
    
    WHEN MATCHED THEN    
        UPDATE SET    
            --target.ppr_vl_faixa           = ISNULL(source.ppr_vl_faixa, 0),    
            target.ppr_vl_paradas         = ISNULL(source.ppr_vl_paradas, 0),    
            target.ppr_vl_pontos          = ISNULL(source.ppr_vl_pontos, 0),  
            target.ppr_vl_pacotes         = ISNULL(source.ppr_vl_pacotes, 0),  
            target.ppr_vl_risco           = source.ppr_vl_risco,    
            target.ppr_vl_adicional_km    = source.ppr_vl_adicional_km,    
            target.ppr_vl_ajudante        = source.ppr_vl_ajudante,    

            --alterado por Saulo Barros em 11/01/2026 para que o valor de feriado seja contabilizado no campo ppr_vl_dom_fer
            --target.ppr_vl_dom_fer         = source.ppr_vl_dom,    
            --target.ppr_vl_fer             = source.ppr_vl_fer,    
            target.ppr_vl_dom_fer         = case when source.ppr_vl_dom > 0 then source.ppr_vl_dom else source.ppr_vl_fer end,    
            target.ppr_vl_fer             = 0,
            --fim alteração

            target.ppr_vl_recarga         = source.ppr_vl_recarga,    
            target.ppr_vl_bonus_ds        = source.ppr_vl_bonus_ds,    
            target.ppr_vl_pedagio         = source.ppr_vl_pedagio,    
            target.ppr_vl_pm              = source.ppr_vl_pm;    
    
    
    
end 
GO
