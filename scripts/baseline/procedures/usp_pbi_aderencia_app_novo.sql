-- ============================================================
-- BASELINE: dbo.usp_pbi_aderencia_app_novo
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[usp_pbi_aderencia_app_novo]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[usp_pbi_aderencia_app_novo]
as
begin

	drop table if exists #base
	select 
		users.cli_cd_codigo_cliente as Transportadora,
		users.usr_nm_usuario as Motorista,
		cast(gps.rgp_dh_data_hora as date) as Data,
		users.usr_cd_usuario,
		count(*) as Apontamentos,
		min(gps.rgp_dh_data_hora) as Abertura,
		max(gps.rgp_dh_data_hora) as Encerramento

		into #base

	from 
		tb_registro_gps as gps with(nolock)
		join tb_usuario as users with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
		where usr_in_ativo = 1
	group by 
		users.usr_nm_usuario,
		users.usr_cd_usuario,
		cast(gps.rgp_dh_data_hora as date),
		users.cli_cd_codigo_cliente


	drop table if exists #tb_aderencia_app_novo

	select DataReferencia,
		   rotas.NomeMotorista,
		   ServiceCenter,
		   coalesce(b.dab_nm_base,svc.svc_cd_service_center,rotas.ServiceCenter)  Base,
		   isnull(KmColetado,0) as KmColetado,
		   isnull(LinkMapa,'') as LinkMapa,
		   clientes.cli_cd_codigo_cliente as TenantId,
		--    isnull(Apontamentos,0) as Apontamentos,
		   isnull(QuantidadeApontamento,0) as Apontamentos,
		--    case when Apontamentos is null then 0 else 1 end as StatusApontamento,
		   case when UsouAPP = 'Sim' then 1 else 0 end as StatusApontamento,
		   case when acesso.Motorista is not null then 'Sim' else 'Não' end PossuiUsuario,
		   acesso.UltimoAcesso,
		   ultirota.UltimaRota,
		   1 as TotalRotas,
		   lst_cd_lista
	  
		into #tb_aderencia_app_novo

	from tb_ml_rotas as rotas with(nolock)
		left join tb_ml_service_center svc with(nolock) on rotas.ServiceCenter = svc.svc_cd_service_center 
		and rotas.idtransportadora = rotas.idtransportadora
		
		left join tb_ml_service_center svc2 with(nolock) 
		on case when isnull(rotas.OrigemSaida,'') <> '' then rotas.OrigemSaida else rotas.ServiceCenter end = svc2.svc_cd_service_center
		and rotas.idtransportadora = rotas.idtransportadora

		left join tb_dra_bases b with(nolock) 
		on svc2.svc_cd_service_center = b.dab_cd_service_center and rotas.IdTransportadora = b.dab_cd_transportadora

		inner join
				(
				select 
					 cli_cd_codigo_cliente
					,lst_cd_lista
					,cli_id_logistics
					,cli_dt_ini_geo
				from tb_clientes as a with(nolock)
				inner join tb_lista as b with(nolock)
				on a.cli_cd_codigo_cliente = b.lst_cd_cliente
				where lst_nm_lista = 'Clientes transportadoras'
				and cli_cd_codigo_cliente <> 7
				and lst_ds_label = 'Mercado Livre'
			) as clientes
		on rotas.idtransportadora = clientes.cli_id_logistics

		left join #base as base
		on clientes.cli_cd_codigo_cliente = base.Transportadora 

		and rotas.NomeMotorista = base.Motorista
		and rotas.DataReferencia = base.Data
		left join 	 (
						select users.cli_cd_codigo_cliente as Transportadora,
							   users.usr_nm_usuario as Motorista,
							   max(gps.rgp_dh_data_hora) as UltimoAcesso
						from tb_usuario as users with(nolock)
							left join tb_registro_gps as gps with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
						where usr_in_ativo = 1
						group by users.usr_nm_usuario,
								 users.cli_cd_codigo_cliente
					) as acesso
		on clientes.cli_cd_codigo_cliente = acesso.Transportadora 
		and rotas.NomeMotorista = acesso.Motorista
		
		left join 
		(
			select 
				UltimaRota,
				NomeMotorista,
				idtransportadora

			from
			(
				SELECT 
					ROW_NUMBER() OVER (partition by NomeMotorista,idtransportadora ORDER BY DataReferencia DESC) as RowNumber,
					DataReferencia as UltimaRota,
					NomeMotorista,
					idtransportadora

				FROM 
					vw_rotas with(nolock)
			) as a
				where RowNumber = 1

		) as ultirota
		on 1=1
		AND clientes.cli_id_logistics	= ultirota.idtransportadora 
		and rotas.NomeMotorista			= ultirota.NomeMotorista 

	where rotas.Excluido = 0
          and rotas.DataReferencia BETWEEN CAST(GETDATE()-31 as date ) and CAST(GETDATE() as date )
          and rotas.NomeMotorista not in ('','-')
		  and rotas.DataReferencia >= clientes.cli_dt_ini_geo
		  --AND rotas.IdTransportadora = 2087146923

