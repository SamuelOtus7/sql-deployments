-- ============================================================
-- BASELINE: dbo.UspAtualizaEdicoes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspAtualizaEdicoes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspAtualizaEdicoes] (
    @CodPeriodoPagamento int,
	@idrota varchar(50) = null
) as 

	declare
      @IdTransportadora int
    -- , @CodPeriodoPagamento int = 385
    , @data_inicial date
    , @data_final date
	, @clienteid int
	, @usuarioIrisys int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	-- , @idrota varchar(50) = 201778186
	--, @avulso int = null
    ,@tipocontrato int = null



	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)



	if @idrota is not null
		begin
			set @usuarioIrisys = (select distinct usuarioda from vw_rotas where cast(idrota as varchar(50)) = @idrota)
			set @Motorista = (select distinct NomeMotorista from vw_rotas where cast(idrota as varchar(50)) = @idrota)
		end

	set @IdTransportadora = (
							select cli_id_logistics
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
						and lst_ds_label = 'Mercado Livre'
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

-- {"Edição da ficha de rota": 1}

declare @idchaveedicao int = (
                            select lst_ds_chave 
                            from tb_lista 
                            where lst_nm_lista = 'Edição da ficha de rota'
                            and lst_cd_cliente = @clienteid
                            and lst_ds_chave in (
                                select value
                                from  tb_parametros as par
                                cross apply openjson(par.prm_ds_valor, '$') as j
                                where 1=1
                                and  prm_nm_parametro = 'Edição na ficha de rota'
                            )
)


/*

-- SELECT @idchaveedicao
if @idchaveedicao in (1,3) --and @IdTransportadora not in (472463006, 244041012, 678279205) --1387994348
begin
    drop table if exists #tb_fin_resultado_financeiro_alteracao
    SELECT *
    into #tb_fin_resultado_financeiro_alteracao
    FROM tb_fin_resultado_financeiro_alteracao
    WHERE (IDROTA = @idrota OR @idrota IS NULL)


    merge into tb_pgto_periodo_rota_edit as target
    using (
        select
            idrota as edit_rota,
            CicloPM as edit_Ciclo_PM,
            QuantidadePontos as edit_Quantidade_Pontos,
            QuantidadeParadas as edit_Quantidade_Paradas,
            QuantidadePacotes as edit_Quantidade_Pacotes,
            TipoVeiculo as edit_Tipo_Veiculo,
            FaixaKM as edit_Faixa_KM,
            servicecenter as edit_Service_Center,
            getdate() as edit_dh_criacao,
            4032 as edit_cd_usr_criacao,
            Observacao  as edit_observacao,
            Regiao as edit_Regiao,
            RiscoV2 as edit_RiscoV2,
            Ajudante as edit_Ajudante,
            AreaRisco as edit_AreaRisco
         from #tb_fin_resultado_financeiro_alteracao as a

    ) as source
    on target.edit_rota = source.edit_rota

    when matched then
    update set
        edit_Ciclo_PM = source.edit_Ciclo_PM,
        edit_Quantidade_Pontos = source.edit_Quantidade_Pontos,
        edit_Quantidade_Paradas = source.edit_Quantidade_Paradas,
        edit_Quantidade_Pacotes = source.edit_Quantidade_Pacotes,
        edit_Tipo_Veiculo = source.edit_Tipo_Veiculo,
        edit_Faixa_KM = source.edit_Faixa_KM,
        edit_Service_Center = source.edit_Service_Center,
        edit_dh_criacao = source.edit_dh_criacao,
        edit_cd_usr_criacao = source.edit_cd_usr_criacao,
        edit_observacao = source.edit_observacao,
        edit_Regiao = source.edit_Regiao,
        edit_RiscoV2 = source.edit_RiscoV2,
        edit_Ajudante = source.edit_Ajudante,
        edit_AreaRisco = source.edit_AreaRisco

    when not matched then
    insert (
        edit_rota,
        edit_Ciclo_PM,
        edit_Quantidade_Pontos,
        edit_Quantidade_Paradas,
        edit_Quantidade_Pacotes,
        edit_Tipo_Veiculo,
        edit_Faixa_KM,
        edit_Service_Center,
        edit_dh_criacao,
        edit_cd_usr_criacao,
        edit_observacao,
        edit_Regiao,
        edit_RiscoV2,
        edit_Ajudante,
        edit_AreaRisco
    )
    values (
        source.edit_rota,
        source.edit_Ciclo_PM,
        source.edit_Quantidade_Pontos,
        source.edit_Quantidade_Paradas,
        source.edit_Quantidade_Pacotes,
        source.edit_Tipo_Veiculo,
        source.edit_Faixa_KM,
        source.edit_Service_Center,
        source.edit_dh_criacao,
        source.edit_cd_usr_criacao,
        source.edit_observacao,
        source.edit_Regiao,
        source.edit_RiscoV2,
        source.edit_Ajudante,
        source.edit_AreaRisco
    );
end
    */
GO
