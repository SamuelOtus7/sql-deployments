-- ============================================================
-- BASELINE: dbo.UspFinAtualizaEspelhoConsolidado_bkp20250602
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspFinAtualizaEspelhoConsolidado_bkp20250602]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [dbo].[UspFinAtualizaEspelhoConsolidado_bkp20250602]
(
	@periodo int
) as

-- select
-- ppr_cd_rota, count(*) 
-- from tb_pgto_periodo_rota 
-- where ppr_cd_periodo = 303 
-- and isnumeric(ppr_cd_rota) = 0
-- group by ppr_cd_rota
-- having count(*) > 1

-- declare @periodo int = 303
declare @CodigoCliente int = (select pgp_cd_cliente from tb_pgto_periodo where pgp_cd_periodo = @periodo)

--Para 50+ precisa considerar a chave motorista e svc
if @CodigoCliente in (11,1,56)
begin
	drop table if exists #tb_pgto_periodo_rota_50mais
	select 
		ppr_base.ppr_base_principal as base_principal_espelho
		,ppr_rota.*
		into #tb_pgto_periodo_rota_50mais
	from 
		tb_pgto_periodo_rota as ppr_rota
		join (
				select 
					*
					,row_number() over(partition by ppr_cd_motorista, ppr_base_principal order by qtd desc) ordem
				from
					(
					select
						ppr_cd_motorista
						,ppr_base_principal
						,ppr_cd_periodo
						,count(*) qtd
					from 
						tb_pgto_periodo_rota
					where 
						ppr_cd_periodo = @periodo
					group by 
						ppr_cd_motorista, 
						ppr_base_principal,
						ppr_cd_periodo
					) as a
			) as ppr_base on ppr_rota.ppr_cd_motorista = ppr_base.ppr_cd_motorista
						and ppr_rota.ppr_base_principal = ppr_base.ppr_base_principal
						and ppr_rota.ppr_cd_periodo = ppr_base.ppr_cd_periodo
	where 
		ordem = 1

	drop table if exists #pag_espelhos_50mais
	select
		ppr_cd_motorista as mtn_cd_motorista
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo
		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,count(*) as mtn_qt_rotas
		,bss_cd_base as mtn_cd_base
		,base_principal_espelho mtn_base_principal
		into #pag_espelhos_50mais
	from 
		#tb_pgto_periodo_rota_50mais as a
		left join [tb_pgto_periodo] as periodo on a.ppr_cd_periodo = periodo.pgp_cd_periodo
		left join tb_bases as c on a.base_principal_espelho = case 
									when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla
									when bss_ds_marketplace = 'shopee' then bss_ds_nome
									else bss_ds_sigla end
								and periodo.pgp_cd_cliente = c.bss_cod_cliente

	WHERE 
		ppr_in_excluido = 0
		and ppr_cd_periodo = @periodo
	group by  
		ppr_cd_motorista,
		ppr_cd_periodo,
		periodo.pgp_cd_cliente,
		bss_cd_base,ppr_nome_motorista,
		base_principal_espelho

	update 
		a
	set
		a.mtn_vl_nfs = b.mtn_vl_nfs
		,a.mtn_qt_rotas = b.mtn_qt_rotas
	from 
		tb_pag_espelhos as a
		join #pag_espelhos_50mais as b on a.mtn_cd_motorista = b.mtn_cd_motorista
								and a.mtn_base_principal = b.mtn_base_principal
								and a.mtn_cd_pgto_periodo = b.mtn_cd_pgto_periodo
	where 
		a.mtn_cd_pgto_periodo = @periodo