delete a from tb_aderencia_app_novo as a 
inner join #tb_aderencia_app_novo as b
on a.DataReferencia = b.DataReferencia


insert into tb_aderencia_app_novo (
								DataReferencia
								,NomeMotorista
								,ServiceCenter
								,Base
								,KmColetado
								,LinkMapa
								,TenantId
								,Apontamentos
								,StatusApontamento
								,PossuiUsuario
								,UltimoAcesso
								,UltimaRota
								,TotalRotas
								,ListaFiltro
								)

select distinct * from #tb_aderencia_app_novo asa

union all

select distinct  
	 rota.datareferencia
	,rota.Motorista
	,rota.NomeHub
	,bss_ds_cidade as base
	,'0' as KmColetado	
	,'0' as LinkMapa
	,cli_cd_codigo_cliente TenantId
	,isnull(gps.Apontamentos,0) as Apontamentos
	,case when gps.Apontamentos > 20 then 1 else 0 end  StatusApontamento
	,case when motorista.usr_cd_usuario is null then 'Não' else 'Sim' end  PossuiUsuario	
	,UltimoAcesso	
	,null UltimaRota	
	,null TotalRotas
	,lst_cd_lista as ListaFiltro

from vw_rotas_spe_v4 as rota with(nolock)
left join (

	select usr_cd_usuario,a.* 
	from tb_spe_motoristas as a with(nolock)
	inner join tb_usuario as b with(nolock)
	on a.nome = b.usr_nm_usuario 
	--where cli_cd_codigo_cliente in (27,5)

) as motorista
on rota.IdMotorista = motorista.IdMotorista

left join #base as gps
on motorista.usr_cd_usuario = gps.usr_cd_usuario
and  rota.datareferencia = gps.data

left join 	 
(
	select users.cli_cd_codigo_cliente as Transportadora,
			users.usr_nm_usuario as Motorista,
			usr_cd_usuario,
			max(gps.rgp_dh_data_hora) as UltimoAcesso
	from tb_usuario as users with(nolock)
		left join tb_registro_gps as gps with(nolock) on gps.rgp_cd_usuario = users.usr_cd_usuario
	where usr_in_ativo = 1
	group by users.usr_nm_usuario,usr_cd_usuario,
				users.cli_cd_codigo_cliente
) as acesso
on gps.Transportadora = acesso.Transportadora 
and gps.usr_cd_usuario = acesso.usr_cd_usuario

inner join 
			(
				select 
					 cli_cd_codigo_cliente
					,lst_cd_lista
					,cli_id_shopee
				from tb_clientes as a with(nolock)
				inner join tb_lista as b with(nolock)
				on a.cli_cd_codigo_cliente = b.lst_cd_cliente
				where lst_nm_lista = 'Clientes transportadoras'
				and cli_cd_codigo_cliente <> 7
				and lst_ds_label = 'Shopee'
			) as cli
on rota.idtransportadora = cli_id_shopee

left join tb_bases as base with(nolock)
on rota.NomeHub = base.bss_ds_nome
and bss_cd_idtransportadora = rota.idtransportadora

where rota.datareferencia  BETWEEN CAST(GETDATE()-31 as date ) and CAST(GETDATE() as date )
--and rota.IdTransportadora = 20230008
and rota.Motorista is not null
and rota.NomeHub is not null --Verificar por que hub está vindo null

end

--select * 
--from tb_lista
--where lst_nm_lista = 'Clientes transportadoras'
--and lst_cd_cliente is not NULL
--and lst_cd_cliente <> 7




--select distinct
--svc_cd_service_center Base 
--,svc_nm_cidade Cidade 
--from
--	tb_ml_service_center
--where svc_nm_cidade is not NULL

--select 
--	distinct 
--	 bss_ds_nome
--	,isnull(bss_ds_cidade,'Não cadastrado') as bss_ds_cidade

--from tb_bases
--where bss_ds_marketplace = 'Shopee'




GO
