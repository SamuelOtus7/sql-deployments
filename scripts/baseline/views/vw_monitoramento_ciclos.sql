-- ============================================================
-- BASELINE: dbo.vw_monitoramento_ciclos
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_ciclos]    Script Date: 14/09/2026 12:12:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[vw_monitoramento_ciclos]

as
select base.*,
	   svc.ColetasPorMinutoTotalizadores
from (
		select b.ServiceCenter,
			   t.tpr_nome_transportadora Transportadora,
			   min(b.DataAtualizacao) as AtualizacaoRotaMaisAntiga,
			   max(b.DataAtualizacao) as AtualizacaoRotaMaisRecente,
			   min(a.DataAtualizacao) as AtualizacaoPacoteMaisAntiga,
			   max(a.DataAtualizacao) as AtualizacaoPacoteMaisRecente,
			   convert(varchar,dateadd(SECOND,datediff(second,min(b.DataAtualizacao),getdate()),0),108) as DuracaoCicloRota,
			   convert(varchar,dateadd(SECOND,datediff(second,min(a.DataAtualizacao),getdate()),0),108) as DuracaoCicloPacote,
			   count(distinct B.IdRota) as Rotas,
			   count(distinct a.IdPacote) as Entregas,
			   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(b.DataAtualizacao),GETDATE()),0),108) as TempoSemColetaRota,
			   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(a.DataAtualizacao),GETDATE()),0),108) as TempoSemColetaPacote,
			   sum(c.ColetasPorMinutoRotas) as ColetasPorMinutoRotas
		from 
			tb_ml_rotas b  with(nolock) 
			left join tb_ml_pacotes a with(nolock) on a.IdRota = b.IdRota and a.Excluido = 0 and a.DataReferencia = b.DataReferencia
			left join tb_dra_transportadora t on b.IdTransportadora = t.tpr_cd_transportadora
			left join (
						select cmr_cd_rota as IdRota,
							   COUNT(*) as Coletas,
							   MAX(cmr_dh_escrita) as UltimaColeta,
							   MIN(cmr_dh_escrita) as PrimeiraColeta   ,
							   case when DATEDIFF(second, MIN(cmr_dh_escrita), MAX(cmr_dh_escrita)) > 0 
									then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(cmr_dh_escrita), MAX(cmr_dh_escrita)) as float) * 60.0
							   else 1 end as ColetasPorMinutoRotas,
							   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(cmr_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
							   DATEDIFF(SECOND,MAX(cmr_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
						from db_Irisys_Json.dbo.tb_ml_coleta_rotas (nolock)
						where cast(cmr_dh_escrita as date)= CAST(getdate() as date)
						group by cmr_cd_rota
					  ) c 
			on b.IdRota = c.IdRota
		where b.DataReferencia = cast(getdate() as date)
		and b.Excluido = 0
		and isnull(a.SubStatus,'') <> 'transferred'
		group by b.ServiceCenter,t.tpr_nome_transportadora
	) as base
left join (
				select cmt_cd_servicecenter as ServiceCenter,
					   COUNT(*) as Coletas,
					   MAX(cmt_dh_escrita) as UltimaColeta,
					   MIN(cmt_dh_escrita) as PrimeiraColeta   ,
					   case when DATEDIFF(second, MIN(cmt_dh_escrita), MAX(cmt_dh_escrita)) > 0 
							then CAST(COUNT(*) as float) / CAST(DATEDIFF(second, MIN(cmt_dh_escrita), MAX(cmt_dh_escrita)) as float)
					   end * 60.0 as ColetasPorMinutoTotalizadores,
					   convert(varchar,dateadd(second,DATEDIFF(SECOND,MAX(cmt_dh_escrita),GETDATE()),0),108) as TempoDesdeAUltimaColeta,
					   DATEDIFF(SECOND,MAX(cmt_dh_escrita),GETDATE()) as SegundosDesdeAUltimaColeta
				from db_Irisys_Json.dbo.tb_ml_coleta_totalizador (nolock)
				where cast(cmt_dh_escrita as date) = CAST(getdate() as date)
				group by cmt_cd_servicecenter
			  ) svc
	on base.ServiceCenter = svc.ServiceCenter

GO
