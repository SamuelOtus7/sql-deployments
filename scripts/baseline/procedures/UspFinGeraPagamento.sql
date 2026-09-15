-- ============================================================
-- BASELINE: dbo.UspFinGeraPagamento
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinGeraPagamento]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinGeraPagamento] (
    @CodPeriodoPagamento int,
	@idrota varchar(50) = null,
	@avulso int = null -- codigo espelho,
)
as
set nocount on

--BEGIN
--	SET @idrota = NULL_
--END

--declare @CodPeriodoPagamento int = 2791,
--	@idrota varchar(50) = null,
--	@avulso int = null -- codigo espelho,


declare @clienteid int,@operacao int

--Incluído por Saulo Barros em 10/07/2025 para atualizar o usuário DA
--Estava ocorrendo situações que o motorista era cadastrado e não aparecia no espelho pq essa rotina não tinha sido executada ainda
--exec [dbo].[UspAtualzaUsuarioDA]

set @clienteid = (
					select pgp_cd_cliente
					from [tb_pgto_periodo] as a (NOLOCK)
					left join tb_clientes as b (NOLOCK)
					on a.pgp_cd_cliente = cli_cd_codigo_cliente
					where pgp_cd_periodo  = @CodPeriodoPagamento
					)

set @operacao = (
					select pgp_tipo_operacao
					from [tb_pgto_periodo] as a (NOLOCK)
					left join tb_clientes as b (NOLOCK)
					on a.pgp_cd_cliente = cli_cd_codigo_cliente
					where pgp_cd_periodo  = @CodPeriodoPagamento
					)




SET @avulso = CASE WHEN @avulso = 0 THEN NULL ELSE @avulso END;

--if @avulso is not null
--begin

--		update 
--			a
--		set
--			 mtn_vl_nfs = ppr_vl_total
--			,mtn_nome_motorista = ppr_nome_motorista
--			,mtn_cd_motorista = ppr_cd_motorista
--		from 
--			tb_pag_espelhos as a (NOLOCK)
--			inner join (
--				select
--					ppr_cd_pgto_espelho
--					,ppr_nome_motorista
--					,ppr_cd_motorista
--					,sum(ppr_vl_total) as ppr_vl_total
--				FROM 
--					[tb_pgto_periodo_rota] AS a (NOLOCK)
--				where 
--					ppr_cd_pgto_espelho = @avulso
--					and ppr_cd_periodo  = @CodPeriodoPagamento
--					and ppr_fl_desconto = 0
--				group by 
--					ppr_cd_pgto_espelho,
--					ppr_nome_motorista,
--					ppr_cd_motorista
--			) as b
--				on a.mtn_cd_motorista_nfs = b.ppr_cd_pgto_espelho
--		where
--			a.mtn_cd_operacao = @Operacao

--end

--else

--begin

	declare
      @IdTransportadora int
     --, @CodPeriodoPagamento int = 245
    , @data_inicial date
    , @data_final date
	, @usuarioIrisys int
	, @Motorista varchar(250)
	, @IdCliTransportadora int
	 --, @idrota varchar(50) = null
	--, @avulso int = null
    ,@tipocontrato int = null
	,@TipoOperacao varchar(100)
	,@EspelhoBase varchar(10)


	set @data_inicial = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with (nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	set @data_final = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with (nolock) where  pgp_cd_periodo  = @CodPeriodoPagamento)



	--if @idrota is not null
	--	begin
	--		set @usuarioIrisys = (select distinct usuarioda from vw_rotas (NOLOCK) where idrota = @idrota and usuarioda is not null )
	--		set @Motorista = (select distinct NomeMotorista from vw_rotas (NOLOCK) where idrota = @idrota)
	--	end


	if @avulso is not null
		begin
			set @usuarioIrisys = (select mtn_cd_motorista from tb_pag_espelhos with(nolock) where mtn_cd_motorista_nfs = @avulso and mtn_cd_pgto_periodo = @CodPeriodoPagamento)
			set @Motorista = (select mtn_nome_motorista   from tb_pag_espelhos with(nolock) where mtn_cd_motorista_nfs = @avulso and mtn_cd_pgto_periodo = @CodPeriodoPagamento)
			set @EspelhoBase = (select mtn_base_principal from tb_pag_espelhos with(nolock) where mtn_cd_motorista_nfs = @avulso and mtn_cd_pgto_periodo = @CodPeriodoPagamento)
		end



	--SELECT 
	--	ppr_cd_rota
	--INTO 
	--	#rotas_espelho
	--FROM 
	--	tb_pgto_periodo_rota r WITH (NOLOCK)
	--WHERE 
	--	ppr_cd_periodo = @CodPeriodoPagamento
	--	AND ppr_in_excluido = 0
	--	and (
	--	exists (select 
	--				1 
	--			from 
	--				tb_pgto_periodo_rota pgto with(nolock)
	--			where 
	--				pgto.ppr_cd_motorista_nfs = @avulso 
	--				and pgto.ppr_cd_tipo_pgto = 1362
	--				and pgto.ppr_in_excluido = 0
	--				and pgto.ppr_cd_rota = r.ppr_cd_rota
	--			)
	--	or
	--		@avulso is null
	--	)


	--CREATE CLUSTERED INDEX CX_rotas_espelho ON #rotas_espelho (ppr_cd_rota);





	set @IdTransportadora = (
							select cli_id_logistics
							from [tb_pgto_periodo] as a (NOLOCK)
							left join tb_clientes as b (NOLOCK)
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)


	set @TipoOperacao = (

						select 
							lst_ds_valor 
						from 
							tb_lista with(nolock)
						where 
							lst_nm_lista = 'Operações Marketplace' 
							and lst_cd_lista in (
												select pgp_tipo_operacao
												from [tb_pgto_periodo] as a (NOLOCK)
												left join tb_clientes as b (NOLOCK)
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
											)
						)

	set @tipocontrato = (
							select pgp_cd_tipo_contratos
							from [tb_pgto_periodo] as a (NOLOCK)
							left join tb_clientes as b (NOLOCK)
							on a.pgp_cd_cliente = cli_cd_codigo_cliente
							where pgp_cd_periodo  = @CodPeriodoPagamento
						)

	set @IdCliTransportadora = (

						select lst_cd_lista from tb_lista (NOLOCK)
						where lst_nm_lista = 'Clientes transportadoras'
						and lst_ds_label = 'Mercado Livre'
						and lst_cd_cliente in (
												select pgp_cd_cliente
												from [tb_pgto_periodo] as a (NOLOCK)
												left join tb_clientes as b (NOLOCK)
												on a.pgp_cd_cliente = cli_cd_codigo_cliente
												where pgp_cd_periodo  = @CodPeriodoPagamento
												)
												)

	declare @DataPrevistaPagamento date = (  
      
								select pgp_dt_prevista_pagamento  
								from [tb_pgto_periodo] as a (NOLOCK)  
								where pgp_cd_periodo  = @CodPeriodoPagamento
     
								)
	


	--IF(@clienteid in (11,45)) --incluído ac2 por Saulo Barros em 01/07/2025
	--BEGIN
	--	EXEC [dbo].[UspAtualizaFaixaRTT]
	--END


	--filtra as rotas por tipo de operacao sem deixar duplicar as rotas
    --tambem faz o filtro de tipo de contrato dos motoristas 


	--Regra criada em 29/05/2026 por Saulo e Gustavo para ajsutar o usuarioda do espelho quando é alterado na tabela de rotas
	
	if @clienteid = 56
	begin
		
		IF OBJECT_ID('tempdb..#AjusteParceiro') IS NOT NULL DROP TABLE #AjusteParceiro;
		select  
  		  distinct
  		  e.mtn_cd_motorista_nfs Espelho
  		  ,e.mtn_cd_motorista UsuarioDA_Espelho
  		  ,r.UsuarioDA UsuarioDA_Rotas
		into #AjusteParceiro
		from  
  		  tb_pag_espelhos e with(nolock)
  		  join tb_clientes c with(nolock) on e.mtn_cod_cliente = c.cli_cd_codigo_cliente
  		  join tb_pgto_periodo_rota p with(nolock) on e.mtn_cd_motorista_nfs = p.ppr_cd_motorista_nfs
  		  join tb_ml_rotas r with(nolock) on p.ppr_cd_rota = r.idrota and c.cli_id_logistics = r.IdTransportadora
		where  
  		  p.ppr_in_excluido = 0
  		  and p.ppr_cd_tipo_pgto = 1362
  		  and p.ppr_cd_motorista <> r.UsuarioDA
  		  and c.cli_cd_codigo_cliente = 56
  		  and e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
		  and (
					exists (select 
								1 
							from 
								tb_pgto_periodo_rota pgto with(nolock)
							where 
								pgto.ppr_cd_motorista_nfs = @avulso 
								and pgto.ppr_cd_tipo_pgto = 1362
								and pgto.ppr_in_excluido = 0
								and pgto.ppr_cd_rota = r.IdRota
							)
					or
					@avulso is null
				)


		update  
  		  e
		set  
  		  e.mtn_cd_motorista = a.UsuarioDA_Rotas
		from
  		  tb_pag_espelhos as e 
  		  join #AjusteParceiro as a  on e.mtn_cd_motorista_nfs = a.Espelho
  		  left join tb_pag_espelhos valid on valid.mtn_cd_motorista = a.UsuarioDA_Rotas
    										and valid.mtn_cd_pgto_periodo = @CodPeriodoPagamento
		where
  		  e.mtn_cd_pgto_periodo = @CodPeriodoPagamento
  		  and valid.mtn_cd_motorista is null



		update
  		  r
		set  
  		  r.ppr_cd_motorista = a.UsuarioDA_Rotas
		from
  		  tb_pgto_periodo_rota as r
  		  join #AjusteParceiro as a
    		on r.ppr_cd_motorista_nfs = a.Espelho
  		  left  join tb_pgto_periodo_rota as valid
    		on valid.ppr_cd_motorista = a.UsuarioDA_Rotas
    		and valid.ppr_cd_periodo = @CodPeriodoPagamento
		where
  		  r.ppr_cd_periodo = @CodPeriodoPagamento
  		  and valid.ppr_cd_motorista is null
	end
	



	drop table if exists #origem
	select
		*,row_number() over(partition by idrota order by datareferencia) orderfinal
	into 
		#origem
	from ( 

		select * ,row_number() over(partition by idrota order by datareferencia) rnumber
		from vw_rotas a (NOLOCK)
		where a.IdTransportadora = @IdTransportadora
			and a.DataReferencia between @data_inicial and @data_final
			and (@Motorista is null or a.NomeMotorista = @Motorista)
			and nomemotorista <> ''
			and nomemotorista <> '-'
			and tipo = @TipoOperacao
			and (
				@TipoOperacao <> 'FM'
				or not exists (
					select 1
					from vw_rotas lm with (nolock)
					where lm.IdTransportadora = a.IdTransportadora
					  and lm.IdRota = a.IdRota
					  and lm.DataReferencia = a.DataReferencia
					  and lm.tipo = 'LM'
				)
			)

	) as a

	where a.IdTransportadora = @IdTransportadora
	--and a.IdTransportadora <> 643493085
	and a.DataReferencia between @data_inicial and @data_final
	and (@Motorista is null or a.NomeMotorista = @Motorista)
    and nomemotorista <> ''
     and (
        @tipocontrato = '-1' 
        or UsuarioDA in (
                       select
                       mot_cd_usuario
                       from tb_motorista as a (NOLOCK)
                       left join tb_tipo_contrato as b (NOLOCK)
                       on a.mot_ctn_cd_tipo_contrato = b.ttc_cd_tipo_contrato
                       where mot_cd_cliente =
                                               (
                                               select pgp_cd_cliente
	 											from [tb_pgto_periodo] as a (NOLOCK)
	 											left join tb_clientes as b (NOLOCK)
	 											on a.pgp_cd_cliente = cli_cd_codigo_cliente
	 											where pgp_cd_periodo  = @CodPeriodoPagamento
                                               )
                                    and (@tipocontrato = '-1'
        or a.mot_ctn_cd_tipo_contrato = @tipocontrato)
                       )
     )
	--  AND tipo = @TipoOperacao


	-- Após #origem
	-- PERFORMANCE
	CREATE NONCLUSTERED INDEX IX_origem_IdRota
	ON #origem (IdRota)
	INCLUDE (DataReferencia, NomeMotorista, UsuarioDA, ServiceCenter, OrigemSaida);


	
	---------------------------------------------------------
	--REGRA DE FM para ParceiroSpot caso a rota for null incluir 1
	---------------------------------------------------------
	update	
		#origem
	set	
		KmTotal = 1
	where
		KmTotal is null
		and @TipoOperacao = 'FM'
		and @clienteid = 56



		delete  from #origem where orderfinal > 1
		--remover os l
		IF @IdTransportadora = 643493085
		BEGIN 
			delete
				from #origem
			where
				IdTransportadora = 643493085 and ServiceCenter not in ('SSP6','SSP20','SSP5','SSP45')
				
		END


	--and a.tipo = 'last_mile'


	--Incluído por Saulo Barros em 22/07/2025 para criação da seguinte regra solicitada pela AC2
	--Se o motorista tiver rotas em EPE4 ou EPE5, considerar esses XPT caso tenha alguma rota que não veio a informação do XPT
	IF(@clienteid = 45)
	BEGIN
		update
			o
		set
			OrigemSaida = o2.OrigemSaida
		from
			#origem o
			join (
				--Verifica motoristas que fizeram rotas em EPE4 ou EPE5 e que tiveram alguma rota que não apareceu a informação de XPT, ou seja, só tem a informação do SVC SPE1
				select
					r.NomeMotorista
					,isnull(QtdeEPE4, 0) QtdeEPE4
					,isnull(QtdeEPE5, 0) QtdeEPE5
					,isnull(QtdeSPE1, 0) QtdeSPE1
					,case when isnull(QtdeEPE4, 0) > 0 then 'EPE4' else 'EPE5' end OrigemSaida
				from
					(
						select
							r.NomeMotorista
							,count(case when r.OrigemSaida = 'EPE4' then 1 end) QtdeEPE4
							,count(case when r.OrigemSaida = 'EPE5' then 1 end) QtdeEPE5
						from
							#origem r
						where
							r.OrigemSaida in ('EPE4', 'EPE5')
						group by
							r.NomeMotorista
					) r
					left join 
					(
						select
							r.NomeMotorista
							,count(1) QtdeSPE1
						from
							#origem r
						where
							r.ServiceCenter = 'SPE1'
							and r.OrigemSaida in ('', 'SPE1')
						group by
							r.NomeMotorista
					) r2 on r.NomeMotorista = r2.NomeMotorista
				where
					QtdeSPE1 is not null
					and (
							(isnull(QtdeEPE4, 0) > 0 and isnull(QtdeEPE5, 0) = 0)
							or
							(isnull(QtdeEPE4, 0) = 0 and isnull(QtdeEPE5, 0) > 0)
						)

			) o2 on o.NomeMotorista = o2.NomeMotorista
		where
			IdTransportadora = 1950609251
			and o.ServiceCenter = 'SPE1'
			and o.OrigemSaida in ('', 'SPE1')
	END
	
IF(@clienteid = 45)
	BEGIN
UPDATE r
SET r.tipoveiculo = p.Veiculo
FROM tb_ml_rotas r
INNER JOIN tb_fin_prefatura p
    ON p.idrota = r.idrota
WHERE r.tipoveiculo <> p.Veiculo
  AND p.idtransportadora = '1731064496'
  AND p.servicecenter IN ('SBA6', 'SMR1', 'EMR13')
  AND p.Ano = 2025
  AND p.Mes >= 11 END;

	--Incluído por Saulo Barros em 16/04/2025 para criação da seguinte regra solicitada pela 50+
	--Regra 01: quando for coletado rota do SAL1 em que não tiver informação de xpt, considerar como ECE1
	--Regra 02: quando for coletado rota do SRN1 em que não tiver informação de xpt, considerar como ERN4
	IF(@clienteid = 11)
	BEGIN
		update
			#origem
		set
			OrigemSaida = 'ECE1'
		where
			ServiceCenter = 'SAL1'
			and left(isnull(OrigemSaida,''),1) <> 'E'
			and IdTransportadora = 1726310024
			
		update
			#origem
		set
			OrigemSaida = 'ERN4'
		where
			ServiceCenter = 'SRN1'
			and left(isnull(OrigemSaida,''),1) <> 'E'
			and IdTransportadora = 1726310024

		--se o xpt começar com BR, considera a informação do Service Center
		update
			#origem
		set
			OrigemSaida = ServiceCenter
		where
			left(isnull(OrigemSaida,''),2) = 'BR'
			and IdTransportadora = 1726310024
	
	END

	--Incluído por Saulo Barros em 02/05/2025 para gerar pagamento apenas de motoristas cadastrados e ativos no sistema para 50+
	IF(@clienteid = 11)
	BEGIN
		--apaga rotas que não tiveram UsuarioDA
		delete #origem where UsuarioDA is null

		--apaga rotas de motoristas que não estão ativos
		delete
			o
		from
			#origem o
			join tb_usuario u with(nolock) on o.UsuarioDA = u.usr_cd_usuario and u.cli_cd_codigo_cliente = @clienteid
		where
			u.usr_in_ativo = 0
	END


	--Incluído por Saulo Barros em 05/02/2026 para que os pagamentos a partir da Q2 de Janeiro de 2026 seja considerado o tipo de veiculo da prefatura ao inves do que foi coletado
	IF(@clienteid = 11 and @data_inicial >= '2026-01-16')
	BEGIN
		update 
			r
		set 
			r.TipoVeiculo = p.Veiculo + case when p.ContinuacaoVeiculo is not null then ' - ' + p.ContinuacaoVeiculo else '' end
		from 
			#origem r
			join tb_fin_prefatura p on p.idrota = r.idrota
		where 
			p.idtransportadora = 1726310024
			and p.Veiculo is not null
	END

	drop table if exists #tabela_insert
	CREATE TABLE #tabela_insert(
		[ppr_cd_periodo] [int] NULL,
		[ppr_cd_rota] [varchar](50) NULL,
		[ppr_cd_faixa_km] [varchar](20) NULL,
		[ppr_ds_placa] [varchar](50) NULL,
		[ppr_ds_tipo_veiculo] [varchar](50) NULL,
		[ppr_ds_ciclo] [varchar](50) NULL,
		[ppr_qt_pacotes] [int] NULL,
		[ppr_qt_pontos] [int] NULL,
		[ppr_qt_paradas] [int] NULL,
		[ppr_in_area_risco] [bit] NULL,
		[ppr_in_ajudante] [bit] NULL,
		[ppr_in_dom_fer] [bit] NULL,
		[ppr_vl_base] [decimal](10, 2) NULL,
		[ppr_vl_paradas] [decimal](10, 2) NULL,
		[ppr_vl_risco] [decimal](10, 2) NULL,
		[ppr_vl_ajudante] [decimal](10, 2) NULL,
		[ppr_vl_dom_fer] [decimal](10, 2) NULL,
		[ppr_vl_lancamentos] [decimal](10, 2) NULL,
		[ppr_vl_total_km_real] [decimal](10, 2) NULL,
		[ppr_vl_total_km_minimo] [decimal](10, 2) NULL,
		[ppr_vl_total_km_prefatura] [decimal](10, 2) NULL,
		[ppr_vl_total] [decimal](10, 2) NULL,
		[ppr_dh_criacao] [datetime]  NULL,
		[ppr_cd_usr_criacao] [int]  NULL,
		[ppr_dh_modificacao] [datetime]  NULL,
		[ppr_cd_usr_modificacao] [int]  NULL,
		[ppr_in_ativo] [bit]  NULL,
		[ppr_in_excluido] [bit]  NULL,
		[ppr_cd_motorista] [int] NULL,
		[ppr_vl_insucessos] [int] NULL,
		[ppr_vl_success_delivery] [decimal](10, 5) NULL,
		[ppr_qt_pacotes_entregues] [int] NULL,
		[ppr_qt_pacotes_pendentes] [int] NULL,
		[ppr_bfm_vl_FaixaKM] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_domingo] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_ciclo_pm] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas0_60] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas61_75] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas76_85] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas86_90] [decimal](10, 2) NULL,
		[ppr_bfm_vl_paradas_acima_90] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_ajudante] [decimal](10, 2) NULL,
		[ppr_bfm_vl_adicional_risco] [decimal](10, 2) NULL,
		[ppr_bfm_vl_insucesso] [decimal](10, 2) NULL,
		[ppr_lcto_dt_lancamento] [date] NULL,
		[ppr_lcto_ciclo] [varchar](10) NULL,
		[ppr_lcto_tipo] [varchar](50) NULL,
		[ppr_lcto_vl_risco_ajudante] [decimal](10, 2) NULL,
		[ppr_lcto_qt_pacotes] [int] NULL,
		[ppr_lcto_qt_pontos] [int] NULL,
		[ppr_lcto_observacao] [varchar](1000) NULL,
		[ppr_lcto_usr_criacao] [int] NULL,
		[ppr_lcto_dh_modificacao] [datetime] NULL,
		[ppr_lcto_usr_modificacao] [int] NULL,
		[ppr_lcto_vl_apoio] [decimal](10, 2) NULL,
		[ppr_id_transportadora] [int] NULL,
		[ppr_usou_app] [varchar](10) NULL,
		[ppr_data_referencia] [date] NULL,
		[ppr_base_principal] varchar(30) null,
		[ppr_tipo_rota] varchar(30) null,
		ppr_nome_motorista varchar(300) null,
		ppr_vl_bonus [decimal](10, 2) NULL,
		svc_espelho  varchar(30),
		bkt_vl_km_ideal [decimal](10, 2) NULL,
		ppr_vl_trevo [decimal](10, 2) NULL,
		ppr_vl_pm [decimal](10, 2) NULL,
        ppr_vl_valor_frete [decimal](10, 2) NULL,
        ppr_total_km	decimal(10,2) null,
        ppr_nm_cidade	varchar(100) null,
        ppr_vl_pedagio  decimal(10,2) null,
		ppr_lcto_cd_lancamento int NULL,
		ppr_vl_aluguel decimal(10,2) NULL,
		ppr_vl_desconto decimal(10,2) NULL,
		ppr_vl_recarga decimal(10,2) NULL,
		ppr_per_endereco_nao_visitado decimal(10,2) null,
        ppr_cd_tipo varchar(5) null,
		ppr_nm_cluster varchar(60) null,
		ppr_total_km_meli decimal(10,2) null,
		ppr_total_km_rtt decimal(10,2) null,
		FaixaKm2 [varchar](20) null,
		

		--Incluído por Saulo Barros em 18/06/2025 para poder salvar o bonus ds e o adicinal de km nos campos abaixo
		ppr_vl_bonus_ds decimal(10,2) null,
		ppr_vl_adicional_km decimal(10,2) null,

		--Incluído por Saulo Barros em 20/08/2025 para armazenar na tabela temporária se é ambulancia
		ppr_in_ambulancia bit null,
		ppr_cd_tipo_pgto int null,
		ppr_in_zerar_rota bit null,
		ppr_in_pgto_fixo bit null,

		ppr_nm_origem_km  varchar(100) null
	)
	

