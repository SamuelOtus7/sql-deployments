-- ============================================================
-- BASELINE: dbo.UspMLReprocessarRotas_bkp
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLReprocessarRotas_bkp]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLReprocessarRotas_bkp]
as 
begin

	SET NOCOUNT ON;

	truncate table tb_rotas_para_reprocessar

	--Atualiza delta indicadores
	exec [UspMLAtualizaDeltaIndicadoresRotas] 5


	--Insere rotas que manteve diferença nos indicadores ou que não foram finalizadas
	insert into tb_rotas_para_reprocessar (IdRota, DataReferencia, IdTransportadora)

	select 
		r.IdRota,
		r.DataReferencia as DataReferencia,
		r.IdTransportadora as IdTransportadora
	from
		tb_ml_rotas r --with(nolock)
		inner join (select IdRota,max(DataReferencia) as ultima from tb_ml_rotas where Excluido = 0 group by IdRota) as ultimo
		on r.IdRota = ultimo.IdRota and r.DataReferencia = ultimo.ultima
		left join (
			select
				IdRota,
				DataReferencia,
				IdTransportadora,
				count(1) Pacotes,
				sum(case when StatusEntrega = 'delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when StatusEntrega = 'pending' then 1 else 0 end) PacotesPendentes,
				sum(case when StatusEntrega = 'not_delivered' and isnull(SubStatus,'') <> 'transferred' then 1 else 0 end) PacotesNaoEntregues,
				sum(case when StatusEntrega = 'not_delivered' and isnull(SubStatus,'') = 'transferred' then 1 else 0 end) PacotesTransferidos
			from
				tb_ml_pacotes with(nolock)
			where
				DataReferencia < cast(getdate() as date)
				and Excluido = 0
			group by
				IdRota,
				DataReferencia,
				IdTransportadora
		) p on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia and r.IdTransportadora = p.IdTransportadora
		left join db_Irisys_Json.dbo.tb_ml_coleta_rotas c with(nolock) on r.IdRota = c.cmr_cd_rota 
										and r.DataReferencia = c.cmr_dh_referencia
										and r.IdTransportadora = c.cmr_cd_transportadora
										and c.cmr_dh_escrita >= cast(getdate() as date)
	where
		--(r.DataReferencia >= '2023-04-16' or r.IdTransportadora in(834780814,1491631999)) and
		r.DataReferencia >= cast(getdate()-10 as date)
		--and r.IdRota = 177370656
		and c.cmr_cd_coleta is null
		and r.StatusRota <> 'planned'
		and 
			(
				r.TotalPacotes <> isnull(p.Pacotes,0)
				or 
				r.PacotesEntregues <> isnull(p.PacotesEntregues,0)
				or 
				r.PacotesPendentes <> isnull(p.PacotesPendentes,0)
				or 
				r.PacotesNaoEntregue <> isnull(p.PacotesNaoEntregues,0)
				or 
				r.PacotesTransferidos <> isnull(p.PacotesTransferidos,0)
				or
				r.TotalPacotes <> r.PacotesEntregues + r.PacotesNaoEntregue + r.PacotesTransferidos
			)

	--insere rotas não encontradas na pre fatura
	insert into tb_rotas_para_reprocessar (IdRota, DataReferencia, IdTransportadora)
	select 
		distinct 
		prefatura.IdRota, 
		prefatura.DataInicio DataReferencia,
		prefatura.IdTransportadora
	from 
		tb_fin_prefatura prefatura with(nolock)
		left join tb_ml_rotas rotas with(nolock) on prefatura.IdRota = rotas.IdRota
	where
		rotas.IdRota is null
		and prefatura.DataInicio >= '2025-03-01'
		

	--insert into tb_rotas_para_reprocessar (IdRota, DataReferencia, IdTransportadora)
	--select
	--	distinct
	--	pacote.IdRota,
	--	pacote.DataReferencia,
	--	pacote.IdTransportadora
	--from
	--	tb_ml_pacotes pacote with(nolock)
	--	left join tb_ml_rotas rotas with(nolock) on pacote.IdRota = rotas.IdRota 
	--								and pacote.IdTransportadora = rotas.IdTransportadora
	--								and pacote.DataReferencia = rotas.DataReferencia
	--								and rotas.Excluido = 0
	--where
	--	rotas.Id is null
	--	and pacote.Excluido = 0
	--	and pacote.DataReferencia < cast(getdate() as date)
	
insert into tb_rotas_para_reprocessar
select 
		a.route_id IdRota,
		a.date_data as DataReferencia,
		a.idtransportadora as IdTransportadora
from [dbo].[tb_ml_historico_rotas_meli] as a
left join (
    select
        idrota 
        ,datareferencia
        ,IdTransportadora
    from  tb_ml_pacotes
    where Excluido = 0 
    group by idrota,datareferencia,IdTransportadora
)as b 
on a.route_id = b.idrota 
and a.date_data = b.datareferencia
and a.IdTransportadora = b.IdTransportadora
where b.idrota is null
and a.route_id <> a.IdTransportadora -- Correção de carregamento errado na tabela 
--===================================================
--Foi identificado que rotas estão sendo enviadas para outro transportador, avaliar comentário acima
--===================================================



insert into tb_rotas_para_reprocessar

select distinct 
IdRota	
,DataReferencia
,IdTransportadora	
 from tb_ml_pacotes a
  join tb_Clientes b
 on a.idtransportadora = b.cli_id_logistics
 where idrota in(
select idrota 
from tb_ml_rotas nolock 
where datareferencia >= getdate()-3
and PacotesPendentes > 0
and Excluido = 0
--and idtransportadora in (652375997
--,1871738758
--,472463006
--,124442948
--,446666723
--,2030412272
--,2130011770
--,244041012
--,643493085)
 and StatusRota <> 'planned'  )
 and cli_in_ativo = 1
 and cli_ds_nome not in ('Torres Transportes','Eco Express') -- Clientes ativos que estão saindo


end
GO
