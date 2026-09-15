-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaIndicadoresRotaV5
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaIndicadoresRotaV5]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEAtualizaIndicadoresRotaV5] (
	@QtdeDiasRetroativo int = 90
)
as
begin

	SET NOCOUNT ON;

----excluid as rotas do dia anterior
--drop table if exists #base
--select * 
--into #base
--from tb_spe_rotas_v5
--where 1=1 
--	and codigorota in ( 
--    select codigorota  from vw_pacotes_spe_v4 
--    where  DataReferencia = CAST(getdate()-@QtdeDiasRetroativo as date)
--    and StatusEntrega = 'Pendente'
--    )
--	and DataReferencia = CAST(getdate()-@QtdeDiasRetroativo as date)
--	and excluido = 0


 --insert into tb_spe_rotas_v5
 --(

 --CodigoRota
 --,IdTransportadora
 --,DataReferencia
 --,DataHoraInicio
 --,DataHoraFim
 --,DataHoraColeta
 --,IdStation
 --,IdMotorista
 --,IdStatus
 --,DataAtualizacao
 --,Excluido
 --,TotalPacotes
 --,PacotesEntregues
 --,PacotesNaoEntregue
 --,PacotesPendentes
 --,DataUltimaEntrega
 --,KmColetado
 --,LinkMapa
 --,TipoVeiculo
 --,DataHoraCarga
 --,Paradas
 --,CidadeReferencia
 --,DistanciaTotal
 --)
 --select 
 --	 a.CodigoRota
 --	,a.IdTransportadora
 --	,CAST(getdate() as date) as DataReferencia
 --	,a.DataHoraInicio
 --	,a.DataHoraFim
 --	,a.DataHoraColeta
 --	,a.IdStation
 --	,a.IdMotorista
 --	,a.IdStatus
 --	,getdate() as DataAtualizacao
 --	,0 Excluido
 --	,a.TotalPacotes
 --	,a.PacotesEntregues
 --	,a.PacotesNaoEntregue
 --	,a.PacotesPendentes
 --	,a.DataUltimaEntrega
 --	,a.KmColetado
 --	,a.LinkMapa
 --	,a.TipoVeiculo
 --	,a.DataHoraCarga
 --	,a.Paradas
 --	,a.CidadeReferencia
 --	,a.DistanciaTotal

 --from #base as a
 --left join tb_spe_rotas_v5 as b
 --on a.codigorota = b.codigorota
 --and dateadd(day,1,a.datareferencia) =  b.datareferencia 

 --where b.datareferencia is null


 --update a
 --set Excluido = 1

 --from tb_spe_rotas_v5 as a
 --inner join #base as b
 --on a.CodigoRota = b.CodigoRota
 --and a.DataReferencia = b.DataReferencia




--atualiza os indicadores
	update
		r
	set
		r.TotalPacotes = isnull(p.TotalPacotes,0),
		r.PacotesEntregues = isnull(p.PacotesEntregues,0),
		r.PacotesNaoEntregue = p.PacotesNaoEntregue,
		r.PacotesPendentes = p.PacotesPendentes,
		r.DataUltimaEntrega = p.DataUltimaEntrega,
		r.TipoOperacao = 'LM'

	from
		tb_spe_rotas_v5 r
		inner join (
			select
				p.IdTransportadora,
			--	p.DataReferencia,
				p.CodigoRota,
				count(1) TotalPacotes,          
				sum(case when p.StatusEntrega = 'Delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when p.StatusEntrega in ('On Hold','On_Hold', 'Cancelled', 'OnHold') then 1 else 0 end) PacotesNaoEntregue,
				sum(case when p.StatusEntrega in( 'Delivering','Assigned') then 1  when p.StatusEntrega like '%Return_%'  then 1  else 0 end) PacotesPendentes,
				max(case when p.StatusEntrega = 'Delivered' then p.DataHoraEntrega end) DataUltimaEntrega
			from
				tb_spe_pacotes_v5 p with(nolock)
			where
				p.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
				and Excluido = 0
				and isnull(p.SubStatus,'') <> 'transferred'
              
			group by
				p.IdTransportadora,
			--	p.DataReferencia,
				p.CodigoRota
		) p on r.IdTransportadora = p.IdTransportadora  and r.CodigoRota = p.CodigoRota
	where
		r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
		and Excluido = 0


	--atualiza os indicadores LH
	update
		r
	set
		r.TotalPacotes = isnull(lh.TotalPacotes,0),
		r.PacotesEntregues = isnull(lh.TotalPacotes,0),
		r.TipoOperacao = 'LH'
	from  tb_spe_rotas_v5 r with(nolock)
	inner  join (
        	select  IdTransportadora
          	  ,  CodigoRota
          	  ,  count(CodigoPacote) TotalPacotes
        	from  tb_spe_pacotes_lh with(nolock)
        	group  by  IdTransportadora
          	  ,  CodigoRota
      	  ) lh
    	on r.IdTransportadora = lh.IdTransportadora  and r.CodigoRota = lh.CodigoRota
	where
    	r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
    	and Excluido = 0  


	--atualiza os indicadores FM
	update
		r
	set
		r.TotalPacotes = isnull(fm.TotalPacotes,0),
		r.PacotesEntregues = isnull(fm.TotalPacotes,0),
		r.TipoOperacao = 'FM'
	from  tb_spe_rotas_v5 r with(nolock)
	inner  join (
				select	distinct	IdTransportadora
						,	cast(CodigoRota as varchar) CodigoRota
						,	count(CodigoPacote) TotalPacotes
				from	tb_spe_pacotes_FM as a with(nolock)
				where	Excluido = 0
				group	by	IdTransportadora
						,	CodigoRota
			
			) fm
    	on r.IdTransportadora = fm.IdTransportadora and r.CodigoRota = fm.CodigoRota
	where
    	r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
    	and Excluido = 0  


end


GO