CREATE NONCLUSTERED INDEX [IDX_TMP_ppr_cd_periodo_ppr_cd_rota]
ON [dbo].[#tabela_insert] ([ppr_cd_periodo],[ppr_cd_rota])




	drop table if exists #tb_pgto_periodo_rota_edit
	select *
	into #tb_pgto_periodo_rota_edit
	from(
		select
			*
			,cast(SUBSTRING(edit_Faixa_KM, 1, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(12,4)) as edit_km_selecionado
			,row_number() over(partition by edit_rota order by edit_dh_criacao desc) as ordem

		from tb_pgto_periodo_rota_edit (NOLOCK)
		where edit_cd_periodo =  @CodPeriodoPagamento
			and (@avulso is null or edit_cd_espelho = @avulso)
		--where (@idrota is null or edit_rota = @idrota)

		) as a
	where ordem = 1;


	-- Após #tb_pgto_periodo_rota_edit
	-- PERFORMANCE
	CREATE NONCLUSTERED INDEX IX_edit_rota
	ON #tb_pgto_periodo_rota_edit (edit_rota);



    --Etapa de Edit Origem Rotas KM
    --Feito para o cliente alterar a fonte do KM selecionado
    alter table #tb_pgto_periodo_rota_edit add KmEditado decimal(10,4)
    alter table #tb_pgto_periodo_rota_edit add NomeKmEditado varchar(100)
    
    update
        edit
    set
        edit.edit_Total_KM = isnull(case 
                                when lst_ds_label = 'KM do app Irisys'                                  then km.pontosAppRotasTotalKm
                                when lst_ds_label = 'KM latitude e longetude dos Pacotes'               then km.pontosRotasPacotesKm
                                when lst_ds_label = 'Km por trevo a trevo'                              then trv.bkt_vl_km_ideal
                                when lst_ds_label = 'Km do RTT'                                         then rtt.KmRTT
                                when lst_ds_label = 'Faixa km da prefatura'                             then pre.FimIntervalo
                                when lst_ds_label = 'Km do app Irisys ou KM lat e long dos pacotes.'    then isnull(case when km.pontosAppRotasTotalKm = 0 then km.pontosRotasPacotesKm else km.pontosAppRotasTotalKm end,1)
                                when lst_ds_label = 'Km coletado do Silos'                              then r.KmTotal
                             end,0)

      , edit.NomeKmEditado = 'Editado Manualmente - ' + edit.edit_origem_km
    from    
        vw_ml_rotas as r
        inner join #tb_pgto_periodo_rota_edit as edit
            on r.IdRota = edit.edit_rota 
            and edit.edit_origem_km is not null
        inner join tb_lista as lst 
            on lst.lst_nm_lista = 'Parâmetros do financeiro - Quilometragem' 
            and edit.edit_origem_km = lst.lst_ds_label
        left join tb_ml_processamento_km_rotas as km 
            on r.IdKmProcessado = km.id
        left join vw_prefatura_espelhos as pre
            on r.IdRota = pre.IdRota
            and r.IdTransportadora = pre.IdTransportadora
        left join tb_fin_base_km_trevo as trv
            on r.idtrevo = trv.bkt_cd_base_km_trevo
        left join (
                    SELECT IdRota , cast(KmTotal as decimal(10,4)) KmRTT
                    FROM (
                        SELECT *,
                               ROW_NUMBER() OVER (PARTITION BY idrota ORDER BY quinzena DESC) AS rn
                        FROM tb_ml_bsc_rtt WITH (NOLOCK)
                    ) AS sub
                    WHERE rn = 1
            ) AS rtt on rtt.idrota = r.idrota
    where
        r.datareferencia between @data_inicial and @data_final
        and r.idtransportadora = @IdTransportadora
		and (@avulso is null or edit.edit_cd_espelho = @avulso)





		drop table if exists #vw_rotas
		select
			a.*
			,cli_cd_codigo_cliente as IdTransportadoraClic
			,b.TipoVeiculo as TipoVeiculoAlterado
			,null  VersaoDA
			,veiculos.vei_ds_tipo as TipoVeiculoCad
			,case when isnull(veiculos.vei_valor_fixo,0) = 0 then null else veiculos.vei_valor_fixo end ValorFixoPlacaRota
		into #vw_rotas

		from (
		  select
		   a.[IdTransportadora]

		--   ,[Id]
		  ,a.[IdRota]
		  ,[DataReferencia]
		  ,[DataHoraInicio]
		  ,isnull(edit_Ciclo_PM,
				case 
					when a.idtransportadora = 1726310024 and fatura.CicloPM is not null then fatura.CicloPM
					--when a.idtransportadora = 1726310024 and fatura.CicloPM is null and fatura.KmCiclo = 'AMBULANCE' then 'AM'
					when datepart(hour,DataHoraInicio) < 12 then 'AM' 
				else 
					'PM' 
				end
			) Ciclo_Pm
		  ,[StatusRota]
		  ,[SubStatusRota]
		  ,[StatusPrazo]


		  
		  --Alterado em 24/02/25 por Saulo Barros para considerar XPT (OrigemSaida) apenas se começar com a letra E e descosiderar casos como BRNBA366, BRNBA410...
		  --,isnull(edit_Service_Center,case when a.[ServiceCenter] <> OrigemSaida AND base_origem.bss_ds_sigla IS NOT NULL then OrigemSaida else a.ServiceCenter end ) as ServiceCenter
		  --,isnull(edit_Service_Center,case when a.[ServiceCenter] <> OrigemSaida  and left(OrigemSaida,1) in ('E','M') then OrigemSaida else a.ServiceCenter end ) as ServiceCenter
		  ,coalesce(edit_Service_Center,case 
											when --ambulancia = 1 and 
											a.idtransportadora = 1387994348
												then isnull(ctb_saida,case when a.[ServiceCenter] <> OrigemSaida  and left(OrigemSaida,1) = 'E' then OrigemSaida else a.ServiceCenter end)
											else 
												case when a.[ServiceCenter] <> OrigemSaida  and left(OrigemSaida,1) in ('E','M') then OrigemSaida else a.ServiceCenter end
										end ) as ServiceCenter
		  --Fim Alteração

		  ,[NomeServiceCenter]
		  ,[Base]
		  ,isnull( edit_cidade ,CidadeDistante) [CidadeBase]
		  --,case when a.idtransportadora = 2087146923 then coalesce(edit_cidade, Base,CidadeDistante) else ISNULL(edit_cidade, CidadeDistante) end AS CidadeBase
		  ,[TipoOrigemSaida]
		  ,isnull(edit_Service_Center,[OrigemSaida]) OrigemSaida --alterado por saulo barros em 12/01/2025 para considerar a origem saida a informação do SVC caso tenha sido alterado na tabela de edit
		  ,[TipoRota]
		  ,isnull(edit_Tipo_Veiculo, case when a.IdTransportadora in (124442948, 678279205) then isnull(vei_ds_tipo,[TipoVeiculo]) else  [TipoVeiculo] end ) as TipoVeiculo
		  ,[NomeMotorista]
		  ,isnull(edit_Placa,a.[Placa]) as Placa
		  ,[NivelExperienciaMotorista]
		  ,[IdNivelMotorista]
		  ,[NivelMotorista]
		  ,[QuantidadePacotesTransportados]
		  ,[PercentualEntregasBemSucedidas]
		  ,[PercentualEntregasSemRelamacaoes]
		  ,[PossuiAjudante]
		  ,[Ajudante]
		  ,EnderecosVisitados
          ,COALESCE(edit_Total_KM,edit_km_selecionado,
                     case
                        when a.IdTransportadora = 2087146923
                            then cast([vmp_kmpagamento] as decimal(10,2))
                        when a.IdTransportadora = 124442948 and a.servicecenter in ('SRJ1','SRJ10', 'SRJ2' ,'SRJ6')
                            then 1  
						when a.idtransportadora in  (244041012,1950609251)
							then 
								 coalesce([Km_rtt],kmmapapacote,1)
						when a.idtransportadora = 1387994348 then case when [Km_rtt] > 0 then [Km_rtt] else isnull(kmmapapacote,1) end
						when a.idtransportadora = 472463006 then case when [KmTotal] > 0 then [KmTotal] else isnull(kmmapapacote,1) end --incluido por Saulo Barros em 20/02/2026

						--incluído por Saulo Barros em 17/03/2026
						--regra de km para transmaná: 1° Km App, 2° Km RTT, 3° Km Meli, 4° Km Pacote
						when a.idtransportadora = 678279205 then case when kmcoletadoapp > 0 then kmcoletadoapp else case when Km_rtt > 0 then Km_rtt else case when KmTotal > 0 then KmTotal else kmmapapacote end end end

                        else
                           case when kmcoletadoapp = 0 or km_rtt > 0 then coalesce(edit_km_selecionado,km_rtt,kmmapapacote,kmtotal,1) else kmcoletadoapp end
                    end
                ) KmColetado

		--   ,COALESCE(edit_km_selecionado,
        --             case
        --                 when base = LEFT([bkt_nm_cidades], CHARINDEX('- ', [bkt_nm_cidades]) - 1)
        --                     then 1 else cast([vmp_kmpagamento] as decimal(10,2)) end
        --             , case
        --                 when a.IdTransportadora = 2087146923 and (base = LEFT([bkt_nm_cidades], CHARINDEX('- ', [bkt_nm_cidades]) - 1) or KmColetado = 0)
        --                     then 1
        --                 else
        --                     KmColetado   end
        --         ) KmColetado

		  ,isnull(vmp_linkpagamento,
				case
					when a.IdTransportadora  in (643493085)
						then  LinkMapaMeli
				else
					LinkMapa  end ) LinkMapa

		--   ,[LinkMapa]
		  ,isnull(edit_Quantidade_Pacotes, [TotalPacotes]) as TotalPacotes
		  ,isnull(
			edit_quantidade_pacotes_entregues,
			case
				when a.idtransportadora in (2130011770,113907685,643493085,1491631999) and isnull(edit_ambulancia,1) <> 0 and (fatura.KmCiclo = 'AMBULANCE' OR A.Ambulancia = 1 or isnull(edit_ambulancia,0)= 1)
					then 0 
				ELSE [PacotesEntregues] 
			END 
			)PacotesEntregues
		  ,[PacotesPendentes]
		  ,[PacotesNaoEntregue]
		  ,[PacotesEntreguesForaAreaEntrega]
		  ,[PacotesTransferidos]
		  ,[TempoEmRota]
		  ,[TempoChegadaAreaEntrega]
		  ,[TempoAreaEntrega]
		  ,[PercentualProgresso]
		  ,[KmTotal]
		  ,[TempoEmRotaSec]
		  ,[SegundosEntreEntregas]
		  ,[RotaFinalizada]
		  ,[StatusGeralRota]
		  ,Codigo_usuario_motorista
		  ,isnull(edit_Quantidade_Pontos,
                case
					when a.idtransportadora in (2130011770,113907685,643493085,1491631999) and isnull(edit_ambulancia,1) <> 0 and (fatura.KmCiclo = 'AMBULANCE' OR A.Ambulancia = 1 or isnull(edit_ambulancia,0)= 1)
						then 0
					when a.idtransportadora = 113907685
						then fatura.parada
					else
                    [QuantidadePontos] - case when a.idtransportadora = 678279205 then PacotesNaoEntregue else 0 end  
				end  ) as QuantidadePontos,

				case
                when a.idtransportadora in (2130011770,113907685,643493085,1491631999) and isnull(edit_ambulancia,1) <> 0 and (fatura.KmCiclo = 'AMBULANCE' OR A.Ambulancia = 1 or isnull(edit_ambulancia,0)= 1)
                    then coalesce(edit_Quantidade_Paradas,0)
				
				--Adicionado por Saulo Barros em 06/08/2025 para que quando for SDD considerar as paradas coletadas do Irisys pois não vem na prefatura quando é SDD
                when a.idtransportadora = 1726310024 and a.TipoVeiculo like '%SDD%'
					then isnull(edit_Quantidade_Paradas,[QuantidadeParadas])

				when a.idtransportadora in (113907685,1726310024,678279205,1731064496)
                    then coalesce(edit_Quantidade_Paradas,fatura.parada)
				when a.idtransportadora = 2130011770
					then coalesce(edit_Quantidade_Paradas,fatura.parada, [QuantidadeParadas])
				when a.idtransportadora in (1662443209, 1950609251,472463006) --incluido por Saulo em 30/06/2025 para colocar a AC2 para considerar a quantidade de paradas do monitoramento
					then coalesce(edit_Quantidade_Paradas, [QuantidadeParadas])
				else
				    isnull(edit_Quantidade_Paradas,[QuantidadeParadas] - CASE WHEN a.idtransportadora = 113907685 THEN 0 ELSE [PacotesTransferidos] END - case when a.idtransportadora in (1329461926, 113907685,124442948,643493085) then 0 else PacotesNaoEntregue end)
                end as QuantidadeParadas


 		  ,[QuantidadeReclamacoes]
		  ,[QuantidadeAmbulancia]
		  ,[StatusPrimeiraEntrega]
		  ,[StatusSegundaEntrega]
		  ,[DataUltimaEntrega]
		  ,isnull(edit_cidade,[Cidades]			) as [Cidades]
		  ,isnull(edit_cidade,cidadedistante) as [CidadeReferencia]
		  ,[KmColetadoMeli]
		  ,[LinkMapaMeli]
		  ,[KmColetadoAPP]
		  ,[LinkMapaApp]
		  ,isnull(edit_ambulancia,[Ambulancia]) Ambulancia
		  ,edit_ambulancia --preciso desse campo separado pois existem clientes que não olham a ambulancia pela informação que coletamos, e sim pelo que vem na prefatura
		  ,[KmMotorista]
		  ,UsuarioDA
		  ,isnull(edit_usou_app ,UsouAPP) as UsouAPP
		  ,idtrevo
		  ,case when (a.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário com Ajudante',
												'Rental Utilitário com Ajudante', 'Utilitário Elétrico BYD')
			or
					a.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'
							,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35', 'RVH5G50', 'RVH5G47', 'RVH5G49', 'RVG5F53', 'RVG0G04', 'RVG0G07', 'RVH5G46', 'RVH5G52', 'RUV4E94', 'RUV4E98',
							'TCG3I07', 'RUX2J27', 'RUX2J26', 'RUM3C10', 'RUL8C97', 'RUW5E58', 'RUV4E97', 'RUW5E67', 'RUM3C14', 'SIR9G29', 
							'RVH5G41', 'RVH5G43', 'RUX2I97', 'SYZ5B94', 'RUW5E13', 'RVH5G40', 'RUL8C94', 'RUV4E93', 'RUX2J15', 'SJD9D66', 
							'RUL8C67', 'RUM3C16', 'RUW5E12', 'RVP3G53', 'RUX2J02', 'RUL7F93', 'RUL8C79', 'SIM8F42', 'RUW5E59', 'RUW5D81', 
							'RUX2J28', 'RUW5E78', 'SJD9D75', 'RVB8F43', 'RNK7H65', 'RUW5E64', 'RUX2J24', 'RUX2J20', 'RVG0G06', 'SJD9D64', 
							'RUX2J17', 'RUX2J32', 'RUX2I95', 'RUV4E91', 'RUZ1I48', 'RVB8F61', 'RVB8F64', 'RVB8F62', 'RVB8F63', 'SHH6A78', 
							'SIS6B22', 'RUV4E73', 'RUV4E89', 'RUX2J01', 'RUL7F37', 'RUL8C74', 'RUL8C75', 'SHW9H05', 'RUW6G62', 'RUV9I34', 
							'RVH5G22', 'RVH5G23', 'RVH5G24', 'SYD9B89', 'RUL7F53', 'RUW5D91', 'RUW5D83', 'RVG0G05', 'RVD4D30', 'RUM3C36', 
							'RVD4C81', 'RUO6A94', 'SIH2I75', 'RVH5G45', 'RUW5E49', 'RUW5E17', 'SIB2E50', 'RUW5E60', 'RUW5E47', 'RVH5G31', 
							'RUX2C91', 'RVB8F44', 'RUW5E08', 'RUM3C05', 'SIM8E51', 'SII3G79', 'RVG0G03', 'RUW5E16', 'RUX2C88', 'RVG0G08', 
							'RUM3C11', 'SHW9H13', 'RUM2B56', 'RUW5E05', 'QMZ0F77', 'RUZ1I50', 'RVG5F56', 'RUL7G08', 'RVB8F65', 'UAI5H95', 
							'SII3G69', 'RUL8C72', 'RVD4C87', 'RUM3C50', 'RUO6A93', 'SHL9I88', 'RVD4D28', 'SYR9B87', 'RVD4C70', 'RUX2J03', 
							'RUX2J23', 'RNK7G34', 'RUX2J30', 'RVB8F46', 'RUX2I98', 'RUL8C96', 'RUZ1I49', 'RVH5G48', 'RUZ1I47', 'RUZ1I51', 
							'RVH5G42', 'RUZ1I46', 'RVH5G25', 'RVH5G26', 'RVH5G32', 'RUV4F21', 'RUV4F23', 'TCG6F43', 'RUV4F98', 'SJD9E21', 
							'RUO6A95', 'RVD4C89', 'RUZ1I57', 'RUV4E32', 'RUM3C15', 'RVB8F55', 'RVB8F47', 'TCG7H90', 'SUI2E53', 'EOA9C32', 
							'SIM8F23', 'RUH2A40', 'RUO6B45', 'RUL8C98', 'RUV4F13', 'RUX2J07', 'TCC6E30', 'RUX2C89', 'RUV4F12', 'RUX2J31', 
							'RUV4F18', 'RUX2J00', 'SHH6B82', 'RUL7F29', 'RNK7H60', 'RUV4F20', 'SIB2G49', 'SID5I75', 'RNK7H32', 'RUW5E07', 
							'SHO0F24', 'SIN9A77', 'RUW5E19', 'RUV4E95', 'RUV4F19', 'SJE1I64', 'RUX2J22', 'SSV4C07', 'RUV4F22', 'RUW5E04', 
							'RTS2B17', 'RUX2I99', 'RVH5G51', 'RUW5E15', 'RUL8C95', 'RUW5E02', 'SIY2G07', 'SIB2I02', 'FAB9A57', 'RUW5E66', 
							'RUL8C68', 'RVD4C75', 'RVD4C69', 'TAK7B92', 'SFJ5E15', 'SFJ5E17', 'SFJ5E59', 'SFJ5E42', 'SIA7J43','SHZ5D73','SIA7J41'
                            ,'SIA7J19','SIA7J23','SIA7J10','SIA7J12','SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35','CUB4205','RTT0B11'
                            ,'GBL0E72','EOC8B83','SYE0I39','SJD9D65','RVP9C81','RFU0E09','SHM3E82','SYA  3I62 ','TCC  2I37','SII  8D78','SJZ  8I97')
							)
				then 1
				else null end Rental,
		bkt_qt_cidades,
		isnull(cast(LEFT(edit_Faixa_KM, CHARINDEX('/', edit_Faixa_KM) - 1) as decimal(10,2)), bkt_vl_km_ideal) as kmtrevo,
        tipo,
		fatura.InicioIntervalo km_prefatura,
		case when edit_zerar_pagamento = 1 then 1 else 0 end ppr_in_zerar_rota

		from  #origem as a

		inner join  tb_clientes as cli (NOLOCK)
		on a.idtransportadora  = cli.cli_id_logistics

		left join  tb_motorista as mot
		on a.usuarioda = mot_cd_usuario

		left join tb_fin_contrato_base ctb
		on a.servicecenter = ctb.ctb_svc
		and mot.mot_ctn_cd_tipo_contrato = ctb.ctb_cd_contrato
		and ctb_cd_cliente = cli.cli_cd_codigo_cliente

		left join #tb_pgto_periodo_rota_edit as b
		  on CONVERT(VARCHAR,a.IdRota) = b.edit_rota



	  left join (
				select* 
				from tb_fin_base_km_trevo with (nolock)
				where bkt_cd_transportadora = 2087146923
				) trevo
	  on a.idtrevo = trevo.bkt_cd_base_km_trevo

	  left join [tb_validacao_mapas] as altermapa (NOLOCK)
	  on altermapa.vmp_cd_rota  = a.idrota

      left join vw_fin_prefatura as fatura (NOLOCK)
        on a.idtransportadora = fatura.IdTransportadora
        and a.idrota = fatura.idrota and fatura.tipopf = @TipoOperacao

	left join (
				select
					cli_id_logistics,a.* 
				from tb_veiculos as a (NOLOCK)
				inner join tb_clientes as b (NOLOCK)
				on a.vei_cd_cliente = b.cli_cd_codigo_cliente
				where
					vei_in_ativo = 1
					and vei_in_excluido = 0
			  ) as veiculo	
	on a.placa = veiculo.vei_ds_placa
	and a.idtransportadora = veiculo.cli_id_logistics

	LEFT JOIN tb_bases as base_origem (NOLOCK) on base_origem.bss_ds_sigla = a.OrigemSaida
						AND base_origem.bss_cd_idtransportadora = a.IdTransportadora

						--Alterado em 24/02/25 por Saulo Barros para considerar XPT (OrigemSaida) apenas se começar com a letra E e descosiderar casos como BRNBA366, BRNBA410...
						and left(a.OrigemSaida,1) = 'E'

		 ) as a

		left join (
					select a.*,b. cli_id_logistics
					from tb_fin_resultado_financeiro_alteracao as a (NOLOCK)
					inner join tb_clientes as b (NOLOCK)
					on a.idtransportadora = b.cli_cd_codigo_cliente
					) as b
		on a.IdTransportadora = b.cli_id_logistics
		and a.idrota = b.idrota


		inner join  tb_clientes as cli (NOLOCK)
		on a.idtransportadora  = cli.cli_id_logistics

		left join tb_veiculos veiculos with (nolock) on a.Placa = veiculos.vei_ds_placa 
															and cli.cli_cd_codigo_cliente = veiculos.vei_cd_cliente
															and veiculos.vei_in_ativo = 1
															and veiculos.vei_in_excluido = 0

	where cli.cli_cd_codigo_cliente <> 7;



	-- Após #vw_rotas (antes dos UPDATEs encadeados)
	-- PERFORMANCE
	CREATE NONCLUSTERED INDEX IX_vwrotas_IdRota
	ON #vw_rotas (IdRota)
	INCLUDE (NomeMotorista, DataReferencia, IdTransportadora, ServiceCenter, OrigemSaida);

	CREATE NONCLUSTERED INDEX IX_vwrotas_NomeMotorista
	ON #vw_rotas (NomeMotorista)
	INCLUDE (ServiceCenter, OrigemSaida);



	alter table #vw_rotas add svc_espelho varchar(50);

	update #vw_rotas
	set idtransportadora = case when idtransportadoraclic = 1 then 7 else idtransportadoraclic end 

	--gera o pagamento do motorista para o svc que ele teve mais rota

		update 
			a
		set	
			--Regra criada por Saulo Barros em 24/02/2025 para não considerar para 50+, onde eles possuem caso que um motorista atende em mais de um svc
			--a.servicecenter = case when a.idtransportadora in (11) then isnull(edit_Service_Center,a.servicecenter) else isnull(edit_Service_Center,b.servicecenter) end
		
			--Regra criada por Saulo Barros em 24/02/2025 para não considerar para 50+, onde eles possuem caso que um motorista atende em mais de um svc
			--,svc_espelho = b.servicecenter --  b.NomeServiceCenter
			svc_espelho = case when a.idtransportadora in (11,1,56) and @clienteid <> 7 then isnull(edit_Service_Center,a.servicecenter) else b.servicecenter end --  b.NomeServiceCenter
			--atualiza a base quando e ambulancia de xpt
			--,a.servicecenter = case when a.idtransportadora in (61) and @clienteid <> 7 then isnull(edit_Service_Center,b.servicecenter) else a.servicecenter end --  b.NomeServiceCenter
		from 
			#vw_rotas as a
			left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,a.IdRota) = edit.edit_rota
			left join (
				select 
					*
				,row_number() over(partition by nomemotorista order by qtd desc) ordem
				from(
					select
						nomemotorista
						,case when origemsaida is not null then origemsaida else servicecenter end servicecenter
						,NomeServiceCenter
						,count(*) qtd
					from #vw_rotas
					group by nomemotorista,case when origemsaida is not null then origemsaida else servicecenter end,NomeServiceCenter
				) as a
		) as b
		on a.nomemotorista = b.nomemotorista
		where b.ordem = 1

	--and edit.ordem = 1

	alter table #vw_rotas add kmRTT decimal(10,2) 
	update 
		r
	set 
		r.KmRTT = case when rtt.KmTotal < 1 then 1 else cast(rtt.KmTotal as int) end --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa
	from
		#vw_rotas r
		join tb_ml_bsc_rtt rtt on r.IdRota = rtt.IdRota 
								and cast(cast(rtt.Ano as varchar(4)) + '-' + cast(rtt.Mes as varchar(2)) + '-' + cast(case when rtt.Quinzena = 1 then 1 else 16 end as varchar(2)) as date) between @data_inicial and @data_final
	

	
	--Adicionado por Saulo Barros em 21/11/2025 para caso não tenha sido coletado km RTT, considerar como 1 o km
	if (@clienteid = 11)
	begin
		update #vw_rotas set KmRTT = 1 where KmRTT is null
	end


	IF(@clienteid = 57)
	begin
		update 
			r
		set 
			r.KmRTT =  CASE 
							WHEN r.IdTransportadora = 57 AND ISNULL(rtt.KmTotal, 0) < 1 THEN 1 
							WHEN r.IdTransportadora = 57 THEN CAST(rtt.KmTotal AS decimal(10,4))
							ELSE cast(rtt.KmTotal as int) 
						END, 
			r.KmColetado = CASE 
								WHEN r.IdTransportadora = 57 AND ISNULL(rtt.KmTotal, 0) < 1 THEN 1 
								WHEN r.IdTransportadora = 57 THEN CAST(rtt.KmTotal AS decimal(10,4))
								ELSE r.KmColetado 
							END
		FROM 
			#vw_rotas r
			LEFT JOIN tb_ml_bsc_rtt rtt ON r.IdRota = rtt.IdRota
				and			(
            CAST(@data_inicial AS DATE) BETWEEN 
                DATEFROMPARTS(rtt.Ano, rtt.Mes, CASE WHEN rtt.Quinzena = 1 THEN 1 ELSE 16 END)
                AND 
                DATEFROMPARTS(rtt.Ano, rtt.Mes, 
                    CASE 
                        WHEN rtt.Quinzena = 1 THEN 15 
                        ELSE DAY(EOMONTH(DATEFROMPARTS(rtt.Ano, rtt.Mes, 1))) 
                    END
                )
            OR
            CAST(@data_final AS DATE) BETWEEN 
                DATEFROMPARTS(rtt.Ano, rtt.Mes, CASE WHEN rtt.Quinzena = 1 THEN 1 ELSE 16 END)
                AND 
                DATEFROMPARTS(rtt.Ano, rtt.Mes, 
                    CASE 
                        WHEN rtt.Quinzena = 1 THEN 15 
                        ELSE DAY(EOMONTH(DATEFROMPARTS(rtt.Ano, rtt.Mes, 1))) 
                    END
                )
				) ---- Adicionado por Matheus trecho para considerar também @data_final em 18/07 por conta de casos com KM Zerados.
		end

	
	--Adicionado por Saulo Barros em 16/01/2026
	--Parceiro spot considera primeiro kmcoletadoapp e depois kmrtt (válido a partir da Q2 de Janeiro de 2026)
	--if @clienteid = 56 and @data_inicial >= '2026-01-16'
	--begin
	--	update 
	--		r
	--	set 
	--		r.KmColetado = case when KmColetadoAPP > 0 then KmColetadoAPP else case when KmRTT > 0 then KmRTT else KmColetado end end --coalesce(KmColetadoAPP,KmRTT,KmColetado)
	--	FROM 
	--		#vw_rotas r
	--end


	--Incluído por Saulo Barros em 01/07 para considerar km da ac2 o rtt
	--Inclusão do isnull(edit.edit_total_km) por Saulo Barros en 08/07/2025 para considerar o km se tiver editado
	IF(@clienteid = 45)
	begin
		update 
			r
		set 
			r.KmColetado = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal is null then 100 else case when isnull(rtt.KmTotal,0) < 1 then 1 else rtt.KmTotal end end) --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa
			,r.KmRTT = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal is null then 100 else case when isnull(rtt.KmTotal,0) < 1 then 1 else rtt.KmTotal end end) --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa 
		from
			#vw_rotas r
			left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota 
			left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,r.IdRota) = edit.edit_rota
	end


	--Adicionado por Matheus 29/09/2025 -- OTL considerar KMRtt
		IF(@clienteid = 64)
	begin
		update 
			r
		set 
			r.KmColetado = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal is null then 100 else case when isnull(rtt.KmTotal,0) < 1 then 1 else rtt.KmTotal end end) --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa
		   ,r.KmRTT = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal is null then 100 else case when isnull(rtt.KmTotal,0) < 1 then 1 else rtt.KmTotal end end) --altera para 1 km quando o km do rtt vier 0 para poder entrar na primeira faixa 
		from
			#vw_rotas r
			left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota 
			left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,r.IdRota) = edit.edit_rota
		where  r.ServiceCenter in ('SSP8', 'SS12', 'SSP28', 'SSP24', 'SSP14') 
	end


	

	--Incluído por Saulo Barros em 09/07 para considerar km da Rodoprime o rtt, se não tiver RTT continua o que era antes (KmColetado)
	--Incluido por Gabriel Ramos em 29/07 para considerar km de acordo com a regra da Rodoprime (se não tiver RTT continua o que era antes (KmColetado))
	IF @clienteid in ( 57)
	begin
		update 
			r
		set 
			r.KmColetado = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal < 1  or rtt.KmTotal is null then isnull(pre.InicioIntervalo,1) else isnull(rtt.KmTotal,1) end)
			,r.KmRTT = coalesce(edit.edit_total_km, edit.edit_km_selecionado, case when rtt.KmTotal < 1  or rtt.KmTotal is null then isnull(pre.InicioIntervalo,1) else isnull(rtt.KmTotal,1) end)
		from
			#vw_rotas r
			left join tb_fin_prefatura as pre
			on r.idrota = pre.idrota 
			and r.DataReferencia = pre.DataTermino
			left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota 
			left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,r.IdRota) = edit.edit_rota
	end

	IF @clienteid in (61)
	begin
		update 
			r
		set 
			r.KmColetado = coalesce(edit.edit_Total_KM, edit.edit_km_selecionado, case when rtt.KmTotal < 1  or rtt.KmTotal is null then coalesce(r.KmColetado,pre.InicioIntervalo,1) else isnull(rtt.KmTotal,1) end)
			,r.KmRTT = coalesce(edit.edit_Total_KM, edit.edit_km_selecionado, case when rtt.KmTotal < 1  or rtt.KmTotal is null then coalesce(r.KmColetado,pre.InicioIntervalo,1) else isnull(rtt.KmTotal,1) end)
		from
			#vw_rotas r
			left join tb_fin_prefatura as pre
			on r.idrota = pre.idrota 
			and r.DataReferencia = pre.DataTermino
			left join tb_ml_bsc_rtt rtt with(nolock) on r.IdRota = rtt.IdRota 
			left join #tb_pgto_periodo_rota_edit as edit on CONVERT(VARCHAR,r.IdRota) = edit.edit_rota
	end


	alter table  #vw_rotas add kmAC2 decimal(10,2) 
	alter table  #vw_rotas add adicionalKm bit null

	update #vw_rotas 
	set kmAC2 = case when IdTransportadora in (45) and KmColetado >100 then KmColetado -100 else KmColetado  end
	,KmColetado = case when  IdTransportadora in (45) and KmColetado >100  then 100 else  KmColetado end
	,adicionalKm = case when IdTransportadora in (45) and KmColetado >100 then 1 else 0  end

	--comentado por Saulo Barros em 04/08/2025
	alter table #vw_rotas add menor_km int 
	/*
	--considera menor km entre KmMeli, RTT e Prefatura quando for 50+ e o SVC for SBA1, SBA6 ou SBA2
	alter table #vw_rotas add menor_km int 
	update 
		#vw_rotas
	set 
		menor_km = case 
						when (kmRTT <= KmTotal or KmTotal is null) and (KmRTT <= km_prefatura or km_prefatura is null) then kmRTT
						when (KmTotal <= kmRTT or kmRTT is null) and (KmTotal <= km_prefatura or km_prefatura is null) then KmTotal
						else km_prefatura 
					end
	where
		idtransportadora = 11
		and servicecenter in ('SBA1', 'SBA6', 'SBA2')
	*/


	ALTER TABLE #vw_rotas ADD KmParceiroSpot DECIMAL(10,2)
		
	UPDATE #vw_rotas
	SET KmParceiroSpot = CASE WHEN IdTransportadora = 472463006 AND OrigemSaida = 'EMG17' AND KmColetado > 100 THEN KmColetado - 100 ELSE KmColetado END


	-- Incluído em 19/03/2025 por Saulo Barros para considerar o dia da semana (para cálculo de domingo ou feriado) o menor dia em que teve um pacote com status de entregue ou não entrege
	alter table #vw_rotas add DataInicio date
	update
		r
	set
		DataInicio = isnull(p.DataInicio, DataReferencia)
	from
		#vw_rotas r
		left join (
			select
				r.IdRota, 
				min(cast(p.DataHoraEntrega as date)) DataInicio
			from
				#vw_rotas r
				join tb_clientes c with(Nolock) on r.IdTransportadora = c.cli_cd_codigo_cliente
				join tb_ml_pacotes p with(nolock) on r.IdRota = p.IdRota and c.cli_id_logistics = p.IdTransportadora
			where
				p.StatusEntrega in ('delivered', 'not_delivered')
			group by
				r.IdRota
		) p on r.IdRota = p.IdRota


	
	-- Incluído por Saulo Barros em 04/10/2025 para criação de seguinte regra:
	-- Regra 01: Quando a rota for dos SVC SCE1, ECE1, ECE3, será pago 84% do valor que veio na prefatura, considerando também as paradas. O desconto será abatido também porém será calculado a partir de outra procedure
	-- Regra 02: Quando a rota for dos SVC SPA1, SPI1, será pago 83% do valor que veio na prefatura, considerando também as paradas. O desconto será abatido também porém será calculado a partir de outra procedure
	-- Só será criado a regra caso o motorista não tenha um pagamento fixo por placa
	-- Altero o valor ValorFixoPlacaRota pois na regra da procedure mais abaixo, ele não calcula valor de faixa quando este campo é preenchido 
	if @clienteid = 11 and @data_inicial >= '2025-09-16'
	begin
		
		drop table if exists #pgto_prefatura
		select
			IdRota,
			Total + isnull(VLParada,0) TotalPrefatura
			into #pgto_prefatura
		from
			tb_fin_prefatura with(nolock)
		where
			IdTransportadora = 1726310024
			and DataTermino between @data_inicial and @data_final
			and Total > 0

		update
			r
		set
			--r.ValorFixoPlacaRota = case when ServiceCenter in ('SCE1', 'ECE1', 'ECE3') then p.TotalPrefatura * 0.84 else p.TotalPrefatura * 0.83 end
			r.ValorFixoPlacaRota = p.TotalPrefatura * 0.84
		from 
			#vw_rotas r
			join #pgto_prefatura p on r.IdRota = p.IdRota
		where
			ServiceCenter in ('SCE1', 'ECE1', 'ECE3', 'SPA1', 'SPI1')
			and ValorFixoPlacaRota is null
	end
	

	-- Regra criada por Saulo Barros em 09/01/2026 para que todas as rotas da 50+ de EBA26, EBA27 e SBA4 sejam consideradas sempre como AM
	if @clienteid = 11 and @data_inicial >= '2025-12-16'
	begin
		update 
			#vw_rotas 
		set 
			Ciclo_Pm = 'AM'
		where
			ServiceCenter in ('EBA26', 'EBA27', 'SBA4')
	end


	-- Regra criada por Saulo Barros em 19/01/2026 para que todas as rotas da Transmaná no período de 01/01/2026 a 10/01/2026 das bases 
	--SSP7, SSP25, SSP29, SSP34, SSP38, SSP40, SSP49 sejam consideradas como AM
	if @clienteid = 37 and @data_inicial = '2026-01-01'
	begin
		update 
			#vw_rotas 
		set 
			Ciclo_Pm = 'AM'
		where
			ServiceCenter in ('SSP7', 'SSP25', 'SSP29', 'SSP34', 'SSP38', 'SSP40', 'SSP49')
			and DataReferencia between '2026-01-01' and '2026-01-10'
	end


	-- Regra criada por Saulo Barros em 27/02/2026 para que todas as rotas da Transmaná das bases 
	--SSP7, SSP25, SSP29, SSP34, SSP38, SSP40, SSP49 sejam consideradas como AM
	if @clienteid = 37 and @data_inicial >= '2026-02-01'
	begin
		update 
			#vw_rotas 
		set 
			Ciclo_Pm = 'AM'
		where
			ServiceCenter in ('SSP7', 'SSP25', 'SSP29', 'SSP34', 'SSP38', 'SSP40', 'SSP49')
	end



	drop table if exists  #tb_ml_service_center
	select *
	into #tb_ml_service_center
	from tb_ml_service_center (NOLOCK);

	-- Após #tb_ml_service_center
	-- PERFORMANCE
	CREATE NONCLUSTERED INDEX IX_svc
	ON #tb_ml_service_center (idtransportadora, svc_cd_service_center);


	update a
	set idtransportadora = cli_cd_codigo_cliente
	from #tb_ml_service_center as a
	inner join tb_clientes as b (NOLOCK)
	on a.idtransportadora = b.cli_id_logistics;

	insert into #tabela_insert
	(ppr_cd_periodo
	,ppr_cd_rota
	,ppr_cd_faixa_km
	,ppr_ds_placa
	,ppr_ds_tipo_veiculo
	,ppr_ds_ciclo
	,ppr_qt_pacotes
	,ppr_qt_pontos
	,ppr_qt_paradas
	,ppr_in_area_risco
	,ppr_in_ajudante
	,ppr_in_dom_fer
	,ppr_vl_base
	,ppr_vl_paradas
	,ppr_vl_risco
	,ppr_vl_ajudante
	,ppr_vl_dom_fer
	,ppr_vl_lancamentos
	,ppr_vl_total_km_real
	,ppr_vl_total_km_minimo
	,ppr_vl_total_km_prefatura
	,ppr_vl_total
	,ppr_cd_usr_criacao
	,ppr_dh_modificacao
	,ppr_cd_usr_modificacao
	,ppr_in_ativo
	,ppr_in_excluido
	,ppr_cd_motorista
	,ppr_vl_insucessos
	,ppr_vl_success_delivery
	,ppr_qt_pacotes_entregues
	,ppr_qt_pacotes_pendentes
	,ppr_usou_app
	,ppr_data_referencia
	,ppr_base_principal
	,ppr_tipo_rota
	,ppr_nome_motorista
	,ppr_vl_bonus
	,svc_espelho
	,bkt_vl_km_ideal
	,ppr_vl_trevo
	,ppr_lcto_observacao
    ,ppr_vl_pm
    ,ppr_vl_valor_frete
    ,ppr_total_km
    ,ppr_nm_cidade
    ,ppr_vl_pedagio
	,ppr_lcto_cd_lancamento
	,ppr_vl_aluguel
	,ppr_vl_recarga
	,ppr_per_endereco_nao_visitado
    ,ppr_cd_tipo
	,ppr_nm_cluster
	,ppr_total_km_meli
	,ppr_total_km_rtt
	,FaixaKm2
	,ppr_vl_bonus_ds
	,ppr_vl_adicional_km
	,ppr_in_ambulancia
	,ppr_cd_tipo_pgto
	,ppr_in_zerar_rota
	,ppr_in_pgto_fixo
	,ppr_nm_origem_km
	)
		SELECT  DISTINCT
			@CodPeriodoPagamento as ppr_cd_periodo,
			rotas.IdRota as ppr_cd_rota,
			--rotas.FaixaKm as ppr_cd_faixa_km,
			FaixaKm as ppr_cd_faixa_km,
			rotas.Placa as ppr_ds_placa,
			rotas.TipoVeiculo as ppr_ds_tipo_veiculo,
			rotas.CicloPM as ppr_ds_ciclo,
			rotas.TotalPacotes as ppr_qt_pacotes,
			rotas.QuantidadePontos as ppr_qt_pontos,
			
		
            --Comentado por Saulo Barros em 30/06 pois a informação do espelho tem que ser a quantidade de paradas
			--case 
			--	when bfa_calcula_por_parada = 0  then isnull(QuantidadePontos,0) 
			--	when bfa_calcula_por_parada = 1  then isnull(QuantidadeParadas,0) 
			--	when bfa_calcula_por_parada is null  then isnull(PacotesEntregues,0) 
			--	else isnull(ValorParadas,0) end as ppr_qt_paradas,
			rotas.QuantidadeParadas as ppr_qt_paradas,



			case when rotas.RISCO > 0 then 1 else 0 end ppr_in_area_risco,
			case when AJUDANTE > 0 then 1 else 0  end ppr_in_ajudante,

			--Alterado por Saulo Barros em 29/07/2025 para considerar domingo ou feriado pelo campo criado na subconsulta
			--e não verificando se teve algum valor
			ppr_in_dom_fer,
			--case when DomingoOuFeriado > 0 then 1 else 0  end ppr_in_dom_fer,

			--case when rotas.SaidaKmPreFatura < rotas.Saida  and rotas.SaidaKmPreFatura > 0 then rotas.SaidaKmPreFatura else rotas.Saida end as ppr_vl_base,
			case 
				--when ValorFixoPlacaRota is not null then isnull(ValorFixoPlacaRota,0)
				when idtransportadora = 63 and ambulanciaPrefatura = 1 then 0
				when IdTransportadora in(11,45) and ValorFixoPlacaRota is not null then isnull(ValorFixoPlacaRota,0)
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then 0
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then isnull(rotas.SaidaKm0a100,0)
				when IdTransportadora = 11 and ambulanciaPrefatura = 1 and ServiceCenter = 'SPA1' then isnull(SaidaKm0a100AM,0)
				when IdTransportadora = 11 and ambulanciaPrefatura = 1 and ServiceCenter = 'SBA1' and CidadeBase = 'São Sebastião do Passé' and rotas.TipoVeiculo in ('Veículo de Passeio', 'Utilitários') then isnull(SaidaKm0a100AMSVC,0)
				when IdTransportadora = 11 and ambulanciaPrefatura = 1 then isnull(rotas.SaidaKm0a100,0)
                when IdTransportadora = 40 and rotas.TipoVeiculo = 'Van' then isnull(ValorFrete,0)
				
				--incluído por Saulo Barros em 15/06/2026
				when IdTransportadora = 11 and ServiceCenter in ('EBA26', 'EBA27') and rotas.Data >= '2026-05-16' then coalesce(rotas.SaidaKmPreFatura,rotas.SaidaKmRTT,0)

				--incluído por Saulo Barros em 17/07/2026 para considear a prefatura como origem km principal para tudo a partir da Q2 de Junho de 2026
				when IdTransportadora = 11 and rotas.Data >= '2026-06-16' then coalesce(rotas.SaidaKmPreFatura,rotas.SaidaKmRTT,0)


				when IdTransportadora = 11 then isnull(rotas.SaidaKmRTT,0)
                when IdTransportadora = 49 and ServiceCenter in ('SRJ1','SRJ10', 'SRJ2' ,'SRJ6') then
																									case when IdTransportadora in (49)  and EnderecoNaoVisitadoPrefatura = 1 then 0 else  isnull(rotas.Saida,0) END 
                -- when IdTransportadora in (34,40,46,49,47) and rotaprefatura is not null  then 
				--case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 1 and FaixaKm is not null then 0 else  rotas.SaidaKmPreFatura END
                when IdTransportadora in (34,40,46,49,47,63) and rotaprefatura is not null then
                case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 0 and FaixaKm is not null then 0 else  case 
																																	when IdTransportadora in (40) and rotas.Saida < rotas.SaidaKmPreFatura and rotas.Saida > 0
																																		then isnull(rotas.Saida,0)
																																else   isnull(rotas.SaidaKmPreFatura,0)
																																	END END
    --            when IdTransportadora = 1 and Rental = 1 then isnull(rotas.Saida, 0)
				--when IdTransportadora = 1 and CidadeBase = 'Presidente Prudente' then isnull(ValorFrete, 0)
				--when IdTransportadora = 1 then isnull(rotas.ppr_vl_trevo, 0)
				--Adicionado por saulo barros em 21/02/2026 para que para base SRJ10, tipo de veiculos Motocileta e Triciclo seja valor frete cadastrado * total de pacotes entregues
				when IdTransportadora = 56 and rotas.TipoVeiculo in ('Motocicleta', 'Triciclos') and ServiceCenter = 'SRJ10' then isnull(rotas.PacotesEntregues,0) * isnull(rotas.SaidaKm0a100,0)
				
				when IdTransportadora in (56,67,68) and ServiceCenter not in ('MRJ8') and rotas.TipoVeiculo = 'Motocicleta' then rotas.TotalPacotes * isnull(rotas.Saida,0)

			
				
				--Comentado por Saulo Barros em 18/06 pois está sendo feito o calculo do km adicional em ValorAdicionalKm
				--when IdTransportadora in (56,45) and kmAC2>100 then isnull(rotas.Saida + ValorKmAC2 ,0)
                else 
                    isnull(rotas.Saida,0)
                end  
            ppr_vl_base,


			case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 1 then 0 
			else
			case
				--Adicionado por Saulo Barros em 02/09/2025
				--Regra: quando é pago um valor fixo pela placa, não calcula parada para 50+
				when idtransportadora in(11,45) and ValorFixoPlacaRota is not null then 0

				--Adicionado por Saulo Barros em 16/12
				--Regra: quando for ambulancia não pagar valor de parada
				when idtransportadora = 11 and ambulanciaPrefatura = 1 then 0

				when idtransportadora = 45 then isnull(ValorParadas,0)
				--when idtransportadora = 61 then isnull(ValorPacotesEntregues,0)
				when bfa_calcula_por_parada = 0  then isnull(ValorPontos,0)
				when bfa_calcula_por_parada = 1  then case when idtransportadora = 27 and isnull(QuantidadeParadas,0) < 20 and  rotas.TotalPacotes > 70   then 40 else  isnull(ValorParadas,0) end  
				when bfa_calcula_por_parada is null and idtransportadora not in (61,59)  then isnull(ValorPacotesEntregues,0) 
				else isnull(ValorParadas,0) end
			END as ppr_vl_paradas,


			rotas.RISCO as ppr_vl_risco,
			rotas.AJUDANTE as ppr_vl_ajudante,

			--Adicionado por Saulo Barros em 19/08/2025
			--Regra: quando é pago um valor fixo pela placa, não calcula valor para domingo e feriado para 50+
			case when idtransportadora in(45, 11) and ValorFixoPlacaRota is not null then
				0
			else
				isnull(DomingoOuFeriado,0) 
			end as ppr_vl_dom_fer,

			isnull(rotas.ValorApoioLancamentos,0) as ppr_vl_lancamentos,
			--0 as ppr_vl_lancamentos,
			0 as ppr_vl_total_km_real,
			rotas.SaidaKm0a100 as ppr_vl_total_km_minimo,
			rotas.SaidaKmPreFatura as ppr_vl_total_km_prefatura,

            case 
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then 0
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then rotas.SaidaKm0a100
				
			else
				isnull(
						case 
				--when ValorFixoPlacaRota is not null then ValorFixoPlacaRota
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then 0
                when IdTransportadora = 34 and ambulanciaPrefatura = 1 then rotas.SaidaKm0a100
				when IdTransportadora = 11 and ambulanciaPrefatura = 1 then rotas.SaidaKm0a100
                when IdTransportadora = 40 and rotas.TipoVeiculo = 'Van' then ValorFrete
				--incluído por Saulo Barros em 15/06/2026
				when IdTransportadora = 11 and ServiceCenter in ('EBA26', 'EBA27') and rotas.Data >= '2026-05-16' then coalesce(rotas.SaidaKmPreFatura,rotas.SaidaKmRTT,0)

				--incluído por Saulo Barros em 17/07/2026 para considear a prefatura como origem km principal para tudo a partir da Q2 de Junho de 2026
				when IdTransportadora = 11 and rotas.Data >= '2026-06-16' then coalesce(rotas.SaidaKmPreFatura,rotas.SaidaKmRTT,0)

				when IdTransportadora = 11 then rotas.SaidaKmRTT
                when IdTransportadora = 49 and ServiceCenter in ('SRJ1','SRJ10', 'SRJ2' ,'SRJ6') then
																									case when IdTransportadora in (49)  and EnderecoNaoVisitadoPrefatura = 1 then 0 else  rotas.Saida END 
			 -- when IdTransportadora in (34,40,46,49,47) and rotaprefatura is not null  then 
				--case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 1 and FaixaKm is not null then 0 else  rotas.SaidaKmPreFatura END
                when IdTransportadora in (34,40,46,49,47,63) and rotaprefatura is not null then
                case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 0 and FaixaKm is not null then 0 else  case 
																																	when IdTransportadora in (40) and rotas.Saida < rotas.SaidaKmPreFatura and rotas.Saida > 0
																																		then isnull(rotas.Saida,0)
																																else   isnull(rotas.SaidaKmPreFatura,0)
																																	END END

    --            when IdTransportadora in (1) and Rental = 1  then isnull(rotas.Saida,0)
				--when IdTransportadora in (1) and CidadeBase = 'Presidente Prudente'  then isnull(rotas.Saida,0)
				--when IdTransportadora in (1) then isnull(rotas.ppr_vl_trevo,0)
				--Adicionado por saulo barros em 21/02/2026 para que para base SRJ10, tipo de veiculos Motocileta e Triciclo seja valor frete cadastrado * total de pacotes entregues
				when IdTransportadora = 56 and rotas.TipoVeiculo in ('Motocicleta', 'Triciclos') and ServiceCenter = 'SRJ10' then isnull(rotas.PacotesEntregues,0) * isnull(rotas.SaidaKm0a100,0)

				when IdTransportadora in (56) and rotas.TipoVeiculo = 'Triciclos' then rotas.TotalPacotes * isnull(rotas.Saida,0)
				
				--Comentado por Saulo Barros em 18/06 pois está sendo feito o calculo do km adicional em ValorAdicionalKm
				--when IdTransportadora in (56,45) and kmAC2>100 then isnull(isnull(rotas.Saida,0) + ValorKmAC2 ,0) 
                else 
                    rotas.Saida
                end 
				,0)
				+
				isnull(Bonificacao,0)+isnull(ppr_vl_pedagio ,0) +
				+
				case when IdTransportadora in (49,47)  and EnderecoNaoVisitadoPrefatura = 1 then 0 else
				case 
						when bfa_calcula_por_parada = 0  then isnull(ValorPontos,0)
						when bfa_calcula_por_parada = 1  then isnull(ValorParadas,0) 
						when bfa_calcula_por_parada is null and idtransportadora <> 61  then isnull(ValorPacotesEntregues,0) 
					else isnull(ValorParadas,0) end end 

				+isnull(RISCO,0)+isnull(AJUDANTE,0)+isnull(ASCRESC,0)
				+isnull(DomingoOuFeriado,0)
				+isnull(ppr_vl_recarga,0)
				
            end 
			--+ 0
			+ isnull(rotas.ValorApoioLancamentos,0) 
			+ isnull(ValorBonusDs,0)
			+ isnull(ValorAdicionalKm,0)

			as ppr_vl_total ,

			8851                   as ppr_cd_usr_criacao,
			getdate()              as ppr_dh_modificacao,
			8851                   as ppr_cd_usr_modificacao,
			1                      as ppr_in_ativo,
			0                      as ppr_in_excluido,
			rotas.UsuarioDA        as ppr_cd_motorista,
			PacotesNaoEntregue     as ppr_vl_insucessos,
			--NULLIF(rotas.PacotesEntregues,0) / CAST(NULLIF(rotas.TotalPacotes,0) as decimal(9,2)) as ppr_vl_success_delivery,
			case when isnull(rotas.TotalPacotes,0) = 0 then 0 else isnull(rotas.PacotesEntregues,0) / CAST(isnull(rotas.TotalPacotes,0) as decimal(9,2)) end as ppr_vl_success_delivery,
			rotas.PacotesEntregues as ppr_qt_pacotes_entregues,
			PacotesPendentes       as ppr_qt_pacotes_pendentes,
			UsouAPP					as ppr_usou_app,
			Data as ppr_data_referencia,
			ServiceCenter as ppr_base_principal,
			'Inteira' as TipoRota,
			NomeMotorista as ppr_nome_motorista,
			isnull(Bonificacao,0) as ppr_vl_bonus,
			svc_espelho,
			bkt_vl_km_ideal,
			ppr_vl_trevo,
			observacao as ppr_lcto_observacao,
            ValorPM as ppr_vl_pm,
            ValorFrete as ppr_vl_valor_frete,
            -- case when IdTransportadora = 61 then rotas.KmTotal else rotas.KmColetado end as ppr_total_km,
			case 
				when IdTransportadora = 61 then Isnull(rotas.KmRTT,rotas.KmTotal)  -- Adicionado em 19/11/2025 para ajustar KM Rodoprime

				--Comentado a regra para parceiro spot (56) pois no código acima a tratativa está sendo feito no KmColetado em 16/01/2026 por Saulo Barros
				--when IdTransportadora in (56) then rotas.KmTotal  --retirado transportadora 37 do filtro em 03/11/2025 por Saulo Barros por conta da task https://app.clickup.com/t/86ad06r9m 
			    when IdTransportadora = 57 AND rotas.KmRTT <= 1 then rotas.KmTotal  
			    when IdTransportadora = 57 then rotas.KmRTT  
				
				--comentado por Saulo Barros em 17/03/2026 pois a regra de qual km é utilizado já está sendo feita no código mais acima na definação do valor do KmColetado
				--when idtransportadora = 37 and UsouAPP <> 'Sim' then  rotas.KmTotal
		    else rotas.KmColetado end as ppr_total_km,
            rotas.CidadeBase as ppr_nm_cidade,
            ppr_vl_pedagio,
			NULL AS ppr_lcto_cd_lancamento,
			vei_alugar_veiculo AS ppr_vl_aluguel,
			ppr_vl_recarga,
			PercentualEnderecosVisitados as ppr_per_endereco_nao_visitado,
            TIPO AS ppr_cd_tipo,
			rotas.TipoRota,
			rotas.KmTotal ppr_total_km_meli,
			rotas.KmRTT ppr_total_km_rtt,
			-- Adicionado por Gabriel Ramos dia 30 de Julho 2025 para atender solicitação da Elo. Sempre que o km for inválido considerar KMMeli.
			--case when IdTransportadora in (57) and rotas.KmRTT < = 1 then rotas.KmTotal else rotas.KmRTT end,
			FaixaKm2,

			ValorBonusDs ppr_vl_bonus_ds,
			ValorAdicionalKm ppr_vl_adicional_km,

			-- case when IdTransportadora = 11 and ambulanciaPrefatura = 1 then 1 else 0 end ppr_in_ambulancia
			CASE 
			WHEN (IdTransportadora = 11 AND ambulanciaPrefatura = 1) OR (IdTransportadora IN (63, 56, 45) AND rotas.ambulancia = 1) 
			THEN 1 
			ELSE 0 
		END AS ppr_in_ambulancia,

		1362 ppr_cd_tipo_pgto,

		ppr_in_zerar_rota,

		case when IdTransportadora in(11,45) and ValorFixoPlacaRota is not null then 1 else 0 end ppr_in_pgto_fixo,

		ppr_nm_origem_km

		FROM
		( 
			SELECT
				-- @IdTransportadora IdTransportadora,
				r.idtransportadora,
				--@Ano Ano,
				--@Mes Mes,
				--@Quinzena Quinzena,
			--	r.IdTrevo,
            r.Ambulancia,
--			null observacao,
				-- /*lancamentos.Desc_Lancamento*/ null AS observacao, 
				lancamentos.tlm_ds_observacao observacao,
				r.dataReferencia AS Data,
				r.serviceCenter ,
				r.CidadeReferencia,
				r.Placa,
				TipoVeiculo,
				r.NomeMotorista,
				r.UsuarioDA,
				r.UsouAPP,
				r.idRota as IdRota,
                R.TIPO,
				r.PacotesEntregues,
				r.Ciclo_Pm CicloPM,
				TotalPacotes,
				r.PacotesNaoEntregue,
				QuantidadePontos,
				r.PacotesPendentes,
				lancamentos.ValorApoio as ValorApoioLancamentos,
                isnull(isnull(isnull(freteKm0a100Cidade.bfm_vl_frete,frete.bfm_vl_frete), freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) as ValorFrete ,
                isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) as ValorPM,

				--KmColetado,

				--Adicionado por Saulo Barros em 29/07/2025 para verificar se a data da rota é de um domingo ou feriado
				case when DATEPART(weekday, r.DataInicio) = 1  or isnull(dt.Feriado,0) = 1  then 1 else 0 end ppr_in_dom_fer,
				
				case when r.IdTransportadora = 11 and isnull(pre.kmciclo,'') = 'AMBULANCE' then -- and r.serviceCenter in ('SBA1', 'ECE1', 'ECE3', 'SCE1') then
					0
				else
					CASE 
						WHEN DATEPART(weekday, r.DataInicio) = 1  --DATEPART(weekday, r.DataReferencia) = 1 
								OR (r.idtransportadora = 46 AND DATEPART(weekday, r.DataInicio) = 7) --DATEPART(weekday, r.DataReferencia) = 7) 
								OR dt.Feriado = 1  -- domingo ou feriado
						THEN 
							--verifica se o valor do domingo ou feriado é valor fixo por faixa de km, se for considera a diferença entre o frete e ele
							case 
								when r.IdTransportadora = 11 and Ciclo_Pm = 'AM' and r.ServiceCenter in ('EBA26', 'EBA27') and r.DataReferencia >= '2026-05-16' and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) is not null and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) > 0
									then coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) - coalesce(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete,freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete)

								when r.IdTransportadora = 11 and Ciclo_Pm = 'PM' and r.ServiceCenter in ('EBA26', 'EBA27') and r.DataReferencia >= '2026-05-16' and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) is not null and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) > 0
									then coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteMenorKmCidade.bfm_vl_domfer_pm,freteMenorKm.bfm_vl_domfer_pm, freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) - coalesce(freteKmPreFaturaCidade.bfm_vl_frete_pm,freteKmPreFatura.bfm_vl_frete_pm,freteMenorKmCidade.bfm_vl_frete_pm,freteMenorKm.bfm_vl_frete_pm, freteKmRTTCidade.bfm_vl_frete_pm,freteKmRTT.bfm_vl_frete_pm)
								
								--incluído por Saulo Barros em 17/07/2026 para considear a prefatura como origem km principal para tudo a partir da Q2 de Junho de 2026
								when r.IdTransportadora = 11 and Ciclo_Pm = 'AM' and r.DataReferencia >= '2026-06-16' and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) is not null and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) > 0
									then coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_am,freteKmPreFatura.bfm_vl_domfer_am,freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) - coalesce(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete,freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete)

								when r.IdTransportadora = 11 and Ciclo_Pm = 'PM' and r.DataReferencia >= '2026-06-16' and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) is not null and coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) > 0
									then coalesce(freteKmPreFaturaCidade.bfm_vl_domfer_pm,freteKmPreFatura.bfm_vl_domfer_pm,freteMenorKmCidade.bfm_vl_domfer_pm,freteMenorKm.bfm_vl_domfer_pm, freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) - coalesce(freteKmPreFaturaCidade.bfm_vl_frete_pm,freteKmPreFatura.bfm_vl_frete_pm,freteMenorKmCidade.bfm_vl_frete_pm,freteMenorKm.bfm_vl_frete_pm, freteKmRTTCidade.bfm_vl_frete_pm,freteKmRTT.bfm_vl_frete_pm)



								when r.IdTransportadora = 11 and Ciclo_Pm = 'AM' and coalesce(freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) is not null and coalesce(freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) > 0
									then coalesce(freteMenorKmCidade.bfm_vl_domfer_am,freteMenorKm.bfm_vl_domfer_am, freteKmRTTCidade.bfm_vl_domfer_am,freteKmRTT.bfm_vl_domfer_am) - coalesce(freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete)
								when r.IdTransportadora = 11 and Ciclo_Pm = 'PM' and isnull(freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) is not null and isnull(freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) > 0
									then coalesce(freteMenorKmCidade.bfm_vl_domfer_pm,freteMenorKm.bfm_vl_domfer_pm, freteKmRTTCidade.bfm_vl_domfer_pm,freteKmRTT.bfm_vl_domfer_pm) - coalesce(freteMenorKmCidade.bfm_vl_frete_pm,freteMenorKm.bfm_vl_frete_pm, freteKmRTTCidade.bfm_vl_frete_pm,freteKmRTT.bfm_vl_frete_pm)
								--Adicionado por Saulo Barros em 02/07/2025 para cálculo do domingo na Elo quando o valor já foi definido direto na tabela frete
								when r.IdTransportadora = 57 and Ciclo_Pm = 'AM' and coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) is not null and coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) > 0
									then coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) - coalesce(frete.bfm_vl_frete,freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete)
								when r.IdTransportadora = 57 and Ciclo_Pm = 'PM' and coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) is not null and coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) > 0
									then coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) - coalesce(frete.bfm_vl_frete,freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete)
								--Adicionado por Gabriel Ramos em 31/07/2025 para cálculo do domingo na Coomap quando o valor já foi definido direto na tabela frete
								when r.IdTransportadora = 63 and Ciclo_Pm = 'AM' and coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) is not null and coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) > 0
									then coalesce(frete.bfm_vl_domfer_am,freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am) 
								when r.IdTransportadora = 63 and Ciclo_Pm = 'PM' and coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) is not null and coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) > 0
									then coalesce(frete.bfm_vl_domfer_pm,freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm) 	
							else
								CASE 
									WHEN (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_domingo ELSE adicional.bfa_tipo_adicional_domingo END) = 2 
									THEN
										(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END)
									ELSE
										CASE 
											WHEN Ciclo_Pm = 'PM' 
													OR (r.idtransportadora = 46 AND DATEPART(weekday, r.DataReferencia) = 7) 
											THEN
												CASE      
													WHEN COALESCE(frete.bfm_vl_frete_pm, freteKm.bfm_vl_frete_pm, freteKm2.bfm_vl_frete_pm, freteKmPreFaturaCidade.bfm_vl_frete_pm, freteKmPreFatura.bfm_vl_frete_pm) IS NOT NULL 
													THEN
														COALESCE(frete.bfm_vl_frete_pm, freteKm.bfm_vl_frete_pm, freteKm2.bfm_vl_frete_pm, freteKmPreFaturaCidade.bfm_vl_frete_pm, freteKmPreFatura.bfm_vl_frete_pm)
													ELSE
														COALESCE(frete.bfm_vl_frete, freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete, freteKmPreFaturaCidade.bfm_vl_frete, freteKmPreFatura.bfm_vl_frete) -
														isnull(
															CASE 
																WHEN (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 
																THEN  -- PM
																	(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
																ELSE
																	COALESCE(frete.bfm_vl_frete, freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete, freteKmPreFaturaCidade.bfm_vl_frete, freteKmPreFatura.bfm_vl_frete) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END) / 100
															END
															,0
														)
												END
											ELSE
												case when r.idtransportadora = 11 then
													case when (r.ServiceCenter in ('EBA26', 'EBA27') and r.DataReferencia >= '2026-05-16') or (r.DataReferencia >= '2026-06-16') then
														COALESCE(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete, freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete, freteKmRTT.bfm_vl_frete, freteKmPreFaturaCidade.bfm_vl_frete, freteKmPreFatura.bfm_vl_frete, frete.bfm_vl_frete, freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete)
													else
														COALESCE(freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete, freteKmRTT.bfm_vl_frete, freteKmPreFaturaCidade.bfm_vl_frete, freteKmPreFatura.bfm_vl_frete, frete.bfm_vl_frete, freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete)
													end
												else
													COALESCE(freteKmRTTCidade.bfm_vl_frete, frete.bfm_vl_frete, freteKm.bfm_vl_frete, freteKm2.bfm_vl_frete, freteKmPreFaturaCidade.bfm_vl_frete, freteKmPreFatura.bfm_vl_frete)
												end
										END
										* (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END) / 100
								END
							end
					END
				end
				 DomingoOuFeriado,

                case
                    when r.placa in ( 'SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10','SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35',
                    'RVH5G50', 'RVH5G47', 'RVH5G49', 'RVG5F53', 'RVG0G04', 'RVG0G07', 'RVH5G46', 'RVH5G52', 'RUV4E94', 'RUV4E98',
                    'TCG3I07', 'RUX2J27', 'RUX2J26', 'RUM3C10', 'RUL8C97', 'RUW5E58', 'RUV4E97', 'RUW5E67', 'RUM3C14', 'SIR9G29', 
                    'RVH5G41', 'RVH5G43', 'RUX2I97', 'SYZ5B94', 'RUW5E13', 'RVH5G40', 'RUL8C94', 'RUV4E93', 'RUX2J15', 'SJD9D66', 
                    'RUL8C67', 'RUM3C16', 'RUW5E12', 'RVP3G53',  'RUL7F93', 'RUL8C79', 'SIM8F42', 'RUW5E59', 'RUW5D81', 
                    'RUX2J28', 'RUW5E78', 'SJD9D75', 'RVB8F43', 'RNK7H65', 'RUW5E64', 'RUX2J24', 'RUX2J20', 'RVG0G06', 'SJD9D64', 
                    'RUX2J17', 'RUX2J32', 'RUX2I95', 'RUV4E91', 'RUZ1I48', 'RVB8F61', 'RVB8F64', 'RVB8F62', 'RVB8F63', 'SHH6A78', 
                    'SIS6B22', 'RUV4E73', 'RUV4E89', 'RUX2J01', 'RUL7F37', 'RUL8C74', 'RUL8C75', 'SHW9H05', 'RUW6G62', 'RUV9I34', 
                    'RVH5G22', 'RVH5G23', 'RVH5G24', 'SYD9B89', 'RUL7F53', 'RUW5D91', 'RUW5D83', 'RVG0G05', 'RVD4D30', 'RUM3C36', 
                    'RVD4C81', 'RUO6A94', 'SIH2I75', 'RVH5G45', 'RUW5E49', 'RUW5E17', 'SIB2E50', 'RUW5E60', 'RUW5E47', 'RVH5G31', 
                    'RUX2C91', 'RVB8F44', 'RUW5E08', 'RUM3C05', 'SIM8E51', 'SII3G79', 'RVG0G03', 'RUW5E16', 'RUX2C88', 'RVG0G08', 
                    'RUM3C11', 'SHW9H13', 'RUM2B56', 'RUW5E05', 'QMZ0F77', 'RUZ1I50', 'RVG5F56', 'RUL7G08', 'RVB8F65', 'UAI5H95', 
                    'SII3G69', 'RUL8C72', 'RVD4C87', 'RUM3C50', 'RUO6A93', 'SHL9I88', 'RVD4D28', 'SYR9B87', 'RVD4C70', 'RUX2J03', 
                    'RUX2J23', 'RNK7G34', 'RUX2J30', 'RVB8F46', 'RUX2I98', 'RUL8C96', 'RUZ1I49', 'RVH5G48', 'RUZ1I47', 'RUZ1I51', 
                    'RVH5G42', 'RUZ1I46', 'RVH5G25', 'RVH5G26', 'RVH5G32', 'RUV4F21', 'RUV4F23', 'TCG6F43', 'RUV4F98', 'SJD9E21', 
                    'RUO6A95', 'RVD4C89', 'RUZ1I57', 'RUV4E32', 'RUM3C15', 'RVB8F55', 'RVB8F47', 'TCG7H90', 'SUI2E53', 'EOA9C32', 
                    'SIM8F23', 'RUH2A40', 'RUO6B45', 'RUL8C98', 'RUV4F13', 'RUX2J07', 'TCC6E30', 'RUX2C89', 'RUV4F12', 'RUX2J31', 
                    'RUV4F18', 'RUX2J00', 'SHH6B82', 'RUL7F29', 'RNK7H60', 'RUV4F20', 'SIB2G49', 'SID5I75', 'RNK7H32', 'RUW5E07', 
                    'SHO0F24', 'SIN9A77', 'RUW5E19', 'RUV4E95', 'RUV4F19', 'SJE1I64', 'RUX2J22', 'SSV4C07', 'RUV4F22', 'RUW5E04', 
                    'RTS2B17', 'RUX2I99', 'RVH5G51', 'RUW5E15', 'RUL8C95', 'RUW5E02', 'SIY2G07', 'SIB2I02', 'FAB9A57', 'RUW5E66', 
                    'RUL8C68', 'RVD4C75', 'RVD4C69', 'TAK7B92', 'SFJ5E15', 'SFJ5E17', 'SFJ5E59', 'SFJ5E42')
                        then 150
                    WHEN r.placa IN ('SIA7J43', 'SIA7J41', 'SIA7J12') THEN 200
                    WHEN r.placa IN ('SHZ5D73', 'SIA7J19', 'SIA7J23', 'SIA7J10', 'SIA7J09', 'SIA7J25', 'SHZ5D98', 'CUB4205', 'RVP9C81') THEN 180
                    WHEN r.placa IN ('FGF8G96', 'LUI2C35', 'RTT0B11', 'SYE0I39', 'SJD9D65', 'SHM3E82', 'TCC2I37', 'SII8D78') THEN 150
                    WHEN r.placa IN ('GBL0E72', 'EOC8B83', 'SYA3I62') THEN 120
                    WHEN r.placa = 'RFU0E09' THEN 155
                    else 
                case when r.Ciclo_Pm = 'AM' THEN freteTrevo.bfm_vl_frete ELSE freteTrevo.bfm_vl_frete_PM END end AS ppr_vl_trevo,
				-- freteTrevo.bfm_vl_frete as ppr_vl_trevo,

				--pagamento saida
				--case
				--	when Rental is null and freteTrevo.bfm_vl_frete is not null
				--		then freteTrevo.bfm_vl_frete
				--	else
                case when isnull(r.edit_ambulancia,1) <> 0 and (pre.kmciclo = 'AMBULANCE' or isnull(r.edit_ambulancia,0) = 1) then 1 else 0 end as ambulanciaPrefatura,

                case 
                     WHEN DATEPART(weekday, r.DataInicio) = 1 --DATEPART(weekday, r.DataReferencia) = 1 
							OR (r.idtransportadora = 46 AND DATEPART(weekday, r.DataInicio) = 7) --DATEPART(weekday, r.DataReferencia) = 7) 
							OR dt.Feriado = 1  -- domingo ou feriado

                    then
                            case  
                            when r.IdTransportadora = 48 and Ciclo_Pm = 'AM' 
                                then COALESCE(frete.bfm_vl_domfer_am, freteKm.bfm_vl_domfer_am, freteKm2.bfm_vl_domfer_am, freteKmPreFaturaCidade.bfm_vl_domfer_am, freteKmPreFatura.bfm_vl_domfer_am)
                            when r.IdTransportadora = 48 and Ciclo_Pm = 'PM' 
                                then COALESCE(frete.bfm_vl_domfer_pm, freteKm.bfm_vl_domfer_pm, freteKm2.bfm_vl_domfer_pm, freteKmPreFaturaCidade.bfm_vl_domfer_pm, freteKmPreFatura.bfm_vl_domfer_pm)
                            else  
                                case 
                                        when Ciclo_Pm = 'PM' 
                                    then
                                        isnull(isnull(frete.bfm_vl_frete_pm, freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)
                                    else isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) end
                                end 
                else
                    case
                    when r.idtransportadora = 34 and isnull(r.edit_ambulancia,1) <> 0 and (pre.kmciclo = 'AMBULANCE' or isnull(r.edit_ambulancia,0) = 1) then 0
                    when r.idtransportadora in (63) and r.ambulancia = 1 then 0
                else
						case
							when r.placa in ( '')
								then 150
							WHEN r.placa in ('RUX2J02','RUZ1I57') then 115
                            WHEN r.placa IN ('SIA7J43', 'SIA7J41', 'SIA7J12') THEN 200
                            WHEN r.placa IN ('SHZ5D73', 'SIA7J19', 'SIA7J23', 'SIA7J10', 'SIA7J09', 'SIA7J25', 'SHZ5D98', 'CUB4205', 'RVP9C81','RUM3C14') THEN 180
                            WHEN r.placa IN ('FGF8G96', 'LUI2C35', 'RTT0B11', 'SYE0I39', 'SJD9D65', 'SHM3E82', 'TCC2I37', 'SII8D78') THEN 150
                            WHEN r.placa IN ('GBL0E72', 'EOC8B83', 'SYA3I62') THEN 120
                            WHEN r.placa = 'RFU0E09' THEN 155
							else
						isnull(case when Ciclo_Pm = 'PM' then
							case when isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm) is not null then
								isnull(isnull(frete.bfm_vl_frete_pm,freteKm.bfm_vl_frete_pm),freteKm2.bfm_vl_frete_pm)
							else
								isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
								-
								isnull(
									case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
										(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
									else
										isnull(isnull(frete.bfm_vl_frete,freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
									end
								,0)
							end
						else
							        isnull(isnull(frete.bfm_vl_frete, freteKm.bfm_vl_frete),freteKm2.bfm_vl_frete)
						end,0)
					end end end Saida,

				/*calculo adicional pool */
				case
				when ADICIONAL_POOL.bfa_vl_adicional is not null
					then
						ADICIONAL_POOL.bfa_vl_adicional
					else
						0
					 end as ValorPool,

			  /*calculo adicional fixo */
				case
				when adicional_fixo.bfm_vl_frete_fixo is not null
					then
						adicional_fixo.bfm_vl_frete_fixo
					else
						0
					 end as ValorFixos,
		
				(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_calcula_por_parada ELSE adicional.bfa_calcula_por_parada END) AS bfa_calcula_por_parada ,
		
	
       case 
            when r.idtransportadora = 48 and r.ServiceCenter = 'SSP21' 
                then 
                    case
                        when r.Quantidadepontos <= 50 then 0
                        when r.Quantidadepontos <= 60 then (r.Quantidadepontos - 49) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
                        when r.Quantidadepontos between 61 and 90 then (11 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.Quantidadepontos - 60) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
                        else (11 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (30 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.Quantidadepontos - 90) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
                    end
				
			when r.idtransportadora = 66 and r.tipoveiculo in ('Utilitários','Veículo de Passeio') and r.ServiceCenter IN ('SSP7','SRJ9','SRJ2')
				then 
					 case
                        when  r.Quantidadepontos <= 59 then r.Quantidadepontos * 0.10
                        when  r.Quantidadepontos between 60 and 69 then (59 * 0.10) + ((r.Quantidadepontos-59)*0.20)
                        when  r.Quantidadepontos between 70 and 79 then (59 * 0.10) + (10 * 0.20) + ((r.Quantidadepontos-69)*0.30)
                        else 0
                    end
            
            else 
                    case
                        when  r.Quantidadepontos <= 60 then r.Quantidadepontos * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
                        when  r.Quantidadepontos between 61 and 75 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.Quantidadepontos-60)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
                        when  r.Quantidadepontos between 76 and 85 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.Quantidadepontos-75)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
                        when  r.Quantidadepontos between 86 and 90 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.Quantidadepontos-85)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
                        else (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.Quantidadepontos-90)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
                    end
            end  as ValorPontos,

				CASE 
    WHEN r.idtransportadora = 48 AND r.ServiceCenter = 'SSP34' THEN 
        CASE
            WHEN r.PacotesEntregues <= 40 THEN 0
            WHEN r.PacotesEntregues <= 70 THEN (r.PacotesEntregues - 39) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
            WHEN r.PacotesEntregues BETWEEN 71 AND 100 THEN 
                (31 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + 
                ((r.PacotesEntregues - 70) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
            ELSE 
                (31 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + 
                (30 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + 
                ((r.PacotesEntregues - 101) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
        END
   ELSE
        CASE 
            WHEN r.idtransportadora = 59 AND r.TotalPacotes >= 80 THEN 
                CASE 
                    WHEN r.ServiceCenter IN ('SBA1','SBA2','SSE1') THEN 50.00
                    WHEN r.ServiceCenter IN ('EBA2', 'EBA3', 'EBA4', 'EBA5', 'EBA9', 'EBA11', 'EBA14', 'EBA16', 'EBA19', 'EBA21', 
					'EBA22', 'EBA25', 'ESE1','SBA3', 'SSE1' ) THEN 40.00
                    WHEN r.ServiceCenter IN ('EBA2', 'SES1', 'SMG7') THEN 0.00
                    ELSE 
                        (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + 
                        (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + 
                        (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + 
                        (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + 
                        ((r.PacotesEntregues - 90) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
                END
			--WHEN r.idtransportadora = 61 AND @tipocontrato IN (  270,275,277,279,281,283,285,309,310,311,312,313,314
			--													,315,316,317,318,319,320,327,328,353) 
			--							 and r.ServiceCenter in ('EBA12','EBA14','EBA6','EBA13','EBA22','EBA6',
			--															'EBA19','EBA16','SBA2','SBA3','EBA11','EBA4',
			--															'EBA25','EBA21','ESE1','EBA3'
			--															) AND r.PacotesEntregues > 80
			--															and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio', 'Utilitários SDD')
			--															THEN 40.00
   --         WHEN r.idtransportadora = 61 and r.ServiceCenter in ('SSE1','SBA1','SBA6') 
			--	AND r.PacotesEntregues > 80 
			--	and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio', 'Utilitários SDD') 
			--	AND @tipocontrato IN (  270,275,277,279,281,283,285,309,310,311,312,313,314
			--													,315,316,317,318,319,320,327,328,353) 
			--	THEN 50.00
			WHEN r.PacotesEntregues <= 60 THEN r.PacotesEntregues * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
            WHEN r.PacotesEntregues BETWEEN 61 AND 75 THEN (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.PacotesEntregues - 60) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
            WHEN r.PacotesEntregues BETWEEN 76 AND 85 THEN (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.PacotesEntregues - 75) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
            WHEN r.PacotesEntregues BETWEEN 86 AND 90 THEN (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.PacotesEntregues - 85) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
            ELSE 
                (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.PacotesEntregues - 90) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
        END
			END 
AS ValorPacotesEntregues,

						
   --                     case 
			--	when r.idtransportadora = 48 and r.ServiceCenter = 'SSP34' 
			--		then 
			--			case
			--				when r.PacotesEntregues <= 40 then 0
			--				when r.PacotesEntregues <= 70 then (r.PacotesEntregues - 39) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
			--				when r.PacotesEntregues between 71 and 100 then (31 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.PacotesEntregues - 70) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
			--				else (31 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (30 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.PacotesEntregues - 101) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
			--			end
			--else
			--			case 
			--				when r.PacotesEntregues <= 60 then r.PacotesEntregues * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
			--				when r.PacotesEntregues between 61 and 75 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.PacotesEntregues-60)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
			--				when r.PacotesEntregues between 76 and 85 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.PacotesEntregues-75)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
			--				when r.PacotesEntregues between 86 and 90 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.PacotesEntregues-85)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
			--				else (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.PacotesEntregues-90)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
			--			end
			--end as ValorPacotesEntregues,

						
			
				
						CASE 
					    WHEN r.idTransportadora = 45 
					         AND r.tipoVeiculo IN ('Veículo de Passeio', 'Utilitários', 'Van')
					         AND r.serviceCenter IN ('SAL1', 'EAL2', 'SBA1', 'SCE1', 'ECE2', 'SJP1', 'SPE1', 'EPE4', 'EPE5', 'SRN1', 'SSE1','SPI1','SDF1','SDF2','EDF8')
					         AND r.quantidadeParadas > 63
					         AND r.PacotesEntregues BETWEEN 80 AND 110 THEN 20
					
					    WHEN r.idTransportadora = 45 
					         AND r.tipoVeiculo IN ('Veículo de Passeio', 'Utilitários', 'Van')
					         AND r.serviceCenter IN ('SAL1', 'EAL2', 'SBA1', 'SCE1', 'ECE2', 'SJP1', 'SPE1', 'EPE4', 'EPE5', 'SRN1', 'SSE1','SPI1','SDF1','SDF2','EDF8')
					         AND r.quantidadeParadas > 63
					         AND r.PacotesEntregues > 110 THEN 50
					
						-- Faixa km > 100 ------
						WHEN r.idTransportadora = 45 AND r.tipoVeiculo IN ('Veículo de Passeio', 'Utilitários', 'Van')
						     AND r.serviceCenter IN ('SPI1','SDF1')
							 AND r.quantidadeParadas > 63
						     AND isnull(r.kmtotal,0) > 100
						THEN (r.PacotesEntregues * 0.60)						
					
					
							-- Faixa entre 60 e 90
						WHEN r.idTransportadora = 45 AND r.tipoVeiculo = 'VUC' 
						     AND r.serviceCenter IN ('SAL1', 'EAL2', 'SBA1', 'SCE1', 'ECE2', 'SJP1', 'SPE1', 'EPE4', 'EPE5', 'SRN1', 'SSE1')
						     AND r.PacotesEntregues BETWEEN 60 AND 90
						THEN (r.PacotesEntregues * 0.25)
						
						-- Faixa entre 91 e 100
						WHEN r.idTransportadora = 45 AND r.tipoVeiculo = 'VUC' 
						     AND r.serviceCenter IN ('SAL1', 'EAL2', 'SBA1', 'SCE1', 'ECE2', 'SJP1', 'SPE1', 'EPE4', 'EPE5', 'SRN1', 'SSE1')
						     AND r.PacotesEntregues BETWEEN 91 AND 100
						THEN (90 * 0.25) + ((r.PacotesEntregues - 90) * 0.50)
						
						-- Faixa acima de 100
						WHEN r.idTransportadora = 45 AND r.tipoVeiculo = 'VUC' 
						     AND r.serviceCenter IN ('SAL1', 'EAL2', 'SBA1', 'SCE1', 'ECE2', 'SJP1', 'SPE1', 'EPE4', 'EPE5', 'SRN1', 'SSE1')
						     AND r.PacotesEntregues > 100
						THEN (90 * 0.25) + (10 * 0.50) + ((r.PacotesEntregues - 100) * 0.25)
						--when r.idtransportadora  = 45 and r.tipoveiculo in ( 'Veículo de Passeio' , 'Utilitários' , 'Van' ) and r.QuantidadeParadas between 80 and 110 then 20
						--when r.idtransportadora  = 45 and r.tipoveiculo in ( 'Veículo de Passeio' , 'Utilitários' , 'Van' ) and r.QuantidadeParadas > 110 then 50
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Utilitários SDD' and r.QuantidadeParadas <= 60 then 260
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Utilitários SDD' and r.QuantidadeParadas between 61 and 80 then 270
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Utilitários SDD' and r.QuantidadeParadas >= 81 then 280
                        
                        when r.idtransportadora  = 33 and r.tipoveiculo = 'Van SDD' and r.QuantidadeParadas <= 25 then 310
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Van SDD' and r.QuantidadeParadas between 25 and 35 then 320
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Van SDD' and r.QuantidadeParadas >= 35 then 330

						when r.idtransportadora  = 33 and r.tipoveiculo = 'Vuc SDD' and r.QuantidadeParadas <= 25 then 400
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Vuc SDD' and r.QuantidadeParadas between 25 and 35 then 415
						when r.idtransportadora  = 33 and r.tipoveiculo = 'Vuc SDD' and r.QuantidadeParadas >= 35 then 430

						when r.idtransportadora = 58 and Ciclo_Pm <> 'AM' then 0

						--na 50+ para o ECE3 e ECE1 só recebe parada se a perfomrnace for 100%
						when r.idtransportadora = 11 and r.ServiceCenter in ('ECE3', 'ECE1') and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) <> 1 then 0

						--se tiver 100% de entrega paga no mínimo 10 reais pelas paradas
						when r.idtransportadora = 11 and r.ServiceCenter = 'ECE1' and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) = 1 then
							case when
								case 
									when r.QuantidadeParadas <= 60 then r.QuantidadeParadas * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
									when r.QuantidadeParadas between 61 and 75 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.QuantidadeParadas-60)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
									when r.QuantidadeParadas between 76 and 85 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.QuantidadeParadas-75)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
									when r.QuantidadeParadas between 86 and 90 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.QuantidadeParadas-85)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
									else (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.QuantidadeParadas-90)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
								end < 10 then 10 
								else
								case 
									when r.QuantidadeParadas <= 60 then r.QuantidadeParadas * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
									when r.QuantidadeParadas between 61 and 75 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.QuantidadeParadas-60)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
									when r.QuantidadeParadas between 76 and 85 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.QuantidadeParadas-75)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
									when r.QuantidadeParadas between 86 and 90 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.QuantidadeParadas-85)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
									else (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.QuantidadeParadas-90)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
								end
							end

					else
						case 
							when r.QuantidadeParadas <= 60 then r.QuantidadeParadas * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
							when r.QuantidadeParadas between 61 and 75 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + ((r.QuantidadeParadas-60)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END))
							when r.QuantidadeParadas between 76 and 85 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + ((r.QuantidadeParadas-75)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END))
							when r.QuantidadeParadas between 86 and 90 then (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + ((r.QuantidadeParadas-85)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END))
							else (60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)) + (15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)) + (10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)) + (5 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)) + ((r.QuantidadeParadas-90)*(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas_acima_90 ELSE adicional.bfa_vl_paradas_acima_90 END))
						end
					end ValorParadas ,

				/*calculo adicional */
				isnull(
					case when r.IdTransportadora = 1491631999 and r.Ambulancia = 1 then
						0
					else
						CASE
						WHEN (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_calcula_por_parada ELSE adicional.bfa_calcula_por_parada END) = 0
							THEN
								CASE
									WHEN r.QuantidadeParadas <= 60
						THEN r.QuantidadeParadas * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
					WHEN r.QuantidadeParadas <= 90
						THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + (r.QuantidadeParadas - 60) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)
					--WHEN r.QuantidadeParadas <= 85
					--	THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + (r.QuantidadeParadas - 75) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)
					--WHEN r.QuantidadeParadas <= 90
					--	THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + 10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END) + (r.QuantidadeParadas - 85) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)
				ELSE 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 30 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + (r.QuantidadeParadas - 90) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)
					END
						WHEN (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_calcula_por_parada ELSE adicional.bfa_calcula_por_parada END) = 1
							THEN
							CASE
								WHEN r.QuantidadeParadas <= 60
									THEN r.QuantidadeParadas * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END)
								WHEN r.QuantidadeParadas <= 90
									THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + (r.QuantidadeParadas - 60) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END)
								--WHEN r.QuantidadeParadas <= 85
								--	THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + (r.QuantidadeParadas - 75) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)
								--WHEN r.QuantidadeParadas <= 90
								--	THEN 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 15 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + 10 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END) + (r.QuantidadeParadas - 85) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas86_90 ELSE adicional.bfa_vl_paradas86_90 END)
								ELSE 60 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas0_60 ELSE adicional.bfa_vl_paradas0_60 END) + 30 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas61_75 ELSE adicional.bfa_vl_paradas61_75 END) + (r.QuantidadeParadas - 90) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_paradas76_85 ELSE adicional.bfa_vl_paradas76_85 END)
							END
						END
					end
				+
				/*calculo adicional pool */
				case
				when ADICIONAL_POOL.bfa_vl_adicional is not null
					then
						ADICIONAL_POOL.bfa_vl_adicional
					else
						0
					 end
					 +
			  /*calculo adicional fixo */
				case
				when adicional_fixo.bfm_vl_frete_fixo is not null
					then
						adicional_fixo.bfm_vl_frete_fixo
					else
						0
					 end,0) AS [ADD],

				(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_risco ELSE adicional.bfa_vl_adicional_risco END) AS RISCO,
    
				--case
    --                when r.idtransportadora = 45 and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio') 
    --                    then 
    --                        case
    --                            when r.totalpacotes between 81 and 90 then 20
    --                        when r.totalpacotes > 90 then 30
    --                            else 0 end
    --            else 0 end 
				-- 0 AS AJUDANTE,
			
			CASE WHEN r.idtransportadora = 59 AND @tipocontrato NOT IN (262)
				and r.ServiceCenter in ('SBA1', 'SBA2' ,'SBA6') and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio', 'VUC', 'Utilitários SDD','Vuc SDD','Van SDD') 
				AND r.totalpacotes >= 80
				THEN 50.00

	
			
			WHEN r.idtransportadora = 61 AND @tipocontrato IN (  270,275,277,279,281,283,285,309,310,311,312,313,314
																,315,316,317,318,319,320,327,328,353,397) 
										 and r.ServiceCenter in ('EBA12','EBA14','EBA6','EBA13','EBA22','EBA6',
																		'EBA19','EBA16','SBA2','SBA3','EBA11','EBA4',
																		'EBA25','EBA21','ESE1','EBA3','EBA29'
																		) AND r.totalpacotes >= 80
																		and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio', 'Utilitários SDD')
																		THEN 40.00
             WHEN r.idtransportadora = 61 and r.ServiceCenter in ('SSE1') 
				AND r.totalpacotes >= 80 
				and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio','Utilitários SDD') 
				AND @tipocontrato IN (  270,275,277,279,281,283,285,309,310,311,312,313,314
																,315,316,317,318,319,320,327,328,353,351) 
				THEN 50.00
		     WHEN r.idtransportadora = 61 and r.ServiceCenter in ('SBA1','SBA6') 
				AND r.totalpacotes >= 80 
				and r.TipoVeiculo in ('Utilitários','Van','Veículo de Passeio') 
				AND @tipocontrato IN (  270,275,277,279,281,283,285,309,310,311,312,313,314
																,315,316,317,318,319,320,327,328,353,351) 
				THEN 50.00
			WHEN r.idtransportadora = 61 AND r.totalpacotes < 80 THEN 0 
				ELSE ISNULL((CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ajudante ELSE adicional.bfa_vl_adicional_ajudante END),0) END  AS AJUDANTE,

				ISNULL(NULL,0) AS ASCRESC,

				isnull(case when Ciclo_Pm = 'PM' then
					case when freteKmMotorista.bfm_vl_frete_pm is not null then
						freteKmMotorista.bfm_vl_frete_pm
					else
						freteKmMotorista.bfm_vl_frete
						-
						isnull(
							case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
								(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
							else
								freteKmMotorista.bfm_vl_frete * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
							end
						,0)
					end
				else
					freteKmMotorista.bfm_vl_frete
				end,0)
			/*	+
				/*calculo saida domingo */

				isnull(
				case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
					case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_domingo ELSE adicional.bfa_tipo_adicional_domingo END) = 2 then
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END)
					else
				case when Ciclo_Pm = 'PM' then
					case when freteKmMotorista.bfm_vl_frete_pm is not null then
						freteKmMotorista.bfm_vl_frete_pm
					else
						freteKmMotorista.bfm_vl_frete
						-
						case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
							(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
						else
							freteKmMotorista.bfm_vl_frete * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
						end
					end
				else
					freteKmMotorista.bfm_vl_frete
				end
				*
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END) / 100
				end
					end,0)*/
				SaidaKmMotorista,


				isnull(case when Ciclo_Pm = 'PM' then
					case when coalesce(freteMenorKmCidade.bfm_vl_frete_pm,freteMenorKm.bfm_vl_frete_pm, freteKmRTTCidade.bfm_vl_frete_pm,freteKmRTT.bfm_vl_frete_pm) is not null then
						coalesce(freteMenorKmCidade.bfm_vl_frete_pm,freteMenorKm.bfm_vl_frete_pm, freteKmRTTCidade.bfm_vl_frete_pm,freteKmRTT.bfm_vl_frete_pm)
					else
						coalesce(freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete)
						-
						isnull(
							case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
								(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
							else
								coalesce(freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
							end
						,0)
					end
				else
					coalesce(freteMenorKmCidade.bfm_vl_frete,freteMenorKm.bfm_vl_frete, freteKmRTTCidade.bfm_vl_frete,freteKmRTT.bfm_vl_frete)
				end,0) SaidaKmRTT,

			
			isnull(case when Ciclo_Pm = 'PM' then
					case when isnull(freteKm0a100Cidade.bfm_vl_frete_pm,freteKm0a100.bfm_vl_frete_pm) is not null then
						isnull(freteKm0a100Cidade.bfm_vl_frete_pm,freteKm0a100.bfm_vl_frete_pm)
					else
						isnull(freteKm0a100Cidade.bfm_vl_frete,freteKm0a100.bfm_vl_frete)
						-
						isnull(
							case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
								(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
							else
								isnull(freteKm0a100Cidade.bfm_vl_frete,freteKm0a100.bfm_vl_frete) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
							end
						,0)
					end
				else
					isnull(freteKm0a100Cidade.bfm_vl_frete,freteKm0a100.bfm_vl_frete)
				end,0)
			
				/*+
				/*calculo saida domingo */

                isnull(
				case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
					case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_domingo ELSE adicional.bfa_tipo_adicional_domingo END) = 2 then
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END)
					else
				case when Ciclo_Pm = 'PM' then
					case when freteKm0a100.bfm_vl_frete_pm is not null then
						freteKm0a100.bfm_vl_frete_pm
					else
						freteKm0a100.bfm_vl_frete
						-
						case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
							(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
						else
							freteKm0a100.bfm_vl_frete * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
						end
					end
				else
					freteKm0a100.bfm_vl_frete
				end
				*
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END) / 100
				end
					end,0)*/
				SaidaKm0a100,


				COALESCE(freteKm0a100Cidade.bfm_vl_frete,freteKm0a100.bfm_vl_frete,0) SaidaKm0a100AM,

				--Olha o frete sem olhar cidade
				ISNULL(freteKm0a100.bfm_vl_frete,0) SaidaKm0a100AMSVC,


				isnull(case when Ciclo_Pm = 'PM' then
					case when COALESCE(freteKmPreFaturaCidade.bfm_vl_frete_pm,freteKmPreFatura.bfm_vl_frete_pm) is not null then
						COALESCE(freteKmPreFaturaCidade.bfm_vl_frete_pm,freteKmPreFatura.bfm_vl_frete_pm)
					else
						COALESCE(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete)
						-
						isnull(
							case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
								(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
							else
								COALESCE(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
							end
						,0)
					end
				else
					COALESCE(freteKmPreFaturaCidade.bfm_vl_frete,freteKmPreFatura.bfm_vl_frete)
				end,0)
				/*+
				/*calculo saida domingo */
				isnull(
				case when DATEPART(weekday, r.DataReferencia) = 1 or dt.Feriado = 1 then --domingo ou feriado
					case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_domingo ELSE adicional.bfa_tipo_adicional_domingo END) = 2 then
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END)
					else
				case when Ciclo_Pm = 'PM' then
					case when freteKmPreFatura.bfm_vl_frete_pm is not null then
						freteKmPreFatura.bfm_vl_frete_pm
					else
						freteKmPreFatura.bfm_vl_frete
						-
						case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_adicional_ciclo_pm ELSE adicional.bfa_tipo_adicional_ciclo_pm END) = 2 then --PM
							(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)
						else
							freteKmPreFatura.bfm_vl_frete * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_ciclo_pm ELSE adicional.bfa_vl_adicional_ciclo_pm END)  / 100
						end
					end
				else
					freteKmPreFatura.bfm_vl_frete
				end
				*
						(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_domingo ELSE adicional.bfa_vl_adicional_domingo END) / 100
				end
					end,
                    0)*/
				SaidaKmPreFatura,

				case /*bfa_tipo_insucesso: coluna de insucesso
					   bfa_cd_insucesso quantidade de insucesso */
					when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_tipo_insucesso ELSE adicional.bfa_tipo_insucesso END) = 0
						and CHARINDEX(right(calendario.PeriodoSemana,3), (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_cd_dias_insentos ELSE adicional.bfa_cd_dias_insentos END))  = 0
						and r.PacotesNaoEntregue <= (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_cd_insucesso ELSE adicional.bfa_cd_insucesso END)
						 then (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_insucesso ELSE adicional.bfa_vl_insucesso END)
					else 0 end  as AdicionalInsucessos

			,r.TipoVeiculoCad
            ,
			case when editrota.edit_Faixa_Km is not null then editrota.edit_Faixa_Km else
				case 
					when r.idtransportadora in (34,40,46,47,63)  then  isnull(pre.IntervaloFaixa, cast(COALESCE(freteKm.bfm_vl_inicio_faixa,freteKm2.bfm_vl_inicio_faixa) as varchar)
					+ '/' + cast(COALESCE(freteKm.bfm_vl_fim_faixa,freteKm2.bfm_vl_fim_faixa) as varchar))

					when r.idtransportadora in (1)  then cast(freteTrevo.bfm_vl_inicio_faixa as varchar)
               												 + '/' + cast(freteTrevo.bfm_vl_fim_faixa as varchar)
					
					when r.IdTransportadora = 11 and r.ServiceCenter in ('EBA26', 'EBA27') and r.DataReferencia >= '2026-05-16' then isnull(pre.IntervaloFaixa,
																		cast(coalesce(freteMenorKmCidade.bfm_vl_inicio_faixa,freteMenorKm.bfm_vl_inicio_faixa, freteKmRTTCidade.bfm_vl_inicio_faixa,freteKmRTT.bfm_vl_inicio_faixa) as varchar)
               															+ '/' + cast(coalesce(freteMenorKmCidade.bfm_vl_fim_faixa,freteMenorKm.bfm_vl_fim_faixa, freteKmRTTCidade.bfm_vl_fim_faixa,freteKmRTT.bfm_vl_fim_faixa) as varchar))

					when r.IdTransportadora = 11 and r.DataReferencia >= '2026-06-16' then isnull(pre.IntervaloFaixa,
																		cast(coalesce(freteMenorKmCidade.bfm_vl_inicio_faixa,freteMenorKm.bfm_vl_inicio_faixa, freteKmRTTCidade.bfm_vl_inicio_faixa,freteKmRTT.bfm_vl_inicio_faixa) as varchar)
               															+ '/' + cast(coalesce(freteMenorKmCidade.bfm_vl_fim_faixa,freteMenorKm.bfm_vl_fim_faixa, freteKmRTTCidade.bfm_vl_fim_faixa,freteKmRTT.bfm_vl_fim_faixa) as varchar))
					
					when r.idtransportadora = 11  then cast(coalesce(freteMenorKmCidade.bfm_vl_inicio_faixa,freteMenorKm.bfm_vl_inicio_faixa, freteKmRTTCidade.bfm_vl_inicio_faixa,freteKmRTT.bfm_vl_inicio_faixa) as varchar)
               												 + '/' + cast(coalesce(freteMenorKmCidade.bfm_vl_fim_faixa,freteMenorKm.bfm_vl_fim_faixa, freteKmRTTCidade.bfm_vl_fim_faixa,freteKmRTT.bfm_vl_fim_faixa) as varchar)
				 else 
					cast(COALESCE(freteKm.bfm_vl_inicio_faixa,freteKm2.bfm_vl_inicio_faixa) as varchar)
					+ '/' + cast(COALESCE(freteKm.bfm_vl_fim_faixa,freteKm2.bfm_vl_fim_faixa) as varchar) end 
			end FaixaKm
			,
			cast(COALESCE(freteKm.bfm_vl_inicio_faixa,freteKm2.bfm_vl_inicio_faixa) as varchar)
					+ '/' + cast(COALESCE(freteKm.bfm_vl_fim_faixa,freteKm2.bfm_vl_fim_faixa) as varchar) FaixaKm2
			,r.kmcoletado
			,r.QuantidadeParadas
            ,R.CidadeBase
			,r.TipoRota
			,r.KmTotal
			,r.KmRTT

			--,case
			--	--when r.usouapp = 'Sim' and r.idtransportadora = 1
			--	--	and     ((r.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário sem Ajudante',
			--	--								'Rental Utilitário com Ajudante', 'VUC Dedicado com Ajudante',
   -- --                                            'Utilitário Elétrico BYD','Large Van Elétrica - Equipe Única', 'Large Van Eletrica J750' 
			--	--								) 
			--	--								-- removido tipos de veiculos frota fixa ('MeliOne Van Frota Fixa','Van Frota Fixa - Equipe dupla', 'Frota Fixa Large Van Ford Auto','Frota Fixa Large Van Ford'
												

			--	--			and TipoContrato in (16)) --removido motorista frota fixa tipo de contrato 3
			--	--			or
			--	--			r.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'
			--	--			,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35',
			--	--			'RVH5G50', 'RVH5G47', 'RVH5G49', 'RVG5F53', 'RVG0G04', 'RVG0G07', 'RVH5G46', 'RVH5G52', 'RUV4E94', 'RUV4E98',
			--	--			'TCG3I07', 'RUX2J27', 'RUX2J26', 'RUM3C10', 'RUL8C97', 'RUW5E58', 'RUV4E97', 'RUW5E67', 'RUM3C14', 'SIR9G29', 
			--	--			'RVH5G41', 'RVH5G43', 'RUX2I97', 'SYZ5B94', 'RUW5E13', 'RVH5G40', 'RUL8C94', 'RUV4E93', 'RUX2J15', 'SJD9D66', 
			--	--			'RUL8C67', 'RUM3C16', 'RUW5E12', 'RVP3G53', 'RUX2J02', 'RUL7F93', 'RUL8C79', 'SIM8F42', 'RUW5E59', 'RUW5D81', 
			--	--			'RUX2J28', 'RUW5E78', 'SJD9D75', 'RVB8F43', 'RNK7H65', 'RUW5E64', 'RUX2J24', 'RUX2J20', 'RVG0G06', 'SJD9D64', 
			--	--			'RUX2J17', 'RUX2J32', 'RUX2I95', 'RUV4E91', 'RUZ1I48', 'RVB8F61', 'RVB8F64', 'RVB8F62', 'RVB8F63', 'SHH6A78', 
			--	--			'SIS6B22', 'RUV4E73', 'RUV4E89', 'RUX2J01', 'RUL7F37', 'RUL8C74', 'RUL8C75', 'SHW9H05', 'RUW6G62', 'RUV9I34', 
			--	--			'RVH5G22', 'RVH5G23', 'RVH5G24', 'SYD9B89', 'RUL7F53', 'RUW5D91', 'RUW5D83', 'RVG0G05', 'RVD4D30', 'RUM3C36', 
			--	--			'RVD4C81', 'RUO6A94', 'SIH2I75', 'RVH5G45', 'RUW5E49', 'RUW5E17', 'SIB2E50', 'RUW5E60', 'RUW5E47', 'RVH5G31', 
			--	--			'RUX2C91', 'RVB8F44', 'RUW5E08', 'RUM3C05', 'SIM8E51', 'SII3G79', 'RVG0G03', 'RUW5E16', 'RUX2C88', 'RVG0G08', 
			--	--			'RUM3C11', 'SHW9H13', 'RUM2B56', 'RUW5E05', 'QMZ0F77', 'RUZ1I50', 'RVG5F56', 'RUL7G08', 'RVB8F65', 'UAI5H95', 
			--	--			'SII3G69', 'RUL8C72', 'RVD4C87', 'RUM3C50', 'RUO6A93', 'SHL9I88', 'RVD4D28', 'SYR9B87', 'RVD4C70', 'RUX2J03', 
			--	--			'RUX2J23', 'RNK7G34', 'RUX2J30', 'RVB8F46', 'RUX2I98', 'RUL8C96', 'RUZ1I49', 'RVH5G48', 'RUZ1I47', 'RUZ1I51', 
			--	--			'RVH5G42', 'RUZ1I46', 'RVH5G25', 'RVH5G26', 'RVH5G32', 'RUV4F21', 'RUV4F23', 'TCG6F43', 'RUV4F98', 'SJD9E21', 
			--	--			'RUO6A95', 'RVD4C89', 'RUZ1I57', 'RUV4E32', 'RUM3C15', 'RVB8F55', 'RVB8F47', 'TCG7H90', 'SUI2E53', 'EOA9C32', 
			--	--			'SIM8F23', 'RUH2A40', 'RUO6B45', 'RUL8C98', 'RUV4F13', 'RUX2J07', 'TCC6E30', 'RUX2C89', 'RUV4F12', 'RUX2J31', 
			--	--			'RUV4F18', 'RUX2J00', 'SHH6B82', 'RUL7F29', 'RNK7H60', 'RUV4F20', 'SIB2G49', 'SID5I75', 'RNK7H32', 'RUW5E07', 
			--	--			'SHO0F24', 'SIN9A77', 'RUW5E19', 'RUV4E95', 'RUV4F19', 'SJE1I64', 'RUX2J22', 'SSV4C07', 'RUV4F22', 'RUW5E04', 
			--	--			'RTS2B17', 'RUX2I99', 'RVH5G51', 'RUW5E15', 'RUL8C95', 'RUW5E02', 'SIY2G07', 'SIB2I02', 'FAB9A57', 'RUW5E66', 
			--	--			'RUL8C68', 'RVD4C75', 'RVD4C69', 'TAK7B92', 'SFJ5E15', 'SFJ5E17', 'SFJ5E59', 'SFJ5E42', 'SIA7J43','SHZ5D73','SIA7J41'
   -- --                        ,'SIA7J19','SIA7J23','SIA7J10','SIA7J12','SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35','CUB4205','RTT0B11'
   -- --                        ,'GBL0E72','EOC8B83','SYE0I39','SJD9D65','RVP9C81','RFU0E09','SHM3E82','SYA  3I62 ','TCC  2I37','SII  8D78','SJZ  8I97'
                            
   -- --                        )
							
			--	--			)
			--	--	then 5
			--	--when r.usouapp = 'Não' and r.idtransportadora = 1
			--	--	and    ((r.TipoVeiculo in ('Rental Utilitário sem Ajudante','Melione Rental Utilitário sem Ajudante',
			--	--								'Rental Utilitário com Ajudante', 'VUC Dedicado com Ajudante',                                                
			--	--								'Utilitário Elétrico BYD','Large Van Elétrica - Equipe Única', 'Large Van Eletrica J750'
			--	--								) 
			--	--								-- removido tipos de veiculos frota fixa ('MeliOne Van Frota Fixa','Van Frota Fixa - Equipe dupla', 'Frota Fixa Large Van Ford Auto','Frota Fixa Large Van Ford'
			--	--			and TipoContrato in (16)) --removido motorista frota fixa tipo de contrato 3
			--	--			or
			--	--			r.placa in ( 'SIA7J43','SHZ5D73','SIA7J41' ,'SIA7J19','SIA7J23','SIA7J10'
			--	--			,'SIA7J12' ,'SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35',
			--	--			'RVH5G50', 'RVH5G47', 'RVH5G49', 'RVG5F53', 'RVG0G04', 'RVG0G07', 'RVH5G46', 'RVH5G52', 'RUV4E94', 'RUV4E98',
			--	--			'TCG3I07', 'RUX2J27', 'RUX2J26', 'RUM3C10', 'RUL8C97', 'RUW5E58', 'RUV4E97', 'RUW5E67', 'RUM3C14', 'SIR9G29', 
			--	--			'RVH5G41', 'RVH5G43', 'RUX2I97', 'SYZ5B94', 'RUW5E13', 'RVH5G40', 'RUL8C94', 'RUV4E93', 'RUX2J15', 'SJD9D66', 
			--	--			'RUL8C67', 'RUM3C16', 'RUW5E12', 'RVP3G53', 'RUX2J02', 'RUL7F93', 'RUL8C79', 'SIM8F42', 'RUW5E59', 'RUW5D81', 
			--	--			'RUX2J28', 'RUW5E78', 'SJD9D75', 'RVB8F43', 'RNK7H65', 'RUW5E64', 'RUX2J24', 'RUX2J20', 'RVG0G06', 'SJD9D64', 
			--	--			'RUX2J17', 'RUX2J32', 'RUX2I95', 'RUV4E91', 'RUZ1I48', 'RVB8F61', 'RVB8F64', 'RVB8F62', 'RVB8F63', 'SHH6A78', 
			--	--			'SIS6B22', 'RUV4E73', 'RUV4E89', 'RUX2J01', 'RUL7F37', 'RUL8C74', 'RUL8C75', 'SHW9H05', 'RUW6G62', 'RUV9I34', 
			--	--			'RVH5G22', 'RVH5G23', 'RVH5G24', 'SYD9B89', 'RUL7F53', 'RUW5D91', 'RUW5D83', 'RVG0G05', 'RVD4D30', 'RUM3C36', 
			--	--			'RVD4C81', 'RUO6A94', 'SIH2I75', 'RVH5G45', 'RUW5E49', 'RUW5E17', 'SIB2E50', 'RUW5E60', 'RUW5E47', 'RVH5G31', 
			--	--			'RUX2C91', 'RVB8F44', 'RUW5E08', 'RUM3C05', 'SIM8E51', 'SII3G79', 'RVG0G03', 'RUW5E16', 'RUX2C88', 'RVG0G08', 
			--	--			'RUM3C11', 'SHW9H13', 'RUM2B56', 'RUW5E05', 'QMZ0F77', 'RUZ1I50', 'RVG5F56', 'RUL7G08', 'RVB8F65', 'UAI5H95', 
			--	--			'SII3G69', 'RUL8C72', 'RVD4C87', 'RUM3C50', 'RUO6A93', 'SHL9I88', 'RVD4D28', 'SYR9B87', 'RVD4C70', 'RUX2J03', 
			--	--			'RUX2J23', 'RNK7G34', 'RUX2J30', 'RVB8F46', 'RUX2I98', 'RUL8C96', 'RUZ1I49', 'RVH5G48', 'RUZ1I47', 'RUZ1I51', 
			--	--			'RVH5G42', 'RUZ1I46', 'RVH5G25', 'RVH5G26', 'RVH5G32', 'RUV4F21', 'RUV4F23', 'TCG6F43', 'RUV4F98', 'SJD9E21', 
			--	--			'RUO6A95', 'RVD4C89', 'RUZ1I57', 'RUV4E32', 'RUM3C15', 'RVB8F55', 'RVB8F47', 'TCG7H90', 'SUI2E53', 'EOA9C32', 
			--	--			'SIM8F23', 'RUH2A40', 'RUO6B45', 'RUL8C98', 'RUV4F13', 'RUX2J07', 'TCC6E30', 'RUX2C89', 'RUV4F12', 'RUX2J31', 
			--	--			'RUV4F18', 'RUX2J00', 'SHH6B82', 'RUL7F29', 'RNK7H60', 'RUV4F20', 'SIB2G49', 'SID5I75', 'RNK7H32', 'RUW5E07', 
			--	--			'SHO0F24', 'SIN9A77', 'RUW5E19', 'RUV4E95', 'RUV4F19', 'SJE1I64', 'RUX2J22', 'SSV4C07', 'RUV4F22', 'RUW5E04', 
			--	--			'RTS2B17', 'RUX2I99', 'RVH5G51', 'RUW5E15', 'RUL8C95', 'RUW5E02', 'SIY2G07', 'SIB2I02', 'FAB9A57', 'RUW5E66', 
			--	--			'RUL8C68', 'RVD4C75', 'RVD4C69', 'TAK7B92', 'SFJ5E15', 'SFJ5E17', 'SFJ5E59', 'SFJ5E42', 'SIA7J43','SHZ5D73','SIA7J41'
   -- --                        ,'SIA7J19','SIA7J23','SIA7J10','SIA7J12','SIA7J09','SIA7J25','SHZ5D98','FGF8G96','LUI2C35','CUB4205','RTT0B11'
   -- --                        ,'GBL0E72','EOC8B83','SYE0I39','SJD9D65','RVP9C81','RFU0E09','SHM3E82','SYA  3I62 ','TCC  2I37','SII  8D78','SJZ  8I97'
                            
   -- --                        )
							
			--	--			)
			--	--	then -10
					

   --             --  when  r.idtransportadora = 33 and r.ServiceCenter = 'SMG14' and NULLIF(r.PacotesEntregues,0) / CAST(NULLIF(r.TotalPacotes,0) as decimal(9,2)) = 1
   --             --     then 20 
   --              when  r.idtransportadora = 33  and r.tipoveiculo in ('Utilitários SDD','Vuc SDD', 'Van SDD','Veículo de Passeio' )  and NULLIF(r.PacotesEntregues,0) / CAST(NULLIF(r.TotalPacotes,0) as decimal(9,2)) = 1
   --                 then 20
			--	when  r.idtransportadora = 57  and  NULLIF(r.PacotesEntregues,0) / CAST(NULLIF(r.TotalPacotes,0) as decimal(9,2)) = 1
   --                 then 10
   --             /* bonus de sucesso da fcargo*/
   --             -- when  r.idtransportadora = 27 and  PacotesNaoEntregue <= 1 and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) = 1 AND R.ServiceCenter = 'SSP7'
   --             --     then 30 
   --             /* bonus 50 mais */
   --             when  r.idtransportadora = 11 and NULLIF(R.PacotesEntregues,0) / CAST(NULLIF(R.TotalPacotes,0) as decimal(9,2)) = 1 AND R.ServiceCenter in ('SCE1','EC1','EC13','SAL1') and isnull(pre.kmciclo,'') <> 'AMBULANCE'
   --                 then 10
			--	else 0 end
   --             +
   --             case 
   --             when r.idtransportadora = 11 and R.ServiceCenter in ('SCE1','EC1','EC13','SAL1') and CidadeBase in ('Trairi','Flecheiras','Córrego Fundo') --alterado de CidadeReferencia para CidadeBase que é o campo utilizado no relatório 
   --                 then 100
   --             when r.idtransportadora = 11 and R.ServiceCenter in ('SPE1') and CidadeBase in ('Abreu e Lima') --alterado de CidadeReferencia para CidadeBase que é o campo utilizado no relatório 
   --                 --Acrescentado por Saulo Barros em 08/05/2025 para pagar bonus para Abreu e Lima apenas se for primeira faixa
			--		and coalesce(freteMenorKmCidade.bfm_vl_inicio_faixa,freteMenorKm.bfm_vl_inicio_faixa, freteKmRTTCidade.bfm_vl_inicio_faixa,freteKmRTT.bfm_vl_inicio_faixa) = 1
			--		then 10
   --             else 0 end Bonificao 

			   ,ISNULL(
				CASE
					WHEN r.idtransportadora = 33  
						 AND r.tipoveiculo IN ('Utilitários SDD','Vuc SDD', 'Van SDD','Veículo de Passeio')  
						 AND NULLIF(r.PacotesEntregues, 0) / CAST(NULLIF(r.TotalPacotes, 0) AS decimal(9,2)) = 1
						THEN 20

					--Comentando por Saulo Barros em 18/06/2025 pois está fazendo o calculo a baixo
					--WHEN r.idtransportadora = 57  
					--	 AND NULLIF(r.PacotesEntregues, 0) / CAST(NULLIF(r.TotalPacotes, 0) AS decimal(9,2)) = 1
					--	THEN 10

					ELSE 0
				END, 0
			)
			-- Comentado por Gabriel Ramos, devido a contabilização no ppr_vl_bonus ao invés de ppr_vl_base
			--+
			--ISNULL(
			--    CASE 
			--        WHEN r.kmAC2 > 100 AND (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END) IS NOT NULL
			--            THEN (r.kmAC2 - 100) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END)
			--        ELSE 0
			--    END, 0
			--)
			+
			ISNULL(
				CASE 
					WHEN r.idtransportadora = 11 
						 AND NULLIF(r.PacotesEntregues, 0) / CAST(NULLIF(r.TotalPacotes, 0) AS decimal(9,2)) = 1 
						 AND r.ServiceCenter IN ('SCE1','EC1','EC13','SAL1') 
						 AND ISNULL(pre.kmciclo, '') <> 'AMBULANCE'
						THEN 10
					ELSE 0
				END, 0
			)
			+
			ISNULL(
				CASE 
					WHEN r.idtransportadora = 11 
						 AND r.ServiceCenter IN ('SCE1','EC1','EC13','SAL1') 
						 AND CidadeBase IN ('Trairi','Flecheiras','Córrego Fundo') 
						THEN 100

					--adicionado em 15/08/2025 por Saulo Barros
					WHEN r.idtransportadora = 11 
						 AND r.ServiceCenter = 'SBA1'
						 and r.TipoVeiculo in ('Veículo de Passeio', 'Utilitários')
						 AND CidadeBase IN ('Camaçari','Dias D''Ávila', 'Dias d`Ávila') 
						 AND COALESCE(
								freteMenorKmCidade.bfm_vl_inicio_faixa,
								freteMenorKm.bfm_vl_inicio_faixa, 
								freteKmRTTCidade.bfm_vl_inicio_faixa,
								freteKmRTT.bfm_vl_inicio_faixa
							 ) = 1
						 and r.DataReferencia >= '2025-08-01'
						THEN 10

					WHEN r.idtransportadora = 11 
						 AND r.ServiceCenter = 'SPE1' 
						 AND CidadeBase = 'Abreu e Lima' 
						 --comentado em 07/11/2025 solicitado pela Natalia para dar 10 reais de bonus independente de faixa
						 --AND COALESCE(
							--	freteMenorKmCidade.bfm_vl_inicio_faixa,
							--	freteMenorKm.bfm_vl_inicio_faixa, 
							--	freteKmRTTCidade.bfm_vl_inicio_faixa,
							--	freteKmRTT.bfm_vl_inicio_faixa
							-- ) = 1
						THEN 10

					WHEN r.idtransportadora = 11 
						 AND r.ServiceCenter = 'SPE1' 
						 AND CidadeBase in ('Paulista', 'Camaragibe', 'São Lourenço da Mata', 'Olinda')
						 AND COALESCE(
								freteMenorKmCidade.bfm_vl_inicio_faixa,
								freteMenorKm.bfm_vl_inicio_faixa, 
								freteKmRTTCidade.bfm_vl_inicio_faixa,
								freteKmRTT.bfm_vl_inicio_faixa
							 ) = 1
						and r.DataReferencia >= '2025-09-16'
						THEN 10

					ELSE 0
				END, 0
			)
			--Criado por Saulo Barros em 18/06/2025 para adicionar regra pontual (será criado um processo apartado para todos casos assim)
			+
			case when r.IdTransportadora = 11 and r.DataReferencia between '2025-06-14' and '2025-06-15' and nullif(r.PacotesEntregues, 0) / cast(nullif(r.TotalPacotes, 0) AS decimal(9,2)) >= 0.94 and r.TipoVeiculo not like '%SDD%' and r.ServiceCenter in ('SBA1', 'SBA2', 'SPA1', 'SAL1', 'SPE1', 'SBA6', 'ECE1') then			
				40
			else
				0
			end
			
			AS Bonificacao

			,svc_espelho
			,bkt_vl_km_ideal
			, Rental
            ,Case when r.idtransportadora = 67 then (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_pedagio ELSE adicional.bfa_vl_adicional_pedagio END) else atp_dc_valor end  as ppr_vl_pedagio -- 24/10 Matheus - alterado Ricoo
			,KmAC2 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END) ValorKmAC2
			,kmAC2
			,ValorFixoPlacaRota
			,(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_recarga ELSE adicional.bfa_vl_adicional_recarga END) AS ppr_vl_recarga
			,1-(isnull(EnderecosVisitados,0) / cast(nullif(totalpacotes,0) as decimal(10,2))) as PercentualEnderecosVisitados
			,pre.EnderecoNaoVisitado as EnderecoNaoVisitadoPrefatura
            ,pre.idrota as rotaprefatura
			,r.OrigemSaida
			,r.KmParceiroSpot

			--Incluído por Saulo Barros em 18/06/2025 para poder calcular o bonus ds e o adicinal de km nos campos abaixo
			--coloca a principio apenas para AC2 e ELO mas na reestrutração precisa calcular independente de transportadora
			,case when r.IdTransportadora in (45, 57) then
				case when (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_bonus_ds ELSE adicional.bfa_vl_bonus_ds END) is not null and nullif(r.PacotesEntregues, 0) / cast(nullif(r.TotalPacotes, 0) AS decimal(9,2)) = 1 then
					(CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_bonus_ds ELSE adicional.bfa_vl_bonus_ds END)
				else
					0
				end
			else
				0
			end ValorBonusDs


			,case when r.IdTransportadora in (45, 57,64) then -- Adicionado OTL Matheus 29/09/2025
				--na elo não retirou 100km, então retiro aqui 
				case when r.kmAC2 > 100 and r.IdTransportadora in(57) and (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END) is not null then
					(r.kmAC2 - 100) * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END)
					
				else
				

					case when adicionalKm = 1 and (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END) is not null and r.IdTransportadora in (45)  then
						r.kmAC2 * (CASE WHEN adicional_cidade.bfa_cd_transportadora IS NOT NULL THEN adicional_cidade.bfa_vl_adicional_km100 ELSE adicional.bfa_vl_adicional_km100 END) 
						
					else
						0
					end
				end
			else
				0
			end ValorAdicionalKm

			,vei_alugar_veiculo
			--,tlm_cd_lancamento_manual

			,r.ppr_in_zerar_rota

			,isnull(editrota.NomeKmEditado,'Km Padrão') ppr_nm_origem_km

			FROM
			#vw_rotas r with (nolock)

            left join (
                SELECT
                    atp_ds_rota
					,atp_cd_codigo_cliente
                    ,sum(atp_dc_valor) as atp_dc_valor
                FROM [tb_atm_pedagios] (NOLOCK)
                where
					atp_in_excluido = 0
					--and atp_cd_codigo_cliente  = 1
					and atp_cd_codigo_status = 1
				group by atp_ds_rota,atp_cd_codigo_cliente
				) pedagios
            on cast(r.idrota as varchar(50)) = pedagios.atp_ds_rota
			AND R.idtransportadora = pedagios.atp_cd_codigo_cliente
	

			left join (
					select vei_ds_placa,vei_cd_valor_aluguel * -1 as vei_alugar_veiculo 
					from tb_veiculos
					where vei_cd_cliente = @clienteid
					and vei_in_ativo	= 1 
					and vei_in_excluido = 0
					and vei_alugar_veiculo = 1
 			) as valorAluguel
			on valorAluguel.vei_ds_placa = r.placa

			left join DimData as calendario (NOLOCK) on r.DataReferencia = calendario.[Data]

				left join vw_fin_prefatura pre (NOLOCK) on @IdTransportadora = pre.IdTransportadora
													and r.IdRota = pre.IdRota and pre.tipopf = @TipoOperacao

													--and r.DataReferencia = pre.DataTermino
													--and pre.Quinzena = @Quinzena
													--and pre.Ano = @Ano
													--and pre.Mes = @Mes
			left join
				(
					select
						mot_nm_motorista NomeMotorista,
						U.mot_cd_cliente IdTransportadora,
						u.mot_ctn_cd_tipo_contrato TipoContrato,
                        mot_cd_usuario as usr_cd_usuario
					from
						tb_motorista u (NOLOCK)
						join tb_clientes c (NOLOCK) on u.mot_cd_cliente = c.cli_cd_codigo_cliente
						--join tb_ml_aprovacao_usuario a on u.usr_cd_usuario = a.mau_cd_usuario_gerado and a.mau_ds_status = 'Aprovado'
					where
						mot_cd_status = 1
						and c.cli_id_logistics <> 0

						--Incluído por Saulo Barros em 27/06/2025 para não considerar tipo de contratp para AC2
						and c.cli_cd_codigo_cliente not in (45,56)  --não considerar tipo de contrato para AC2 e Parceiro Spot
				) m on r.usuarioda = m.usr_cd_usuario and r.IdTransportadora = m.IdTransportadora

                left join #tb_pgto_periodo_rota_edit as editrota
                on CONVERT(VARCHAR,r.IdRota) = editrota.edit_rota


				left join #tb_ml_service_center svc2 on r.ServiceCenter = svc2.svc_cd_service_center and r.idtransportadora = svc2.idtransportadora

				left join #tb_ml_service_center svc with (nolock)
				on case when isnull(r.OrigemSaida,'') <> '' then r.OrigemSaida else r.ServiceCenter end = svc.svc_cd_service_center
				and r.idtransportadora = svc.idtransportadora

				left join (
				/*feriado sera controlado pelo cliente na tela https://50mais.irisys.com.br/feriados */
								select 
									 tfd_cd_cliente idtransportadora
									,bss_ds_sigla servicecenter
									,a.Data
									,1 Feriado
								from DimData as a with (nolock)

								inner join [tb_feriados] as b with (nolock)
								on a.data = b.tfd_dh_feriado

								left join tb_bases  as c with (nolock)
								on bss_cod_cliente = tfd_cd_cliente
								and (
								bss_ds_estado  = tfd_ds_estado
								or tfd_ds_municipio = bss_ds_cidade
								or tfd_tipo_feriado = 'Nacional'
								)
								where tfd_in_excluido = 0
				) as dt 
				on r.DataInicio = dt.Data
				and r.idtransportadora  = dt.idtransportadora
				and r.servicecenter = dt.servicecenter
				

				left join tb_dra_tipo_veiculo tv with (nolock) on r.TipoVeiculo = tv.tvl_nm_tipo_veiculo

				left join tb_fin_cidades_risco_transportadora as risco (NOLOCK) on r.IdTransportadora = risco.crt_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = risco.crt_cd_service_center
																		and r.CidadeReferencia = risco.crt_nm_cidade

				left join (
					        select * 
							from tb_fin_base_km_trevo with (nolock)
							where bkt_cd_transportadora = 2087146923
							) trevo 
													on r.IdTrevo = trevo.bkt_cd_base_km_trevo

													--	r.IdTransportadora = trevo.bkt_cd_transportadora
													--and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = trevo.bkt_cd_service_center
													--and r.Cidades = trevo.bkt_nm_cidades

				left join vw_fin_base_frete_motorista freteTrevo (NOLOCK) on r.IdTransportadora = freteTrevo.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteTrevo.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteTrevo.bfm_cd_tipo_veiculo
																		and (freteTrevo.bfm_nm_cidade is null or freteTrevo.bfm_nm_cidade = '')
																		and r.kmtrevo >= (freteTrevo.bfm_vl_inicio_faixa)
																		and r.kmtrevo <= freteTrevo.bfm_vl_fim_faixa
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteTrevo.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteTrevo.bmf_cd_tipo_contrato,-1))
																						)
																		AND r.DataReferencia BETWEEN freteTrevo.bfm_data_inicio_vigencia AND ISNULL(freteTrevo.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteTrevo.Operacao = @TipoOperacao
																		and freteTrevo.bfm_cd_codigo_cliente = @IdCliTransportadora

				left join vw_fin_base_frete_motorista frete (NOLOCK) on r.IdTransportadora = frete.bfm_cd_transportadora
																		and r.servicecenter = frete.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = frete.bfm_cd_tipo_veiculo
																		and r.CidadeBase = frete.bfm_nm_cidade
																		and r.KmColetado >= (frete.bfm_vl_inicio_faixa-1)
																		and r.KmColetado < (frete.bfm_vl_fim_faixa)
																		AND r.DataReferencia BETWEEN frete.bfm_data_inicio_vigencia AND ISNULL(frete.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and frete.Operacao = @TipoOperacao

																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1))
																						) 
																		and frete.bfm_cd_codigo_cliente = @IdCliTransportadora

				left join vw_fin_base_frete_adicional_motorista adicional_cidade (NOLOCK) on r.IdTransportadora = adicional_cidade.bfa_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_cidade.bfa_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = adicional_cidade.bfa_cd_tipo_veiculo
																		--and (r.CidadeReferencia = adicional_cidade.bfa_nm_cidade or adicional_cidade.bfa_nm_cidade is null)
																		and (r.CidadeReferencia = adicional_cidade.bfa_nm_cidade)
																		-- and isnull(m.TipoContrato,-1) = isnull(adicional_cidade.bfa_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_cidade.bfa_cd_tipo_contrato,-1)
																			--or ( r.IdTransportadora = 40 and 1=1) 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_cidade.bfa_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(adicional_cidade.bfa_cd_tipo_contrato,-1))
																			or ( r.IdTransportadora = 40 and 1=1) 
																						)
																		AND r.DataReferencia BETWEEN adicional_cidade.bfa_data_inicio_vigencia AND ISNULL(adicional_cidade.bfa_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and adicional_cidade.Operacao = @TipoOperacao
																		and adicional_cidade.bfa_cd_codigo_cliente = @IdCliTransportadora

				left join vw_fin_base_frete_adicional_motorista adicional (NOLOCK) on r.IdTransportadora = adicional.bfa_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional.bfa_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = adicional.bfa_cd_tipo_veiculo
																		--and (r.CidadeReferencia = adicional.bfa_nm_cidade or adicional.bfa_nm_cidade is null)
																		and adicional.bfa_nm_cidade is null
																		-- and isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1)
																		--	or ( r.IdTransportadora = 40 and 1=1) 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(adicional.bfa_cd_tipo_contrato,-1))
																			or ( r.IdTransportadora = 40 and 1=1) 
																						)
																		AND r.DataReferencia BETWEEN adicional.bfa_data_inicio_vigencia AND ISNULL(adicional.bfa_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and adicional.Operacao = @TipoOperacao
																		and adicional.bfa_cd_codigo_cliente = @IdCliTransportadora



				left join (
					SELECT
					*
					FROM
					vw_fin_base_frete_adicional_motorista with (nolock)
					WHERE bfa_cd_tipo_veiculo IN (1,4)
					and bfa_cd_base_frete_adicional_motorista <> 1309
					and Operacao = @TipoOperacao
					and bfa_cd_codigo_cliente = @IdCliTransportadora

				) adicional_pool  on r.IdTransportadora = adicional_pool.bfa_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_pool.bfa_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = adicional_pool.bfa_cd_tipo_veiculo
																		and (r.CidadeReferencia = adicional_pool.bfa_nm_cidade or adicional_pool.bfa_nm_cidade is null)
																		-- and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1)
																		--	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(adicional_pool.bfa_cd_tipo_contrato,-1))
																						)
																		AND r.DataReferencia BETWEEN adicional_pool.bfa_data_inicio_vigencia AND ISNULL(adicional_pool.bfa_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))

				left join vw_fin_base_frete_motorista freteKm with (nolock)  on r.IdTransportadora = freteKm.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKm.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = freteKm.bmf_cd_tipo_contrato
																		and (freteKm.bfm_nm_cidade is null or freteKm.bfm_nm_cidade = '')
																		and trevo.bkt_vl_km_ideal > (freteKm.bfm_vl_inicio_faixa - 1)
                                                                        and trevo.bkt_vl_km_ideal < (freteKm.bfm_vl_fim_faixa - 1)
																		-- and isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1)
																		--	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKm.bmf_cd_tipo_contrato,-1))
																						)
																		AND r.DataReferencia BETWEEN freteKm.bfm_data_inicio_vigencia AND ISNULL(freteKm.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKm.Operacao = @TipoOperacao
																		and freteKm.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKm2 with (nolock)  on r.IdTransportadora = freteKm2.bfm_cd_transportadora
																		--and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm2.bfm_cd_service_center
																		and R.servicecenter = freteKm2.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKm2.bfm_cd_tipo_veiculo
																		and (freteKm2.bfm_nm_cidade is null or freteKm2.bfm_nm_cidade = '')
																		and r.KmColetado > (freteKm2.bfm_vl_inicio_faixa-1)
																		and r.KmColetado <= (freteKm2.bfm_vl_fim_faixa)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKm2.bmf_cd_tipo_contrato,-1))
																						)

																			-- or (1=1)	
																			 --) 
																		--and ( r.idtransportadora = 45
																		--	  or isnull(m.TipoContrato,-1) = isnull(frete.bmf_cd_tipo_contrato,-1)
																		--	) 

																		AND r.DataReferencia BETWEEN freteKm2.bfm_data_inicio_vigencia AND ISNULL(freteKm2.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKm2.Operacao = @TipoOperacao
																		and freteKm2.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista adicional_fixo with (nolock) on adicional_fixo.bfm_vl_frete_fixo is NOT null
																		AND r.IdTransportadora = adicional_fixo.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = adicional_fixo.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = adicional_fixo.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1)
																		--)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(adicional_fixo.bmf_cd_tipo_contrato,-1))
																						)
																		and r.Cidades = r.CidadeReferencia
																		--and r.cidades = adicional_fixo.bfm_nm_cidade
																		and r.CidadeReferencia = adicional_fixo.bfm_nm_cidade
																		AND r.DataReferencia BETWEEN adicional_fixo.bfm_data_inicio_vigencia AND ISNULL(adicional_fixo.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and adicional_fixo.Operacao = @TipoOperacao
																		and adicional_fixo.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKmMotorista with (nolock)  on r.IdTransportadora = freteKmMotorista.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmMotorista.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKmMotorista.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1)
																		--	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKmMotorista.bmf_cd_tipo_contrato,-1))
																						)
																		and (freteKmMotorista.bfm_nm_cidade is null or freteKmMotorista.bfm_nm_cidade = '')
																		and r.KmMotorista > (freteKmMotorista.bfm_vl_inicio_faixa - 1)
																		and r.KmMotorista <= freteKmMotorista.bfm_vl_fim_faixa
																		AND r.DataReferencia BETWEEN freteKmMotorista.bfm_data_inicio_vigencia AND ISNULL(freteKmMotorista.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKmMotorista.Operacao = @TipoOperacao
																		and freteKmMotorista.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKm0a100 with (nolock)  on r.IdTransportadora = freteKm0a100.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm0a100.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKm0a100.bfm_cd_tipo_veiculo
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1))
																						)
																		-- and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																		-- 	 	)
																		and (freteKm0a100.bfm_nm_cidade is null or freteKm0a100.bfm_nm_cidade = '')
																		and freteKm0a100.bfm_vl_inicio_faixa = 1
																		AND r.DataReferencia BETWEEN freteKm0a100.bfm_data_inicio_vigencia AND ISNULL(freteKm0a100.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKm0a100.Operacao = @TipoOperacao
																		and freteKm0a100.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKm0a100Cidade with (nolock)  on r.IdTransportadora = freteKm0a100Cidade.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKm0a100Cidade.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKm0a100Cidade.bfm_cd_tipo_veiculo
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100Cidade.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100Cidade.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKm0a100Cidade.bmf_cd_tipo_contrato,-1))
																						)
																		-- and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKm0a100.bmf_cd_tipo_contrato,-1)
																		-- 	 	)
																		and freteKm0a100Cidade.bfm_nm_cidade = r.cidadebase
																		and freteKm0a100Cidade.bfm_vl_inicio_faixa = 1
																		AND r.DataReferencia BETWEEN freteKm0a100Cidade.bfm_data_inicio_vigencia AND ISNULL(freteKm0a100Cidade.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKm0a100Cidade.Operacao = @TipoOperacao
																		and freteKm0a100Cidade.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKmPreFatura with (nolock)  on r.IdTransportadora = freteKmPreFatura.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmPreFatura.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKmPreFatura.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1)
																		-- 	 	or ( r.IdTransportadora = 40 and 1=1))
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKmPreFatura.bmf_cd_tipo_contrato,-1))
																			or ( r.IdTransportadora = 40 and 1=1)
																			)

																		and (freteKmPreFatura.bfm_nm_cidade is null or freteKmPreFatura.bfm_nm_cidade = '')
																		and coalesce(LEFT(editrota.edit_Faixa_KM, CHARINDEX('/', editrota.edit_Faixa_KM + '/') - 1),pre.InicioIntervalo,1) >= freteKmPreFatura.bfm_vl_inicio_faixa
																		and coalesce(LEFT(editrota.edit_Faixa_KM, CHARINDEX('/', editrota.edit_Faixa_KM + '/') - 1),case when isnull(pre.FimIntervalo,50) = 99999 then 9999 else isnull(pre.FimIntervalo,50) end) <= freteKmPreFatura.bfm_vl_fim_faixa
																		AND r.DataReferencia BETWEEN freteKmPreFatura.bfm_data_inicio_vigencia AND ISNULL(freteKmPreFatura.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKmPreFatura.Operacao = @TipoOperacao
																		and freteKmPreFatura.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKmPreFaturaCidade with (nolock)  on r.IdTransportadora = freteKmPreFaturaCidade.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmPreFaturaCidade.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKmPreFaturaCidade.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1)
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1))
																						)
																		and freteKmPreFaturaCidade.bfm_nm_cidade = r.cidadebase
																		and isnull(pre.InicioIntervalo,1) >= freteKmPreFaturaCidade.bfm_vl_inicio_faixa
																		and case when isnull(pre.FimIntervalo,50) = 99999 then 9999 else isnull(pre.FimIntervalo,50) end <= freteKmPreFaturaCidade.bfm_vl_fim_faixa
																		AND r.DataReferencia BETWEEN freteKmPreFaturaCidade.bfm_data_inicio_vigencia AND ISNULL(freteKmPreFaturaCidade.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKmPreFaturaCidade.Operacao = @TipoOperacao
																		and freteKmPreFaturaCidade.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKmRTT with (nolock)  on r.IdTransportadora = freteKmRTT.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmRTT.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteKmRTT.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(freteKmRTT.bmf_cd_tipo_contrato,-1)
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmRTT.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmRTT.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKmRTT.bmf_cd_tipo_contrato,-1))
																						)
																		and (freteKmRTT.bfm_nm_cidade is null or freteKmRTT.bfm_nm_cidade = '')
																		and (
																				(
																					r.KmRTT > (freteKmRTT.bfm_vl_inicio_faixa - 1)
																					and r.KmRTT <= freteKmRTT.bfm_vl_fim_faixa
																					and editrota.edit_Faixa_Km is null
																				)
																				or
																				editrota.edit_Faixa_Km = cast(freteKmRTT.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteKmRTT.bfm_vl_fim_faixa as varchar)
																			)
																		AND r.DataReferencia BETWEEN freteKmRTT.bfm_data_inicio_vigencia AND ISNULL(freteKmRTT.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteKmRTT.Operacao = @TipoOperacao
																		and freteKmRTT.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteKmRTTCidade with (nolock)  on r.IdTransportadora = freteKmRTTCidade.bfm_cd_transportadora
																and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteKmRTTCidade.bfm_cd_service_center
																and tv.tvl_cd_tipo_veiculo = freteKmRTTCidade.bfm_cd_tipo_veiculo
																--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1)
																	--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmRTTCidade.bmf_cd_tipo_contrato,-1)
																	--		)

																and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteKmRTTCidade.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteKmRTTCidade.bmf_cd_tipo_contrato,-1))
																						)
																and freteKmRTTCidade.bfm_nm_cidade = r.cidadebase
																and (
																		(
																			r.KmRTT > (freteKmRTTCidade.bfm_vl_inicio_faixa - 1)
																			and r.KmRTT <= freteKmRTTCidade.bfm_vl_fim_faixa
																			and editrota.edit_Faixa_Km is null
																		)
																		or
																		editrota.edit_Faixa_Km = cast(freteKmRTTCidade.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteKmRTTCidade.bfm_vl_fim_faixa as varchar)
																	)
																AND r.DataReferencia BETWEEN freteKmRTTCidade.bfm_data_inicio_vigencia AND ISNULL(freteKmRTTCidade.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																and freteKmRTTCidade.Operacao = @TipoOperacao
																and freteKmRTTCidade.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteMenorKm with (nolock)  on r.IdTransportadora = freteMenorKm.bfm_cd_transportadora
																		and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteMenorKm.bfm_cd_service_center
																		and tv.tvl_cd_tipo_veiculo = freteMenorKm.bfm_cd_tipo_veiculo
																		--and isnull(m.TipoContrato,-1) = isnull(freteMenorKm.bmf_cd_tipo_contrato,-1)
																		 --and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteMenorKm.bmf_cd_tipo_contrato,-1)
																		 --	 	)
																		and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteMenorKm.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteMenorKm.bmf_cd_tipo_contrato,-1))
																						)
																		and (freteMenorKm.bfm_nm_cidade is null or freteMenorKm.bfm_nm_cidade = '')
																		and (
																				(
																					r.menor_km > (freteMenorKm.bfm_vl_inicio_faixa - 1)
																					and r.menor_km <= freteMenorKm.bfm_vl_fim_faixa
																					and editrota.edit_Faixa_Km is null
																				)
																				or
																				editrota.edit_Faixa_Km = cast(freteMenorKm.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteMenorKm.bfm_vl_fim_faixa as varchar)
																			)
																		AND r.DataReferencia BETWEEN freteMenorKm.bfm_data_inicio_vigencia AND ISNULL(freteMenorKm.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																		and freteMenorKm.Operacao = @TipoOperacao
																		and freteMenorKm.bfm_cd_codigo_cliente = @IdCliTransportadora

			left join vw_fin_base_frete_motorista freteMenorKmCidade with (nolock)  on r.IdTransportadora = freteMenorKmCidade.bfm_cd_transportadora
																and isnull(svc.svc_cd_service_center,svc2.svc_cd_service_center) = freteMenorKmCidade.bfm_cd_service_center
																and tv.tvl_cd_tipo_veiculo = freteMenorKmCidade.bfm_cd_tipo_veiculo
																--and isnull(m.TipoContrato,-1) = isnull(freteKmPreFaturaCidade.bmf_cd_tipo_contrato,-1)
																	--and (@tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteMenorKmCidade.bmf_cd_tipo_contrato,-1)
																	--		)
																and (
																			(@TipoOperacao = 'FM' and @tipocontrato = '-1' OR isnull(m.TipoContrato,-1) = isnull(freteMenorKmCidade.bmf_cd_tipo_contrato,-1))
																			or (isnull(m.TipoContrato,-1) = isnull(freteMenorKmCidade.bmf_cd_tipo_contrato,-1))
																						)
																and freteMenorKmCidade.bfm_nm_cidade = r.cidadebase
																and (
																		(
																			r.menor_km > (freteMenorKmCidade.bfm_vl_inicio_faixa - 1)
																			and r.menor_km <= freteMenorKmCidade.bfm_vl_fim_faixa
																			and editrota.edit_Faixa_Km is null
																		)
																		or
																		editrota.edit_Faixa_Km =cast( freteMenorKmCidade.bfm_vl_inicio_faixa as varchar) + '/' + cast(freteMenorKmCidade.bfm_vl_fim_faixa as varchar)
																	)
																AND r.DataReferencia BETWEEN freteMenorKmCidade.bfm_data_inicio_vigencia AND ISNULL(freteMenorKmCidade.bfm_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
																and freteMenorKmCidade.Operacao = @TipoOperacao
																and freteMenorKmCidade.bfm_cd_codigo_cliente = @IdCliTransportadora
			left JOIN
				(
                    /*Comentado por Gabriel Ramos 19/11/2025 para ajustar problema de soma dos lançamentos Manuais 
					> Alinhado com o Samuel que irá pegar apenas a primeira observação*/
					--SELECT	*,
					--		ROW_NUMBER() OVER(PARTITION BY tlm_cd_cliente, IdRota ORDER BY Data DESC) AS ID
					--FROM (
					--		select
					--			 tlm_cd_cliente
					--			,trim(cast(tlm_cd_rota as varchar(50))) as IdRota
					--			,tlm_dh_referencia as Data
					--			,sum(isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
					--				+ case when plm_nm_tipo = 'Apoio' then (-1 * isnull(tlm_vl_valor_apoio,0)) else (-1 * isnull(tlm_vl_valor_descontos,0)) end) ValorApoio
					--			,tlm_ds_observacao
					--		from 
					--			vw_lancamentos_manuais_aprovados
					--		where 
					--			plm_in_calculo_desconto = 0
					--			and (@idrota is null or tlm_cd_rota = @idrota)
					--			and Operacao = @TipoOperacao
					--			and tlm_cd_cliente = @clienteid
					--		group by
					--			tlm_cd_cliente,
					--			cast(tlm_cd_rota as varchar(50)),
					--			tlm_dh_referencia,
					--			tlm_ds_observacao
							
									
					--	  ) LNC
								SELECT
									  TRIM(CAST(tlm_cd_rota AS VARCHAR(50))) AS IdRota
									, SUM(ISNULL(tlm_vl_valor_adicional,0)+ ISNULL(tlm_vl_valor_rota,0) + case when plm_nm_tipo = 'ROTAS DE BIKE' then isnull(tlm_vl_valor_apoio,0) else 0 end 
												+ CASE WHEN plm_nm_tipo = 'Apoio'  THEN (-1 * ISNULL(tlm_vl_valor_apoio,0)) ELSE (-1 * ISNULL(tlm_vl_valor_descontos,0)) END) AS ValorApoio
								, MIN(tlm_ds_observacao) AS tlm_ds_observacao   
							FROM 
								vw_lancamentos_manuais_aprovados
							WHERE 
								  plm_in_calculo_desconto = 0
								  AND (@idrota is null or tlm_cd_rota = @idrota)
								  AND Operacao = @TipoOperacao
								  AND tlm_cd_cliente = @clienteid
								  and tlm_dh_referencia >= @data_inicial
								  and tlm_dh_referencia < dateadd(day,1,@data_final)
							GROUP BY
								  TRIM(CAST(tlm_cd_rota AS VARCHAR(50)))
				) as lancamentos
				on cast(r.IdRota as varchar(50)) = lancamentos.IdRota
				--	AND lancamentos.ID = 1
				
				
			where 1=1
			and r.DataReferencia < cast(getdate() as date)

		) AS ROTAS;






		if @clienteid = 37 and @data_inicial >= '2025-11-16'
		begin
			update #tabela_insert
		set ppr_vl_dom_fer = ppr_vl_dom_fer*2
			where 
			ppr_data_referencia between  '2025-11-16' and '2025-12-28' and ppr_vl_dom_fer <> 0
		end


		--Adicionado por Saulo Barros em 19/08/2025
		if @clienteid = 11 and @data_inicial = '2025-08-01'
		begin
			
			--Regra: se o motorista tiver trabalhado tanto no dia 09 quanto no dia 10 de Agosto (dia dos pais) e for do SVC de SPE1 ou ERN4 e não for ambulancia
			--		 recebe 40 reais pelo dia do sábado e 45 reais pelo dia de domingo

			drop table if exists #bonus_incentivo_dia_dos_pais
			select
				min(t.ppr_cd_rota) ppr_cd_rota
				,t.ppr_nome_motorista
				,case when ppr_data_referencia = '2025-08-09' then 40 else 45 end ppr_vl_bonus
				into #bonus_incentivo_dia_dos_pais
			from
				#tabela_insert t
				join (
						select 
							ppr_nome_motorista
						from 
							#tabela_insert
						where 
							ppr_base_principal in ('SPE1', 'ERN4')
							and ppr_data_referencia between '2025-08-09' and '2025-08-10'
							and ppr_in_ambulancia = 0
						group by 
							ppr_nome_motorista
						having 
							count(distinct ppr_data_referencia) = 2
					) t2 on t.ppr_nome_motorista = t2.ppr_nome_motorista
			where
				t.ppr_base_principal in ('SPE1', 'ERN4')
				and t.ppr_data_referencia between '2025-08-09' and '2025-08-10'
				and ppr_in_ambulancia = 0
			group by
				t.ppr_nome_motorista
				,t.ppr_data_referencia
			order by
				2

			update
				t
			set
				ppr_vl_bonus = isnull(t.ppr_vl_bonus,0) + b.ppr_vl_bonus
				,ppr_vl_total = isnull(t.ppr_vl_total,0) + b.ppr_vl_bonus
			from
				#tabela_insert t
				join #bonus_incentivo_dia_dos_pais b on t.ppr_cd_rota = b.ppr_cd_rota
			
		end

		--Regra criada por Saulo Barros em 09/03/2026 para não calcular valor de rota da Parceiro caso não tenha pacotes entregues
		if @clienteid = 56 
		begin
			update  
				#tabela_insert
			set 
				ppr_vl_base		= 0
				,ppr_vl_paradas		= 0
				,ppr_vl_risco		= 0
				,ppr_vl_ajudante	= 0
				,ppr_vl_dom_fer		= 0
				,ppr_vl_bonus		= 0
				,ppr_vl_total		= ppr_vl_lancamentos
			where 
				ppr_cd_periodo = @CodPeriodoPagamento
				and ppr_qt_pacotes_entregues = 0
				and @TipoOperacao <> 'FM'
		end 

		--Regra removida por Gustavo Tavares em 05/05/2026 por solicitação do cliente
		/*
		--Regra criada por Saulo Barros em 22/04/2026 para zerar valor da rota se tiver menos de 20 pacotes entregues para Rodoprime
		if @clienteid = 61 and @data_inicial >= '2026-04-01'
		begin
			update  
				#tabela_insert
			set 
				ppr_vl_base		= 0
				,ppr_vl_paradas		= 0
				,ppr_vl_risco		= 0
				,ppr_vl_ajudante	= 0
				,ppr_vl_dom_fer		= 0
				,ppr_vl_bonus		= 0
				,ppr_vl_total		= ppr_vl_lancamentos
			where 
				ppr_cd_periodo = @CodPeriodoPagamento
				and ppr_qt_pacotes < 20
		end 
		*/


		--Será Migrado para TB_VEICULOS
		--Estes motoristas dirigem placas que sao tipo de ajudante mas nao tem ajudante
		 update #tabela_insert
