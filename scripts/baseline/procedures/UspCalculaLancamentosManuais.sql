-- ============================================================
-- BASELINE: dbo.UspCalculaLancamentosManuais
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspCalculaLancamentosManuais]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  procedure [dbo].[UspCalculaLancamentosManuais] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint
)
as
begin
	
	SET NOCOUNT ON
	
	declare @data_inicial date = cast(cast(@Ano as varchar(4)) + '-' + cast(@Mes as varchar(2)) + '-' + case when @Quinzena = 1 then'01' else '16' end as date)
	declare @data_final date = case when @Quinzena = 1 then dateadd(day,14,@data_inicial) else eomonth(@data_inicial) end

	delete tb_fin_lancamentos_manuais where IdTransportadora = @IdTransportadora and Ano = @Ano and Mes = @Mes and Quinzena = @Quinzena
	
	insert into tb_fin_lancamentos_manuais  (IdTransportadora, Ano, Mes, Quinzena, IdRota, DataReferencia, ServiceCenter, Motorista, MotoristaApoio, TipoVeiculo, Ciclo, DescontoMeli, DescontoSaida, TipoLancamento, Motivo)
	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		null IdRota,
		lan.tlm_dh_nao_utilizado DataReferencia,
		lan.tlm_cd_service_center ServiceCenter,
		lan.tlm_cd_motorista Motorista,
		null MotoristaApoio,
		rotas.TipoVeiculo,
		lan.tlm_cd_periodo Ciclo,
		(fin.RecebMeli+fin.RecebimentoDomingo) / 2.0 * -1 DescontoMeli,
		fin.PgtoSaida / 2.0 * -1 DescontoSaida,
		lan.tlm_cd_tipo TipoLancamento,
		lan.tlm_ds_observacao
	from
		tb_lancamentos_manuais lan with(nolock)
		join tb_aprovacao_lancamento_manual apr with(nolock) on lan.tlm_cd_lancamento_manual = apr.alm_cd_lancamento_manual
		join tb_clientes cli with(nolock) on lan.tlm_cd_cliente = cli.cli_cd_codigo_cliente
		left join DimData dt on lan.tlm_dh_nao_utilizado = dt.Data
		left join tb_ml_rotas rotas with(nolock) on cli.cli_id_logistics = rotas.IdTransportadora
								and lan.tlm_cd_motorista = rotas.NomeMotorista
								and rotas.Excluido = 0
								and rotas.Id = (
												select
													max(Id)
												from
													tb_ml_rotas r2 with(nolock)
												where
													r2.Excluido = 0
													and rotas.NomeMotorista = r2.NomeMotorista
													and rotas.IdTransportadora = r2.IdTransportadora
												)
		left join vw_resultado_financeiro fin with(nolock) on cli.cli_id_logistics = fin.IdTransportadora
								and rotas.TipoVeiculo = fin.TipoVeiculo
								and lan.tlm_cd_periodo = fin.CicloPM
								and lan.tlm_cd_service_center = fin.ServiceCenter
								and case when DATEPART(weekday, lan.tlm_dh_nao_utilizado) = 1 or dt.Feriado = 1 then 'Sim' else 'Não' end = fin.DomingoOuFeriado
								and fin.IdRota = (
													select
														max(IdRota)
													from
														vw_resultado_financeiro f2 with(nolock)
													where
														fin.IdTransportadora = f2.IdTransportadora
														and fin.TipoVeiculo = f2.TipoVeiculo
														and fin.CicloPM = f2.CicloPM
														and fin.ServiceCenter = f2.ServiceCenter
														and fin.DomingoOuFeriado = f2.DomingoOuFeriado
												)
	where
		cli.cli_id_logistics = @IdTransportadora
		and cast(lan.tlm_dh_nao_utilizado as date) between @data_inicial and @data_final
		and apr.alm_in_excluido = 0
		and lan.tlm_in_excluido = 0
		and tlm_in_marketplace = 'ML'
		and apr.alm_ds_status = 'Aprovado'
		and lan.tlm_cd_tipo = 'NoShow'
		and lan.tlm_dh_nao_utilizado is not null

	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		null IdRota,
		tlm_dh_nao_utilizado DataReferencia,
		lan.tlm_cd_service_center ServiceCenter,
		lan.tlm_cd_motorista Motorista,
		null MotoristaApoio,
		vei.tvl_nm_tipo_veiculo TipoVeiculo,
		lan.tlm_cd_periodo Ciclo,
		(fin.RecebMeli+fin.RecebimentoDomingo) / 2.0 DescontoMeli,
		fin.PgtoSaida / 2.0 DescontoSaida,
		lan.tlm_cd_tipo TipoLancamento,
		lan.tlm_ds_observacao
	from
		tb_lancamentos_manuais lan with(nolock)
		join tb_aprovacao_lancamento_manual apr with(nolock) on lan.tlm_cd_lancamento_manual = apr.alm_cd_lancamento_manual
		join tb_clientes cli with(nolock) on lan.tlm_cd_cliente = cli.cli_cd_codigo_cliente
		join tb_dra_tipo_veiculo vei with(nolock) on lan.tlm_cd_tipo_veiculo_nao_utilizado = vei.tvl_cd_tipo_veiculo
		left join DimData dt on lan.tlm_dh_nao_utilizado = dt.Data
		left join vw_resultado_financeiro fin with(nolock) on cli.cli_id_logistics = fin.IdTransportadora
								and vei.tvl_nm_tipo_veiculo = fin.TipoVeiculo
								and fin.CicloPM =  'AM'
								and lan.tlm_cd_service_center = fin.ServiceCenter
								and case when DATEPART(weekday, lan.tlm_dh_nao_utilizado) = 1 or dt.Feriado = 1 then 'Sim' else 'Não' end = fin.DomingoOuFeriado
								and fin.IdRota = (
													select
														max(IdRota)
													from
														vw_resultado_financeiro f2 with(nolock)
													where
														fin.IdTransportadora = f2.IdTransportadora
														and fin.TipoVeiculo = f2.TipoVeiculo
														and fin.CicloPM = f2.CicloPM
														and fin.ServiceCenter = f2.ServiceCenter
														and fin.DomingoOuFeriado = f2.DomingoOuFeriado
												)
	where
		cli.cli_id_logistics = @IdTransportadora
		and cast(lan.tlm_dh_nao_utilizado as date) between @data_inicial and @data_final
		and apr.alm_in_excluido = 0
		and lan.tlm_in_excluido = 0
		and tlm_in_marketplace = 'ML'
		and apr.alm_ds_status = 'Aprovado'
		and lan.tlm_cd_tipo = 'Não Utilizado'
		and tlm_dh_nao_utilizado is not null

	union all

	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		lan.tlm_cd_rota IdRota,
		fin.DataReferencia,
		lan.tlm_cd_service_center ServiceCenter,
		lan.tlm_cd_motorista Motorista,
		lan.tlm_ds_motorista_apoio MotoristaApoio,
		fin.TipoVeiculo,
		lan.tlm_cd_periodo Ciclo,
		0 DescontoMeli,
		case when tlm_tipo_valor_apoio = 'Percentual' then	
			(fin.PgtoSaida + fin.PgtoRisco + fin.PgtoParadas + fin.PgtoAjudante) * cast(tlm_vl_valor_apoio as decimal(8,2)) / 100
		else
			cast(tlm_vl_valor_apoio as decimal(8,2))
		end DescontoSaida,
		lan.tlm_cd_tipo TipoLancamento,
		lan.tlm_ds_observacao
	from
		tb_lancamentos_manuais lan with(nolock)
		join tb_aprovacao_lancamento_manual apr with(nolock) on lan.tlm_cd_lancamento_manual = apr.alm_cd_lancamento_manual
		join tb_clientes cli with(nolock) on lan.tlm_cd_cliente = cli.cli_cd_codigo_cliente
		left join vw_resultado_financeiro fin with(nolock) on cli.cli_id_logistics = fin.IdTransportadora
								and lan.tlm_cd_rota = fin.IdRota
	where
		cli.cli_id_logistics = @IdTransportadora
		and fin.DataReferencia between @data_inicial and @data_final
		and apr.alm_in_excluido = 0
		and lan.tlm_in_excluido = 0
		and tlm_in_marketplace = 'ML'
		and apr.alm_ds_status = 'Aprovado'
		and lan.tlm_cd_tipo = 'Apoio'

	--Atualiza apoio no resultado financeiro
	update
		fin
	set
		fin.PgtoLancamentoManual = lan.TipoLancamento,
		fin.PgtoValorManual = lan.DescontoSaida * -1
	from 
		tb_fin_lancamentos_manuais lan
		join tb_fin_resultado_financeiro fin on lan.IdTransportadora = fin.IdTransportadora and lan.IdRota = fin.IdRota
	where
		lan.IdTransportadora = @IdTransportadora
		and lan.Ano = @Ano
		and lan.Mes = @Mes
		and lan.Quinzena = @Quinzena
		and lan.TipoLancamento = 'Apoio'




	--Insere nos lançamentos manuais os valores de desconto buscados da pré-fatura
	insert into tb_fin_lancamentos_manuais  (IdTransportadora, Ano, Mes, Quinzena, IdRota, DataReferencia, ServiceCenter, Motorista, MotoristaApoio, TipoVeiculo, Ciclo, DescontoMeli, DescontoSaida, TipoLancamento, Motivo)
	select
		@IdTransportadora IdTransportadora,
		@Ano Ano,
		@Mes Mes,
		@Quinzena Quinzena,
		p.IdRota IdRota,
		p.DataReferencia,
		r.ServiceCenter,
		r.NomeMotorista Motorista,
		null MotoristaApoio,
		r.TipoVeiculo,
		case when datepart(hour,r.DataHoraInicio) <= 12 or isnull(pre.CicloPM,'') = 'AM' then 'AM' else 'PM' end CicloPM,
		0 DescontoMeli,
		p.TotalDesconto * -1 DescontoSaida,
		--p.Descricao TipoLancamento,
		CASE 
			WHEN CHARINDEX(':', p.Descricao) > 0
				THEN LEFT(p.Descricao, CHARINDEX(':', p.Descricao) - 1)
			WHEN CHARINDEX('>', p.Descricao) > 0
				THEN LEFT(p.Descricao, CHARINDEX(' >', p.Descricao) - 1)
			ELSE p.Descricao 
		end as TipoLancamento,
		p.Pacotes
	from
		(
		select
			IdTransportadora,
			Ano,
			Mes,
			Quinzena,
			DataReferencia,
			IdRota,
			Descricao,
			IdPacote Pacotes,
			Total TotalDesconto
			/*Pacotes = STUFF((
				SELECT 
					N'', ' ,' + cast(IdPacote as varchar)
				FROM
					tb_fin_prefatura_descontos f2
				WHERE 
					f.IdTransportadora = f2.IdTransportadora
					and f.IdRota = f2.IdRota
						FOR XML PATH(''), TYPE).value(N'.[1]', N'nvarchar(max)'), 1, 2, N''
				),
			sum(Total) TotalDesconto*/
		from
			tb_fin_prefatura_descontos f
		where
			IdTransportadora = @IdTransportadora
			and Ano = @Ano
			and Mes = @Mes
			and Quinzena = @Quinzena
		/*group by
			IdTransportadora,
			Ano,
			Mes,
			Quinzena,
			DataReferencia,
			IdRota,
			Descricao*/
	) p
	join vw_rotas r on p.IdRota = r.IdRota and p.IdTransportadora = r.IdTransportadora
	left join DimData dt on p.DataReferencia = dt.Data
	left join tb_fin_prefatura pre on r.IdTransportadora = pre.IdTransportadora
												and r.IdRota = pre.IdRota
												--and r.DataReferencia = pre.DataTermino
												and pre.Quinzena = @Quinzena
												and pre.Ano = @Ano
												and pre.Mes = @Mes
end
GO
