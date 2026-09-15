-- ============================================================
-- BASELINE: dbo.UspSPEFinAtualizaAdicionais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEFinAtualizaAdicionais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UspSPEFinAtualizaAdicionais]
    @CodPeriodoPagamento INT,
    @idrota VARCHAR(50) = NULL
    --@usuarioIrisys int
AS
BEGIN
    SET NOCOUNT ON;



declare
      @IdTransportadora int
    --, @CodPeriodoPagamento int = 1040
	, @usuarioIrisys int
	--, @idrota varchar(50) = null
    , @data_inicial date
    , @data_final date
	, @clienteid int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	,@tipocontrato int = null



	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)



	if @idrota is not null
		begin
			set @usuarioIrisys = (select distinct UsuarioIrisys from vw_rotas_spe_v4 where codigorota = @idrota)
			set @Motorista = (select distinct Motorista from vw_rotas_spe_v4 where codigorota = @idrota)
		end

	set @IdTransportadora = (
							select cli_id_shopee
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)


	set @tipocontrato = (
							select pgp_cd_tipo_contratos
							from [tb_pgto_periodo] as a
							left join tb_clientes as b
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)



	set @IdCliTransportadora = (

						select lst_cd_lista from tb_lista
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'shopee'
						and lst_cd_cliente in (
												select pgp_cd_cliente
												from [tb_pgto_periodo] as a
												left join tb_clientes as b
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
												)
												)



	set @clienteid = (
						select pgp_cd_cliente
						from [tb_pgto_periodo] as a
						left join tb_clientes as b
						on a.pgp_cd_cliente = cli_cd_codigo_cliente
						where pgp_cd_periodo  = @CodPeriodoPagamento
						)


	declare @UtilizaContrato int = (
						select prm_ds_valor 
						from tb_parametros 
						where prm_ds_categoria = 'Financeiro - Pagamentos'
						and prm_nm_parametro = 'Utiliza contrato'
						and prm_cod_cliente = @clienteid
						)

    declare @RegraAdicionalDS int = (
						select prm_ds_valor 
						from tb_parametros 
						where prm_ds_categoria = 'Financeiro - Pagamentos'
						and prm_nm_parametro = 'Regra adicional DS'
						and prm_cod_cliente = @clienteid
						)

    set @RegraAdicionalDS = isnull(@RegraAdicionalDS,0)


-- Atualização do DS
update  tb_pgto_periodo_rota
set     ppr_vl_success_delivery =  CAST(ppr_qt_pacotes_entregues AS DECIMAL(10,2)) / NULLIF(ppr_qt_pacotes, 0)
WHERE   ppr_cd_periodo = @CodPeriodoPagamento;