set ppr_vl_base = 150
,ppr_vl_total = (150    + ppr_vl_paradas    + ppr_vl_risco +    ppr_vl_ajudante +   ppr_vl_dom_fer  + ppr_vl_lancamentos)
where ppr_nome_motorista in ('PAULO RICARDO MOTA DOS SANTOS','MATHEUS FERREIRA IBANHEZ','PEDRO HENRIQUE DE SOUZA','EDINEI CELESTRINO DE SOUZA','VINICIUS NASCIMENTO DE JESUS','EDGAR FERNANDES RIBAS',
'FABIANO CAMILO SOUZA ANDRADE','ALEXANDRE FERREIRA SUSUKI','REINALDO MANZELA DE MEDEIROS','GUSTAVO JUNIO MAXIMO BRAGA','RODRIGO DE LIMA GERONIMO',
'LINCON RIBEIRO DE SOUZA','RODRIGO ANTONIO CRUZ')
and ppr_ds_placa in ('SFN7I49','STP9H08','SSX4A25','TAO4A29','TAR2I86','TAR2I89','SSX9F39','TAR3E09','GES4H74','GHS8D82','SUW8E88', 'SWR4E09','SWF9F34')
and ppr_cd_periodo = 649


--Será Migrado para TB_VEICULOS
		--Estes motoristas tem valor fixo de 180 sem paradas
		 update #tabela_insert
