-- ============================================================
-- BASELINE: dbo.UspFinAtualizaDescontosCampanhas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaDescontosCampanhas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[UspFinAtualizaDescontosCampanhas]  (
	@CodPeriodoPagamento int
	,@CodEspelho int = null
)
as
begin

--	declare @CodPeriodoPagamento int = 1552
	declare @StatusPeriodo int = (select pgp_cd_status from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
	declare @DataLimiteReanalise date = (select pgp_dt_limite_reanalise from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo = @CodPeriodoPagamento)

	set @CodEspelho = case when @CodEspelho = 0 then null else @CodEspelho end

	--Só faz alteração caso o período ainda esteja em aberto
	if @StatusPeriodo = 1
	begin

		declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @CodPeriodoPagamento)
		declare @DataInicial date = (select pgp_dt_inicio from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)
		declare @DataFinal date = (select pgp_dt_fim from [dbo].[tb_pgto_periodo] with(nolock) where pgp_cd_periodo  = @CodPeriodoPagamento)

		
		--Regras Campanhas 50+
		if @CodigoCliente = 11
		begin

			--zera o valor do bonus
			update 
				p
			set
				ppr_vl_bonus_campanha = 0
			from
				tb_pgto_periodo_rota p with(nolock)
				join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
			where 
				ppr_cd_periodo = @CodPeriodoPagamento
				and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
				and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


			--Regra Assiduidade PRE PEAK Season 2025
			--Descrição Regra: para os finais de semana e feriado, o motorista ganha um adicional de 12 reais por dia entre os dias 01/11/2025 a 21/12/2025. 
			--				   Caso rode tanto no sábado quanto no domingo do mesmo fim de semana recebe mais 16 reais
			--Critérios:
				-- 1- Bases Todas --'SBA6', 'SBA4', 'SBA2', 'SPE1', 'EBA26', 'EBA27', 'SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPE1'
				-- 2- Todos os veículos com excessão de Bulk
				-- 3- DS > 90%
			
			if @DataInicial >= '2025-11-01' and @DataFinal <= '2025-12-31'
			begin
				
				--Como o motorista pode rodar em mais de uma rota no mesmo dia, pego a menor rota por dia
				drop table if exists #base
				select
					min(ppr_cd_rota) ppr_cd_rota
					,ppr_data_referencia
					,ppr_nome_motorista
					into #base
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_cd_rota is not null
					and ppr_lcto_cd_lancamento is null 
					and isnull(ppr_in_ambulancia,0) = 0
					and ppr_vl_base is not null
					and exists (select 1 from vw_rotas r where r.IdTransportadora = 1726310024 and DataReferencia between @DataInicial and @DataFinal and r.IdRota = p.ppr_cd_rota)
					and ppr_data_referencia between '2025-11-01' and '2025-12-21'
					--and ppr_base_principal in ('SBA6', 'SBA4', 'SBA2', 'SPE1', 'EBA26', 'EBA27', 'SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPE1')
					and ppr_ds_tipo_veiculo not like '%Bulk%'
					and (ppr_in_dom_fer = 1 or datepart(weekday, ppr_data_referencia) in (1, 7))
					--and ppr_vl_success_delivery > 0.90
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
				group by
					ppr_data_referencia
					,ppr_nome_motorista
				-- 	select * from tb_clientes

				-- Recebe 12 reais
				update
					p
				set
					ppr_vl_bonus_campanha = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_bonus_campanha + 12.60 else ppr_vl_bonus_campanha + 12 end 
					,ppr_vl_total = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_total + 12.60 else ppr_vl_total + 12 end 
				from
					tb_pgto_periodo_rota p with(nolock)
					join #base b on p.ppr_cd_rota = b.ppr_cd_rota
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and ppr_vl_base is not null
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				
				-- Recebe mais 16 reais se rodar sábado e domingo do mesmo fds
				update
					p
				set
					ppr_vl_bonus_campanha = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_bonus_campanha + 16.80 else ppr_vl_bonus_campanha + 16 end 
					,ppr_vl_total = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_total + 16.80 else ppr_vl_total + 16 end 
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join (
							select
								d.ppr_cd_rota
							from
								(select * from #base where datepart(weekday, ppr_data_referencia) = 7) s --sábado
								join (select * from #base where datepart(weekday, ppr_data_referencia) = 1) d--domingo
																											on s.ppr_nome_motorista = d.ppr_nome_motorista
																											and dateadd(day,1,s.ppr_data_referencia) = d.ppr_data_referencia
						) b on p.ppr_cd_rota = b.ppr_cd_rota
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_vl_base is not null
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
				

			end


			--Regra PRE PEAK Season 2025
			--Descrição Regra: ganha 12 reais por rota no período de 26/10/2025 a 22/11/2025.
			--Critérios:
				-- 1- Bases 'SBA6', 'SBA4', 'SBA2', 'SPE1', 'EBA26', 'EBA27', 'SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPE1'
				-- 2- Todos os veículos com excessão de Bulk
				-- 3- DS > 97% em dia de semana e DS > 90% fim de semana
			
			if @DataInicial >= '2025-10-16' and @DataFinal <= '2025-11-30'
			begin
				
				update
					p
				set
					ppr_vl_bonus_campanha = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_bonus_campanha + 12.60 else ppr_vl_bonus_campanha + 12 end 
					,ppr_vl_total = case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_total + 12.60 else ppr_vl_total + 12 end 
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_cd_rota is not null
					and ppr_lcto_cd_lancamento is null  
					and isnull(ppr_in_ambulancia,0) = 0
					--and ppr_vl_base > 0
					and exists (select 1 from vw_rotas r where r.IdTransportadora = 1726310024 and DataReferencia between @DataInicial and @DataFinal and r.IdRota = p.ppr_cd_rota)
					and ppr_data_referencia between '2025-10-26' and '2025-11-22'
					and ppr_base_principal in ('SBA6', 'SBA4', 'SBA2', 'SPE1', 'EBA26', 'EBA27', 'SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPE1')
					and ppr_ds_tipo_veiculo not like '%Bulk%'
					and (
							((ppr_in_dom_fer = 1 or datepart(weekday, ppr_data_referencia) in (1, 7)) and ppr_vl_success_delivery >= 0.0)
							or
							(ppr_in_dom_fer = 0 and datepart(weekday, ppr_data_referencia) not in (1, 7) and ppr_vl_success_delivery > 0.97)
						)
					and ppr_vl_base is not null
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


			--Regra PEAK Season 2025
			--Descrição Regra: ganha 20 reais por rota no período de 23/11/2025 a 23/12/2025.
			--Critérios:
				-- 1- Bases Todas
				-- 2- Todos os veículos
				-- 3- DS > 97% em dia de semana e DS > 90% fim de semana

				--Mudança de regra para considerar 12 reais por motorista a partir da 01Q122025 para as bases SBA2, EBA26 e EBA27
			
			if @DataInicial >= '2025-11-16' and @DataFinal <= '2025-12-31'
			begin
				
				update
					p
				set
					ppr_vl_bonus_campanha = case when p.ppr_data_referencia >= '2025-12-01' and ppr_base_principal in ('SBA2', 'EBA26', 'EBA27') then ppr_vl_bonus_campanha + 12 else case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_bonus_campanha + 21 else ppr_vl_bonus_campanha + 20 end end
					,ppr_vl_total = case when p.ppr_data_referencia >= '2025-12-01' and ppr_base_principal in ('SBA2', 'EBA26', 'EBA27') then ppr_vl_total + 12 else case when p.ppr_base_principal in ('SCE1', 'ECE1', 'ECE3', 'SLA1', 'SPA1', 'SPI1') then ppr_vl_total + 21 else ppr_vl_total + 20 end end
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_cd_rota is not null
					and ppr_lcto_cd_lancamento is null  
					and isnull(ppr_in_ambulancia,0) = 0
					--and ppr_vl_base > 0
					and exists (select 1 from vw_rotas r where r.IdTransportadora = 1726310024 and DataReferencia between @DataInicial and @DataFinal and r.IdRota = p.ppr_cd_rota)
					and ppr_data_referencia between '2025-11-23' and '2025-12-23'
					and (
							((ppr_in_dom_fer = 1 or datepart(weekday, ppr_data_referencia) in (1, 7)) and ppr_vl_success_delivery >= 0)
							or
							(ppr_in_dom_fer = 0 and datepart(weekday, ppr_data_referencia) not in (1, 7) and ppr_vl_success_delivery > 0.97)
						)
					and ppr_vl_base is not null
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end



			--cria adicional de 20% no dia 04/04 e 10% no dia 05/04 em caso de ter a quantidade mínima de motoristas no dia por base
			--retirado a regra mínima em 22/04/2026 solicitado pela 50mais e não considerado ambulancia
			if @DataInicial >= '2026-04-01' and @DataFinal <= '2026-04-15'
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.2
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.2,0)
				from
					tb_pgto_periodo_rota p
					/*
					join (
							select
								ppr_base_principal
								,count(distinct ppr_nome_motorista) QtdeMotorista
							from
								tb_pgto_periodo_rota
							where
								ppr_cd_periodo = @CodPeriodoPagamento
								and ppr_in_excluido = 0
								and ppr_cd_tipo_pgto = 1362
								and ppr_ds_tipo_veiculo not like '%sdd%'
								and ppr_base_principal in ('SBA2', 'SPE1', 'SCE1', 'SAM1', 'SBA6', 'SPI1', 'SPA1')
								and ppr_data_referencia = '2026-04-04'
							group by
								ppr_base_principal
							having
								count(distinct ppr_nome_motorista) >= case
																		when ppr_base_principal = 'SBA2' then 10
																		when ppr_base_principal = 'SPE1' then 22
																		when ppr_base_principal = 'SCE1' then 16
																		when ppr_base_principal = 'SAM1' then 11
																		when ppr_base_principal = 'SBA6' then 18
																		when ppr_base_principal = 'SPI1' then 4
																		when ppr_base_principal = 'SPA1' then 4
																	end
					) p2 on p.ppr_base_principal = p2.ppr_base_principal
					*/
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_ds_tipo_veiculo not like '%sdd%'
					and p.ppr_base_principal in ('SBA2', 'SPE1', 'SCE1', 'SAM1', 'SBA6', 'SPI1', 'SPA1', 'SBA4', 'EBA26', 'EBA27')
					and p.ppr_data_referencia = '2026-04-04'
					and p.ppr_in_ambulancia = 0
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					/*
					join (
							select
								ppr_base_principal
								,count(distinct ppr_nome_motorista) QtdeMotorista
							from
								tb_pgto_periodo_rota
							where
								ppr_cd_periodo = @CodPeriodoPagamento
								and ppr_in_excluido = 0
								and ppr_cd_tipo_pgto = 1362
								and ppr_ds_tipo_veiculo not like '%sdd%'
								and ppr_base_principal in ('SBA2', 'SPE1', 'SCE1', 'SAM1', 'SBA6', 'SPI1', 'SPA1')
								and ppr_data_referencia = '2026-04-05'
							group by
								ppr_base_principal
							having
								count(distinct ppr_nome_motorista) >= case
																		when ppr_base_principal = 'SBA2' then 11
																		when ppr_base_principal = 'SPE1' then 16
																		when ppr_base_principal = 'SCE1' then 12
																		when ppr_base_principal = 'SAM1' then 0
																		when ppr_base_principal = 'SBA6' then 8
																		when ppr_base_principal = 'SPI1' then 4
																		when ppr_base_principal = 'SPA1' then 3
																	end
					) p2 on p.ppr_base_principal = p2.ppr_base_principal
					*/
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_ds_tipo_veiculo not like '%sdd%'
					and p.ppr_base_principal in ('SBA2', 'SPE1', 'SCE1', 'SAM1', 'SBA6', 'SPI1', 'SPA1', 'SBA4', 'EBA26', 'EBA27')
					and p.ppr_data_referencia = '2026-04-05'
					and p.ppr_in_ambulancia = 0
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end

			--cria adicional de 10% no dia 10/05 oara veículos spot
			if @DataInicial >= '2026-05-01' and @DataFinal <= '2026-05-15'
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_ds_tipo_veiculo not like '%sdd%'
					and p.ppr_data_referencia = '2026-05-10'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


			--cria adicional de 10% no dia 13/06 para SDD e veículos spot
			if @DataInicial >= '2026-06-01' and @DataFinal <= '2026-06-15' 
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-06-13'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end

			--cria adicional de 10% nos dia 22/23/24
			if @DataInicial >= '2026-06-16' and @DataFinal <= '2026-06-30' 
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia in ('2026-06-22', '2026-06-23')
					and p.ppr_base_principal in ('SBA2', 'SBA4', 'SBA6', 'SPE1', 'EBA26', 'EBA27', 'ERN4')
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-06-24'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-06-29'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-06-19'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


			--cria adicional de 10% no dia 05/07
			if @DataInicial >= '2026-07-01' and @DataFinal <= '2026-07-15' 
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.1
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.1,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-07-05'
					and p.ppr_in_ambulancia = 0
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


			--cria adicional de 30% no dia 09/08
			if @DataInicial >= '2026-08-01' and @DataFinal <= '2026-08-15' 
			begin
				
				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

				update
					p
				set
					p.ppr_vl_bonus_ds = ppr_vl_base * 0.3
					,p.ppr_vl_total = ppr_vl_total + isnull(ppr_vl_base * 0.3,0)
				from
					tb_pgto_periodo_rota p
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and p.ppr_in_excluido = 0
					and p.ppr_cd_tipo_pgto = 1362
					and p.ppr_data_referencia = '2026-08-09'
					and p.ppr_in_ambulancia = 0
					and p.ppr_ds_tipo_veiculo not like '%sdd%'
					and e.mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end

		end --fim if 50+
	


		--Regras Campanhas Decargo
		if @CodigoCliente = 68
		begin


				--zera o valor do bonus
				update 
					p
				set
					ppr_vl_bonus_ds = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_data_referencia between '2025-12-01' and '2025-12-21'
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				--Regra Assiduidade PRE PEAK Season 2025
				--Descrição Regra: Valor: R$ 10,00 a mais por rota aos finais de semana + R$ 15,00 se rodar os dois dias = R$ 35,00 total 
				--Critérios:
					-- 1- Bases TODOS
					-- 2- Spot e SDD
					-- 3- DS maior que 95%
				--OBS: Rotas de ambulância não ganham o bônus

				--if @DataInicial >= '2025-12-01' and @DataFinal <= '2025-12-21'
				--begin

				update	p
				set		ppr_vl_bonus_ds = ppr_vl_bonus_ds + 10
				from	tb_pgto_periodo_rota p with(nolock)
				join	tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where	ppr_cd_periodo = @CodPeriodoPagamento
						and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
						and ppr_ds_tipo_veiculo in ('Van SDD','VUC Dedicado com Ajudante','Utilitários','Motocicleta','Veículo de Passeio','Vuc SDD','Utilitários SDD','Vuc','Van')
						and datepart(weekday, ppr_data_referencia) in (1, 7) 
						and ppr_vl_success_delivery > 0.95
						and ppr_data_referencia between '2025-12-01' and '2025-12-21'
						and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				-- Recebe mais 16 reais se rodar sábado e domingo do mesmo fds
				drop table if exists #baseDEC
				select
					min(ppr_cd_rota) ppr_cd_rota
					,ppr_data_referencia
					,ppr_nome_motorista
					into #baseDEC
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_cd_rota is not null
					and ppr_lcto_cd_lancamento is null 
					and isnull(ppr_in_ambulancia,0) = 0
					and ppr_ds_tipo_veiculo in ('Van SDD','VUC Dedicado com Ajudante','Utilitários','Motocicleta','Veículo de Passeio','Vuc SDD','Utilitários SDD','Vuc','Van')
					and ppr_vl_success_delivery > 0.95
					and datepart(weekday, ppr_data_referencia) in (1, 7) 
					and ppr_data_referencia between '2025-12-01' and '2025-12-21'
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
				group by
					ppr_data_referencia
					,ppr_nome_motorista
				


				update
					p
				set
					ppr_vl_bonus_ds = ppr_vl_bonus_ds + 15

				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join (
							select
								d.ppr_cd_rota
							from
								(select * from #baseDEC where datepart(weekday, ppr_data_referencia) = 7) s --sábado
								join (select * from #baseDEC where datepart(weekday, ppr_data_referencia) = 1) d--domingo
																											on s.ppr_nome_motorista = d.ppr_nome_motorista
																											and dateadd(day,1,s.ppr_data_referencia) = d.ppr_data_referencia
						) b on p.ppr_cd_rota = b.ppr_cd_rota
				where
					p.ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and ppr_ds_tipo_veiculo in ('Van SDD','VUC Dedicado com Ajudante','Utilitários','Motocicleta','Veículo de Passeio','Vuc SDD','Utilitários SDD','Vuc','Van')
					and ppr_vl_success_delivery > 0.95
					and datepart(weekday, ppr_data_referencia) in (1, 7) 
					and ppr_data_referencia between '2025-12-01' and '2025-12-21'
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



				--Nova Campanha para a Decargo
				--Aplicar o adicional de 30% para as datas 05/04 e 10/05.
				--Configurar a regra como não acumulativa, garantindo que o percentual de 30% substitua integralmente qualquer adicional vigente anteriormente.
				--Abranger a aplicação para todas as bases e todos os tipos de veículos cadastrados.
				--Atualização Saulo 08/05: zerar apenas o adicional de domingo/feriado
				update 
					p
				set
				--	ppr_vl_paradas      = 0
				--,   ppr_vl_pontos       = 0
				--,   ppr_vl_risco        = 0
				--,   ppr_vl_adicional_km = 0
				--,   ppr_vl_ajudante     = 0
				   ppr_vl_dom          = 0
				,   ppr_vl_fer          = 0
				--,   ppr_vl_recarga      = 0
				--,   ppr_vl_bonus_ds     = 0
				--,   ppr_vl_pm           = 0
				,   ppr_vl_dom_fer      = 0
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				where 
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and ppr_data_referencia in ('2026-04-05','2026-05-10')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				update
					p
				set
					ppr_vl_dom_fer = ppr_vl_base * 0.3
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.3)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia in ('2026-04-05','2026-05-10')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
				--fim nova regra

				--Configurar a regra de acréscimo pontual para a data de 13/06.
				--Solicitado o adicional de 10% nas rotas realizadas no dia 13/06
				--Tipo de contrato: Todos
				--Veículos que terá o adicional: Todos
			
				--Unica restrição: Veiculos com placas de veiculos com valor fixo cadastrado
				--Veiculos SDD se tiver valor fixo cadastrado receberá normalmente

				if @DataInicial >= '2026-06-01' and @DataFinal <= '2026-06-15'
				begin
				

					update
						p
					set
						 ppr_vl_dom_fer = ppr_vl_base * 0.1
						,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)

					from
						tb_pgto_periodo_rota p with(nolock)
						join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
						join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
						join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
						left join tb_veiculos v with(nolock) on p.ppr_ds_placa = v.vei_ds_placa 
																and v.vei_cd_cliente = @CodigoCliente
																and v.vei_valor_fixo > 0

					where
						ppr_cd_periodo = @CodPeriodoPagamento
						and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
						and p.ppr_in_excluido = 0
						and e.mtn_in_excluido = 0
						and ppr_cd_rota is not null
						and ppr_cd_tipo_pgto = 1362
						and ppr_vl_base > 0
						and p.ppr_data_referencia = '2026-06-13'
						and (
								ppr_ds_tipo_veiculo like '%SDD'
								or
								ppr_ds_tipo_veiculo not like '%SDD' and v.vei_valor_fixo is null
							
								)
						and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				end


			--Configurar a regra de acréscimo pontual para a data de 29/06.
        --Solicitado o adicional de 10% nas rotas realizadas no dia 29/06
        --Tipo de contrato: Todos
        --Veículos que terá o adicional: Regra deve ser aplicada para as operações SDD e SPOT de LM 

        if @DataInicial >= '2026-06-16' and @DataFinal <= '2026-06-30'
        begin


          update
            p
          set
             ppr_vl_dom_fer = ppr_vl_base * 0.1
            ,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)

          from
            tb_pgto_periodo_rota p with(nolock)
            join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
            join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
            join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
            left join tb_veiculos v with(nolock) on p.ppr_ds_placa = v.vei_ds_placa 
                                and v.vei_cd_cliente = @CodigoCliente
                                and v.vei_valor_fixo > 0

          where
            ppr_cd_periodo = @CodPeriodoPagamento
            and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
            and p.ppr_in_excluido = 0
            and e.mtn_in_excluido = 0
            and ppr_cd_rota is not null
            and ppr_cd_tipo_pgto = 1362
            and ppr_vl_base > 0
            and p.ppr_data_referencia in ('2026-06-19','2026-06-29')
            and (
                ppr_ds_tipo_veiculo like '%SDD'
                or
                ppr_ds_tipo_veiculo not like '%SDD' and v.vei_valor_fixo is null

                )
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



        end

        if @DataInicial >= '2026-07-01' and @DataFinal <= '2026-07-15'
        begin


          update
            p
          set
             ppr_vl_dom_fer = ppr_vl_base * 0.1
            ,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)

          from
            tb_pgto_periodo_rota p with(nolock)
            join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
            join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
            join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
            left join tb_veiculos v with(nolock) on p.ppr_ds_placa = v.vei_ds_placa 
                                and v.vei_cd_cliente = @CodigoCliente
                                and v.vei_valor_fixo > 0

          where
            ppr_cd_periodo = @CodPeriodoPagamento
            and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
            and p.ppr_in_excluido = 0
            and e.mtn_in_excluido = 0
            and ppr_cd_rota is not null
            and ppr_cd_tipo_pgto = 1362
            and ppr_vl_base > 0
            and p.ppr_data_referencia = '2026-07-05'
            and (
                ppr_ds_tipo_veiculo like '%SDD'
                or
                ppr_ds_tipo_veiculo not like '%SDD' and v.vei_valor_fixo is null

                )
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


        end



			if @DataInicial >= '2026-08-01' and @DataFinal <= '2026-08-15'
			begin
 
				update
					p
				set
						ppr_vl_dom_fer = ppr_vl_dom_fer + (ppr_vl_base * 0.3)
					,	ppr_vl_total   = ppr_vl_total   + (ppr_vl_base * 0.3)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
					left join tb_veiculos v with(nolock) on p.ppr_ds_placa = v.vei_ds_placa 
										and v.vei_cd_cliente = @CodigoCliente
										and v.vei_valor_fixo > 0
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-08-09'
					and ppr_ds_tipo_veiculo in ('Vuc','Van','Utilitários','Veículo de Passeio','Motocicleta')
					and v.vei_valor_fixo is null
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
 
			end


			--end
		end --fim if Decargo


		--Adicionado Regra por Saulo Barros em 26/02/2026
		--Regras Campanhas Transmaná
		if @CodigoCliente = 37 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
		begin

			
			--Regra: Adicionar 10% sobre o valor da rota no dia 17/02
			--Critérios:
			--	Os motoristas aptos a receberem o adicional são todos os motorista que estão vinculados ao tipo de contrato agregado - COD: 81
			--	Deve ser adicionado 10% sob o valor da rota no dia 17/02
			--	Os valores devem refletir em todos os relatórios de pagamentos
			--  Os valores devem ser adicionados no campo "Bonus DS"
			if @DataInicial >= '2026-02-16' and @DataFinal <= '2026-02-28'
			begin
				update
					p
				set
					ppr_vl_bonus_ds = ppr_vl_base * 0.1 
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_data_referencia = '2026-02-17'
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
			end


			--Regra: Adicionar 10% sobre o valor das rotas nos dias 03/04/2026 e 04/04/2026 e 20% nas rotas do dia 05/04/2026
			--Critérios:
			--	Os motoristas aptos a receberem o adicional são todos os motorista que estão vinculados ao tipo de contrato agregado - COD: 81
			--	Deve ser adicionado 10% sob o valor da rota nos dias 03/04/2026 e 04/04/2026
			--	Deve ser adicionado 20% sob o valor da rota no dia 05/04/2026
			--	Os valores devem refletir em todos os relatórios de pagamentos
			--  Os valores devem ser adicionados no campo "Bonus DS"
			if @DataInicial >= '2026-04-01' and @DataFinal <= '2026-04-15'
			begin
				update
					p
				set
					ppr_vl_bonus_ds = ppr_vl_base * case when p.ppr_data_referencia = '2026-04-05' then 0.2 else 0.1 end
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * case when p.ppr_data_referencia = '2026-04-05' then 0.2 else 0.1 end)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_data_referencia between '2026-04-03' and '2026-04-05'
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


			--Aplicação de adicional de feriado na base de frete – 21/04
				--O adicional de 10% deve ser aplicado sobre o valor da rota.	
				--A regra deve valer para todas as bases de frete.	
				--A aplicação deve ocorrer exclusivamente para o dia 21/04.	
				--Os valores atualizados devem refletir corretamente o adicional de feriado.

			if @DataInicial >= '2026-04-16' and @DataFinal <= '2026-04-30'
			begin
				
				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.1 
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-04-21'
					--Ajuste para remover esses tipos de veiculos que vão ser um valor diferente
					and p.ppr_ds_tipo_veiculo not in ('Veículo de Passeio','Utilitários','Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



				--Aplicar adicional de 20% para os tipos de veiculos 'Veículo de Passeio','Utilitários','Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool'
				--Datas 18,19,20 e 21/04
				--Somente contrato agregado - 81
				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.2
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.2)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia between '2026-04-18' and '2026-04-21'
					and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Veículo de Passeio','Utilitários','Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


			end


			--Solicitado o adicional de 30% nas rotas realizadas no dia 10/05, vinculadas ao tipo de veículo carro SPOT.
			--Tipo de contrato: Agregado
			--Veículos que terá o adicional:
			--Bulk - VUC equipe única Pool
			--Utilitários
			--Veículo de Passeio

			if @DataInicial >= '2026-05-01' and @DataFinal <= '2026-05-15'
			begin
				

				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.3
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.3)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-05-10'
					and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Veículo de Passeio','Utilitários','Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)



			end


			--Configurar a regra de acréscimo pontual para a data de 13/06.
			--Solicitado o adicional de 10% nas rotas realizadas no dia 13/06
			--Tipo de contrato: Agregado

			--Veículos que terá o adicional:
			--'Bulk - VUC equipe única Pool'
			--'Bulk - VUC equipe dupla Pool'

			--Basear o cálculo no valor original da rota, somando os 10% ao montante final que será enviado para o espelho de pagamento do motorista.
			--As rotas realizadas por veículos do tipo BULK da frota Spot - Veículo do motorista seguem a tabela de preço e regras de pagamento padrão cadastradas no sistema para a operação.


			if @DataInicial >= '2026-06-01' and @DataFinal <= '2026-06-15'
			begin
				

				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.1
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-06-13'
					and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool','Veículo de Passeio','Utilitários')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


			end

			--Cliente solicitou que seja feita a aplicação de um adicional de 10% nas rotas SPOT nos dias 19/06/2026 e 24/06/2026
			--Veículos para aplicar os 10%: 
			--  Veículo de Passeio
			--  Utilitários
			--	Bulk - VUC equipe única Pool
			if @DataInicial >= '2026-06-16' and @DataFinal <= '2026-06-30'
			begin
				

				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.1
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia in ('2026-06-19','2026-06-24')
					--and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool','Veículo de Passeio','Utilitários')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


			end


			--Cliente solicitou a que seja feita a aplicação de um adicional nas suas operações SPOT nos dias 05/07/2026 e 09/07/2026
			--Dia 05/07/2026(Domingo) receberá um adicional de 10% totalizando 20% 
			--Dia 09/07/2026 receberá um adicional de 20% totalizando 30% 
			--Ressaltou que cliente já paga um adicional de 10% para todas as suas operações nos dias de domingo e feriados, esse adicional mencionado acima deve ser aplicado apenas na operação SPOT e nós dias descritos no corpo da task.

			if @DataInicial >= '2026-07-01' and @DataFinal <= '2026-07-15'
			begin
				

				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.2
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.2)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia in ('2026-07-05')
					--and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool','Veículo de Passeio','Utilitários')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)


				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.3
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.3)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia in ('2026-07-09')
					--and m.mot_ctn_cd_tipo_contrato = 81
					and p.ppr_ds_tipo_veiculo in ('Bulk - VUC equipe única Pool','Bulk - VUC equipe dupla Pool','Veículo de Passeio','Utilitários')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)

			end


		end --Fim Transmana


		if @CodigoCliente = 66
		begin
	
			if @DataInicial >= '2026-06-01' and @DataFinal <= '2026-06-15'
			begin
				
				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.1
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-06-13'
					and p.ppr_base_principal in ('SSP23', 'SMG9', 'SMG11')
					and p.ppr_ds_tipo_veiculo in ('Utilitários', 'Veículo de Passeio', 'Vuc', 'Bulk Vuc', 'Vuc SDD', 'Utilitários SDD', 'Van')
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
					
			end

			/*
			A transportadora definiu o pagamento de 30% a mais no dia 09/08 como bônus de campanha de dias dos pais.
			As bases que devem receber são:
				Danieli: EMG20, SRJ13, SRJ3, SMR1 e SMG14
				Bruno: ERJ7, EMG30, EGO2, SRJ6 e SSP8
				Thais: SRJ6
				Conceição: SES2 , SMG1 , SRJ4 e SSP39
			Todos os modais devem receber o adicional. A porcentagem deve ser adicionada ao valor de domingo/feriado já cadastrado, e deve considerar o valor base para cálculo
			*/
			if @DataInicial >= '2026-08-01' and @DataFinal <= '2026-08-15'
			begin
				
				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_dom_fer + (ppr_vl_base * 0.3)
					--,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.3)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia = '2026-08-09'
					and (p.ppr_base_principal in ('EMG20','SRJ13','SRJ3','SMR1','SMG14','ERJ7','EMG30','EGO2','SSP8','SES2','SMG1','SRJ4','SSP39')
						or (p.ppr_base_principal in ('SRJ6') and p.ppr_ds_tipo_veiculo not in ('Frota Fixa Large Van Ford'))
						)
					and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
					
			end
		
		end --fim if hawk


		/*
		Comentado por Saulo em 16/07/2026 solicitado pela Jennifer
		if @CodigoCliente = 69
		begin
			if @DataInicial >= '2026-06-16' and @DataFinal <= '2026-06-30'
			begin
				update
					p
				set
					 ppr_vl_dom_fer = ppr_vl_base * 0.1
					,ppr_vl_total = ppr_vl_total + (ppr_vl_base * 0.1)
				from
					tb_pgto_periodo_rota p with(nolock)
					join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
					join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
					join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
					join tb_tipo_contrato c with(nolock) on m.mot_ctn_cd_tipo_contrato = c.ttc_cd_tipo_contrato
				where
					ppr_cd_periodo = @CodPeriodoPagamento
					and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
					and p.ppr_in_excluido = 0
					and e.mtn_in_excluido = 0
					and ppr_cd_rota is not null
					and ppr_cd_tipo_pgto = 1362
					and ppr_vl_base > 0
					and p.ppr_data_referencia in ('2026-06-24', '2026-06-29')
					and c.ttc_nm_tipo = 'Motorista agregado'
					and p.ppr_base_principal in ('SSP17', 'SSP23', 'SSP6', 'SSC2', 'SSC1', 'SSC9', 'SSC3', 'SSC8', 'SSC5', 'SMG1', 'SMG15', 'SMS1', 'EMS10', 'SMG5', 'SPR1', 'SPR8', 'SPR3', 'EPR5', 'SRS1', 'SRS5', 'SRS3', 'SMG8', 'SPR11', 'SPR10')
					and p.ppr_ds_tipo_veiculo in ('Veículo de Passeio', 'Utilitários', 'Van', 'Vuc', 'Vuc SDD', 'Van SDD', 'Utilitários SDD')
			end
		end --fim ado
		*/

	end


	--Adicionado Regra por Saulo Barros em 28/08/2026
	--Regras Campanhas Deluna
	if @CodigoCliente = 88 and cast(getdate() as date) <= isnull(@DataLimiteReanalise,cast(getdate() as date))
	begin

			
		--Regra: Incentivo dia dos pais
		--Critérios:
		--	Incluir adicional de 80 reais para o dia 09/08
		--	Apenas motoristas agregados
		--	Apenas Bases: 'SMG14', 'SMG15', 'SES1', 'SMG8', 'SRJ7', 'SRJ2', 'SRJ4', 'SRJ10', 'SRJ8', 'SRJ6'
		--  Os valores devem ser adicionados no campo "Bonus DS"
		if @DataInicial >= '2026-08-01' and @DataFinal <= '2026-08-15'
		begin
			update
				p
			set
				ppr_vl_bonus_ds = 80
				,ppr_vl_total = isnull(ppr_vl_total,0) + 80
			from
				tb_pgto_periodo_rota p with(nolock)
				join tb_pag_espelhos e with(nolock) on p.ppr_cd_motorista_nfs = e.mtn_cd_motorista_nfs
				join tb_usuario u with(nolock) on e.mtn_cd_motorista = u.usr_cd_usuario
				join tb_motorista m with(nolock) on u.usr_cd_usuario = m.mot_cd_usuario
			where
				ppr_cd_periodo = @CodPeriodoPagamento
				and mtn_cd_status in (34,228,38) --apenas espelhos em aberto
				and p.ppr_in_excluido = 0
				and e.mtn_in_excluido = 0
				and ppr_cd_rota is not null
				and ppr_cd_tipo_pgto = 1362
				and m.mot_ctn_cd_tipo_contrato = 482 --AGREGADO
				and ppr_base_principal in ('SMG14', 'SMG15', 'SES1', 'SMG8', 'SRJ7', 'SRJ2', 'SRJ4', 'SRJ10', 'SRJ8', 'SRJ6')
				and p.ppr_data_referencia = '2026-08-09'
				and (p.ppr_cd_motorista_nfs = @CodEspelho or @CodEspelho is null)
		end

	end --fim if deluna

end
GO