--  Cria temp com cálculos
DROP TABLE IF EXISTS #tb_pgto_periodo_rota;
SELECT 
	r.ppr_cd_rota,
    r.ppr_data_referencia,
    r.ppr_cd_pagamento_rota,
    r.ppr_vl_base,
    r.ppr_vl_paradas,
    r.ppr_vl_total,
    r.ppr_ds_tipo_veiculo,
    r.ppr_cd_faixa_km,
    r.ppr_vl_total_km_real,
    r.ppr_vl_total_km_minimo,
    r.ppr_vl_total_km_prefatura,
    r.ppr_qt_pacotes,
    r.ppr_qt_pontos,
    r.ppr_qt_paradas,
    r.ppr_vl_success_delivery,
    r.ppr_qt_pacotes_entregues,
    adicional.bfa_cd_base_frete_adicional_motorista,
    r.ppr_in_dom,
    r.ppr_in_fer,
    r.ppr_in_sab,
    r.ppr_in_zerar_rota,

    adicional.bfa_adicional_pct_min,
    adicional.bfa_vl_pct_min,
    adicional.bfa_tipo_adicional_pct_min,

    adicional.bfa_perc_ds,
    adicional.bfa_tipo_bonus_ds,
    adicional.bfa_vl_bonus_ds,
    adicional.bfa_perc_sla,
    adicional.bfa_tipo_bonus_sla,
    adicional.bfa_vl_bonus_sla,



    -- adicionais
    CASE WHEN pre.rpre_in_risco = 1 then 
    CASE
        WHEN r.ppr_qt_pacotes_entregues < adicional.bfa_pacotes_min_adicional_risco THEN 0
        WHEN r.ppr_qt_pacotes_entregues > adicional.bfa_pacotes_max_adicional_risco THEN 0
        ELSE ISNULL(adicional.bfa_vl_adicional_risco,0) END 
    ELSE 0 END AS novo_vl_risco,
    CASE 
        WHEN r.ppr_qt_pacotes >= adicional.bfa_cd_pacote_ajudante THEN adicional.bfa_vl_adicional_ajudante
        ELSE 0 END AS novo_vl_ajudante,
    CASE
        WHEN adicional.bfa_tipo_adicional_ajudante = 1 AND r.ppr_qt_pacotes >= adicional.bfa_cd_pacote_ajudante
        THEN (adicional.bfa_vl_adicional_ajudante/100.0) * r.ppr_vl_base
        WHEN adicional.bfa_tipo_adicional_ajudante = 2 AND r.ppr_qt_pacotes >= adicional.bfa_cd_pacote_ajudante
        THEN adicional.bfa_vl_adicional_ajudante
        ELSE 0 END AS novo_vl_risco_ajudante,
    CASE 
        WHEN DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1 THEN 1 ELSE 0
        END AS novo_in_dom_fer,
    CASE
        WHEN adicional.bfa_tipo_adicional_domingo = 1 
             AND (DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1)
        THEN (adicional.bfa_vl_adicional_domingo/100.0) * r.ppr_vl_base
        WHEN adicional.bfa_tipo_adicional_domingo = 2 
             AND (DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1)
        THEN adicional.bfa_vl_adicional_domingo
        WHEN adicional.bfa_tipo_adicional_domingo = 3 --Pagar por pacote 
             AND (DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1)
        THEN adicional.bfa_vl_adicional_domingo * r.ppr_qt_pacotes
        ELSE 0 END AS novo_vl_dom_fer,
    
   
    CASE WHEN @RegraAdicionalDS = 1 --Considera quando a rota inicia e finaliza no mesmo dia
        THEN
            CASE 
                WHEN adicional.bfa_vl_bonus_ds IS NOT NULL
                 AND NULLIF(r.ppr_qt_pacotes_entregues,0) / CAST(NULLIF(r.ppr_qt_pacotes,0) AS DECIMAL(9,2)) >= bfa_perc_ds
                 AND r.ppr_qt_pacotes_entregues >= bfa_adicional_pct_min
                 --Regra que verifica se a rota iniciou e finalizou no mesmo dia
                 AND rt.CodigoRota is not null
                THEN adicional.bfa_vl_bonus_ds
            ELSE 0 
            END
        WHEN @RegraAdicionalDS = 0 --Sem regra de rotas no adiconal DS
        THEN 
            CASE 
                WHEN adicional.bfa_vl_bonus_ds IS NOT NULL
                 AND NULLIF(r.ppr_qt_pacotes_entregues,0) / CAST(NULLIF(r.ppr_qt_pacotes,0) AS DECIMAL(9,2)) >= bfa_perc_ds
                 AND r.ppr_qt_pacotes_entregues >= bfa_adicional_pct_min
                THEN adicional.bfa_vl_bonus_ds
            ELSE 0 
            END 
     END AS novo_vl_bonus_ds,
    
    -- Total 
    --ISNULL(r.ppr_vl_base,0) +
       ISNULL(adicional.bfa_vl_adicional_risco,0)
      --+ CASE WHEN r.ppr_qt_pacotes >= adicional.bfa_cd_pacote_ajudante THEN adicional.bfa_vl_adicional_ajudante ELSE 0 END
      --+ CASE
      --      WHEN adicional.bfa_tipo_adicional_domingo = 1 
      --           AND (DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1)
      --      THEN (adicional.bfa_vl_adicional_domingo/100.0) * r.ppr_vl_base
      --      WHEN adicional.bfa_tipo_adicional_domingo = 2 
      --           AND (DATEPART(weekday, r.ppr_data_referencia) = 1 OR ISNULL(dt.Feriado,0) = 1)
      --      THEN adicional.bfa_vl_adicional_domingo
      --      ELSE 0 END
      --+ CASE 
      --      WHEN adicional.bfa_vl_bonus_ds IS NOT NULL
      --       AND NULLIF(r.ppr_qt_pacotes_entregues,0) / CAST(NULLIF(r.ppr_qt_pacotes,0) AS DECIMAL(9,2)) = 1
      --      THEN adicional.bfa_vl_bonus_ds ELSE 0 END
      --+ ISNULL(r.ppr_vl_paradas,0)
      + ISNULL(r.ppr_vl_pedagio,0)
      + ISNULL(r.ppr_vl_aluguel,0)
      + ISNULL(r.ppr_vl_recarga,0)
      --+ ISNULL(r.ppr_vl_lancamentos,0)
      - ISNULL(r.ppr_vl_desconto,0) AS novo_vl_paradas