set ppr_vl_base = 180
,ppr_vl_paradas = 0
,ppr_vl_total = (180 + isnull(ppr_vl_risco,0) +    isnull(ppr_vl_ajudante,0) +   isnull(ppr_vl_dom_fer,0)  + isnull(ppr_vl_lancamentos,0))
where ppr_nome_motorista in ('MATHEUS HENRIQUE MOREIRA SILVA', 'MARCO TULIO RIBEIRO DE OLIVEIRA')
and ppr_ds_placa in ('SIA7J23','SIA7J25')
and ppr_cd_periodo = 551


update #tabela_insert
set ppr_vl_dom_fer = ppr_vl_dom_fer*2
where 
ppr_data_referencia =  '2025-07-09' and ppr_vl_dom_fer <> 0 and ppr_cd_periodo = 718

 update #tabela_insert
set ppr_vl_total = (isnull(ppr_vl_base,0) + isnull(ppr_vl_risco,0) +    isnull(ppr_vl_ajudante,0) +   isnull(ppr_vl_dom_fer,0)  + isnull(ppr_vl_lancamentos,0))
where 
ppr_data_referencia =  '2025-06-15' and ppr_vl_dom_fer <> 0 and ppr_cd_periodo = 658


	 update #tabela_insert
set ppr_vl_base = 180
,ppr_vl_paradas = 0
,ppr_vl_total = (180 + isnull(ppr_vl_risco,0) +    isnull(ppr_vl_ajudante,0) +   isnull(ppr_vl_dom_fer,0)  + isnull(ppr_vl_lancamentos,0))
where ppr_base_principal = 'SSP22'
and ppr_cd_periodo = 649
and ppr_nm_cidade = 'São Carlos'


