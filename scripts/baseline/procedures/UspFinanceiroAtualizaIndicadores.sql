-- ============================================================
-- BASELINE: dbo.UspFinanceiroAtualizaIndicadores
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinanceiroAtualizaIndicadores]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspFinanceiroAtualizaIndicadores] (
	@IdTransportadora int,
	@Ano int,
	@Mes tinyint,
	@Quinzena tinyint,
	@Etapa varchar(50)
)
as
begin
	
	SET NOCOUNT ON
	

	declare @QuantidadeRotas int
	declare @QuantidadeRotasSemValor int
	declare @QuantidadeVeiculos int
	declare @QuantidadeMotoristas int
	declare @ValorTotal decimal(10,2)
	declare @ValorDA decimal(10,2)
	declare @ValorDiferenca decimal(10,2)
	declare @ValorDescontoPM decimal(10,2)
	declare @PercentualDiferenca decimal(10,2)
	declare @ValoresIguais int
	declare @ValoresMaiorPreFatura int
	declare @ValoresMaiorDA int
	declare @RotasAusenteDA int
	declare @RotasAusentePreFatura int


	--Cria os indicadores da quinzena caso não exista
	if not exists (select 1 from tb_fin_indicadores with(nolock) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa)
	begin
		if @Etapa = 'Prefatura'
		begin
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Quantidade de Rotas', 0, 'Inteiro', 1, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Quantidade de Veiculos', 0, 'Inteiro', 2, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Quantidade de Motoristas', 0, 'Inteiro', 3, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valor Total', 0, 'Dinheiro', 4, 1, null,null,null)
		end

		if @Etapa = 'Faturamento'
		begin
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Rotas Processadas', 0, 'Inteiro', 1, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Quantidade de Veiculos', 0, 'Inteiro', 2, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Quantidade de Motoristas', 0, 'Inteiro', 3, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Rotas sem Valor', 0, 'Inteiro', 4, 1, null,null,null)
			--insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Rotas fora da média SVC', 0, 'Inteiro', 5, 1, null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valor Pré Fatura', 0, 'Dinheiro', 5, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valor Irisys', 0, 'Dinheiro', 6, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Diferença Pré Fatura', 0, 'Dinheiro', 7, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, '% Diferença', 0, 'Percentual', 8, 1, null,null,null)
		end

		if @Etapa = 'Validação'
		begin
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valores Iguais', 0, 'Inteiro', 1, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valores maiores na pré-fatura', 0, 'Inteiro', 2, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Valores maiores Irisys', 0, 'Inteiro', 3, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Ausentes no Irisys', 0, 'Inteiro', 4, 1, null,null,null)
			insert into tb_fin_indicadores values (@IdTransportadora, @Ano, @Mes, @Quinzena, @Etapa, 'Ausentes na pré-fatura', 0, 'Inteiro', 5, 1, null,null,null)
		end
	end
	

	--Atualiza os indicadores
	if @Etapa = 'Prefatura'
	begin
		
		select
			@QuantidadeRotas = count(1),
			--@QuantidadeVeiculos = count(distinct Veiculo + ' - ' + isnull(ContinuacaoVeiculo,0)),
			@QuantidadeVeiculos = count(distinct Veiculo ),

			@QuantidadeMotoristas = count(distinct Motorista),
			@ValorTotal = sum(Total)
		from
			tb_fin_prefatura with(nolock)
		where
			IdTransportadora = @IdTransportadora
			and Ano = @Ano
			and Mes = @Mes
			and Quinzena = @Quinzena

	
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeRotas,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Quantidade de Rotas'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeVeiculos,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Quantidade de Veiculos'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeMotoristas,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Quantidade de Motoristas'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValorTotal,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valor Total'
		update a
			set 
				fid_cd_cliente = cli_cd_codigo_cliente

			from tb_fin_indicadores as a with(nolock)
			inner join tb_clientes as b with(nolock)
			on fid_cd_transportadora = cli_id_logistics

			where 1=1
			and fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena
			and cli_cd_codigo_cliente <> 7

	
	end 


	if @Etapa = 'Faturamento'
	begin
		
		select
			@QuantidadeRotas = count(1),
			@QuantidadeVeiculos = count(distinct TipoVeiculo),
			@QuantidadeMotoristas = count(distinct Motorista),
			@QuantidadeRotasSemValor = sum(case when isnull(RecebMeli,0) = 0 then 1 else 0 end),
			@ValorDA = sum(RecebMeli) - sum(DescontoCicloPM)
		from 
			tb_fin_resultado_financeiro with(nolock)
		where
			IdTransportadora in ( 
				select cli_cd_codigo_cliente  from tb_clientes with(nolock) where cli_id_logistics = @IdTransportadora
			)
			and Ano = @Ano
			and Mes = @Mes
			and Quinzena = @Quinzena

		select
			@ValorTotal = sum(Total)
		from
			tb_fin_prefatura with(nolock)
		where
			IdTransportadora = @IdTransportadora
			and Ano = @Ano
			and Mes = @Mes
			and Quinzena = @Quinzena

		set @ValorDiferenca = isnull(@ValorDA,0)-isnull(@ValorTotal,0)
		set @PercentualDiferenca = case when isnull(@ValorTotal,0) = 0 then 0 else (isnull(@ValorDA,0)-isnull(@ValorTotal,0)) / isnull(@ValorTotal,0) end


		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeRotas,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Rotas Processadas'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeVeiculos,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Quantidade de Veiculos'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeMotoristas,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Quantidade de Motoristas'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@QuantidadeRotasSemValor,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Rotas sem Valor'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValorTotal,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valor Pré Fatura'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValorDA,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valor Irisys'
		update tb_fin_indicadores set fid_vl_indicador = @ValorDiferenca where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Diferença Pré Fatura'
		update tb_fin_indicadores set fid_vl_indicador = @PercentualDiferenca where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = '% Diferença'
		update a
			set 
				fid_cd_cliente = cli_cd_codigo_cliente

			from tb_fin_indicadores as a
			inner join tb_clientes as b
			on fid_cd_transportadora = cli_id_logistics

			where 1=1
			and fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena
			and cli_cd_codigo_cliente <> 7

	end 
		
	if @Etapa = 'Validação'
	begin
		
		select
			@ValoresIguais = sum(case when MaiorValor = 'Valores Iguais' then 1 else 0 end),
			@ValoresMaiorPreFatura = sum(case when MaiorValor = 'Pré Fatura' then 1 else 0 end),
			@ValoresMaiorDA = sum(case when MaiorValor = 'Irisys' then 1 else 0 end),
			@RotasAusenteDA = sum(case when StatusRotaBatimento = 'Rota ausente no Irisys' then 1 else 0 end),
			@RotasAusentePreFatura = sum(case when StatusRotaBatimento = 'Rota ausente na pré fatura' then 1 else 0 end)
		from
			vw_validacao_financeiro with(nolock)
		where
			IdTransportadora  = @IdTransportadora
			and Ano = @Ano
			and Mes = @Mes
			and Quinzena = @Quinzena
			and Marketplace = 'Mercado Livre'
			and Operacao = 'LM'

		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValoresIguais,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valores Iguais'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValoresMaiorPreFatura,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valores maiores na pré-fatura'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@ValoresMaiorDA,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Valores maiores Irisys'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@RotasAusenteDA,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Ausentes no Irisys'
		update tb_fin_indicadores set fid_vl_indicador = isnull(@RotasAusentePreFatura,0) where fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena and fid_nm_etapa = @Etapa and fid_nm_indicador = 'Ausentes na pré-fatura'
		update a
			set 
				fid_cd_cliente = cli_cd_codigo_cliente

			from tb_fin_indicadores as a
			inner join tb_clientes as b
			on fid_cd_transportadora = cli_id_logistics

			where 1=1
			and fid_cd_transportadora = @IdTransportadora and fid_nr_ano = @Ano and fid_nr_mes = @Mes and fid_nr_quinzena = @Quinzena
			and cli_cd_codigo_cliente <> 7
	end
 

end
GO
