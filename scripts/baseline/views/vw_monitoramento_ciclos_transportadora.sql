-- ============================================================
-- BASELINE: dbo.vw_monitoramento_ciclos_transportadora
-- Tipo: View
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  View [dbo].[vw_monitoramento_ciclos_transportadora]    Script Date: 14/09/2026 12:12:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_monitoramento_ciclos_transportadora]

as

select top 1000 
	   cli_cd_codigo_cliente as CodigoCliente,
	   cli_ds_nome as Cliente,
	   cli_id_logistics as CodigoLogistics,
	   TotalizadorUltimaAtualizacao,
	   TotalizadorMinutosSemColetar,
	   TotalizadorMinutosSemEscrever,
	   RotasUltimaAtualizacao,
	   RotasMinutosSemColetar,
	   RotasMinutosSemEscrever
from tb_clientes as cli with(nolock)
	left join (
			select isnull(totalizador.cmt_cd_transportadora,rotas.cmr_cd_transportadora) as idtransportadora,
				   totalizador.UltimaAtualizacao as TotalizadorUltimaAtualizacao,
				   totalizador.MinutosSemColetar as TotalizadorMinutosSemColetar,
				   totalizador.MinutosSemEscrever as TotalizadorMinutosSemEscrever,
				   rotas.UltimaAtualizacao  as RotasUltimaAtualizacao,
				   rotas.MinutosSemColetar  as RotasMinutosSemColetar,
				   rotas.MinutosSemEscrever as RotasMinutosSemEscrever
			from
				(
					SELECT 
						cmt_cd_transportadora
						,dateadd(hh,-3,max(cmt_dh_coleta)) as UltimaAtualizacao
						,datediff(minute,dateadd(hh,-3,max(cmt_dh_coleta)),getdate()) as MinutosSemColetar
						,datediff(minute,max(cmt_dh_escrita),getdate()) as MinutosSemEscrever
					FROM 
						db_Irisys_Json.dbo.tb_ml_coleta_totalizador as a WITH (nolock)
					WHERE 
						cmt_dh_referencia >= cast(getdate() as date)
					group by cmt_cd_transportadora
				) as totalizador
				full join (
					SELECT 
						cmr_cd_transportadora
						,dateadd(hh,-3,max(cmr_dh_coleta)) as UltimaAtualizacao
						,datediff(minute,dateadd(hh,-3,max(cmr_dh_coleta)),getdate()) as MinutosSemColetar
						,datediff(minute,max(cmr_dh_escrita),getdate()) as MinutosSemEscrever
					FROM 
						db_Irisys_Json.dbo.tb_ml_coleta_rotas as a WITH (nolock)
					WHERE 
						cmr_dh_referencia >= cast(getdate() as date)
					group by cmr_cd_transportadora
				) as rotas
				on totalizador.cmt_cd_transportadora = rotas.cmr_cd_transportadora
		) as base
	on cli.cli_id_logistics = base.idtransportadora
where cli_in_ativo = 1 
	  and cli_ds_nome <> 'Otus7'
order by TotalizadorUltimaAtualizacao
GO
