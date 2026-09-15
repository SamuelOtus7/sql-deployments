-- ============================================================
-- BASELINE: dbo.UspSPEAtualizaRotasPendentes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspSPEAtualizaRotasPendentes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[UspSPEAtualizaRotasPendentes] as 


--leva as rotas para o dia seguinte as rotas que tiveram pendentes 

	-- SET NOCOUNT on;
declare @QtdeDiasRetroativo int = 1


drop table if exists #base
select * 
into #base
from tb_spe_rotas_v5
where 1=1 
	and DataReferencia = CAST(getdate()-@QtdeDiasRetroativo as date)
	and PacotesPendentes > 0
    and excluido = 0
    -- and CodigoRota = 'AT202502160ZRJ7'


 insert into tb_spe_rotas_v5
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
 	,getdate() as DataAtualizacao
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
 left join tb_spe_rotas_v5 as b
 on a.codigorota = b.codigorota
 and dateadd(day,1,a.datareferencia) =  b.datareferencia 

 where b.datareferencia is null


 update a
 set Excluido = 1

 from tb_spe_rotas_v5 as a
 inner join #base as b
 on a.CodigoRota = b.CodigoRota
 and a.DataReferencia = b.DataReferencia

GO
