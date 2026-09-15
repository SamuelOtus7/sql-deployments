-- ============================================================
-- BASELINE: dbo.UspExpurgoColetas
-- Tipo: StoredProcedure
-- Schema: dbo
-- Origem: Dump SSMS db_Irisys.sql (14/09/2026)
-- ============================================================
/****** Object:  StoredProcedure [dbo].[UspExpurgoColetas]    Script Date: 14/09/2026 12:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[UspExpurgoColetas]
as 
begin
	--Atualiza a tabela de histórico de coletas antes de expurgar as tabelas de coleta 
	exec UspLoadDraHistPerfMinuto
	
	--Expurgo de Rotas
	delete totalizadores
	from db_Irisys_Json.dbo.tb_ml_coleta_totalizador as totalizadores
		join tb_clientes as cli on totalizadores.cmt_cd_transportadora = cli.cli_id_logistics
		left join (
			select max(cmt_cd_coleta) as cmt_cd_coleta
			from db_Irisys_Json.dbo.tb_ml_coleta_totalizador
			group by cmt_cd_transportadora, cmt_cd_servicecenter, cmt_dh_referencia
		)  as ultimo
	on totalizadores.cmt_cd_coleta = ultimo.cmt_cd_coleta
	where (ultimo.cmt_cd_coleta is null and cast(totalizadores.cmt_dh_coleta as date) < cast(getdate() as date))
		  or cli.cli_in_ativo = 0
		  or totalizadores.cmt_dh_coleta <= dateadd(month,-3,getdate())


	--Expurgo de Pacotes
	delete rotas
	from db_Irisys_Json.dbo.tb_ml_coleta_rotas as rotas
		join tb_clientes as cli on rotas.cmr_cd_transportadora = cli.cli_id_logistics
		left join (
			select max(cmr_cd_coleta) as cmr_cd_coleta
			from db_Irisys_Json.dbo.tb_ml_coleta_rotas
			group by cmr_cd_transportadora, cmr_cd_rota, cmr_dh_referencia
		)  as ultimo
	on rotas.cmr_cd_coleta = ultimo.cmr_cd_coleta
	where (ultimo.cmr_cd_coleta is null and cast(rotas.cmr_dh_coleta as date) < cast(getdate() as date))
		  or cli.cli_in_ativo = 0
		  or rotas.cmr_dh_coleta <= dateadd(month,-2,getdate())

	--Expurgo tb_stg_looker_rtt
	delete tb_stg_looker_rtt where DataExtracao <= DATEADD(day,-30,cast(getdate() as date))


end


select cast(cmr_dh_coleta as date) as data, count(*) as qtde
from db_Irisys_Json.dbo.tb_ml_coleta_rotas
group by cast(cmr_dh_coleta as date)
order by 1
GO