INTO    #tb_pgto_periodo_rota
FROM    tb_pgto_periodo_rota r
INNER   JOIN tb_pag_espelhos b ON r.ppr_cd_motorista_nfs = b.mtn_cd_motorista_nfs
LEFT    JOIN tb_motorista mot ON b.mtn_cd_motorista = mot.mot_cd_usuario
LEFT    JOIN tb_dra_tipo_veiculo vic ON r.ppr_ds_tipo_veiculo = vic.tvl_nm_tipo_veiculo
LEFT    JOIN (
                SELECT  tfd_cd_cliente idtransportadora, bss_ds_sigla servicecenter, a.Data, 1 Feriado
                FROM    DimData a
                INNER   JOIN tb_feriados b ON a.data = b.tfd_dh_feriado
                LEFT    JOIN tb_bases c ON c.bss_cod_cliente = tfd_cd_cliente
                                        AND (c.bss_ds_estado = tfd_ds_estado OR tfd_ds_municipio = c.bss_ds_cidade OR tfd_tipo_feriado = 'Nacional')
                WHERE   tfd_in_excluido = 0
            ) dt ON r.ppr_data_referencia = dt.Data
                AND b.mtn_cod_cliente = dt.idtransportadora
                AND r.ppr_base_principal = dt.servicecenter
LEFT    JOIN tb_fin_base_frete_adicional_motorista adicional
            ON b.mtn_cod_cliente = adicional.bfa_cd_transportadora
              AND ISNULL(r.ppr_base_principal,'') = adicional.bfa_cd_service_center
              AND vic.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
              AND (r.ppr_nm_cidade = adicional.bfa_nm_cidade OR adicional.bfa_nm_cidade IS NULL OR adicional.bfa_nm_cidade = '')
      
            --AND ISNULL(mot.mot_ctn_cd_tipo_contrato,-1) = ISNULL(adicional.bfa_cd_tipo_contrato,-1)
              and (
				        (@UtilizaContrato = 1 and ISNULL(mot.mot_ctn_cd_tipo_contrato,-1) = ISNULL(adicional.bfa_cd_tipo_contrato,-1))
				        or
				        @UtilizaContrato = 0
		        )


              AND r.ppr_data_referencia BETWEEN adicional.bfa_data_inicio_vigencia 
                                    AND ISNULL(adicional.bfa_data_fim_vigencia, DATEADD(YEAR,1,GETDATE()))
LEFT    JOIN tb_spe_fin_rota_prefatura as pre on r.ppr_data_referencia = pre.rpre_dt_data and r.ppr_cd_rota = pre.rpre_cd_rota

--left join utilizado para identificar se a rota foi finalizada no mesmo dia. Utilizado isso na regra de bonus DS
LEFT    JOIN tb_spe_rotas_v5 as rt with(nolock)
            ON r.ppr_cd_rota = rt.CodigoRota
             and rt.IdTransportadora = @IdTransportadora
             and r.ppr_data_referencia = rt.DataReferencia
             and CAST(DataHoraInicio AS DATE) = CAST(DataUltimaEntrega AS DATE)
             and rt.Excluido = 0