if @clienteid = 40
begin
	update  #tabela_insert
	set  ppr_cd_faixa_km = case when ppr_vl_valor_frete < ppr_vl_total_km_prefatura and ppr_vl_valor_frete > 0 then FaixaKm2 else ppr_cd_faixa_km end
end
-- Processo abaixo zera o valor da base caso o success delivery ser menor que 0.9 

if @clienteid = 27 
begin
    update  #tabela_insert
    set 
        ppr_vl_base		= 0
    ,ppr_vl_paradas		= 0
    ,ppr_vl_risco		= 0
    ,ppr_vl_ajudante	= 0
    ,ppr_vl_dom_fer		= 0
    ,ppr_vl_lancamentos	= 0
    ,ppr_vl_total		= 0

    where ppr_per_endereco_nao_visitado > 0.9
    and ppr_cd_periodo = @CodPeriodoPagamento
end 

if @clienteid = 64
begin
    update  #tabela_insert
    set 
     ppr_vl_base		= 0
  --  ,ppr_vl_paradas		= 0
   --,ppr_vl_risco		= 0
   --,ppr_vl_ajudante	= 0
   --,ppr_vl_dom_fer		= 0
   --,ppr_vl_lancamentos	= 0
   --,ppr_vl_total		= 0

    where ppr_per_endereco_nao_visitado > 0.1
    and ppr_cd_periodo = @CodPeriodoPagamento
