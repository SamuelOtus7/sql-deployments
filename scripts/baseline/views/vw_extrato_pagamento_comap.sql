-- ============================================================
-- BASELINE: dbo.vw_extrato_pagamento_comap
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_extrato_pagamento_comap]    Script Date: 14/09/2026 12:12:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vw_extrato_pagamento_comap] as



	select 
		 ppr_cd_pgto_espelho 
		,ppr_ds_placa as placa
		,mtn_cd_pgto_periodo
		,mtn_base_principal as Base 
		,mtn_nome_motorista as Motorista
		,cadResp.usr_nm_usuario as Responsavel
		,sum(ppr_vl_total) as TotalReceber
		,sum(case when  ppr_cd_rota is not null  then ppr_vl_base else 0 end) TotalDiariaLiqPre 
		,sum(case when  ppr_lcto_cd_lancamento is null and ppr_cd_rota is null then ppr_vl_base else 0 end) ValorAvulso 
		,sum(ppr_vl_lancamentos) as ppr_vl_lancamentos
		,sum(ppr_vl_paradas	) as Parada	
		,sum(ppr_vl_pedagio	) as Pedagio	
		,sum(ppr_vl_risco	) as risco	
		,sum(ppr_vl_ajudante ) as ppr_vl_ajudante	
		,sum(ppr_vl_dom_fer	) as ppr_vl_dom_fer	
		,sum(case when  ppr_cd_rota is not null and ppr_lcto_cd_lancamento is  null then 1 else 0 end) QtdRotas

		,SUM( 
				case 
					when plm_nm_tipo = 'PF - PNR' then tlm_vl_valor_descontos * - 1
				else 0	end 
			) AS PNR
		,SUM( 
				case 
					when plm_nm_tipo = 'PF - Pacote Perdido' then tlm_vl_valor_descontos * -1
				else 0	end 
			) as PacotePerdido
		,SUM( 
				case 
					when plm_nm_tipo = 'PF - Endereço não visitado' then tlm_vl_valor_descontos * -1
				else 0	end 
			) as EnderecaoNaoVisitado
		
		,SUM( 
				case 
					when plm_nm_tipo = 'Abastecimento' then tlm_vl_valor_descontos * -1
				else 0	end 
			) as Abastecimento

		,SUM( 
				case 
					when plm_nm_tipo = 'Backup' then tlm_vl_valor_adicional 
				else 0	end 
			) [Backup]

		,SUM( 
				case 
					when plm_nm_tipo = 'Ambulância' then tlm_vl_valor_adicional
				else 0	end 
			) Ambulancia
			
	from tb_pgto_periodo_rota as a

	inner join tb_pag_espelhos as pag
	on ppr_cd_pgto_espelho = pag.mtn_cd_motorista_nfs
	
	left join vw_lancamentos_manuais_aprovados as aprov
	on a.ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual

	inner join tb_motorista as b
	on pag.mtn_cd_motorista = b.mot_cd_usuario

	inner join tb_usuario as cad
	on pag.mtn_cd_motorista  = cad.usr_cd_usuario

	left join tb_usuario as cadResp
	on cad.usr_cd_usr_responsavel_contrato = cadResp.usr_cd_usuario

	where 1=1
	--and ppr_cd_periodo = 2086
	and ppr_in_excluido = 0
	--and ppr_nome_motorista  like '%thais christina%'
	--and ppr_base_principal = 'SBA6'
	group by 
		 ppr_cd_pgto_espelho
		,ppr_ds_placa
		,mtn_cd_pgto_periodo
		,mtn_base_principal 
		,mtn_nome_motorista 
		,cadResp.usr_nm_usuario

