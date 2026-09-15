-- ============================================================
-- BASELINE: dbo.UspFinValidacao
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinValidacao]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   procedure [dbo].[UspFinValidacao]   (
    @CodPeriodoPagamento int
) as

	declare 
      @IdTransportadora int 
    -- , @CodPeriodoPagamento int = 80
    , @data_inicial date 
    , @data_final date 
	, @clienteid int
	, @usuarioIrisys int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	, @idrota varchar(50) = null --157094505
    ,@tipocontrato int = null


	
	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)

	

	if @idrota is not null
		begin 
			set @usuarioIrisys = (select distinct usuarioda from vw_rotas where idrota = @idrota)
			set @Motorista = (select distinct NomeMotorista from vw_rotas where idrota = @idrota)
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
						select cli_id_logistics
						from [tb_pgto_periodo] as a
						left join tb_clientes as b
						on a.pgp_cd_cliente = cli_cd_codigo_cliente
						where pgp_cd_periodo  = @CodPeriodoPagamento 
						)

    drop table if exists #origem
	select
	*
	into #origem
	from  vw_rotas as a
	
	where a.IdTransportadora = @IdTransportadora
	and a.DataReferencia between @data_inicial and @data_final
    and nomemotorista <> ''
    and UsuarioDA in (
                        select
                        usr_cd_usuario
                        from tb_usuario as a
                        inner join tb_tipo_contrato as b
                        on a.usr_cd_tipo_contrato = b.ttc_cd_tipo_contrato
                        where cli_cd_codigo_cliente = 
                                                (
                                                select pgp_cd_cliente
												from [tb_pgto_periodo] as a
												left join tb_clientes as b
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
                                                )
                        and a.usr_cd_tipo_contrato = @tipocontrato 
                        )


drop table if exists #tb_fin_prefatura
select
*
into #tb_fin_prefatura
from tb_fin_prefatura 
where idtransportadora = @IdTransportadora
and DataInicio between @data_inicial and @data_final
and Motorista in (
                        select
                        usr_cd_usuario
                        from tb_usuario as a
                        inner join tb_tipo_contrato as b
                        on a.usr_cd_tipo_contrato = b.ttc_cd_tipo_contrato
                        where cli_cd_codigo_cliente = 
                                                (
                                                select pgp_cd_cliente
												from [tb_pgto_periodo] as a
												left join tb_clientes as b
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
                                                )
                        and a.usr_cd_tipo_contrato = @tipocontrato 
                        )

-- select * 
-- from tb_pgto_periodo_rota as a
-- inner join #origem as b
-- on a.ppr_cd_rota = b.idrota
-- where ppr_cd_periodo =  @CodPeriodoPagamento  


insert into tb_fin_validacao_financeiro
SELECT 
    @IdTransportadora AS IdTransportadora,
    @CodPeriodoPagamento AS Periodo,
    'Validacao' AS Etapa,
    'Quantidade correta' as Indicador,
    (SELECT COUNT(*) 
     FROM tb_pgto_periodo_rota AS a
     INNER JOIN #origem AS b ON a.ppr_cd_rota = b.idrota
     WHERE a.ppr_cd_periodo = @CodPeriodoPagamento) AS Valor;

insert into tb_fin_validacao_financeiro
SELECT 
    @IdTransportadora AS IdTransportadora,
    @CodPeriodoPagamento AS Periodo,
    'Validacao' AS Etapa,
    'Nao gerou pagamento' as Indicador,
    (SELECT COUNT(*) 
     FROM #origem AS b
     LEFT JOIN tb_pgto_periodo_rota AS a 
     ON a.ppr_cd_rota = b.idrota AND a.ppr_cd_periodo = @CodPeriodoPagamento
     WHERE a.ppr_cd_rota IS NULL) AS Valor;

insert into tb_fin_validacao_financeiro
SELECT 
    @IdTransportadora AS IdTransportadora,
    @CodPeriodoPagamento AS Periodo,
    'Validacao Pre Fatura' AS Etapa,
    'Quantidade correta' as Indicador,
    (SELECT COUNT(*) 
     FROM tb_pgto_periodo_rota AS a
     INNER JOIN #tb_fin_prefatura AS b ON a.ppr_cd_rota = b.idrota
     WHERE a.ppr_cd_periodo = @CodPeriodoPagamento) AS Valor;

insert into tb_fin_validacao_financeiro
SELECT 
    @IdTransportadora AS IdTransportadora,
    @CodPeriodoPagamento AS Periodo,
    'Validacao Pre Fatura' AS Etapa,
    'Gerou Pagamento e nao tem na pre fatura' as Indicador,
    (SELECT COUNT(*) 
     FROM tb_pgto_periodo_rota AS a
     LEFT JOIN #tb_fin_prefatura AS b ON a.ppr_cd_rota = b.idrota
     WHERE a.ppr_cd_periodo = @CodPeriodoPagamento
     AND b.idrota IS NULL) AS Valor;

insert into tb_fin_validacao_financeiro
SELECT 
    @IdTransportadora AS IdTransportadora,
    @CodPeriodoPagamento AS Periodo,
    'Validacao Pre Fatura' AS Etapa,
    'Tem na prefatura e não gerou pagamento' as Indicador,
    (SELECT COUNT(*) 
     FROM #tb_fin_prefatura AS b
     LEFT JOIN tb_pgto_periodo_rota AS a 
     ON a.ppr_cd_rota = b.idrota AND a.ppr_cd_periodo = @CodPeriodoPagamento
     WHERE a.ppr_cd_rota IS NULL) AS valor;


-- create table tb_fin_validacao_financeiro
-- (
--     IdTransportadora int,
--     Periodo int,
--     Etapa varchar(250),
--     Indicador varchar(250),
--     Valor decimal(10,2)
-- )

select * from tb_fin_validacao_financeiro
GO