end 




if @clienteid = 45 
begin
    update #tabela_insert
    set 
        ppr_vl_base = 
            case when ppr_vl_success_delivery < 0.5 then 0
			else
				case 
					when ppr_ds_ciclo = 'PM' THEN isnull(ppr_vl_pm * ppr_vl_success_delivery,0)
					else isnull(ppr_vl_valor_frete * ppr_vl_success_delivery,0) 
				end
			end,
        ppr_vl_paradas     = 0,
        ppr_vl_risco       = 0,
        ppr_vl_ajudante    = 0,
        ppr_vl_dom_fer     = 0,
        ppr_vl_lancamentos = 0,
		ppr_vl_total = (
            isnull(
                case when ppr_vl_success_delivery < 0.5 then 0
				else
					case 
					  when ppr_ds_ciclo = 'PM' THEN isnull(ppr_vl_pm * ppr_vl_success_delivery,0)
					  else isnull(ppr_vl_valor_frete * ppr_vl_success_delivery,0) 
					end
				end, 0
            )
            + ISNULL(ppr_vl_paradas,     0)
            + ISNULL(ppr_vl_dom_fer,     0)
            + ISNULL(ppr_vl_risco,       0)
            + ISNULL(ppr_vl_ajudante,    0)
            + ISNULL(ppr_vl_lancamentos, 0)
            + ISNULL(ppr_vl_bonus,       0)
            + ISNULL(ppr_vl_recarga,     0)
            + ISNULL(ppr_vl_aluguel,     0)
            + ISNULL(ppr_vl_pedagio,     0)
            + ISNULL(ppr_vl_desconto,    0)
        )
    where 
        ppr_vl_success_delivery < 0.90
        AND ppr_cd_periodo = @CodPeriodoPagamento

		--incluido por Saulo Barros em 02/07/2025 para não considerar essa regra para domingo e feriados
		and ppr_in_dom_fer=0

		--adicionado por Saulo Barros em 11/05/2025 para não considerar essa regra quando o pagamento for fixo (por placa)
		and ppr_in_pgto_fixo = 0
end


--Regra criada por Saulo Barros em 30/03/2026 para zerar valor de rota da AC2 que for ambulancia e o tipo do veículo for SDD
if @clienteid = 45 
begin
	update  
		#tabela_insert
	set 
		ppr_vl_base			= 0
		,ppr_vl_paradas		= 0
		,ppr_vl_risco		= 0
		,ppr_vl_ajudante	= 0
		,ppr_vl_dom_fer		= 0
		,ppr_vl_total		= ppr_vl_lancamentos
	where 
		ppr_cd_periodo = @CodPeriodoPagamento
		and ppr_in_ambulancia = 1
		and ppr_ds_tipo_veiculo like '%SDD%'
		--and ppr_ds_tipo_veiculo not in ('Veículo de Passeio', 'Utilitários', 'Van', 'Vuc')
end


if @clienteid = 45 and @data_final >= '2026-07-26'
begin	
    -- 1) Identificar 1ª rota do motorista no dia (DataHoraInicio)
    drop table if exists #bonus_sdd_ac2;
    select
        t.ppr_cd_rota,
        case
            when t.ppr_ds_tipo_veiculo in ('Utilitários SDD','Van SDD') then 46.15
            when t.ppr_ds_tipo_veiculo = 'Vuc SDD' then 30.76
        end as vl_bonus
    into #bonus_sdd_ac2
    from (
        select
            t.*,
            r.DataHoraInicio,
            row_number() over (
                partition by t.ppr_cd_motorista, t.ppr_data_referencia
                order by r.DataHoraInicio, t.ppr_cd_rota
            ) as ordem_rota_dia
        from #tabela_insert t
        inner join #vw_rotas r on cast(r.IdRota as varchar(50)) = t.ppr_cd_rota
        where t.ppr_cd_periodo = @CodPeriodoPagamento
          and t.ppr_data_referencia >= '2026-07-26'
          and t.ppr_ds_tipo_veiculo in ('Utilitários SDD','Van SDD','Vuc SDD')
          and t.ppr_in_ambulancia = 0
          and t.ppr_in_zerar_rota = 0
          and (
                (t.ppr_in_dom_fer = 0 and t.ppr_vl_success_delivery >= 0.985)
             or (t.ppr_in_dom_fer = 1 and t.ppr_vl_success_delivery >= 0.95)
          )
    ) t
    where t.ordem_rota_dia = 1;

    -- 2) Aplicar bonificação
    update t
    set
        ppr_vl_bonus_ds = isnull(t.ppr_vl_bonus_ds, 0) + b.vl_bonus,
        ppr_vl_total = isnull(t.ppr_vl_total, 0) + b.vl_bonus
    from #tabela_insert t
    inner join #bonus_sdd_ac2 b on t.ppr_cd_rota = b.ppr_cd_rota;
end





--Zera rotas que tiver sido alterado o flag para zerar
update  
	#tabela_insert
set 
	ppr_vl_base			= 0
	,ppr_vl_paradas		= 0
	,ppr_vl_risco		= 0
	,ppr_vl_ajudante	= 0
	,ppr_vl_dom_fer		= 0
	,ppr_vl_bonus		= 0
	,ppr_vl_total		= ppr_vl_lancamentos
where 
	ppr_cd_periodo = @CodPeriodoPagamento
	and ppr_in_zerar_rota = 1

	drop table if exists #espelho
	select
		distinct
		--Alteração por Saulo Barros em 24/02 para considerar o código do motorista o mesmo que vem da origem do  tb_pgto_periodo_rota (retirado left join na usuario e alterado groupby)
		 --usr_cd_usuario as mtn_cd_motorista
		 a.ppr_cd_motorista mtn_cd_motorista
		 --Fim Alteração
		--,a.*
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,228 mtn_cd_status
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,null mtn_ds_link_nfs
		,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
		,getdate() mtn_dh_criacao
		,7174 as mtn_cd_usr_criacao
		,getdate() mtn_dh_modificacao
		,7174 as mtn_cd_usr_modificacao
		,0 as mtn_in_excluido
		,periodo.pgp_cd_cliente as mtn_cod_cliente
		,count(*) as mtn_qt_rotas
		,94  as mtn_cd_tipo_espelho
		,@IdCliTransportadora as mtn_cd_cliente_transportadora
		,bss_cd_base as mtn_cd_base
		--,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
		,svc_espelho mtn_base_principal
		,@operacao as mtn_cd_operacao
		into #espelho

	from #tabela_insert as a

	left join [tb_pgto_periodo] as periodo (NOLOCK)
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	left join tb_clientes (NOLOCK) AS CLI ON CLI.cli_cd_codigo_cliente = periodo.pgp_cd_cliente

--	left join (
--					SELECT	usr_nm_usuario usr_nm_usuario,
--							cli_cd_codigo_cliente,
--							usr_cd_usuario,
--							ROW_NUMBER() OVER(PARTITION BY usr_nm_usuario, cli_cd_codigo_cliente ORDER BY usr_cd_usuario DESC) AS ID
--					FROM tb_usuario
--					WHERE usr_in_ativo = 1
--			   ) as usu
--	on ppr_nome_motorista  = usr_nm_usuario
----	and usu.usr_in_ativo = 1
--    and usu.cli_cd_codigo_cliente = @clienteid
--	and usu.ID = 1

	--left join vw_rotas as b (NOLOCK)
	--on a.ppr_cd_rota = b.idrota
	--	AND b.IdTransportadora = CLI.cli_id_logistics

	left join tb_bases as c (NOLOCK)
	on a.svc_espelho = c.bss_ds_sigla
	and c.bss_cd_idtransportadora = @IdTransportadora

	WHERE ppr_in_excluido = 0

	--where ppr_cd_periodo = 4298
	--where ppr_cd_rota = 146941866

	--group by  usr_cd_usuario ,ppr_cd_periodo,periodo.pgp_cd_cliente,bss_cd_base,ppr_nome_motorista,svc_espelho;
	group by  a.ppr_cd_motorista ,ppr_cd_periodo,periodo.pgp_cd_cliente,bss_cd_base,ppr_nome_motorista,svc_espelho;
	--case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end;

CREATE NONCLUSTERED INDEX [IDX_periodo]
ON [dbo].[#espelho] ([mtn_cd_pgto_periodo])
INCLUDE ([mtn_nome_motorista],[mtn_vl_nfs],[mtn_base_principal])



	--Regra criada por Saulo Barros em 26/02/2025 para gerar para 50+ espelhos dos motoristas que receberam de apoio que não tiveram rotas
	if @clienteid = 11
	begin
		insert into #espelho
		select
			usr_cd_usuario as mtn_cd_motorista
			,tlm_ds_motorista_apoio as mtn_nome_motorista
			,@CodPeriodoPagamento as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,SUM(isnull(tlm_vl_valor_apoio,0)) as mtn_vl_nfs
			,null mtn_ds_link_nfs
			,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,7174 as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,7174 as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@clienteid as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94  as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,bss_cd_base as mtn_cd_base
			--,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
			,tlm_cd_service_center mtn_base_principal
			,@operacao as mtn_cd_operacao
		from 
			vw_lancamentos_manuais_aprovados a
			left join (select distinct NomeMotorista from vw_rotas (NOLOCK) where IdTransportadora = @IdTransportadora and DataReferencia between @data_inicial and @data_final and UsuarioDA is not null) m on a.tlm_ds_motorista_apoio = m.NomeMotorista
			join (
						SELECT	
							usr_nm_usuario usr_nm_usuario,
							cli_cd_codigo_cliente,
							usr_cd_usuario,
							ROW_NUMBER() OVER(PARTITION BY usr_nm_usuario, cli_cd_codigo_cliente ORDER BY usr_cd_usuario DESC) AS ID
						FROM 
							tb_usuario (NOLOCK)
						WHERE 
							usr_in_ativo = 1
							and cli_cd_codigo_cliente = @clienteid
					   ) as usu
			on a.tlm_ds_motorista_apoio  = usr_nm_usuario
			and usu.ID = 1
			left join tb_bases as c (NOLOCK) on a.tlm_cd_service_center = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
		where 
			a.plm_in_calculo_desconto = 0
			and tlm_cd_cliente <> 37
			and a.Operacao = @TipoOperacao
			and cast(tlm_dh_referencia as date) between @data_inicial and @data_final
			and a.plm_nm_tipo = 'Apoio'
			and a.tlm_ds_motorista_apoio <> 'null'
			and m.NomeMotorista is null
			and a.tlm_cd_cliente = @clienteid
		group by
			usr_cd_usuario
			,tlm_ds_motorista_apoio
			,bss_cd_base
			,tlm_cd_service_center


		-- demais lançamentos
		insert into #espelho
		select
			usr_cd_usuario as mtn_cd_motorista
			,tlm_cd_motorista as mtn_nome_motorista
			,@CodPeriodoPagamento as mtn_cd_pgto_periodo
			,228 mtn_cd_status
			,SUM(isnull(tlm_vl_valor_apoio,0)) as mtn_vl_nfs
			,null mtn_ds_link_nfs
			,dateadd(day,30,@data_final) as mtn_dt_prazo_contestacao
			,getdate() mtn_dh_criacao
			,7174 as mtn_cd_usr_criacao
			,getdate() mtn_dh_modificacao
			,7174 as mtn_cd_usr_modificacao
			,0 as mtn_in_excluido
			,@clienteid as mtn_cod_cliente
			,count(*) as mtn_qt_rotas
			,94  as mtn_cd_tipo_espelho
			,@IdCliTransportadora as mtn_cd_cliente_transportadora
			,bss_cd_base as mtn_cd_base
			--,case when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla else bss_ds_nome end as mtn_base_principal
			,tlm_cd_service_center mtn_base_principal
			,@operacao as mtn_cd_operacao
		from 
			vw_lancamentos_manuais_aprovados a
			left join (select distinct NomeMotorista from vw_rotas (NOLOCK) where IdTransportadora = @IdTransportadora and DataReferencia between @data_inicial and @data_final and UsuarioDA is not null) m on a.tlm_cd_motorista = m.NomeMotorista
			join (
						SELECT	
							usr_nm_usuario usr_nm_usuario,
							cli_cd_codigo_cliente,
							usr_cd_usuario,
							ROW_NUMBER() OVER(PARTITION BY usr_nm_usuario, cli_cd_codigo_cliente ORDER BY usr_cd_usuario DESC) AS ID
						FROM 
							tb_usuario (NOLOCK)
						WHERE 
							usr_in_ativo = 1
							and cli_cd_codigo_cliente = @clienteid
					   ) as usu
			on a.tlm_cd_motorista  = usr_nm_usuario
			and usu.ID = 1
			left join tb_bases as c (NOLOCK) on a.tlm_cd_service_center = c.bss_ds_sigla and c.bss_cd_idtransportadora = @IdTransportadora
		where 
			
			a.plm_in_calculo_desconto = 0
			and tlm_cd_cliente <> 37
			and a.Operacao = @TipoOperacao
			and cast(tlm_dh_referencia as date) between @data_inicial and @data_final
			and a.plm_nm_tipo <> 'Apoio'
			and a.tlm_cd_motorista <> 'null'
			and m.NomeMotorista is null
			and a.tlm_cd_cliente = @clienteid
			and not exists (select 1 from #espelho e where e.mtn_nome_motorista = a.tlm_cd_motorista)
			and not exists (select 1 from #espelho e where e.mtn_cd_motorista = usr_cd_usuario)
		group by
			usr_cd_usuario
			,tlm_cd_motorista
			,bss_cd_base
			,tlm_cd_service_center
	end
	--Fim Regra




	--Regra criada por Saulo Barros em 24/02/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
	if @clienteid in (11,1,56)
	begin
		update 
			b
		set
			mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)
		from 
			#tabela_insert as a
			inner join #espelho as b on ppr_cd_periodo = mtn_cd_pgto_periodo and ppr_nome_motorista = mtn_nome_motorista AND a.svc_espelho = b.mtn_base_principal
		where 
			ppr_cd_periodo = @CodPeriodoPagamento
			--and ppr_cd_motorista = 4298
			and ppr_cd_rota is NULL

		update 
			b
		set
			mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)
		from 
			(
				select 
					ppr_cd_periodo
					,ppr_cd_motorista
					,ppr_base_principal
					,sum(isnull(ppr_vl_total,0))  ppr_vl_total
				from 
					tb_pgto_periodo_rota as a (NOLOCK)
				where 
					ppr_cd_periodo = @CodPeriodoPagamento 
					and ppr_cd_rota is NULL
					AND ppr_in_excluido = 0
					and ppr_fl_desconto = 0
				group by 
					ppr_cd_periodo 
					,ppr_cd_motorista
					,ppr_base_principal
			) as a inner join #espelho as b on ppr_cd_periodo = mtn_cd_pgto_periodo
										and ppr_cd_motorista = mtn_cd_motorista
										and ppr_base_principal = mtn_base_principal
		where 
			ppr_cd_periodo = @CodPeriodoPagamento
	end
	--Fim regra
	else
	begin
		update 
			b
		set
			mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)
		from 
			#tabela_insert as a
			inner join #espelho as b on ppr_cd_periodo = mtn_cd_pgto_periodo and ppr_nome_motorista = mtn_nome_motorista
		where 
			ppr_cd_periodo = @CodPeriodoPagamento
			--and ppr_cd_motorista = 4298
			and ppr_cd_rota is NULL

			-- update b
			-- set
			-- 	mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)

			-- from tb_pgto_periodo_rota as a
			-- inner join #espelho as b
			-- on ppr_cd_periodo = mtn_cd_pgto_periodo
			-- and ppr_cd_motorista = mtn_cd_motorista
			-- where ppr_cd_periodo = @CodPeriodoPagamento
			-- --and ppr_cd_motorista = 4298
			-- and ppr_cd_rota is NULL

	
		update b
		set
			mtn_vl_nfs = isnull(ppr_vl_total,0)+isnull(mtn_vl_nfs,0)
		from (
			select 
				ppr_cd_periodo
				,ppr_cd_motorista
				,sum(isnull(ppr_vl_total,0))  ppr_vl_total
			from 
				tb_pgto_periodo_rota as a (NOLOCK)
			where 
				ppr_cd_periodo = @CodPeriodoPagamento 
				and ppr_cd_rota is NULL
				AND ppr_in_excluido = 0
				and ppr_fl_desconto = 0
			group by 
				ppr_cd_periodo 
				,ppr_cd_motorista
		) as a
		inner join #espelho as b
		on ppr_cd_periodo = mtn_cd_pgto_periodo
		and ppr_cd_motorista = mtn_cd_motorista
		where ppr_cd_periodo = @CodPeriodoPagamento
	end

	
	--Incluído por Saulo Barros em 15/07/2025 pois como o merge do espelho também olha o campo mtn_cd_motorista, quando existe alguma situação em que
	--já foi gerado um espelho com um código, e esse código de usuário foi inativado e gerado um novo, é criado um novo espelho ao inves de alterar
	--O script verifica no espelho que está sendo atualizado, se existe um espelho com código de usuário inativo e que existe um outro código desse mesmo usuário (verificando nome)
	--e atualiza
	--exemplo: select * from tb_usuario where usr_nm_usuario like '%Adailton Jose de Moura%'
	update
		e
	set
		e.mtn_cd_motorista = u2.usr_cd_usuario
	from
		tb_pag_espelhos e with(nolock)
		join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
		join tb_usuario u2 with(nolock) on e.mtn_nome_motorista = u2.usr_nm_usuario
										and e.mtn_cod_cliente = u2.cli_cd_codigo_cliente
										and u2.usr_in_ativo = 1
	where
		mtn_cd_pgto_periodo = @CodPeriodoPagamento
		and mtn_cd_operacao = @Operacao
		and u.usr_in_ativo = 0