end
else
begin
	--update  tb_pgto_periodo_rota
	--set ppr_vl_total = (isnull(ppr_vl_base,0)
	--+isnull(ppr_vl_paradas,0)
	--+isnull(ppr_vl_risco,0)
	--+isnull(ppr_vl_ajudante,0)
	--+isnull(ppr_vl_dom_fer,0)
	--+isnull(ppr_vl_lancamentos,0)
	--+isnull(ppr_vl_pedagio,0)
	--+isnull(ppr_vl_aluguel,0)
	--+isnull(ppr_vl_desconto,0)
	--+isnull(ppr_vl_recarga,0)
	--+isnull(ppr_vl_pacotes,0)
	--+isnull(ppr_vl_bonus,0)
	--+isnull(ppr_vl_insucessos,0)
	--+case 
	--	when ppr_cd_rota is null or ppr_vl_base is null then ppr_vl_total else 0 end 
	--)

	
	--from tb_pgto_periodo_rota
	--where ppr_cd_periodo = @periodo

	drop table if exists #tb_pgto_periodo_rota
	select 
		ppr_base.ppr_base_principal as base_principal_espelho
		,ppr_rota.*
		
		into #tb_pgto_periodo_rota
	from tb_pgto_periodo_rota as ppr_rota
	inner join 
			(
				select *
				,row_number() over(partition by ppr_cd_motorista order by qtd desc) ordem
				from(
					select
						ppr_cd_motorista
						,ppr_base_principal
						,ppr_cd_periodo
						,count(*) qtd
					from tb_pgto_periodo_rota
					where ppr_cd_periodo = @periodo
					group by ppr_cd_motorista, ppr_base_principal,ppr_cd_periodo
				) as a
			) as ppr_base
	on ppr_rota.ppr_cd_motorista = ppr_base.ppr_cd_motorista
	and ppr_rota.ppr_cd_periodo = ppr_base.ppr_cd_periodo
	where ordem = 1


	-- SELECT base_principal_espelho, * FROM #tb_pgto_periodo_rota
	-- WHERE ppr_nome_motorista = 'AGNALDO GOMES BARREIROS'


	-- SELECT TOP 10 * FROM tb_bases
	-- WHERE bss_cod_cliente = 27
	-- AND bss_ds_nome = 'XPT_SP_Itapetininga'


	drop table if exists #pag_espelhos
	select
			ppr_cd_motorista as mtn_cd_motorista
		,ppr_nome_motorista as mtn_nome_motorista
		,ppr_cd_periodo as mtn_cd_pgto_periodo

		,SUM(isnull(ppr_vl_total,0)) as mtn_vl_nfs
		,count(*) as mtn_qt_rotas
		,bss_cd_base as mtn_cd_base
		,base_principal_espelho mtn_base_principal
	
		into #pag_espelhos

	from #tb_pgto_periodo_rota as a

	left join [tb_pgto_periodo] as periodo
	on a.ppr_cd_periodo = periodo.pgp_cd_periodo

	left join tb_bases as c
	on a.base_principal_espelho = case 
									when bss_ds_marketplace = 'Mercado Livre' then bss_ds_sigla
									when bss_ds_marketplace = 'shopee' then bss_ds_nome
									else bss_ds_sigla end
	and periodo.pgp_cd_cliente = c.bss_cod_cliente

	WHERE ppr_in_excluido = 0
	and ppr_cd_periodo = @periodo
	--where ppr_cd_rota = 146941866

	group by  ppr_cd_motorista ,ppr_cd_periodo,periodo.pgp_cd_cliente,bss_cd_base,ppr_nome_motorista,
	base_principal_espelho;



	update a
	set
		a.mtn_vl_nfs = b.mtn_vl_nfs
		,a.mtn_qt_rotas = b.mtn_qt_rotas
		,a.mtn_cd_base = b.mtn_cd_base
		,a.mtn_base_principal = b.mtn_base_principal

	from tb_pag_espelhos as a
	inner join #pag_espelhos as b
	on a.mtn_cd_motorista = b.mtn_cd_motorista
	and a.mtn_cd_pgto_periodo = b.mtn_cd_pgto_periodo
	where a.mtn_cd_pgto_periodo = @periodo

end
GO
