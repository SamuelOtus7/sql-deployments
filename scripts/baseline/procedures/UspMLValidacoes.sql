-- ============================================================
-- BASELINE: dbo.UspMLValidacoes
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspMLValidacoes]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UspMLValidacoes]
as 
begin

	SET NOCOUNT ON;

	--Verifica se anda existe algum pacote ou rota para sempre processados
	select count(1) from db_Irisys_Json.dbo.tb_ml_coleta_totalizador with(nolock) where cmt_in_processado = 0
	select count(1) from db_Irisys_Json.dbo.tb_ml_coleta_rotas with(nolock) where cmr_in_processado = 0


	--Confere se existe alguma rota coletada que não foi para a tabela de pacotes
	select
		coleta.cmr_cd_coleta,
		coleta.cmr_ds_json,
		coleta.cmr_cd_transportadora,
		coleta.cmr_cd_rota,
		coleta.cmr_dh_coleta,
		coleta.cmt_dh_processamento,
		coleta.cmr_in_processado
	from
		db_Irisys_Json.dbo.tb_ml_coleta_rotas coleta with(nolock)
		left join tb_ml_pacotes pacotes with(nolock) on coleta.cmr_cd_rota = pacotes.IdRota 
									and coleta.cmr_cd_transportadora = pacotes.IdTransportadora
									and cmr_dh_referencia = pacotes.DataReferencia
	where
		coleta.cmr_in_processado = 1
		and coleta.cmr_dh_referencia < cast(getdate() as date)
		and pacotes.Id is null


	--Confere se existe algum pacote em que a rota não existe na tabela de rotas
	select
		distinct
		pacote.IdRota,
		pacote.IdTransportadora,
		pacote.DataReferencia
	from
		tb_ml_pacotes pacote with(nolock)
		left join tb_ml_rotas rotas with(nolock) on pacote.IdRota = rotas.IdRota 
									and pacote.IdTransportadora = rotas.IdTransportadora
									and pacote.DataReferencia = rotas.DataReferencia
	where
		rotas.Id is null
		and pacote.DataReferencia < cast(getdate() as date)


	--Confere se existe alguma rota sem pacote
	select
		distinct
		rotas.IdRota,
		rotas.IdTransportadora,
		rotas.DataReferencia
	from
		tb_ml_rotas rotas with(nolock)
		left join tb_ml_pacotes pacote with(nolock) on rotas.IdRota = pacote.IdRota 
									and rotas.IdTransportadora = pacote.IdTransportadora
									and rotas.DataReferencia = pacote.DataReferencia
									and pacote.Excluido = 0
	where
		pacote.Id is null
		and rotas.Excluido = 0
	

	--Confere se existe service center não cadastrado
	select
		distinct ServiceCenter
	from
		tb_ml_rotas rotas with(nolock)
		left join tb_ml_service_center_teste svc on rotas.ServiceCenter = svc.svc_cd_service_center  and rotas.idtransportadora = svc.idtransportadora
	where
		svc.svc_cd_service_center is null

	--Confere se a quantidade de pacotes registrado na rota bate com o que tem em pacotes
	select
		r.IdRota,
		r.DataReferencia
	from
		tb_ml_rotas r
		left join (
			select
				IdRota,
				DataReferencia,
				count(1) Pacotes,
				sum(case when StatusEntrega = 'delivered' then 1 else 0 end) PacotesEntregues,
				sum(case when StatusEntrega = 'pending' then 1 else 0 end) PacotesPendentes,
				sum(case when StatusEntrega = 'not_delivered' then 1 else 0 end) PacotesNaoEntregues
			from
				tb_ml_pacotes
			where
				DataReferencia between '2023-02-06' and '2023-02-08'
			group by
				IdRota,
				DataReferencia
		) p on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia
	where
		r.DataReferencia between '2023-02-06' and '2023-02-08'
		and 
			(
				r.TotalPacotes <> isnull(p.Pacotes,0)
				or 
				r.PacotesEntregues <> isnull(p.PacotesEntregues,0)
				or 
				r.PacotesPendentes <> isnull(p.PacotesPendentes,0)
				or 
				r.PacotesNaoEntregue <> isnull(p.PacotesNaoEntregues,0)
			)

	--Confere rota excluida mas com pacotes não excluídos
	select
		top 100
		p.*
	from
		tb_ml_rotas r
		join tb_ml_pacotes p on r.IdRota = p.IdRota and r.DataReferencia = p.DataReferencia
	where
		r.Excluido = 1 and p.Excluido = 0
		and r.DataReferencia = cast(getdate() as date)
	order by
		p.Id desc

	select
		*
	from
		tb_ml_rotas
	where
		IdRota=82739413
		and DataReferencia = '2023-02-14'

	select
		*,
		case when cmt_ds_json like '%82739413%' then 1 else 0 end TemRota
	from
		db_Irisys_Json.dbo.tb_ml_coleta_totalizador
	where
		cmt_cd_servicecenter = 'SMG8'
		and cmt_dh_referencia = '2023-02-14'
	order by
		cmt_cd_coleta

	select
		*,
		case when cmr_ds_json like '%42030752222%' then 1 else 0 end TemPacote
	from
		db_Irisys_Json.dbo.tb_ml_coleta_rotas
	where
		cmr_cd_rota = 82739413
		and cmr_dh_referencia = '2023-02-14'
	order by
		cmr_cd_coleta

end
GO
