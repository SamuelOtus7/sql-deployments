-- ============================================================
-- BASELINE: dbo.UspFinAplicaRegrasFinanceiro
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAplicaRegrasFinanceiro]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[UspFinAplicaRegrasFinanceiro]
(
    @CodPeriodoPagamento int
    ,@FaseExecucao int = 1
    ,@IdRota int = null
    ,@CodEspelho int = null
    ,@CodUsuario int = null
)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- INFORMAÇÕES SOBRE O PERÍODO QUE ESTÁ SENDO PROCESSADO
    ------------------------------------------------------------
    declare @CodigoCliente int
    declare @DataInicial date
    declare @DataFinal date

    select
        @CodigoCliente = pgp_cd_cliente
        ,@DataInicial = pgp_dt_inicio
        ,@DataFinal = pgp_dt_fim
    from tb_pgto_periodo with (nolock)
    where pgp_cd_periodo = @CodPeriodoPagamento

    declare @Operacao int = (
        select lst_cd_lista
        from tb_lista as a with (nolock)
        join tb_pgto_periodo as b with (nolock)
            on a.lst_cd_cliente = b.pgp_cd_cliente
            and a.lst_cd_lista = b.pgp_tipo_operacao
        where lst_nm_lista = 'Operações Marketplace'
            and pgp_cd_periodo = @CodPeriodoPagamento
    )

    declare @IdCliTransportadora int = (
        select lst_cd_lista
        from tb_lista (nolock)
        where lst_nm_lista = 'Clientes transportadoras'
            and lst_ds_label = 'Mercado Livre'
            and lst_cd_cliente = @CodigoCliente
    )

    ------------------------------------------------------------
    -- VARIÁVEIS PARA O LOOP DE REGRAS
    ------------------------------------------------------------
    declare @CodigoRegra int
    declare @TipoRegra varchar(50)
    declare @TipoContrato int
    declare @ServiceCenter varchar(50)
    declare @TipoVeiculo int
    declare @NomeCriterio1 varchar(30)
    declare @ValorCriterio1 varchar(60)
    declare @NomeCriterio2 varchar(30)
    declare @ValorCriterio2 varchar(60)
    declare @NomeCriterio3 varchar(30)
    declare @ValorCriterio3 varchar(60)
    declare @NomeAcao1 varchar(30)
    declare @ValorAcao1 varchar(60)
    declare @NomeAcao2 varchar(30)
    declare @ValorAcao2 varchar(60)
    declare @NomeAcao3 varchar(30)
    declare @ValorAcao3 varchar(60)

    -- Variáveis da regra DESCONTO_DS_PROPORCIONAL
    declare @PercDSMinimoZera decimal(5,4)
    declare @PercDSIntegral decimal(5,4)
    declare @PercMinimoVisitas decimal(5,4)

    -- Variáveis da regra BONUS_DS
    declare @PercDSBonus decimal(5,4)
    declare @MinimoDiasRodados int
    declare @PercDSAcumulado decimal(5,4)
    declare @VlBonusSpot985 decimal(10,2)
    declare @VlBonusSpot100 decimal(10,2)
    declare @VlBonusFrotaFixaQuinzenal decimal(10,2)

    -- Variáveis da regra SDD_DS
    declare @PercDSSDD decimal(5,4)
    declare @VlSDDVanUtil decimal(10,2)
    declare @VlSDDVuc decimal(10,2)

    ------------------------------------------------------------
    -- TEMP TABLE: rotas do período (somente leitura base)
    -- Carrega uma vez; as regras atualizam esta temp;
    -- no final, um único UPDATE persiste na tabela original
    ------------------------------------------------------------
    drop table if exists #rotas_periodo

    select
        a.ppr_cd_pagamento_rota
        ,a.ppr_cd_periodo
        ,a.ppr_cd_rota
        ,a.ppr_data_referencia
        ,a.ppr_base_principal
        ,a.ppr_ds_tipo_veiculo
        ,a.ppr_total_km
        ,a.ppr_nm_origem_km
        ,a.ppr_in_area_risco
        ,a.ppr_cd_desconto_sd
        ,a.ppr_in_excluido
        ,a.ppr_vl_base
        ,a.ppr_vl_base_calculado
        ,a.ppr_vl_desconto
        ,a.ppr_id_transportadora
        ,a.ppr_in_zerar_rota
        ,a.ppr_in_calcular_adicional
        ,a.ppr_motivo_rota_zerada
        ,a.ppr_vl_success_delivery
        ,a.ppr_qt_pacotes
        ,a.ppr_qt_pacotes_entregues
        ,a.ppr_per_endereco_nao_visitado
        ,a.ppr_in_dom
        ,a.ppr_in_sab
        ,a.ppr_in_fer
        ,a.ppr_vl_bonus_ds
        ,a.ppr_vl_paradas
        ,a.ppr_vl_ajudante
        ,a.ppr_vl_risco
        ,a.ppr_vl_dom
        ,a.ppr_vl_fer
        ,a.ppr_cd_desconto_ds
        ,a.ppr_ds_placa
        ,a.ppr_cd_motorista_nfs
        ,a.ppr_cd_pgto_espelho
        ,a.ppr_cd_tipo_pgto
        ,a.ppr_nome_motorista
        ,a.ppr_vl_bonus
    into #rotas_periodo
    from tb_pgto_periodo_rota as a with (nolock)
    where a.ppr_cd_periodo = @CodPeriodoPagamento
        and a.ppr_in_excluido = 0

    ------------------------------------------------------------
    -- CARREGA AS REGRAS ATIVAS E VIGENTES DA FASE SOLICITADA
    ------------------------------------------------------------
    drop table if exists #regras_financeiro

    select *
    into #regras_financeiro
    from tb_fin_regras_financeiro with (nolock)
    where rlf_cd_codigo_cliente = @CodigoCliente
        and rlf_cd_cli_transportadora = @IdCliTransportadora
        and rlf_cd_operacao = @Operacao
        and rlf_nr_fase_execucao = @FaseExecucao
        and rlf_int_ativo = 1
        and @DataInicial between rlf_data_inicio_vigencia
            and isnull(rlf_data_fim_vigencia, cast(getdate() as date))

    ------------------------------------------------------------
    -- LOOP: WHILE EXISTS + SELECT TOP 1 + DELETE
    ------------------------------------------------------------
    while exists (select 1 from #regras_financeiro)
    begin
        select top 1
            @CodigoRegra = rlf_cd_regras_financeiro
            ,@TipoRegra = rlf_nm_tipo_regra
            ,@TipoContrato = rlf_cd_tipo_contrato
            ,@ServiceCenter = rlf_cd_service_center
            ,@TipoVeiculo = rlf_cd_tipo_veiculo
            ,@NomeCriterio1 = rlf_nm_criterio01
            ,@ValorCriterio1 = rlf_vl_criterio01
            ,@NomeCriterio2 = rlf_nm_criterio02
            ,@ValorCriterio2 = rlf_vl_criterio02
            ,@NomeCriterio3 = rlf_nm_criterio03
            ,@ValorCriterio3 = rlf_vl_criterio03
            ,@NomeAcao1 = rlf_nm_acao01
            ,@ValorAcao1 = rlf_vl_acao01
            ,@NomeAcao2 = rlf_nm_acao02
            ,@ValorAcao2 = rlf_vl_acao02
            ,@NomeAcao3 = rlf_nm_acao03
            ,@ValorAcao3 = rlf_vl_acao03
        from #regras_financeiro

        ------------------------------------------------------------
        -- IF POR TIPO DE REGRA
        ------------------------------------------------------------

        --======================================================
        -- FASE 1 — REGRA: SOBRESCRITA_KM
        --======================================================
        if @TipoRegra = 'SOBRESCRITA_KM'
        begin
            update a
            set
                a.ppr_total_km = b.KmTotal
                ,a.ppr_nm_origem_km = @ValorAcao3
            from #rotas_periodo as a
            join tb_ml_rotas as b with (nolock)
                on a.ppr_cd_rota = b.IdRota
                and a.ppr_data_referencia = b.DataReferencia
            join tb_dra_tipo_veiculo as tv with (nolock)
                on tv.tvl_cd_tipo_veiculo = @TipoVeiculo
                and tv.tvl_nm_tipo_veiculo = a.ppr_ds_tipo_veiculo
            where a.ppr_base_principal = @ServiceCenter
                and b.KmTotal is not null
        end --fim SOBRESCRITA_KM

        --======================================================
        -- FASE 2 — REGRA: AREA_RISCO
        --======================================================
        if @TipoRegra = 'AREA_RISCO'
        begin
            update a
            set a.ppr_in_area_risco = cast(@ValorAcao1 as bit)
            from #rotas_periodo as a
            where a.ppr_base_principal = @ServiceCenter
                and (
                    @NomeCriterio1 is null
                    or (
                        @NomeCriterio1 = 'DescontoSD'
                        and isnull(a.ppr_cd_desconto_sd, 0) = cast(isnull(@ValorCriterio1, 0) as int)
                    )
                )
        end --fim AREA_RISCO

        --======================================================
        -- FASE 3a — REGRA: ZERAR_ROTA_DS_BAIXO
        --======================================================
        if @TipoRegra = 'ZERAR_ROTA_DS_BAIXO'
        begin
            update a
            set
                a.ppr_vl_base = 0
                ,a.ppr_in_zerar_rota = 1
                ,a.ppr_motivo_rota_zerada = isnull(@ValorAcao2, 'DS abaixo do limite')
            from #rotas_periodo as a
            join tb_ml_rotas as b with (nolock)
                on a.ppr_cd_rota = b.IdRota
                and a.ppr_data_referencia = b.DataReferencia
            where b.TotalPacotes > 0
                and (cast(b.PacotesEntregues as decimal(10,4)) / b.TotalPacotes) < cast(isnull(@ValorCriterio1, '0.90') as decimal(5,4))
                and (@ServiceCenter is null or a.ppr_base_principal = @ServiceCenter)
                and not exists (
                    select 1
                    from tb_fin_prefatura pf with (nolock)
                    where pf.IdRota = a.ppr_cd_rota
                        and pf.IdTransportadora = a.ppr_id_transportadora
                )
        end --fim ZERAR_ROTA_DS_BAIXO

        --======================================================
        -- FASE 3b — REGRA: DESCONTO_DS_PROPORCIONAL
        -- DS (Delivery Success) com 3 faixas:
        --   DS < 50%: desconto total (não recebe frete)
        --   DS 50-95%: desconto proporcional ao DS (se regra de
        --             visitas atendida), senão desconto total
        --   DS >= 95%: sem desconto (frete integral)
        --
        -- O valor base (ppr_vl_base) NÃO é alterado.
        -- O desconto é registrado em ppr_vl_desconto (negativo)
        -- e o motivo em ppr_motivo_rota_zerada.
        --
        -- Critérios:
        --   @ValorCriterio1 = PercentualDSMinimoZera (0.50)
        --   @ValorCriterio2 = PercentualDSIntegral (0.95)
        --   @ValorCriterio3 = PercentualMinimoVisitas (0.90)
        --======================================================
        if @TipoRegra = 'DESCONTO_DS_PROPORCIONAL'
        begin
            set @PercDSMinimoZera = cast(isnull(@ValorCriterio1, '0.50') as decimal(5,4))
            set @PercDSIntegral = cast(isnull(@ValorCriterio2, '0.95') as decimal(5,4))
            set @PercMinimoVisitas = 0.10--cast(isnull(@ValorCriterio3, '0.90') as decimal(5,4))

            update a
            set
                -- Desconto (negativo): ppr_vl_base não é alterado
                a.ppr_vl_desconto = case
                    -- DS < 50%: desconto total
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSMinimoZera
                        then -isnull(a.ppr_vl_base, 0)
                    -- DS 50-95%: desconto proporcional ou total
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSIntegral
                        then case
                            -- Regra de visitas atendida: desconto proporcional
                            when isnull(a.ppr_per_endereco_nao_visitado, 1) >= @PercMinimoVisitas
                                then -(a.ppr_vl_base * (1 - isnull(a.ppr_vl_success_delivery,
                                    case when a.ppr_qt_pacotes > 0
                                    then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                                    else 1 end)))
                            -- Regra de visitas NÃO atendida: desconto total
                            else -isnull(a.ppr_vl_base, 0)
                        end
                    -- DS >= 95%: sem desconto
                    else 0
                end
                ,a.ppr_in_zerar_rota = case
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSMinimoZera
                        then 1
                    -- DS 50-95% com Not Visit nao atendida: zera rota
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSIntegral
                        and isnull(a.ppr_per_endereco_nao_visitado, 1) < @PercMinimoVisitas
                        then 1
                    else a.ppr_in_zerar_rota
                end
                ,a.ppr_in_calcular_adicional = case
                    -- DS < 50%: nao calcula adicional
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSMinimoZera
                        then 0
                    -- DS 50-95% com Not Visit nao atendida: nao calcula adicional
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSIntegral
                        and isnull(a.ppr_per_endereco_nao_visitado, 1) < @PercMinimoVisitas
                        then 0
                    else a.ppr_in_calcular_adicional
                end
                ,a.ppr_motivo_rota_zerada = case
                    -- DS < 50%: rota zerada
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSMinimoZera
                        then isnull(@ValorAcao2, 'DS abaixo de 50% - rota zerada')
                    -- DS 50-95% com visitas atendidas: proporcional
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSIntegral
                        then case
                            when isnull(a.ppr_per_endereco_nao_visitado, 1) >= @PercMinimoVisitas
                                then 'DS proporcional aplicado'
                            else 'DS abaixo de 95% e visitas nao atendidas - rota zerada'
                        end
                    -- DS >= 95%: sem desconto
                    else a.ppr_motivo_rota_zerada
                end
                ,a.ppr_cd_desconto_ds = case
                    when isnull(a.ppr_vl_success_delivery,
                        case when a.ppr_qt_pacotes > 0
                        then cast(a.ppr_qt_pacotes_entregues as decimal(10,4)) / a.ppr_qt_pacotes
                        else 1 end) < @PercDSIntegral
                        then 1
                    else 0
                end
            from #rotas_periodo as a
            where a.ppr_vl_success_delivery is not null
                or a.ppr_qt_pacotes > 0
                and isnull(a.ppr_in_zerar_rota, 0) = 0
        end --fim DESCONTO_DS_PROPORCIONAL

        --======================================================
        -- REGRA: NOT_VISIT
        -- Zera a rota se o percentual de enderecos visitados
        -- for inferior ao minimo configurado (90%).
        -- Aplica-se a todos os dias (normais, sabados, domingos
        -- e feriados) sem excecao.
        -- Regra independente do DS.
        --
        -- Criterios:
        --   @ValorCriterio1 = PercentualMinimoVisitas (0.90)
        -- Acoes:
        --   @ValorAcao2 = Motivo
        --======================================================
        if @TipoRegra = 'NOT_VISIT'
        begin
            set @PercMinimoVisitas = 0.10 --cast(isnull(@ValorCriterio1, '0.90') as decimal(5,4))

            update a
            set
                a.ppr_vl_desconto = -isnull(a.ppr_vl_base, 0)
                ,a.ppr_in_zerar_rota = 1
                ,a.ppr_in_calcular_adicional = 0
                ,a.ppr_motivo_rota_zerada = isnull(@ValorAcao2, 'Not Visit - acima de 90% de enderecos não visitados')
                ,a.ppr_cd_desconto_sd = 1
            from #rotas_periodo as a
            where isnull(a.ppr_per_endereco_nao_visitado, 1) < @PercMinimoVisitas
                and isnull(a.ppr_in_zerar_rota, 0) = 0
                and isnull(a.ppr_vl_base, 0) > 0

        end --fim NOT_VISIT

        --======================================================
        -- FASE 4 — REGRA: BONUS_DS
        -- Bônus de desempenho DS:
        --   Spot DS >= 98,5%: R$ 10/rota
        --   Spot DS = 100%: +R$ 10/rota (cumulativo)
        --   Frota Fixa rota 100%: R$ 10/rota
        --   Frota Fixa quinzenal: R$ 130/motorista+placa
        --     (mínimo 13 dias rodados e DS acumulado >= 98,5%)
        --     inserido como linha adicional (tipo_pgto = 1363)
        --
        -- Critérios:
        --   @ValorCriterio1 = PercentualDSBonus (0.985)
        --   @ValorCriterio2 = MinimoDiasRodados (13)
        --   @ValorCriterio3 = PercentualDSAcumulado (0.985)
        -- Ações:
        --   @ValorAcao1 = BonusSpot985 (10.00)
        --   @ValorAcao2 = BonusSpot100 (10.00)
        --   @ValorAcao3 = BonusFrotaFixaQuinzenal (130.00)
        --======================================================
        if @TipoRegra = 'BONUS_DS'
        begin
            set @PercDSBonus = cast(isnull(@ValorCriterio1, '0.985') as decimal(5,4))
            set @MinimoDiasRodados = cast(isnull(@ValorCriterio2, '13') as int)
            set @PercDSAcumulado = cast(isnull(@ValorCriterio3, '0.985') as decimal(5,4))
            set @VlBonusSpot985 = cast(isnull(@ValorAcao1, '10.00') as decimal(10,2))
            set @VlBonusSpot100 = cast(isnull(@ValorAcao2, '10.00') as decimal(10,2))
            set @VlBonusFrotaFixaQuinzenal = cast(isnull(@ValorAcao3, '130.00') as decimal(10,2))

            -- Passo 0: Zera bonus_ds de rotas zeradas (evita manter valor de processamento anterior)
            update #rotas_periodo
            set ppr_vl_bonus_ds = 0
            where isnull(ppr_in_zerar_rota, 0) = 1

            -- Passo 1: Bônus por rota (Spot e Frota Fixa)
            -- Identifica Frota Fixa por tipo de veículo OU placa com valor fixo
            --
            -- Veículos Frota Fixa (16 tipos):
            --   Utilitário Localiza 2025, Utilitário TKS 2025,
            --   Melione Rental Utilitário com Ajudante,
            --   Frota Fixa Large Master, Frota Fixa Large Van Ford,
            --   Frota Fixa Large Van Ford Auto, Van TKS 2025, Van Vamos 2025 H2,
            --   MeliOne Van Frota Fixa, Melione Van TKS 2025,
            --   Van Frota Fixa - Equipe dupla,
            --   VUC DEDICADO COM AJUDANTE, VUC Dedicado com Ajudante,
            --   Vuc TKS 2025, Vuc Vamos 2025, Vuc Vamos 2025 H2,
            --   Melione Vuc Vamos 2025
            update a
            set a.ppr_vl_bonus_ds = case
                -- Veículos SDD: não recebem BONUS_DS (apenas SDD_DS)
                when a.ppr_ds_tipo_veiculo in ('Utilitários SDD','Van SDD','Vuc SDD','HR SDD')
                    then 0
                -- Spot: DS >= 98,5% ganha R$ 10; DS = 100% ganha +R$ 10 (cumulativo)
                -- Exclui Frota Fixa e veículos SDD
                when a.ppr_ds_tipo_veiculo not in (
                    'Utilitário Localiza 2025','Utilitário TKS 2025',
                    'Melione Rental Utilitário com Ajudante',
                    'Frota Fixa Large Master','Frota Fixa Large Van Ford',
                    'Frota Fixa Large Van Ford Auto','Van TKS 2025','Van Vamos 2025 H2',
                    'MeliOne Van Frota Fixa','Melione Van TKS 2025',
                    'Van Frota Fixa - Equipe dupla',
                    'VUC DEDICADO COM AJUDANTE','VUC Dedicado com Ajudante',
                    'Vuc TKS 2025','Vuc Vamos 2025','Vuc Vamos 2025 H2',
                    'Melione Vuc Vamos 2025'
                ) and not exists (
                    select 1 from tb_veiculos v with (nolock)
                    where v.vei_ds_placa = a.ppr_ds_placa
                        and v.vei_valor_fixo is not null
                        and v.vei_valor_fixo > 0
                )
                then case
                    when isnull(a.ppr_vl_success_delivery, 1) >= @PercDSBonus
                        then @VlBonusSpot985 + case
                            when isnull(a.ppr_vl_success_delivery, 1) >= 1.0
                            then @VlBonusSpot100
                            else 0
                        end
                    else 0
                end
                -- Frota Fixa: DS = 100% ganha R$ 10/rota
                else case
                    when isnull(a.ppr_vl_success_delivery, 0) >= 1.0
                        then @VlBonusSpot100
                    else 0
                end
            end
            from #rotas_periodo as a
            where a.ppr_cd_tipo_pgto = 1362
                and (a.ppr_vl_success_delivery is not null or a.ppr_qt_pacotes > 0)
                and isnull(a.ppr_in_zerar_rota, 0) = 0

            -- Passo 2: Bônus quinzenal Frota Fixa
            -- Agrega por motorista+placa, calcula dias rodados e DS acumulado
            -- Se elegível, faz upsert via MERGE (insert/update/delete)
            -- Linha adicional: tipo_pgto = 1363, ppr_lcto_tipo = 'Bonus DS Quinzenal'

            ;with frota_fixa_agg as (
                select
                    r.ppr_cd_motorista_nfs
                    ,r.ppr_cd_pgto_espelho
                    ,r.ppr_base_principal
                    ,r.ppr_ds_placa
                    ,r.ppr_ds_tipo_veiculo
                    ,r.ppr_id_transportadora
                    ,r.ppr_nome_motorista
                    ,count(distinct r.ppr_data_referencia) as dias_rodados
                    ,case when sum(r.ppr_qt_pacotes) > 0
                        then cast(sum(r.ppr_qt_pacotes_entregues) as decimal(10,4)) / sum(r.ppr_qt_pacotes)
                        else 0
                    end as ds_acumulado
                from #rotas_periodo as r
                where r.ppr_cd_tipo_pgto = 1362
                    and (
                        r.ppr_ds_tipo_veiculo in (
                            'Utilitário Localiza 2025','Utilitário TKS 2025',
                            'Melione Rental Utilitário com Ajudante',
                            'Frota Fixa Large Master','Frota Fixa Large Van Ford',
                            'Frota Fixa Large Van Ford Auto','Van TKS 2025','Van Vamos 2025 H2',
                            'MeliOne Van Frota Fixa','Melione Van TKS 2025',
                            'Van Frota Fixa - Equipe dupla',
                            'VUC DEDICADO COM AJUDANTE','VUC Dedicado com Ajudante',
                            'Vuc TKS 2025','Vuc Vamos 2025','Vuc Vamos 2025 H2',
                            'Melione Vuc Vamos 2025'
                        )
                        or exists (
                            select 1 from tb_veiculos v with (nolock)
                            where v.vei_ds_placa = r.ppr_ds_placa
                                and v.vei_valor_fixo is not null
                                and v.vei_valor_fixo > 0
                        )
                    )
                group by r.ppr_cd_motorista_nfs, r.ppr_cd_pgto_espelho, r.ppr_base_principal,
                    r.ppr_ds_placa, r.ppr_ds_tipo_veiculo, r.ppr_id_transportadora, r.ppr_nome_motorista
            )
            merge tb_pgto_periodo_rota as t
            using (
                select
                    ff.ppr_cd_motorista_nfs
                    ,ff.ppr_cd_pgto_espelho
                    ,ff.ppr_base_principal
                    ,ff.ppr_ds_placa
                    ,ff.ppr_ds_tipo_veiculo
                    ,ff.ppr_id_transportadora
                    ,ff.ppr_nome_motorista
                    ,ff.dias_rodados
                    ,ff.ds_acumulado
                from frota_fixa_agg as ff
                where ff.dias_rodados >= @MinimoDiasRodados
                    and ff.ds_acumulado >= @PercDSAcumulado
            ) as s
                on t.ppr_cd_periodo = @CodPeriodoPagamento
                and t.ppr_cd_tipo_pgto = 1363
                and t.ppr_lcto_tipo = 'Bonus DS Quinzenal'
                and t.ppr_in_excluido = 0
                and t.ppr_cd_motorista_nfs = s.ppr_cd_motorista_nfs
                and t.ppr_ds_placa = s.ppr_ds_placa

            -- Já existe linha para este motorista+placa: atualiza
            when matched then
                update set
                    t.ppr_vl_lancamentos = @VlBonusFrotaFixaQuinzenal
                    ,t.ppr_vl_total = @VlBonusFrotaFixaQuinzenal
                    ,t.ppr_lcto_dt_lancamento = cast(getdate() as date)
                    ,t.ppr_lcto_observacao = 'Bonus quinzenal Frota Fixa - '
                        + cast(s.ppr_cd_motorista_nfs as varchar) + '/' + s.ppr_ds_placa
                        + ' - ' + cast(s.dias_rodados as varchar) + ' dias, DS acumulado '
                        + cast(cast(s.ds_acumulado * 100 as decimal(5,2)) as varchar) + '%'
                    ,t.ppr_dh_modificacao = getdate()
                    ,t.ppr_cd_usr_modificacao = isnull(@CodUsuario, 7)

            -- Novo motorista+placa elegível: insere
            when not matched by target then
                insert (
                    ppr_cd_periodo, ppr_cd_rota, ppr_cd_motorista_nfs,
                    ppr_cd_pgto_espelho, ppr_base_principal, ppr_data_referencia,
                    ppr_ds_placa, ppr_ds_tipo_veiculo, ppr_cd_tipo_pgto,
                    ppr_vl_lancamentos, ppr_vl_total,
                    ppr_lcto_tipo, ppr_lcto_dt_lancamento, ppr_lcto_observacao,
                    ppr_dh_criacao, ppr_cd_usr_criacao,
                    ppr_dh_modificacao, ppr_cd_usr_modificacao,
                    ppr_in_ativo, ppr_in_excluido,
                    ppr_id_transportadora, ppr_nome_motorista
                )
                values (
                    @CodPeriodoPagamento,
                    NULL,
                    s.ppr_cd_motorista_nfs,
                    s.ppr_cd_pgto_espelho,
                    s.ppr_base_principal,
                    @DataFinal,
                    s.ppr_ds_placa,
                    s.ppr_ds_tipo_veiculo,
                    1363,
                    @VlBonusFrotaFixaQuinzenal,
                    @VlBonusFrotaFixaQuinzenal,
                    'Bonus DS Quinzenal',
                    cast(getdate() as date),
                    'Bonus quinzenal Frota Fixa - '
                        + cast(s.ppr_cd_motorista_nfs as varchar) + '/' + s.ppr_ds_placa
                        + ' - ' + cast(s.dias_rodados as varchar) + ' dias, DS acumulado '
                        + cast(cast(s.ds_acumulado * 100 as decimal(5,2)) as varchar) + '%',
                    getdate(), isnull(@CodUsuario, 7),
                    getdate(), isnull(@CodUsuario, 7),
                    1, 0,
                    s.ppr_id_transportadora, s.ppr_nome_motorista
                )

            -- Linha existente sem correspondência no source: remove
            when not matched by source
                and t.ppr_cd_periodo = @CodPeriodoPagamento
                and t.ppr_cd_tipo_pgto = 1363
                and t.ppr_lcto_tipo = 'Bonus DS Quinzenal'
                and t.ppr_in_excluido = 0
            then
                delete
            ;

        end --fim BONUS_DS

        --======================================================
        -- FASE 5 — REGRA: SDD_DS
        -- SDD (adicional por dia trabalhado) para veículos SDD:
        --   Van SDD e Utilitário SDD: R$ 46,15/rota elegível
        --   VUC SDD: R$ 30,77/rota elegível
        --   HR SDD e VUC PP SDD: não aplicam
        --
        -- Elegibilidade: DS da rota >= 98,5% (regra diária)
        -- Valor gravado em ppr_vl_bonus (não cumulativo com bônus DS)
        --
        -- Critérios:
        --   @ValorCriterio1 = PercentualDS (0.985)
        --   @ValorCriterio2 = ValorSDDVanUtil (46.15)
        --   @ValorCriterio3 = ValorSDDVuc (30.77)
        --======================================================
        if @TipoRegra = 'SDD_DS'
        begin
            set @PercDSSDD = cast(isnull(@ValorCriterio1, '0.985') as decimal(5,4))
            set @VlSDDVanUtil = cast(isnull(@ValorCriterio2, '46.15') as decimal(10,2))
            set @VlSDDVuc = cast(isnull(@ValorCriterio3, '30.77') as decimal(10,2))

            update a
            set a.ppr_vl_bonus = case
                -- Van SDD e Utilitário SDD: R$ 46,15/rota + R$ 10 se DS = 100%
                when a.ppr_ds_tipo_veiculo in ('Van SDD','Utilitários SDD')
                    and isnull(a.ppr_vl_success_delivery, 0) >= @PercDSSDD
                    then @VlSDDVanUtil + case
                        when isnull(a.ppr_vl_success_delivery, 0) >= 1.0
                        then 10.00
                        else 0
                    end
                -- VUC SDD: R$ 30,77/rota + R$ 10 se DS = 100%
                when a.ppr_ds_tipo_veiculo = 'Vuc SDD'
                    and isnull(a.ppr_vl_success_delivery, 0) >= @PercDSSDD
                    then @VlSDDVuc + case
                        when isnull(a.ppr_vl_success_delivery, 0) >= 1.0
                        then 10.00
                        else 0
                    end
                -- VUC SDD: R$ 30,77/rota + R$ 10 se DS = 100%
                when a.ppr_ds_tipo_veiculo = 'HR SDD'
                    and isnull(a.ppr_vl_success_delivery, 0) >= @PercDSSDD
                    then @VlSDDVuc + case
                        when isnull(a.ppr_vl_success_delivery, 0) >= 1.0
                        then 10.00
                        else 0
                    end
                -- Não elegível: zera
                else 0
            end
            from #rotas_periodo as a
            where a.ppr_cd_tipo_pgto = 1362
                and a.ppr_ds_tipo_veiculo in ('Van SDD','Utilitários SDD','Vuc SDD','HR SDD')
                and (a.ppr_vl_success_delivery is not null or a.ppr_qt_pacotes > 0)
        end --fim SDD_DS

        -- Remove a regra processada
        delete #regras_financeiro
        where rlf_cd_regras_financeiro = @CodigoRegra

    end --fim while regras

    ------------------------------------------------------------
    -- UPDATE FINAL: persiste as alterações da temp na tabela original
    ------------------------------------------------------------
    update t
    set
        t.ppr_total_km = r.ppr_total_km
        ,t.ppr_nm_origem_km = r.ppr_nm_origem_km
        ,t.ppr_in_area_risco = r.ppr_in_area_risco
        ,t.ppr_vl_base = r.ppr_vl_base
        ,t.ppr_vl_desconto = r.ppr_vl_desconto
        ,t.ppr_in_zerar_rota = r.ppr_in_zerar_rota
        ,t.ppr_in_calcular_adicional = r.ppr_in_calcular_adicional
        ,t.ppr_motivo_rota_zerada = r.ppr_motivo_rota_zerada
        ,t.ppr_cd_desconto_ds = r.ppr_cd_desconto_ds
        ,t.ppr_vl_bonus_ds = r.ppr_vl_bonus_ds
        ,t.ppr_vl_bonus = r.ppr_vl_bonus
    from tb_pgto_periodo_rota as t
    join #rotas_periodo as r
        on t.ppr_cd_pagamento_rota = r.ppr_cd_pagamento_rota
        and t.ppr_cd_periodo = r.ppr_cd_periodo
    where t.ppr_cd_periodo = @CodPeriodoPagamento
        and t.ppr_cd_tipo_pgto = 1362
        and (
            t.ppr_total_km <> r.ppr_total_km
            or t.ppr_nm_origem_km <> r.ppr_nm_origem_km
            or (t.ppr_nm_origem_km is null and r.ppr_nm_origem_km is not null)
            or isnull(t.ppr_in_area_risco, 0) <> isnull(r.ppr_in_area_risco, 0)
            or isnull(t.ppr_vl_base, 0) <> isnull(r.ppr_vl_base, 0)
            or isnull(t.ppr_vl_desconto, 0) <> isnull(r.ppr_vl_desconto, 0)
            or isnull(t.ppr_in_zerar_rota, 0) <> isnull(r.ppr_in_zerar_rota, 0)
            or isnull(t.ppr_in_calcular_adicional, 1) <> isnull(r.ppr_in_calcular_adicional, 1)
            or isnull(t.ppr_motivo_rota_zerada, '') <> isnull(r.ppr_motivo_rota_zerada, '')
            or isnull(t.ppr_cd_desconto_ds, 0) <> isnull(r.ppr_cd_desconto_ds, 0)
            or isnull(t.ppr_vl_bonus_ds, 0) <> isnull(r.ppr_vl_bonus_ds, 0)
            or isnull(t.ppr_vl_bonus, 0) <> isnull(r.ppr_vl_bonus, 0)
        )

END
GO