WHERE   r.ppr_cd_periodo = @CodPeriodoPagamento
        AND (@idrota IS NULL OR r.ppr_cd_rota = @idrota);


   
    -- Dias uteis
    alter table #tb_pgto_periodo_rota add ppr_vl_faixa decimal(10,2)
    update  a
    set     ppr_vl_faixa = case when ppr_vl_success_delivery > bfa_perc_ds then
                            case when ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim then bfa_fx_valor end
                            else 0 end

    from    #tb_pgto_periodo_rota as a
    inner   join tb_fin_base_frete_adicional_motorista_parada as b 
            on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista            
    where   ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim
            and (ppr_in_dom = 0 or ppr_in_fer = 0 or ppr_in_sab = 0)
            and bfa_dia_util = 1

    -- Sabado, Domingo e Feriado (Feriados não cadastrados para o cliente)
    update  a
    set     ppr_vl_faixa = case when ppr_vl_success_delivery > bfa_perc_ds then
                            case when ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim then bfa_fx_valor end
                            else 0 end
    from    #tb_pgto_periodo_rota as a
    inner   join tb_fin_base_frete_adicional_motorista_parada as b 
            on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista           
    where   ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim
            and (ppr_in_dom = 1 or ppr_in_fer = 1 or ppr_in_sab = 1)
            and bfa_dia_util = 0

    -- Não aplica a regra de dias uteis
    update  a
    set     ppr_vl_faixa = case when ppr_vl_success_delivery > bfa_perc_ds then
                            case when ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim then bfa_fx_valor end
                            else 0 end
    from    #tb_pgto_periodo_rota as a
    inner   join tb_fin_base_frete_adicional_motorista_parada as b 
            on a.bfa_cd_base_frete_adicional_motorista = b.bfa_cd_adicional_motorista           
    where   ppr_qt_pacotes_entregues between bfa_fx_ini and bfa_fx_fim
            and bfa_dia_util is null


    -- Calcula - se 1,50 por pct acima de 150 entregues
    alter table #tb_pgto_periodo_rota add ppr_vl_adicional_pct_min decimal(10,2)
    update  a
    set     ppr_vl_adicional_pct_min = case when bfa_tipo_adicional_pct_min = 1 --Valor Fixo
                                            then bfa_vl_pct_min
                                            when bfa_tipo_adicional_pct_min = 2 --Valor Por pacote (diferença)
                                            then (ppr_qt_pacotes_entregues - bfa_adicional_pct_min) * bfa_vl_pct_min
                                            end
    from    #tb_pgto_periodo_rota as a
    where   bfa_adicional_pct_min is not null
            and ppr_qt_pacotes_entregues > bfa_adicional_pct_min


    --Acima de 98 %  aplica o bônus de DS R$ 0,20 SLA R$ 0,10
    --alter table #tb_pgto_periodo_rota add ppr_vl_bonus_ds decimal(10,2)
    --update  a
    --                            -- O valaor vai ser aplicado por pacote entregue?
    --set     ppr_vl_bonus_ds = case when ppr_vl_success_delivery > bfa_perc_ds then bfa_vl_bonus_ds end
    --from    #tb_pgto_periodo_rota as a
    --where   bfa_perc_ds is not null

    --alter table #tb_pgto_periodo_rota add ppr_vl_bonus_sla decimal(10,2)
    --update  a
    --                            -- O valaor vai ser aplicado por pacote entregue?
    --set     ppr_vl_bonus_sla = case when ppr_vl_sla > bfa_perc_sla then bfa_vl_bonus_sla end
    --from    #tb_pgto_periodo_rota as a
    --where   bfa_perc_sla is not null

    -- Atualiza campo de adicionais
    update  #tb_pgto_periodo_rota
    set     ppr_vl_paradas = novo_vl_paradas + isnull(ppr_vl_faixa,0) + isnull(ppr_vl_adicional_pct_min,0) --+ isnull(ppr_vl_bonus_ds,0) -- + isnull(ppr_vl_bonus_sla.0)

    --Atualiza campo do valor total
    update  #tb_pgto_periodo_rota
    set     ppr_vl_total = ISNULL(ppr_vl_paradas,0) + ISNULL(ppr_vl_base,0)


-- Zera adicional se tiver editado a rota para ser zerada
UPDATE 
    #tb_pgto_periodo_rota
SET 
    novo_vl_risco = 0
    ,novo_vl_ajudante = 0
    ,novo_vl_risco_ajudante = 0
    ,novo_in_dom_fer = 0
    ,novo_vl_dom_fer = 0
    ,novo_vl_bonus_ds = 0
    ,ppr_vl_paradas = 0
    ,ppr_vl_total = ppr_vl_base
where
    ppr_in_zerar_rota = 1


-- Atualiza valores
UPDATE r
SET r.ppr_vl_risco       = c.novo_vl_risco,
    r.ppr_vl_ajudante    = c.novo_vl_ajudante,
    r.ppr_lcto_vl_risco_ajudante = c.novo_vl_risco_ajudante,
    r.ppr_in_dom_fer     = c.novo_in_dom_fer,
    r.ppr_vl_dom_fer     = c.novo_vl_dom_fer,
    r.ppr_vl_bonus_ds    = c.novo_vl_bonus_ds,
    r.ppr_vl_paradas     = c.ppr_vl_paradas,
    r.ppr_vl_total       = c.ppr_vl_total
FROM tb_pgto_periodo_rota r
JOIN #tb_pgto_periodo_rota c ON r.ppr_cd_pagamento_rota = c.ppr_cd_pagamento_rota;



END
GO