--etapa para direcionar os erros 
	drop table if exists #tabela_duplicados
	select
	target.ppr_cd_rota,
	count(*) qtd 
	into #tabela_duplicados
	from [tb_pgto_periodo_rota] AS target
	join (
		
		 SELECT
        a.ppr_cd_periodo,
        a.ppr_cd_rota
   
    FROM #tabela_insert AS a
    INNER JOIN tb_pag_espelhos AS b (NOLOCK)
        ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
        AND a.ppr_nome_motorista = b.mtn_nome_motorista
		AND a.ppr_cd_motorista = b.mtn_cd_motorista
        AND (a.ppr_base_principal = b.mtn_base_principal or a.svc_espelho = b.mtn_base_principal)
		and  b.mtn_cd_status in (34,228,38,1298)
		and b.mtn_cd_operacao = @Operacao
		--and  ppr_qt_pacotes > 0 


	) AS source
	ON target.ppr_cd_periodo = source.ppr_cd_periodo
	AND target.ppr_cd_rota = source.ppr_cd_rota
	AND target.ppr_lcto_cd_lancamento IS NULL


	group by target.ppr_cd_rota
	having count(*) > 1





	insert into tb_pgto_periodo_rota_erros (
	
	ppr_cd_periodo
	,ppr_cd_rota
	,ppr_cd_faixa_km
	,ppr_ds_placa
	,ppr_ds_tipo_veiculo
	,ppr_ds_ciclo
	,ppr_qt_pacotes
	,ppr_qt_pontos
	,ppr_qt_paradas
	,ppr_in_area_risco
	,ppr_in_ajudante
	,ppr_in_dom_fer
	,ppr_vl_base
	,ppr_vl_paradas
	,ppr_vl_risco
	,ppr_vl_ajudante
	,ppr_vl_dom_fer
	,ppr_vl_lancamentos
	,ppr_vl_total_km_real
	,ppr_vl_total_km_minimo
	,ppr_vl_total_km_prefatura
	,ppr_vl_total
	,ppr_dh_criacao
	,ppr_cd_usr_criacao
	,ppr_dh_modificacao
	,ppr_cd_usr_modificacao
	,ppr_in_ativo
	,ppr_in_excluido
	,ppr_cd_motorista
	,ppr_vl_insucessos
	,ppr_vl_success_delivery
	,ppr_qt_pacotes_entregues
	,ppr_qt_pacotes_pendentes
	,ppr_bfm_vl_FaixaKM
	,ppr_bfm_vl_adicional_domingo
	,ppr_bfm_vl_adicional_ciclo_pm
	,ppr_bfm_vl_paradas0_60
	,ppr_bfm_vl_paradas61_75
	,ppr_bfm_vl_paradas76_85
	,ppr_bfm_vl_paradas86_90
	,ppr_bfm_vl_paradas_acima_90
	,ppr_bfm_vl_adicional_ajudante
	,ppr_bfm_vl_adicional_risco
	,ppr_bfm_vl_insucesso
	,ppr_lcto_dt_lancamento
	,ppr_lcto_ciclo
	,ppr_lcto_tipo
	,ppr_lcto_vl_risco_ajudante
	,ppr_lcto_qt_pacotes
	,ppr_lcto_qt_pontos
	,ppr_lcto_observacao
	,ppr_lcto_usr_criacao
	,ppr_lcto_dh_modificacao
	,ppr_lcto_usr_modificacao
	,ppr_lcto_vl_apoio
	,ppr_id_transportadora
	,ppr_usou_app
	,ppr_data_referencia
	,ppr_base_principal
	,ppr_tipo_rota
	,ppr_nome_motorista
	,ppr_vl_bonus
	,svc_espelho
	,bkt_vl_km_ideal
	,ppr_vl_trevo
	,ppr_vl_pm
	,ppr_vl_valor_frete
	,ppr_total_km
	,ppr_nm_cidade
	,ppr_vl_pedagio
	,ppr_lcto_cd_lancamento
	,ppr_vl_aluguel
	,ppr_vl_desconto
	,ppr_vl_recarga
	,ppr_per_endereco_nao_visitado
	,ppr_cd_tipo
	,ppr_nm_cluster
	,ppr_total_km_meli
	,ppr_total_km_rtt
	,FaixaKm2
	,ppr_vl_bonus_ds
	,ppr_vl_adicional_km
	)

	select 
		a.ppr_cd_periodo
	,a.ppr_cd_rota
	,a.ppr_cd_faixa_km
	,a.ppr_ds_placa
	,a.ppr_ds_tipo_veiculo
	,a.ppr_ds_ciclo
	,a.ppr_qt_pacotes
	,a.ppr_qt_pontos
	,a.ppr_qt_paradas
	,a.ppr_in_area_risco
	,a.ppr_in_ajudante
	,a.ppr_in_dom_fer
	,a.ppr_vl_base
	,a.ppr_vl_paradas
	,a.ppr_vl_risco
	,a.ppr_vl_ajudante
	,a.ppr_vl_dom_fer
	,a.ppr_vl_lancamentos
	,a.ppr_vl_total_km_real
	,a.ppr_vl_total_km_minimo
	,a.ppr_vl_total_km_prefatura
	,a.ppr_vl_total
	,getdate() ppr_dh_criacao
	,a.ppr_cd_usr_criacao
	,a.ppr_dh_modificacao
	,a.ppr_cd_usr_modificacao
	,a.ppr_in_ativo
	,a.ppr_in_excluido
	,a.ppr_cd_motorista
	,a.ppr_vl_insucessos
	,a.ppr_vl_success_delivery
	,a.ppr_qt_pacotes_entregues
	,a.ppr_qt_pacotes_pendentes
	,a.ppr_bfm_vl_FaixaKM
	,a.ppr_bfm_vl_adicional_domingo
	,a.ppr_bfm_vl_adicional_ciclo_pm
	,a.ppr_bfm_vl_paradas0_60
	,a.ppr_bfm_vl_paradas61_75
	,a.ppr_bfm_vl_paradas76_85
	,a.ppr_bfm_vl_paradas86_90
	,a.ppr_bfm_vl_paradas_acima_90
	,a.ppr_bfm_vl_adicional_ajudante
	,a.ppr_bfm_vl_adicional_risco
	,a.ppr_bfm_vl_insucesso
	,a.ppr_lcto_dt_lancamento
	,a.ppr_lcto_ciclo
	,a.ppr_lcto_tipo
	,a.ppr_lcto_vl_risco_ajudante
	,a.ppr_lcto_qt_pacotes
	,a.ppr_lcto_qt_pontos
	,a.ppr_lcto_observacao
	,a.ppr_lcto_usr_criacao
	,a.ppr_lcto_dh_modificacao
	,a.ppr_lcto_usr_modificacao
	,a.ppr_lcto_vl_apoio
	,a.ppr_id_transportadora
	,a.ppr_usou_app
	,a.ppr_data_referencia
	,a.ppr_base_principal
	,a.ppr_tipo_rota
	,a.ppr_nome_motorista
	,a.ppr_vl_bonus
	,a.svc_espelho
	,a.bkt_vl_km_ideal
	,a.ppr_vl_trevo
	,a.ppr_vl_pm
	,a.ppr_vl_valor_frete
	,a.ppr_total_km
	,a.ppr_nm_cidade
	,a.ppr_vl_pedagio
	,a.ppr_lcto_cd_lancamento
	,a.ppr_vl_aluguel
	,a.ppr_vl_desconto
	,a.ppr_vl_recarga
	,a.ppr_per_endereco_nao_visitado
	,a.ppr_cd_tipo
	,a.ppr_nm_cluster
	,a.ppr_total_km_meli
	,a.ppr_total_km_rtt
	,a.FaixaKm2
	,a.ppr_vl_bonus_ds
	,a.ppr_vl_adicional_km
	from #tabela_insert as a
	inner join #tabela_duplicados as b
	on a.ppr_cd_rota  = b.ppr_cd_rota



drop table if exists #para_deletar
    ALTER TABLE #tabela_insert ADD _uid_del BIGINT IDENTITY(1,1);
	
	-- Comentado por Gabriel dia 30/09/2025 pois a rotina abaixo ainda permitia que fosse inserido duplicado nos espelhos.

--SELECT d._uid_del
--INTO #para_deletar
--FROM (
--    SELECT 
--        a._uid_del,
--        ROW_NUMBER() OVER (
--            PARTITION BY a.ppr_cd_rota 
--            ORDER BY a._uid_del      -- ajuste este ORDER BY se quiser outro critério
--        ) AS ordem
--    FROM #tabela_insert AS a
--    INNER JOIN #tabela_duplicados AS b
--        ON a.ppr_cd_rota = b.ppr_cd_rota
--) AS d
--WHERE d.ordem > 1;

--DELETE a
--FROM #tabela_insert AS a
--JOIN #para_deletar AS x
--  ON x._uid_del = a._uid_del;

--Incluído por Gabriel dia 30/09/2025 para que remova os duplicados nas rotas

;WITH DELETAR AS (
    SELECT 
        a._uid_del,
        ROW_NUMBER() OVER (
            PARTITION BY a.ppr_cd_rota 
            ORDER BY 
                CASE WHEN a.ppr_vl_base > 0 THEN 0 ELSE 1 END,  -- mantém as com base primeiro
                a._uid_del
        ) AS ordem
    FROM #tabela_insert AS a
)
DELETE FROM DELETAR WHERE ordem > 1;

	MERGE tb_pag_espelhos AS target
	USING (
		SELECT
			 esp.mtn_cd_motorista
			,esp.mtn_cd_pgto_periodo
			,esp.mtn_cd_status
			,esp.mtn_vl_nfs
			,esp.mtn_ds_link_nfs
			,esp.mtn_dt_prazo_contestacao
			,esp.mtn_dh_criacao
			,esp.mtn_cd_usr_criacao
			,esp.mtn_dh_modificacao
			,esp.mtn_cd_usr_modificacao
			,esp.mtn_in_excluido
			,esp.mtn_cod_cliente
			,esp.mtn_qt_rotas
			,esp.mtn_cd_tipo_espelho
			,esp.mtn_cd_cliente_transportadora
			,esp.mtn_cd_base
			,esp.mtn_base_principal
			,esp.mtn_nome_motorista
			,CONVERT(DECIMAL(10,2),
				CASE
					WHEN MOT.mot_pag_cd_tipo_pagamento = 1
						THEN NULL
					WHEN MOT.mot_pag_cd_tipo_pagamento = 2
						THEN (ESP.mtn_vl_nfs * 0.06) * (0.135)
					ELSE NULL
				END)												AS mtn_vl_imposto
			,CONVERT(DECIMAL(10,2),ESP.mtn_vl_nfs -
				(CASE
					WHEN MOT.mot_pag_cd_tipo_pagamento = 1
						THEN NULL
					WHEN MOT.mot_pag_cd_tipo_pagamento = 2
						THEN (ESP.mtn_vl_nfs * 0.06) * (0.135)
					ELSE NULL
				END))												AS mtn_vl_liquido
			,esp.mtn_cd_operacao

			,MOT.Banco			as mtn_ds_Banco
			,MOT.NomeTitular		as mtn_ds_NomeTitular
			,MOT.CpfTitular		as mtn_ds_CpfTitular
			,MOT.CnpjTitular		as mtn_ds_CnpjTitular
			,MOT.Agencia			as mtn_ds_Agencia
			,MOT.Conta			as mtn_ds_Conta
			,MOT.TipoConta		as mtn_ds_TipoConta
			,MOT.TipoChavePix		as mtn_ds_TipoChavePix
			,MOT.ChavePix			as mtn_ds_ChavePix
			,MOT.CnpjEmpresa		as mtn_ds_CnpjEmpresa
			,MOT.RazaoSocial		as mtn_ds_RazaoSocial
			,MOT.NomeFantasia		as mtn_ds_NomeFantasia

			,@DataPrevistaPagamento mtn_dt_prevista_pagamento

		FROM #espelho AS ESP
		left JOIN (
						SELECT	*,
								ROW_NUMBER() OVER(PARTITION BY CodigoUsuario ORDER BY CodigoUsuario ASC)	AS ID
						FROM vw_dados_motoristas (NOLOCK)
					) AS MOT ON MOT.CodigoUsuario = ESP.mtn_cd_motorista
								AND MOT.ID = 1

		--inner join tb_pag_espelhos as c
		--on esp.mtn_nome_motorista =		c.mtn_nome_motorista
		--and esp.mtn_cd_pgto_periodo =	c.mtn_cd_pgto_periodo
		--and esp.mtn_base_principal =	c.mtn_base_principal
		--and esp.mtn_cd_operacao =		c.mtn_cd_operacao

		where esp.mtn_nome_motorista is not null and esp.mtn_cd_motorista is not null



	) AS source
	ON (
		target.mtn_nome_motorista = source.mtn_nome_motorista
		AND target.mtn_cd_motorista = source.mtn_cd_motorista
		AND target.mtn_cd_pgto_periodo = source.mtn_cd_pgto_periodo
		AND target.mtn_in_excluido = 0
		AND target.mtn_cd_operacao = source.mtn_cd_operacao

		--Regra criada por Saulo Barros em 24/02/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
		and (
				(@clienteid in (11,1,56) and source.mtn_base_principal = target.mtn_base_principal)
				or
				@clienteid not in (11,1,56)
			)

		--and target.mtn_cd_motorista = source.mtn_cd_motorista

--		AND target.mtn_cd_base = source.mtn_cd_base
		)
	WHEN MATCHED AND target.mtn_cd_status in (34,228,38,1298) THEN
		UPDATE SET
			-- mtn_cd_status = source.mtn_cd_status
			--,
			mtn_vl_nfs = source.mtn_vl_nfs
			--,mtn_ds_link_nfs = source.mtn_ds_link_nfs
			,mtn_dt_prazo_contestacao = source.mtn_dt_prazo_contestacao
		--	,mtn_dh_criacao = source.mtn_dh_criacao
			,mtn_cd_usr_criacao = source.mtn_cd_usr_criacao
			,mtn_dh_modificacao = source.mtn_dh_modificacao
			,mtn_cd_usr_modificacao = source.mtn_cd_usr_modificacao
			,mtn_in_excluido = source.mtn_in_excluido
			,mtn_cod_cliente = source.mtn_cod_cliente
			,mtn_qt_rotas = source.mtn_qt_rotas
			,mtn_cd_tipo_espelho = source.mtn_cd_tipo_espelho
			,mtn_cd_cliente_transportadora = source.mtn_cd_cliente_transportadora
			,mtn_base_principal = source.mtn_base_principal
			,mtn_nome_motorista =  source.mtn_nome_motorista
			,mtn_cd_base = source.mtn_cd_base
			,mtn_cd_motorista = source.mtn_cd_motorista
			,mtn_vl_imposto = source.mtn_vl_imposto
			,mtn_vl_liquido = source.mtn_vl_liquido
			,mtn_ds_Banco			= source.mtn_ds_Banco
			,mtn_ds_NomeTitular		= source.mtn_ds_NomeTitular
			,mtn_ds_CpfTitular		= source.mtn_ds_CpfTitular
			,mtn_ds_CnpjTitular		= source.mtn_ds_CnpjTitular
			,mtn_ds_Agencia			= source.mtn_ds_Agencia
			,mtn_ds_Conta			= source.mtn_ds_Conta
			,mtn_ds_TipoConta		= source.mtn_ds_TipoConta
			,mtn_ds_TipoChavePix	= source.mtn_ds_TipoChavePix
			,mtn_ds_ChavePix		= source.mtn_ds_ChavePix
			,mtn_ds_CnpjEmpresa		= source.mtn_ds_CnpjEmpresa
			,mtn_ds_RazaoSocial		= source.mtn_ds_RazaoSocial
			,mtn_ds_NomeFantasia	= source.mtn_ds_NomeFantasia
			--ajuste para atualizar somente quando a data não for atualizada manualmente
			,mtn_dt_prevista_pagamento = case when target.mtn_in_prevista_manual = 0 then source.mtn_dt_prevista_pagamento else target.mtn_dt_prevista_pagamento end


	WHEN NOT MATCHED THEN
		INSERT (
			 mtn_cd_motorista
			,mtn_cd_pgto_periodo
			,mtn_cd_status
			,mtn_vl_nfs
			,mtn_ds_link_nfs
			,mtn_dt_prazo_contestacao
			,mtn_dh_criacao
			,mtn_cd_usr_criacao
			,mtn_dh_modificacao
			,mtn_cd_usr_modificacao
			,mtn_in_excluido
			,mtn_cod_cliente
			,mtn_qt_rotas
			,mtn_cd_tipo_espelho
			,mtn_cd_cliente_transportadora
			,mtn_base_principal
			,mtn_nome_motorista
			,mtn_cd_base
			,mtn_vl_imposto
			,mtn_vl_liquido
			,mtn_cd_operacao
			,mtn_ds_Banco
			,mtn_ds_NomeTitular
			,mtn_ds_CpfTitular
			,mtn_ds_CnpjTitular
			,mtn_ds_Agencia
			,mtn_ds_Conta
			,mtn_ds_TipoConta
			,mtn_ds_TipoChavePix
			,mtn_ds_ChavePix
			,mtn_ds_CnpjEmpresa
			,mtn_ds_RazaoSocial
			,mtn_ds_NomeFantasia
			,mtn_dt_prevista_pagamento
		)
		VALUES (
			 source.mtn_cd_motorista
			,source.mtn_cd_pgto_periodo
			,source.mtn_cd_status
			,source.mtn_vl_nfs
			,source.mtn_ds_link_nfs
			,source.mtn_dt_prazo_contestacao
			,source.mtn_dh_criacao
			,source.mtn_cd_usr_criacao
			,source.mtn_dh_modificacao
			,source.mtn_cd_usr_modificacao
			,source.mtn_in_excluido
			,source.mtn_cod_cliente
			,source.mtn_qt_rotas
			,source.mtn_cd_tipo_espelho
			,source.mtn_cd_cliente_transportadora
			,source.mtn_base_principal
			,source.mtn_nome_motorista
			,source.mtn_cd_base
			,source.mtn_vl_imposto
			,source.mtn_vl_liquido
			,source.mtn_cd_operacao
			,source.mtn_ds_Banco
			,source.mtn_ds_NomeTitular
			,source.mtn_ds_CpfTitular
			,source.mtn_ds_CnpjTitular
			,source.mtn_ds_Agencia
			,source.mtn_ds_Conta
			,source.mtn_ds_TipoConta
			,source.mtn_ds_TipoChavePix
			,source.mtn_ds_ChavePix
			,source.mtn_ds_CnpjEmpresa
			,source.mtn_ds_RazaoSocial
			,source.mtn_ds_NomeFantasia
			,source.mtn_dt_prevista_pagamento
		);



	MERGE INTO [tb_pgto_periodo_rota] AS target
	USING (
		
		 SELECT
        a.ppr_cd_periodo,
        a.ppr_cd_rota,
        a.ppr_cd_faixa_km,
        a.ppr_ds_placa,
        a.ppr_ds_tipo_veiculo,
        a.ppr_ds_ciclo,
        a.ppr_qt_pacotes,
        a.ppr_qt_pontos,
        a.ppr_qt_paradas,
        a.ppr_in_area_risco,
        a.ppr_in_ajudante,
        a.ppr_in_dom_fer,
        a.ppr_vl_base,
        a.ppr_vl_paradas,
        a.ppr_vl_risco,
        a.ppr_vl_ajudante,
        a.ppr_vl_dom_fer,
        a.ppr_vl_lancamentos,
        a.ppr_vl_total_km_real,
        a.ppr_vl_total_km_minimo,
        a.ppr_vl_total_km_prefatura,
        a.ppr_vl_total,
        a.ppr_cd_usr_criacao,
        a.ppr_dh_modificacao,
        a.ppr_cd_usr_modificacao,
        a.ppr_in_ativo,
        a.ppr_in_excluido,
        a.ppr_cd_motorista,
        a.ppr_vl_insucessos,
        a.ppr_vl_success_delivery,
        a.ppr_qt_pacotes_entregues,
        a.ppr_qt_pacotes_pendentes,
        b.mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
        a.ppr_usou_app,
        MIN(a.ppr_data_referencia) AS ppr_data_referencia, -- Seleciona a menor data
        a.ppr_base_principal,
        a.ppr_tipo_rota,
        a.ppr_nome_motorista,
        b.mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho,
        a.ppr_vl_bonus,
        ppr_lcto_observacao,
        a.ppr_vl_pm,
        ppr_vl_valor_frete,
        ppr_total_km,
        ppr_nm_cidade,
        ppr_vl_pedagio,
        a.ppr_lcto_cd_lancamento,
        a.ppr_vl_aluguel,
        a.ppr_vl_recarga,
        a.ppr_per_endereco_nao_visitado,
        a.ppr_cd_tipo,
        a.ppr_nm_cluster,
        a.ppr_total_km_meli,
        a.ppr_total_km_rtt,
		a.ppr_vl_bonus_ds,
		a.ppr_vl_adicional_km,
		a.ppr_in_ambulancia,
		a.ppr_cd_tipo_pgto,
		a.ppr_in_zerar_rota,
		a.ppr_nm_origem_km
    FROM #tabela_insert AS a
    INNER JOIN tb_pag_espelhos AS b (NOLOCK)
        ON a.ppr_cd_periodo = b.mtn_cd_pgto_periodo
        AND a.ppr_nome_motorista = b.mtn_nome_motorista
		AND a.ppr_cd_motorista = b.mtn_cd_motorista
        AND (a.ppr_base_principal = b.mtn_base_principal or a.svc_espelho = b.mtn_base_principal)
		and  b.mtn_cd_status in (34,228,38,1298)
		and b.mtn_cd_operacao = @Operacao
		and b.mtn_in_excluido = 0 --incluído por Saulo Barros em 20/02/2026
		--and  ppr_qt_pacotes > 0 

    GROUP BY
        a.ppr_cd_periodo,
        a.ppr_cd_rota,
        a.ppr_cd_faixa_km,
        a.ppr_ds_placa,
        a.ppr_ds_tipo_veiculo,
        a.ppr_ds_ciclo,
        a.ppr_qt_pacotes,
        a.ppr_qt_pontos,
        a.ppr_qt_paradas,
        a.ppr_in_area_risco,
        a.ppr_in_ajudante,
        a.ppr_in_dom_fer,
        a.ppr_vl_base,
        a.ppr_vl_paradas,
        a.ppr_vl_risco,
        a.ppr_vl_ajudante,
        a.ppr_vl_dom_fer,
        a.ppr_vl_lancamentos,
        a.ppr_vl_total_km_real,
        a.ppr_vl_total_km_minimo,
        a.ppr_vl_total_km_prefatura,
        a.ppr_vl_total,
        a.ppr_cd_usr_criacao,
        a.ppr_dh_modificacao,
        a.ppr_cd_usr_modificacao,
        a.ppr_in_ativo,
        a.ppr_in_excluido,
        a.ppr_cd_motorista,
        a.ppr_vl_insucessos,
        a.ppr_vl_success_delivery,
        a.ppr_qt_pacotes_entregues,
        a.ppr_qt_pacotes_pendentes,
        b.mtn_cd_motorista_nfs,
        a.ppr_usou_app,
        a.ppr_base_principal,
        a.ppr_tipo_rota,
        a.ppr_nome_motorista,
        a.ppr_vl_bonus,
        ppr_lcto_observacao,
        a.ppr_vl_pm,
        ppr_vl_valor_frete,
        ppr_total_km,
        ppr_nm_cidade,
        ppr_vl_pedagio,
        a.ppr_lcto_cd_lancamento,
        a.ppr_vl_aluguel,
        a.ppr_vl_recarga,
        a.ppr_per_endereco_nao_visitado,
        a.ppr_cd_tipo,
        a.ppr_nm_cluster,
        a.ppr_total_km_meli,
        a.ppr_total_km_rtt,
		a.ppr_vl_bonus_ds,
		a.ppr_vl_adicional_km,
		a.ppr_in_ambulancia,
		a.ppr_cd_tipo_pgto,
		a.ppr_in_zerar_rota,
		a.ppr_nm_origem_km
		--and a.ppr_base_principal = b.mtn_base_principal

		--WHERE (@idrota IS NULL OR a.ppr_cd_rota = @idrota)

	) AS source
	ON target.ppr_cd_periodo = source.ppr_cd_periodo
	AND target.ppr_cd_rota = source.ppr_cd_rota
	--AND target.ppr_in_excluido = 0
	AND target.ppr_lcto_cd_lancamento IS NULL
	AND LTRIM(RTRIM(ISNULL(target.ppr_lcto_observacao,''))) <> 'Lançamento - Aluguel'
	--and target.ppr_base_principal = source.ppr_base_principal
	--Inserindo o filtro para repara o bug de executar apenas um espelho
	AND (@avulso IS NULL OR target.ppr_cd_motorista_nfs = @avulso)
	AND (@idrota IS NULL OR target.ppr_cd_rota = @idrota)


	WHEN MATCHED THEN
		UPDATE SET
			target.ppr_cd_faixa_km = source.ppr_cd_faixa_km,
			target.ppr_ds_placa = source.ppr_ds_placa,
			target.ppr_ds_tipo_veiculo = source.ppr_ds_tipo_veiculo,
			target.ppr_ds_ciclo = source.ppr_ds_ciclo,
			target.ppr_qt_pacotes = source.ppr_qt_pacotes,
			target.ppr_qt_pontos = source.ppr_qt_pontos,
			target.ppr_qt_paradas = source.ppr_qt_paradas,
			target.ppr_in_area_risco = source.ppr_in_area_risco,
			target.ppr_in_ajudante = source.ppr_in_ajudante,
			target.ppr_in_dom_fer = source.ppr_in_dom_fer,
			target.ppr_vl_base = source.ppr_vl_base,
			target.ppr_vl_paradas = source.ppr_vl_paradas,
			target.ppr_vl_risco = source.ppr_vl_risco,
			target.ppr_vl_ajudante = source.ppr_vl_ajudante,
			target.ppr_vl_dom_fer = source.ppr_vl_dom_fer,
			target.ppr_vl_lancamentos = source.ppr_vl_lancamentos,
			target.ppr_vl_total_km_real = source.ppr_vl_total_km_real,
			target.ppr_vl_total_km_minimo = source.ppr_vl_total_km_minimo,
			target.ppr_vl_total_km_prefatura = source.ppr_vl_total_km_prefatura,
			target.ppr_vl_total = source.ppr_vl_total,
			target.ppr_cd_usr_criacao = source.ppr_cd_usr_criacao,
			target.ppr_dh_modificacao = getdate(),
			target.ppr_cd_usr_modificacao = source.ppr_cd_usr_modificacao,
			--target.ppr_in_ativo = source.ppr_in_ativo,
			--target.ppr_in_excluido = source.ppr_in_excluido,
			target.ppr_cd_motorista = source.ppr_cd_motorista,
			target.ppr_vl_insucessos = source.ppr_vl_insucessos,
			target.ppr_vl_success_delivery = source.ppr_vl_success_delivery,
			target.ppr_qt_pacotes_entregues = source.ppr_qt_pacotes_entregues,
			target.ppr_qt_pacotes_pendentes = source.ppr_qt_pacotes_pendentes,
			target.ppr_cd_motorista_nfs = source.ppr_cd_motorista_nfs,
			target.ppr_usou_app = source.ppr_usou_app,
			target.ppr_data_referencia = source.ppr_data_referencia,
			target.ppr_base_principal = source.ppr_base_principal,
			target.ppr_tipo_rota = source.ppr_tipo_rota,
			target.ppr_nome_motorista = source.ppr_nome_motorista,
			target.ppr_cd_pgto_espelho = source.ppr_cd_pgto_espelho,
			target.ppr_vl_bonus = source.ppr_vl_bonus,
			target.ppr_lcto_observacao = source.ppr_lcto_observacao,
            target.ppr_vl_pm = source.ppr_vl_pm,
            target.ppr_vl_valor_frete = source.ppr_vl_valor_frete,
            target.ppr_total_km = source.ppr_total_km,
            target.ppr_nm_cidade = source.ppr_nm_cidade,
            target.ppr_vl_pedagio = source.ppr_vl_pedagio,
			target.ppr_lcto_cd_lancamento = source.ppr_lcto_cd_lancamento,
			target.ppr_vl_aluguel = source.ppr_vl_aluguel,
			target.ppr_vl_recarga = source.ppr_vl_recarga,
			target.ppr_per_endereco_nao_visitado = source.ppr_per_endereco_nao_visitado,
            target.ppr_cd_tipo = source.ppr_cd_tipo,
			target.ppr_nm_cluster = source.ppr_nm_cluster,
			target.ppr_total_km_meli = source.ppr_total_km_meli,
			target.ppr_total_km_rtt = source.ppr_total_km_rtt,
			target.ppr_vl_bonus_ds = source.ppr_vl_bonus_ds,
			target.ppr_vl_adicional_km = source.ppr_vl_adicional_km,
			target.ppr_in_ambulancia = source.ppr_in_ambulancia,
			target.ppr_cd_tipo_pgto = source.ppr_cd_tipo_pgto,
			target.ppr_in_excluido = 0,
			target.ppr_in_zerar_rota = source.ppr_in_zerar_rota,
			target.ppr_nm_origem_km = source.ppr_nm_origem_km
			-- target.ppr_dh_modificacao = getdate()
			


	WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			ppr_cd_periodo,
			ppr_cd_rota,
			ppr_cd_faixa_km,
			ppr_ds_placa,
			ppr_ds_tipo_veiculo,
			ppr_ds_ciclo,
			ppr_qt_pacotes,
			ppr_qt_pontos,
			ppr_qt_paradas,
			ppr_in_area_risco,
			ppr_in_ajudante,
			ppr_in_dom_fer,
			ppr_vl_base,
			ppr_vl_paradas,
			ppr_vl_risco,
			ppr_vl_ajudante,
			ppr_vl_dom_fer,
			ppr_vl_lancamentos,
			ppr_vl_total_km_real,
			ppr_vl_total_km_minimo,
			ppr_vl_total_km_prefatura,
			ppr_vl_total,
			ppr_cd_usr_criacao,
			ppr_dh_modificacao,
			ppr_cd_usr_modificacao,
			ppr_in_ativo,
			ppr_in_excluido,
			ppr_cd_motorista,
			ppr_vl_insucessos,
			ppr_vl_success_delivery,
			ppr_qt_pacotes_entregues,
			ppr_qt_pacotes_pendentes,
			ppr_cd_motorista_nfs,
			ppr_usou_app,
			ppr_data_referencia,
			ppr_base_principal,
			ppr_tipo_rota,
			ppr_nome_motorista,
			ppr_cd_pgto_espelho,
			ppr_vl_bonus,
			ppr_lcto_observacao,
            ppr_vl_pm,
            ppr_vl_valor_frete,
            ppr_total_km,
            ppr_nm_cidade,
            ppr_vl_pedagio,
			ppr_lcto_cd_lancamento,
			ppr_vl_aluguel,
			ppr_vl_recarga,
			ppr_per_endereco_nao_visitado,
            ppr_cd_tipo,
			ppr_nm_cluster,
			ppr_total_km_meli,
			ppr_total_km_rtt,
			ppr_vl_bonus_ds,
			ppr_vl_adicional_km,
			ppr_in_ambulancia,
			ppr_cd_tipo_pgto,
			ppr_in_zerar_rota,
			ppr_nm_origem_km
		)
		VALUES (
			source.ppr_cd_periodo,
			source.ppr_cd_rota,
			source.ppr_cd_faixa_km,
			source.ppr_ds_placa,
			source.ppr_ds_tipo_veiculo,
			source.ppr_ds_ciclo,
			source.ppr_qt_pacotes,
			source.ppr_qt_pontos,
			source.ppr_qt_paradas,
			source.ppr_in_area_risco,
			source.ppr_in_ajudante,
			source.ppr_in_dom_fer,
			source.ppr_vl_base,
			source.ppr_vl_paradas,
			source.ppr_vl_risco,
			source.ppr_vl_ajudante,
			source.ppr_vl_dom_fer,
			source.ppr_vl_lancamentos,
			source.ppr_vl_total_km_real,
			source.ppr_vl_total_km_minimo,
			source.ppr_vl_total_km_prefatura,
			source.ppr_vl_total,
			source.ppr_cd_usr_criacao,
			source.ppr_dh_modificacao,
			source.ppr_cd_usr_modificacao,
			source.ppr_in_ativo,
			source.ppr_in_excluido,
			source.ppr_cd_motorista,
			source.ppr_vl_insucessos,
			source.ppr_vl_success_delivery,
			source.ppr_qt_pacotes_entregues,
			source.ppr_qt_pacotes_pendentes,
			source.ppr_cd_motorista_nfs,
			source.ppr_usou_app,
			source.ppr_data_referencia,
			source.ppr_base_principal,
			source.ppr_tipo_rota,
			source.ppr_nome_motorista,
			source.ppr_cd_pgto_espelho,
			source.ppr_vl_bonus,
			source.ppr_lcto_observacao,
            source.ppr_vl_pm,
            source.ppr_vl_valor_frete,
            source.ppr_total_km,
            source.ppr_nm_cidade,
            source.ppr_vl_pedagio,
			source.ppr_lcto_cd_lancamento,
			source.ppr_vl_aluguel,
			source.ppr_vl_recarga,
			source.ppr_per_endereco_nao_visitado,
            source.ppr_cd_tipo,
			source.ppr_nm_cluster,
			source.ppr_total_km_meli,
			source.ppr_total_km_rtt,
			source.ppr_vl_bonus_ds,
			source.ppr_vl_adicional_km,
			source.ppr_in_ambulancia,
			source.ppr_cd_tipo_pgto,
			source.ppr_in_zerar_rota,
			source.ppr_nm_origem_km
		);
