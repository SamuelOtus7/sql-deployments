-- ============================================================
-- BASELINE: dbo.vw_prefatura_50mais
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_prefatura_50mais]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vw_prefatura_50mais]
as
select 
	'MELI' Cliente
	,p.Veiculo + case when p.ContinuacaoVeiculo is not null then ' - ' + p.ContinuacaoVeiculo else '' end Descricao
	,case when p.Mes < 10 then '0' else '' end + cast(p.Mes as varchar(2)) + 'Q0' + cast(p.Quinzena as varchar(1)) Competencia
	,'Diaria' Operacao
	,p.ServiceCenter Hub
	,p.IdRota Rota
	,p.DataTermino DataFaturamento
	,p.Total FreteRecebido
	,s.svc_nm_cidade Localidade
	,'LM' TipoServico
	,p.DataAtualizacao
	,p.CicloPM
	,p.IntervaloFaixa
	,p.Dia
	,p.Placa
	,p.Motorista
	,p.Kmciclo
	,case when p.KmCiclo like '%AMBULANCE%' then 'Sim' else 'Não' end Ambulancia
from 
	tb_fin_prefatura p with(nolock)
	left join tb_ml_service_center s on p.ServiceCenter = s.svc_cd_service_center and p.IdTransportadora = s.idtransportadora
where 
	p.IdTransportadora = 1726310024 

union all

select 
	'MELI' Cliente
	,p.Veiculo + case when p.ContinuacaoVeiculo is not null then ' - ' + p.ContinuacaoVeiculo else '' end Descricao
	,case when p.Mes < 10 then '0' else '' end + cast(p.Mes as varchar(2)) + 'Q0' + cast(p.Quinzena as varchar(1)) Competencia
	,'Parada' Operacao
	,p.ServiceCenter Hub
	,p.IdRota Rota
	,p.DataTermino DataFaturamento
	,p.VLParada FreteRecebido
	,s.svc_nm_cidade Localidade
	,'LM' TipoServico
	,p.DataAtualizacao
	,p.CicloPM
	,p.IntervaloFaixa
	,p.Dia
	,p.Placa
	,p.Motorista
	,p.Kmciclo
	,case when p.KmCiclo like '%AMBULANCE%' then 'Sim' else 'Não' end Ambulancia
from 
	tb_fin_prefatura p with(nolock)
	left join tb_ml_service_center s on p.ServiceCenter = s.svc_cd_service_center and p.IdTransportadora = s.idtransportadora
where 
	p.IdTransportadora = 1726310024 
	and p.Parada is not null

union all

select 
	'MELI' Cliente
	,p.Descricao + case when p.IdPacote is not null then ': ' + cast(p.IdPacote as varchar) else '' end Descricao
	,case when p.Mes < 10 then '0' else '' end + cast(p.Mes as varchar(2)) + 'Q0' + cast(p.Quinzena as varchar(1)) Competencia
	,'Penalty' Operacao
	,r.ServiceCenter Hub
	,p.IdRota Rota
	,p.DataReferencia DataFaturamento
	,p.Total*-1 FreteRecebido
	,s.svc_nm_cidade Localidade
	,'LM' TipoServico
	,p.DataAtualizacao
	,null CicloPM
	,null IntervaloFaixa
	,null Dia
	,null Placa
	,p.Motorista
	,null Kmciclo
	,null Ambulancia
from 
	tb_fin_prefatura_descontos p with(nolock)
	left join vw_rotas r on p.IdRota = r.IdRota and p.IdTransportadora = r.IdTransportadora
	left join tb_ml_service_center s on r.ServiceCenter = s.svc_cd_service_center and r.IdTransportadora = s.idtransportadora
where 
	p.IdTransportadora = 1726310024 

union all

select 
	'MELI' Cliente
	,p.TipoVeiculo Descricao
	,case when p.Mes < 10 then '0' else '' end + cast(p.Mes as varchar(2)) + 'Q0' + cast(p.Quinzena as varchar(1)) Competencia
	,'Diaria' Operacao
	,p.ServiceCenter Hub
	,p.IdRota Rota
	,p.DataTermino DataFaturamento
	,p.Total FreteRecebido
	,s.svc_nm_cidade Localidade
	,'LH' TipoServico
	,null DataAtualizacao
	,null CicloPM
	,null IntervaloFaixa
	,p.Dia
	,p.Placa
	,p.Motorista
	,null Kmciclo
	,null Ambulancia
from 
	tb_fin_lh_prefatura p with(nolock)
	left join tb_ml_service_center s on p.ServiceCenter = s.svc_cd_service_center and p.IdTransportadora = s.idtransportadora
where 
	p.IdTransportadora = 1726310024 
	
GO
