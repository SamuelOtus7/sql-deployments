-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaIndicadoresRotaV4
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaIndicadoresRotaV4]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[UspSPEAtualizaIndicadoresRotaV4] (
	@QtdeDiasRetroativo int = 1
)
as
begin

	SET NOCOUNT ON;

	
--excluid as rotas do dia anterior
drop table if exists #base
select * 
into #base
from tb_spe_rotas_v4
where 1=1 
	--and IdTransportadora = 20230010
	and TotalPacotes = 0
	and PacotesPendentes is null
	and DataReferencia = CAST(getdate()-@QtdeDiasRetroativo as date)
	and excluido = 0



insert into tb_spe_rotas_v4
(

CodigoRota
,IdTransportadora
,DataReferencia
,DataHoraInicio
,DataHoraFim
,DataHoraColeta
,IdStation
,IdMotorista
,IdStatus
,DataAtualizacao
,Excluido
,TotalPacotes
,PacotesEntregues
,PacotesNaoEntregue
,PacotesPendentes
,DataUltimaEntrega
,KmColetado
,LinkMapa
,TipoVeiculo
,DataHoraCarga
,Paradas
,CidadeReferencia
,DistanciaTotal
)
select 
	 a.CodigoRota
	,a.IdTransportadora
	,CAST(getdate() as date) as DataReferencia
	,a.DataHoraInicio
	,a.DataHoraFim
	,a.DataHoraColeta
	,a.IdStation
	,a.IdMotorista
	,a.IdStatus
	,a.DataAtualizacao
	,0 Excluido
	,a.TotalPacotes
	,a.PacotesEntregues
	,a.PacotesNaoEntregue
	,a.PacotesPendentes
	,a.DataUltimaEntrega
	,a.KmColetado
	,a.LinkMapa
	,a.TipoVeiculo
	,a.DataHoraCarga
	,a.Paradas
	,a.CidadeReferencia
	,a.DistanciaTotal

from #base as a
left join tb_spe_rotas_v4 as b
on a.codigorota = b.codigorota
and dateadd(day,1,a.datareferencia) =  b.datareferencia 

where b.datareferencia is null
and b.excluido = 0

update a
set Excluido = 1
from tb_spe_rotas_v4 as a
inner join #base as b
on a.CodigoRota = b.CodigoRota
and a.DataReferencia = b.DataReferencia




--reativa e leva para o dia seguinte as rotas do dia anteiror
drop table if exists #rotaexistentes
SELECT distinct codigorota, dateadd(day,-1,datareferencia) as datareferencia
into #rotaexistentes
FROM tb_spe_rotas_v4 
where datareferencia =  cast(getdate() as date)
--and codigorota = 'AT2024060621RI3'
and codigorota in (
					SELECT 
						distinct 
						codigorota  

					FROM tb_spe_pacotes_v4 
					where 1=1
					--and codigorota = 'AT2024060521BUR'
					and datareferencia = cast(getdate() as date)
					and StatusEntrega = 'Delivered'
					)

insert into tb_spe_rotas_v4
(

CodigoRota
,IdTransportadora
,DataReferencia
,DataHoraInicio
,DataHoraFim
,DataHoraColeta
,IdStation
,IdMotorista
,IdStatus
,DataAtualizacao
,Excluido
,TotalPacotes
,PacotesEntregues
,PacotesNaoEntregue
,PacotesPendentes
,DataUltimaEntrega
,KmColetado
,LinkMapa
,TipoVeiculo
,DataHoraCarga
,Paradas
,CidadeReferencia
,DistanciaTotal
)
SELECT 
	a.CodigoRota
	,a.IdTransportadora
	,cast(getdate() as date) as DataReferencia
	,a.DataHoraInicio
	,a.DataHoraFim
	,a.DataHoraColeta
	,a.IdStation
	,a.IdMotorista
	,a.IdStatus
	,a.DataAtualizacao
	,0 Excluido
	,a.TotalPacotes
	,a.PacotesEntregues
	,a.PacotesNaoEntregue
	,a.PacotesPendentes
	,a.DataUltimaEntrega
	,a.KmColetado
	,a.LinkMapa
	,a.TipoVeiculo
	,a.DataHoraCarga
	,a.Paradas
	,a.CidadeReferencia
	,a.DistanciaTotal