--declare @idperiodo int = 1430
/*
select distinct 
	 mtn_cd_pgto_periodo
	,mtn_base_principal as Base 
	,mtn_nome_motorista as Motorista
	,cadResp.usr_nm_usuario as Responsavel
	,ppr_ds_placa as Placa -- E se o motorista dirigir duas placas na quinzena? 
	,qtdRotas as QtdRotas
	--,mtn_vl_nfs as TotalReceber
	
	,ppr_vl_total 
			+ isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then isnull(avulso.Valor,0)  else 0 end,0)
			+ isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then PacotePerdido else 0 end,0)
			+ isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then EnderecaoNaoVisitado else 0 end,0)
			+ isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then PNR else 0 end,0) 		as TotalReceber

	,ppr_vl_base	as TotalDiariaLiqPre
	
	,ppr_vl_paradas as Parada
	,ppr_vl_pedagio as Pedagio
	
	, isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then PacotePerdido else 0 end,0) as PacotePerdido
	, isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then PNR else 0 end,0) as PNR
	, isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then EnderecaoNaoVisitado else 0 end,0) as EnderecaoNaoVisitado
			
	
	--,isnull(PacotePerdido,0) as PacotePerdido
	--,isnull(PNR,0) as PNR
	--,isnull(EnderecaoNaoVisitado,0) as EnderecaoNaoVisitado
	,ppr_vl_risco
	,ppr_vl_ajudante
	,ppr_vl_dom_fer
	,ppr_vl_lancamentos
	--,isnull(avulso.Valor,0) 
	,isnull(case when ROW_NUMBER() over(partition by mtn_cd_pgto_periodo, mtn_base_principal, mtn_nome_motorista  order by qtdRotas desc ) = 1 then isnull(avulso.Valor,0)  else 0 end,0) as ValorAvulso


from tb_pag_espelhos as a

inner join tb_motorista as b
on a.mtn_cd_motorista = b.mot_cd_usuario

inner join tb_usuario as cad
on a.mtn_cd_motorista  = cad.usr_cd_usuario

left join tb_usuario as cadResp
on cad.usr_cd_usr_responsavel_contrato = cadResp.usr_cd_usuario

inner join (
			select 
				 ppr_cd_pgto_espelho
				,ppr_ds_placa
				,sum(isnull(ppr_vl_base			,0)) as ppr_vl_base	
				,sum(isnull(ppr_vl_paradas		,0)) as ppr_vl_paradas
				,sum(isnull(ppr_vl_pedagio		,0)) as ppr_vl_pedagio
				,sum(isnull(ppr_vl_total		,0)) as ppr_vl_total
				,sum(isnull(ppr_vl_risco		,0)) as ppr_vl_risco
				,sum(isnull(ppr_vl_ajudante		,0)) as ppr_vl_ajudante
				,sum(isnull(ppr_vl_dom_fer		,0)) as ppr_vl_dom_fer
				,sum(isnull(ppr_vl_lancamentos	,0)) as ppr_vl_lancamentos
				,sum(case when ppr_cd_rota is not null and ppr_vl_base is not null then 1 else 0 end) qtdRotas
				,ppr_lcto_observacao

			from tb_pgto_periodo_rota as a
			where ppr_cd_rota is not null
			and  ppr_in_excluido = 0
			--and ppr_nome_motorista = 'Wisley Bruno Galvao'
			--and  ppr_cd_periodo in (1430)
			
			group by ppr_cd_pgto_espelho,ppr_ds_placa,ppr_lcto_observacao
) as c
on a.mtn_cd_motorista_nfs = c.ppr_cd_pgto_espelho

left join (

			select 
				ppr_cd_pgto_espelho
				--,ppr_cd_pagamento_rota
				,SUM( 
						case 
							when plm_nm_tipo = 'PF - PNR' then tlm_vl_valor_descontos * - 1
						else 0	end 
					) AS PNR
				,SUM( 
						case 
							when plm_nm_tipo = 'PF - Pacote Perdido' then tlm_vl_valor_descontos * -1
						else 0	end 
					) as PacotePerdido
				,SUM( 
						case 
							when plm_nm_tipo = 'PF - Endereço não visitado' then tlm_vl_valor_descontos * -1
						else 0	end 
					) as EnderecaoNaoVisitado

			from tb_pgto_periodo_rota as a
			inner join vw_lancamentos_manuais_aprovados as b
			on a.ppr_lcto_cd_lancamento = tlm_cd_lancamento_manual

			where ppr_lcto_cd_lancamento is not null 
			and  ppr_in_excluido = 0
			--and ppr_nome_motorista = 'Wisley Bruno Galvao'
			--and  ppr_cd_periodo in (1430)

			group by ppr_cd_pgto_espelho--,ppr_cd_pagamento_rota


) as lanc
on a.mtn_cd_motorista_nfs = lanc.ppr_cd_pgto_espelho


left join (
--730906
--730906
			select 
				ppr_cd_pgto_espelho
				,SUM( ppr_vl_total) as Valor

			from tb_pgto_periodo_rota as a
			
			where ppr_cd_rota is null
			and  ppr_in_excluido = 0
			--and  ppr_cd_periodo in (1430)
			--and ppr_nome_motorista = 'Wisley Bruno Galvao'

			group by ppr_cd_pgto_espelho


) as avulso
on a.mtn_cd_motorista_nfs = avulso.ppr_cd_pgto_espelho



where 1=1 
and ppr_ds_placa is not null
--and mtn_cd_pgto_periodo in (@IdPeriodo)
--and mtn_nome_motorista = 'Carlos Henrique Macedo Alves'
*/


GO