--WHEN NOT MATCHED BY SOURCE THEN
--    UPDATE SET
--        ppr_in_excluido = 1,
--        ppr_dh_modificacao = GETDATE();

--insere os lancamentos manuis sem rota
drop table if exists #lancamento_sem_rota

drop table if exists #lancamento_sem_rota
SELECT	
		esp.ppr_cd_periodo
		,case when cast(tlm_cd_rota as varchar(50)) = 'null' OR a.plm_nm_tipo = 'Apoio'  then null else cast(tlm_cd_rota as varchar(50)) end  as ppr_cd_rota
		,case when a.plm_nm_tipo = 'Apoio' then tlm_ds_motorista_apoio else tlm_cd_motorista end ppr_nome_motorista
		,usr_cd_usuario
		,cast(tlm_dh_referencia as date) ppr_data_referencia
		,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
		    + case when a.plm_nm_tipo = 'Apoio' then tlm_vl_valor_apoio else (-1 * isnull(tlm_vl_valor_descontos,0)) end
		AS ppr_vl_lancamentos
        
        ,isnull(tlm_vl_valor_adicional,0) + isnull(tlm_vl_valor_rota,0) 
		    + case when a.plm_nm_tipo = 'Apoio' then tlm_vl_valor_apoio else (-1 * isnull(tlm_vl_valor_descontos,0)) end ppr_vl_total

		,case when isnull(tlm_ds_observacao,'') = '' then a.plm_nm_tipo else tlm_ds_observacao end as ppr_lcto_observacao
		--,1 ppr_lcto_observacao
		,esp.ppr_cd_pgto_espelho
		,getdate() ppr_dh_criacao
		,esp.ppr_cd_usr_criacao
		,esp.ppr_dh_modificacao
		,esp.ppr_cd_usr_modificacao
		,esp.ppr_in_ativo
		,esp.ppr_in_excluido
		,esp.ppr_cd_motorista
		,esp.ppr_cd_motorista_nfs
		,tlm_cd_lancamento_manual as ppr_lcto_cd_lancamento
		,tlm_cd_service_center
		into #lancamento_sem_rota

FROM (
		select
			a.*
		from 
			vw_lancamentos_manuais_aprovados a
		where
			plm_in_calculo_desconto = 0
			and tlm_cd_cliente <> 37
			and tlm_cd_rota is null
			and Operacao = @TipoOperacao
			and cast(tlm_dh_referencia as date) between @data_inicial and @data_final
	  ) as a


inner join tb_usuario as usu (NOLOCK)
--Alterado por Saulo Barros em 16/07/2025 para fazer o join com motorista apoio se o tipo for Apoio
on case
	when a.plm_nm_tipo = 'Apoio' then tlm_ds_motorista_apoio else a.tlm_cd_motorista end = usu.usr_nm_usuario
--on case 
--	when tlm_cd_rota = 'null' then a.tlm_cd_motorista
--	else tlm_ds_motorista_apoio end  = usu.usr_nm_usuario
and usu.usr_in_ativo = 1
and cli_cd_codigo_cliente = tlm_cd_cliente

left join  (

	select distinct 
	 mtn_cd_pgto_periodo as ppr_cd_periodo
	,mtn_cd_motorista as ppr_cd_motorista
	,mtn_cd_motorista_nfs as ppr_cd_pgto_espelho
	,mtn_nome_motorista as ppr_nome_motorista
	,case when @clienteid = 11 then mtn_base_principal else null end as mtn_base_principal
	,getdate() as ppr_dh_criacao
	,8851 as ppr_cd_usr_criacao
	,getdate() as ppr_dh_modificacao
	,8851 ppr_cd_usr_modificacao
	,1 ppr_in_ativo
	,0 ppr_in_excluido
	,mtn_cd_motorista_nfs  as ppr_cd_motorista_nfs

	from tb_pag_espelhos (NOLOCK)
	where mtn_cd_pgto_periodo = @CodPeriodoPagamento 
	and mtn_cd_operacao = @Operacao

) as esp
on usu.usr_cd_usuario = esp.ppr_cd_motorista 

--Regra criada por Saulo Barros em 24/02/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
and ((@clienteid in (11,1,56) and esp.mtn_base_principal = a.tlm_cd_service_center) or @clienteid not in (11,1,56))

--comentado em 21/05/2025 por Saulo Barros pois estava duplicando lançamentos da 50+ e não foi identificado o motivo de realizar este left join		
--left join (
--				select distinct ppr_cd_periodo ,pgp_dt_inicio,pgp_dt_fim,ppr_nome_motorista, ppr_cd_pgto_espelho
--				from tb_pgto_periodo_rota as a (NOLOCK)
--				inner join tb_pgto_periodo as b (NOLOCK)
--				on a.ppr_cd_periodo = b.pgp_cd_periodo
--				--where ppr_nome_motorista  = 'Joao Moreira de Paula Neto'
--				and ppr_cd_periodo = @CodPeriodoPagamento
--			) as periodo
--on periodo.ppr_nome_motorista = case 
--									when tlm_cd_rota = 'null' then a.tlm_cd_motorista
--									else tlm_ds_motorista_apoio end 
--FIM COMENTÁRIO
									
where esp.ppr_cd_periodo = @CodPeriodoPagamento
	

/*
insert into [tb_pgto_periodo_rota] 
(
 ppr_cd_rota, ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho
, ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido
,ppr_cd_motorista,ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento, ppr_base_principal
)

select 
 a.ppr_cd_rota, a.ppr_nome_motorista, a.ppr_data_referencia, a.ppr_lcto_observacao, a.ppr_vl_lancamentos, a.ppr_vl_total, a.ppr_cd_periodo, a.ppr_cd_pgto_espelho
,a.ppr_dh_criacao, a.ppr_cd_usr_criacao, a.ppr_dh_modificacao, a.ppr_cd_usr_modificacao, a.ppr_in_ativo, a.ppr_in_excluido
,a.ppr_cd_motorista,a.ppr_cd_motorista_nfs, a.ppr_lcto_cd_lancamento, tlm_cd_service_center

from #lancamento_sem_rota as a
left  join [tb_pgto_periodo_rota] as b (NOLOCK)
on a.ppr_lcto_cd_lancamento = b.ppr_lcto_cd_lancamento
and a.ppr_cd_periodo = b.ppr_cd_periodo
and a.ppr_cd_motorista = b.ppr_cd_motorista
where b.ppr_cd_periodo is null ;
*/


/*
	DESATIVAR REGRA DE ADICIONAL ASSIDUIDADE - 21/07/2026
----------- insert de adicional ac2 assiduidade quinzenal de sdd
if @TipoOperacao = 'LM'
begin
	INSERT INTO [tb_pgto_periodo_rota] 
	(
	  ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos,ppr_vl_base, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho,
	  ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido,
	  ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento,ppr_base_principal,ppr_tipo_rota
	)
	SELECT DISTINCT
		NomeMotorista,
		NULL AS DataReferencia,
	--Regra Alterada por Gabriel em 2025-09-12 para considerar diferença no Vuc SDD conforme solicitação https://app.clickup.com/t/86abqh8bu
		----'Adicional Assiduidade SDD' AS ppr_lcto_observacao,
		----NULL AS ppr_vl_lancamentos,
		----600 AS ppr_vl_base,
		----600 AS ppr_vl_total,
		  CASE 
			WHEN r.tipoveiculo ='Vuc SDD'
				 THEN 'Adicional Assiduidade VUC SDD'
			ELSE 'Adicional Assiduidade SDD'
		END AS ppr_lcto_observacao,
		NULL AS ppr_vl_lancamentos,
		CASE 
			WHEN r.tipoveiculo ='Vuc SDD' THEN 400 
			ELSE 600 
		END AS ppr_vl_base,
		CASE 
			WHEN r.tipoveiculo ='Vuc SDD' THEN 400 
			ELSE 600 
		END AS ppr_vl_total,
		@CodPeriodoPagamento AS ppr_cd_periodo,
		mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho,
		GETDATE() AS ppr_dh_criacao,
		31397 AS ppr_cd_usr_criacao,
		GETDATE() AS ppr_dh_modificacao,
		31397 AS ppr_cd_usr_modificacao,
		1 AS ppr_in_ativo,
		0 AS ppr_in_excluido,
		Codigo_usuario_motorista AS ppr_cd_motorista,
		mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
		NULL AS ppr_lcto_cd_lancamento,
		r.Base,
		'Adicional'
	FROM vw_rotas r (NOLOCK)
	INNER JOIN dimdata d (NOLOCK) ON r.datareferencia = d.data
	INNER JOIN tb_dra_tipo_veiculo tv (NOLOCK) ON r.tipoveiculo = tv.tvl_nm_tipo_veiculo 
	left JOIN tb_fin_base_frete_adicional_motorista f (NOLOCK) ON tv.tvl_cd_tipo_veiculo = f.bfa_cd_tipo_veiculo 
		AND r.ServiceCenter = bfa_cd_service_center
		AND r.DataReferencia BETWEEN f.bfa_data_inicio_vigencia AND ISNULL(f.bfa_data_fim_vigencia,CONVERT(DATE,DATEADD(YEAR,1,GETDATE())))
	INNER JOIN tb_pag_espelhos pe (NOLOCK) ON pe.mtn_nome_motorista = r.nomemotorista   and mtn_cd_operacao = @Operacao

	--Regra criada por Saulo Barros em 24/02/2025 para considerar para 50+ a chave Periodo, Motorista e SVC
	and ((@clienteid in (11,1,56) and pe.mtn_base_principal = r.ServiceCenter) or @clienteid not in (11,1,56))


	WHERE r.idtransportadora = 1950609251
	  AND r.datareferencia BETWEEN @data_inicial AND @data_final
	  AND r.tipoveiculo LIKE '%sdd%'
	--Comentado por Gabriel em 2025-09-12 
	 -- AND bfa_vl_sdd IS NOT NULL
	  AND mtn_cd_pgto_periodo = @CodPeriodoPagamento
 
		--adicionado por Saulo Barros em 17/03/2026 para evitar bug em duplicar espelho porque essa informação está nula
		and Codigo_usuario_motorista is not null

	GROUP BY 
		idtransportadora,
		NomeMotorista,
		r.tipoveiculo,

		--Comentado por Saulo Barros em 11/07 alinhado com Lucas e Isadora pois não preciso verificar a quinzena, e sim o periodo completo do fechamento
		--CONCAT(d.mes, quinzena),
		tvl_cd_tipo_veiculo,
		r.ServiceCenter,
		bfa_vl_sdd,
		mtn_cd_motorista_nfs,
		Codigo_usuario_motorista,
		r.Base
	HAVING COUNT(distinct dataReferencia) >= 13
	AND NOT EXISTS (
		SELECT 1
		FROM [tb_pgto_periodo_rota] p (NOLOCK)
		WHERE p.ppr_cd_periodo = @CodPeriodoPagamento
		  AND p.ppr_cd_motorista = Codigo_usuario_motorista
		  AND p.ppr_lcto_observacao LIKE 'Adicional Assiduidade%'
	)

	ORDER BY 2;



	--Adicionado por Saulo Barros em 04/09: task https://app.clickup.com/t/86aajrcy1
	-- insert de adicional ac2 assiduidade quinzenal SBA1
	if @clienteid = 45
	begin
		INSERT INTO [tb_pgto_periodo_rota] 
		(
		  ppr_nome_motorista, ppr_data_referencia, ppr_lcto_observacao, ppr_vl_lancamentos,ppr_vl_base, ppr_vl_total, ppr_cd_periodo, ppr_cd_pgto_espelho,
		  ppr_dh_criacao, ppr_cd_usr_criacao, ppr_dh_modificacao, ppr_cd_usr_modificacao, ppr_in_ativo, ppr_in_excluido,
		  ppr_cd_motorista, ppr_cd_motorista_nfs, ppr_lcto_cd_lancamento,ppr_base_principal,ppr_tipo_rota
		)
		select
			pag.mtn_nome_motorista,
			NULL AS DataReferencia,
			'Adicional Assiduidade' AS ppr_lcto_observacao,
			NULL AS ppr_vl_lancamentos,
			100 AS ppr_vl_base,
			100 AS ppr_vl_total,
			@CodPeriodoPagamento AS ppr_cd_periodo,
			mtn_cd_motorista_nfs AS ppr_cd_pgto_espelho,
			GETDATE() AS ppr_dh_criacao,
			31397 AS ppr_cd_usr_criacao,
			GETDATE() AS ppr_dh_modificacao,
			31397 AS ppr_cd_usr_modificacao,
			1 AS ppr_in_ativo,
			0 AS ppr_in_excluido,
			mtn_cd_motorista AS ppr_cd_motorista,
			mtn_cd_motorista_nfs AS ppr_cd_motorista_nfs,
			NULL AS ppr_lcto_cd_lancamento,
			pag.mtn_base_principal,
			'Adicional'
		from
			tb_pag_espelhos pag
			join (
					select
						UsuarioDA
						,ServiceCenter
					from
						vw_rotas
					where
						ServiceCenter = 'SBA1'
						and TipoVeiculo in ('Veículo de Passeio', 'Utilitários', 'Van')
						and idtransportadora = 1950609251
						and DataReferencia between @data_inicial and @data_final
						and UsuarioDA is not null
					group by
						UsuarioDA
						,ServiceCenter
					having
						count(distinct DataReferencia) >= 13
				) bon on pag.mtn_cd_motorista = bon.UsuarioDA and pag.mtn_base_principal = bon.ServiceCenter
		where
			pag.mtn_cd_pgto_periodo = @CodPeriodoPagamento
			and pag.mtn_in_excluido = 0
			and not exists (
							SELECT 
								1
							FROM 
								[tb_pgto_periodo_rota] p (NOLOCK)
							WHERE 
								p.ppr_cd_periodo = @CodPeriodoPagamento
								AND p.ppr_cd_motorista = mtn_cd_motorista
								AND p.ppr_lcto_observacao = 'Adicional Assiduidade'
						)
			and mtn_cd_status in (34,228,38,1298)
			and mtn_cd_operacao = @Operacao
	end
end --fim do if que verifica se é LM
*/

--gera descontos
exec UspFinGeraDescontoPagamento @CodPeriodoPagamento; 
exec UspFinGeraDescontoNotVisited @CodPeriodoPagamento; 


/****************************************** Aluguel ******************************************/

DELETE FROM tb_pgto_periodo_rota
WHERE LTRIM(RTRIM(ISNULL(ppr_lcto_observacao,''))) = 'Lançamento - Aluguel'
	AND ppr_cd_periodo = @CodPeriodoPagamento;

WITH Pagamento AS 
(
	SELECT	ppr_cd_periodo,
			NULL AS ppr_cd_rota,
			NULL AS ppr_cd_faixa_km,
			ppr_ds_placa,
			VEI.vei_ds_tipo AS ppr_ds_tipo_veiculo,
			NULL AS ppr_ds_ciclo,
			NULL AS ppr_qt_pacotes,
			NULL AS ppr_qt_pontos,
			NULL AS ppr_qt_paradas,
			NULL AS ppr_in_area_risco,
			NULL AS ppr_in_ajudante,
			NULL AS ppr_in_dom_fer,
			NULL AS ppr_vl_base,
			NULL AS ppr_vl_paradas,
			NULL AS ppr_vl_risco,
			NULL AS ppr_vl_ajudante,
			NULL AS ppr_vl_dom_fer,
			NULL AS ppr_vl_lancamentos,
			NULL AS ppr_vl_total_km_real,
			NULL AS ppr_vl_total_km_minimo,
			NULL AS ppr_vl_total_km_prefatura,
			NULL AS ppr_vl_total,
			8851 AS ppr_cd_usr_criacao,
			GETDATE() AS ppr_dh_modificacao,
			8851 AS ppr_cd_usr_modificacao,
			1 AS ppr_in_ativo,
			0 AS ppr_in_excluido,
			ppr_cd_motorista,
			NULL AS ppr_vl_insucessos,
			NULL AS ppr_vl_success_delivery,
			NULL AS ppr_qt_pacotes_entregues,
			NULL AS ppr_qt_pacotes_pendentes,
			NULL AS ppr_bfm_vl_FaixaKM,
			NULL AS ppr_bfm_vl_adicional_domingo,
			NULL AS ppr_bfm_vl_adicional_ciclo_pm,
			NULL AS ppr_bfm_vl_paradas0_60,
			NULL AS ppr_bfm_vl_paradas61_75,
			NULL AS ppr_bfm_vl_paradas76_85,
			NULL AS ppr_bfm_vl_paradas86_90,
			NULL AS ppr_bfm_vl_paradas_acima_90,
			NULL AS ppr_bfm_vl_adicional_ajudante,
			NULL AS ppr_bfm_vl_adicional_risco,
			NULL AS ppr_bfm_vl_insucesso,
			NULL AS ppr_lcto_dt_lancamento,
			NULL AS ppr_lcto_ciclo,
			NULL AS ppr_lcto_tipo,
			NULL AS ppr_lcto_vl_risco_ajudante,
			NULL AS ppr_lcto_qt_pacotes,
			NULL AS ppr_lcto_qt_pontos,
			'Lançamento - Aluguel' AS ppr_lcto_observacao,
			NULL AS ppr_lcto_usr_criacao,
			NULL AS ppr_lcto_dh_modificacao,
			NULL AS ppr_lcto_usr_modificacao,
			NULL AS ppr_lcto_vl_apoio,
			NULL AS ppr_id_transportadora,
			ppr_cd_motorista_nfs,
			NULL AS ppr_usou_app,
			NULL AS ppr_data_referencia,
			NULL AS ppr_base_principal,
			NULL AS ppr_tipo_rota,
			ppr_nome_motorista,
			ppr_cd_pgto_espelho,
			NULL AS ppr_vl_bonus,
			NULL AS ppr_vl_pm,
			NULL AS ppr_vl_valor_frete,
			NULL AS ppr_total_km,
			NULL AS ppr_nm_cidade,
			NULL AS ppr_vl_pedagio,
			NULL AS ppr_lcto_cd_lancamento,
			NULL AS ppr_vl_aluguel,
			NULL AS ppr_vl_recarga,
			COUNT(DISTINCT ppr_cd_rota) AS qtd_rotas
	FROM tb_pgto_periodo_rota AS PPR (NOLOCK)
	LEFT JOIN tb_veiculos	  AS VEI (NOLOCK) ON VEI.vei_ds_placa = PPR.ppr_ds_placa
	WHERE ppr_in_excluido = 0
		AND ppr_cd_periodo = @CodPeriodoPagamento
		AND ppr_cd_rota IS NOT NULL
	GROUP BY ppr_cd_periodo,
			 ppr_ds_placa,
			 VEI.vei_ds_tipo,
			 ppr_cd_motorista,
			 ppr_cd_motorista_nfs,
			 ppr_nome_motorista,
			 ppr_cd_pgto_espelho
),

Aluguel AS 
(
	SELECT	tm.mot_cd_usuario AS mot_cd_motorista,
			tm.mot_nm_motorista,
			tm.mot_ds_plate as his_ds_placa ,
			tm.mot_ds_vehicle_rental_value as his_ds_valor,
			CASE
				WHEN ISNUMERIC(REPLACE(REPLACE(c.his_ds_valor,'R$',''),',','.')) = 1
					THEN CONVERT(DECIMAL(10,2),REPLACE(REPLACE(c.his_ds_valor,'R$',''),',','.'))
				ELSE CONVERT(DECIMAL(10,2),0)
			END as vva_vl_aluguel,
			--vei_cd_valor_aluguel as vva_vl_aluguel,
			b.vei_ds_modelo_cobranca,
			tm.mot_dt_vehicle_rental_initial as his_ds_data_inicio
	FROM tb_motorista tm (NOLOCK)

	inner join tb_veiculos as b (NOLOCK)
	on tm.mot_ds_plate = b.vei_ds_placa

	inner join (
					SELECT	*,
							ROW_NUMBER() OVER(PARTITION BY his_ds_placa, his_cd_cliente ORDER BY his_dh_criacao DESC)	AS ID
					FROM tb_historico_alugueis (NOLOCK)
					WHERE his_ds_valor is not null
						AND his_fl_status_aluguel = 'Ativo'
				) as c 
	on c.his_ds_placa = b.vei_ds_placa
		and c.his_cd_cliente = b.vei_cd_cliente
		and c.ID = 1
)

INSERT INTO tb_pgto_periodo_rota(
	ppr_cd_periodo,
	ppr_cd_rota,
	ppr_cd_faixa_km,
	ppr_ds_placa,
	ppr_ds_tipo_veiculo,
	ppr_ds_ciclo,
	ppr_qt_pacotes,
	ppr_qt_pontos,
	ppr_qt_paradas,
	ppr_in_area_risco,
	ppr_in_ajudante,
	ppr_in_dom_fer,
	ppr_vl_base,
	ppr_vl_paradas,
	ppr_vl_risco,
	ppr_vl_ajudante,
	ppr_vl_dom_fer,
	ppr_vl_lancamentos,
	ppr_vl_total_km_real,
	ppr_vl_total_km_minimo,
	ppr_vl_total_km_prefatura,
	ppr_vl_total,
	ppr_cd_usr_criacao,
	ppr_dh_modificacao,
	ppr_cd_usr_modificacao,
	ppr_in_ativo,
	ppr_in_excluido,
	ppr_cd_motorista,
	ppr_vl_insucessos,
	ppr_vl_success_delivery,
	ppr_qt_pacotes_entregues,
	ppr_qt_pacotes_pendentes,
	ppr_bfm_vl_FaixaKM,
	ppr_bfm_vl_adicional_domingo,
	ppr_bfm_vl_adicional_ciclo_pm,
	ppr_bfm_vl_paradas0_60,
	ppr_bfm_vl_paradas61_75,
	ppr_bfm_vl_paradas76_85,
	ppr_bfm_vl_paradas86_90,
	ppr_bfm_vl_paradas_acima_90,
	ppr_bfm_vl_adicional_ajudante,
	ppr_bfm_vl_adicional_risco,
	ppr_bfm_vl_insucesso,
	ppr_lcto_dt_lancamento,
	ppr_lcto_ciclo,
	ppr_lcto_tipo,
	ppr_lcto_vl_risco_ajudante,
	ppr_lcto_qt_pacotes,
	ppr_lcto_qt_pontos,
	ppr_lcto_observacao,
	ppr_lcto_usr_criacao,
	ppr_lcto_dh_modificacao,
	ppr_lcto_usr_modificacao,
	ppr_lcto_vl_apoio,
	ppr_id_transportadora,
	ppr_cd_motorista_nfs,
	ppr_usou_app,
	ppr_data_referencia,
	ppr_base_principal,
	ppr_tipo_rota,
	ppr_nome_motorista,
	ppr_cd_pgto_espelho,
	ppr_vl_bonus,
	ppr_vl_pm,
	ppr_vl_valor_frete,
	ppr_total_km,
	ppr_nm_cidade,
	ppr_vl_pedagio,
	ppr_lcto_cd_lancamento,
	ppr_vl_aluguel,
	ppr_vl_recarga
)

SELECT	PGT.ppr_cd_periodo,
		PGT.ppr_cd_rota,
		PGT.ppr_cd_faixa_km,
		PGT.ppr_ds_placa,
		PGT.ppr_ds_tipo_veiculo,
		PGT.ppr_ds_ciclo,
		PGT.ppr_qt_pacotes,
		PGT.ppr_qt_pontos,
		PGT.ppr_qt_paradas,
		PGT.ppr_in_area_risco,
		PGT.ppr_in_ajudante,
		PGT.ppr_in_dom_fer,
		PGT.ppr_vl_base,
		PGT.ppr_vl_paradas,
		PGT.ppr_vl_risco,
		PGT.ppr_vl_ajudante,
		PGT.ppr_vl_dom_fer,
		PGT.ppr_vl_lancamentos,
		PGT.ppr_vl_total_km_real,
		PGT.ppr_vl_total_km_minimo,
		PGT.ppr_vl_total_km_prefatura,
		CONVERT(DECIMAL(10,2),
			CASE
				WHEN ISNULL(LTRIM(RTRIM(ALG.vei_ds_modelo_cobranca)),'') = 'dias_com_rotas'
					THEN 
						CASE
							WHEN ALG.his_ds_data_inicio >= @data_inicial
								THEN (ALG.vva_vl_aluguel / 30) * PGT.qtd_rotas
							ELSE 0
						END
				WHEN ISNULL(LTRIM(RTRIM(ALG.vei_ds_modelo_cobranca)),'') = 'dias_corridos'
					THEN 
						CASE 
							WHEN ALG.his_ds_data_inicio BETWEEN @data_inicial AND @data_final
								THEN (ALG.vva_vl_aluguel / 30.0) * DATEDIFF(DAY,ALG.his_ds_data_inicio,DATEADD(DAY,1,@data_final))
							WHEN ALG.his_ds_data_inicio < @data_inicial
								THEN (ALG.vva_vl_aluguel / 30.0) * DATEDIFF(DAY,@data_inicial,DATEADD(DAY,1,@data_final))
							ELSE 0
						END
				ELSE 0
			END * -1) AS ppr_vl_total,
		PGT.ppr_cd_usr_criacao,
		PGT.ppr_dh_modificacao,
		PGT.ppr_cd_usr_modificacao,
		PGT.ppr_in_ativo,
		PGT.ppr_in_excluido,
		PGT.ppr_cd_motorista,
		PGT.ppr_vl_insucessos,
		PGT.ppr_vl_success_delivery,
		PGT.ppr_qt_pacotes_entregues,
		PGT.ppr_qt_pacotes_pendentes,
		PGT.ppr_bfm_vl_FaixaKM,
		PGT.ppr_bfm_vl_adicional_domingo,
		PGT.ppr_bfm_vl_adicional_ciclo_pm,
		PGT.ppr_bfm_vl_paradas0_60,
		PGT.ppr_bfm_vl_paradas61_75,
		PGT.ppr_bfm_vl_paradas76_85,
		PGT.ppr_bfm_vl_paradas86_90,
		PGT.ppr_bfm_vl_paradas_acima_90,
		PGT.ppr_bfm_vl_adicional_ajudante,
		PGT.ppr_bfm_vl_adicional_risco,
		PGT.ppr_bfm_vl_insucesso,
		PGT.ppr_lcto_dt_lancamento,
		PGT.ppr_lcto_ciclo,
		PGT.ppr_lcto_tipo,
		PGT.ppr_lcto_vl_risco_ajudante,
		PGT.ppr_lcto_qt_pacotes,
		PGT.ppr_lcto_qt_pontos,
		PGT.ppr_lcto_observacao,
		PGT.ppr_lcto_usr_criacao,
		PGT.ppr_lcto_dh_modificacao,
		PGT.ppr_lcto_usr_modificacao,
		PGT.ppr_lcto_vl_apoio,
		PGT.ppr_id_transportadora,
		PGT.ppr_cd_motorista_nfs,
		PGT.ppr_usou_app,
		PGT.ppr_data_referencia,
		PGT.ppr_base_principal,
		PGT.ppr_tipo_rota,
		PGT.ppr_nome_motorista,
		PGT.ppr_cd_pgto_espelho,
		PGT.ppr_vl_bonus,
		PGT.ppr_vl_pm,
		PGT.ppr_vl_valor_frete,
		PGT.ppr_total_km,
		PGT.ppr_nm_cidade,
		PGT.ppr_vl_pedagio,
		PGT.ppr_lcto_cd_lancamento,
		CONVERT(DECIMAL(10,2),
			CASE
				WHEN ISNULL(LTRIM(RTRIM(ALG.vei_ds_modelo_cobranca)),'') = 'dias_com_rotas'
					THEN 
						CASE
							WHEN ALG.his_ds_data_inicio >= @data_inicial
								THEN (ALG.vva_vl_aluguel / 30) * PGT.qtd_rotas
							ELSE 0
						END
				WHEN ISNULL(LTRIM(RTRIM(ALG.vei_ds_modelo_cobranca)),'') = 'dias_corridos'
					THEN 
						CASE 
							WHEN ALG.his_ds_data_inicio BETWEEN @data_inicial AND @data_final
								THEN (ALG.vva_vl_aluguel / 30.0) * DATEDIFF(DAY,ALG.his_ds_data_inicio,DATEADD(DAY,1,@data_final))
							WHEN ALG.his_ds_data_inicio < @data_inicial
								THEN (ALG.vva_vl_aluguel / 30.0) * DATEDIFF(DAY,@data_inicial,DATEADD(DAY,1,@data_final))
							ELSE 0
						END
				ELSE 0
			END * -1) AS ppr_vl_aluguel,
		PGT.ppr_vl_recarga
FROM Pagamento	   AS PGT
INNER JOIN Aluguel AS ALG ON ALG.his_ds_placa = PGT.ppr_ds_placa
					AND ALG.mot_cd_motorista  = PGT.ppr_cd_motorista


DELETE e
FROM tb_pag_espelhos AS e
WHERE NOT EXISTS (
    SELECT 1
    FROM tb_pgto_periodo_rota AS p
    WHERE p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
	AND ppr_cd_periodo = @CodPeriodoPagamento
)
AND mtn_cd_pgto_periodo = @CodPeriodoPagamento
AND mtn_cd_status = 228
and mtn_cod_cliente <> 11 --incluido por saulo barors em 16/12/2025
and mtn_cd_tipo_espelho <> 95  --incluído por saulo barros em 16/02/2026 para não apagar espelhos avulsos


EXEC UspFlexRota @CodPeriodoPagamento,@data_inicial,@data_final

-- exec [UspFinGeraPagamentoAreaRisco] @CodPeriodoPagamento, @idrota;


--Adicionado por Saulo Barros em 25/03/2026 para excluir rotas que entraram no período mas não estão mais na #vw_rotas
--Só executa se tiver executado todo o período
if @idrota is null and @avulso is null
begin
	update
		p
	set
		p.ppr_in_excluido = 1
	from
		tb_pgto_periodo_rota p
		join tb_pag_espelhos e on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
									and e.mtn_cd_cliente_transportadora = @IdCliTransportadora
									and e.mtn_cd_operacao = @Operacao
		left join #vw_rotas r on p.ppr_cd_rota = r.IdRota
	where
		p.ppr_cd_periodo = @CodPeriodoPagamento
		and p.ppr_in_excluido = 0
		and p.ppr_cd_tipo_pgto = 1362
		and e.mtn_cd_status in (34,228,38,1298)
		and r.IdRota is null
end


--end

GO