FROM tb_spe_rotas_v4 as a

left join  #rotaexistentes as b
on a.codigorota = b.codigorota
and a.datareferencia = b.datareferencia 

where a.datareferencia = cast(getdate()-1 as date)
and a.datareferencia = a.datahorainicio
and a.excluido = 1
and b.codigorota is null
--and a.codigorota = 'AT2024060521BUR'
and a.codigorota in (
					SELECT 
						distinct 
						codigorota  

					FROM tb_spe_pacotes_v4 
					where 1=1
					--and codigorota = 'AT2024060521BUR'
					and datareferencia = cast(getdate() as date)
					and StatusEntrega = 'Delivered'
					);

/*
drop table if exists #reativarota 
select distinct
	 a.codigorota
	,a.IdTransportadora
	,a.datareferencia

	into #reativarota

from tb_spe_pacotes_v4  as a

left join vw_rotas_spe_v4 as b
on a.codigorota = b.codigorota

where  1=1
and a.datareferencia >= '2024-06-01'
--and a.codigorota = 'AT202405301Y9DT' 
and a.StatusEntrega <> 'Assigned' 
and a.Excluido = 0
and b.codigorota is null


insert into tb_spe_rotas_v4

select
	 a.CodigoRota
	,a.IdTransportadora
	,b.DataReferencia
	,a.DataHoraInicio
	,a.DataHoraFim
	,a.DataHoraColeta
	,a.IdStation
	,a.IdMotorista
	,a.IdStatus
	,a.DataAtualizacao
	,a.Excluido
	,a.TotalPacotes
	,a.PacotesEntregues
	,a.PacotesNaoEntregue
	,a.PacotesPendentes
	,a.DataUltimaEntrega
	,a.KmColetado
	,a.LinkMapa
	,a.TipoVeiculo
	,a.DataHoraCarga
	,a.Paradas
	,a.CidadeReferencia
	,a.DistanciaTotal

from tb_spe_rotas_v4 as a
inner join #reativarota as b
on a.CodigoRota = b.CodigoRota
--and a.DataReferencia = b.DataReferencia

--where a.codigorota = 'AT2024060823DJW'


update a
set a.excluido = 1
from tb_spe_rotas_v4 as a
inner join #reativarota as b
on a.CodigoRota = b.CodigoRota
and a.DataReferencia <> b.DataReferencia
*/





--atualiza os indicadores
	update
		r
	set
		r.TotalPacotes = isnull(p.TotalPacotes,0),
		r.PacotesEntregues = isnull(p.PacotesEntregues,0),
		r.PacotesNaoEntregue = p.PacotesNaoEntregue,
		r.PacotesPendentes = p.PacotesPendentes,
		r.DataUltimaEntrega = p.DataUltimaEntrega

	from
		tb_spe_rotas_v4 r
		left join (
			select
				p.IdTransportadora,
				p.DataReferencia,
				p.CodigoRota,
				count(1) TotalPacotes,
				sum(case when p.StatusEntrega = 'Delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when p.StatusEntrega in ('On Hold','On_Hold', 'Cancelled') then 1 else 0 end) PacotesNaoEntregue,
				sum(case when p.StatusEntrega = 'Assigned' then 1 else 0 end) PacotesPendentes,
				max(case when p.StatusEntrega = 'Delivered' then p.DataHoraEntrega end) DataUltimaEntrega
			from
				tb_spe_pacotes_v4 p with(nolock)
			where
				p.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
				and Excluido = 0
				and isnull(p.SubStatus,'') <> 'transferred'
			group by
				p.IdTransportadora,
				p.DataReferencia,
				p.CodigoRota
		) p on r.IdTransportadora = p.IdTransportadora and r.DataReferencia = p.DataReferencia and r.CodigoRota = p.CodigoRota
	where
		r.DataReferencia >= dateadd(day,-@QtdeDiasRetroativo,cast(getdate() as date))
		and Excluido = 0


	


end
GO
