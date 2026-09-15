-- ============================================================
-- BASELINE: dbo.UspMensagemIndicadores_drop
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMensagemIndicadores_drop]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [dbo].[UspMensagemIndicadores_drop]  
(
 @transportdora INT,
    @data date,
    @svc varchar(50),
	@codrelatorio int
)as 



 --DECLARE  @transportdora INT = 33,
 --@data date = '2024-07-17',
 --@svc varchar(10) = 'SMG4',
 --@codrelatorio int = 1092

	 
--DECLARE  @transportdora INT = 27,
--@data date = '2024-04-04',
--@svc varchar(50) = 'LM Hub_SP_Jundiaí',
--@codrelatorio int = 1122

if @codrelatorio in (1092,1128,1146)
begin


	SELECT  Indicador as Indicador
			,Valor

  
	FROM   
	   (
		select 
			 cast(format(DataReferencia,'dd/MM') as varchar(30)) as data
			 ,cast(left(round(cast(sum(CAST(PacotesEntregues AS INT )) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT ) )*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
			 ,cast(sum(CAST(TotalPacotes AS INT)) as varchar(30)) as pacotes
			 ,cast(sum(CAST(PacotesEntregues AS INT )) as varchar(30)) as  entregues
			 ,cast(sum(case when StatusRota = 'Fechada' then 1 else 0 end ) as varchar(30)) as finalizados
			 ,cast(sum(case when StatusRota = 'Ativa' then 1 else 0 end ) as varchar(30)) as abertos
			 ,cast(sum(CAST(PacotesPendentes AS INT) ) as varchar(30)) as qtde_pendentes
			 ,cast(left(round(cast(sum(CAST(PacotesPendentes as INT)) as decimal(10,2)) / SUM(CAST(TotalPacotes AS INT))*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
			 ,cast(sum(CAST(PacotesNaoEntregue as INT )) as varchar(30)) as         insucessos
            ,cast(sum(isnull(QuantidadeAmbulancia,0)) as varchar(30)) as ambulancia
			,cast(sum(isnull(QuantidadeReclamacoes,0)) as varchar(30)) as qtd_Reclamacoes
			,cast(servicecenter as varchar(30)) as sigla_svc
			,cast(Base as varchar(30)) as nome_svc
            ,cast(case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end as varchar(30)) as   ciclo


		from vw_rotas
		where IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
		and DataReferencia = @data
		and servicecenter = @svc
		group by DataReferencia,servicecenter,Base
        ,case when FORMAT(datahorainicio,'HH') < 12  then 'AM' else 'PM' end 
	   ) p  
	UNPIVOT  
	   (Valor FOR Indicador IN   
		  (  
			data
			,pacotes
			,qtde_pendentes
			,[success_delivery]
			,[perc_pendentes]
			,finalizados
			,abertos
			,insucessos 
			,sigla_svc
            ,nome_svc
			,entregues
            ,ambulancia
            ,qtd_Reclamacoes
            ,ciclo
			-- ,ListaInsucessos
			)  
	)AS unpvt

union ALL

	select 
		'lista_insucessos' as lista_insucessos
		,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
		-- ,a.qtd
	FROM
	(
		select 

			b.SubStatus
			,COUNT(*) qtd

		from vw_rotas as a
		inner join vw_pacotes as b
		on a.idtransportadora = b.idtransportadora
		and a.IdRota = b.IdRota

		where a.IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
		and a.DataReferencia = @data
		and a.servicecenter = @svc
		and StatusEntrega = 'Não Entregue'
		and b.SubStatus <> 'Transferido'
		group by b.SubStatus

	) as a

union ALL

select 
		'lista_veiculos' as lista_veiculos
		,cast(STRING_AGG('• ' + a.TipoVeiculo  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
		-- ,a.qtd
FROM
(
    select 

        a.TipoVeiculo
        ,COUNT(*) qtd

    from vw_rotas as a

    where a.IdTransportadora in (
                    select distinct  cli_id_logistics
                    from tb_clientes 
                    where 1=1 
                    and cli_cd_codigo_cliente =  @transportdora
                    and cli_ds_logo_report  is not null
                    )
    and a.DataReferencia = @data
    and a.servicecenter = @svc

    group by a.TipoVeiculo

) as a


--- indicadores diarios
union ALL

SELECT  Indicador as Indicador
,Valor
FROM   
(            
       
SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as in_veiculos_cadastrados
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as in_veiculos_disp
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as in_rotas_recebidas
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as in_rotas_carregadas
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as in_noShow
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as in_distrato
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as ds_noShow_nome
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as ds_noShow_motivo
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as ds_noShow_operacao
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as in_distrato_nome
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as in_distrato_motivo
FROM (SELECT @svc AS ServiceCenter) AS Base
	outer apply (
					select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
					from [tb_indicadores_diarios] as a
						inner join tb_acessos_indicadores as b
						on a.ind_cd_base = b.aci_cd_acessos_indicadores
							and a.ind_cd_transportadora = b.aci_cd_transportadora
					where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
					and aci_cd_base = base.ServiceCenter
			  ) as a
-- and  cast(ind_dh_data as date) = @data


) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
 in_veiculos_cadastrados
,in_veiculos_disp
,in_rotas_recebidas
,in_rotas_carregadas
,in_noShow
,in_distrato
,ds_noShow_nome
,ds_noShow_motivo
,ds_noShow_operacao
,in_distrato_nome
,in_distrato_motivo
-- ,ListaInsucessos

)
)AS unpvt

end 


else if @codrelatorio = 1126
	begin

	SELECT  Indicador as Indicador
			,Valor  
	FROM   
	   (
		select 
			--  IdTransportadora
			-- ,IdRota
			-- 'Endereço incorreto: 2/nDestinatário ausente: 4/nEstabelecimento fechado: 6' as ListaInsucessos
			cast(format(DataReferencia,'dd/MM') as varchar(30)) as data
			,cast(sum(cast(PacotesEntregues as int )) as varchar(30)) as  entregues
			,cast(left(round(cast(sum(cast(PacotesEntregues as int)) as decimal(10,2)) / SUM(cast(TotalPacotes as int) )*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
			,cast(sum(cast(TotalPacotes as int )) as varchar(30)) as         pacotes
			,cast(sum(case when StatusRota = 'Fechada' then 1 else 0 end ) as varchar(30)) as finalizados
			,cast(sum(case when StatusRota = 'Ativa' then 1 else 0 end ) as varchar(30)) as abertos
			,cast(sum(cast(PacotesPendentes as int)) as varchar(30)) as qtde_pendentes
			,cast(left(round(cast(sum(cast(PacotesPendentes as int)) as decimal(10,2)) / SUM(cast(TotalPacotes  as int))*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
			,cast(sum(cast(PacotesNaoEntregue as int)) as varchar(30)) as         insucessos
			--,cast(servicecenter as varchar(30)) as sigla_svc
			--,cast(Base as varchar(30)) as nome_svc


		from vw_rotas_diaatual
		where IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
		and DataReferencia = @data
		--and servicecenter = @svc
		group by DataReferencia

	   ) p  
	UNPIVOT  
	   (Valor FOR Indicador IN   
		  (  
			data
			,pacotes
			,qtde_pendentes
			,[success_delivery]
			,[perc_pendentes]
			,finalizados
			,abertos
			,insucessos 
			,entregues
			--,sigla_svc
   --         ,nome_svc
			-- ,ListaInsucessos
			)  
	)AS unpvt

	union ALL

	select 
		'lista_insucessos' as lista_insucessos
		,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
		-- ,a.qtd
	FROM
	(
		select 

			b.SubStatus
			,COUNT(*) qtd

		from vw_rotas_diaatual as a
		inner join vw_pacotes_diaatual as b
		on a.idtransportadora = b.idtransportadora
		and a.IdRota = b.IdRota

		where a.IdTransportadora in (
                        select distinct  cli_id_logistics
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
		and a.DataReferencia = @data
		--and a.servicecenter = @svc
		and StatusEntrega = 'Não Entregue'
		and b.SubStatus <> 'Transferido'
		group by b.SubStatus

	) as a

--- indicadores diarios
union ALL

SELECT  Indicador as Indicador
,Valor
FROM   
(            
       
SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as in_veiculos_cadastrados
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as in_veiculos_disp
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as in_rotas_recebidas
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as in_rotas_carregadas
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as in_noShow
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as in_distrato
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as ds_noShow_nome
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as ds_noShow_motivo
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as ds_noShow_operacao
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as in_distrato_nome
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as in_distrato_motivo
FROM (SELECT isnull(@svc,'-') AS ServiceCenter) AS Base
	outer apply (
					select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
					from [tb_indicadores_diarios] as a
						inner join tb_acessos_indicadores as b
						on a.ind_cd_base = b.aci_cd_acessos_indicadores
							and a.ind_cd_transportadora = b.aci_cd_transportadora
					where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
					and aci_cd_base = base.ServiceCenter
			  ) as a
-- and  cast(ind_dh_data as date) = @data

) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
 in_veiculos_cadastrados
,in_veiculos_disp
,in_rotas_recebidas
,in_rotas_carregadas
,in_noShow
,in_distrato
,ds_noShow_nome
,ds_noShow_motivo
,ds_noShow_operacao
,in_distrato_nome
,in_distrato_motivo
-- ,ListaInsucessos

)
)AS unpvt
	end 

	else if @codrelatorio = 1122
	begin

		--DECLARE  @transportdora INT = 20230008,
		--	@data date = '2024-04-04',
		--	@svc varchar(50) = 'LM Hub_SP_Jundiaí'

		SELECT  Indicador as Indicador
				,Valor
 
		FROM   
		   (
			select 
				--  IdTransportadora
				-- ,IdRota
				-- 'Endereço incorreto: 2/nDestinatário ausente: 4/nEstabelecimento fechado: 6' as ListaInsucessos
				cast(format(DataReferencia,'dd/MM') as varchar(30)) as data
				,cast(sum(PacotesEntregues) as varchar(30)) as entregues
				,cast(left(round(cast(sum(PacotesEntregues) as decimal(10,2)) / SUM(TotalPacotes)*100,2),5) + '%'   as varchar(30)) as   [success_delivery]
				,cast(sum(TotalPacotes) as varchar(30)) as         pacotes
				,cast(sum(case when RotaFinalizada = 1 then 1 else 0 end ) as varchar(30)) as finalizados
				,cast(sum(case when RotaFinalizada = 0 then 1 else 0 end ) as varchar(30)) as abertos
				,cast(sum(PacotesPendentes) as varchar(30)) as qtde_pendentes
				,cast(left(round(cast(sum(PacotesPendentes) as decimal(10,2)) / SUM(TotalPacotes)*100,2),5) + '%'   as varchar(30)) as   [perc_pendentes]
				,cast(sum(PacotesNaoEntregue) as varchar(30)) as         insucessos
				,cast(NomeHub as varchar(30)) as sigla_svc
    
    
			from vw_rotas_spe_v4
			where IdTransportadora in (
                        select distinct  cli_id_shopee
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
			and DataReferencia = @data
			and NomeHub = @svc
			group by DataReferencia,NomeHub

		   ) p  
		UNPIVOT  
		   (Valor FOR Indicador IN   
			  (  
				data
				,entregues
				,pacotes
				,qtde_pendentes
				,[success_delivery]
				,[perc_pendentes]
				,finalizados
				,abertos
				,insucessos 
				,sigla_svc
				-- ,ListaInsucessos
				)  
		)AS unpvt

		union all


		select 
			'lista_insucessos' as lista_insucessos
			,cast(STRING_AGG('• ' + a.SubStatus  + ': ' + cast(a.qtd as varchar(10)) + ' \n', '') as varchar(800)) as Valor
			-- ,a.qtd
		FROM
		(
			select 

				b.SubStatus
				,COUNT(*) qtd
	
			from vw_rotas_spe_v4 as a
			inner join vw_pacotes_spe_v4 as b
			on a.idtransportadora = b.idtransportadora
			and a.codigorota = b.codigorota
	
			where a.IdTransportadora in (
                        select distinct  cli_id_shopee
                        from tb_clientes 
                        where 1=1 
                        and cli_cd_codigo_cliente =  @transportdora
                        and cli_ds_logo_report  is not null
						)
			and a.DataReferencia = @data
			and a.nomehub = @svc
			and StatusEntregaShopee = 'On_Hold'
			group by b.SubStatus
	
		) as a

union all


--- indicadores diarios

SELECT  Indicador as Indicador
,Valor
FROM   
(        
   
SELECT
    cast(ind_dh_data as date) as data
    ,aci_cd_base
    ,cast(isnull([ind_in_veiculos_cadastrados]      ,0) as varchar(50)) as [in_veiculos_cadastrados]
    ,cast(isnull([ind_in_veiculos_disponibilizados] ,0) as varchar(50)) as [in_veiculos_disp]
    ,cast(isnull([ind_in_rotas_recebidas]           ,0) as varchar(50)) as [in_rotas_recebidas]
    ,cast(isnull([ind_in_rotas_carregadas]          ,0) as varchar(50)) as [in_rotas_carregadas]
    ,cast(isnull([ind_in_noShow]                    ,0) as varchar(50)) as [in_noShow]
    ,cast(isnull([ind_in_distrato]                  ,0) as varchar(50)) as [in_distrato]
    ,cast(isnull([ind_ds_noShow_nome]               ,0) as varchar(50)) as [ds_noShow_nome]
    ,cast(isnull([ind_ds_noShow_motivo]             ,0) as varchar(50)) as [ds_noShow_motivo]
    ,cast(isnull([ind_ds_noShow_operacao]           ,0) as varchar(50)) as [ds_noShow_operacao]
    ,cast(isnull([ind_in_distrato_nome]             ,0) as varchar(50)) as [in_distrato_nome]
    ,cast(isnull([ind_in_distrato_motivo]           ,0) as varchar(50)) as [in_distrato_motivo]
FROM (SELECT @svc AS ServiceCenter) AS Base
	outer apply (
					select * -- ALTRERAR PARA TRAZER APENAS OS CAMPOS NECESSÁRIOS
					from [tb_indicadores_diarios] as a
						inner join tb_acessos_indicadores as b
						on a.ind_cd_base = b.aci_cd_acessos_indicadores
							and a.ind_cd_transportadora = b.aci_cd_transportadora
					where cast(ind_dh_data as date) = @data
                    and ind_cd_transportadora = @transportdora
					and aci_cd_base = base.ServiceCenter
			  ) as a
-- and  cast(ind_dh_data as date) = @data

) p  
UNPIVOT  
(Valor FOR Indicador IN   
(  
 [in_veiculos_cadastrados]
,[in_veiculos_disp]
,[in_rotas_recebidas]
,[in_rotas_carregadas]
,[in_noShow]
,[in_distrato]
,[ds_noShow_nome]
,[ds_noShow_motivo]
,[ds_noShow_operacao]
,[in_distrato_nome]
,[in_distrato_motivo]
-- ,ListaInsucessos

)
)AS unpvt


	end 




GO
